extends SceneTree
# 399 ohne Bild: Erschaffung (Heldwerte.erschaffe) und Spielstand hin und zurueck (Zustand, Heldwerte, Ort); Hauptmenue Schritt fuer
# Schritt bis „Abenteuer beginnen“. Aufruf: im Ordner godot mit -s res://tests/spielstand_test.gd

const KH := preload("res://tests/knopf_hilfe.gd")
func _initialize() -> void: _lauf.call_deferred()

func _leer() -> void:
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	if FileAccess.file_exists(Spielstand.ALT): DirAccess.remove_absolute(ProjectSettings.globalize_path(Spielstand.ALT))

# 870.8 (870a 1): ein echter Spielstand der Version 1 (Build 275, main 11.11., Zwerg Kaempfer „Brann“, tests/golden) laedt nicht:
# „Weiter“ fehlt, lade() gibt nichts, die Liste zeigt ihn mit Hinweis und nur Loeschen, in beiden Entwuerfen; kein Absturz
func _alt_870_8() -> int:
	var f := 0
	_leer()
	var q := FileAccess.open(Spielstand.datei(2), FileAccess.WRITE); q.store_string(FileAccess.get_file_as_string("res://tests/golden/spielstand_v1.json")); q.close()
	if not Spielstand.alt(Spielstand.liste()[1]) or not Spielstand.lade(2).is_empty() or not Spielstand.lade().is_empty() or Spielstand.letzter() != 0 or not Spielstand.gibt_es():
		f += 1; print("FEHLER 870.8 Spielstand: alt %s, lade %s, letzter %d" % [Spielstand.alt(Spielstand.liste()[1]), Spielstand.lade(2).keys(), Spielstand.letzter()])
	var st := Steuerung.new()
	root.add_child(st)
	var m := Hauptmenue.new(st)
	st.add_child(m)
	await process_frame
	var texte: Array = m.box.find_children("*", "Button", true, false).filter(func(c): return not c.is_queued_for_deletion()).map(func(b): return KH.text(b))
	if texte.any(func(t): return t.to_lower().begins_with("weiter") or t.to_lower().begins_with("continue")) or not texte.any(func(t): return t.to_lower().contains("spielst") or t.to_lower().contains("saved")):
		f += 1; print("FEHLER 870.8 Hauptmenue: %s" % [texte])
	st.queue_free()
	for e in ["", "B"]:
		Spielstaende.entwurf = e
		var sp := Spielstaende.new()
		root.add_child(sp)
		await process_frame
		var geladen := []
		sp.laden.connect(func(p): geladen.append(p))
		var satz := Spielstaende.alt_satz(Sprache.aktiv() == "de")
		var woerter: Array = sp.liste.find_children("*", "", true, false).filter(func(c): return c is Label or c is Button).map(func(c): return String(c.text).replace("\u00a0", " "))   # ohne_waise
		var alle := " | ".join(PackedStringArray(woerter))
		var laden_ := woerter.filter(func(t): return t.to_lower().begins_with("laden") or t.to_lower().begins_with("load"))
		if not alle.contains(satz) or not alle.to_upper().contains("BRANN") or laden_.size() != 0 or sp.liste.find_child("Heldbild", true, false) != null:
			f += 1; print("FEHLER 870.8 Spielstaende %s: %s" % [e, alle])
		# Antippen der Zeile laedt nicht
		for c in sp.liste.find_children("*", "Control", true, false):
			if c.gui_input.get_connections().size() > 0:
				for gedrueckt in [true, false]:
					var tipp := InputEventMouseButton.new(); tipp.pressed = gedrueckt; tipp.button_index = MOUSE_BUTTON_LEFT; tipp.position = Vector2(10, 10)
					c.gui_input.emit(tipp)
		await process_frame
		if geladen.has(2): f += 1; print("FEHLER 870.8 Spielstaende %s: alter Stand laedt" % e)
		print("870.8 Spielstaende %s: %s" % [e, alle.replace("\n", " | ").left(240)])
		sp.queue_free()
		await process_frame
	Spielstaende.entwurf = "B"
	return f

func _lauf() -> void:
	var fehler := 0
	_leer()
	Spielstand.platz = 1
	var z := Zustand.new()
	z.name = "Mira"; z.gold = 23; z.dazu("potion", 2); z.setze("met_jorin")
	var hw := BrsHeld.fuer_spiel("Mira", "Elf", "Zauberlehrling", z.neue_uid)
	hw.leben = 3
	Spielstand.speichere(z, hw, {"karte": "inn", "x": 4, "y": 6, "blick": "UP"})
	var d := Spielstand.lade()
	var z2 := Zustand.aus_daten(d["zustand"])
	var h2 := BrsHeld.aus_spiel_daten(d["held"])
	if z2.gold != 23 or z2.anzahl("potion") != 2 or not z2.has("met_jorin"): fehler += 1; print("FEHLER Zustand")
	if h2.herkunft != "Zauberlehrling" or h2.volk != "Elf" or h2.leben != 3 or h2.max_leben() != hw.max_leben() or h2.schutzwert() != hw.schutzwert(): fehler += 1; print("FEHLER Held %s" % h2.spiel_daten())
	if String(d["ort"]["karte"]) != "inn": fehler += 1; print("FEHLER Ort")
	print("Spielstand: %s %s %s, Leben %d/%d, Schutzwert %d" % [h2.name, h2.volk, h2.herkunft, h2.leben, h2.max_leben(), h2.schutzwert()])
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
	# 1009 (Lauf 366 „FEHLER Plaetze 1 2“): zwei Speicherungen in derselben Millisekunde; „Weiter“ nimmt trotzdem die spätere
	var gleich := 0
	for i in 30:
		Spielstand.platz = 1; Spielstand.speichere(z, hw, {"karte": "village", "x": 1, "y": 1, "blick": "UP"})
		Spielstand.platz = 3; Spielstand.speichere(z, hw, {"karte": "village", "x": 1, "y": 1, "blick": "UP"})
		if Spielstand.letzter() != 3: gleich += 1
	if gleich > 0: fehler += 1; print("FEHLER 1009 gleiche Millisekunde: %d von 30 mal Platz 1 statt 3" % gleich)
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
	await druecke.call(0)   # Neues Spiel (ohne Spielstand der erste Knopf): 470 Erschaffung nach BRS (erschaffung_brs.gd)
	await process_frame
	var e: ErschaffungBrs = m.get_node("Erschaffung")
	# 630/470: Wahlfelder, − und + und die Knoepfe unten ohne Rahmen, nach Aufschrift (KH)
	var tippe := func(t: String, anfang := false) -> void:
		await process_frame
		var k := KH.finde(e, t, anfang)
		if k == null: fehler += 1; print("FEHLER Erschaffung ohne „%s“: %s" % [t, KH.texte(e)])
		else: KH.tippe(k)
	if KH.finde(e, ("Kämpfer" if Sprache.aktiv() == "de" else "Fighter").to_upper()) != null: fehler += 1; print("FEHLER Erschaffung: alte Klassenwahl noch da")
	await tippe.call(ErschaffungBrs.tx(ErschaffungBrs.VOLK["Zwerg"]).to_upper())
	await tippe.call(ErschaffungBrs.tx(ErschaffungBrs.HERKUNFT["Klosterschüler"]).to_upper().replace("ß", "SS"))
	var vor_kraft := e.b.wert("kraft")
	await tippe.call("−")   # Kraft einen weniger (erstes −), ein Punkt frei: Abenteuer beginnen gesperrt
	if e.b.frei() != 1: fehler += 1; print("FEHLER Grundwerte: − gibt keinen Punkt frei (%d)" % e.b.frei())
	await tippe.call(Sprache.u("start"))
	await process_frame
	if not ergebnis.is_empty(): fehler += 1; print("FEHLER Erschaffung: beginnt mit freiem Punkt")
	await tippe.call("+")   # erstes + (Kraft) wieder hoch
	await tippe.call(Sprache.u("start"))   # Abenteuer beginnen (unten rechts)
	await process_frame
	print("Hauptmenue: %s" % ergebnis)
	if String(ergebnis.get("brs", {}).get("volk", "")) != "Zwerg" or ergebnis.has("klasse") or String(ergebnis.get("brs", {}).get("herkunft", "")) != "Klosterschüler" or String(ergebnis.get("name", "")) == "" or int(ergebnis.get("platz", 0)) != 1: fehler += 1; print("FEHLER Hauptmenue")
	if int(ergebnis.get("brs", {}).get("grundwerte", {}).get("kraft", -1)) != vor_kraft: fehler += 1; print("FEHLER Grundwerte: Kraft %s statt %d" % [ergebnis.get("brs", {}).get("grundwerte", {}).get("kraft"), vor_kraft])
	# alle vier Plaetze belegt: Abenteuer beginnen fragt, wen der Neue ersetzt (alt SlotChooser); Antippen des zweiten waehlt Platz 2
	for n in range(1, 5):
		Spielstand.platz = n
		Spielstand.speichere(z, hw, {"karte": "inn", "x": 4, "y": 6, "blick": "UP"})
	var e2 := ErschaffungBrs.new()
	root.add_child(e2)
	await process_frame
	var w2 := {}
	e2.fertig.connect(func(w): w2.merge(w))
	e2.volk_waehlen("Zwerg")   # Mensch waehlt eine Fertigkeit selbst, sonst ist die Seite nicht fertig
	await process_frame
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
	e2.queue_free()
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
	sp.queue_free()
	fehler += await _alt_870_8()
	_leer()
	print("SPIELSTAND %d Fehler" % fehler)
	quit(1 if fehler else 0)
