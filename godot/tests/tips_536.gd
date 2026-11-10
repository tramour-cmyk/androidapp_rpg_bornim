# 536 (Chef 03.11., 23:56, Build 249: „Tip durch Drücken funktioniert nicht“): langes Drücken wie am Handy (Finger und
# nachgebildete Maus) im MARS-Probekampf im Hochformat: auf „Angriff“ erscheint der Hinweis und es wird nicht angegriffen; ein kurzes
# Tippen auf „Abwehr“ wirkt weiter; lang auf eine Ansage eines Gegners erscheint, was sie heißt und was hilft. Prüfung ohne Grafik.
# Aufruf: im Ordner godot mit -s res://tests/tips_536.gd (Exit 0 = richtig)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Tips = preload("res://kampf/marstips.gd")

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _touch(p: Vector2, down: bool) -> void:
	var t := InputEventScreenTouch.new()
	t.position = p
	t.pressed = down
	root.push_input(t, true)
	var m := InputEventMouseButton.new()
	m.device = InputEvent.DEVICE_ID_EMULATION
	m.position = p
	m.global_position = p
	m.button_index = MOUSE_BUTTON_LEFT
	m.pressed = down
	root.push_input(m, true)


func _soll(gut: bool, was: String) -> void:
	print(("ok     " if gut else "FEHLER ") + was)
	if not gut:
		fehler += 1


func _bereit(kf) -> void:
	Engine.time_scale = 8.0
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 20000 and (kf.busy or kf.playing or not kf.beats.is_empty() or kf.ring_open or kf.mars.current().side != "PARTY"):
		await process_frame
	Engine.time_scale = 1.0
	for i in 5:
		await process_frame


func _knopf(ui, wort: String) -> Button:
	for b in ui.orders.find_children("*", "Button", true, false):
		if (b as Button).text == wort.to_upper() and b.is_visible_in_tree():
			return b
	return null


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start()
	for i in 3:
		await process_frame
	var kf = p.fight
	var ui = kf.ui
	await _bereit(kf)
	# 1) lang auf „Angriff“
	var b := _knopf(ui, "Angriff")
	_soll(b != null, "Knopf Angriff da")
	if b != null:
		var c := b.get_global_rect().get_center()
		var vorher: String = ui.pick
		_touch(c, true)
		await create_timer(0.7).timeout
		_touch(c, false)
		for i in 3:
			await process_frame
		_soll(ui.tip.visible and ui.tip.text == Tips.ATTACK[0], "lang auf Angriff: Hinweis „%s…“" % ui.tip.text.left(40))
		_soll(ui.pick == vorher and not kf.busy, "lang auf Angriff greift nicht an (Auswahl %s, busy %s)" % [ui.pick, kf.busy])
	ui.tip.visible = false
	# 2) kurz auf „Abwehr“ wirkt
	b = _knopf(ui, "Abwehr")
	if b != null:
		var c2 := b.get_global_rect().get_center()
		var zug = kf.mars.current()
		_touch(c2, true)
		await process_frame
		_touch(c2, false)
		for i in 5:
			await process_frame
		_soll(kf.busy or kf.mars.current() != zug, "kurz auf Abwehr wirkt")
		_soll(not ui.tip.visible, "kurz auf Abwehr ohne Hinweis")
	await _bereit(kf)
	# 3) lang auf eine Ansage
	var ziel := ""
	var r := Rect2()
	for id in ui.sign_of:
		ziel = id
		r = ui.sign_of[id]
		break
	_soll(ziel != "", "eine Ansage im Bild")
	if ziel != "":
		var kennung := String(kf.shown.intents[ziel][0].id)
		_touch(r.get_center(), true)
		await create_timer(0.7).timeout
		_touch(r.get_center(), false)
		for i in 3:
			await process_frame
		var soll: String = Tips.INTENTS[kennung][0] if Tips.INTENTS.has(kennung) else ""
		_soll(ui.tip.visible and ui.tip.text == soll, "lang auf die Ansage %s von %s: „%s…“" % [kennung, ziel, ui.tip.text.left(40)])
	print("TIPS_536 %d Fehler" % fehler)
	quit(1 if fehler else 0)
