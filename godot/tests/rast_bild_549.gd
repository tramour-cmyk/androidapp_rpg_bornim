extends SceneTree
# 549 Probe mit Bild am Rechner (nicht im Bau): das neue Rastfenster (rastfeld.gd), Entwurf A „Tafel“ und B „Ohne Kasten“, je am Feuer
# und an Rowenas Theke, mit den Texten des Spiels. Hintergrund nur Platzhalter (Nacht im Wald mit Feuerschein), im Spiel die Welt.
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

func _grund() -> Control:
	var g := Gradient.new()
	g.set_color(0, Color("4a2a12"))
	g.set_color(1, Color("070a08"))
	g.add_point(0.35, Color("1c1a10"))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.42)
	tex.fill_to = Vector2(1.1, 1.0)
	tex.width = 270; tex.height = 585
	var r := TextureRect.new()
	r.texture = tex
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.stretch_mode = TextureRect.STRETCH_SCALE
	return r

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.gold = 42; z.dazu("raw_meat", 2)
	var teile := func(s: String) -> Array: return s.split(" · ")
	var kurz: Array = teile.call(Sprache.r("short"))
	var lang: Array = teile.call(Sprache.r("long"))
	var feuer := [{"id": "kurz", "name": kurz[0], "dauer": kurz[1], "tut": Sprache.r("shortDoes"), "zeichen": "CLOCK"},
		{"id": "lang", "name": lang[0], "dauer": lang[1], "tut": Sprache.r("longDoes"), "zeichen": "MOON"}]
	var met: Array = teile.call(Sprache.r("meadBuy", [Rast.met_preis(z)]))
	var zimmer: Array = teile.call(Sprache.r("roomBuy", [Rast.ZIMMER_PREIS]))
	var fleisch: Array = teile.call(Sprache.r("meatSell", [12]))
	var theke := [{"id": "met", "name": met[0], "dauer": met[1], "tut": Sprache.r("meadDoes"), "zeichen": "MUG"},
		{"id": "fleisch", "name": fleisch[0], "dauer": fleisch[1], "tut": "2× " + Sprache.t(Sprache.texte["dinge"]["raw_meat"]["name"]), "zeichen": "MEAT"},
		{"id": "lang", "name": zimmer[0], "dauer": zimmer[1], "tut": Sprache.r("roomDoes"), "zeichen": "BED"}]
	for e_ in ["A", "B", "B2"]:   # B2: 557 Vorlage 2 (Chef 16:37: Rast „mit denselben Bausteinen“ wie die anderen Schirme)
		var e: String = "B" if e_ == "B2" else e_
		Spielstaende.vorlage2 = e_ == "B2"
		for ort in ["feuer", "theke"]:
			var g := _grund()
			root.add_child(g)
			var f: Rastfeld
			if ort == "feuer": f = Rastfeld.neu(e, Sprache.r("ask"), "Tag 2 · 21:40 · TP 9 / 22", feuer, Sprache.r("leave"))
			else: f = Rastfeld.neu(e, Sprache.r("tavern"), "%d %s" % [z.gold, Sprache.u("gold")], theke, Sprache.r("leave"), "", [Rast.rowena_sagt(z, "Alrik", false)], "SCHENKE")
			root.add_child(f)
			for i in 4: await process_frame
			var oben := 2340.0; var unten := 0.0
			for l in f.find_children("*", "Label", true, false):
				oben = minf(oben, l.get_global_rect().position.y); unten = maxf(unten, l.get_global_rect().end.y)
			print("TEXT %s %s von %.0f bis %.0f" % [e_, ort, oben, unten])
			await _bild("549_%s_%s" % [e_, ort])
			f.free(); g.free()
			await process_frame
	Spielstaende.vorlage2 = false
	quit(0)
