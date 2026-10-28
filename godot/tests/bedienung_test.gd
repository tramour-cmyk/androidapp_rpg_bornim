extends SceneTree
# 399.1 ohne Bild: Bedienung aus dem Menue System wie alt (MenuSigns.kt „Bedienung“, „Rückfragen“): Wischen und Klassisch
# (Steuerkreuz, Knoepfe in der Leiste, „Weiter“ im Gespraech), Aktionsknopf links, Joystick-Ring, Renntaste, Karte näher,
# Rückfragen beim Wegwerfen und im Laden, gespeichert. Aufruf: im Ordner godot mit -s res://tests/bedienung_test.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll:
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _initialize() -> void: _lauf.call_deferred()

func tipp(n: Control, p: Vector2, an: bool) -> void:
	var t := InputEventScreenTouch.new()
	t.position = p; t.pressed = an; t.index = 0
	n._gui_input(t)

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	Bedienung.lade()
	var vorher := {}
	for k in ["klassisch", "ring", "lauf_taste", "links", "karte_nah", "ruetteln", "rueckfragen"]: vorher[k] = Bedienung._wert(k)
	Bedienung.klassisch = false; Bedienung.ring = 1; Bedienung.lauf_taste = false; Bedienung.links = false
	Bedienung.karte_nah = false; Bedienung.ruetteln = false; Bedienung.rueckfragen = true
	var dp := AktionsKnopf.DP
	var ui := Steuerung.new()
	root.add_child(ui)
	await process_frame
	var js := []
	ui.joystick.connect(func(v): js.append(v))
	var lauf := []
	ui.laufen.connect(func(an): lauf.append(an))
	var tipps := []
	ui.tippen.connect(func(p): tipps.append(p))
	# Wischen: ohne Angebot kein Knopf, keine Leiste; Angebot rechts unten, 22 dp vom Rand
	pruefe("Wischen Leiste", ui.kreuz_leiste.visible, false)
	pruefe("Wischen ohne Angebot", [ui.aktion_knopf.visible, ui.lauf_knopf.visible], [false, false])
	ui.biete_an("ENTER", "Laden")
	pruefe("Wischen Angebot", [ui.aktion_knopf.visible, ui.ort_schild.visible, ui.aktion_knopf.anchor_left], [true, true, 1.0])
	pruefe("Wischen rechts", ui.aktion_knopf.position.is_equal_approx(Vector2(-98, -98) * dp), true)
	pruefe("Ring Normal", ui.JOY, 94.0 * dp)
	# Linkshaender: Knopf und Schild links
	Bedienung.links = true; Bedienung.ring = 0; Bedienung.lauf_taste = true
	ui.richte_ein()
	pruefe("links Knopf", [ui.aktion_knopf.anchor_left, ui.aktion_knopf.position.is_equal_approx(Vector2(22, -98) * dp)], [0.0, true])
	pruefe("links Schild", [ui.ort_schild.anchor_left, is_equal_approx(ui.ort_schild.offset_left, 106 * dp)], [0.0, true])
	pruefe("Ring Fein", ui.JOY, 76.0 * dp)
	pruefe("Renntaste da", ui.lauf_knopf.visible, true)
	ui.lauf_knopf.button_down.emit(); ui.lauf_knopf.button_up.emit()
	pruefe("Renntaste schaltet an", [lauf, ui.lauf_knopf.matt], [[true], false])
	ui.lauf_knopf.button_down.emit(); ui.lauf_knopf.button_up.emit()
	pruefe("Renntaste schaltet aus", lauf, [true, false])
	lauf.clear()
	# Klassisch: Leiste, Knopf immer (matt mit Funke), Renntaste solange gedrueckt, ein Finger auf der Welt tut nichts
	Bedienung.klassisch = true
	ui.richte_ein()
	ui.biete_an("")
	pruefe("Klassisch Leiste", ui.kreuz_leiste.visible, true)
	pruefe("Knoepfe ueber der Leiste", [ui.aktion_knopf.get_index() > ui.kreuz_leiste.get_index(), ui.lauf_knopf.get_index() > ui.kreuz_leiste.get_index(),
		ui.textfeld.get_index() > ui.kreuz_leiste.get_index(), ui.wahl_grund.get_index() > ui.kreuz_leiste.get_index()], [true, true, true, true])
	pruefe("Klassisch Knopf", [ui.aktion_knopf.visible, ui.aktion_knopf.matt, ui.aktion_knopf.zeichen, ui.ort_schild.visible], [true, true, "ACT", false])
	ui.biete_an("TALK")
	pruefe("Klassisch Angebot", [ui.aktion_knopf.matt, ui.aktion_knopf.zeichen], [false, "TALK"])
	pruefe("Klassisch Kreuz rechts bei links", ui.kreuz.anchor_left, 1.0)
	ui.lauf_knopf.button_down.emit()
	ui.lauf_knopf.button_up.emit()
	pruefe("Klassisch Rennen halten", lauf, [true, false])
	var w := InputEventScreenTouch.new()
	w.position = Vector2(300, 400); w.pressed = true; w.index = 0
	ui._unhandled_input(w)
	w = w.duplicate(); w.pressed = false
	ui._unhandled_input(w)
	pruefe("Klassisch kein Tippen", tipps.size(), 0)
	# Steuerkreuz: oben gedrueckt = Bildschirm oben, Mitte frei, Loslassen = still
	var g := ui.kreuz.size.x
	tipp(ui.kreuz, Vector2(g / 2, g * 0.1), true)
	tipp(ui.kreuz, Vector2(g / 2, g * 0.1), false)
	tipp(ui.kreuz, Vector2(g * 0.9, g / 2), true)
	pruefe("Kreuz", js, [Vector2(0, -1), Vector2.ZERO, Vector2(1, 0)])
	pruefe("Kreuz Mitte", ui.kreuz.dir_bei(Vector2(g / 2 + 2, g / 2 - 2)), Vector2.ZERO)
	tipp(ui.kreuz, Vector2(g * 0.9, g / 2), false)
	# im Gespraech zeigt der Knopf „Weiter“ und schaltet die Zeile weiter
	var gelesen := [0]
	ui.gelesen.connect(func(): gelesen[0] += 1)
	ui.sage([{"text": "Eins"}])
	pruefe("Klassisch Weiter", [ui.aktion_knopf.visible, ui.aktion_knopf.zeichen, ui.lauf_knopf.visible], [true, "NEXT", false])
	ui.aktion_knopf.pressed.emit()
	pruefe("Weiter schliesst", [ui.textfeld.visible, gelesen[0]], [false, 1])
	pruefe("Textfeld ueber der Leiste", ui.textfeld.offset_bottom < -(Steuerung.KREUZ + 28) * dp, true)
	# Karte näher: 5,6 statt 6,75 Kacheln quer
	var k := Kamera.new()
	root.add_child(k)
	Bedienung.karte_nah = true
	k.fern_neu()
	pruefe("Karte näher", is_equal_approx(k.zoom, Kamera.FERN * 5.6 / 6.75), true)
	Bedienung.karte_nah = false
	k.fern_neu()
	pruefe("Karte normal", is_equal_approx(k.zoom, Kamera.FERN), true)
	k.free()
	# Rückfragen aus: Wegwerfen ohne Frage
	var z := Zustand.new()
	var hw := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(42), z.neue_uid, 3, "RARE", "WIZARD"))
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.frage_wegwerfen(z.beutel[0])
	pruefe("Rückfrage an: fragt", z.beutel.size(), 1)
	Bedienung.rueckfragen = false
	m.frage_wegwerfen(z.beutel[0])
	pruefe("Rückfrage aus: weg", z.beutel.size(), 0)
	# Menue zeigt Bedienung; Antippen wechselt und speichert
	m.reiter = "system"; m.baue()
	await process_frame
	var aktion: Array = m.inhalt.find_children("*", "Button", true, false).filter(func(b): return b.text.begins_with("AKTION"))
	pruefe("Menue Aktion", aktion.size(), 1)
	if aktion.size() == 1:
		aktion[0].pressed.emit()
		pruefe("Menue Aktion wechselt", Bedienung.links, false)
		Bedienung.geladen = false
		Bedienung.links = true
		Bedienung.lade()
		pruefe("gespeichert", Bedienung.links, false)
	var steuer: Array = m.inhalt.find_children("*", "Button", true, false).filter(func(b): return b.text.begins_with("STEUERUNG"))
	pruefe("Menue Klassisch ohne Joystick", [steuer.size(), m.inhalt.find_children("*", "Button", true, false).filter(func(b): return b.text.begins_with("JOYSTICK")).size()], [1, 0])
	m.free()
	# Laden: Seltenes verkaufen fragt noch einmal; „Abbrechen“ laesst es, „Verkaufen“ verkauft
	Bedienung.rueckfragen = true
	var spiel = load("res://skripte/spiel.gd").new()
	spiel.ui = ui
	spiel.zustand = z
	spiel.werte = hw
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(7), z.neue_uid, 3, "RARE", "WIZARD"))
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(8), z.neue_uid, 3, "COMMON", "WIZARD"))
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(9), z.neue_uid, 3, "COMMON", "WIZARD"))
	spiel.laden = Laden.new(["potion"], false)
	# Kaufen: ohne Gold matt; mit Gold nach dem Kasten gekauft
	z.gold = 0
	var ware: Array = Laden.ware(z, hw)
	if ware.is_empty(): fehler += 1; print("FALSCH keine Ware")
	else:
		spiel._laden_wahl("ag:%d" % int(ware[0]["uid"]))
		var ok: Array = ui.wahl_box.get_children().filter(func(b): return b is Button and b.text.begins_with("Kaufen"))
		pruefe("Kaufen matt ohne Gold", [ok.size(), ok[0].disabled if ok.size() > 0 else false], [1, true])
		spiel._laden_wahl("")
		z.gold = 100000
		var n0 := z.beutel.size()
		spiel._laden_wahl("ag:%d" % int(ware[0]["uid"]))
		pruefe("noch nicht gekauft", z.beutel.size(), n0)
		spiel._laden_wahl("ok")
		pruefe("gekauft", z.beutel.size(), n0 + 1)
		z.beutel.remove_at(z.beutel.size() - 1)
	var i_selten := z.beutel.find(z.beutel.filter(func(x): return String(x["rarity"]) == "RARE")[0])
	# erst der Kasten mit dem Stueck (gearDialog), „Verkaufen“ darin fragt bei Seltenem noch einmal
	spiel._laden_wahl("vg:%d" % i_selten)
	pruefe("Laden Kasten", [spiel.laden_stueck, spiel.laden_frage, z.beutel.size()], ["vg:%d" % i_selten, "", 3])
	spiel._laden_wahl("")
	pruefe("Kasten Abbrechen", [spiel.laden_stueck, z.beutel.size(), spiel.laden != null], ["", 3, true])
	spiel._laden_wahl("vg:%d" % i_selten)
	spiel._laden_wahl("ok")
	pruefe("Laden fragt", [spiel.laden_frage, z.beutel.size()], ["vg:%d" % i_selten, 3])
	spiel._laden_wahl("")
	pruefe("Abbrechen", [spiel.laden_frage, z.beutel.size(), spiel.laden != null], ["", 3, true])
	spiel._laden_wahl("vg:%d" % i_selten)
	spiel._laden_wahl("ok")
	spiel._laden_wahl("ja")
	pruefe("Verkaufen nach Frage", [z.beutel.size(), spiel.laden_stueck, spiel.laden_frage], [2, "", ""])
	# Gewoehnliches: Kasten, dann sofort verkauft
	var i_gew := z.beutel.find(z.beutel.filter(func(x): return String(x["rarity"]) == "COMMON")[0])
	var gold0 := z.gold
	spiel._laden_wahl("vg:%d" % i_gew)
	spiel._laden_wahl("ok")
	pruefe("Gewöhnliches nach Kasten", [z.beutel.size(), z.gold > gold0, spiel.laden_frage], [1, true, ""])
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(10), z.neue_uid, 3, "COMMON", "WIZARD"))
	spiel._laden_wahl("alle")
	pruefe("Gewöhnliche fragt", [spiel.laden_frage, z.beutel.size()], ["alle", 2])
	spiel._laden_wahl("ja")
	pruefe("Gewöhnliche verkauft", z.beutel.size(), 0)
	z.dazu("wolf_pelt", 3)
	spiel._laden_wahl("verk:wolf_pelt")
	spiel._laden_wahl("m:alle")
	spiel._laden_wahl("m:ok")
	pruefe("Alle Felle fragt", [spiel.laden_frage, z.anzahl("wolf_pelt")], ["m:ok", 3])
	spiel._laden_wahl("ja")
	pruefe("Alle Felle verkauft", z.anzahl("wolf_pelt"), 0)
	z.dazu("wolf_pelt", 3)
	Bedienung.rueckfragen = false
	spiel._laden_wahl("verk:wolf_pelt")
	spiel._laden_wahl("m:alle")
	spiel._laden_wahl("m:ok")
	pruefe("Rückfragen aus: sofort", [spiel.laden_frage, z.anzahl("wolf_pelt")], ["", 0])
	spiel.free()
	for kk in vorher:
		match kk:
			"klassisch": Bedienung.klassisch = vorher[kk]
			"ring": Bedienung.ring = vorher[kk]
			"lauf_taste": Bedienung.lauf_taste = vorher[kk]
			"links": Bedienung.links = vorher[kk]
			"karte_nah": Bedienung.karte_nah = vorher[kk]
			"ruetteln": Bedienung.ruetteln = vorher[kk]
			"rueckfragen": Bedienung.rueckfragen = vorher[kk]
	Bedienung.speichere()
	print("BEDIENUNG %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
