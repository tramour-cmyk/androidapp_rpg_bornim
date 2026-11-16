# 1305 (Chef 15.11., 17:18, Probekampf drei Wölfe: „in die letzte Reihe gelaufen und habe den Wolf geschlagen“; reihe_1305 Seed 7
# und 9): ein Treffer eines Gegners ohne Schaden (Modell D, 478) blieb ohne Meldung. Beim Einkreisen tauschte der hintere Wolf
# so in den Regeln nach vorn (863), im Bild biss er nie und blieb hinten stehen. Hier: jeder Angriff eines Gegners (mars._strike,
# ohne Ring) hinterlässt eine Meldung mit Wurf, auch mit 0 Schaden; und wer dabei den Platz tauscht, tut es mit dieser Meldung.
# Regeln am echten Kampfort, ohne Bild.
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/meldung_1305.gd
# Exit 0 = gut, 1 sonst.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")

const VERSUCHE := 80

var fehler := 0


func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok:
		fehler += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	seed(7)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	if kf == null:
		pruefe(false, "kein Kampf")
		quit(1)
		return
	var m = kf.mars
	m.quick_run = true     # ohne Kampfort-Zuhörer, nur der Bericht der Regeln
	var held = m.find("hero")
	var stumm := 0
	var null_schaden := 0
	var tausch_stumm := 0
	for i in VERSUCHE:
		var hinten = null
		for f in m.all:
			if f.side == "FOES" and f.standing() and f.place.x == Mars.BACK:
				hinten = f
				break
		var w = hinten if hinten != null and i % 2 == 0 else null
		if w == null:
			for f in m.all:
				if f.side == "FOES" and f.standing():
					w = f
					break
		held.hp = held.max_hp
		held.prone = false
		held.held = false
		var platz: Vector2i = w.place
		var hp0: int = held.hp
		m._take_log()
		m._strike(w, held, m.I_STAB, Mars.NONE)
		var log: Array = m._take_log()
		var gesagt := log.any(func(e): return e.actor == w.id and e.roll != null)
		if not gesagt:
			stumm += 1
			if w.place != platz:
				tausch_stumm += 1
		if gesagt and held.hp == hp0 and log.any(func(e): return e.actor == w.id and e.roll != null and e.roll[4]):
			null_schaden += 1
	pruefe(stumm == 0, "%d Angriffe der Wölfe, ohne Meldung mit Wurf: %d (davon mit Platztausch %d); Treffer mit 0 Schaden gemeldet: %d" % [VERSUCHE, stumm, tausch_stumm, null_schaden])
	print("MELDUNG1305 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
