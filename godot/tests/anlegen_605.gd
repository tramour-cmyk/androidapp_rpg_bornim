extends SceneTree
# 605 wiederholt (Chef 08.11., 15:57–15:59, t269.16/17: aus dem leeren Kopffeld die göttliche Kapuze gewählt: „nur Wegwerfen, kein
# Anlegen … Zurück fehlt“): der Weg des Chefs mit einem Stück wie seinem (göttliche Kapuze, viele Boni) je Klasse und Bildhöhe des
# Handys: Wechselschirm Kopf, Stück antippen; im Fenster müssen „Abbrechen“ und „Anlegen“ da, ganz im Bild und (wer tragen kann)
# anwählbar sein; ein Tipp auf Anlegen legt es an. Ohne Bild. Aufruf im Ordner godot: headless, -s res://tests/anlegen_605.gd

var fehler := 0
const UNTEN_PX := 118.0     # 551: runde Ecke unten am Gerät des Chefs; dort kein Knopf

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func warte(n := 3) -> void:
	for i in n: await process_frame

func finger(p: Vector2, an: bool) -> void:
	var f := root.get_final_transform()
	var t := InputEventScreenTouch.new()
	t.index = 0; t.position = f * p; t.pressed = an
	root.push_input(t)
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT; e.pressed = an; e.position = f * p; e.global_position = f * p
	e.button_mask = MOUSE_BUTTON_MASK_LEFT if an else 0
	root.push_input(e)

func tippe(p: Vector2) -> void:
	finger(p, true); await process_frame; finger(p, false)
	await warte(3)

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	# die Oberfläche ist 1080 breit (canvas_items), Handy 19,5:9 wie das des Chefs (headless bleibt die sichtbare Fläche so hoch); oben
	# der Rand unter der Kamera (Rand.oben, am Gerät die sichere Fläche, 399.4), unten die runde Ecke (551: 118 px am Gerät des Chefs)
	for groesse in [Vector2i(1080, 2340)]:
		root.size = groesse
		for oben in [0.0, 110.0, 160.0]:
			Rand.test_oben = oben
			for kl in ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]:
				for seed in [1, 2, 3]:
					await _fall(groesse, kl, seed, oben)
	print("ANLEGEN605 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)

func _fall(groesse: Vector2i, kl: String, seed: int, oben: float) -> void:
	var z := Zustand.new()
	var hw := Heldwerte.erschaffe("Thora", "HUMAN", kl, {}, z.neue_uid)
	var g := z.ausruestung_dazu(Beute.wuerfle(z.neue_uid(), "hood", 1, "DIVINE", KotlinZufall.new(seed)))
	var m := Menue.new(hw, z)
	root.add_child(m)
	m.reiter = "ausruestung"; m.baue()
	await warte(6)
	var vorher := m.get_child_count()
	m.tippe_fach("HEAD")
	await warte(4)
	var zeile := _flaeche(m, "")
	var name_ := Beute.name(g)
	if zeile == null:
		pruefe(false, "%s %s %d: keine Zeile im Wechselschirm" % [groesse, kl, seed])
		m.queue_free(); await warte(); return
	await tippe(zeile.get_global_rect().get_center())
	var bild := Rect2(Vector2.ZERO, Vector2(groesse) - Vector2(0, UNTEN_PX))
	var an := _flaeche(m, "haupt")
	var ab := _flaeche(m, "neben", true)
	var texte: Array = []
	for k in m.get_child(m.get_child_count() - 1).find_children("*", "PanelContainer", true, false):
		if k.has_meta("knopf") and (k as Control).is_visible_in_tree():
			var l = k.find_child("Text", true, false)
			texte.append("%s %s %s" % [k.get_meta("knopf"), l.text if l else "?", str(k.get_global_rect().position.y as int)])
	var ok_an: bool = an != null and bild.encloses(an.get_global_rect())
	var ok_ab: bool = ab != null and bild.encloses(ab.get_global_rect())
	pruefe(ok_an and ok_ab, "%s oben %d %s %d %s (tragbar %s): Anlegen %s, Abbrechen %s; Knöpfe %s" % [groesse, int(oben), kl, seed, name_, hw.kann_tragen(g),
		"im Bild" if ok_an else ("außerhalb (y %d)" % int(an.get_global_rect().position.y) if an else "fehlt"),
		"im Bild" if ok_ab else ("außerhalb" if ab else "fehlt"), str(texte)])
	if ok_an and hw.kann_tragen(g):
		await tippe(an.get_global_rect().get_center())
		pruefe(hw.ding("HEAD") != null and int(hw.ding("HEAD")["uid"]) == int(g["uid"]), "  ein Tipp auf Anlegen legt die Kapuze an")
	m.queue_free()
	await warte()

func _flaeche(m: Node, art: String, links := false) -> Control:
	var s := m.get_child(m.get_child_count() - 1)
	for k in s.find_children("*", "PanelContainer", true, false):
		if not (k as Control).is_visible_in_tree(): continue
		if art == "" and not k.has_meta("knopf") and k.mouse_filter != Control.MOUSE_FILTER_IGNORE and k.get_child_count() > 0 and k.get_child(0) is MarginContainer: return k
		if art != "" and String(k.get_meta("knopf", "")) == art and bool(k.get_meta("links", false)) == links: return k
	return null
