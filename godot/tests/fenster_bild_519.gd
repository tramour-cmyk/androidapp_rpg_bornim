extends SceneTree
# 519 Probe mit Bild am Rechner (nicht im Bau): Spielmenue, Fenster eines Gegenstands wie in der Aufnahme des Chefs (23:13,
# „Göttlicher Ring des Eisernen Richters“) und ein Schwert mit vier Knoepfen; Held und Ringe wie tests/fenster_519.gd.
# PNG nach OBERFLAECHE_AUS. Aufruf: im Ordner godot, mit Fenster (xvfb-run), --resolution 1080x2340

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("OBERFLAECHE_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func ring(z: Zustand, saat: int, rolls: Array) -> Dictionary:
	return {"uid": z.neue_uid.call(), "base": "ring", "rarity": "DIVINE", "ilvl": 9, "plus": 0, "rolls": rolls, "unique": null, "name_seed": saat}

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 100
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var saat := 0
	for s in 200:
		if Beute.name(ring(z, s, [])).ends_with("Eisernen Richters"): saat = s; break
	hw.anlegen(ring(z, saat + 1, [["DEX", 2], ["STR", 2]]))
	var neu := ring(z, saat, [["ALL_STATS", 1], ["DEX", 2], ["CHA", 2]])
	z.beutel.append(neu)
	var schwert := Beute.erzeuge_mit_uid(KotlinZufall.new(5), z.neue_uid, 9, "DIVINE", "FIGHTER")
	z.beutel.append(schwert)
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	m.frage_stueck(neu)
	await _bild("519_ring")
	m.get_child(m.get_child_count() - 1).free()
	m.frage_stueck(schwert)
	await _bild("519_schwert")
	quit(0)
