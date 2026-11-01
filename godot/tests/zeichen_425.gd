extends SceneTree
# 425 ohne Bild: Menue „System“ als Zeichen wie alt (MenuSigns.kt). Wie ein Finger (Beruehren, Zittern, Loslassen; wie tasten_4161):
# kurz tippen auf ein Zeichen in der rollenden Mitte wirkt einmal; 0,6 s halten oeffnet die Erklaerung und wirkt nicht; halten und
# dabei 40 Punkte ziehen (Rollen) tut nichts; Tippen auf das Fenster schliesst es; Android-Zurück schliesst erst das Fenster.
# Aufruf: im Ordner godot mit -s res://tests/zeichen_425.gd -> „ZEICHEN n Fehler“

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func finger(p: Vector2, halten: float, ziehen: Vector2) -> void:
	var f := root.get_final_transform()
	var h := InputEventMouseMotion.new(); h.position = f * p; h.global_position = f * p
	root.push_input(h)
	var a := InputEventScreenTouch.new(); a.index = 0; a.position = f * p; a.pressed = true
	root.push_input(a)
	var am := InputEventMouseButton.new(); am.button_index = MOUSE_BUTTON_LEFT; am.pressed = true; am.position = f * p; am.global_position = f * p
	am.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(am)
	await process_frame
	var q := p
	if ziehen != Vector2.ZERO:
		for i in 4:
			var r := ziehen / 4.0
			q += r
			var d := InputEventScreenDrag.new(); d.index = 0; d.position = f * q; d.relative = f.basis_xform(r)
			root.push_input(d)
			var dm := InputEventMouseMotion.new(); dm.position = f * q; dm.global_position = f * q; dm.relative = f.basis_xform(r)
			dm.button_mask = MOUSE_BUTTON_MASK_LEFT
			root.push_input(dm)
			await process_frame
	if halten > 0.0: await create_timer(halten).timeout
	var b := InputEventScreenTouch.new(); b.index = 0; b.position = f * q; b.pressed = false
	root.push_input(b)
	var bm := InputEventMouseButton.new(); bm.button_index = MOUSE_BUTTON_LEFT; bm.pressed = false; bm.position = f * q; bm.global_position = f * q
	root.push_input(bm)
	for i in 3: await process_frame

func zeichen(m: Menue, w: String) -> Zeichenknopf:
	await process_frame
	for b in m.inhalt.find_children("*", "Zeichenknopf", true, false):
		if (b as Zeichenknopf).wort == w:
			m.rolle.ensure_control_visible(b)
			await process_frame; await process_frame
			return b
	return null

func mitte(c: Control) -> Vector2:
	return c.get_global_rect().get_center()

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	Bedienung.lade()
	var z := Zustand.new()
	var hw := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	m.reiter = "system"; m.baue()
	for i in 4: await process_frame
	var blut := Bedienung.blut
	var zk: Zeichenknopf = await zeichen(m, "Blut")
	pruefe(zk != null, "Zeichen Blut da")
	if zk == null: return _ende()
	await finger(mitte(zk.kreis), 0.0, Vector2(0, 8))
	pruefe(Bedienung.blut == (blut + 1) % 3, "kurz tippen (8 Punkte Zittern) wechselt Blut %d -> %d" % [blut, Bedienung.blut])
	pruefe(Zeichenknopf.offen == "", "kurz tippen erklaert nicht")
	blut = Bedienung.blut
	zk = await zeichen(m, "Blut")
	await finger(mitte(zk.kreis), 0.6, Vector2.ZERO)
	pruefe(Bedienung.blut == blut, "halten wechselt nicht")
	pruefe(Zeichenknopf.offen == "Blut" and is_instance_valid(m.erklaer_fenster), "halten oeffnet die Erklaerung")
	if is_instance_valid(m.erklaer_fenster):
		var r: Rect2 = m.erklaer_fenster.get_global_rect()
		pruefe(r.end.y <= m.get_global_rect().end.y - 60 * Menue.DP and r.size.y > 60 * Menue.DP, "Fenster ueber „Schließen“, %.0f hoch" % r.size.y)
		pruefe(Zurueck.taste(self), "Zurück nimmt das Fenster")
		await process_frame
		pruefe(Zeichenknopf.offen == "" and is_instance_valid(m), "Zurück schliesst erst das Fenster, das Menue bleibt")
	zk = await zeichen(m, "Tempo")
	await finger(mitte(zk.kreis), 0.6, Vector2.ZERO)
	pruefe(Zeichenknopf.offen == "Tempo", "zweites Halten oeffnet Tempo")
	if is_instance_valid(m.erklaer_fenster):
		var innen: Control = m.erklaer_fenster.get_child(1).get_child(0)
		await finger(mitte(innen), 0.0, Vector2.ZERO)
		pruefe(Zeichenknopf.offen == "" and not is_instance_valid(m.erklaer_fenster) or m.erklaer_fenster == null, "Tippen auf das Fenster schliesst es")
	var tempo := Bedienung.tempo
	zk = await zeichen(m, "Tempo")
	await finger(mitte(zk.kreis), 0.6, Vector2(0, 40))
	pruefe(Bedienung.tempo == tempo and Zeichenknopf.offen == "", "halten und ziehen (Rollen) tut nichts")
	# Wert unter dem Zeichen, nie ein Satz
	var lang_ := 0
	for b in m.inhalt.find_children("*", "Zeichenknopf", true, false):
		for l in (b as Node).find_children("*", "Label", true, false): lang_ = maxi(lang_, (l as Label).text.length())
	pruefe(lang_ <= 12, "laengste Beschriftung unter einem Zeichen %d Zeichen" % lang_)
	_ende()

func _ende() -> void:
	print("ZEICHEN %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
