extends SceneTree
# 550 (Chef 04.11., 00:19, Build 249: „erstes Mal Heilkräuter gepflückt ein riesen Kasten als Einblendung. Dann ab dem 2. Mal
# normale Größe“): ohne Bild; der kurze Hinweis (steuerung.gd kurz) hat beim ersten Mal dieselbe Groesse wie beim zweiten und
# hoechstens zwei Zeilen Hoehe. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/hinweis_550.gd
# -> „HINWEIS n Fehler“

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var ui: Steuerung = spiel.ui
	var t := "Du pflückst Heilkräuter (+2)."
	var groessen := []
	for mal in 3:
		ui.kurz(t)
		await process_frame   # das erste Bild nach dem Hinweis
		groessen.append(ui.notiz_feld.size)
		print("%d. Mal: %s" % [mal + 1, ui.notiz_feld.size])
	var lb := ui.notiz_feld.get_child(0) as Label
	var zeile := lb.get_line_height()
	if not groessen[0].is_equal_approx(groessen[1]): fehler += 1; print("FEHLER erstes Mal %s, zweites Mal %s" % [groessen[0], groessen[1]])
	for g in groessen:
		if g.y > zeile * 2 + 40 * AktionsKnopf.DP: fehler += 1; print("FEHLER Kasten zu hoch: %s (Zeile %d)" % [g, zeile])
	print("HINWEIS %d Fehler" % fehler)
	quit(1 if fehler else 0)
