extends SceneTree
# 785.15 (Abgleich alt, SkirmishScreen.kt 340, 494, 1354–1358): das Erklärfenster im Kampf schließt sich mit einem Tipp darauf, ist
# weg, solange der Ring auf ein Tippen wartet, und kommt danach wieder, solange seine 6 s laufen. Ohne Bild, ohne Kaufmodelle.
# Aufruf: im Ordner godot mit -s res://tests/tipp_78515.gd; maßgeblich die Zeile TIPP78515.
const Aufruf = preload("res://kampf/aufruf.gd")
const LIMIT_MS := 60000

var fehler := 0


func pruefe(ok: bool, was: String) -> void:
	print(("gut    " if ok else "FEHLER ") + was)
	if not ok:
		fehler += 1


func _initialize() -> void:
	_lauf.call_deferred()


func _ruhig(k) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < LIMIT_MS and (k.busy or k.playing or not k.beats.is_empty() or k.verhuellt):
		await process_frame
	for i in 3:
		await process_frame


func _lauf() -> void:
	var tab = Tabellen.lade()
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST"}):
		print("TIPP78515 nicht gestartet")
		quit(1)
		return
	await process_frame
	await process_frame
	var k = a.kampf
	Engine.time_scale = 30.0
	await _ruhig(k)
	Engine.time_scale = 1.0
	var ui = k.ui
	ui.show_tip("Probe: ein Erklärfenster.")
	await process_frame
	pruefe(ui.tip.visible, "das Erklärfenster steht")
	pruefe(ui.tip.mouse_filter == Control.MOUSE_FILTER_STOP, "es nimmt Tipps an")
	var ev := InputEventScreenTouch.new()
	ev.pressed = true
	ev.position = ui.tip.size * 0.5
	ui.tip.gui_input.emit(ev)
	await process_frame
	pruefe(not ui.tip.visible, "ein Tipp darauf schließt es")
	# Ring: weg, solange er auf ein Tippen wartet; danach wieder da
	ui.show_tip("Probe: noch ein Erklärfenster.")
	ui.ring_target = "wolf1"
	await process_frame
	await process_frame
	pruefe(not ui.tip.visible, "während des Rings ist es weg")
	ui.ring_target = ""
	await process_frame
	await process_frame
	pruefe(ui.tip.visible, "nach dem Ring kommt es wieder (die 6 s laufen noch)")
	# die Uhr eines geschlossenen Fensters schließt kein späteres
	ui.tip_schliessen()
	await create_timer(4.0).timeout
	ui.show_tip("Probe: ein spätes Erklärfenster.")
	await create_timer(3.0).timeout
	pruefe(ui.tip.visible, "die Uhr des früheren Fensters schließt das spätere nicht")
	await create_timer(3.5).timeout
	pruefe(not ui.tip.visible, "nach 6 s ist es zu")
	print("TIPP78515 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
