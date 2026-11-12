extends SceneTree
# 842 Probe mit Bild am Rechner (nicht im Bau): Knopf im Gespraech unter Pims Zeile und unter Osrics Heilung, Verband in der Tasche
# und in Thessas Laden; die Welt dahinter fehlt am Rechner (ohne Dorfmodelle), Grund wie oberflaeche_bild.gd.
# Aufruf: im Ordner godot, mit Fenster (xvfb-run), -s res://tests/knopf_bild_842.gd --resolution 1080x2340; Bilder nach KNOPF842_AUS

func _initialize() -> void: _lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 8: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("KNOPF842_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var grund := ColorRect.new()
	grund.color = Color(0.45, 0.5, 0.42)
	grund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(grund)
	var ui := Steuerung.new()
	root.add_child(ui)
	await process_frame
	ui.sage([{"wer": "Pim", "text": "Thessa verkauft Alchemistenfeuer. Damit kann man sogar zaubern, ohne Magier zu sein!", "knopf": "Schick Pim heim (Überreden)"}])
	ui.weiter()
	await _bild("1_pim")
	ui.sage([{"text": "Ein warmes Licht umhüllt dich. Leben und Mana sind wieder voll.", "knopf": "Kaufen"}])
	ui.weiter()
	await _bild("2_osric")
	ui.schliesse_text()
	var z := Zustand.new()
	z.name = "Mira"; z.gold = 37; z.dazu("bandage", 3); z.dazu("potion", 2)
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	z.brs = hw.als_daten()
	var ebene := CanvasLayer.new()
	ebene.layer = 50
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	m.frage_ding("bandage")
	await _bild("3_tasche")
	m.queue_free()
	var ls := LadenSchirm.new(hw, z, Laden.new(Geschichte.SHOP_STOCK, false))
	ebene.add_child(ls)
	await _bild("4_thessa")
	quit(0)
