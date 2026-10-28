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
	print("MENUE %d Fehler" % fehler)
	quit(1 if fehler else 0)
