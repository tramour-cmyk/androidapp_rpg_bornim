extends SceneTree
# 399.1 Probe mit Bild am Rechner (nicht im Bau): Hauptmenue, Erschaffung, Spielstaende, Ueber, Leiste, Menue und Textkasten wie im
# alten Spiel (Test 130, Chef 14:38, 14:39; Test 132, Chef 16:09),
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
	if Sprache.aktiv() != "de": Sprache.wechsle()   # die Probe auf Deutsch (Helfer: lief auf Englisch)
	# Beispielheld fuer Leiste, Spielstaende und Menue: Elfenmagierin Stufe 4, angeschlagen, vergiftet, Trank, Beute
	var z := Zustand.new()
	z.name = "Mira"; z.gold = 37; z.dazu("potion", 2); z.tag = 3; z.minuten = 21 * 60 + 5; z.leiden["POISON"] = 2
	var hw := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	hw.ep_dazu(int(Heldwerte.regel("ep_fuer_stufe")[4])); hw.tp = 9
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(42), z.neue_uid, 3, "RARE", "WIZARD"))
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(7), z.neue_uid, 2, "UNCOMMON", "WIZARD"))
	ui.leiste.zeige(hw, z, true)
	var alt_platz := Spielstand.platz
	var gesichert := Spielstand.liste()
	for n in [1, 3]:
		Spielstand.platz = n
		Spielstand.speichere(z, hw, {"karte": "inn" if n == 1 else "village", "x": 4, "y": 6, "blick": "UP"})
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
	e.queue_free()
	menue.spielstaende()
	await _bild("spielstaende")
	menue.get_node("Spielstaende").queue_free()
	for n in [1, 3]:   # die Plaetze wie vorher
		Spielstand.loesche(n)
		if not gesichert[n - 1].is_empty():
			var f := FileAccess.open(Spielstand.datei(n), FileAccess.WRITE); f.store_string(JSON.stringify(gesichert[n - 1])); f.close()
	Spielstand.platz = alt_platz
	menue.ueber()
	await _bild("ueber")
	ebene.queue_free()
	await _bild("leiste")
	var ebene2 := CanvasLayer.new()
	ebene2.layer = 40
	root.add_child(ebene2)
	var m := Menue.new(hw, z)
	ebene2.add_child(m)
	await _bild("menue_held")
	m.rolle.scroll_vertical = 100000
	await _bild("menue_held_unten")
	m.reiter = "tasche"; m.baue()
	await _bild("menue_tasche")
	# 399.1 Benutzen und Ausruestung: Kasten zum Heiltrank, der Reiter Ausruestung, Kasten zum Stab in der Haupthand
	m.frage_ding("potion")
	await _bild("menue_trank")
	for c in m.get_children(): if c is ColorRect and c.color.a < 0.9: c.queue_free()
	m.lege_an(z.beutel[0])
	m.reiter = "ausruestung"; m.baue()
	await _bild("menue_ausruestung")
	m.tippe_fach("MAIN_HAND")
	await _bild("menue_fach")
	for c in m.get_children(): if c is ColorRect and c.color.a < 0.9: c.queue_free()
	ebene2.queue_free()
	ui.sage([{"wer": "Rowena", "text": "Probetext mit Sprecher: zwei Zeilen lang, damit Umbruch, Zeilenhöhe und Rand zu sehen sind."}])
	await _bild("text_sprecher")
	ui.sage([{"text": "Probetext ohne Sprecher: erzählt, darum schräg wie im alten Spiel, ebenfalls zwei Zeilen lang."}])
	await _bild("text_erzaehlt")
	quit(0)
