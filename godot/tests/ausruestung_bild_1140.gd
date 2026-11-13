extends SceneTree
# 1140 (Chef 13.11., 14:26: Fackel ausgerüstet, im Menü Ausrüstung nicht am Helden; 16:28: Aussehen als Bild, nicht am Handy):
# Reiter Ausrüstung wie im Spiel, links der Held mit Fackel in der Nebenhand, rechts derselbe ohne (Fackel abgelegt), in einem Bild.
# Braucht die Kaufmodelle des Helden (im Lauf der APK, Schritt „Ausrüstungsbild (1140)“); mit Fenster (xvfb-run), 1080 × 2340,
# PNG nach BILD1140_AUS (Vorgabe user://): 1140_mit, 1140_ohne (das Zusammensetzen macht der Schritt)

func _initialize() -> void: _lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 40: await process_frame
	# 1212 (t284, 284.3a: der Teller drehte, das Bild zeigte den Helden von rechts, die Fackel verdeckt): stehend, von vorn etwas zur
	# linken Seite gedreht (rund 30 Grad), so dass Gesicht und Fackelhand zu sehen sind
	for d in root.find_children("*", "SubViewportContainer", true, false):
		if not d is Drehteller: continue
		d.dreht = false
		if d.teller: d.teller.rotation.y = -0.5
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD1140_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	z.name = "Thora"
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	var fackel := z.ausruestung_dazu({"uid": z.neue_uid(), "base": "torch", "rarity": "COMMON", "ilvl": 1, "rolls": []})
	z.beutel.erase(fackel)
	hw.anlegen_nebenhand(fackel)
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	m.reiter = "ausruestung"
	m.baue()
	await _bild("1140_mit")
	hw.ausruestung.erase("OFF_HAND")
	m.baue()
	await _bild("1140_ohne")
	print("AUSRUESTUNG1140 Nebenhand vorher: %s" % fackel.get("base"))
	quit(0)
