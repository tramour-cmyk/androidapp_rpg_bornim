extends SceneTree
# 536 ohne Bild: bei der Zielwahl trägt jeder Wählbare seinen Namen, nach langem Drücken alle drei Sekunden lang, danach keiner;
# die Ansage eines Benannten steht über seinem Namen. Aufruf: im Ordner godot mit -s res://tests/namen_536.gd
const Aufruf = preload("res://kampf/aufruf.gd")
const LIMIT_MS := 60000

func _initialize() -> void: _lauf.call_deferred()

func _ruhig(k) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < LIMIT_MS and (k.busy or k.playing or not k.beats.is_empty() or k.verhuellt):
		await process_frame
	for i in 3:
		await process_frame

func _lauf() -> void:
	Engine.time_scale = 30.0
	var f := 0
	var tab = Tabellen.lade()
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST"}):
		print("FEHLER nicht gestartet"); quit(1); return
	await process_frame
	await process_frame
	var k = a.kampf
	await _ruhig(k)
	var ui = k.ui
	var feinde: Array = k.mars.fighters().filter(func(x): return x.side == "FOES" and x.standing()).map(func(x): return String(x.id))
	print("ohne Wahl: Namen ", ui.named.keys())
	if not ui.named.is_empty(): f += 1
	ui._set_pick("target")
	for i in 3: await process_frame
	var ziele: Array = k.mars.targets(k.mars.current()).map(func(x): return String(x.id))
	print("Zielwahl: Ziele ", ziele, " Namen ", ui.named.keys())
	for z in ziele:
		if not ui.named.has(z): f += 1
	ui._set_pick("main")
	ui.names_until = Time.get_ticks_msec() + ui.NAMES_MS
	for i in 3: await process_frame
	print("lang gedrückt: Feinde ", feinde, " Namen ", ui.named.keys())
	for z in feinde:
		if not ui.named.has(z): f += 1
	ui.names_until = 0
	for i in 3: await process_frame
	print("danach: Namen ", ui.named.keys())
	if not ui.named.is_empty(): f += 1
	# 536 (Chef 16:56: „Das erste Fenster … war riesig … Die anderen waren dann okay“): erstes und zweites Erklärfenster gleich hoch
	var satz := "Wolf 1: Anspringen → Probe. Ein Sprung, der umwirft, wenn er trifft."
	ui.show_tip(satz)
	await process_frame
	await process_frame
	var h1: float = ui.tip.size.y
	ui.show_tip(satz)
	await process_frame
	await process_frame
	var h2: float = ui.tip.size.y
	print("Erklärfenster: erstes %.0f px, zweites %.0f px hoch, Schirm %.0f" % [h1, h2, root.get_visible_rect().size.y])
	if absf(h1 - h2) > 2.0: f += 1
	# 536 (Chef 17:02): ein Tipp auf ein Zustandsschild erklärt es (Status.kt desc)
	var wolf = k.mars.find("wolf1")
	wolf.status = {"BLEED": 3}
	k.shown["status"] = k.mars._statuses()
	for i in 3: await process_frame
	var tipp := ""
	if not ui.status_rects.is_empty():
		var ev := InputEventScreenTouch.new()
		ev.pressed = true
		ev.position = (ui.status_rects[0][0] as Rect2).get_center()
		ui._scene_input(ev)
		tipp = ui.tip.text if ui.tip.visible else ""
	print("Zustandsschild: %d Schilder, Tipp „%s“" % [ui.status_rects.size(), tipp])
	if tipp != "Blutend: Schaden jede Runde, Heilung nur halb so stark.": f += 1
	print("NAMEN 536 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
