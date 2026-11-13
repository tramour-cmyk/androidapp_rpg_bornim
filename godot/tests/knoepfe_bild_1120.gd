extends SceneTree
# 1120 (Chef 13.11., 16:52: „Der muss da randrücken ans Größerzeichen.“): Bild des Gesprächskastens bei Pim (zwei Wahlen) und Osric
# (eine Wahl), je vorher (Aufschrift links in der halben Breite) und nachher (rechtsbündig am Pfeil ›).
# Aufruf: BILD1120_AUS=<ordner> xvfb-run godot --path godot --rendering-driver opengl3 --resolution 1080x2340 -s res://tests/knoepfe_bild_1120.gd
# schreibt <ordner>/1120_<wer>_<vorher|nachher>.png

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var aus := OS.get_environment("BILD1120_AUS")
	if aus == "": aus = "user://"
	root.size = Vector2i(1080, 2340)
	var grund := ColorRect.new()
	grund.color = Color(0.12, 0.13, 0.11)
	grund.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(grund)
	var faelle := [["pim", {"wer": "Pim", "text": "Papa sagt, Goblins haben Angst vor Feuer! Stimmt das?", "knopf": ["Schick Pim heim (Überreden)", "Gib Pim 5 Gold"]}],
		["osric", {"wer": "Osric", "text": "Schau dich ruhig um. Was ich habe, ist gutes Zeug.", "knopf": "Kaufen"}]]
	for f in faelle:
		var ui := Steuerung.new()
		root.add_child(ui)
		await process_frame
		ui.sage([f[1]])
		await process_frame
		ui.weiter()   # Text ganz, Knöpfe stehen
		for i in 4: await process_frame
		var reihe := ui.text_knopf.find_child("Reihe", true, false)
		var labels: Array = reihe.find_children("Text", "Label", true, false) if reihe else []
		for art in ["vorher", "nachher"]:
			for l in labels:
				if (l as Label).text != "NICHT JETZT":
					(l as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if art == "vorher" else HORIZONTAL_ALIGNMENT_RIGHT
			for i in 3: await process_frame
			await RenderingServer.frame_post_draw
			var p := aus.path_join("1120_%s_%s.png" % [f[0], art])
			root.get_texture().get_image().save_png(p)
			print("BILD1120 ", p)
		ui.queue_free()
		await process_frame
	print("BILD1120 fertig")
	quit()
