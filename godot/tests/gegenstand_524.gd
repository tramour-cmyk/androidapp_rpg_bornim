extends SceneTree
# 524 (Abgleich 512 zu Build 249): Inhalt des Gegenstandsfensters wie GearDetails alt (GearUi.kt 156–243): Seltenheit und Art,
# Tragort · Stufe · Gewicht, Schaden je Griff mit Schadensart, Angriff +n, Finesse/Fernkampf, Schild, Vergleich mit Obergrenze (519).
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

func stueck(z: Zustand, base: String, rarity := "UNCOMMON", plus := 0) -> Dictionary:
	return {"uid": z.neue_uid.call(), "base": base, "rarity": rarity, "ilvl": 3, "plus": plus, "rolls": [], "unique": null, "name_seed": 1}

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
	var grund := int(BrsHeld.lade()["waffen"][BrsHeld.fertigkeit_von("longsword")]["schaden"])
	for soll in ["Vielseitig: eine oder beide Hände · Stufe 3", "Schaden %d · Hieb" % grund, "Angriff +1"]:
		pruefe(t.contains(soll), "Langschwert ohne „%s“" % soll)
	pruefe(RegEx.create_from_string("\\d+W\\d+").search(t) == null and not t.contains("Mit beiden Händen"), "Langschwert mit Würfeltext: %s" % t)
	var panzer := stueck(z, "chain_mail", "COMMON")
	t = texte(Menue.stueck_zeilen_von(kaempfer, panzer))
	print("Kettenpanzer: ", t)
	pruefe(t.contains("Oberkörper · Stufe 3 · schwer") or t.contains("· Stufe 3 · schwer"), "Kettenpanzer ohne Gewicht")
	pruefe(t.contains("Schutzwert %d" % BrsHeld.schutzwert_von("chain_mail")), "Kettenpanzer ohne Schutzwert nach BRS")   # 683, 870.4
	pruefe(t.contains("Metall:"), "Kettenpanzer ohne Hinweis zu Metall")
	pruefe(not t.contains("schleichen"), "963: Schleichen-Hinweis ruht, bis Schleichen wirkt ([870.14.ding.klirrt])")
	var kugel := stueck(z, "orb", "COMMON")
	t = texte(Menue.stueck_zeilen_von(kaempfer, kugel))
	print("Zauberkugel (Kämpfer): ", t)
	pruefe(not t.contains("Zauberkraft"), "870.4: Zauberkraft entfällt ([870.14.ding])")
	var bogen := stueck(z, "longbow", "COMMON")
	t = texte(Menue.stueck_zeilen_von(magier, bogen))
	print("Langbogen (Magier): ", t)
	pruefe(t.contains("Fernkampf"), "Langbogen ohne „Fernkampf“")
	pruefe(t.contains("Noch nie benutzt: du fängst bei null an.") and not t.contains("Klasse"), "Zauberlehrling mit Langbogen ohne Hinweis „Noch nie benutzt“ ([870.14.ding.neu])")
	# 963 ([870.14.wert.…]): Heldenreiter nennt nur, was wirkt (Gift ohne Krankheit, Kraut ohne Spähen)
	var zae := "\n".join(Menue.erklaerung(kaempfer, "zaehigkeit"))
	pruefe(zae.contains("Abwehr gegen Gift.") and not zae.contains("Krankheit"), "963: Zähigkeit nennt Krankheit: %s" % zae)
	var wahr := "\n".join(Menue.erklaerung(kaempfer, "wahrnehmung"))
	pruefe(wahr.contains("Aussicht auf ein Kraut mehr beim Sammeln.") and not wahr.contains("Spähen"), "963: Wahrnehmung nennt Spähen: %s" % wahr)
	var fackel := Beute.fackel(z.neue_uid.call())
	t = texte(Menue.stueck_zeilen_von(kaempfer, fackel))
	pruefe(t.contains("Pech und Werg auf einem Stock."), "Fackel ohne Erklärung")
	print("GEGENSTAND524 %d Fehler" % fehler)
	quit(1 if fehler else 0)
