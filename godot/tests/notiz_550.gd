extends SceneTree
# 550 (Chef 04.11., 00:19: „erstes Mal Heilkräuter gepflückt ein riesen Kasten als Einblendung. Dann ab dem 2. Mal normale Größe“):
# die kurze Notiz (steuerung.gd kurz) ist schon beim ersten Mal so gross wie danach, eine Zeile. Ohne Bild. Aufruf: im Ordner godot,
# --headless -s res://tests/notiz_550.gd -> „NOTIZ550 n Fehler“

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	root.size = Vector2i(1080, 2340)
	var s := Steuerung.new()
	root.add_child(s)
	for i in 3: await process_frame
	var groessen := []
	for t in ["Du pflückst Heilkräuter (+2).", "Du pflückst Heilkräuter (+1).", "Du pflückst Heilkräuter (+2)."]:
		s.kurz(t)
		groessen.append(s.notiz_feld.size)
		await process_frame
	print("Groessen: %s" % str(groessen))
	if not groessen[0].is_equal_approx(groessen[2]): print("FEHLER erstes Mal %s, danach %s" % [groessen[0], groessen[2]]); fehler += 1
	var lb := s.notiz_feld.get_child(0) as Label
	if lb.get_line_count() != 1: print("FEHLER %d Zeilen statt einer" % lb.get_line_count()); fehler += 1
	# ein langer Text bricht um, auch beim ersten Mal nicht hoeher als danach
	var s2 := Steuerung.new()
	root.add_child(s2)
	for i in 3: await process_frame
	var lang := "Garrick schwenkt die Fackel aus dem Feuer: Die Biester weichen zurück, solange du am Lager bleibst und das Feuer brennt."
	var h := []
	for i in 2:
		s2.kurz(lang)
		await process_frame
		await process_frame
		h.append(s2.notiz_feld.size)
		if not s2.notiz_feld.visible: print("FEHLER lang nicht sichtbar"); fehler += 1
	print("Lang: %s" % str(h))
	if not h[0].is_equal_approx(h[1]) or h[0].y > 400: print("FEHLER lang erstes Mal %s, danach %s" % [h[0], h[1]]); fehler += 1
	print("NOTIZ550 %d Fehler" % fehler)
	quit(1 if fehler else 0)
