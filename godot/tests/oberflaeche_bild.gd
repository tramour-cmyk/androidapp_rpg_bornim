extends SceneTree
# 399.1 Probe mit Bild am Rechner (nicht im Bau): Hauptmenue und Textkasten wie im alten Spiel (Test 130, Chef 14:38, 14:39),
# als PNG nach OBERFLAECHE_AUS (Vorgabe user://). Braucht godot/daten (karten.json, texte.json, held.json, hauptmenue.bild).
# Aufruf: im Ordner godot, mit Fenster (xvfb-run), -s res://tests/oberflaeche_bild.gd --resolution 1080x2340

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
	var welt := Node3D.new()
	root.add_child(welt)
	var grund := ColorRect.new()   # graugruen wie die leere Welt hinter dem Menue (Test 130), damit Luecken auffallen
	grund.color = Color(0.45, 0.5, 0.42)
	grund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(grund)
	var ui := Steuerung.new()
	root.add_child(ui)
	var ebene := CanvasLayer.new()
	ebene.layer = 50
	root.add_child(ebene)
	var menue := Hauptmenue.new(ui)
	ebene.add_child(menue)
	await _bild("menue")
	menue.erschaffung()
	await _bild("erschaffung")
	var e: Erschaffung = menue.get_node("Erschaffung")
	e.volk = "DWARF"; e.klasse = "WIZARD"; e.gekauft = Heldwerte.vorschlag("WIZARD")
	e.baue()
	await _bild("erschaffung_zwerg_magier")
	e.rolle.scroll_vertical = 100000
	await _bild("erschaffung_unten")
	ebene.queue_free()
	ui.sage([{"wer": "Rowena", "text": "Probetext mit Sprecher: zwei Zeilen lang, damit Umbruch, Zeilenhöhe und Rand zu sehen sind."}])
	await _bild("text_sprecher")
	ui.sage([{"text": "Probetext ohne Sprecher: erzählt, darum schräg wie im alten Spiel, ebenfalls zwei Zeilen lang."}])
	await _bild("text_erzaehlt")
	quit(0)
