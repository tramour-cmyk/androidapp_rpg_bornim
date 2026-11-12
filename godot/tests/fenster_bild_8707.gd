extends SceneTree
# 870.7 (Umzug BRS Schritt 6, Bild vor dem Umzugspaket B2): Gegenstandsfenster nach dem BRS, drei Stuecke aus der Tasche eines
# Wachsoldaten: gutes Langschwert (Schaden mit Guete, Schadensart, Grundwert, Guete, Fertigkeit), meisterhafter Kettenpanzer
# (Schutzwert mit Guete), episches Kurzschwert mit Zusatzeigenschaften („+1 Dolche“, „+3 % kritisch“). Am Rechner mit Fenster
# (xvfb-run), 1080 × 2340: <BILD8707_AUS>/8707_<n>.png

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 100
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var stuecke := [
		{"uid": z.neue_uid.call(), "base": "longsword", "rarity": "UNCOMMON", "ilvl": 3, "guete": 1, "rolls": [["STR", 1]], "unique": null, "name_seed": 1},
		{"uid": z.neue_uid.call(), "base": "chain_mail", "rarity": "COMMON", "ilvl": 3, "guete": 2, "rolls": [], "unique": null, "name_seed": 2},
		{"uid": z.neue_uid.call(), "base": "shortsword", "rarity": "EPIC", "ilvl": 6, "guete": 0, "rolls": [["SKILL", 1, "Dolche"], ["CRIT", 3], ["HP", 5]], "unique": null, "name_seed": 3},
	]
	for g in stuecke: z.beutel.append(g)
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	var aus := OS.get_environment("BILD8707_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	for i in stuecke.size():
		m.frage_stueck(stuecke[i])
		for k in 30: await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(aus + "/8707_%d.png" % (i + 1))
		print("BILD ", aus + "/8707_%d.png" % (i + 1))
		m.get_child(m.get_child_count() - 1).free()
		await process_frame
	quit(0)
