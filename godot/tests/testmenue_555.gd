extends SceneTree
# 555 (Chef 04.11., 00:30) und 554 (00:27) ohne Bild: der Reiter „Test“ hat wieder, was alt da war, und die Hilfen zum Durchspielen;
# Stationen setzen den Stand von Kapitel 1 und stellen den Helden auf ein begehbares Feld; Bosse, Truhen, Merker; Kampfhilfen in MARS
# (immer kritisch, keine Rettungswuerfe, unsterblich); Blende „bereit nach“; Absturzbericht. Braucht godot/daten (karten.json, texte.json,
# held.json). Aufruf: im Ordner godot, --headless -s res://tests/testmenue_555.gd -> „TESTMENUE555 n Fehler“

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FEHLER %s %s" % [was, wie])

func _initialize() -> void: _lauf.call_deferred()

func woerter(m: Menue) -> Array:
	return m.inhalt.find_children("*", "Zeichenknopf", true, false).map(func(k): return String(k.wort))

func knopf(m: Menue, wort: String) -> Zeichenknopf:
	for k in m.inhalt.find_children("*", "Zeichenknopf", true, false):
		if String(k.wort) == wort: return k
	return null

func texte(m: Menue) -> Array:
	return m.inhalt.find_children("*", "Button", true, false).filter(func(b): return not b is Zeichenknopf).map(func(b): return String(b.text))

func druecke(m: Menue, text: String) -> bool:
	for b in m.inhalt.find_children("*", "Button", true, false):
		if not b is Zeichenknopf and String(b.text).to_upper().begins_with(text.to_upper()): b.pressed.emit(); return true
	return false

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", "Wachsoldat", z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	Testmodus.an = true; Testmodus.geladen = true
	var gesendet := []
	m.test.connect(func(was, mit): gesendet.append([was, mit]))
	m.reiter = "test"; m.baue()
	for i in 4: await process_frame
	# was alt da war und die Hilfen zum Durchspielen
	var w := woerter(m)
	for x in ["Unsterblich", "Schnell", "Kartenzoom", "Monster", "Bosse", "Truhen", "Geschichte", "Kritisch", "Rettung", "Kapitelende", "Dorf", "Uhrzeit", "Tag / Nacht"]:
		pruefe("Zeichen fehlt", w.has(x), x)
	var zeilen: Array = m.inhalt.find_children("*", "Label", true, false).map(func(l): return String(l.text))
	pruefe("Letzter Lauf", zeilen.any(func(t): return t.begins_with("Letzter Lauf: ")), "")
	pruefe("Blende bereit nach", zeilen.any(func(t): return t.begins_with("Blende: bereit nach ")), "")
	# 554: Monster beachten mich nicht, an und wieder aus
	knopf(m, "Monster").tat.call()
	pruefe("Monster beachten nicht an", Herde.beachten_nicht)
	knopf(m, "Monster").tat.call()
	pruefe("Monster beachten nicht aus", not Herde.beachten_nicht)
	# Kampfhilfen schalten die Merker in MARS
	knopf(m, "Kritisch").tat.call(); knopf(m, "Rettung").tat.call(); knopf(m, "Unsterblich").tat.call()
	pruefe("Kampfhilfen an", Mars.held_immer_krit and Mars.gegner_ohne_rettung and Mars.held_unsterblich)
	knopf(m, "Schnell").tat.call()
	pruefe("Schnell", is_equal_approx(Held.schnell, 3.0), str(Held.schnell))
	knopf(m, "Schnell").tat.call()
	pruefe("Schnell aus", is_equal_approx(Held.schnell, 1.0), str(Held.schnell))
	# Kartenzoom: vier Stufen wie alt, dann wieder wie unter Bedienung; jede Stufe geht an die Welt
	var stufen := []
	for i in 5:
		gesendet.clear()
		knopf(m, "Kartenzoom").tat.call()
		stufen.append(Kamera.test_kacheln)
		pruefe("Kartenzoom an die Welt", not gesendet.is_empty() and gesendet[0][0] == "zoom", str(gesendet))
	pruefe("Kartenzoom Stufen", stufen == [5.6, 6.75, 8.4, 10.5, 0.0], str(stufen))
	# Merker: aufklappen, einen setzen, wieder loeschen; „Ort neu“ geht an die Welt
	knopf(m, "Geschichte").tat.call()
	for i in 2: await process_frame
	pruefe("Merker offen", texte(m).any(func(t): return t.to_upper().begins_with("GARRICK GETROFFEN: ")), str(texte(m).slice(0, 4)))
	druecke(m, "Garrick getroffen: ")
	pruefe("Merker gesetzt", z.has(Geschichte.HUNTER_MET))
	for i in 2: await process_frame
	druecke(m, "Garrick getroffen: ")
	pruefe("Merker geloescht", not z.has(Geschichte.HUNTER_MET))
	gesendet.clear()
	for i in 2: await process_frame
	druecke(m, "Ort neu")
	pruefe("Ort neu", not gesendet.is_empty() and gesendet[0][0] == "ort_neu", str(gesendet))
	# Bosse und Truhen zuruecksetzen
	for f in [Geschichte.GRIMFANG_DEFEATED, Geschichte.KROGG_DEFEATED, Geschichte.GRAK_DEFEATED, Geschichte.SMOKE_GIVEN, "kiste:cave_1", Geschichte.LYRA_RESCUED]: z.setze(f)
	z.gepflueckt["forest:3:4"] = 1
	knopf(m, "Bosse").tat.call()
	pruefe("Bosse zurueck", not (z.has(Geschichte.GRIMFANG_DEFEATED) or z.has(Geschichte.KROGG_DEFEATED) or z.has(Geschichte.GRAK_DEFEATED) or z.has(Geschichte.SMOKE_GIVEN)))
	pruefe("Bosse lassen Lyra", z.has(Geschichte.LYRA_RESCUED))
	knopf(m, "Truhen").tat.call()
	pruefe("Truhen und Kraeuter", not z.has("kiste:cave_1") and z.gepflueckt.is_empty())
	# Stationen: Merker bis dahin, spaetere geloescht, Schluesseldinge, ein begehbares Feld
	var erwartet := {"Garrick": ["barrier_open", "hunter_met"], "Morwen": ["krogg_hint", "hedda_met"], "Grimmzahn": ["smoke_given", "grimfang_defeated"],
		"Höhle": ["grimfang_defeated", "cave_seen"], "Krogg": ["cave_seen", "krogg_defeated"], "Grak": ["gate_open", "grak_defeated"], "Lyra": ["grak_defeated", "lyra_rescued"],
		"Tempel": ["lyra_gone", "chapter1_done"]}
	for s in Testmodus.STATIONEN:
		var n := String(s[0])
		z.setze(Geschichte.CHAPTER1_DONE)
		var ziel := Testmodus.station(n, z)
		pruefe("Station " + n, ziel.size() == 4, str(ziel))
		if ziel.size() != 4: continue
		pruefe("Station %s Karte" % n, ziel[0] == s[1], str(ziel[0]))
		pruefe("Station %s Merker davor" % n, z.has(String(erwartet[n][0])), "")
		pruefe("Station %s Merker danach" % n, not z.has(String(erwartet[n][1])) and not z.has(Geschichte.CHAPTER1_DONE), "")
		var k := Karte.lade(String(ziel[0]), z.flaggen)
		pruefe("Station %s begehbar" % n, k.begehbar(ziel[1]), str(ziel[1]))
		pruefe("Station %s Blick" % n, String(ziel[2]) in ["UP", "DOWN", "LEFT", "RIGHT"], str(ziel[2]))
		var rauch := z.anzahl(Geschichte.SMOKE_BUNDLE)
		pruefe("Station %s Rauchbuendel" % n, rauch == (1 if n in ["Grimmzahn", "Höhle", "Krogg"] else 0), str(rauch))
		pruefe("Station %s Amulett" % n, z.anzahl("sun_amulet") == (1 if n in ["Lyra", "Tempel"] else 0), str(z.anzahl("sun_amulet")))
		pruefe("Station %s Graks Schluessel" % n, z.anzahl("grak_key") == (1 if n == "Lyra" else 0), str(z.anzahl("grak_key")))
	# Grak: der Weg hinauf fuehrt ueber das Feld, auf dem er spricht (Geschichte.ausloeser, Zeile 4)
	Testmodus.station("Grak", z)
	var kg := Karte.lade("cave", z.flaggen)
	pruefe("Grak Weg durchs Gitter", kg.begehbar(Vector2i(10, 6)) and kg.begehbar(Vector2i(10, 5)) and kg.begehbar(Vector2i(10, 4)))
	pruefe("Grak spricht auf dem Weg", not Geschichte.ausloeser("cave", Vector2i(10, 4), z).is_empty())
	_mars()
	Mars.held_immer_krit = false; Mars.gegner_ohne_rettung = false; Mars.held_unsterblich = false
	# Blende: bereit nach, von Schwarz bis der Ort steht
	Messung.blende(true)
	OS.delay_msec(200)
	Messung.blende(false)
	pruefe("Blende bereit", Messung.bereit_ms >= 150.0 and Messung.bereit_ms < 2000.0, str(Messung.bereit_ms))
	# Absturzbericht: Fehler und Ende eines Protokolls
	var p := "user://test555.log"
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string("Godot Engine v4\nERROR: etwas ging schief\n   at: foo (res://x.gd:3)\nruhig\nSCRIPT ERROR: kaputt\nletzte Zeile\n")
	f.close()
	var b := Messung.bericht(p)
	pruefe("Bericht Fehler", b.get("fehler", []).size() == 2 and String(b["fehler"][0]).contains("res://x.gd:3"), str(b.get("fehler")))
	pruefe("Bericht Ende", String(b.get("ende", "")).contains("letzte Zeile"), "")
	DirAccess.remove_absolute(p)
	print("TESTMENUE555 %d Fehler" % fehler)
	quit(1 if fehler else 0)

# MARS mit den Kampfhilfen: jeder Waffenwurf des Helden ausser der 1 trifft (kritisch), Gegner weichen keinem Zauber aus, der Held faellt nie
func _mars() -> void:
	var tables: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var skills := {}
	for s in tables.skills: skills[s.id] = s
	var wolf: Dictionary
	for mo in tables.monsters:
		if mo.id == "wolf": wolf = mo
	var fehl := 0
	var wuerfe := 0
	for seed in range(1, 25):
		var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
		var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
		var fe := [Mars.monster_fighter("w1", Vector2i(Mars.FRONT, 0), wolf, 999), Mars.monster_fighter("w2", Vector2i(Mars.FRONT, 1), wolf, 999)]
		var mars = Mars.new([hero], fe, tables, Wuerfel.new(seed), Wuerfel.new(7))
		var heard := []
		mars.listener = func(e): heard.append(e)
		mars.start()
		if mars.current() != hero: continue
		mars.act(["attack", "w1"])
		for e in heard:
			if e.actor == "hero" and Mars.ist_angriff(e.roll) and bool(e.roll[4]):     # 870.5: jeder Treffer kritisch
				wuerfe += 1
				if not Mars.ist_krit(e.roll): fehl += 1
		# keine Rettung: ein Zauber mit Rettungswurf trifft den Wolf immer voll
		var t: Mars.Fighter = fe[1]
		var vor := t.hp
		var trifft := [0]
		mars.listener = func(e): if e.actor == "hero" and Mars.ist_angriff(e.roll) and e.roll[4]: trifft[0] += 1
		for i in 10: mars._brs_zauber(hero, t, Mars.BrsKampf.w()["zauber"]["Funkenpfeil"])     # 870.5: Zauber trifft immer
		pruefe("Gegner ohne Rettung", trifft[0] == 10, "%d von 10" % trifft[0])
		# unsterblich: der Held bleibt auf 1
		mars._hurt(hero, 99999, "w1", "x")
		pruefe("Held unsterblich", hero.hp == 1, str(hero.hp))
	pruefe("Held immer kritisch", wuerfe > 0 and fehl == 0, "%d von %d Wuerfen verfehlt" % [fehl, wuerfe])
	# 555 (Chef 11:52, „Spinne kommt nicht“): Kampf beschwoeren nur mit Gruppen, deren Monster ein Modell haben; die anderen als Zeile
	var fs := Testmodus.feinde()
	var spinne := Streuner.da("giant_spider")
	pruefe("Spinne nur mit Modell", fs.has("SPIDER") == spinne and (spinne or Testmodus.ohne_modell().any(func(n): return String(n).contains("Spinne"))), "Modell %s, Liste %s, ohne %s" % [spinne, fs.keys(), Testmodus.ohne_modell()])
	pruefe("Wolfsrudel bleibt (mit Wolfsmodell)", fs.has("WOLVES") == Streuner.da("wolf"), str(fs.keys()))
