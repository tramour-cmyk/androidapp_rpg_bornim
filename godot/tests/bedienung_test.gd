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
	pruefe("Wischen rechts", Vector2(ui.aktion_knopf.offset_left, ui.aktion_knopf.offset_top).is_equal_approx(Vector2(-98, -98) * dp), true)   # vom Anker aus (t139)
	pruefe("Ring Normal", ui.JOY, 94.0 * dp)
	# Linkshaender: Knopf und Schild links
	Bedienung.links = true; Bedienung.ring = 0; Bedienung.lauf_taste = true
	ui.richte_ein()
	pruefe("links Knopf", [ui.aktion_knopf.anchor_left, Vector2(ui.aktion_knopf.offset_left, ui.aktion_knopf.offset_top).is_equal_approx(Vector2(22, -98) * dp)], [0.0, true])
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
	# Laden (416.3: ladenschirm.gd wie ShopScreen.kt): Seltenes verkaufen fragt noch einmal; „Abbrechen“ laesst es, „Verkaufen“ verkauft
	Bedienung.rueckfragen = true
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(7), z.neue_uid, 3, "RARE", "WIZARD"))
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(8), z.neue_uid, 3, "COMMON", "WIZARD"))
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(9), z.neue_uid, 3, "COMMON", "WIZARD"))
	var ls := LadenSchirm.new(hw, z, Laden.new(["potion"], false))
	root.add_child(ls)
	await process_frame
	pruefe("Laden ganzer Schirm", ls.get_global_rect().size.y >= root.get_visible_rect().size.y * 0.9, true)
	for sw in ["verkaufen", "kaufen"]:
		ls.seite = sw; ls.baue(); await process_frame
	# Kaufen: ohne Gold matt; mit Gold nach dem Kasten gekauft
	z.gold = 0
	var ware: Array = Laden.ware(z, hw)
	if ware.is_empty(): fehler += 1; print("FALSCH keine Ware")
	else:
		ls.stueck(ware[0], true)
		var ok: Array = kasten(ls).filter(func(b): return b.text.begins_with("KAUFEN"))
		pruefe("Kaufen matt ohne Gold", [ok.size(), ok[0].disabled if ok.size() > 0 else false], [1, true])
		await druecke(ls, "ABBRECHEN")
		z.gold = 100000
		var n0 := z.beutel.size()
		ls.stueck(ware[0], true)
		pruefe("noch nicht gekauft", z.beutel.size(), n0)
		await druecke(ls, "KAUFEN")
		pruefe("gekauft", z.beutel.size(), n0 + 1)
		z.beutel.remove_at(z.beutel.size() - 1)
	var g_selten: Dictionary = z.beutel.filter(func(x): return String(x["rarity"]) == "RARE")[0]
	# erst der Kasten mit dem Stueck (gearDialog), „Verkaufen“ darin fragt bei Seltenem noch einmal
	ls.stueck(g_selten, false)
	pruefe("Laden Kasten", [kasten(ls).size(), z.beutel.size()], [2, 3])
	await druecke(ls, "ABBRECHEN")
	pruefe("Kasten Abbrechen", [kasten(ls).size(), z.beutel.size()], [0, 3])
	ls.stueck(g_selten, false)
	await druecke(ls, "VERKAUFEN")
	pruefe("Laden fragt", [kopf_offen(ls), z.beutel.size()], ["WIRKLICH VERKAUFEN?" if Sprache.aktiv() == "de" else "REALLY SELL?", 3])
	await druecke(ls, "ABBRECHEN")
	pruefe("Abbrechen", [kasten(ls).size(), z.beutel.size()], [0, 3])
	ls.stueck(g_selten, false)
	await druecke(ls, "VERKAUFEN")
	await druecke(ls, "VERKAUFEN")
	pruefe("Verkaufen nach Frage", [z.beutel.size(), kasten(ls).size()], [2, 0])
	# Gewoehnliches: Kasten, dann sofort verkauft
	var gold0 := z.gold
	ls.stueck(z.beutel.filter(func(x): return String(x["rarity"]) == "COMMON")[0], false)
	await druecke(ls, "VERKAUFEN")
	pruefe("Gewöhnliches nach Kasten", [z.beutel.size(), z.gold > gold0, kasten(ls).size()], [1, true, 0])
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(10), z.neue_uid, 3, "COMMON", "WIZARD"))
	ls.alle_gewoehnlichen(z.beutel.filter(func(x): return String(x["rarity"]) == "COMMON"))
	pruefe("Gewöhnliche fragt", [kasten(ls).size() > 0, z.beutel.size()], [true, 2])
	await druecke(ls, "VERKAUFEN")
	pruefe("Gewöhnliche verkauft", z.beutel.size(), 0)
	z.dazu("wolf_pelt", 3)
	ls.menge("wolf_pelt", false, 1)
	await druecke(ls, "ALLE")
	await druecke(ls, "VERKAUFEN")
	pruefe("Alle Felle fragt", [kasten(ls).size() > 0, z.anzahl("wolf_pelt")], [true, 3])
	await druecke(ls, "VERKAUFEN")
	pruefe("Alle Felle verkauft", z.anzahl("wolf_pelt"), 0)
	z.dazu("wolf_pelt", 3)
	Bedienung.rueckfragen = false
	ls.menge("wolf_pelt", false, 1)
	await druecke(ls, "ALLE")
	await druecke(ls, "VERKAUFEN")
	pruefe("Rückfragen aus: sofort", [kasten(ls).size(), z.anzahl("wolf_pelt")], [0, 0])
	pruefe("Notiz unten", ls.notiz.text != "", true)
	ls.queue_free()
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

# 416.3: die Knoepfe des obersten offenen Kastens (Menue.dialog: Schleier 0,82) im Ladenschirm
func kasten(m: Node) -> Array:
	var r: Array = []
	for c in m.get_children():
		if c is ColorRect and not c.is_queued_for_deletion() and c.color.a > 0.5 and c.color.a < 0.9:
			r = c.find_children("*", "Button", true, false)
	return r

func kopf_offen(m: Node) -> String:
	for c in m.get_children():
		if c is ColorRect and not c.is_queued_for_deletion() and c.color.a > 0.5 and c.color.a < 0.9:
			var l: Array = c.find_children("*", "Label", true, false)
			if not l.is_empty(): return (l[0] as Label).text
	return ""

func druecke(m: Node, anfang: String) -> void:
	var b: Array = kasten(m).filter(func(x): return x.text.begins_with(anfang) and not x.disabled)
	if b.is_empty():
		fehler += 1
		print("FALSCH kein Knopf %s in %s" % [anfang, kasten(m).map(func(x): return x.text)])
		return
	b[0].pressed.emit()
	await process_frame
