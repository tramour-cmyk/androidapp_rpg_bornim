extends SceneTree
# 399.1 ohne Bild: Leiste (TP, ZP, EP, Tag und Uhr, Zustaende, freie Punkte) und Menue (Held, Tasche, Punkte verteilen) wie im
# alten Spiel. Aufruf: im Ordner godot mit -s res://tests/menue_test.gd

func _initialize() -> void: _lauf.call_deferred()

func texte(n: Node) -> String:
	return " | ".join(PackedStringArray(n.find_children("*", "Label", true, false).map(func(l): return l.text)))

func _lauf() -> void:
	var fehler := 0
	Sprache.lade()
	var z := Zustand.new()
	z.gold = 37; z.dazu("potion", 2); z.tag = 3; z.minuten = 21 * 60 + 5
	z.leiden["POISON"] = 2
	var hw := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	hw.ep_dazu(int(Heldwerte.regel("ep_fuer_stufe")[4]))   # Stufe 4: zwei freie Attributspunkte
	hw.tp = 5
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(42), z.neue_uid, 3, "RARE", "WIZARD"))
	var l := Leiste.new()
	root.add_child(l)
	l.zeige(hw, z, true)
	await process_frame
	var t := texte(l)
	print("Leiste: ", t)
	for soll in ["5/%d" % hw.max_tp(), "Tag 3 · 21:05" if Sprache.aktiv() == "de" else "Day 3 · 21:05", "★ +%d" % hw.offen]:
		if not t.contains(soll): fehler += 1; print("FEHLER Leiste ohne ", soll)
	if l.zeichen.art != "mond": fehler += 1; print("FEHLER Leiste: nachts kein Mond")
	if hw.offen <= 0: fehler += 1; print("FEHLER keine freien Punkte bei Stufe %d" % hw.stufe)
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	t = texte(m)
	for soll in ["MIRA", ": 37", "%d / %d" % [5, hw.max_tp()]]:
		if not t.contains(soll): fehler += 1; print("FEHLER Held ohne ", soll)
	# Punkte verteilen: + bei Intelligenz, Uebernehmen, Ja
	var int_vor := hw.wert("INT")
	var plus: Array = m.inhalt.find_children("*", "Button", true, false).filter(func(b): return b.text == "+")
	plus[3].pressed.emit()   # STR, DEX, CON, INT
	await process_frame; await process_frame
	var ueb: Array = m.inhalt.find_children("*", "Button", true, false).filter(func(b): return b.text in ["ÜBERNEHMEN", "APPLY"])
	if ueb.is_empty(): fehler += 1; print("FEHLER kein Übernehmen")
	else:
		ueb[0].pressed.emit()
		await process_frame
		var ja: Array = m.find_children("*", "Button", true, false).filter(func(b): return b.text in ["JA, VERTEILEN", "YES, SPEND"])
		ja[0].pressed.emit()
		await process_frame; await process_frame
		if hw.wert("INT") != int_vor + 1: fehler += 1; print("FEHLER INT %d -> %d" % [int_vor, hw.wert("INT")])
	# Tasche
	var reiter: Array = m.leiste.find_children("*", "Button", true, false)
	reiter[1].pressed.emit()
	await process_frame; await process_frame
	t = texte(m)
	print("Tasche: ", t.substr(0, 300))
	for soll in [Laden.name("potion"), "×2", "37", Beute.name(z.beutel[0])]:
		if not t.contains(soll): fehler += 1; print("FEHLER Tasche ohne ", soll)
	# 399.1 Benutzen (Game.useItemOutside): Heiltrank mit festen Wuerfeln, Kraeutertrank heilt das Gift, voll heisst voll
	var vier := func(n: int, w: int) -> int: return n * 3
	var tp_vor := hw.tp
	var s1 := Menue.benutze(z, hw, "potion", vier)
	if hw.tp != mini(hw.max_tp(), tp_vor + 8) or z.anzahl("potion") != 1 or not s1.contains(str(hw.tp - tp_vor)): fehler += 1; print("FEHLER Heiltrank: ", s1, " TP ", hw.tp)
	z.dazu("remedy")
	var s2 := Menue.benutze(z, hw, "remedy", vier)
	if not z.leiden.is_empty() or z.anzahl("remedy") != 0: fehler += 1; print("FEHLER Kräutertrank: ", s2)
	hw.tp = hw.max_tp()
	var s3 := Menue.benutze(z, hw, "potion", vier)
	if z.anzahl("potion") != 1 or s3 != Sprache.u("alreadyFull"): fehler += 1; print("FEHLER voll: ", s3)
	z.dazu("spark_potion")
	Menue.benutze(z, hw, "spark_potion", vier)
	if not z.funke or z.anzahl("spark_potion") != 0: fehler += 1; print("FEHLER Leuchtfunke")
	print("Benutzen: ", s1, " | ", s2, " | ", s3)
	# Tasche: Antippen des Heiltranks zeigt den Kasten mit Benutzen
	var zeilen_: Array = m.inhalt.get_children().filter(func(c): return c is HBoxContainer and texte(c).contains(Laden.name("potion")))
	if zeilen_.is_empty(): fehler += 1; print("FEHLER Heiltrank-Zeile fehlt")
	else:
		var los := InputEventMouseButton.new(); los.button_index = MOUSE_BUTTON_LEFT; los.pressed = true
		zeilen_[0].gui_input.emit(los)
		var hoch := InputEventMouseButton.new(); hoch.button_index = MOUSE_BUTTON_LEFT; hoch.pressed = false
		zeilen_[0].gui_input.emit(hoch)
		await process_frame
		var knoepfe: Array = m.find_children("*", "Button", true, false).map(func(b): return b.text)
		if Sprache.u("use").to_upper() not in knoepfe: fehler += 1; print("FEHLER kein Benutzen-Knopf: ", knoepfe)
		for c in m.get_children(): if c is ColorRect and c.color.a < 0.9: c.queue_free()
		await process_frame
	# Ausruestung: anlegen aus der Tasche, Platz zeigt es, ablegen bringt es zurueck
	var g: Dictionary = z.beutel[0]
	var platz := String(Beute.grundform(String(g["base"]))["slot"])
	var meld := m.lege_an(g)
	if hw.ding(platz) == null or int(hw.ding(platz)["uid"]) != int(g["uid"]) or m.im_beutel(g) >= 0: fehler += 1; print("FEHLER anlegen: ", meld)
	m.reiter = "ausruestung"; m.baue()
	await process_frame; await process_frame
	t = texte(m)
	print("Ausrüstung: ", t.substr(0, 400))
	for soll in [Beute.name(g), m.platzname("HEAD"), m.platzname("OFF_HAND"), Sprache.u("attack")]:
		if not t.contains(soll): fehler += 1; print("FEHLER Ausrüstung ohne ", soll)
	m.lege_ab(platz)
	if hw.ding(platz) != null or m.im_beutel(g) < 0: fehler += 1; print("FEHLER ablegen")
	if m.passend(platz).is_empty(): fehler += 1; print("FEHLER passend leer fuer ", platz)
	# Satt wird gespeichert
	z.satt = true
	if not Zustand.aus_daten(z.als_daten()).satt: fehler += 1; print("FEHLER satt nicht gespeichert")
	print("MENUE %d Fehler" % fehler)
	quit(1 if fehler else 0)
