# 1072, Fund t293.1 (Chef 16.11., 17:39/17:41, Probekampf Wölfe auf Automatik: „der hat von der Seite halt angegriffen, aber dann hat
# er sich falsch ausgerichtet“; „gucken tut er ja. Orientiert sein.“): ein Gegner, der seinen Platz am Gegner hält (1072 Schritt 2,
# kampfort.platz_eigen), steht mit dem Rumpf zu seinem Ziel, sobald er angesagt hat oder angreift, nicht nur mit dem Kopf.
# Spielt den Probekampf wie reihe_1305 (Held und Söldner auf Automatik) und misst jede Ansage eines Wolfs am eigenen Platz: steht er
# eine Sekunde nach der Ansage in Ruhe, wie weit zeigt der Rumpf neben das Ziel? Über DREH_MAX Grad: eine Zeile „FEHLER 1072 Dreh“.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/dreh_1072.gd (SEED=7, GEGNER=WOLVES, SEKUNDEN=120,
# DURCHGAENGE=2: danach „Nochmal“ und derselbe Kampf noch einmal; je Durchgang die Bisse, nach denen ein Wolf zurück in die
# Aufstellung ging, Fund t293.1 a, nur Auskunft).
# Exit = Zahl der Fehler (Drehung; die Bisse ohne Platz am Gegner zählen nicht mit).
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const FPS := 30.0
const DREH_MAX := 30.0     # Rumpf bis so weit neben dem Ziel gilt als zum Ziel gedreht (Ruhe halb seitlich: 12°)

var kf
var fehler := 0
var geprueft := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _env(n: String, d: String) -> String:
	return OS.get_environment(n) if OS.get_environment(n) != "" else d


func _lauf() -> void:
	var s := int(_env("SEED", "7"))
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
	kf.mars.find("hero").auto = true
	kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
	while kf.verhuellt:
		await process_frame
	if _env("FLANKE", "") != "":
		await _flanke()
		return
	var zurueck_ges := 0
	for durchgang in int(_env("DURCHGAENGE", "1")):
		if durchgang > 0:     # „Nochmal“ wie im Probekampf (Kampfort.again, probe.gd _start)
			kf.again()
			for i in 4:
				await process_frame
			kf = p.fight
			kf.mars.find("merc").auto = true
			kf.mars.find("hero").auto = true
			kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
			while kf.verhuellt:
				await process_frame
		var r := await _durchgang()
		zurueck_ges += r[1]
		print("Durchgang %d: %d Bisse, %d danach zurück in die Aufstellung" % [durchgang + 1, r[0], r[1]])
	print("DREH1072 Seed %s: %d Fehler bei %d Ansagen am eigenen Platz; %d Bisse ohne Platz am Gegner (nur Auskunft)" % [s, fehler, geprueft, zurueck_ges])
	quit(fehler)


## Ein Kampf bis zum Ende oder SEKUNDEN: prüft die Drehung je Ansage am eigenen Platz und zählt Bisse, nach denen der Wolf nicht am
## Gegner bleibt (t293.1 a: „immer Angriff und völlig zurückweichen“); gibt [Bisse, zurück] zurück
func _durchgang() -> Array:
	var bisse := 0
	var zurueck := 0
	var gebissen := {}
	var letzte = null
	var seit := {}     # Kennung -> [Bild der Ansage, Ziel]
	var n := 0
	var ring_seit := -1
	while n < int(FPS) * int(_env("SEKUNDEN", "120")):
		await process_frame
		n += 1
		if not is_same(kf.shown, letzte) and kf.shown is Dictionary:
			letzte = kf.shown
			var a = kf.shown.get("actor")
			if a != null and String(a).begins_with("wolf") and kf.shown.get("roll") != null and kf.shown.get("target") != null:
				gebissen[String(a)] = n
		for id in gebissen.keys():
			var fb = null
			for k in kf.figures:     # Kennungen der Figuren sind nicht immer String
				if String(k) == id:
					fb = kf.figures[k]
			if fb == null or fb.down or fb.dead_at >= 0:
				gebissen.erase(id)
			elif n - int(gebissen[id]) >= int(FPS / 2) and not fb.unterwegs() and not (fb.tween and fb.tween.is_running()):
				gebissen.erase(id)
				bisse += 1
				var rand := INF     # wie kampfort._platz_am_gegner: Rand des nächsten Gegners bis zur eigenen Mitte
				for o in kf.figures.values():
					if o.fighter.side != "FOES" and o.visible and not o.down and o.dead_at < 0:
						rand = minf(rand, o.clearance(fb.position))
				if rand > kf.KONTAKT_M * fb._scale():
					zurueck += 1
					print("ZURUECK 1072: %s %.1f s, nach dem Biss %.2f m vom nächsten Gegner" % [id, n / FPS, rand])
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if kf.ring_open:
			if ring_seit < 0:
				ring_seit = n
			elif n - ring_seit >= int(kf.RING_MS / 1000.0 * FPS):
				kf._answer_ring(Mars.GOOD)
		else:
			ring_seit = -1
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING" and kf.mars.pilot_next():
			kf.go_on()
		for id in kf.figures:
			var f = kf.figures[id]
			if f.fighter.side != "FOES" or f.down or f.dead_at >= 0:
				continue
			var ziel = f.aim
			if f.angesagt == null or ziel == null or not is_instance_valid(ziel) or not kf.platz_eigen.has(id):
				seit.erase(id)
				continue
			if not seit.has(id) or seit[id][1] != ziel:
				seit[id] = [n, ziel, false]
			if seit[id][2] or n - seit[id][0] < int(FPS) or f.unterwegs() or (f.tween and f.tween.is_running()):
				continue
			seit[id][2] = true
			geprueft += 1
			var vor := Vector3(sin(f.rotation.y), 0.0, cos(f.rotation.y))
			var zu := Vector3(ziel.position.x - f.position.x, 0.0, ziel.position.z - f.position.z)
			var w := rad_to_deg(absf(vor.signed_angle_to(zu, Vector3.UP)))
			var zeile := "%s %.1f s: Rumpf %.0f° neben %s (Platz am Gegner, Reihe %s)" % [id, n / FPS, w, ziel.fighter.id, kf.platz_eigen[id]]
			if w > DREH_MAX:
				fehler += 1
				print("FEHLER 1072 Dreh: " + zeile)
			else:
				print("  " + zeile)
	return [bisse, zurueck]


## FLANKE=1: der Fall des Chefs ohne Kaufwolf nachgestellt (am Rechner stehen die Ersatzwölfe nach dem Biss fast vorn): Wolf 1 hält
## seinen Platz am Gegner neben dem Helden (2,4 m Mitte zu Mitte, FLANKE_M; näher verweigert der Kaufwolf die Drehung zu Recht, sein
## Rumpf schwänge durch den Helden), 30° bis 120° neben der Achse des Kampforts, und sagt auf den Helden an
func _flanke() -> void:
	var h = kf.figures["hero"]
	var f = kf.figures["wolf1"]
	var achse: Vector3 = kf.facing(false)
	for id in kf.figures:     # nur Held und Wolf 1: die Drehung soll nur an der Luft zum Helden hängen, nicht an Gedränge
		if String(id) != "hero" and String(id) != "wolf1":
			kf.figures[id].visible = false
	for w in [30.0, 60.0, 90.0, 120.0]:
		for seite in [1.0, -1.0]:
			var p: Vector3 = h.position + achse.rotated(Vector3.UP, deg_to_rad(w * seite)) * float(_env("FLANKE_M", "2.4"))
			if f.tween and f.tween.is_running():
				f.tween.kill()
			f.position = Vector3(p.x, f.position.y, p.z)
			kf.platz_eigen["wolf1"] = Mars.FRONT
			f.aim = null
			f.announce(f.angesagt, h)
			for i in int(FPS * 2.0):
				await process_frame
			geprueft += 1
			var vor := Vector3(sin(f.rotation.y), 0.0, cos(f.rotation.y))
			var zu := Vector3(h.position.x - f.position.x, 0.0, h.position.z - f.position.z)
			var g := rad_to_deg(absf(vor.signed_angle_to(zu, Vector3.UP)))
			var zeile := "wolf1 %+.0f° neben der Achse: Rumpf %.0f° neben dem Helden" % [w * seite, g]
			if g > DREH_MAX:
				fehler += 1
				print("FEHLER 1072 Dreh: " + zeile)
			else:
				print("  " + zeile)
	print("DREH1072 Flanke: %d Fehler bei %d Stellungen" % [fehler, geprueft])
	quit(fehler)
