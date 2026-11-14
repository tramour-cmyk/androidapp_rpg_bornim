extends SceneTree
# 505 Bild (284.7m; Sokrates 13.11., 17:33 „505, Läufe frei“): Menü → Karte im Flüsterwald wie im Spiel, der Held war am Lager
# von Garrick (10, 9) und ging ein Stück nach Süden (bis 10, 14); gesehen ist der Streifen mit Tagessicht (nebel.gd DAY_SIGHT) um
# den Weg, der Rest leeres Pergament. Daneben das Dorf (ohne Nebel, wie alt). Mit Fenster (xvfb-run), 540 × 1170, PNG nach
# BILD505_AUS (Vorgabe user://): 505_wald, 505_dorf. Braucht nur godot/daten (Kartenblatt), läuft am Rechner.

func _initialize() -> void: _lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 30: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD505_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	z.name = "Thora"
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	var k: Dictionary = Kartenreiter.blatt().get("karten", {}).get("forest", {})
	var w := int(k.get("breite", 0)); var h := int(k.get("hoehe", 0))
	var ek := PackedByteArray(); ek.resize(w * h)
	var r := 5.2   # nebel.gd DAY_SIGHT
	for y in h:
		for x in w:
			for wy in range(9, 15):
				if Vector2(x, y).distance_to(Vector2(10, wy)) <= r: ek[y * w + x] = 1
	var s := ""
	var i := 0
	while i < ek.size():   # wie nebel.gd speichert (4 Kacheln je Ziffer)
		var v := 0
		for b in 4:
			if i + b < ek.size() and ek[i + b] == 1: v |= 1 << b
		s += "%x" % v
		i += 4
	z.erkundet["forest"] = s
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	m.ort = {"karte": "forest", "x": 10, "y": 14, "blick": "DOWN"}
	ebene.add_child(m)
	await process_frame
	m.reiter = "karte"
	m.baue()
	await _bild("505_wald")
	m.ort = {"karte": "village", "x": 10, "y": 10, "blick": "DOWN"}
	m.baue()
	await _bild("505_dorf")
	print("KARTENNEBELBILD505 fertig")
	quit(0)
