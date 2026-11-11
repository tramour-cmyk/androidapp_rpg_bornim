extends SceneTree
# 701 (Chef 08.11., 20:37, t270.5): Bild des Gegenstandsfensters wie im Foto des Chefs, ein Amulett „+1 alle Attribute“, dessen Bonus
# die Obergrenze schluckt (ein angelegter Ring „+1 alle Attribute“ fuellt sie schon). Am Rechner mit Fenster (xvfb-run), 1080 × 2340:
#   <BILD701_AUS>/701_fenster.png

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 100
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	hw.anlegen({"uid": z.neue_uid.call(), "base": "ring", "rarity": "RARE", "ilvl": 3, "plus": 0, "rolls": [["ALL_STATS", 1]], "unique": null, "name_seed": 1})
	var neu := {"uid": z.neue_uid.call(), "base": "amulet", "rarity": "RARE", "ilvl": 3, "plus": 0, "rolls": [["ALL_STATS", 1], ["HP", 3]], "unique": null, "name_seed": 2}
	z.beutel.append(neu)
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	m.frage_stueck(neu)
	for i in 30: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD701_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/701_fenster.png")
	print("BILD ", aus + "/701_fenster.png")
	quit(0)
