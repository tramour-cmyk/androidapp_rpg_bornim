extends SceneTree
# 549 ohne Bild: das Rastfenster (rastfeld.gd) passt in beiden Entwürfen am Feuer und an der Theke ganz auf den Schirm (1080 × 2340),
# keine Zeile überlappt die nächste, kein Text kleiner als 13 sp. Aufruf: im Ordner godot, --headless -s res://tests/rast_mass_549.gd
# -> „RASTMASS549 n Fehler“

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FEHLER %s %s" % [was, wie])

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.gold = 42
	var teile := func(s: String) -> Array: return s.split(" · ")
	var kurz: Array = teile.call(Sprache.r("short"))
	var lang: Array = teile.call(Sprache.r("long"))
	var feuer := [{"id": "kurz", "name": kurz[0], "dauer": kurz[1], "tut": Sprache.r("shortDoes"), "zeichen": "CLOCK"},
		{"id": "lang", "name": lang[0], "dauer": lang[1], "tut": Sprache.r("longDone"), "zeichen": "MOON", "an": false}]
	var met: Array = teile.call(Sprache.r("meadBuy", [Rast.met_preis(z)]))
	var zimmer: Array = teile.call(Sprache.r("roomBuy", [Rast.ZIMMER_PREIS]))
	var fleisch: Array = teile.call(Sprache.r("meatSell", [12]))
	var theke := [{"id": "met", "name": met[0], "dauer": met[1], "tut": Sprache.r("meadDoes"), "zeichen": "MUG"},
		{"id": "fleisch", "name": fleisch[0], "dauer": fleisch[1], "tut": "2× Rohes Fleisch", "zeichen": "COIN"},
		{"id": "lang", "name": zimmer[0], "dauer": zimmer[1], "tut": Sprache.r("roomDoes"), "zeichen": "BED"}]
	for e in ["A", "B"]:
		for ort in ["feuer", "theke"]:
			var f: Rastfeld
			if ort == "feuer": f = Rastfeld.neu(e, Sprache.r("ask"), "Tag 2 · 21:40 · TP 9 / 22", feuer, Sprache.r("leave"), Sprache.r("shortRested"))
			else: f = Rastfeld.neu(e, Sprache.r("tavern"), "Gold: 42", theke, Sprache.r("leave"), "", [Rast.rowena_sagt(z, "Alrik", false)], "SCHENKE")
			root.add_child(f)
			for i in 6: await process_frame
			var wo := "%s %s" % [e, ort]
			var labels: Array = f.find_children("*", "Label", true, false)
			for l in labels:
				var r: Rect2 = l.get_global_rect()
				pruefe("auf dem Schirm " + wo, r.position.y >= 0 and r.end.y <= 2340 and r.position.x >= 0 and r.end.x <= 1080, "„%s“ %s" % [l.text.left(30), r])
				pruefe("Schrift " + wo, l.get_theme_font_size("font_size") >= int(13 * Stil.SP), "„%s“ %d" % [l.text.left(30), l.get_theme_font_size("font_size")])
				pruefe("eine Zeile hoch genug " + wo, r.size.y < 400, "„%s“ %s" % [l.text.left(30), r.size])
			for i in labels.size():
				for j in range(i + 1, labels.size()):
					var a: Rect2 = labels[i].get_global_rect().grow(-2)
					var b: Rect2 = labels[j].get_global_rect().grow(-2)
					pruefe("ueberlappt " + wo, not a.intersects(b), "„%s“ / „%s“" % [labels[i].text.left(20), labels[j].text.left(20)])
			var gew := []
			f.gewaehlt.connect(func(id): gew.append(id))
			for b in f.find_children("*", "PanelContainer", true, false):
				if b.has_meta("id") and b.mouse_filter == Control.MOUSE_FILTER_STOP: f.gewaehlt.emit(String(b.get_meta("id")))
			# Hoehe jeder Wahl wie ihr Inhalt, keine leeren Flaechen
			for b in f.find_children("*", "PanelContainer", true, false):
				if b.has_meta("id") and (e == "B" or String(b.get_meta("id")) == ""): pruefe("Wahl so hoch wie ihr Inhalt " + wo, b.size.y <= b.get_child(0).get_combined_minimum_size().y + 2, "%s: %.0f statt %.0f" % [b.get_meta("id"), b.size.y, b.get_child(0).get_combined_minimum_size().y])
			var unten := 0.0; var oben := 2340.0
			for c in f.find_children("*", "Control", true, false):
				if c is Label: oben = minf(oben, c.get_global_rect().position.y); unten = maxf(unten, c.get_global_rect().end.y)
			print("%s: Text von %.0f bis %.0f" % [wo, oben, unten])
			pruefe("Wahlen und Weiter " + wo, gew.size() == (2 if ort == "feuer" else 4) and gew.has(""), str(gew))
			f.queue_free()
			await process_frame
	print("RASTMASS549 %d Fehler" % fehler)
	quit(1 if fehler else 0)
