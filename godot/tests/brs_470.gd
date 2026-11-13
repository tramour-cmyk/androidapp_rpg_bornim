extends SceneTree
# 470 ohne Bild: Erschaffung nach BRS 1.1 (regeln/brs_held.gd) gegen das Nachschlagewerk Abschnitt 2 und die Herkuenfte der Simulation 444
# (sim.py Held mit variante: Untergrenze plus „plus“ plus „plus_variante“). Aufruf: im Ordner godot mit -s res://tests/brs_470.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if str(ist) != str(soll):
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if BrsHeld.lade().is_empty() or BrsHeld.e().is_empty():
		print("FALSCH daten/werte.json fehlt oder ohne Block „erschaffung“"); quit(1); return
	pruefe("Grundwerte", BrsHeld.grundwerte(), ["kraft", "gewandtheit", "zaehigkeit", "verstand", "wille", "wahrnehmung"])
	pruefe("Summe vor dem Volk (6 x 1 + 21)", BrsHeld.summe_soll(), 27)
	pruefe("Völker", BrsHeld.voelker(), ["Mensch", "Elf", "Zwerg", "Hügelvolk", "Orkblütiger"])
	pruefe("Herkünfte, Wanderer zuletzt", BrsHeld.herkuenfte().back(), "Wanderer")
	# Wanderer: alles auf 3, 9 frei, zwei Fertigkeiten selbst (Mensch eine mehr)
	var b := BrsHeld.neu("Elf", "Wanderer")
	pruefe("Wanderer frei", [b.frei(), b.verteilt["kraft"], b.wahl_anzahl(), b.fertig()], [9, 3, 2, false])
	for i in 9: b.hoch("wille")
	pruefe("Wille höchstens 8, Rest frei", [b.verteilt["wille"], b.frei()], [8, 4])
	b.runter("kraft")
	pruefe("nie unter 3", b.verteilt["kraft"], 3)
	for g in ["verstand", "verstand", "verstand", "zaehigkeit"]: b.hoch(g)
	pruefe("alle verteilt", [b.frei(), b.kann_hoch("kraft")], [0, false])
	# Elf: Gewandtheit +1, Wahrnehmung +1, Zähigkeit −1; Zähigkeit 4 -> 3, Gewandtheit 3 -> 4
	pruefe("Elf", [b.wert("gewandtheit"), b.wert("wahrnehmung"), b.wert("zaehigkeit"), b.wert("wille")], [4, 4, 3, 8])
	# 933 A (Chef 11.11., 13:07): Malus bis 2, Zwerg mit Gewandtheit 3 hat 2; Bonus hebt 8 auf 9
	var z := BrsHeld.neu("Zwerg", "Wanderer")
	for i in 5: z.hoch("zaehigkeit")
	pruefe("Zwerg", [z.wert("gewandtheit"), z.wert("zaehigkeit"), z.wert("verstand")], [2, 9, 4])
	z.hoch("gewandtheit")
	pruefe("Zwerg Gewandtheit 4 -> 3", z.wert("gewandtheit"), 3)
	pruefe("Volk senkt bis 2, hebt bis 9", [int(BrsHeld.e()["volk_min"]), int(BrsHeld.e()["volk_max"])], [2, 9])
	# Fertigkeiten wählen
	b.waehle("Bogen"); b.waehle("Bergbau"); b.waehle("Spähen"); b.waehle("Dolche")
	pruefe("Wanderer wählt zwei, Bergbau nicht", [b.wahl, b.fertig()], [["Bogen", "Spähen"], true])
	b.waehle("Bogen")
	pruefe("abwählen", b.wahl, ["Spähen"])
	pruefe("nicht wählbar: Bergbau", BrsHeld.waehlbar()["Sammeln"].has("Bergbau"), false)
	pruefe("nicht wählbar in Kapitel 1: Illusion, Beschwörung (984.1)", [BrsHeld.waehlbar()["Magie"].has("Illusion"), BrsHeld.waehlbar()["Magie"].has("Beschwörung"), b.kann_waehlen("Illusion")], [false, false, false])
	var n := 0
	for gr in BrsHeld.waehlbar(): n += (BrsHeld.waehlbar()[gr] as Array).size()
	pruefe("37 Fertigkeiten, Bergbau erst ab Kapitel 2, Illusion und Beschwörung nicht in Kapitel 1", n, 34)
	# Herkunft verteilt vor wie sim444 (Spalte 21) und gibt ihre Fertigkeiten mit dem Startwert
	var W := BrsHeld.lade()
	for hk in BrsHeld.herkuenfte():
		if hk == "Wanderer": continue
		var x := BrsHeld.neu("Orkblütiger", hk)
		var d: Dictionary = W["herkuenfte"][hk]
		var soll := {}
		for g in BrsHeld.grundwerte(): soll[g] = 3
		for teil in ["plus", "plus_variante"]:
			for g in d.get(teil, {}): soll[g] = mini(8, int(soll[g]) + int(d[teil][g]))
		pruefe(hk + " vorverteilt", [x.verteilt, x.frei()], [soll, 0])
		pruefe(hk + " Fertigkeiten", x.fertigkeiten().keys(), d["fertigkeiten"])
		pruefe(hk + " Startwert", x.fertigkeiten().values().max(), int(W["held"]["startfertigkeit"]))
		pruefe(hk + " fertig ohne Wahl", x.fertig(), true)
	# Mensch: +1 frei (Vorgabe auf den höchsten Wert, wählbar) und eine Fertigkeit mehr
	var m := BrsHeld.neu("Mensch", "Wachsoldat")
	pruefe("Mensch +1 auf den höchsten", [m.frei_ziel(), m.wert("kraft"), m.verteilt["kraft"]], ["kraft", 7, 6])
	m.mensch_frei = "wille"
	pruefe("Mensch +1 gewählt", [m.wert("wille"), m.wert("kraft")], [5, 6])
	pruefe("Mensch wählt eine", [m.wahl_anzahl(), m.fertig()], [1, false])
	m.waehle("Schild")
	pruefe("Herkunftsfertigkeit nicht doppelt", m.wahl, [])
	m.waehle("Handeln")
	pruefe("Mensch fertig", [m.fertig(), m.fertigkeiten().size()], [true, 4])
	# Herkunft wechseln: Wahl bleibt, soweit sie passt
	m.waehle_herkunft("Wanderer")
	pruefe("Wechsel zum Wanderer", [m.wahl, m.wahl_anzahl(), m.frei()], [["Handeln"], 3, 9])
	# Leben und Mana (N 2, werte.json held)
	var hd: Dictionary = W["held"]
	pruefe("Leben", m.max_leben(1), int(hd["leben_basis"]) + int(hd["leben_je_stufe"]) + int(hd["leben_je_zaehigkeit"]) * m.wert("zaehigkeit"))
	pruefe("Mana", m.max_mana(), int(hd["mana_basis"]) + int(hd["mana_je_wille"]) * m.wert("wille"))
	# Spielstand hin und zurück
	var r := BrsHeld.aus_daten(JSON.parse_string(JSON.stringify(b.als_daten())))
	pruefe("Spielstand", r.als_daten(), b.als_daten())
	var z3 := Zustand.new(); z3.brs = b.als_daten()
	pruefe("Spielstand im Zustand", Zustand.aus_daten(JSON.parse_string(JSON.stringify(z3.als_daten()))).brs, b.als_daten())
	# 870.4: der Held im Spiel (Heldenstufe, Leben, Mana, Startausrüstung der Herkunft) und im Spielstand
	var sp := BrsHeld.fuer_spiel("Ada", "Zwerg", "Wachsoldat")
	pruefe("Start Wachsoldat", [sp.waffe()["base"], sp.ruestung(), sp.schild() != null], ["longsword", "Mittlere Rüstung", true])
	pruefe("voll", [sp.leben, sp.mana], [sp.max_leben(), sp.max_mana()])
	sp.stufe = 3
	pruefe("Leben Stufe 3", sp.max_leben(), int(hd["leben_basis"]) + 3 * int(hd["leben_je_stufe"]) + int(hd["leben_je_zaehigkeit"]) * sp.wert("zaehigkeit"))
	sp.leben = 7
	var sr := BrsHeld.aus_spiel_daten(JSON.parse_string(JSON.stringify(sp.spiel_daten())))
	pruefe("Spielstand Held", [sr.name, sr.volk, sr.herkunft, sr.stufe, sr.leben, sr.mana, sr.ausruestung.size()], ["Ada", "Zwerg", "Wachsoldat", 3, 7, sp.mana, sp.ausruestung.size()])
	# Seite „Neues Spiel“ passt in die Breite eines Handys (Pruefer 14:5x: Kopf mit 2 x 120 dp schob alles ueber den rechten Rand)
	root.size = Vector2i(1080, 2340)
	var es := ErschaffungBrs.new()
	root.add_child(es)
	for i in 5: await process_frame
	var platz := 1080.0 - 2 * 24 * AktionsKnopf.DP   # 470 (549a): Seitenrand 24 dp, ohne Kasten
	pruefe("Kopf passt (%d px Platz)" % platz, es.kopf.get_parent().get_combined_minimum_size().x <= platz, true)
	pruefe("Inhalt passt", es.inhalt.get_combined_minimum_size().x <= platz, true)
	# Namen der Grundwerte ungekuerzt (Pruefer 14:5x: „Gewandth…“, „Wahrnehmu…“), auch beim Menschen mit dem Knopf „+1“
	var gefunden := 0
	for lb in es.inhalt.find_children("*", "Label", true, false):
		var t := (lb as Label).text
		if t in ["Gewandtheit", "Wahrnehmung", "Agility", "Perception"]:
			gefunden += 1
			pruefe("%s ganz (%d von %d px)" % [t, lb.size.x, lb.get_minimum_size().x], lb.size.x >= (lb as Label).get_theme_font("font").get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, (lb as Label).get_theme_font_size("font_size")).x, true)
	pruefe("Namen gefunden", gefunden, 2)
	# oben steht, warum „Abenteuer beginnen“ gesperrt ist (Prüfer 02.11., 14:5x), und nichts, wenn es frei ist
	pruefe("Vorgabe frei, oben nichts", [not es.los_an(), es.kopf.find_child("Fehlt", true, false) == null], [es.b.wahl_anzahl() > 0, es.b.wahl_anzahl() == 0])
	# Knöpfe der Fertigkeiten gleich breit (Prüfer 02.11., 14:5x: „Tiere beruhigen“ breiter als die anderen), beim Wanderer mit allen Gruppen
	es.b.waehle_herkunft("Wanderer")
	es.baue()
	for i in 5: await process_frame
	var breiten := {}
	var namen: Array = ErschaffungBrs.FERT.keys().map(func(f): return ErschaffungBrs.fert_name(String(f)).to_upper().replace("ß", "SS"))
	for l in es.inhalt.find_children("Text", "Label", true, false):   # 470 (549a): Wahlfelder ohne Rahmen, Breite des antippbaren Felds
		if namen.has((l as Label).text): breiten[(l as Label).text] = roundi((l.get_parent() as Control).size.x)
	var ziel: int = breiten.values().min()
	var fe: Label = es.kopf.find_child("Fehlt", true, false)
	pruefe("Wanderer gesperrt", not es.los_an(), true)
	pruefe("oben steht warum", fe.text if fe else "", Spielstaende.ohne_waise(es.punkte_satz() + " · " + es.wahl_satz()))   # 557: letzte zwei Woerter verbunden
	pruefe("Fertigkeiten gefunden", breiten.size() >= 30, true)
	# 984.1, Fund t278.38 (Chef 12.11., 15:52 „sind nicht da“): Illusion und Beschwörung stehen in Kapitel 1 matt da, nicht wählbar;
	# Bergbau bleibt verborgen bis Kapitel 2 (461c)
	var farbe := {}
	for l in es.inhalt.find_children("Text", "Label", true, false): farbe[(l as Label).text] = (l as Label).get_theme_color("font_color")
	var gross := func(f: String) -> String: return ErschaffungBrs.fert_name(f).to_upper().replace("ß", "SS")
	var matt := Color(Stil.DIM, 0.75)
	pruefe("Illusion, Beschwörung matt da, Bergbau nicht (984.1)", [farbe.get(gross.call("Illusion")) == matt, farbe.get(gross.call("Beschwörung")) == matt, farbe.has(gross.call("Bergbau")), farbe.get(gross.call("Evokation")) == Stil.GOLD], [true, true, false, true])
	pruefe("Fertigkeiten gleich breit", breiten.keys().filter(func(t): return absi(int(breiten[t]) - int(ziel)) > 1).map(func(t): return "%s %d" % [t, breiten[t]]), [])
	es.queue_free()
	print("BRS470 ", "gut" if fehler == 0 else "%d falsch" % fehler)
	quit(1 if fehler else 0)
