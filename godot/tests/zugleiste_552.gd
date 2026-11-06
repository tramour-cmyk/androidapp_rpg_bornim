extends SceneTree
# 552 (Chef 04.11., 00:22, Build 249: „MARS Zugreihenfolge oben fehlt“), Prüfung ohne Grafik: im ganzen Spiel im Hochformat mit
# einem Kamerarand von 90 (Rand.test_oben wie am Handy die sichere Fläche): das schwarze Band der Welt liegt im Kampf über allem;
# die Zugleiste und der ganze Bericht müssen darunter beginnen. Aufruf: im Ordner godot mit -s res://tests/zugleiste_552.gd
# (braucht godot/daten und kampf/daten wie im Bau). Exit 0 = richtig.

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	Rand.test_oben = 90.0
	Testmodus.lade()
	Testmodus.an = true
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	spiel.test_tat("probe", ["WOLVES", "FIGHTER", 3])
	var t0 := Time.get_ticks_msec()
	while spiel.kampf == null and Time.get_ticks_msec() - t0 < 15000: await process_frame
	var k = spiel.kampf
	for i in 120: await process_frame
	var band: CanvasLayer = spiel.get_node_or_null("RandOben")
	var fehler := 0
	var hoch := 0.0
	if band == null or not band.visible:
		print("FEHLER kein Band über der Kamera")
		fehler += 1
	else:
		hoch = (band.get_child(0) as Control).get_global_rect().end.y
	print("Band %.0f (Ebene %d, Kampf Ebene %d), Zugleiste ab %.0f, Bericht ab %.0f" % [hoch, band.layer if band else -1, k.ui.layer, k.ui.turns_top, k.ui.full_log.get_global_rect().position.y])
	if k.ui.turns_top < hoch:
		print("FEHLER Zugleiste unter dem Band")
		fehler += 1
	if k.ui.full_log.get_global_rect().position.y < hoch:
		print("FEHLER Bericht unter dem Band")
		fehler += 1
	print("ZUGLEISTE_552 %d Fehler" % fehler)
	quit(1 if fehler else 0)
