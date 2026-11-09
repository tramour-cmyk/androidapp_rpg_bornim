extends SceneTree
# 524 (Abgleich 512 zu Build 249): Inhalt des Gegenstandsfensters wie GearDetails alt (GearUi.kt 156–243): Seltenheit und Art,
# Tragort · Stufe · Gewicht, Schaden je Griff mit Schadensart, Angriff +n, Finesse/Fernkampf, RK der Ruestung mit GES, Schild,
# Zauberkraft, Warnungen „Ungeübt“ und „Zauberkraft nützt nur Zauberwirkern“, Vergleich mit Schnitt und Obergrenze (519).
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
	var kaempfer := Heldwerte.erschaffe("Thora", "HUMAN", "FIGHTER", {}, z.neue_uid)
	var magier := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	var schwert := stueck(z, "longsword", "UNCOMMON", 1)
	var t := texte(Menue.stueck_zeilen_von(kaempfer, schwert))
	print("Langschwert: ", t)
	for soll in ["Vielseitig: eine oder beide Hände · Stufe 3", "Schaden: 1W8+1 Hieb", "Mit beiden Händen (andere Hand leer): 1W10+1", "Angriff +1"]:
		pruefe(t.contains(soll), "Langschwert ohne „%s“" % soll)
	var panzer := stueck(z, "chain_mail", "COMMON")
	t = texte(Menue.stueck_zeilen_von(kaempfer, panzer))
	print("Kettenpanzer: ", t)
	pruefe(t.contains("Oberkörper · Stufe 3 · schwer") or t.contains("· Stufe 3 · schwer"), "Kettenpanzer ohne Gewicht")
	pruefe(t.contains("Schutzwert 16"), "Kettenpanzer ohne Schutzwert")   # 683: Wörter nach BRS
	var kugel := stueck(z, "orb", "COMMON")
	t = texte(Menue.stueck_zeilen_von(kaempfer, kugel))
	print("Zauberkugel (Kämpfer): ", t)
	pruefe(t.contains("Zauberkraft +1"), "Zauberkugel ohne Zauberkraft")
	pruefe(t.contains("Zauberkraft nützt nur Zauberwirkern."), "Kämpfer ohne Hinweis zur Zauberkraft")
	var bogen := stueck(z, "longbow", "COMMON")
	t = texte(Menue.stueck_zeilen_von(magier, bogen))
	print("Langbogen (Magier): ", t)
	pruefe(t.contains("Fernkampf"), "Langbogen ohne „Fernkampf“")
	pruefe(t.contains("Deine Klasse kann das nicht tragen.") or t.contains("Ungeübt: kein Fertigkeitsbonus auf Angriffe."), "Magier mit Langbogen ohne Warnung")
	var fackel := Beute.fackel(z.neue_uid.call())
	t = texte(Menue.stueck_zeilen_von(kaempfer, fackel))
	pruefe(t.contains("Pech und Werg auf einem Stock."), "Fackel ohne Erklärung")
	print("GEGENSTAND524 %d Fehler" % fehler)
	quit(1 if fehler else 0)
