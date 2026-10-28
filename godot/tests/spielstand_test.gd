extends SceneTree
# 399 ohne Bild: Erschaffung (Heldwerte.erschaffe) und Spielstand hin und zurueck (Zustand, Heldwerte, Ort); Hauptmenue Schritt fuer
# Schritt bis „Abenteuer beginnen“. Aufruf: im Ordner godot mit -s res://tests/spielstand_test.gd

func _initialize() -> void: _lauf.call_deferred()

func _leer() -> void:
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	if FileAccess.file_exists(Spielstand.ALT): DirAccess.remove_absolute(ProjectSettings.globalize_path(Spielstand.ALT))

func _lauf() -> void:
	var fehler := 0
	_leer()
	Spielstand.platz = 1
	var z := Zustand.new()
	z.name = "Mira"; z.gold = 23; z.dazu("potion", 2); z.setze("met_jorin")
	var hw := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	hw.tp = 3
	Spielstand.speichere(z, hw, {"karte": "inn", "x": 4, "y": 6, "blick": "UP"})
	var d := Spielstand.lade()
	var z2 := Zustand.aus_daten(d["zustand"])
	var h2 := Heldwerte.aus_daten(d["held"])
	if z2.gold != 23 or z2.anzahl("potion") != 2 or not z2.has("met_jorin"): fehler += 1; print("FEHLER Zustand")
	if h2.klasse != "WIZARD" or h2.volk != "ELF" or h2.tp != 3 or h2.max_tp() != hw.max_tp() or h2.rk() != hw.rk(): fehler += 1; print("FEHLER Held %s" % h2.als_daten())
	if String(d["ort"]["karte"]) != "inn": fehler += 1; print("FEHLER Ort")
	print("Spielstand: %s %s %s, TP %d/%d, RK %d" % [h2.name, h2.volk, h2.klasse, h2.tp, h2.max_tp(), h2.rk()])
	# 399.1 vier Plaetze wie alt: der alte eine Stand wird Platz 1, „Weiter“ nimmt den zuletzt gespeicherten, Loeschen, erster freier
	var alt := FileAccess.get_file_as_string(Spielstand.datei(1))
	_leer()
	var f := FileAccess.open(Spielstand.ALT, FileAccess.WRITE); f.store_string(alt); f.close()
	if Spielstand.lade().get("platz", 0) != 1 or FileAccess.file_exists(Spielstand.ALT): fehler += 1; print("FEHLER Umzug des alten Spielstands")
	Spielstand.platz = 3
	hw.name = "Tor"
	Spielstand.speichere(z, hw, {"karte": "village", "x": 1, "y": 1, "blick": "UP"})
	var l := Spielstand.liste()
	if Spielstand.letzter() != 3 or l[1].size() != 0 or String(l[2]["held"]["name"]) != "Tor" or Spielstand.frei() != 2: fehler += 1; print("FEHLER Plaetze %d %d" % [Spielstand.letzter(), Spielstand.frei()])
	Spielstand.loesche(3)
	if Spielstand.letzter() != 1: fehler += 1; print("FEHLER Loeschen")
	print("Plaetze: letzter %d, frei %d" % [Spielstand.letzter(), Spielstand.frei()])
	_leer()
	var st := Steuerung.new()
	root.add_child(st)
	var m := Hauptmenue.new(st)
	st.add_child(m)
	await process_frame
	var ergebnis := {}
	m.fertig.connect(func(w): ergebnis.merge(w))
	var druecke := func(i: int):
		await process_frame
		var bs: Array = m.box.find_children("*", "Button", true, false).filter(func(c): return not c.is_queued_for_deletion())
		bs[i].pressed.emit()
	await druecke.call(0)   # Neues Spiel (ohne Spielstand der erste Knopf): 399.1 Erschaffung auf einer Seite (erschaffung.gd)
	await process_frame
	var e: Erschaffung = m.get_node("Erschaffung")
	var knoepfe := func() -> Array:
		await process_frame
		return e.find_children("*", "Button", true, false).filter(func(c): return not c.is_queued_for_deletion())
	var bs: Array = await knoepfe.call()
	bs[2].pressed.emit()    # Volk: Zwerg (Reihe Mensch, Elf, Zwerg, Halbling, Halbork)
	bs = await knoepfe.call()
	bs[5 + 3].pressed.emit()   # Klasse: Kleriker (Kaempfer, Magier, Schurke, Kleriker)
	bs = await knoepfe.call()
	var minus: Button = bs[5 + 4 + 1]   # nach Vorschlag: − und + je Attribut, STR zuerst
	minus.pressed.emit()    # STR einen weniger, ein Punkt frei
	bs = await knoepfe.call()
	bs[bs.size() - 1].pressed.emit()   # Abenteuer beginnen (unten rechts)
	await process_frame
	print("Hauptmenue: %s" % ergebnis)
	if ergebnis.get("volk") != "DWARF" or ergebnis.get("klasse") != "CLERIC" or String(ergebnis.get("name", "")) == "" or int(ergebnis.get("platz", 0)) != 1: fehler += 1; print("FEHLER Hauptmenue")
	var vor := Heldwerte.vorschlag("CLERIC")
	if int(ergebnis.get("werte", {}).get("STR", 0)) != int(vor["STR"]) - 1 or not Heldwerte.gueltiger_kauf(ergebnis.get("werte", {})): fehler += 1; print("FEHLER Punktekauf")
	var h3 := Heldwerte.erschaffe(String(ergebnis["name"]), "DWARF", "CLERIC", ergebnis["werte"])
	if h3.basis["STR"] != int(vor["STR"]) - 1 + 1: fehler += 1; print("FEHLER Punktekauf im Helden: STR %d" % h3.basis["STR"])   # Zwerg STR +1
	# alle vier Plaetze belegt: Abenteuer beginnen fragt, wen der Neue ersetzt (alt SlotChooser); Antippen des zweiten waehlt Platz 2
	for n in range(1, 5):
		Spielstand.platz = n
		Spielstand.speichere(z, hw, {"karte": "inn", "x": 4, "y": 6, "blick": "UP"})
	var e2 := Erschaffung.new()
	root.add_child(e2)
	await process_frame
	var w2 := {}
	e2.fertig.connect(func(w): w2.merge(w))
	e2.beginne()
	await process_frame
	var karten: Array = e2.find_children("*", "PanelContainer", true, false).filter(func(c): return c.gui_input.get_connections().size() > 0)
	if karten.size() != 4: fehler += 1; print("FEHLER Platzwahl: %d Karten" % karten.size())
	else:
		var tipp := InputEventMouseButton.new(); tipp.pressed = true; tipp.button_index = MOUSE_BUTTON_LEFT
		karten[1].gui_input.emit(tipp)
		if int(w2.get("platz", 0)) != 2: fehler += 1; print("FEHLER Platzwahl: %s" % w2)
	# Spielstaende: vier Karten, Loeschen fragt nach und loescht Platz 4
	var sp := Spielstaende.new()
	root.add_child(sp)
	await process_frame
	var geladen := []
	sp.laden.connect(func(p): geladen.append(p))
	var lk: Array = sp.liste.find_children("*", "Button", true, false)
	lk[lk.size() - 1].pressed.emit()   # Laden Platz 4
	lk[lk.size() - 2].pressed.emit()   # Loeschen Platz 4: Rueckfrage
	await process_frame
	var ja: Array = sp.find_children("*", "Button", true, false).filter(func(b): return b.text.begins_with("LÖSCHEN") or b.text.begins_with("DELETE"))
	ja[ja.size() - 1].pressed.emit()
	await process_frame
	if geladen != [4] or Spielstand.liste()[3].size() != 0: fehler += 1; print("FEHLER Spielstaende %s" % [geladen])
	_leer()
	print("SPIELSTAND %d Fehler" % fehler)
	quit(1 if fehler else 0)
