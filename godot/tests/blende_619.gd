extends SceneTree
# 619 (Chef 07.11., 268.18: „Aktionsknopf drückt die Blende gleich mit weg“): ein Knopf, dessen Druck eine Blende ueber den ganzen
# Schirm legt (wie Aktionsknopf -> Kampf -> Kampfblende); der Finger wie auf dem Geraet (Beruehrung und nachgebildete Maus). Was von
# diesem einen Tipp kommt die Blende noch an? Ohne Bild. Aufruf im Ordner godot: headless, -s res://tests/blende_619.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func warte(n := 3) -> void:
	for i in n: await process_frame

func finger(p: Vector2, an: bool, touch_zuerst: bool) -> void:
	var f := root.get_final_transform()
	if an:
		var h := InputEventMouseMotion.new(); h.position = f * p; h.global_position = f * p
		root.push_input(h)
	var t := InputEventScreenTouch.new()
	t.index = 0; t.position = f * p; t.pressed = an
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT; e.pressed = an; e.position = f * p; e.global_position = f * p
	e.button_mask = MOUSE_BUTTON_MASK_LEFT if an else 0
	if touch_zuerst: root.push_input(t); root.push_input(e)
	else: root.push_input(e); root.push_input(t)

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	for reihe in [true, false]:
		for art in ["Ortsblende", "Kampfblende"]:
			var ui := Control.new()
			ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
			root.add_child(ui)
			var k := AktionsKnopf.new()
			k.position = Vector2(800, 2000)
			ui.add_child(k)
			var b := [null]
			k.pressed.connect(func():
				var o: Control = Ortsblende.new("FULL", "Flüsterwald", null) if art == "Ortsblende" else Kampfblende.new("NORMAL", {"id": "wolf", "rudel": true}, RandomNumberGenerator.new())
				ui.add_child(o)
				b[0] = o)
			await warte(3)
			var p := k.get_global_rect().get_center()
			finger(p, true, reihe); await process_frame; finger(p, false, reihe)
			await warte(3)
			pruefe(b[0] != null, "%s: Knopf hat ausgeloest (%s zuerst)" % [art, "Beruehrung" if reihe else "Maus"])
			if b[0] != null: pruefe(not bool(b[0].tippt), "%s: der Tipp, der sie oeffnete, beendet sie nicht (%s zuerst)" % [art, "Beruehrung" if reihe else "Maus"])
			# 619: kommt die Blende schon beim Druck (Finger noch unten), beendet das Loslassen sie nicht; ein ganzer Tipp danach schon
			if b[0] != null: b[0].queue_free()
			b[0] = null
			k.button_down.connect(func():
				if b[0] != null: return
				var o: Control = Ortsblende.new("FULL", "Flüsterwald", null) if art == "Ortsblende" else Kampfblende.new("NORMAL", {"id": "wolf", "rudel": true}, RandomNumberGenerator.new())
				ui.add_child(o)
				b[0] = o)
			await warte(2)
			finger(p, true, reihe); await process_frame; await process_frame; finger(p, false, reihe)
			await warte(3)
			pruefe(b[0] != null and not bool(b[0].tippt), "%s: kommt sie beim Druck, beendet das Loslassen sie nicht (%s zuerst)" % [art, "Beruehrung" if reihe else "Maus"])
			if b[0] != null:
				finger(p, true, reihe); await process_frame; finger(p, false, reihe)
				await warte(2)
				pruefe(bool(b[0].tippt), "%s: ein ganzer Tipp auf ihr beendet sie (%s zuerst)" % [art, "Beruehrung" if reihe else "Maus"])
			ui.queue_free()
			await warte()
	print("BLENDE619 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
