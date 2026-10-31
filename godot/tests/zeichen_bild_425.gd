extends SceneTree
# 425 Probe mit Bild am Rechner (nicht im Bau): Menue „System“ als Zeichen (oben, mit offener Erklaerung, unten) und der Reiter
# „Test“, als PNG nach OBERFLAECHE_AUS (Vorgabe user://). Braucht godot/daten (texte.json, held.json).
# Aufruf: im Ordner godot, mit Fenster (xvfb-run), -s res://tests/zeichen_bild_425.gd --resolution 1080x2340

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("OBERFLAECHE_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	Bedienung.lade()
	var kl = load("res://klang/klang.gd").new()   # fuer das Zeichen „Schritte“ und die Regler
	kl.name = "Klang"
	root.add_child(kl)
	var z := Zustand.new()
	z.name = "Mira"; z.schritte = 1234; z.siege = 5
	var hw := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	m.reiter = "system"; m.baue()
	await _bild("system_oben")
	var blut: Zeichenknopf = m.inhalt.find_children("*", "Zeichenknopf", true, false).filter(func(b): return b.wort == "Blut")[0]
	m.erklaere_zeichen(blut.wort, blut.erklaerung)
	await _bild("system_erklaerung")
	m.schliesse_erklaerung()
	m.rolle.scroll_vertical = 900
	await _bild("system_unten")
	Testmodus.an = true; Testmodus.geladen = true
	m.reiter = "test"; m.baue()
	m.rolle.scroll_vertical = 0
	await _bild("test_oben")
	quit()
