extends SceneTree
# 399.1 (Test 139, Chef 28.10., 21:3x: „ich brauche mein Testmenü wieder. 7-mal aufs Logo unten drücken“): ohne Bild; im Hauptmenue
# schaltet das siebte Tippen auf das Firmenzeichen den Testmodus an (vorher nicht), das Menue zeigt dann den Reiter „Test“; seine
# Knoepfe aendern Stufe, Gold, Vorraete, Waffe, Nebenhand, Uhr und Beute, Teleport, Kapitelende und Kampf gehen an die Welt.
# Der Testmodus steht am Ende wieder wie vorher. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/testmodus_399.gd

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])

func knopf(n: Node, anfang: String) -> Button:
	for b in n.find_children("*", "Button", true, false):
		if not b.is_visible_in_tree(): continue
		if String(b.text).begins_with(anfang.to_upper()): return b
		# 425: Eintraege als Zeichen (zeichenknopf.gd): Name oder Buchstabe
		if b is Zeichenknopf and (String(b.buchstabe) == anfang or String(b.wort).to_upper().begins_with(anfang.to_upper())): return b
	print("FEHLER kein Knopf ", anfang)
	fehler += 1
	return null

func druecke(n: Node, anfang: String) -> void:
	var b := knopf(n, anfang)
	if b: b.pressed.emit()
	await process_frame

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var vorher := Testmodus.ist_an()
	if vorher: Testmodus.umschalten()
	# Hauptmenue: sechsmal nichts, das siebte Mal an
	Hauptmenue.vorspann_gezeigt = true
	var hm := Hauptmenue.new(null)
	root.add_child(hm)
	await process_frame
	var logo: Control = null
	for r in hm.find_children("*", "TextureRect", true, false):
		if r.mouse_filter == Control.MOUSE_FILTER_STOP: logo = r
	if logo == null: fehler += 1; print("FEHLER Firmenzeichen nimmt kein Tippen")
	else:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT; e.pressed = true
		for i in 6: logo.gui_input.emit(e)
		pruefe("nach sechsmal", Testmodus.an, false)
		logo.gui_input.emit(e)
		pruefe("nach siebenmal", Testmodus.an, true)
		await process_frame
		var t := " | ".join(PackedStringArray(hm.find_children("*", "Label", true, false).map(func(l): return l.text)))
		pruefe("Zeile Testmodus aktiv", t.contains("Testmodus aktiv") and t.contains("Testmodus aktiviert"), true)
	hm.queue_free()
	# Menue mit Reiter Test
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", "Wachsoldat", z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	pruefe("sieben Reiter", m.leiste.get_child_count(), 7)
	var taten := []
	m.test.connect(func(w, mit): taten.append([w, mit]))
	m.reiter = "test"
	m.baue()
	await process_frame
	await druecke(m, "+5")
	pruefe("Stufe +5", hw.stufe, 6)
	await druecke(m, "−1")
	pruefe("Stufe −1", [hw.stufe, hw.leben == hw.max_leben()], [5, true])
	await druecke(m, "Gold")
	pruefe("Gold", z.gold, 1000)
	await druecke(m, "Vorräte")
	pruefe("Vorraete", [z.anzahl("potion") >= 10, z.beutel.filter(func(g): return g["base"] == "torch").size(), z.anzahl(Geschichte.SMOKE_BUNDLE)], [true, 2, 1])
	await druecke(m, "Waffe")
	await druecke(m, "Langschwert")
	pruefe("Waffe", String(hw.ding("MAIN_HAND")["base"]) if hw.ding("MAIN_HAND") != null else "", "longsword")
	var nb_vor := String(hw.ding("OFF_HAND")["base"]) if hw.ding("OFF_HAND") != null else ""
	await druecke(m, "Andere Hand")
	pruefe("Nebenhand", String(hw.ding("OFF_HAND")["base"]) if hw.ding("OFF_HAND") != null else "", Testmodus.NEBENHAND[(maxi(Testmodus.NEBENHAND.find(nb_vor), 0) + 1) % 4])
	var uhr := z.minuten
	await druecke(m, "Uhrzeit")
	pruefe("Uhr", z.minuten, (uhr + 180) % 1440)
	var stuecke := z.beutel.size()
	await druecke(m, "Selten")
	pruefe("Beute selten", [z.beutel.size(), String(z.beutel[-1]["rarity"]) if z.beutel.size() > stuecke else ""], [stuecke + 1, "RARE"])
	await druecke(m, "Dorf")
	await druecke(m, "Kapitelende")
	await druecke(m, "Tag / Nacht")   # 500: statt des Probeknopfs rechts in der Welt
	await druecke(m, "Wolfsrudel")
	await druecke(m, "Probekampf starten")   # 1020.2 B: Herkunft als Schalter (Vorgabe Wachsoldat), ein Knopf startet
	pruefe("an die Welt", taten.map(func(x): return x[0]), ["teleport", "kapitelende", "nacht", "kampf", "probe"])
	pruefe("Probe", taten[-1][1] if taten.size() == 5 else [], ["GRAK", "Wachsoldat", 3, true])
	pruefe("vor Aldric", Testmodus.vor_aldric().size(), 2)
	var ph := Testmodus.probeheld("Zauberlehrling", 5)
	pruefe("Probeheld", [ph.stufe, ph.leben == ph.max_leben(), ph.mana == ph.max_mana(), ph.herkunft], [5, true, true, "Zauberlehrling"])
	m.queue_free()
	# aus: kein Reiter Test
	Testmodus.umschalten()
	var m2 := Menue.new(hw, z)
	root.add_child(m2)
	await process_frame
	pruefe("aus: sechs Reiter", m2.leiste.get_child_count(), 6)
	if Testmodus.an != vorher: Testmodus.umschalten()
	print("TESTMODUS %d Fehler" % fehler)
	quit(1 if fehler else 0)
