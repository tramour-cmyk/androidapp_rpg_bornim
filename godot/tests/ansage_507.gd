# 507 (Prüfer Lauf 247: „linke Ansage schwebt“, ohne Strich): Messung ohne Bild am Standbild der Probe (Mira, Söldner Kämpfer,
# Wolfsrudel, Zufall 7, wie probe.gd _still bis zum Zug der Gruppe), je Kampfort: jede Ansage mit Platz, Strich ja/nein und
# wohin der Strich liefe (wie kampf_ui.gd _draw_intents).
# Aufruf: im Ordner godot, ORT=hoehle PLATZ=halle godot --headless --path . -s res://tests/ansage_507.gd; Zeilen ANSAGE507.
# OHNE_ALT=1 stellt den Fall aus Lauf 247 nach (Platz zuvor ohne Strich gewählt). Exit 0 = jede Ansage mit Strich (oder ohne
# Bedarf, gleich über dem Kopf), 1 sonst.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(540, 1170))
	root.size = Vector2i(540, 1170)
	await process_frame
	seed(7)
	var p = Probe.new()
	p.hero_cls = "CLERIC"
	p.still_name = "Mira"
	p.merc_cls = "FIGHTER"
	p.foe = OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	if kf == null:
		print("ANSAGE507 kein Kampf")
		quit(1)
		return
	var wahl_vor := {}
	var t0 := Time.get_ticks_msec()
	var verlauf := func() -> void:
		for id in kf.ui.sign_wahl:
			var w: Array = kf.ui.sign_wahl[id]
			if str(w) != str(wahl_vor.get(id)):
				print("  Wahl %s nach %d ms: Platz %d, Strich %s" % [id, Time.get_ticks_msec() - t0, w[0], w[1]])
				wahl_vor[id] = w.duplicate()
	var bis := Time.get_ticks_msec() + 2500
	while Time.get_ticks_msec() < bis:
		await process_frame
		verlauf.call()
	Engine.time_scale = 8.0
	var until := Time.get_ticks_msec() + 240000
	while Time.get_ticks_msec() < until and (kf.busy or kf.playing or kf.mars.current().side != "PARTY"):
		await process_frame
		verlauf.call()
	Engine.time_scale = 1.0
	# OHNE_ALT=1: jede Ansage hatte im Bild davor ihren Platz ohne Strich (wie nach dem Aufstellen unter der Blende); danach
	# muss sie den Strich wiederbekommen, wo er frei läuft (Prüfer Lauf 247)
	if OS.get_environment("OHNE_ALT") != "":
		for id in kf.ui.sign_wahl:
			kf.ui.sign_wahl[id][1] = false
	await create_timer(0.6).timeout
	await process_frame
	var ui = kf.ui
	var dp: float = ui.dp
	var ohne := 0
	print("ANSAGE507 Ort %s/%s, Szene %s, dp %.2f, Wolf %s" % [kf.ort, kf.platz, str(ui.get_viewport().get_visible_rect().size), dp, preload("res://kampf/figur.gd").ersatz()])
	for id in kf.figures:
		var f = kf.figures[id]
		var foot: Vector2 = ui._foot(f)
		print("  Figur %s: Fuß %s, Höhe %.0f, Kopf %s, sichtbar %s" % [id, foot.round(), ui._tall(f), kf.screen_of(f.head()).round(), f.visible])
	print("  Gegner %s, Ansagen %s, dran %s" % [str(kf.mars.fighters().map(func(f): return [f.id, f.side, f.hp])), str(kf.shown.intents.keys()), kf.mars.current().id])
	for id in ui.sign_of:
		var r: Rect2 = ui.sign_of[id]
		var w = ui.sign_wahl.get(id, [-9, true, 0.0])
		var f = kf.figures[id]
		var foot: Vector2 = ui._foot(f)
		print("  Ansage %s: %s, Platz %d (0 über dem Kopf, 1 links, 2 rechts, 3 unter den Pfoten, -1 höher), Strich %s, Fuß %s" % [id, r, w[0], w[1], foot.round()])
		# wie _draw_intents: von wo nach wo der Strich liefe und ob er gezeichnet wird
		var tall: float = ui._tall(f)
		var head: float = foot.y - tall - 10 * dp
		var s := {"fx": foot.x, "head": head, "top": foot.y - tall * (1.0 if ui._bat(f) else 0.88), "hx": kf.screen_of(f.head()).x,
			"paw": foot.y + tall * 0.12}
		var a: Vector2 = ui._stroke_from(r, foot.x, head)
		var e: Vector2 = ui._stroke_to(r, s)
		var zeichnet: bool = w[1] and a.distance_to(e) > 2 * dp and (r.position.y > foot.y or head - r.end.y > 2 * dp or foot.x < r.position.x or foot.x > r.end.x)
		print("    Strich von %s nach %s, %.0f px, gezeichnet %s" % [a.round(), e.round(), a.distance_to(e), zeichnet])
		# ohne Strich zählt, wo einer nötig wäre (nicht gleich über dem eigenen Kopf)
		if not zeichnet and (r.position.y > foot.y or head - r.end.y > 2 * dp or foot.x < r.position.x or foot.x > r.end.x):
			ohne += 1
	print("ANSAGE507 %s, %d ohne Strich" % ["gut" if ohne == 0 else "FEHLER", ohne])
	quit(1 if ohne else 0)
