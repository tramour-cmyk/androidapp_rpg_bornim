extends SceneTree
# 528 (Abgleich 512): Held, Karte, Chronik wie alt. Prueft ohne Bild: am Stufendeckel des Kapitels der Satz zur Hoechststufe am
# EP-Balken (MenuScreen.kt 594–601); das Kartenzeichen in der oberen Leiste (WorldScreen.kt HudChip onMap) meldet „karte“, der
# Rest der Leiste „menue“; die Karte vom Kartenzeichen, noch einmal „Karte“ angetippt, schliesst das Menue (86.2);
# „Auf der Karte“ bei Nebenauftraegen nur mit Zeichen des Auftraggebers, oeffnet die Karte auf ihm mit seinem Namen (ChronicleTab.kt 100).
# Aufruf: im Ordner godot mit -s res://tests/held_karte_528.gd -> „HELDKARTE528 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func finde(n: Node, name_: String) -> Node: return n.find_child(name_, true, false)

func klick(c: Control, p: Vector2) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	e.position = p
	c._gui_input(e)

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var ebene := CanvasLayer.new()
	root.add_child(ebene)

	# 1. Hoechststufe am EP-Balken: auf der hoechsten Stufe des Kapitels ja (870.4: Grenze nach BRS mit weicher Grenze), auf Stufe 2 nein
	for stufe in [2, Brs.hoechste_stufe()]:
		var z := Zustand.new()
		z.name = "Thora"
		var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
		Testmodus.stufe_setzen(hw, z, stufe)
		pruefe(hw.stufe == stufe, "Stufe %d nicht erreicht: %d" % [stufe, hw.stufe])
		var m := Menue.new(hw, z)
		ebene.add_child(m)
		await process_frame
		var s := finde(m, "Hoechststufe")
		pruefe((s != null) == (stufe >= Brs.hoechste_stufe()), "Satz zur Hoechststufe auf Stufe %d: %s" % [stufe, "da" if s else "fehlt"])
		if s: pruefe((s as Label).text.begins_with("Höchststufe für Kapitel 1 erreicht."), "Wortlaut: %s" % (s as Label).text)
		m.free()

	# 2. Kartenzeichen in der Leiste
	var l := Leiste.new()
	l.size = Vector2(1080, 120)
	ebene.add_child(l)
	await process_frame
	await process_frame
	var kf: Control = l.kartenfeld
	pruefe(kf != null and kf.size.x >= 43 * AktionsKnopf.DP and kf.size.y >= 39 * AktionsKnopf.DP, "Kartenfeld nicht 44 × 40 dp")
	var was := []
	l.karte.connect(func(): was.append("karte"))
	l.menue.connect(func(): was.append("menue"))
	klick(l, kf.get_global_rect().get_center() - l.global_position)
	klick(l, Vector2(10, 10))
	pruefe(was == ["karte", "menue"], "Leiste meldet %s statt [karte, menue]" % [was])

	# 3. Karte vom Kartenzeichen: „Karte“ noch einmal schliesst
	var z2 := Zustand.new()
	z2.name = "Thora"
	var hw2 := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z2.neue_uid)
	var m2 := Menue.new(hw2, z2)
	m2.reiter = "karte"; m2.karte_direkt = true
	m2.ort = {"karte": "village", "x": 20, "y": 20, "blick": "DOWN"}
	ebene.add_child(m2)
	await process_frame
	var zu := []
	m2.zu.connect(func(): zu.append(true))
	m2.tippe_reiter("chronik")
	pruefe(zu.is_empty() and m2.reiter == "chronik" and not m2.karte_direkt, "anderer Reiter schliesst oder bleibt direkt")
	m2.tippe_reiter("karte")
	m2.tippe_reiter("karte")
	pruefe(zu.is_empty(), "Karte ueber die Chronik geoeffnet schliesst beim zweiten Antippen")
	m2.karte_direkt = true
	m2.tippe_reiter("karte")
	pruefe(zu.size() == 1, "Karte vom Kartenzeichen schliesst beim zweiten Antippen nicht")

	# 4. „Auf der Karte“ bei Nebenauftraegen
	var j: Dictionary = Auftraege.alle()[0]
	var wer := String(j["geber"])
	Auftraege.nimm(z2, j)
	m2.reiter = "chronik"; m2.baue()
	await process_frame
	pruefe(finde(m2, "AufDerKarte") == null, "„Auf der Karte“ ohne bekannten Auftraggeber")
	z2.setze("met_" + wer)
	m2.baue()
	await process_frame
	var b := finde(m2, "AufDerKarte") as Button
	pruefe(b != null, "„Auf der Karte“ fehlt bei %s" % wer)
	if b:
		b.pressed.emit()
		for i in 4: await process_frame
		pruefe(m2.reiter == "karte", "„Auf der Karte“ oeffnet nicht die Karte")
		var k := m2.inhalt.get_child(0) as Kartenreiter if m2.inhalt.get_child_count() > 0 else null
		pruefe(k != null and k.tipp_kasten != null, "Karte ohne Namen des Auftraggebers unten")
		if k and k.tipp_kasten:
			var t := PackedStringArray(k.tipp_kasten.find_children("*", "Label", true, false).map(func(x): return x.text))
			pruefe(" ".join(t).contains(Sprache.t(j["geber_name"])), "Name fehlt im Kasten: %s" % [t])
	print("HELDKARTE528 %d Fehler" % fehler)
	quit(1 if fehler else 0)
