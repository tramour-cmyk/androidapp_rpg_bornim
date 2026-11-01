# 416.5 (Chef 31.10., Build 143): im Kampf den ganzen Kampfbericht öffnen, dann ließ er sich nicht mehr schließen.
# Echte Eingaben über den Viewport wie am Handy: Tipp auf den Bericht unten öffnet; Fingerbewegung und Loslassen
# dazwischen; Tipp mitten auf den Text schließt; Wischen über den Text schließt nicht.
# Run: godot --headless --path godot -s res://tests/kampfbericht_test.gd   (exit code 0 = alles richtig)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")

var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok     " if ok else "FEHLER ") + what)
	if not ok:
		fails += 1


func _touch(p: Vector2, down: bool) -> void:
	var t := InputEventScreenTouch.new()
	t.position = p
	t.pressed = down
	root.push_input(t, true)
	var m := InputEventMouseButton.new()     # Android meldet den Finger zusätzlich als Maus (emulate_mouse_from_touch)
	m.position = p
	m.global_position = p
	m.button_index = MOUSE_BUTTON_LEFT
	m.pressed = down
	root.push_input(m, true)


func _move(a: Vector2, b: Vector2) -> void:
	var d := InputEventScreenDrag.new()
	d.position = b
	d.relative = b - a
	root.push_input(d, true)
	var m := InputEventMouseMotion.new()
	m.position = b
	m.global_position = b
	m.relative = b - a
	m.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(m, true)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start()
	await _frames(3)
	var ui = p.fight.ui
	for i in 30:
		ui.log_line("Zeile %d: Der Wolf beißt, der Held weicht aus." % i)
	await _frames(2)
	var box: Control = ui.log_area.get_parent()
	var full: Control = ui.full_log
	for round in 3:
		var c: Vector2 = box.get_global_rect().get_center()
		_touch(c, true)
		await _frames(1)
		_touch(c, false)
		await _frames(2)
		_check(full.visible, "Runde %d: Tipp auf den Bericht öffnet ihn" % round)
		await create_timer(0.3).timeout
		var mid: Vector2 = full.get_global_rect().get_center()
		_move(mid, mid + Vector2(3, 2))     # Finger zittert, Maus schwebt
		await _frames(1)
		_move(mid, mid + Vector2(0, 160))   # Wischen über den Text: blättern, nicht schließen
		_touch(mid, true)
		await _frames(1)
		_move(mid, mid + Vector2(0, 160))
		await _frames(1)
		_touch(mid + Vector2(0, 160), false)
		await _frames(2)
		_check(full.visible, "Runde %d: Wischen über den Text lässt ihn offen" % round)
		_touch(mid, true)
		await _frames(1)
		_touch(mid, false)
		await _frames(2)
		_check(not full.visible, "Runde %d: Tipp mitten auf den Text schließt ihn" % round)
	print("Kampfbericht: %d Fehler" % fails)
	quit(1 if fails > 0 else 0)
