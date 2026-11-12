# 784 (654 A, Chef 09.11., 17:46): Kampf-Sollbild „Wolfsrudel, eine Runde“. Spielt den Wolfsrudel der Probe (Held, Söldner,
# drei Wölfe: zwei vorn, einer hinten) am echten Kampfort Runde für Runde und schreibt je Runde jede Meldung (wer, was, ab wann,
# wie lange) und jeden Ortswechsel (wer, von wo nach wo, Weg, Dauer, in wessen Zug). Danach misst es gegen das Sollbild (SOLL unten,
# Maße aus docs/DESIGN-KAMPF.md F9) und meldet je Überschreitung eine Zeile „ÜBER“. Zeit = Spielzeit (Bilder / 30).
# Der Spieler: wählt sofort Angriff auf das erste Ziel, tippt den Ring auf den Schlag (RING_MS). Exit = Zahl der Überschreitungen
# (nur mit STRENG=1; sonst 0, solange der Kampf nicht hängt).
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/sollbild_784.gd
#   (SEED=7, KLASSE=FIGHTER, SOELDNER=CLERIC, GEGNER=WOLVES, RUNDEN=2, STRENG=1, ZEILEN=1 für jede Meldung)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const Signatur = preload("res://kampf/signatur.gd")
const FPS := 30.0

## Sollbild (784 A, Chef 11.11., 12:15; docs/DESIGN-KAMPF.md F9, Tempo „Normal“): Höchstdauer in Sekunden
const SOLL := {
	"held_angriff": 2.4,      # vom Tippen bis der Held wieder an seinem Platz steht (zügig rückwärts heim, Chef 12:09)
	"held_aufstehen": 3.5,    # 702 C (F9): angesprungen, im eigenen Zug aufstehen (Zeile 1,1 s) und gleich angreifen (2,4 s)
	"soeldner": 2.0,          # Zug des Söldners: Schritt zur Seite, Zauber, Zeile beim Aufschlag, zurück
	"wolf_zug": 3.4,          # Zug eines Wolfs, vorn wie hinten (Platztausch): Ansage bis die nächste Figur beginnt
	"wolf_hin": 0.6,          # Wolf vom Platz bis zum Biss
	"wolf_zurueck": 0.8,      # Wolf nach dem Biss ein, zwei Schritte rückwärts, Gesicht zum Helden (F7)
	"ausweichen": 0.5,        # Ausweichen mit Ortswechsel (F5), Schritt zur Seite oder zurück
	"zurechtruecken": 1.0,    # Platztausch: der vordere weicht nach dem Biss auf den hinteren Platz (Zug des Springers, F9)
	"runde": 14.6,            # von Wahl zu Wahl des Helden (Held, Söldner, drei Wölfe)
	"warten": 12.2,           # davon „…“: Held wartet ohne Knöpfe
	"meldung": 1.1,           # eine Textzeile (Ansage, Biss, Beschreibung), ungekürzt (751 A)
}

var kf
var t := 0.0
var meldungen: Array = []      # [t, actor, cue, text]
var wege := {}                 # id -> laufender Ortswechsel {t0, von, zuletzt, still}
var fertige_wege: Array = []   # [t0, t1, id, von, nach, weg, zug]
var wahlen: Array = []         # Zeitpunkte, an denen der Held wählt
var zug_wechsel: Array = []    # [t, id]: wer am Zug ist (current), sobald es wechselt
var ueber := 0
var uhr: Label                 # im Film: Runde, Zeit seit der Wahl, wer am Zug ist


func _initialize() -> void:
	_lauf.call_deferred()


func _env(n: String, d: String) -> String:
	return OS.get_environment(n) if OS.get_environment(n) != "" else d


func _lauf() -> void:
	if DisplayServer.get_name() == "headless":     # Lauf 342: im Film gibt --resolution die Größe vor (1080×2340 war zu langsam, nach 15 min abgebrochen)
		DisplayServer.window_set_size(Vector2i(1080, 2340))
		root.size = Vector2i(1080, 2340)
	var s := int(_env("SEED", "7"))
	var runden := int(_env("RUNDEN", "2"))
	seed(s)
	var p = Probe.new()
	p.hero_cls = _env("KLASSE", "FIGHTER")
	p.merc_cls = _env("SOELDNER", "CLERIC")
	p.foe = _env("GEGNER", "WOLVES")
	root.add_child(p)
	await process_frame
	p._start(s)
	for i in 4:
		await process_frame
	kf = p.fight
	kf.mars.find("merc").auto = true
	var film := DisplayServer.get_name() != "headless"
	if film:
		if not Signatur.wache(kf, self, "Sollbild 784"):     # 457.2: Toon-Licht, Tusche nach Licht, Schatten wie im Spiel
			quit(1)
			return
		_uhr_anlegen()
		kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)     # 1039: Ring nach Filmzeit
	while kf.verhuellt:
		await process_frame
	# im Film sieht man die Knöpfe einen Augenblick, bevor der Spieler tippt (zählt nicht zur Runde)
	var denken := int(int(_env("WAHL_MS", "900" if film else "0")) / 1000.0 * FPS)
	var gewartet := 0
	var letzte = null
	var ring_seit := -1
	var zuletzt_am_zug := ""
	var n := 0
	while n < int(FPS) * 300:
		await process_frame
		n += 1
		t = n / FPS
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		# wer am Zug ist, sagt die gespielte Meldung (der Regelfaden rechnet voraus); dieselbe Zeile zweimal (vor und beim Aufschlag) einmal
		if not is_same(kf.shown, letzte) and kf.shown is Dictionary and kf.shown.has("text"):
			letzte = kf.shown
			var txt := String(kf.shown.text).left(70)
			var wer := str(kf.shown.get("actor"))
			if meldungen.is_empty() or meldungen[-1][3] != txt:
				meldungen.append([t, wer, str(kf.shown.get("cue")), txt])
				if wer != "<null>" and wer != zuletzt_am_zug:
					zuletzt_am_zug = wer
					zug_wechsel.append([t, wer])
		var c = kf.mars.current()
		_wege_messen(zuletzt_am_zug)
		if uhr != null:
			var r := wahlen.size()
			uhr.text = "Runde %d · %.1f s · %s" % [r, t - wahlen[-1], _name(zuletzt_am_zug)] if r > 0 else "Wahl"
		if kf.ring_open:
			if ring_seit < 0:
				ring_seit = n
			elif n - ring_seit >= int(kf.RING_MS / 1000.0 * FPS):
				kf._answer_ring(Mars.GOOD)
		else:
			ring_seit = -1
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				if wahlen.size() > runden:
					break
				if gewartet < denken:
					gewartet += 1
					continue
				gewartet = 0
				wahlen.append(t)
				zuletzt_am_zug = "hero"
				zug_wechsel.append([t, "hero"])
				var ts: Array = kf.mars.targets(c)
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	for id in wege.keys():
		_weg_ende(id, zuletzt_am_zug)
	_bericht(runden)
	print("SOLLBILD784 %d über dem Maß" % ueber)
	quit(ueber if _env("STRENG", "") != "" else 0)


func _uhr_anlegen() -> void:
	var deck := CanvasLayer.new()
	deck.layer = 100
	uhr = Label.new()
	uhr.position = Vector2(24, 150)     # Lauf 342: oben lag sie über der Zugleiste
	uhr.add_theme_font_size_override("font_size", 34)
	uhr.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	uhr.add_theme_color_override("font_outline_color", Color.BLACK)
	uhr.add_theme_constant_override("outline_size", 8)
	deck.add_child(uhr)
	root.add_child(deck)


func _wege_messen(am_zug: String) -> void:
	for id in kf.figures:
		var f = kf.figures[id]
		if not is_instance_valid(f):
			continue
		var q: Vector3 = f.position
		var w = wege.get(id)
		if w == null:
			wege[id] = {"t0": -1.0, "von": q, "zuletzt": q, "still": 0, "zug": am_zug, "weg": 0.0}
			continue
		var d: float = Vector2(q.x - w.zuletzt.x, q.z - w.zuletzt.z).length()
		if d > 0.15 / FPS:     # bewegt sich (über 0,15 m/s)
			if w.t0 < 0.0:
				w.t0 = t - 1.0 / FPS
				w.von = w.zuletzt
				w.zug = am_zug
				w.weg = 0.0
			w.weg += d
			w.still = 0
		elif w.t0 >= 0.0:
			w.still += 1
			if w.still >= 3:
				_weg_ende(id, am_zug)
		w.zuletzt = q


func _weg_ende(id: String, _am_zug: String) -> void:
	var w = wege[id]
	if w.t0 < 0.0:
		return
	var t1: float = t - w.still / FPS
	if w.weg >= 0.2:
		fertige_wege.append([w.t0, t1, id, w.von, w.zuletzt, w.weg, w.zug])
	w.t0 = -1.0
	w.still = 0


func _name(id: String) -> String:
	return {"hero": "Held", "merc": "Söldner"}.get(id, id.replace("wolf", "Wolf "))


func _p(v: Vector3) -> String:
	return "(%.1f|%.1f)" % [v.x, v.z]


func _mass(was: String, ist: float, wer: String, wann: float) -> void:
	var soll: float = SOLL[was]
	if soll < 0.0:
		print("MISST %-14s %5.1f s (noch ohne Maß) %s bei %.1f s" % [was, ist, wer, wann])
		return
	if ist > soll + 0.05:
		ueber += 1
		print("ÜBER %-14s %5.1f s (Soll %.1f) %s bei %.1f s" % [was, ist, soll, wer, wann])


func _bericht(runden: int) -> void:
	if not wahlen.is_empty():
		print("== Eröffnung: %.1f s bis zur ersten Wahl" % wahlen[0])
		for m in meldungen:
			if m[0] < wahlen[0] - 0.01:
				print("      %5.1f %-8s %-14s %s" % [m[0], _name(m[1]) if m[1] != "<null>" else "–", m[2], m[3]])
	for r in mini(runden, wahlen.size() - 1):
		var a: float = wahlen[r]
		var b: float = wahlen[r + 1]
		print("== Runde %d: %.1f–%.1f s, %.1f s von Wahl zu Wahl" % [r + 1, a, b, b - a])
		_mass("runde", b - a, "Runde %d" % (r + 1), a)
		# Züge der Runde: von einem Zugwechsel zum nächsten
		var zuege: Array = []
		for z in zug_wechsel:
			if z[0] >= a - 0.01 and z[0] < b - 0.01:
				zuege.append(z)
		var warten := 0.0
		for i in zuege.size():
			var z0: float = maxf(zuege[i][0], a)
			var z1: float = zuege[i + 1][0] if i + 1 < zuege.size() else b
			var wer: String = zuege[i][1]
			print("  Zug %-8s %5.1f s  (%.1f–%.1f)" % [_name(wer), z1 - z0, z0, z1])
			if wer == "hero":
				_mass("held_aufstehen" if _steht_auf(z0, z1) else "held_angriff", z1 - z0, "Held", z0)
			elif wer == "merc":
				_mass("soeldner", z1 - z0, "Söldner", z0)
				warten += z1 - z0
			else:
				_mass("wolf_zug", z1 - z0, _name(wer), z0)
				warten += z1 - z0
			if _env("ZEILEN", "") != "":
				for m in meldungen:
					if m[0] >= z0 - 0.01 and m[0] < z1 - 0.01:
						print("      %5.1f %-8s %-14s %s" % [m[0], _name(m[1]) if m[1] != "<null>" else "–", m[2], m[3]])
		print("  Held wartet „…“ %.1f s" % warten)
		_mass("warten", warten, "Runde %d" % (r + 1), a)
		for w in fertige_wege:
			if w[0] >= a - 0.01 and w[0] < b - 0.01:
				var dauer: float = w[1] - w[0]
				var art := _art(w)
				print("    Weg %-8s %-15s %5.2f s %4.1f m %s→%s im Zug %s" % [_name(w[2]), art, dauer, w[5], _p(w[3]), _p(w[4]), _name(w[6])])
				if SOLL.has(art):
					_mass(art, dauer, _name(w[2]), w[0])


## 702 C: steht der Held in diesem Zug erst auf (Meldung RISES), gilt das Maß mit Aufstehen
func _steht_auf(z0: float, z1: float) -> bool:
	for m in meldungen:
		if m[0] >= z0 - 0.01 and m[0] < z1 - 0.01 and m[1] == "hero" and m[2] == "RISES":
			return true
	return false


## Art eines Ortswechsels: Wolf hin (näher an die Gruppe), Wolf zurück, Ausweichen (Held, Söldner im Zug eines Gegners), sonst
## Zurechtrücken
func _art(w: Array) -> String:
	var id: String = w[2]
	var zug: String = w[6]
	var von: Vector3 = w[3]
	var nach: Vector3 = w[4]
	var held = kf.figures.get("hero")
	var gruppe: Vector3 = held.home if held != null else Vector3.ZERO
	if id.begins_with("wolf"):
		if zug != id:
			return "zurechtruecken"
		var naeher: bool = Vector2(nach.x - gruppe.x, nach.z - gruppe.z).length() < Vector2(von.x - gruppe.x, von.z - gruppe.z).length()
		return "wolf_hin" if naeher else "wolf_zurueck"
	if zug.begins_with("wolf"):
		return "ausweichen" if w[5] < 2.0 else "zurechtruecken"
	return "held_weg" if id == zug else "zurechtruecken"
