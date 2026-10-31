extends SceneTree
# 416.1 (Chef 31.10., Build 143: „Tasten reagieren schlecht … Bartform, Kopfform, Farbe … auch in anderen Bereichen“): ohne Bild;
# tippt wie ein Finger (Beruehren, bis 20 Pixel Zittern, Loslassen) auf Knoepfe in der rollenden Mitte der Erschaffung und auf ein
# Farbfeld (Mitte des Felds, nicht der Name darunter); jeder Tipp muss wirken (Befund: das Farbfeld schluckte ihn). Dazu je Menue:
# keine Tippflaeche mit einem Kind, das das Tippen schluckt. Aufruf: im Ordner godot mit
# -s res://tests/tasten_4161.gd -> „TASTEN n Fehler“

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

# wie auf dem Geraet: der Beruehrung folgt die nachgebildete Maus (emulate_mouse_from_touch), beides an den Schirm; p und zittern in
# Leinwandpunkten (auf dem A56 etwa Bildpunkte), push_input will Fensterpunkte (ohne Fenster ist es 64 x 64)
func tipp(p: Vector2, zittern: Vector2) -> void:
	var f := root.get_final_transform()
	var h := InputEventMouseMotion.new(); h.position = f * p; h.global_position = f * p   # der Zeiger steht schon dort
	root.push_input(h)
	var a := InputEventScreenTouch.new(); a.index = 0; a.position = f * p; a.pressed = true
	root.push_input(a)
	var am := InputEventMouseButton.new(); am.button_index = MOUSE_BUTTON_LEFT; am.pressed = true; am.position = f * p; am.global_position = f * p
	am.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(am)
	await process_frame
	var q := p
	if zittern != Vector2.ZERO:
		for i in 3:
			var r := zittern / 3.0
			q += r
			var d := InputEventScreenDrag.new(); d.index = 0; d.position = f * q; d.relative = f.basis_xform(r)
			root.push_input(d)
			var dm := InputEventMouseMotion.new(); dm.position = f * q; dm.global_position = f * q; dm.relative = f.basis_xform(r)
			dm.button_mask = MOUSE_BUTTON_MASK_LEFT
			root.push_input(dm)
			await process_frame
	var b := InputEventScreenTouch.new(); b.index = 0; b.position = f * q; b.pressed = false
	root.push_input(b)
	var bm := InputEventMouseButton.new(); bm.button_index = MOUSE_BUTTON_LEFT; bm.pressed = false; bm.position = f * q; bm.global_position = f * q
	root.push_input(bm)
	for i in 3: await process_frame

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func schlucker(wurzel: Node, wo: String) -> void:
	var n := 0
	for c in wurzel.find_children("*", "Control", true, false) + [wurzel]:
		if (c as Control).get_signal_connection_list("gui_input").is_empty(): continue
		n += 1
		for k in (c as Control).find_children("*", "Control", true, false):
			var x := k as Control
			if x.mouse_filter != Control.MOUSE_FILTER_STOP or not x.is_visible_in_tree(): continue
			if x is BaseButton or x is LineEdit or x is TextEdit or x is Range or x is ScrollContainer or x.get_signal_connection_list("gui_input").size() > 0: continue
			pruefe(false, "%s: %s in %s schluckt das Tippen" % [wo, x.get_class(), c.get_class()])
	pruefe(true, "%s: %d Tippflaechen geprueft" % [wo, n])

func knopf_mit(c: Node, t: String) -> Button:
	for b in c.find_children("*", "Button", true, false):
		if (b as Button).text == t and (b as Button).is_visible_in_tree(): return b
	return null

func _lauf() -> void:
	print("Beruehrschirm %s (wie auf dem Geraet: true)" % DisplayServer.is_touchscreen_available())
	var probe := Button.new(); probe.position = Vector2(5, 5); probe.size = Vector2(80, 40)
	var gedrueckt := [0]
	probe.pressed.connect(func(): gedrueckt[0] += 1)
	root.add_child(probe)
	await process_frame
	await tipp(Vector2(40, 25), Vector2.ZERO)
	pruefe(gedrueckt[0] == 1, "Probeknopf ausserhalb jeder Rolle %d mal gedrueckt (Pruefstand)" % gedrueckt[0])
	probe.queue_free()
	var e := Erschaffung.new()
	root.add_child(e)
	for i in 5: await process_frame
	var d := Heldwerte.lade()
	var n := 0
	for z in [Vector2.ZERO, Vector2(3, 2), Vector2(0, 6), Vector2(0, 12), Vector2(8, 20)]:
		for k in ["CLERIC", "ROGUE", "FIGHTER"]:
			var t := Sprache.t(d["klassen"][k]["name"]).to_upper().replace("ß", "SS")
			var b := knopf_mit(e, t)
			if b == null: pruefe(false, "Knopf %s fehlt" % t); continue
			e.rolle.ensure_control_visible(b)
			await process_frame
			await tipp(b.get_global_rect().get_center(), z)
			pruefe(e.klasse == k, "Klasse %s, Zittern %s px -> %s" % [k, z, e.klasse])
			n += 1
	# Farbfeld: Mitte des Felds
	var liste := [{"rgb": "#d8b89a", "name": {"de": "Hell", "en": "Light"}}, {"rgb": "#a07050", "name": {"de": "Mittel", "en": "Medium"}}]
	var r: Control = e.toene("Haut", liste, "haut")
	root.add_child(r)
	r.position = Vector2(20, 20)
	r.size = Vector2(600, 0)
	for i in 3: await process_frame
	var felder := r.find_children("*", "Panel", true, false)
	pruefe(felder.size() == 2, "zwei Farbfelder (%d)" % felder.size())
	if felder.size() == 2:
		e.aussehen["haut"] = 0
		await tipp((felder[1] as Control).get_global_rect().get_center(), Vector2.ZERO)
		pruefe(int(e.aussehen.get("haut", -1)) == 1, "Farbfeld getippt -> haut %s" % e.aussehen.get("haut"))
	r.queue_free()
	e.queue_free()
	# ueberall (Chef: „auch in anderen Bereichen“): wer auf Tippen hoert (gui_input), darf kein Kind haben, das das Tippen selbst
	# schluckt (MOUSE_FILTER_STOP ohne eigene Bedienung: Panel, PanelContainer, ColorRect, Control); Menue Held, Tasche, Ausruestung
	Sprache.lade()
	var z := Zustand.new()
	z.gold = 37; z.dazu("potion", 2)
	var hw := Heldwerte.erschaffe("Mira", "HUMAN", "FIGHTER", {}, z.neue_uid)
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(42), z.neue_uid, 3, "RARE", "FIGHTER"))
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	schlucker(m, "Menue Held")
	m.tasche(); await process_frame
	schlucker(m, "Menue Tasche")
	m.ausruestung(); await process_frame
	schlucker(m, "Menue Ausruestung")
	m.queue_free()
	var e2 := Erschaffung.new()
	root.add_child(e2)
	await process_frame
	schlucker(e2, "Erschaffung")
	e2.queue_free()
	var sp := Spielstaende.new()
	root.add_child(sp)
	await process_frame
	schlucker(sp, "Spielstaende")
	print("TASTEN %d Fehler" % fehler)
	quit(1 if fehler else 0)
