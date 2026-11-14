# 930.7 (DESIGN-GLUT.md 10 Stufe 2, Prüfpunkt): Film der Glutbedienung am echten Kampfort: der Wachsoldat allein gegen zwei Wölfe,
# drei Runden, Glutsystem an (probe.gd glut_an). Der Spieler tippt durch die Oberfläche (kampf_ui._scene_input, wie ein Finger:
# drücken, loslassen), ein weißer Kreis zeigt jeden Tipp:
#   Runde 1: Tipp auf den Helden (Daumenmenü mit Vorschlag, Vorschau der Schlagfolge), Tipp auf Nachlegen, Tipp auf den Wolf
#   Runde 2: nur ein Tipp auf den Wolf (der Vorschlag spielt, 7.1)
#   Runde 3: Tipp auf den Helden, zweimal Wehr, Tipp auf den Wolf
# Ohne Bild (--headless) misst er die Zeit von Wahl zu Wahl je Runde; GLUT=0 spielt dieselben Runden im alten Kampf (Vergleich F9:
# Rundenzeit nicht länger als heute). Zeilen „GLUT9307 …“; Exit 1, wenn der Kampf hängt oder ein Tipp nichts tat.
# Aufruf im Ordner godot: --headless --fixed-fps 30 -s res://tests/film_glut_9307.gd  (SEED=7, RUNDEN=3, GLUT=0, ZEILEN=1;
# BILDER=<Ordner>: mit Bild je Schritt ein Einzelbild zur eigenen Durchsicht, PROBEBILD)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const Signatur = preload("res://kampf/signatur.gd")
const FPS := 30.0

var kf
var n := 0
var fehler := 0
var kreise: Array = []     # [Ort, Bild]
var deck: Control
var erster_tipp: Array = []     # je Runde die Zeit des ersten Tipps
var tipp_merken := false


func _initialize() -> void:
	_lauf.call_deferred()


func _env(k: String, d: String) -> String:
	return OS.get_environment(k) if OS.get_environment(k) != "" else d


func _warte(bilder: int) -> void:
	for i in bilder:
		await process_frame
		n += 1
		if deck != null:
			deck.queue_redraw()


func _lauf() -> void:
	var film := DisplayServer.get_name() != "headless"
	if not film:
		DisplayServer.window_set_size(Vector2i(1080, 2340))
		root.size = Vector2i(1080, 2340)
	var s := int(_env("SEED", "7"))
	var runden := int(_env("RUNDEN", "3"))
	var glut := _env("GLUT", "1") != "0"
	seed(s)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"     # Wachsoldat (brs_kampf.gd KLASSE_HERKUNFT)
	p.foe = "WOLF2"
	p.ohne_soeldner = true
	p.glut_an = glut
	root.add_child(p)
	await process_frame
	p._start(s)
	for i in 4:
		await process_frame
	kf = p.fight
	if film and not Signatur.wache(kf, self, "Glut 930.7"):
		quit(1)
		return
	kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
	_deck_anlegen()
	var versatz := Engine.get_process_frames() / FPS - n / FPS     # Zeit 0 des Films gegen n (zum Schneiden)
	while kf.verhuellt:
		await _warte(1)
	var wahlen: Array = []
	var denken := int(0.9 * FPS) if film else 0
	while n < int(FPS) * 240:
		await _warte(1)
		_ring()
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if kf.busy or kf.playing or not kf.beats.is_empty() or kf.mars.outcome != "ONGOING":
			continue
		if wahlen.size() >= runden:
			wahlen.append(n / FPS)
			break
		wahlen.append(n / FPS)
		await _warte(denken)
		var r := wahlen.size()
		tipp_merken = true
		if not glut:
			var ts: Array = kf.mars.targets(kf.mars.current())
			kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
			continue
		var f = kf.mars.current()
		var ziel = kf.mars.gk.vorschlag_ziel(f)
		if ziel == null:
			kf.order(["GLUT", {"tun": "warten", "haltung": "wehr"}])
			continue
		if r == 1 or r == 3:
			await _tipp(_auf(kf.figures[f.id]), "Held")
			await _warte(int(1.2 * FPS) if film else 2)
			var art: String = "nach" if r == 1 else "wehr"
			for j in (1 if r == 1 else 2):
				await _tipp(_zeichen(art), art)
				await _warte(int(0.8 * FPS) if film else 2)
			await _warte(int(0.6 * FPS) if film else 0)
			await _knips("runde%d-plan" % r)
			print("GLUT9307 Runde %d Plan %s, Vorschau %s" % [r, str(kf.ui.glut.plan(f, ziel.id)), str(kf.mars.gk.vorschau(f, kf.ui.glut.plan(f, ziel.id)))])
		await _tipp(_auf(kf.figures[ziel.id]), "Wolf")
		await _warte(2)
		for j in 6:     # BILDER: alle 0,5 s des Zugs
			if _env("BILDER", "") == "":
				break
			await _warte(int(0.5 * FPS))
			await _knips("runde%d-%d" % [r, j])
		if not kf.busy and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			print("GLUT9307 FEHLER Runde %d: der Tipp auf den Wolf spielte keinen Zug" % r)
			fehler += 1
			break
	var summe := 0.0
	for i in range(1, wahlen.size()):
		var d: float = wahlen[i] - wahlen[i - 1]
		summe += d
		print("GLUT9307 Runde %d %.1f s (%s)" % [i, d, "Glut" if glut else "alt"])
		# G4 (bis 15 s): je Runde ein Schnitt vom ersten Tipp bis zur nächsten Wahl, höchstens 5 s
		var a: float = (erster_tipp[i - 1] if erster_tipp.size() >= i else wahlen[i - 1]) - 0.4
		print("GLUT9307 Schnitt %d %.2f %.2f" % [i, a + versatz, minf(5.0, wahlen[i] - a)])
	if wahlen.size() > 1:
		print("GLUT9307 Mittel %.1f s je Runde (%s), %d Runden, Ausgang %s" % [summe / (wahlen.size() - 1), "Glut" if glut else "alt", wahlen.size() - 1, kf.mars.outcome])
	if glut:
		print("GLUT9307 Zähler %s" % str(kf.mars.gk.zaehler))
	if _env("ZEILEN", "") != "":
		for e in kf.mars._log:
			print("  %-10s %-26s %s" % [str(e.actor), str(e.cue), String(e.text).left(60)])
	if n >= int(FPS) * 240:
		fehler += 1
		print("GLUT9307 FEHLER: der Kampf hängt")
	print("GLUT9307 %d Fehler" % fehler)
	await _warte(int(1.5 * FPS) if film else 0)
	quit(1 if fehler > 0 else 0)


func _knips(name: String) -> void:
	var dir := _env("BILDER", "")
	if dir == "" or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/%s.png" % [dir, name])


## Ein Ring gilt gut, wenn der große auf dem kleinen liegt (der Spieler trifft ihn; Wehr: langsamer)
var _ring_seit := -1
func _ring() -> void:
	if kf.ring_open:
		if _ring_seit < 0:
			_ring_seit = n
		elif n - _ring_seit >= int(kf.RING_MS * kf.ring_faktor / 1000.0 * FPS):
			kf._answer_ring(Mars.GOOD)
	else:
		_ring_seit = -1


func _auf(fig) -> Vector2:
	return kf.ui._foot(fig) - Vector2(0, kf.ui._tall(fig) * 0.45)


func _zeichen(art: String) -> Vector2:
	var r = kf.ui.glut.symbol_rects.get(art)
	if r == null:
		print("GLUT9307 FEHLER: Zeichen %s nicht im Daumenmenü" % art)
		fehler += 1
		return Vector2(-100, -100)
	return (r as Rect2).get_center()


## Ein Finger: drücken, drei Bilder halten, loslassen (kurzer Tipp, 536), mit Kreis im Film
func _tipp(p: Vector2, was: String) -> void:
	if tipp_merken:
		erster_tipp.append(n / FPS)
		tipp_merken = false
	kreise.append([p, n])
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.position = p
	ev.pressed = true
	ev.device = 0
	kf.ui._scene_input(ev)
	await _warte(3)
	var ev2 := ev.duplicate()
	ev2.pressed = false
	kf.ui._scene_input(ev2)
	print("GLUT9307 Tipp %s bei %.1f s (%d|%d)" % [was, n / FPS, int(p.x), int(p.y)])


func _deck_anlegen() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 120
	deck = Control.new()
	deck.set_anchors_preset(Control.PRESET_FULL_RECT)
	deck.mouse_filter = Control.MOUSE_FILTER_IGNORE
	deck.draw.connect(func():
		for k in kreise:
			var q: float = (n - int(k[1])) / (0.5 * FPS)
			if q >= 0.0 and q < 1.0:
				deck.draw_arc(k[0], (14.0 + 16.0 * q) * kf.ui.dp, 0, TAU, 40, Color(1, 1, 1, 0.85 * (1.0 - q)), 3.0 * kf.ui.dp, true))
	cl.add_child(deck)
	root.add_child(cl)
