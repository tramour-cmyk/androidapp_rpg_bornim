extends SceneTree
# 425 Befunde des Prüfers zum Testmenü (01.11.), ohne Bild gemessen: nichts ragt in das Zeichen darüber oder darunter (Bildrate und
# Standort oben abgeschnitten), kein Knopftext breiter als sein Knopf („Wolf mit Jungwölfen“), die Stufe nur einmal, Seltenheit
# „Sehr selten“ (nicht „Sehr Selten“). Braucht godot/daten wie im Bau. Aufruf: im Ordner godot,
# --headless -s res://tests/testmenue_mass_425.gd --resolution 1080x2340

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FEHLER %s %s" % [was, wie])

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Mira", "Elf", "Zauberlehrling", z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	Testmodus.an = true; Testmodus.geladen = true
	m.reiter = "test"; m.baue()
	for i in 8: await process_frame
	# jedes Kind des Inhalts liegt unter dem vorigen, nichts ueberlappt
	var vor: Control = null
	for c in m.inhalt.get_children():
		if not (c is Control) or not c.visible: continue
		var r: Rect2 = c.get_global_rect()
		if vor != null:
			var rv := vor.get_global_rect()
			pruefe("Ueberlappung", r.position.y >= rv.end.y - 0.5, "%s (%s) beginnt bei %.0f, %s endet bei %.0f" % [c.get_class(), _text(c), r.position.y, _text(vor), rv.end.y])
		# Kinder einer Reihe ragen nicht aus ihr heraus
		for k in c.find_children("*", "Control", true, false):
			if not k.is_visible_in_tree() or k.get_global_rect().size.y < 1: continue
			var rk: Rect2 = k.get_global_rect()
			pruefe("ragt heraus", rk.position.y >= r.position.y - 0.5 and rk.end.y <= r.end.y + 0.5, "%s %s in %s" % [k.get_class(), _text(k), _text(c)])
		vor = c
	# Knopftext passt in den Knopf
	for b in m.inhalt.find_children("*", "Button", true, false):
		if b is Zeichenknopf or String(b.text) == "": continue
		var f: Font = b.get_theme_font("font")
		var w := f.get_multiline_string_size(b.text, HORIZONTAL_ALIGNMENT_CENTER, b.size.x - 12 * Menue.DP, b.get_theme_font_size("font_size"),
			-1, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND if b.autowrap_mode != TextServer.AUTOWRAP_OFF else TextServer.BREAK_MANDATORY)
		pruefe("Knopftext", w.x <= b.size.x - 12 * Menue.DP + 1 and w.y <= b.size.y, "„%s“ %.0f×%.0f in %.0f×%.0f" % [b.text, w.x, w.y, b.size.x, b.size.y])
	# Stufe nur einmal als Wert, Seltenheit klein weiter
	var texte: Array = m.inhalt.find_children("*", "Label", true, false).map(func(l): return String(l.text))
	pruefe("Sehr selten", texte.has("Sehr selten") and not texte.has("Sehr Selten"), str(texte.filter(func(t): return t.to_lower().begins_with("sehr"))))
	var stufen := 0
	for zk in m.inhalt.find_children("*", "Zeichenknopf", true, false):
		if zk.wert != null and String(zk.wert) == str(hw.stufe) and zk.wort == "Stufe": stufen += 1
		if zk.wort == "Stufe" and zk.buchstabe != "" and zk.wert != null and String(zk.wert) == zk.buchstabe: pruefe("Stufe doppelt", false, zk.buchstabe)
	pruefe("Stufe des Helden nicht unter einem Pfeil", stufen == 0, str(stufen))
	# Reiterwechsel beginnt oben: System gerollt, dann Test
	m.reiter = "system"; m.baue()
	for i in 4: await process_frame
	m.rolle.scroll_vertical = 900
	for i in 2: await process_frame
	var rz: Array = m.leiste.get_children()
	rz[rz.size() - 1].pressed.emit()
	for i in 4: await process_frame
	pruefe("Test beginnt oben", m.reiter == "test" and m.rolle.scroll_vertical == 0, "%s %d" % [m.reiter, m.rolle.scroll_vertical])
	# derselbe Reiter behaelt seine Stelle beim Antippen
	m.rolle.scroll_vertical = 600
	for i in 2: await process_frame
	var y0 := m.rolle.scroll_vertical
	m.baue()
	for i in 4: await process_frame
	pruefe("Stelle bleibt", y0 > 0 and m.rolle.scroll_vertical == y0, "%d statt %d" % [m.rolle.scroll_vertical, y0])
	print("TESTMENUE_MASS ", "gut" if fehler == 0 else "FALSCH %d" % fehler)
	quit(1 if fehler else 0)

func _text(c: Node) -> String:
	if c is Label or c is Button: return String(c.text).left(30)
	if c is Zeichenknopf: return c.wort
	var l := c.find_children("*", "Label", true, false)
	return String(l[0].text).left(30) if not l.is_empty() else c.get_class()
