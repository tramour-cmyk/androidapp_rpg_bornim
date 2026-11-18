extends SceneTree
# 1587 (Chef 17.11., 16:35, 1571: Zauberstab in der Haupthand angelegt, an der Figur nicht zu sehen): Reiter Ausrüstung wie im Spiel,
# Zauberlehrling mit Zauberstab (Fackel in der Nebenhand wie im Bild des Chefs), dann mit Magierstab. Braucht die Kaufmodelle des
# Helden und daten/waffen/wand.bin, staff.bin (waffen.py); mit Fenster (xvfb-run), PNG nach BILD1587_AUS (Vorgabe user://)

func _initialize() -> void: _lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 40: await process_frame
	for d in root.find_children("*", "SubViewportContainer", true, false):
		if not d is Drehteller: continue
		d.dreht = false
		if d.teller: d.teller.rotation.y = -0.5
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD1587_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	z.name = "Thora"
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Zauberlehrling", z.neue_uid)
	var ding := func(b: String) -> Dictionary:
		var g: Dictionary = z.ausruestung_dazu({"uid": z.neue_uid(), "base": b, "rarity": "COMMON", "ilvl": 1, "rolls": []})
		z.beutel.erase(g)
		return g
	hw.anlegen(ding.call("wand"))
	hw.anlegen_nebenhand(ding.call("torch"))
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	m.reiter = "ausruestung"
	m.baue()
	await _bild("1587_zauberstab")
	hw.anlegen(ding.call("staff"))
	m.baue()
	await _bild("1587_magierstab")
	print("STAB1587 fertig")
	quit(0)
