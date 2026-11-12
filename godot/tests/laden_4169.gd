extends SceneTree
# 416.9 (Chef 31.10., 22:20/22:28, zu 416.3): ohne Bild. Laden, Verkaufen: die Leiste „Angelegt“ zeigt alle neun Plaetze, leere als
# sichtbaren Rahmen (Befund: leerer Platz war ein Bild ohne Inhalt, man sah nur die zwei angelegten); ein Stueck antippen zeigt die
# Vergleichswerte zum Getragenen; nicht Tragbares hat das Zeichen (NoEntry) auf jedem Bild und vor der Ueberschrift; der Kasten
# „Menge“ zeigt das Bild des Dings. Held wie laden_bild_4163 (Elfenmagierin Stufe 9).
# Aufruf: im Ordner godot mit -s res://tests/laden_4169.gd -> „LADEN4169 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func texte(n: Node) -> String:
	var t := ""
	if n is Label: t += (n as Label).text.replace("\u00a0", " ") + "\n"   # 557 Vorlage 2: letzte zwei Wörter fest verbunden
	for c in n.get_children(): t += texte(c)
	return t

func zaehle(n: Node, marke: String) -> int:
	var k := 1 if n.has_meta(marke) else 0
	for c in n.get_children(): k += zaehle(c, marke)
	return k

func offener_kasten(l: Node) -> Node:
	var k: Node = null
	for c in l.get_children():
		# 630 (549a): das Fenster ohne Kasten ist ganz deckend schwarz mit der Spalte „Fenster“
		if c is ColorRect and (c as ColorRect).color.a > 0.5 and ((c as ColorRect).color.a < 1.0 or c.find_child("Fenster", true, false)): k = c
	return k

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 640
	for id in ["potion", "remedy"]: z.dazu(id, 3)
	var hw := BrsHeld.fuer_spiel("Thora", "Elf", "Zauberlehrling", z.neue_uid)
	Testmodus.stufe_setzen(hw, z, 9)
	for i in 8: z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(40 + i), z.neue_uid, 9, ["COMMON", "UNCOMMON", "RARE", "VERY_RARE"][i % 4], "WIZARD" if i % 3 else ""))
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var l := LadenSchirm.new(hw, z, Laden.new(["potion", "remedy"], false))
	ebene.add_child(l)
	await process_frame
	l.seite = "verkaufen"; l.baue()
	await process_frame

	# 1. neun Plaetze, leere sichtbar
	var leiste: HBoxContainer = null
	for c in l.inhalt.get_children():
		if c is HBoxContainer and c.get_child_count() == LadenSchirm.ANGELEGT.size(): leiste = c
	pruefe(leiste != null, "Leiste Angelegt mit neun Plaetzen fehlt")
	if leiste:
		var belegt := 0
		for platz in LadenSchirm.ANGELEGT:
			if hw.ding(platz) is Dictionary or (platz == "OFF_HAND" and l.zweihaendig(hw.ding("MAIN_HAND"))): belegt += 1
		var leer := 0
		for c in leiste.get_children():
			var ctl := c as Control
			pruefe(ctl.custom_minimum_size.x >= 30 * Menue.DP, "Platz zu klein: " + str(ctl.custom_minimum_size))
			if c.has_meta("leer"):
				leer += 1
				var st := (c as PanelContainer).get_theme_stylebox("panel") as StyleBoxFlat
				pruefe(st != null and st.border_color.a > 0.2 and st.get_border_width(SIDE_TOP) >= 1, "leerer Platz ohne sichtbaren Rand")
		pruefe(leer == LadenSchirm.ANGELEGT.size() - belegt, "leere Plaetze %d, erwartet %d" % [leer, LadenSchirm.ANGELEGT.size() - belegt])
		pruefe(leer > 0, "Probe ohne leeren Platz")
		print("Plaetze: ", belegt, " belegt, ", leer, " leer")

	# 2. 644a A (DESIGN-BRS.md 11 „Mindeststufe“; vorher 870.4 „jeder darf alles tragen“): Stücke der Stufe 9 trägt der Held der Stufe 8
	# (Grenze von Kapitel 1) nicht, gewöhnliche in der Stufe ihrer Grundform schon; jedes nicht Tragbare hat das Zeichen, dazu die Überschrift
	var nicht := z.beutel.filter(func(g): return not hw.kann_tragen(g)).size()
	pruefe(nicht > 0 and nicht < z.beutel.size(), "644a: Probe mit Tragbarem und nicht Tragbarem (%d von %d nicht)" % [nicht, z.beutel.size()])
	pruefe(zaehle(l.inhalt, "kein_zeichen") == nicht + 1, "Zeichen %d, erwartet %d" % [zaehle(l.inhalt, "kein_zeichen"), nicht + 1])
	pruefe(not texte(l.inhalt).contains("⊘"), "Schriftzeichen ⊘ noch da")

	# 3. Vergleichswerte beim Antippen eines tragbaren Stuecks
	var g: Dictionary = {}
	for x in z.beutel:
		if hw.kann_tragen(x) and not Vergleich.von(hw, x).zeilen.is_empty(): g = x; break
	pruefe(not g.is_empty(), "Probe ohne tragbares Stueck mit Vergleich")
	if not g.is_empty():
		l.stueck(g, false)
		await process_frame
		var k := offener_kasten(l)
		pruefe(k != null, "Stueck: kein Kasten")
		if k:
			var t := texte(k)
			var v := Vergleich.von(hw, g)
			pruefe(t.contains(v.satz()), "Stueck: Urteil fehlt")
			var r: Dictionary = v.zeilen[0]
			# 416.9 (Chef 02.11., 10:52): Gegenueberstellung als Tabelle wie alt, Kopf „Vergleich | Angelegt | Neu“, je Wert drei Spalten
			pruefe(t.contains("Vergleich\nAngelegt\nNeu\n") or t.contains("Compare\nEquipped\nNew\n"), "Stueck: Tabellenkopf fehlt")
			pruefe(t.contains("%s\n%s\n%s\n" % [r["wort"], r["vorher"], r["nachher"]]), "Stueck: Vergleichszeile fehlt")
			pruefe(not t.contains("%s: %s → %s" % [r["wort"], r["vorher"], r["nachher"]]), "Stueck: Vergleich noch als Satz")
			print("Vergleich: ", v.satz(), " (", v.zeilen.size(), " Zeilen)")
			k.free()

	# 4. Menge mit Bild
	l.seite = "kaufen"; l.baue()
	await process_frame
	l.menge("potion", true, 2)
	await process_frame
	var m := offener_kasten(l)
	pruefe(m != null, "Menge: kein Kasten")
	if m:
		var b := m.find_child("DingBild", true, false) as TextureRect
		pruefe(b != null, "Menge: Bild fehlt")
		if b: pruefe(b.custom_minimum_size.x >= 40 * Menue.DP, "Menge: Bild zu klein")
	print("LADEN4169 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
