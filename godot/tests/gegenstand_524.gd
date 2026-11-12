extends SceneTree
# 524 (Abgleich 512 zu Build 249): Inhalt des Gegenstandsfensters wie GearDetails alt (GearUi.kt 156–243): Seltenheit und Art,
# Tragort · Stufe · Gewicht, Schaden je Griff mit Schadensart, Angriff +n, Finesse/Fernkampf, Schild, Vergleich mit Obergrenze (519).
# 870.7 ([870.14.ding.…]): Guete statt „Angriff +n“, Schaden und Schutzwert mit Guete, Schadensart aus den Regelwerten, Grundwert im
# Schaden statt Finesse/Fernkampf, Fertigkeit des Stuecks, kein Feld „plus“.
# 870.4: Schutzwert nach BRS, Hinweise zum Tragen nach BRS ([870.14.ding.…]), ohne Zauberkraft und ohne Klasse.
# Ohne Bildbefehl. Aufruf: im Ordner godot mit -s res://tests/gegenstand_524.gd -> „GEGENSTAND524 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func texte(zeilen: Array) -> String:
	var aus: PackedStringArray = []
	for c in zeilen:
		if c is Label: aus.append((c as Label).text)
		for l in (c as Node).find_children("*", "Label", true, false): aus.append((l as Label).text)
	return " | ".join(aus).replace("\u00a0", " ")   # 557 Vorlage 2: die letzten zwei Wörter fest verbunden

func stueck(z: Zustand, base: String, rarity := "UNCOMMON", guete := 0) -> Dictionary:
	return {"uid": z.neue_uid.call(), "base": base, "rarity": rarity, "ilvl": 3, "guete": guete, "rolls": [], "unique": null, "name_seed": 1}

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	var kaempfer := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var magier := BrsHeld.fuer_spiel("Mira", "Elf", "Zauberlehrling", z.neue_uid)
	var schwert := stueck(z, "longsword", "UNCOMMON", 1)
	var t := texte(Menue.stueck_zeilen_von(kaempfer, schwert))
	print("Langschwert: ", t)
	# 944 (t276.5): Schaden als Zahl nach dem BRS, kein Würfel, keine Zeile „Mit beiden Händen“
	var gut := Beute.schaden(schwert)
	pruefe(gut > int(BrsHeld.lade()["waffen"][BrsHeld.fertigkeit_von("longsword")]["schaden"]), "870.7: Güte „Gut“ hebt den Schaden nicht (%d)" % gut)
	for soll in ["Haupt- oder Nebenhand · Stufe 3", "Schaden %d · Schnitt" % gut, "Güte: Gut", "Fertigkeit: Einhänder", "Schaden mit Kraft"]:
		pruefe(t.contains(soll), "Langschwert ohne „%s“" % soll)
	pruefe(not t.contains("Angriff") and not t.contains(" +1"), "870.7: Langschwert mit „Angriff +n“ oder „+1“: %s" % t)
	pruefe(RegEx.create_from_string("\\d+W\\d+").search(t) == null and not t.contains("Mit beiden Händen"), "Langschwert mit Würfeltext: %s" % t)
	var panzer := stueck(z, "chain_mail", "COMMON")
	t = texte(Menue.stueck_zeilen_von(kaempfer, panzer))
	print("Kettenpanzer: ", t)
	pruefe(t.contains("Oberkörper · Stufe 3 · schwer") or t.contains("· Stufe 3 · schwer"), "Kettenpanzer ohne Gewicht")
	pruefe(t.contains("Schutzwert %d" % BrsHeld.schutzwert_von("chain_mail")) and t.contains("Güte: Normal"), "Kettenpanzer ohne Schutzwert nach BRS")   # 683, 870.4
	var meister := stueck(z, "chain_mail", "COMMON", 2)   # 870.7: Schutzwert mit Guete
	var tm := texte(Menue.stueck_zeilen_von(kaempfer, meister))
	pruefe(Beute.schutzwert(meister) > BrsHeld.schutzwert_von("chain_mail") and tm.contains("Schutzwert %d" % Beute.schutzwert(meister)) and tm.contains("Güte: Meisterhaft"),
		"Meisterhafter Kettenpanzer ohne Schutzwert mit Güte: %s" % tm)
	var episch := stueck(z, "shortsword", "EPIC")   # 870.7: „Fertigkeit +n“ mit dem Namen der Fertigkeit, englisch übersetzt
	episch["rolls"] = [["SKILL", 1, "Dolche"], ["CRIT", 3]]
	var te := texte(Menue.stueck_zeilen_von(kaempfer, episch))
	pruefe(te.contains("+1 Dolche") and te.contains("+3 % kritisch"), "Episches Kurzschwert ohne Zusatzeigenschaften im Wortlaut: %s" % te)
	pruefe(Beute.zusatz_text(["SKILL", 1, "Dolche"], "en") == "+1 Daggers", "„Fertigkeit +n“ englisch: %s" % Beute.zusatz_text(["SKILL", 1, "Dolche"], "en"))
	pruefe(not t.contains("schleichen") and t.contains("Metall:"), "Kettenpanzer ohne Hinweis Metall oder mit „schleichen“ (ruht bis Schleichen wirkt, 963)")
	pruefe(not t.contains("Vielseitig"), "870.7: „Vielseitig“ entfällt (kein Kampf mit beiden Händen, STORY-BRS-HELD.md)")
	var kugel := stueck(z, "orb", "COMMON")
	t = texte(Menue.stueck_zeilen_von(kaempfer, kugel))
	print("Zauberkugel (Kämpfer): ", t)
	pruefe(not t.contains("Zauberkraft"), "870.4: Zauberkraft entfällt ([870.14.ding])")
	var bogen := stueck(z, "longbow", "COMMON")
	t = texte(Menue.stueck_zeilen_von(magier, bogen))
	print("Langbogen (Magier): ", t)
	pruefe(t.contains("Schaden mit Gewandtheit") and t.contains("Fertigkeit: Bogen") and not t.contains("Fernkampf"), "Langbogen ohne „Schaden mit Gewandtheit“ (870.7 statt „Fernkampf“)")
	pruefe(t.contains("Noch nie benutzt: du fängst bei null an.") and not t.contains("Klasse"), "Zauberlehrling mit Langbogen ohne Hinweis „Noch nie benutzt“ ([870.14.ding.neu])")
	# 963 ([870.14.wert.…]): Heldenreiter nennt nur, was wirkt (Gift ohne Krankheit, Kraut ohne Spähen)
	var zae := "\n".join(Menue.erklaerung(kaempfer, "zaehigkeit"))
	pruefe(zae.contains("Abwehr gegen Gift") and not zae.contains("Krankheit"), "963: Zähigkeit nennt Krankheit: %s" % zae)
	var wahr := "\n".join(Menue.erklaerung(kaempfer, "wahrnehmung"))
	pruefe(wahr.contains("Aussicht auf ein Kraut mehr beim Sammeln.") and not wahr.contains("Spähen"), "963: Wahrnehmung nennt Spähen: %s" % wahr)
	var fackel := Beute.fackel(z.neue_uid.call())
	t = texte(Menue.stueck_zeilen_von(kaempfer, fackel))
	pruefe(t.contains("Pech und Werg auf einem Stock."), "Fackel ohne Erklärung")
	print("GEGENSTAND524 %d Fehler" % fehler)
	quit(1 if fehler else 0)
