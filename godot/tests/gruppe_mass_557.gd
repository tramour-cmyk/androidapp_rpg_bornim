extends SceneTree
# 557 ohne Bild: die Schirme der Gruppe 557 im Entwurf B (Spielstände, Wechselliste, Gegenstandsfenster, Kapitelende, Brauen,
# Mengenkasten) passen ganz auf den Schirm (1080 × 2340), kein Text überlappt einen anderen, keine Schrift unter 13 sp, jede
# antippbare Fläche mindestens 48 dp hoch. Aufruf: im Ordner godot, --headless -s res://tests/gruppe_mass_557.gd -> „GRUPPE557 n Fehler“
# 557 Runde 4 (Chef 17:40–17:44, mit Vorlage 2, auch auf 360 dp): alle Knöpfe eines Fensters gleich groß (15 sp, 48 dp); Zurück,
# Abbrechen, Schließen links, Weiter, Laden, Anlegen, Brauen, Nebenhand rechts, kein Knopf mittig; Wegwerfen und Löschen überall in
# derselben Warnfarbe; im Gegenstandsfenster zwei Reihen (oben Wegwerfen und Nebenhand, unten Abbrechen und Anlegen); Rast „‹ ZURÜCK“
# statt „Weitergehen“, an der Theke ein eigenes Zeichen; Mengenkasten: nicht wählbare Mengen lesbar gedämpft, „+“ und „−“ gleich hell,
# solange wählbar; „1W6“ mit Abstand („1 W6“); die Seltenheit nicht doppelt („Göttlicher Ring … (göttlich)“)

var fehler := 0
const DP := AktionsKnopf.DP

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FEHLER %s %s" % [was, wie])

func _initialize() -> void: _lauf.call_deferred()

func _messe(wo: String, wurzel: Node) -> void:
	for i in 6: await process_frame
	var w := float(root.size.x); var h := float(root.size.y)
	var labels: Array = wurzel.find_children("*", "Label", true, false).filter(func(l): return l.is_visible_in_tree() and l.text.strip_edges() != "")
	for l in labels:
		var r: Rect2 = l.get_global_rect()
		pruefe("auf dem Schirm " + wo, r.position.y >= 0 and r.end.y <= h and r.position.x >= 0 and r.end.x <= w, "„%s“ %s" % [l.text.left(30), r])
		pruefe("Schrift " + wo, l.get_theme_font_size("font_size") >= int(13 * Stil.SP) - 1, "„%s“ %d" % [l.text.left(30), l.get_theme_font_size("font_size")])
	for i in labels.size():
		for j in range(i + 1, labels.size()):
			var a: Rect2 = labels[i].get_global_rect().grow(-2)
			var b: Rect2 = labels[j].get_global_rect().grow(-2)
			pruefe("ueberlappt " + wo, not a.intersects(b), "„%s“ / „%s“" % [labels[i].text.left(20), labels[j].text.left(20)])
	for p in wurzel.find_children("*", "PanelContainer", true, false):
		if p.is_visible_in_tree() and p.mouse_filter == Control.MOUSE_FILTER_STOP and p.get_theme_stylebox("panel") is StyleBoxEmpty:
			pruefe("Tippflaeche " + wo, p.size.y >= 48 * DP - 1, "%.0f" % p.size.y)
			var r: Rect2 = p.get_global_rect()
			pruefe("Tippflaeche auf dem Schirm " + wo, r.position.x >= -1 and r.end.x <= w + 1, "%s" % r)
	# 557 Runde 5 (Chef 19:19: „da fehlen die Gegenstände mal ganz platt“): jedes Bildfeld (Gegenstand, Trank, Kraut, Zutat) gefüllt;
	# ohne Bilder der Dinge (godot/daten, im Bau aus core exportThingArt) keine Vorlage
	for t in wurzel.find_children("*", "TextureRect", true, false):
		if t.is_visible_in_tree() and t.custom_minimum_size.x >= 16 * DP:
			pruefe("Bildfeld gefüllt " + wo, t.texture != null, "%s %s" % [t.get_parent().name, t.get_global_rect()])
	if Spielstaende.vorlage2: _lage(wo, wurzel)
	print("%s: %d Texte" % [wo, labels.size()])

# 557a B (Chef 04.11., 20:55): der Kopf beginnt oben in derselben Hoehe wie auf jedem Schirm (Spielstaende.OBEN_DP), die Knoepfe stehen
# direkt unter dem Inhalt; fest unten nur, wenn die Liste rollt
const OBEN_557A := 36.0   # Rand oben jedes Schirms (Spielstaende.OBEN_DP)

func _lage(wo: String, wurzel: Node) -> void:
	var sichtbar: Array = wurzel.find_children("*", "Control", true, false).filter(func(c): return c.is_visible_in_tree() and (c is Label and c.text.strip_edges() != "" or c is TextureRect or c.name == "Kopfzeichen"))
	var oben := INF
	for c in sichtbar: oben = minf(oben, (c as Control).get_global_rect().position.y)
	pruefe("Kopf oben " + wo, absf(oben - OBEN_557A * DP) <= 4 * DP, "%.0f px statt %.0f" % [oben, OBEN_557A * DP])
	# 557b B (Chef 05.11., 08:18): auch der Titel selbst steht oben (Rast: Zeichen daneben, nicht darueber)
	var titel_oben := INF
	for c in sichtbar:
		if c is Label and (c as Label).get_theme_font_size("font_size") >= int(15 * Stil.SP): titel_oben = minf(titel_oben, (c as Control).get_global_rect().position.y)
	pruefe("Titel oben " + wo, titel_oben - OBEN_557A * DP <= 16 * DP, "%.0f px" % titel_oben)
	var rollt := false
	for r in wurzel.find_children("*", "ScrollContainer", true, false):
		if r.is_visible_in_tree() and r.get_v_scroll_bar().max_value > r.get_v_scroll_bar().page + 1: rollt = true
	if rollt: return
	for k in wurzel.find_children("*", "PanelContainer", true, false).filter(func(p): return p.has_meta("knopf") and p.is_visible_in_tree()):
		var kr: Rect2 = (k as Control).get_global_rect()
		var drueber := -INF
		for c in sichtbar:
			if (k as Node).is_ancestor_of(c): continue
			var r: Rect2 = (c as Control).get_global_rect()
			if r.end.y <= kr.position.y + 1: drueber = maxf(drueber, r.end.y)
		pruefe("Knopf am Inhalt " + wo, kr.position.y - drueber <= 56 * DP, "%.0f dp Luecke ueber „%s“" % [(kr.position.y - drueber) / DP, (k as Node).find_child("Text", true, false).text if (k as Node).find_child("Text", true, false) else "?"])

const ZURUECK := ["ZURÜCK", "ABBRECHEN", "SCHLIESSEN", "BACK", "CANCEL", "CLOSE"]
const VOR := ["WEITER", "LADEN", "ANLEGEN", "BRAUEN", "NEBENHAND", "NEXT", "LOAD", "EQUIP", "BREW", "OFF HAND"]
const GEFAHR := ["WEGWERFEN", "LÖSCHEN", "DISCARD", "DELETE"]

# 557 Runde 4: die Knoepfe (Spielstaende.knopf) eines Fensters: gleich gross, 15 sp, 48 dp, Seite nach Bedeutung, nichts mittig,
# Gefahr in Warnfarbe; gibt {Text: Knopf} zurueck
func _knoepfe(wo: String, wurzel: Node, mindestens := 1) -> Dictionary:
	var k: Array = wurzel.find_children("*", "PanelContainer", true, false).filter(func(p): return p.has_meta("knopf") and p.is_visible_in_tree())
	pruefe("Knoepfe da " + wo, k.size() >= mindestens, "%d" % k.size())
	var alle := {}
	if k.is_empty(): return alle
	var gr: Vector2 = k[0].size
	for p in k:
		var t: Label = p.find_child("Text", true, false)
		var text := t.text
		alle[text] = p
		var r: Rect2 = p.get_global_rect()
		var tr: Rect2 = t.get_global_rect()
		pruefe("Knoepfe gleich gross " + wo, absf(p.size.x - gr.x) <= 2.0 and absf(p.size.y - gr.y) <= 1.0, "„%s“ %s statt %s" % [text, p.size, gr])
		pruefe("Knopf 15 sp " + wo, t.get_theme_font_size("font_size") == int(round(15 * Stil.SP)), "„%s“ %d" % [text, t.get_theme_font_size("font_size")])
		pruefe("Knopf 48 dp " + wo, p.size.y >= 48 * DP - 1, "„%s“ %.0f" % [text, p.size.y])
		pruefe("Knopftext ganz im Knopf " + wo, r.grow(1).encloses(tr), "„%s“ %s in %s" % [text, tr, r])
		var reihe: Rect2 = (p.get_parent() as Control).get_global_rect()
		var mitte := reihe.get_center().x
		pruefe("Knopf nicht mittig " + wo, absf(tr.get_center().x - mitte) > 24 * DP and absf(r.get_center().x - mitte) > 24 * DP, "„%s“ Text %.0f, Reihe %.0f" % [text, tr.get_center().x, mitte])
		if ZURUECK.has(text):
			pruefe("links: %s %s" % [text, wo], r.end.x <= mitte + 1 and absf(r.position.x - reihe.position.x) <= 1 and tr.position.x - r.position.x <= 30 * DP, "%s in %s" % [tr, reihe])
		if VOR.any(func(x): return text.begins_with(x)):
			pruefe("rechts: %s %s" % [text, wo], r.position.x >= mitte - 1 and absf(reihe.end.x - r.end.x) <= 1 and r.end.x - tr.end.x <= 30 * DP, "%s in %s" % [tr, reihe])
		if GEFAHR.has(text):
			pruefe("Warnfarbe: %s %s" % [text, wo], t.get_theme_color("font_color") == Stil.WARN, "%s" % t.get_theme_color("font_color"))
		pruefe("Knopf hat eine Seite " + wo, ZURUECK.has(text) or GEFAHR.has(text) or VOR.any(func(x): return text.begins_with(x)), "„%s“" % text)
	print("%s: Knöpfe %s, je %.0f × %.0f" % [wo, ", ".join(PackedStringArray(alle.keys())), gr.x, gr.y])
	return alle

func _label(wurzel: Node, text: String) -> Label:
	for l in wurzel.find_children("*", "Label", true, false):
		if l.text == text and l.is_visible_in_tree(): return l
	return null

func _sichtbar(l: Control) -> float:   # Deckkraft mit allen Eltern
	var a := 1.0
	var c: CanvasItem = l
	while c != null:
		a *= c.modulate.a * c.self_modulate.a
		c = c.get_parent() as CanvasItem
	return a

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	# B, Vorlage 2 (Chef 14:21–14:26: Abbrechen sichtbar, Knopf am Inhalt) und Vorlage 2 auf dem schmalsten Schirm (360 dp): das Spiel
	# streckt auf 1080 Breite (canvas_items, expand); strenger gemessen wird hier mit nur 360 dp Breite (content_scale_size)
	for lauf in [["B", false, 1080], ["Vorlage 2", true, 1080], ["Vorlage 2 auf 360 dp", true, int(ceil(360 * DP))]]:
		root.size = Vector2i(int(lauf[2]), 2340)
		root.content_scale_size = root.size
		Spielstaende.vorlage2 = bool(lauf[1])
		print("— %s (%d px)" % [lauf[0], root.size.x])
		await _runde(bool(lauf[1]))
	Spielstaende.vorlage2 = false
	root.size = Vector2i(1080, 2340)
	root.content_scale_size = root.size
	print("GRUPPE557 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func _abbrechen(w: Node) -> bool:
	return w.find_children("*", "Label", true, false).any(func(l): return l.is_visible_in_tree() and l.text.contains("ABBRECHEN"))

func _runde(v2: bool) -> void:
	Spielstaende.entwurf = "B"; Menue.entwurf = "B"; KapitelSchirm.entwurf = "B"; LadenSchirm.entwurf_b = "B"
	var gesichert := Spielstand.liste()
	var probe := Zustand.new(); probe.name = "Mira"
	if v2 and gesichert[0].is_empty():
		Spielstand.platz = 1
		Spielstand.speichere(probe, BrsHeld.fuer_spiel("Mira", "Elf", "Zauberlehrling", probe.neue_uid), {"karte": "village", "x": 4, "y": 6, "blick": "UP"})
	var s := Spielstaende.new()
	root.add_child(s)
	await _messe("Spielstaende", s)
	if v2:
		var k := _knoepfe("Spielstaende", s, 2)
		pruefe("Spielstaende: ZURÜCK und LÖSCHEN", k.has("ZURÜCK") and k.has("LÖSCHEN"), str(k.keys()))
		s.frage_loeschen(Spielstand.liste()[0])
		var f: Node = s.get_child(s.get_child_count() - 1)
		await _messe("Rueckfrage Loeschen", f)
		pruefe("Rueckfrage ohne Kasten", f.find_children("*", "PanelContainer", true, false).all(func(p): return p.get_theme_stylebox("panel") is StyleBoxEmpty), "")
		pruefe("Rueckfrage mit Abbrechen", _abbrechen(f))
		k = _knoepfe("Rueckfrage Loeschen", f, 2)
		pruefe("Rueckfrage Loeschen: ABBRECHEN, LÖSCHEN", k.has("ABBRECHEN") and k.has("LÖSCHEN"), str(k.keys()))
		f.free()
		if gesichert[0].is_empty(): Spielstand.loesche(1)
	s.queue_free()
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Mira", "Elf", "Zauberlehrling", z.neue_uid)
	for r in ["UNCOMMON", "RARE", "VERY_RARE"]: z.ausruestung_dazu({"uid": 0, "base": "robe", "rarity": r, "ilvl": 3, "plus": 0, "rolls": [["DEX", 2], ["AC", 1], ["CON", 4]], "unique": null, "name_seed": 3})
	z.ausruestung_dazu({"uid": 0, "base": "plate", "rarity": "COMMON", "ilvl": 2, "plus": 0, "rolls": [], "unique": null, "name_seed": 2})
	# Runde 4: eine Einhandwaffe (Nebenhand, „1W6“) und ein goettlicher Ring (der Name sagt „Göttlich“ schon)
	var schwert := z.ausruestung_dazu({"uid": 0, "base": "shortsword", "rarity": "RARE", "ilvl": 5, "plus": 0, "rolls": [["STR", 1]], "unique": null, "name_seed": 3})
	var ring := z.ausruestung_dazu({"uid": 0, "base": "ring", "rarity": "DIVINE", "ilvl": 9, "plus": 0, "rolls": [["DEX", 2]], "unique": null, "name_seed": 4})
	var panzer := z.ausruestung_dazu({"uid": 0, "base": "chain_mail", "rarity": "COMMON", "ilvl": 4, "plus": 3, "rolls": [], "unique": null, "name_seed": 5})   # 557 Runde 5: „+3“ am Namen
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.reiter = "ausruestung"; m.baue()
	m.waehle("CHEST")
	await _messe("Wechselliste", m.get_child(m.get_child_count() - 1))
	if v2:
		var k := _knoepfe("Wechselliste", m.get_child(m.get_child_count() - 1))
		pruefe("Wechselliste: ZURÜCK", k.has("ZURÜCK"), str(k.keys()))
	pruefe("Robe mit Wert", Menue.listen_zeile_b(z.beutel[0]).contains("GES"), Menue.listen_zeile_b(z.beutel[0]))
	m.get_child(m.get_child_count() - 1).free()
	var wuerfel := RegEx.create_from_string("\\dW\\d")
	for g in z.beutel:
		m.frage_stueck(g)
		var f: Node = m.get_child(m.get_child_count() - 1)
		var wo: String = "Fenster " + Beute.name(g)
		await _messe(wo, f)
		if v2:
			pruefe("Fenster mit Abbrechen", _abbrechen(f))
			var k := _knoepfe(wo, f, 3)
			pruefe("%s: WEGWERFEN, ABBRECHEN, ANLEGEN" % wo, k.has("WEGWERFEN") and k.has("ABBRECHEN") and k.has("ANLEGEN"), str(k.keys()))
			if k.has("WEGWERFEN") and k.has("ABBRECHEN"):
				pruefe("Wegwerfen ueber Abbrechen " + wo, k["WEGWERFEN"].get_global_rect().end.y <= k["ABBRECHEN"].get_global_rect().position.y + 1, "")
			if g == schwert:
				pruefe("Nebenhand da " + wo, k.has("NEBENHAND"), str(k.keys()))
				if k.has("NEBENHAND") and k.has("WEGWERFEN"):
					var a: Rect2 = k["WEGWERFEN"].get_global_rect(); var b: Rect2 = k["NEBENHAND"].get_global_rect()
					pruefe("Wegwerfen und Nebenhand eine Reihe, getrennt " + wo, absf(a.position.y - b.position.y) < 1 and b.position.x - a.end.x >= 8 * DP - 1, "%s / %s" % [a, b])
			for l in f.find_children("*", "Label", true, false):
				pruefe("1W6 mit Abstand " + wo, wuerfel.search(l.text) == null, "„%s“" % l.text)
			if g == panzer:   # 557 Runde 5 (Chef 19:23): „+x“ in der Namenszeile, nicht allein darunter
				var allein: Array = f.find_children("*", "Label", true, false).filter(func(l): return l.text.strip_edges() == "+3")
				var am_namen: Array = f.find_children("*", "Label", true, false).filter(func(l): return l.text.ends_with("\u00a0+3"))
				pruefe("+3 am Namen " + wo, allein.is_empty() and not am_namen.is_empty(), str(f.find_children("*", "Label", true, false).slice(0, 3).map(func(l): return l.text)))
			if g == ring:
				var doppelt: Array = f.find_children("*", "Label", true, false).filter(func(l): return l.text.strip_edges() == "Göttlich" or l.text.containsn("(göttlich)"))
				pruefe("Seltenheit nicht doppelt " + wo, doppelt.is_empty(), str(doppelt.map(func(l): return l.text)))
		f.free()
	if v2:
		for g in [z.beutel[0], ring]:
			m.frage_wegwerfen(g)
			var f: Node = m.get_child(m.get_child_count() - 1)
			await _messe("Rueckfrage Wegwerfen", f)
			pruefe("Wegwerfen mit Abbrechen", _abbrechen(f))
			var k := _knoepfe("Rueckfrage Wegwerfen", f, 2)
			pruefe("Rueckfrage Wegwerfen: ABBRECHEN, WEGWERFEN", k.has("ABBRECHEN") and k.has("WEGWERFEN"), str(k.keys()))
			pruefe("Ring nicht doppelt göttlich", not f.find_children("*", "Label", true, false).any(func(l): return l.text.containsn("(göttlich)")), "")
			# 557 Runde 5 (Chef 19:23: Rückfragen zentriert, Text bis drei Zeilen; mehr linksbündig)
			for l in f.find_children("*", "Label", true, false):
				if l.autowrap_mode != TextServer.AUTOWRAP_OFF and l.text.strip_edges() != "":
					var soll := HORIZONTAL_ALIGNMENT_CENTER if l.get_line_count() <= 3 else HORIZONTAL_ALIGNMENT_LEFT
					pruefe("Rueckfrage zentriert", l.horizontal_alignment == soll, "„%s“ %d Zeilen" % [l.text.left(30), l.get_line_count()])
			f.free()
	var wk := Vergleich.wirkung(hw, z.beutel[0])
	print("Wirkung ", wk)
	pruefe("Wirkung je Bonus", wk.has("DEX") and wk.has("CON") and int(wk["CON"][1]) <= 4, str(wk))
	m.queue_free()
	var kap := KapitelSchirm.new(hw, Geschichte.CHAPTER_END_TEXT)
	root.add_child(kap)
	await _messe("Kapitelende", kap)
	pruefe("Weiter da", kap.find_child("Weiter", true, false) != null)
	var wy: float = (kap.find_child("Weiter", true, false) as Control).get_global_rect().position.y
	print("Kapitelende: Weiter bei %.0f von 2340" % wy)
	if v2:
		pruefe("Weiter folgt dem Text (Vorlage 2)", wy < 2340 - 160 * DP, "%.0f" % wy)
		var k := _knoepfe("Kapitelende", kap)
		pruefe("Kapitelende: WEITER", k.has("WEITER"), str(k.keys()))
	kap.queue_free()
	z.gold = 23; z.dazu("herbs", 7); z.dazu("potion", 2)
	var l := LadenSchirm.new(hw, z, Laden.new(["herbs", "potion", "remedy"], true))
	root.add_child(l)
	await process_frame
	l.seite = "brauen"; l.baue()
	await _messe("Brauen", l)
	var sch: Array = l.find_children("*", "Label", true, false).filter(func(x): return x.text.contains("ZURÜCK"))
	if not sch.is_empty():
		print("Brauen: Schliessen bei %.0f von 2340" % sch[0].get_global_rect().position.y)
		if v2: pruefe("Schliessen folgt der Liste (Vorlage 2)", sch[0].get_global_rect().position.y < 2340 - 160 * DP, "%.0f" % sch[0].get_global_rect().position.y)
	if v2:
		var k := _knoepfe("Brauen", l)
		pruefe("Brauen: ZURÜCK (618)", k.has("ZURÜCK"), str(k.keys()))
	var heil: Dictionary = Laden.rezepte().filter(func(r): return String(r["ergebnis"]) == "potion")[0]
	var oft := Laden.wie_oft(z, heil)
	print("Heiltrank reicht für %d" % oft)
	l.braukasten_b(heil, 3, true)
	var mk: Node = l.get_child(l.get_child_count() - 1)
	await _messe("Mengenkasten", mk)
	if v2:
		pruefe("Mengenkasten mit Abbrechen", _abbrechen(mk))
		var k := _knoepfe("Mengenkasten", mk, 2)
		pruefe("Mengenkasten: ABBRECHEN, BRAUEN", k.has("ABBRECHEN") and k.keys().any(func(x): return x.begins_with("BRAUEN")), str(k.keys()))
		# Pruefer 17:12: „×5“ bei 3 Traenken und „+“ am Hoechstwert lesbar gedaempft, nicht fast unsichtbar
		if oft < 5:
			var x5 := _label(mk, "×5")
			pruefe("×5 lesbar gedaempft", x5 != null and x5.get_theme_color("font_color") == Stil.DIM and _sichtbar(x5) > 0.99, "%s %.2f" % [x5.get_theme_color("font_color") if x5 else "", _sichtbar(x5) if x5 else 0.0])
		var plus := _label(mk, "+")
		pruefe("+ am Hoechstwert lesbar gedaempft", plus != null and plus.get_theme_color("font_color") == Stil.DIM and _sichtbar(plus) > 0.99, "")
		mk.free()
		if oft >= 3:
			l.braukasten_b(heil, 2)
			mk = l.get_child(l.get_child_count() - 1)
			await _messe("Mengenkasten 2", mk)
			var p_ := _label(mk, "+"); var m_ := _label(mk, "−")
			pruefe("+ und − gleich hell, solange waehlbar", p_ != null and m_ != null and p_.get_theme_color("font_color") == m_.get_theme_color("font_color") and _sichtbar(p_) == _sichtbar(m_), "")
	l.queue_free()
	await process_frame
	if v2: await _rast()
	Spielstaende.entwurf = ""; Menue.entwurf = ""; KapitelSchirm.entwurf = ""; LadenSchirm.entwurf_b = ""

# 549 in 557, Runde 4: Rast mit „‹ ZURÜCK“ (Chef 17:40) links, an der Theke ein eigenes Zeichen statt der Flamme (Pruefer 17:12)
func _rast() -> void:
	var z := Zustand.new()
	z.gold = 42
	var feuer := [{"id": "kurz", "name": "Kurze Rast", "dauer": "1 Std.", "tut": Sprache.r("shortDoes"), "zeichen": "CLOCK"}]
	var theke := [{"id": "met", "name": "Met", "dauer": "3 Gold", "tut": Sprache.r("meadDoes"), "zeichen": "MUG"}]
	for ort in ["feuer", "theke"]:
		var f: Rastfeld
		if ort == "feuer": f = Rastfeld.neu("B", Sprache.r("ask"), "Tag 2 · 21:40 · TP 9 / 22", feuer, Sprache.r("leave"))
		else: f = Rastfeld.neu("B", Sprache.r("tavern"), "Gold: 42", theke, Sprache.r("leave"), "", [Rast.rowena_sagt(z, "Alrik", false)], "SCHENKE")
		root.add_child(f)
		var wo: String = "Rast " + ort
		await _messe(wo, f)
		var k := _knoepfe(wo, f)
		pruefe("Rast: ZURÜCK", k.has("ZURÜCK"), str(k.keys()))
		pruefe("Rast ohne Weitergehen", not f.find_children("*", "Label", true, false).any(func(l): return l.text.containsn("weitergehen")), "")
		var kz: Rastzeichen = f.find_child("Kopfzeichen", true, false)
		pruefe("Rast Zeichen " + ort, kz != null and kz.art == ("REST" if ort == "feuer" else "SCHENKE"), kz.art if kz else "")
		var gew := []
		f.gewaehlt.connect(func(id): gew.append(id))
		if k.has("ZURÜCK"):
			k["ZURÜCK"].gui_input.emit(_tipp(true)); k["ZURÜCK"].gui_input.emit(_tipp(false))
		pruefe("Rast: ZURÜCK schliesst", gew == [""], str(gew))
		f.free()
		await process_frame

func _tipp(an: bool) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = an
	e.position = Vector2(20, 20)
	return e
