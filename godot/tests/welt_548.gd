extends SceneTree
# 545, 548 (Chef 04.11., 00:01 und 00:03, Build 249) ohne Bild, im ganzen Spiel (spiel.tscn mit den Daten des Baus): Testmodus an;
# erst der MARS-Probekampf aus dem Reiter Test, dort der Haken (Finger und nachgebildete Maus wie am Handy); dann ein Kampf mit den
# Ratten der Karte ohne jede Eingabe. Richtig: der Haken gewinnt den Probekampf; die Ratten fallen nicht von selbst.
# Dazu je Wechsel der Höhe des Bedienkastens eine Zeile (springen Haken und Kreuz mitten im Kampf?) und ein Tippen auf den Haken
# unter der Blende vor dem Kampf (darf nichts tun). Befund 04.11., 01:1x (Jerry, Daten aus Build 249): Haken gewinnt, Ratten warten,
# der Kasten wechselt seine Höhe nur zu Beginn und am Ende; 545 und 548 am Rechner nicht nachgestellt.
# Aufruf: im Ordner godot mit -s res://tests/welt_548.gd; braucht godot/daten und kampf/daten wie im Bau, etwa aus dem APK des Baus
# (Artefakt bornim-godot-apk, unzip 'assets/*', assets/daten und assets/kampf/daten nach godot/ kopieren; Kaufmodelle bleiben
# verschlüsselt, der Held fehlt dann im Bild)

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _touch(p: Vector2, down: bool) -> void:
	var t := InputEventScreenTouch.new()
	t.position = p
	t.pressed = down
	root.push_input(t, true)
	var m := InputEventMouseButton.new()
	m.device = InputEvent.DEVICE_ID_EMULATION
	m.position = p
	m.global_position = p
	m.button_index = MOUSE_BUTTON_LEFT
	m.pressed = down
	root.push_input(m, true)

var ueber := {}
## Liegt der Haken (oder das Kreuz) unter dem Bedienkasten? Zählt Bilder je Lage des Kastens
func _wache(k) -> void:
	if k == null or not is_instance_valid(k) or k.ui == null: return
	var p: Rect2 = k.ui.panel.get_global_rect()
	if int(p.position.y) != int(vorher.position.y):
		var bl: Array = k.find_children("*", "Control", true, false).filter(func(c): return c.get_script() and String(c.get_script().resource_path).ends_with("kampfblende.gd") and c.is_visible_in_tree() and c.mouse_filter == Control.MOUSE_FILTER_STOP)
		print("  Kasten oben %d → %d, Haken %s, Blende %s, busy %s, Zug %s" % [int(vorher.position.y), int(p.position.y), k.ui.win_rect, not bl.is_empty(), k.busy, k.mars.current().id if k.mars.outcome == "ONGOING" else "-"])
	for r in [k.ui.win_rect, k.ui.lose_rect]:
		if r.size.x > 0 and vorher.size.x > 0 and vorher.intersects(r):
			if sprung == Vector2.ZERO and k.mars.outcome == "ONGOING": sprung = r.get_center()
			var key := "Haken/Kreuz %s lag im Bild davor unter dem Kasten (oben %d, jetzt %d)" % [r, int(vorher.position.y), int(p.position.y)]
			ueber[key] = int(ueber.get(key, 0)) + 1
	vorher = p
	if k.ui.ring_target != "" and k.figures.has(k.ui.ring_target) and not ringe.has(k.get_instance_id()):
		ringe[k.get_instance_id()] = true
		var fig = k.figures[k.ui.ring_target]
		var h: float = k.ui._tall(fig)
		var c2: Vector2 = k.ui._foot(fig) - Vector2(0, h * 0.45)
		print("  Ring um %s bei %s, Halbmesser %d; Haken zuletzt %s, Würfel %s" % [k.ui.ring_target, c2, int(h * 0.55), letzter_haken, k.ui.dice_rect])
	if k.ui.win_rect.size.x > 0: letzter_haken = k.ui.win_rect
var vorher := Rect2()
var ringe := {}
var letzter_haken := Rect2()
var sprung := Vector2.ZERO     # wo Haken oder Kreuz eben auftauchten, wo vorher der Kasten war: dort tippt der Finger

func _ruhig(k) -> bool:
	return not k.busy and not k.playing and k.beats.is_empty() and not k.ring_open

func _bericht(k) -> String:
	var z: Array = k.ui.lines.slice(maxi(0, k.ui.lines.size() - 6))
	return " | ".join(z)

func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))     # Hochformat wie am Handy
	root.size = Vector2i(1080, 2340)
	Testmodus.lade()
	Testmodus.an = true
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	process_frame.connect(func(): _wache(spiel.kampf))
	for i in 10: await process_frame
	print("Karte ", spiel.karte.id, " Fenster ", root.get_visible_rect().size)
	# 1) Probekampf, Haken
	spiel.test_tat("probe", ["WOLVES", "FIGHTER", 3])
	var t0 := Time.get_ticks_msec()
	while spiel.kampf == null and Time.get_ticks_msec() - t0 < 15000: await process_frame
	var k = spiel.kampf
	if k == null:
		print("FEHLER kein Probekampf"); quit(1); return
	t0 = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 40000 and not (_ruhig(k) and k.ui.win_rect.size.x > 0 and k.mars.current().side == "PARTY"):
		await process_frame
	await create_timer(0.6).timeout     # Haken und Kreuz gelten erst, wenn sie still stehen
	var r: Rect2 = k.ui.win_rect
	var c: Vector2 = k.ui.overlay.get_global_transform_with_canvas() * r.get_center()
	var mm := InputEventMouseMotion.new(); mm.position = c; mm.global_position = c; root.push_input(mm, true)
	await process_frame
	var unter = root.gui_get_hovered_control()
	print("Probe: Haken bei ", r, " Mitte ", c, " darüber ", unter, " ", unter.get_path() if unter else "")
	if unter:
		var n = unter
		while n != null:
			var info := "%s %s" % [n.name, n.get_class()]
			if n is CanvasItem: info += " sichtbar %s" % n.is_visible_in_tree()
			if n is Control: info += " rect %s filter %d" % [n.get_global_rect(), n.mouse_filter]
			if n is CanvasLayer: info += " layer %d sichtbar %s" % [n.layer, n.visible]
			if n.get_script(): info += " skript %s" % n.get_script().resource_path
			print("  ", info)
			n = n.get_parent()
		print("  Kampf-UI-Ebene: ", k.ui.get_parent().get_class(), " ", k.ui.layer if k.ui is CanvasLayer else "")
	_touch(c, true); await process_frame; _touch(c, false)
	t0 = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 15000 and k.mars.outcome == "ONGOING": await process_frame
	print("Probe nach Haken: ", k.mars.outcome, " end_asked ", k.end_asked, " | ", _bericht(k))
	if k.mars.outcome != "WON": fehler += 1; print("FEHLER 545 Haken ohne Wirkung")
	while Time.get_ticks_msec() - t0 < 20000 and not _ruhig(k): await process_frame
	for i in 60: await process_frame
	k.finish()
	t0 = Time.get_ticks_msec()
	# 1025: der Kampf ist erst zu Ende, wenn auch Lohn, Stufe und Blende durch sind (spiel.gd kampf_laeuft); bis dahin beginnt kein zweiter
	while (spiel.kampf != null or spiel.kampf_laeuft or not spiel.visible) and Time.get_ticks_msec() - t0 < 25000: await process_frame
	for i in 30: await process_frame
	# 2) Ratten der Karte, ohne Eingabe
	for er in ["NORMAL", "AMBUSHED"]:
		spiel.im_kampf = false
		spiel._kampf_auf_karte("giant_rat", er, null)
		t0 = Time.get_ticks_msec()
		while spiel.kampf == null and Time.get_ticks_msec() - t0 < 15000: await process_frame
		k = spiel.kampf
		if k == null:
			print("FEHLER kein Rattenkampf"); fehler += 1; continue
		var ruhe := 0
		t0 = Time.get_ticks_msec()
		var aus := "hängt"
		sprung = Vector2.ZERO
		var getippt := false
		while Time.get_ticks_msec() - t0 < 45000:
			await process_frame
			if sprung != Vector2.ZERO and not getippt:
				getippt = true     # der Finger wollte auf die oberste Knopfreihe des Kastens, der eben kürzer wurde
				var mm2 := InputEventMouseMotion.new(); mm2.position = sprung; mm2.global_position = sprung; root.push_input(mm2, true)
				var u3 = root.gui_get_hovered_control()
				print("  vor dem Tippen: Haken %s, busy %s, Ring %s, Kasten %s, darunter %s" % [k.ui.win_rect, k.busy, k.ring_open, k.ui.panel.get_global_rect(), ("%s %s Skript %s Filter %d Rect %s sichtbar %s Kinder %d" % [u3.get_path(), u3.get_class(), u3.get_script().resource_path if u3.get_script() else "-", u3.mouse_filter, u3.get_global_rect(), u3.is_visible_in_tree(), u3.get_child_count()]) if u3 else ""])
				_touch(sprung, true); await process_frame; _touch(sprung, false)
				print("  nach dem Tippen: end_asked %s, Ausgang %s" % [k.end_asked, k.mars.outcome])
				print("Ratten %s: unter der Blende auf den Haken getippt, %s" % [er, sprung])
			if k.mars.outcome != "ONGOING":
				aus = "%s OHNE EINGABE" % k.mars.outcome
				break
			if _ruhig(k) and k.mars.current().side == "PARTY":
				ruhe += 1
				if ruhe > 120:
					aus = "wartet auf den Spieler"
					break
			else:
				ruhe = 0
		print("Ratten %s: %s, Held %d TP | %s" % [er, aus, k.mars.lead().hp, _bericht(k)])
		if aus.contains("OHNE EINGABE") or k.end_asked != null: fehler += 1; print("FEHLER 548: Sieg ohne Absicht")
		if k.mars.outcome == "ONGOING": k.test_end(true)
		t0 = Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 20000 and not (_ruhig(k) and k.mars.outcome != "ONGOING"): await process_frame
		for i in 60: await process_frame
		k.finish()
		t0 = Time.get_ticks_msec()
		while (spiel.kampf != null or spiel.kampf_laeuft or not spiel.visible) and Time.get_ticks_msec() - t0 < 25000: await process_frame
		for i in 30: await process_frame
	print("WELT_548 %d Fehler" % fehler)
	quit(1 if fehler else 0)
