extends SceneTree
# 630 (549a, „jetzt“ Chef 07.11., 22:28): die umgebauten Schirme und Fenster ohne Kasten als Bilder am Rechner (Probe, nicht im Bau):
# Erschaffung (oben, unten), Über das Spiel, Menü Held mit Rückfrage Verteilen, Erklärung eines Werts, Trank, Gegenstand, Anleitung,
# Laden: Stück, Menge kaufen und verkaufen, alle gewöhnlichen verkaufen; Brett. PNG nach OBERFLAECHE_AUS.
# Aufruf: im Ordner godot, mit Fenster (xvfb-run), -s res://tests/schirme_630_bild.gd --resolution 1080x2340

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("OBERFLAECHE_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/630_" + n + ".png")
	print("BILD ", aus + "/630_" + n + ".png")

func _weg(n: Node) -> void:
	for c in n.get_children():
		if c is ColorRect and c.find_child("Fenster", true, false): c.queue_free()
	await process_frame

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var grund := ColorRect.new()
	grund.color = Color(0.45, 0.5, 0.42)   # graugruen: Luecken fallen auf
	grund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(grund)
	var ui := Steuerung.new()
	root.add_child(ui)
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 37; z.dazu("potion", 3); z.dazu("herbs", 4)
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	Testmodus.stufe_setzen(hw, z, 2)
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(42), z.neue_uid, 3, "RARE", "FIGHTER"))
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(7), z.neue_uid, 2, "COMMON", "FIGHTER"))
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(9), z.neue_uid, 2, "COMMON", "FIGHTER"))
	var ebene := CanvasLayer.new()
	ebene.layer = 50
	root.add_child(ebene)
	Hauptmenue.vorspann_gezeigt = true
	var menue := Hauptmenue.new(ui)
	ebene.add_child(menue)
	await process_frame
	menue.erschaffung()
	await _bild("erschaffung")
	var e: ErschaffungBrs = menue.get_node("Erschaffung")
	e.rolle.scroll_vertical = 100000
	await _bild("erschaffung_unten")
	e.queue_free()
	menue.ueber()
	await _bild("ueber")
	ebene.queue_free()
	var ebene2 := CanvasLayer.new()
	ebene2.layer = 40
	root.add_child(ebene2)
	var m := Menue.new(hw, z)
	ebene2.add_child(m)
	await _bild("menue_held")
	# 870.4: keine Attributspunkte mehr, also keine Rueckfrage „Punkte verteilen?“
	m.erklaere("STR")
	await _bild("erklaerung")
	await _weg(m)
	m.reiter = "tasche"; m.baue()
	m.frage_ding("potion")
	await _bild("trank")
	await _weg(m)
	Menue.entwurf = ""   # das Gegenstandsfenster ueber dialog (Entwurf B hat ein eigenes, 557)
	m.frage_stueck(z.beutel[0])
	await _bild("gegenstand")
	await _weg(m)
	Menue.entwurf = "B"
	m.anleitung()
	await _bild("anleitung")
	ebene2.queue_free()
	var ebene3 := CanvasLayer.new()
	root.add_child(ebene3)
	var laden := Laden.new(["herbs", "potion"], true)
	var l := LadenSchirm.new(hw, z, laden)
	ebene3.add_child(l)
	await process_frame
	l.menge("potion", true, 2)
	await _bild("laden_kaufen")
	await _weg(l)
	l.menge("potion", false, 3, true)
	await _bild("laden_verkaufen_alle")
	await _weg(l)
	l.stueck(z.beutel[0], false)
	await _bild("laden_stueck")
	await _weg(l)
	l.alle_gewoehnlichen(z.beutel.filter(func(g): return String(g["rarity"]) == "COMMON"))
	await _bild("laden_gewoehnliche")
	await _weg(l)
	ebene3.queue_free()
	var eb := CanvasLayer.new()   # wie spiel.gd: Ebene 40 ueber der Leiste
	eb.layer = 40
	root.add_child(eb)
	var b := BrettSchirm.new(z)
	eb.add_child(b)
	await _bild("brett")
	quit(0)
