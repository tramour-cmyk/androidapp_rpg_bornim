extends "res://tests/am_zug_565.gd"
# 1296 (Chef 15.11., 14:48, Build 287: „da gibt es den goldenen Hinweis, ich soll ja den Ort wechseln … Ein Wechsel scheint da nicht
# dabei zu sein“): Probekampf Wölfe, der erste Wolf springt an (test_gegnerzug pounce). Protokolliert je Zug, wann Ansage, Eingebung
# und Sprung im Bericht stehen und ob der Held dazwischen am Zug ist; am Zug des Helden: Knopf „Wechsel“ da, aktiv, im Bild.
# Aufruf: im Ordner godot (xvfb-run) ~/godot/godot -s res://tests/wechsel_1296.gd (Messlauf, nicht im Logiksatz: etwa 4 min).
# Befund 15.11.: die erste Ansage (mit Eingebung) kam zu Beginn, die Wölfe sprangen vor dem ersten Zug des Helden.

const Mars = preload("res://regeln/mars.gd")
var zeilen_gesehen := 0

func _bericht(k) -> void:
	var log: Array = k.mars._log
	for i in range(zeilen_gesehen, log.size()):
		var z = log[i]
		print("BERICHT ", str(z.get("text", z) if z is Dictionary else z).substr(0, 140))
	zeilen_gesehen = log.size()

func _knopf(k) -> void:
	k.ui.refresh()
	await process_frame
	await process_frame
	var vp := root.get_visible_rect()
	for b in k.ui.find_children("*", "Button", true, false):
		var bt := b as Button
		if bt.is_visible_in_tree() and bt.text != "":
			var r := bt.get_global_rect()
			print("KNOPF '%s' aktiv %s im Bild %s %s" % [bt.text, not bt.disabled, vp.encloses(r), r])

func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var p = load("res://kampf/probe.tscn").instantiate()
	root.add_child(p)
	await process_frame
	p.hero_cls = "FIGHTER"
	p.still_name = "Alrik"
	p.merc_cls = OS.get_environment("SOELDNER") if OS.get_environment("SOELDNER") != "" else "FIGHTER"
	p.foe = "WOLVES"
	Mars.test_gegnerzug = "pounce"
	p._start(7)
	var t0 := Time.get_ticks_msec()
	while p.fight == null and Time.get_ticks_msec() - t0 < 15000:
		await process_frame
	var k = p.fight
	var alt: Callable = k.mars.listener
	k.mars.listener = func(e):
		print("BERICHT [%s held %s moved %s] %s" % [k.mars.current().id if k.mars.current() else "-", k.mars.find("hero").held, k.mars.find("hero").moved, String(e.text).substr(0, 120)])
		alt.call(e)
	await create_timer(2.5).timeout
	for runde in 6:
		if not await _warte(k, "PARTY", "hero"):
			break
		print("ZUG Held, Runde ", runde, " can_swap ", k.mars.can_swap(k.mars.find("hero")), " Absichten ", k.mars.intents.keys().map(func(x): return [x, k.mars.intents[x][0].id]))
		await _knopf(k)
		_bild("1296_held_%d" % runde)
		_angriff(k)
		await create_timer(0.5).timeout
	print("WECHSEL1296 fertig")
	quit(0)
