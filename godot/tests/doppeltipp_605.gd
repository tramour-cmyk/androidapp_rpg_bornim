extends SceneTree
# 605 (Chef 07.11., zu 268.11: „Ausrüstung muss 2x ‚Anlegen‘ gedrückt werden, ebenso 2x bei ‚Wegwerfen‘ und ‚Zurück‘, prüfe am
# besten alle“) und 617 (268.1: Wischen über die Spielstaende laedt): ein Finger wie auf dem Geraet (Beruehrung und nachgebildete
# Maus, emulate_mouse_from_touch) auf jeder Flaeche, die Spielstaende.tippbar baut (alle Knoepfe der Schirme ohne Kasten, 557).
# Ein Tipp loest genau einmal aus, ein Wisch nie; dazu der Weg des Chefs: Ausruestung, leeres Kopffeld, Zurueck -> wieder die
# Uebersicht, nicht ein zweiter Wechselschirm. Ohne Bild. Aufruf im Ordner godot: headless, -s res://tests/doppeltipp_605.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func warte(n := 3) -> void:
	for i in n: await process_frame

func finger(p: Vector2, an: bool) -> void:   # wie wischen_571: Beruehrung und dazu die nachgebildete Maus
	var f := root.get_final_transform()
	if an:
		var h := InputEventMouseMotion.new(); h.position = f * p; h.global_position = f * p
		root.push_input(h)
	var t := InputEventScreenTouch.new()
	t.index = 0; t.position = f * p; t.pressed = an
	root.push_input(t)
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT; e.pressed = an; e.position = f * p; e.global_position = f * p
	e.button_mask = MOUSE_BUTTON_MASK_LEFT if an else 0
	root.push_input(e)

func zug(p: Vector2, d: Vector2) -> void:
	var f := root.get_final_transform()
	var t := InputEventScreenDrag.new()
	t.index = 0; t.position = f * p; t.relative = f.basis_xform(d)
	root.push_input(t)
	var e := InputEventMouseMotion.new()
	e.position = f * p; e.global_position = f * p; e.relative = f.basis_xform(d); e.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(e)

func tippe(p: Vector2) -> void:
	finger(p, true); await process_frame; finger(p, false)
	await warte(3)

func mitte(c: Control) -> Vector2: return c.get_global_rect().get_center()

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	# 1. eine Flaeche allein
	var zahl := [0]
	var leer := Control.new()
	leer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(leer)
	var inhalt := Control.new()
	inhalt.custom_minimum_size = Vector2(600, 400)
	inhalt.mouse_filter = Control.MOUSE_FILTER_IGNORE   # wie jeder Inhalt einer Flaeche
	var p := Spielstaende.tippbar(inhalt, func(): zahl[0] += 1)
	p.position = Vector2(200, 600)
	leer.add_child(p)
	await warte()
	await tippe(mitte(p))
	pruefe(zahl[0] == 1, "ein Tipp loest einmal aus (%d)" % zahl[0])
	zahl[0] = 0
	var a := mitte(p) + Vector2(0, -120)
	finger(a, true); await process_frame
	for i in 8:
		a += Vector2(0, 30); zug(a, Vector2(0, 30)); await process_frame
	finger(a, false); await warte()
	pruefe(zahl[0] == 0, "ein Wisch ueber die Flaeche loest nichts aus (%d)" % zahl[0])
	leer.queue_free()
	await warte()
	# 2. der Weg des Chefs: Ausruestung, leeres Kopffeld, Zurueck
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Zwerg", "Wachsoldat", z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	m.reiter = "ausruestung"; m.baue()
	await warte(6)
	var vorher := m.get_child_count()
	m.waehle("HEAD")
	await warte(4)
	var schirme := m.get_child_count() - vorher
	pruefe(schirme == 1, "Wechselschirm Kopf offen (%d)" % schirme)
	var zurueck: Control = null
	for k in m.get_child(m.get_child_count() - 1).find_children("*", "PanelContainer", true, false):
		if k.get_meta("links", false) and String(k.get_meta("knopf", "")) == "neben": zurueck = k
	pruefe(zurueck != null, "Knopf Zurueck gefunden")
	if zurueck:
		await tippe(mitte(zurueck))
		await warte(3)
		pruefe(m.get_child_count() == vorher, "nach einem Tipp auf Zurueck wieder die Uebersicht (%d Schirme offen)" % (m.get_child_count() - vorher))
	# 3. leeres Kopffeld, einen Helm waehlen, Abbrechen (Chef: „zurück aber dann nicht wieder in der Ausrüstungsübersicht, sondern im
	# Detailfenster“), wieder waehlen, einmal Anlegen
	var helm := ""
	for id in Beute.grundformen():
		if String(Beute.grundform(id)["slot"]) == "HEAD": helm = id; break
	var g := z.ausruestung_dazu({"uid": 0, "base": helm, "rarity": "UNCOMMON", "ilvl": 1, "plus": 0, "rolls": [], "unique": null, "name_seed": 0})
	m.baue(); await warte(4)
	m.waehle("HEAD"); await warte(4)
	var f := _flaeche(m, "")
	pruefe(f != null, "Helm %s in der Wechselliste" % helm)
	if f == null: quit(1); return
	await tippe(mitte(f))
	pruefe(m.get_child_count() == vorher + 1, "Helm angetippt: genau ein Fenster offen (%d)" % (m.get_child_count() - vorher))
	f = _flaeche(m, "neben", true)
	if f: await tippe(mitte(f))
	pruefe(m.get_child_count() - vorher == 1 and _flaeche(m, "") != null, "Abbrechen: zurueck in der Wechselliste, ein Schirm (%d)" % (m.get_child_count() - vorher))
	f = _flaeche(m, "")
	if f: await tippe(mitte(f))
	f = _flaeche(m, "haupt")
	if f: await tippe(mitte(f))
	pruefe(hw.ding("HEAD") != null and int(hw.ding("HEAD")["uid"]) == int(g["uid"]), "ein Tipp auf Anlegen legt den Helm an")
	pruefe(m.get_child_count() == vorher, "nach Anlegen kein Fenster mehr offen (%d)" % (m.get_child_count() - vorher))
	m.queue_free(); await warte()
	# 4. 606 (Chef 07.11., t268: „Kauf Met in Schänke – Preis laut Liste 2 Gold, abgezogen vom Vermögen werden 4 Gold“): ein Tipp auf
	# „Met“ an der Theke waehlt einmal (Rastfeld, eigene Flaeche wie tippbar)
	var rf := Rastfeld.neu("B", "Theke", "", [{"id": "met", "name": "Met", "dauer": "2 Gold", "tut": "", "an": true, "zeichen": "MUG"}], "Weitergehen")
	root.add_child(rf)
	await warte(4)
	var met := [0]
	rf.gewaehlt.connect(func(id): if id == "met": met[0] += 1)
	var mf: Control = null
	for k in rf.find_children("*", "PanelContainer", true, false):
		if String(k.get_meta("id", "")) == "met": mf = k
	pruefe(mf != null, "Theke: Wahl Met gefunden")
	if mf: await tippe(mitte(mf))
	pruefe(met[0] == 1, "ein Tipp auf Met trinkt einmal (%d)" % met[0])
	print("DOPPELTIPP605 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)

# die oberste Flaeche im zuletzt geoeffneten Schirm: [art] "" eine Zeile (kein Knopf), sonst der Knopf dieser Art
func _flaeche(m: Node, art: String, links := false) -> Control:
	var s := m.get_child(m.get_child_count() - 1)
	for k in s.find_children("*", "PanelContainer", true, false):
		if not (k as Control).is_visible_in_tree(): continue
		if art == "" and not k.has_meta("knopf") and k.mouse_filter != Control.MOUSE_FILTER_IGNORE and k.get_child_count() > 0 and k.get_child(0) is MarginContainer: return k
		if art != "" and String(k.get_meta("knopf", "")) == art and bool(k.get_meta("links", false)) == links: return k
	return null
