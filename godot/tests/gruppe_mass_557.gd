extends SceneTree
# 557 ohne Bild: die Schirme der Gruppe 557 im Entwurf B (Spielstände, Wechselliste, Gegenstandsfenster, Kapitelende, Brauen,
# Mengenkasten) passen ganz auf den Schirm (1080 × 2340), kein Text überlappt einen anderen, keine Schrift unter 13 sp, jede
# antippbare Fläche mindestens 48 dp hoch. Aufruf: im Ordner godot, --headless -s res://tests/gruppe_mass_557.gd -> „GRUPPE557 n Fehler“

var fehler := 0
const DP := AktionsKnopf.DP

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FEHLER %s %s" % [was, wie])

func _initialize() -> void: _lauf.call_deferred()

func _messe(wo: String, wurzel: Node) -> void:
	for i in 6: await process_frame
	var labels: Array = wurzel.find_children("*", "Label", true, false).filter(func(l): return l.is_visible_in_tree() and l.text.strip_edges() != "")
	for l in labels:
		var r: Rect2 = l.get_global_rect()
		pruefe("auf dem Schirm " + wo, r.position.y >= 0 and r.end.y <= 2340 and r.position.x >= 0 and r.end.x <= 1080, "„%s“ %s" % [l.text.left(30), r])
		pruefe("Schrift " + wo, l.get_theme_font_size("font_size") >= int(13 * Stil.SP) - 1, "„%s“ %d" % [l.text.left(30), l.get_theme_font_size("font_size")])
	for i in labels.size():
		for j in range(i + 1, labels.size()):
			var a: Rect2 = labels[i].get_global_rect().grow(-2)
			var b: Rect2 = labels[j].get_global_rect().grow(-2)
			pruefe("ueberlappt " + wo, not a.intersects(b), "„%s“ / „%s“" % [labels[i].text.left(20), labels[j].text.left(20)])
	for p in wurzel.find_children("*", "PanelContainer", true, false):
		if p.is_visible_in_tree() and p.mouse_filter == Control.MOUSE_FILTER_STOP and p.get_theme_stylebox("panel") is StyleBoxEmpty:
			pruefe("Tippflaeche " + wo, p.size.y >= 48 * DP - 1, "%.0f" % p.size.y)
	print("%s: %d Texte" % [wo, labels.size()])

# Vorlage 2 (Chef 14:21–14:26): dieselben Schirme mit Spielstaende.vorlage2; dazu Abbrechen sichtbar, Knopf am Inhalt
func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	for v2 in [false, true]:
		Spielstaende.vorlage2 = v2
		print("— Vorlage 2" if v2 else "— B")
		await _runde(v2)
	Spielstaende.vorlage2 = false
	print("GRUPPE557 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func _abbrechen(w: Node) -> bool:
	return w.find_children("*", "Label", true, false).any(func(l): return l.is_visible_in_tree() and l.text.contains("ABBRECHEN"))

func _runde(v2: bool) -> void:
	Spielstaende.entwurf = "B"; Menue.entwurf = "B"; KapitelSchirm.entwurf = "B"; LadenSchirm.entwurf_b = "B"
	var s := Spielstaende.new()
	root.add_child(s)
	await _messe("Spielstaende", s)
	if v2:
		Spielstand.platz = 1
		var probe := Zustand.new(); probe.name = "Mira"
		var gesichert := Spielstand.liste()
		if gesichert[0].is_empty():
			Spielstand.speichere(probe, Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, probe.neue_uid), {"karte": "village", "x": 4, "y": 6, "blick": "UP"})
		s.frage_loeschen(Spielstand.liste()[0])
		var f: Node = s.get_child(s.get_child_count() - 1)
		await _messe("Rueckfrage Loeschen", f)
		pruefe("Rueckfrage ohne Kasten", f.find_children("*", "PanelContainer", true, false).all(func(p): return p.get_theme_stylebox("panel") is StyleBoxEmpty), "")
		pruefe("Rueckfrage mit Abbrechen", _abbrechen(f))
		f.free()
		if gesichert[0].is_empty(): Spielstand.loesche(1)
	s.queue_free()
	var z := Zustand.new()
	var hw := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	for r in ["UNCOMMON", "RARE", "VERY_RARE"]: z.ausruestung_dazu({"uid": 0, "base": "robe", "rarity": r, "ilvl": 3, "plus": 0, "rolls": [["DEX", 2], ["AC", 1], ["CON", 4]], "unique": null, "name_seed": 3})
	z.ausruestung_dazu({"uid": 0, "base": "plate", "rarity": "COMMON", "ilvl": 2, "plus": 0, "rolls": [], "unique": null, "name_seed": 2})
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.reiter = "ausruestung"; m.baue()
	m.waehle("CHEST")
	await _messe("Wechselliste", m.get_child(m.get_child_count() - 1))
	pruefe("Robe mit Wert", Menue.listen_zeile_b(z.beutel[0]).contains("GES"), Menue.listen_zeile_b(z.beutel[0]))
	m.get_child(m.get_child_count() - 1).free()
	for g in z.beutel:
		m.frage_stueck(g)
		await _messe("Fenster " + Beute.name(g), m.get_child(m.get_child_count() - 1))
		if v2: pruefe("Fenster mit Abbrechen", _abbrechen(m.get_child(m.get_child_count() - 1)))
		m.get_child(m.get_child_count() - 1).free()
	if v2:
		m.frage_wegwerfen(z.beutel[0])
		await _messe("Rueckfrage Wegwerfen", m.get_child(m.get_child_count() - 1))
		pruefe("Wegwerfen mit Abbrechen", _abbrechen(m.get_child(m.get_child_count() - 1)))
		m.get_child(m.get_child_count() - 1).free()
	var wk := Vergleich.wirkung(hw, z.beutel[0])
	print("Wirkung ", wk)
	pruefe("Wirkung je Bonus", wk.has("DEX") and wk.has("CON") and int(wk["CON"][1]) <= 4, str(wk))
	m.queue_free()
	var k := KapitelSchirm.new(hw, Geschichte.CHAPTER_END_TEXT)
	root.add_child(k)
	await _messe("Kapitelende", k)
	pruefe("Weiter da", k.find_child("Weiter", true, false) != null)
	var wy: float = (k.find_child("Weiter", true, false) as Control).get_global_rect().position.y
	print("Kapitelende: Weiter bei %.0f von 2340" % wy)
	if v2: pruefe("Weiter folgt dem Text (Vorlage 2)", wy < 2340 - 160 * DP, "%.0f" % wy)
	k.queue_free()
	z.gold = 23; z.dazu("herbs", 7); z.dazu("potion", 2)
	var l := LadenSchirm.new(hw, z, Laden.new(["herbs", "potion", "remedy"], true))
	root.add_child(l)
	await process_frame
	l.seite = "brauen"; l.baue()
	await _messe("Brauen", l)
	var sch: Array = l.find_children("*", "Label", true, false).filter(func(x): return x.text.contains("SCHLIESSEN"))
	if not sch.is_empty():
		print("Brauen: Schliessen bei %.0f von 2340" % sch[0].get_global_rect().position.y)
		if v2: pruefe("Schliessen folgt der Liste (Vorlage 2)", sch[0].get_global_rect().position.y < 2340 - 160 * DP, "%.0f" % sch[0].get_global_rect().position.y)
	var heil: Dictionary = Laden.rezepte().filter(func(r): return String(r["ergebnis"]) == "potion")[0]
	l.braukasten_b(heil, 3, true)
	await _messe("Mengenkasten", l.get_child(l.get_child_count() - 1))
	if v2: pruefe("Mengenkasten mit Abbrechen", _abbrechen(l.get_child(l.get_child_count() - 1)))
	l.queue_free()
	await process_frame
	Spielstaende.entwurf = ""; Menue.entwurf = ""; KapitelSchirm.entwurf = ""; LadenSchirm.entwurf_b = ""
