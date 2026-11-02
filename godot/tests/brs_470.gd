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
	# Malus nie unter 3: Zwerg mit Gewandtheit 3 bleibt 3; Bonus hebt 8 auf 9
	var z := BrsHeld.neu("Zwerg", "Wanderer")
	for i in 5: z.hoch("zaehigkeit")
	pruefe("Zwerg", [z.wert("gewandtheit"), z.wert("zaehigkeit"), z.wert("verstand")], [3, 9, 4])
	# Fertigkeiten wählen
	b.waehle("Bogen"); b.waehle("Bergbau"); b.waehle("Spähen"); b.waehle("Dolche")
	pruefe("Wanderer wählt zwei, Bergbau nicht", [b.wahl, b.fertig()], [["Bogen", "Spähen"], true])
	b.waehle("Bogen")
	pruefe("abwählen", b.wahl, ["Spähen"])
	pruefe("nicht wählbar: Bergbau", BrsHeld.waehlbar()["Sammeln"].has("Bergbau"), false)
	var n := 0
	for gr in BrsHeld.waehlbar(): n += (BrsHeld.waehlbar()[gr] as Array).size()
	pruefe("37 Fertigkeiten, Bergbau erst ab Kapitel 2", n, 36)
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
	pruefe("Leben", m.leben(1), int(hd["leben_basis"]) + int(hd["leben_je_stufe"]) + int(hd["leben_je_zaehigkeit"]) * m.wert("zaehigkeit"))
	pruefe("Mana", m.mana(), int(hd["mana_basis"]) + int(hd["mana_je_wille"]) * m.wert("wille"))
	# Spielstand hin und zurück
	var r := BrsHeld.aus_daten(JSON.parse_string(JSON.stringify(b.als_daten())))
	pruefe("Spielstand", r.als_daten(), b.als_daten())
	# Brücke bis 2.3 (470a): Klasse aus der Herkunft, SRD 8..16
	pruefe("SRD-Werte", [BrsHeld.srd_wert(3), BrsHeld.srd_wert(5), BrsHeld.srd_wert(8), BrsHeld.srd_wert(9)], [8, 11, 15, 16])
	var zl := BrsHeld.neu("Hügelvolk", "Zauberlehrling")
	var a := zl.alt()
	pruefe("Zauberlehrling alt", [a["volk"], a["klasse"], a["srd"]["INT"]], ["HALFLING", "WIZARD", BrsHeld.srd_wert(zl.wert("wille"))])
	pruefe("Klosterschüler alt", BrsHeld.neu("Mensch", "Klosterschüler").alt()["klasse"], "CLERIC")
	# Seite „Neues Spiel“ passt in die Breite eines Handys (Pruefer 14:5x: Kopf mit 2 x 120 dp schob alles ueber den rechten Rand)
	root.size = Vector2i(1080, 2340)
	var es := Erschaffung.new()
	root.add_child(es)
	for i in 5: await process_frame
	var platz := 1080.0 - 2 * (12 + 14) * AktionsKnopf.DP
	pruefe("Kopf passt (%d px Platz)" % platz, es.kopf.get_parent().get_combined_minimum_size().x <= platz, true)
	pruefe("Inhalt passt", es.inhalt.get_combined_minimum_size().x <= 1080.0 - 2 * 12 * AktionsKnopf.DP, true)
	# Namen der Grundwerte ungekuerzt (Pruefer 14:5x: „Gewandth…“, „Wahrnehmu…“), auch beim Menschen mit dem Knopf „+1“
	var gefunden := 0
	for lb in es.inhalt.find_children("*", "Label", true, false):
		var t := (lb as Label).text
		if t in ["Gewandtheit", "Wahrnehmung", "Agility", "Perception"]:
			gefunden += 1
			pruefe("%s ganz (%d von %d px)" % [t, lb.size.x, lb.get_minimum_size().x], lb.size.x >= (lb as Label).get_theme_font("font").get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, (lb as Label).get_theme_font_size("font_size")).x, true)
	pruefe("Namen gefunden", gefunden, 2)
	es.queue_free()
	print("BRS470 ", "gut" if fehler == 0 else "%d falsch" % fehler)
	quit(1 if fehler else 0)
