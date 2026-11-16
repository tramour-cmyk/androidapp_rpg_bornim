# 1305 (Chef 15.11., 17:18, Probekampf drei Wölfe, Kämpfer mit Schwert und Schild: „in die letzte Reihe gelaufen und habe den
# Wolf geschlagen“): spielt den Probekampf wie sollbild_784 und prüft bei jeder Wahl des Helden, ob jedes Ziel, das die Regeln
# erlauben (mars.targets: Nahkampf trifft vorn, solange dort einer steht), auch im Bild vorn steht: kein erlaubtes Ziel steht
# weiter vom Helden weg als ein Gegner, der in den Regeln hinten steht. Meldet je Fall eine Zeile „FEHLER 1305“.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/reihe_1305.gd (SEED=7, RUNDEN=6, KLASSE=FIGHTER,
# SOELDNER=CLERIC, GEGNER=WOLVES, ZIEL=letztes: der Held schlägt das letzte erlaubte Ziel statt des ersten, ZEILEN=1: jede
# Meldung mit Reihe und Abstand der Wölfe). Vor dem Bau: Seed 7 und 9 je 2 Fehler (Einkreisen, Treffer ohne Meldung)
# Exit = Zahl der Fehler.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const FPS := 30.0

var kf
var fehler := 0


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
	kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
	while kf.verhuellt:
		await process_frame
	var wahlen := 0
	var ring_seit := -1
	var n := 0
	var letzte = null
	while n < int(FPS) * 400:
		await process_frame
		n += 1
		if _env("ZEILEN", "") != "" and not is_same(kf.shown, letzte) and kf.shown is Dictionary:
			letzte = kf.shown
			var pl := []
			for id in kf.shown.get("places", {}):
				if String(id).begins_with("wolf"):
					var q: Vector2i = kf.shown.places[id]
					pl.append("%s%s %.1f" % [id, "v" if q.x == Mars.FRONT else "h", _tiefe(id) if kf.figures.has(id) else -1.0])
			print("  %.1f %s %s | %s | %s" % [n / FPS, str(kf.shown.get("actor")), str(kf.shown.get("cue")), String(kf.shown.get("text", "")).left(60) + " roll=" + str(kf.shown.get("roll") != null) + " tgt=" + str(kf.shown.get("target")), " ".join(pl)])
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
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
				continue
			if wahlen >= int(_env("RUNDEN", "6")):
				break
			wahlen += 1
			var c = kf.mars.current()
			var ts: Array = kf.mars.targets(c)
			_pruefen(c, ts, wahlen, n / FPS)
			var ziel = null
			if not ts.is_empty():
				ziel = ts[-1] if _env("ZIEL", "") == "letztes" else ts[0]
			kf.order(["attack", ziel.id] if ziel != null else ["wait"])
	print("REIHE1305 Seed %s: %d Fehler, %d Wahlen" % [s, fehler, wahlen])
	quit(fehler)


## Tiefe einer Figur vom Helden aus (Meter am Boden zum Helden)
func _tiefe(id: String) -> float:
	var h = kf.figures["hero"]
	var f = kf.figures[id]
	return Vector2(f.position.x - h.position.x, f.position.z - h.position.z).length()


func _pruefen(c, ts: Array, wahl: int, t: float) -> void:
	if c.ranged():
		return
	var zeile := []
	var hinten_min := INF
	for x in kf.mars.fighters():
		if x.side == "FOES" and x.standing() and kf.figures.has(x.id):
			zeile.append("%s %s %.1f m%s" % [x.id, "vorn" if x.place.x == Mars.FRONT else "hinten", _tiefe(x.id),
				" (Platz neu)" if kf.figures[x.id].platz_neu else ""])
			if x.place.x == Mars.BACK and not ts.has(x):
				hinten_min = minf(hinten_min, _tiefe(x.id))
	print("Wahl %d (%.1f s): %s" % [wahl, t, ", ".join(zeile)])
	for x in ts:
		if not kf.figures.has(x.id):
			continue
		var d := _tiefe(x.id)
		if d > hinten_min + 0.3:
			fehler += 1
			print("FEHLER 1305: Wahl %d, Ziel %s (in den Regeln vorn) steht %.1f m weg, ein Gegner hinten nur %.1f m" % [wahl, x.id, d, hinten_min])
		elif x.place.x == Mars.BACK:
			print("Hinweis 1305: Wahl %d, Ziel %s steht in den Regeln hinten (vorn steht keiner mehr), %.1f m weg" % [wahl, x.id, d])

