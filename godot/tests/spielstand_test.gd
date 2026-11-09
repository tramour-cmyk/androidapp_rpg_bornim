extends SceneTree
# 399 ohne Bild: Erschaffung (Heldwerte.erschaffe) und Spielstand hin und zurueck (Zustand, Heldwerte, Ort); Hauptmenue Schritt fuer
# Schritt bis „Abenteuer beginnen“. Aufruf: im Ordner godot mit -s res://tests/spielstand_test.gd

const KH := preload("res://tests/knopf_hilfe.gd")
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
	# 630: Wahlfelder, − und + und die Knoepfe unten ohne Rahmen, nach Aufschrift (KH)
	var d_ := Heldwerte.lade()
	var tippe := func(t: String, anfang := false) -> void:
		await process_frame
		var k := KH.finde(e, t, anfang)
		if k == null: fehler += 1; print("FEHLER Erschaffung ohne „%s“: %s" % [t, KH.texte(e)])
		else: KH.tippe(k)
	await tippe.call(Sprache.t(d_["voelker"]["DWARF"]["name"]))
	await tippe.call(Sprache.t(d_["klassen"]["CLERIC"]["name"]))
	await tippe.call("−")   # STR einen weniger (erstes −), ein Punkt frei
	await tippe.call(Sprache.u("start"))   # Abenteuer beginnen (unten rechts)
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
	# 630: nur im Fenster, ohne den Knopf Abbrechen
	var karten: Array = e2.get_child(e2.get_child_count() - 1).find_children("*", "PanelContainer", true, false).filter(func(c): return c.gui_input.get_connections().size() > 0 and not c.has_meta("knopf") and c.find_child("Fenster", true, false) == null)
	if karten.size() != 4: fehler += 1; print("FEHLER Platzwahl: %d Karten %s" % [karten.size(), karten.map(func(c): return KH.text(c))])
	else:
		for gedrueckt in [true, false]:   # 700: tippbare Zeile (549a), ausgeloest beim Loslassen an derselben Stelle
			var tipp := InputEventMouseButton.new(); tipp.pressed = gedrueckt; tipp.button_index = MOUSE_BUTTON_LEFT; tipp.position = Vector2(10, 10)
			karten[1].gui_input.emit(tipp)
		if int(w2.get("platz", 0)) != 2: fehler += 1; print("FEHLER Platzwahl: %s" % w2)
	# 795: dieselbe Platzwahl in der Erschaffung nach BRS (ohne Rahmen wie 700): Fenster, vier tippbare Zeilen, Loslassen schliesst
	var e3 := ErschaffungBrs.new()
	root.add_child(e3)
	await process_frame
	var n3 := e3.get_child_count()
	e3.platzwahl()
	await process_frame
	var schl3 := e3.get_child(e3.get_child_count() - 1)
	var karten3: Array = schl3.find_children("Platz*", "", true, false)
	if schl3.find_child("Fenster", true, false) == null or karten3.size() != 4: fehler += 1; print("FEHLER Platzwahl BRS: %d Zeilen" % karten3.size())
	else:
		for gedrueckt in [true, false]:
			var tipp := InputEventMouseButton.new(); tipp.pressed = gedrueckt; tipp.button_index = MOUSE_BUTTON_LEFT; tipp.position = Vector2(10, 10)
			karten3[1].gui_input.emit(tipp)
		await process_frame
		if e3.get_child_count() != n3: fehler += 1; print("FEHLER Platzwahl BRS: Fenster bleibt nach dem Tippen")
	e3.queue_free()
	# Spielstaende: vier Karten, Loeschen fragt nach und loescht Platz 4
	Spielstaende.entwurf = ""   # 557: Karten im alten Aussehen; B prüft spielstaende_529
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
