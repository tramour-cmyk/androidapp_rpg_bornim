extends SceneTree
# 399.4 (Chef 28.10., 21:4x: „Ganz oben ist auf dem Handy eine Kamera … nimm oben auch sozusagen den Rand weg“): ohne Bild, mit einem
# angenommenen Rand von 120: schwarzes Band oben, Leiste, Ortsname und Windrose darunter, Aktionsknopf unten unveraendert; Menue und
# Hauptmenue beginnen unter dem Rand. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/rand_399.gd

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	Rand.test_oben = 120.0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var band: CanvasLayer = spiel.get_node_or_null("RandOben")
	var b: Control = band.get_child(0) if band else null
	print("Band: %s %s" % [band != null and band.visible, b.get_global_rect() if b else null])
	if b == null or not band.visible or not is_equal_approx(b.get_global_rect().size.y, 120.0): fehler += 1; print("FEHLER kein Band")
	for c in [spiel.ui.leiste, spiel.ui.ort, spiel.ui.windrose]:
		var r: Rect2 = c.get_global_rect()
		print("%s oben bei %.0f" % [c.name, r.position.y])
		if r.position.y < 120.0: fehler += 1; print("FEHLER %s unter der Kamera" % c.name)
	var schirm: Rect2 = root.get_visible_rect()
	var ak: Rect2 = spiel.ui.aktion_knopf.get_global_rect()
	if not is_equal_approx(ak.end.y, schirm.end.y - 22 * AktionsKnopf.DP): fehler += 1; print("FEHLER Aktionsknopf verschoben: ", ak)
	var m := Menue.new(spiel.held_werte(), spiel.zustand)
	root.add_child(m)
	await process_frame
	print("Menue oben bei %.0f" % m.get_global_rect().position.y)
	if not is_equal_approx(m.get_global_rect().position.y, 120.0): fehler += 1; print("FEHLER Menue")
	m.queue_free()
	Hauptmenue.vorspann_gezeigt = true
	var hm := Hauptmenue.new(null)
	root.add_child(hm)
	await process_frame
	print("Hauptmenue oben bei %.0f" % hm.get_global_rect().position.y)
	if not is_equal_approx(hm.get_global_rect().position.y, 120.0): fehler += 1; print("FEHLER Hauptmenue")
	Rand.test_oben = -1.0
	print("RAND %d Fehler" % fehler)
	quit(1 if fehler else 0)
