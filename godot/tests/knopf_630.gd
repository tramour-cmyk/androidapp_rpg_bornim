extends SceneTree
# 630 (Chef 08.11., 15:11: „Abenteuer R bricht um … der Kasten rechts unten muss schon mal größer sein“): in der Erschaffung steht
# „ABENTEUER BEGINNEN ›“ in einer Zeile, nie mitten im Wort; „‹ ZURÜCK“ links in derselben Schriftgroesse; beide ganz im Schirm.
# Dazu jeder Name im Punktekauf ganz (Bild 2: „Geschickli…“). Deutsch und Englisch bei 1080 px (canvas_items/expand: schmaler wird die Spielflaeche nie). Ohne Bildbefehl. Aufruf: im Ordner godot mit -s res://tests/knopf_630.gd
# -> „KNOPF630 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func alle_label(n: Node, aus: Array) -> Array:
	if n is Label: aus.append(n)
	for c in n.get_children(): alle_label(c, aus)
	return aus

func _lauf() -> void:
	Sprache.lade()
	for breite in [1080]:
		for sprache in ["de", "en"]:
			if Sprache.aktiv() != sprache: Sprache.wechsle()
			root.size = Vector2i(breite, 2340)
			var e := ErschaffungBrs.new()   # 470: Seite „Neues Spiel“ nach BRS
			root.add_child(e)
			for i in 4: await process_frame
			var unten: HBoxContainer = e.find_child("Unten", true, false)
			var k := unten.get_children()
			var was := "%s %d px" % [sprache, breite]
			var groesse := []
			for c in k:
				var l := (c as Control).find_child("Text", true, false) as Label
				var g := l.get_theme_font_size("font_size")
				groesse.append(g)
				var tb := l.get_theme_font("font").get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x
				pruefe(l.autowrap_mode == TextServer.AUTOWRAP_OFF, "%s: „%s“ bricht um" % [was, l.text])
				pruefe(l.get_line_count() == 1, "%s: „%s“ in %d Zeilen" % [was, l.text, l.get_line_count()])
				pruefe(tb <= l.size.x + 1.0, "%s: „%s“ breiter (%.0f) als sein Platz (%.0f)" % [was, l.text, tb, l.size.x])
				var r := (c as Control).get_global_rect()
				pruefe(r.position.x >= 0 and r.end.x <= breite + 0.5, "%s: Knopf ragt hinaus: %s" % [was, r])
				var lr := l.get_global_rect()
				pruefe(lr.position.x >= r.position.x - 0.5 and lr.end.x <= r.end.x + 0.5, "%s: „%s“ ragt aus dem Knopf: %s in %s" % [was, l.text, lr, r])
			pruefe(groesse[0] == groesse[1], "%s: Knöpfe verschieden groß: %s" % [was, groesse])
			# Bild 2 der Probe: „Geschickli…“, „Konstituti…“ im Punktekauf; jeder Name ganz, mindestens 13 sp
			for x in alle_label(e.inhalt, []):
				var l := x as Label
				if l.text_overrun_behavior != TextServer.OVERRUN_TRIM_ELLIPSIS or not l.is_visible_in_tree(): continue
				var g := l.get_theme_font_size("font_size")
				var tb := l.get_theme_font("font").get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x
				pruefe(tb <= l.size.x + 0.5, "%s: „%s“ gekürzt (%.0f in %.0f px)" % [was, l.text, tb, l.size.x])
				pruefe(g >= int(round(13.0 * 0.95 * Stil.SP)), "%s: „%s“ kleiner als 13 sp (%d)" % [was, l.text, g])
			print("%s: Knöpfe %s, Schrift %s" % [was, k.map(func(c): return int((c as Control).size.x)), groesse])
			e.queue_free()
			await process_frame
	print("KNOPF630 %d Fehler" % fehler)
	quit(0)
