# 545 (Chef 04.11., 00:01, Build 249: „Button Gegner killen oder Suicide ohne Funktion“): im Testmodus Haken (gewinnen) und Kreuz
# (verlieren) im MARS-Probekampf mit echten Eingaben über den Viewport wie am Handy (Finger und nachgebildete Maus); danach muss
# der Kampf gewonnen bzw. verloren sein. Ohne Bild. Aufruf: im Ordner godot mit -s res://tests/testende_545.gd (Exit 0 = richtig)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const AufrufS = preload("res://kampf/aufruf.gd")

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _touch(p: Vector2, down: bool) -> void:
	var t := InputEventScreenTouch.new()
	t.position = p
	t.pressed = down
	root.push_input(t, true)
	var m := InputEventMouseButton.new()     # Android meldet den Finger zusätzlich als Maus (emulate_mouse_from_touch)
	m.device = InputEvent.DEVICE_ID_EMULATION
	m.position = p
	m.global_position = p
	m.button_index = MOUSE_BUTTON_LEFT
	m.pressed = down
	root.push_input(m, true)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


## [welt]: wie der Reiter „Test“ den MARS-Probekampf startet (spiel.gd kampf_im_wald mit probe: aufruf.gd, Blende davor), sonst probe.gd
func _ein(gewinnen: bool, welt := false) -> void:
	var p
	var kf
	if welt:
		p = AufrufS.new()
		root.add_child(p)
		var h := Testmodus.probeheld("FIGHTER", 3)
		p.starte("RUDEL", h, Testmodus.probeheld("CLERIC", 3), "wald", "tag", 2, -1, -1, -1, Callable(), {"blende": true})
		var w := 0
		while (p.kampf == null or not p.kampf.is_inside_tree()) and w < 60:
			await process_frame
			w += 1
		kf = p.kampf
	else:
		p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = "WOLVES"
		root.add_child(p)
		await process_frame
		p._start()
		await _frames(3)
		kf = p.fight
	print("Weg: %s" % ("Welt (aufruf.gd, Blende)" if welt else "probe.gd"))
	var ui = kf.ui
	# bis die Gruppe dran ist und die Knöpfe stehen (höchstens 60 s im Zeitraffer)
	Engine.time_scale = 8.0
	var t := 0.0
	while t < 60.0 and (kf.busy or kf.playing or not kf.beats.is_empty() or kf.ring_open or ui.win_rect.size.x <= 0.0):
		await process_frame
		t += 1.0 / 60.0 * Engine.time_scale
	Engine.time_scale = 1.0
	await _frames(2)
	var r: Rect2 = ui.win_rect if gewinnen else ui.lose_rect
	if r.size.x <= 0.0:
		fehler += 1
		print("FEHLER %s: Knopf nicht gezeichnet (Testmodus %s, busy %s)" % ["Haken" if gewinnen else "Kreuz", Testmodus.ist_an(), kf.busy])
	else:
		var c := r.get_center()
		var m := InputEventMouseMotion.new()
		m.position = c
		m.global_position = c
		root.push_input(m, true)
		await _frames(1)
		var unter = root.gui_get_hovered_control()
		print("%s bei %s, darunter %s" % ["Haken" if gewinnen else "Kreuz", c, unter.get_path() if unter else ""])
		for k in [["Würfel", ui.dice_rect], ["Raster", ui.grid_rect]]:
			var m2 := InputEventMouseMotion.new()
			m2.position = (k[1] as Rect2).get_center()
			m2.global_position = m2.position
			root.push_input(m2, true)
			await _frames(1)
			var u2 = root.gui_get_hovered_control()
			print("%s bei %s, darunter %s" % [k[0], m2.position, u2.get_path() if u2 else ""])
		_touch(c, true)
		await _frames(1)
		_touch(c, false)
		t = 0.0
		Engine.time_scale = 8.0
		while t < 40.0 and kf.mars.outcome == "ONGOING":
			await process_frame
			t += 1.0 / 60.0 * Engine.time_scale
		Engine.time_scale = 1.0
		var soll := "WON" if gewinnen else "LOST"
		if kf.mars.outcome != soll:
			fehler += 1
			print("FEHLER %s: Ausgang %s statt %s (end_asked %s)" % ["Haken" if gewinnen else "Kreuz", kf.mars.outcome, soll, kf.end_asked])
		else:
			print("ok     %s: %s" % ["Haken" if gewinnen else "Kreuz", soll])
	if is_instance_valid(kf):
		kf.queue_free()
	if is_instance_valid(p):
		p.queue_free()
	await _frames(4)


func _lauf() -> void:
	Testmodus.geladen = true
	Testmodus.an = true
	DisplayServer.window_set_size(Vector2i(1080, 2340))     # Hochformat wie am Handy
	root.size = Vector2i(1080, 2340)
	await _frames(2)
	await _ein(true)
	await _ein(false)
	await _ein(true, true)
	await _ein(false, true)
	print("TESTENDE 545 %s" % ("ok" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
