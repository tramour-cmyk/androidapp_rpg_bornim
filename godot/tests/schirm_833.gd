extends "res://tests/am_zug_565.gd"
# 833 (Chef 10.11., 10:05–10:17, über Sokrates): unterer Kampfschirm heute und Vorschlag A (kampf_ui.gd schirm_833) im Probekampf gegen
# das Wolfsrudel (Mira, Söldner). Prüft ohne Bild: in A kein Rahmen um Kasten, Bericht und Knöpfe; zieht ein Gegner, stehen dieselben
# Knöpfe ausgegraut an ihrem Platz statt „…“ (Söldner und Held Auto schaltbar), die Höhe des Kastens bleibt gleich; ein Tipp darauf
# nennt den, der am Zug ist, und lässt ihn aufleuchten; am Ende Titel, Zierlinie und Knöpfe der Schirme.
# Aufruf: im Ordner godot --headless -s res://tests/schirm_833.gd (braucht daten/ und kampf/daten/ wie im Bau). Exit 0 = richtig.
# Die Bilder dazu macht tests/schirm_833_bild.gd (gleicher Ablauf).

func _schalte(ui, art: String) -> void:
	ui.schirm_833 = art
	ui.refresh()
	for i in 3: await process_frame

func _knoepfe(ui) -> Array:
	var out := []
	for r in ui.orders.get_children():
		if r.is_queued_for_deletion():
			continue
		for b in r.find_children("*", "Button", true, false):
			out.append(b)
	return out

func _pruefe_a(ui, was: String) -> void:
	# der Kasten bleibt so breit wie der Bildschirm abzüglich Rand (fünf Knöpfe unten schoben ihn hinaus)
	var soll_breit: float = root.size.x - ui.panel.offset_left + ui.panel.offset_right
	if ui.panel.size.x > soll_breit + 1.0:
		print("FEHLER %s: Kasten %.0f breit statt %.0f" % [was, ui.panel.size.x, soll_breit]); fehler += 1
	var sb: StyleBoxFlat = ui.panel.get_theme_stylebox("panel")
	if sb.border_color.a > 0.0:
		print("FEHLER %s: Kasten mit Rahmen" % was); fehler += 1
	for b in _knoepfe(ui):
		var n = b.get_theme_stylebox("disabled" if b.disabled else "normal")
		if n is StyleBoxFlat and (n as StyleBoxFlat).border_color.a > 0.0:
			print("FEHLER %s: Knopf %s mit Rahmen" % [was, b.text]); fehler += 1

func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var p = load("res://kampf/probe.tscn").instantiate()
	root.add_child(p)
	await process_frame
	p.hero_cls = "CLERIC"
	p.still_name = "Mira"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	p._start(7)
	var t0 := Time.get_ticks_msec()
	while p.fight == null and Time.get_ticks_msec() - t0 < 15000:
		await process_frame
	var k = p.fight
	await create_timer(2.5).timeout
	if not await _warte(k, "PARTY", "hero"):
		print("FEHLER Kampf vorbei, bevor Mira dran war"); quit(1); return
	var ui = k.ui
	await _schalte(ui, "")
	await _bild("833_1_held_heute")
	await _schalte(ui, "A")
	_pruefe_a(ui, "Mira")
	var namen_held: Array = _knoepfe(ui).map(func(b): return b.text)
	var hoehe_held: float = ui.panel.size.y
	await _bild("833_1_held_a")
	# 833 A: der ganze Bericht als Fenster ohne Kasten (Titel, Zierlinie, ‹ ZURÜCK), das Erklärfenster ohne Goldrand
	ui.log_line("Probezeile 833 mit 4 Schaden")
	ui._show_full_log(true)
	for i in 4: await process_frame
	var fb: StyleBoxFlat = ui.full_log.get_theme_stylebox("panel")
	if fb.border_color.a > 0.0:
		print("FEHLER ganzer Bericht mit Rahmen"); fehler += 1
	var titel = ui.full_log.find_child("Titel", true, false)
	if titel == null or titel.text != "KAMPFBERICHT":
		print("FEHLER ganzer Bericht ohne Titel KAMPFBERICHT"); fehler += 1
	var zurueck: Array = ui.full_log.find_children("*", "PanelContainer", true, false).filter(func(c): return c.get_meta("knopf", "") == "neben")
	if zurueck.size() != 1:
		print("FEHLER ganzer Bericht ohne ‹ ZURÜCK"); fehler += 1
	await _bild("833_4_bericht_a")
	# Tippen in den Bericht schließt nicht, Android-Zurück schon
	ui.full_log_opened_ms -= 1000
	var mitte: Vector2 = ui.full_log.size / 2
	for gedrueckt in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = gedrueckt
		e.position = mitte
		ui._full_log_input(e)
	if not ui.full_log.visible:
		print("FEHLER Tippen in den Bericht schließt ihn"); fehler += 1
	if not Zurueck.taste(self) or ui.full_log.visible:
		print("FEHLER Android-Zurück schließt den Bericht nicht"); fehler += 1
	ui.show_tip("Probe 833")
	var tb: StyleBoxFlat = ui.tip.get_theme_stylebox("normal")
	if tb.border_color.a > 0.0:
		print("FEHLER Erklärfenster mit Goldrand"); fehler += 1
	ui.tip.visible = false
	# ein Wolf zieht: anhalten, solange er zieht
	k.order(["wait"])
	var bis := Time.get_ticks_msec() + 60000
	while Time.get_ticks_msec() < bis and not (k.busy and _vorn(k) != null and _vorn(k).side == "FOES"):
		if k.ring_open and Time.get_ticks_msec() - k.ring_start > 3000:
			k._answer_ring("NONE")
		await process_frame
	await create_timer(0.5).timeout
	if not k.busy:
		print("FEHLER kein Gegnerzug gefunden"); quit(1); return
	Engine.time_scale = 0.02
	await _schalte(ui, "")
	await _bild("833_2_gegner_heute")
	await _schalte(ui, "A")
	_pruefe_a(ui, "Wolf")
	var ks := _knoepfe(ui)
	var namen: Array = ks.map(func(b): return b.text)
	# seit 751 A stehen beim Gegnerzug die Knöpfe dessen, der als Nächster aus der Gruppe zieht (Söldner mit „Decken“), matt da
	for soll_da in ["ANGRIFF", "KÖNNEN", "TASCHE", "WECHSEL", "ABWEHR"]:
		if not namen.has(soll_da):
			print("FEHLER Knöpfe beim Gegnerzug %s, beim Helden %s" % [namen, namen_held]); fehler += 1
			break
	for b in ks:
		var soll_an: bool = b.text.begins_with("SÖLDNER") or b.text.begins_with("HELD")
		if b.disabled == soll_an:
			print("FEHLER Knopf %s %s" % [b.text, "aus" if b.disabled else "an"]); fehler += 1
	if absf(ui.panel.size.y - hoehe_held) > 1.0:
		print("FEHLER Höhe des Kastens %.0f statt %.0f" % [ui.panel.size.y, hoehe_held]); fehler += 1
	# Tipp auf den ausgegrauten Angriff
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ks[0].gui_input.emit(ev)
	var soll := "%s ist am Zug" % _vorn(k).name(0)
	if not ui.tip.visible or ui.tip.text != soll:
		print("FEHLER Tipp „%s“, soll „%s“" % [ui.tip.text, soll]); fehler += 1
	if ui.aufleuchten_bis <= Time.get_ticks_msec():
		print("FEHLER leuchtet nicht auf"); fehler += 1
	ui.aufleuchten_bis = Time.get_ticks_msec() + 30000     # das Bild am Rechner braucht länger als die 1,5 s
	ui.tip_nr += 1     # und das Fenster bleibt dafür stehen
	for i in 3: await process_frame
	await _bild("833_2_gegner_a")
	print("Gegnerzug: %s, Knöpfe %s, Höhe %.0f" % [soll, namen, ui.panel.size.y])
	Engine.time_scale = 1.0
	# Sieg (Testknopf)
	ui.tip.visible = false
	k.test_end(true)
	# 1106 (Lauf 401, Bildlauf mit Fenster): 60 s reichten dort nicht, die Wölfe lagen, der Kampf war noch beschäftigt, und der Test
	# meldete „zwei Zierlinien“ auf dem Schirm vor dem Sieg (Bild 833_3_sieg_a: Knöpfe matt, kein Sieg); jetzt bis 300 s, und ohne
	# Sieg ein eigener Fehler statt der Prüfungen des Siegs
	bis = Time.get_ticks_msec() + 300000
	while Time.get_ticks_msec() < bis and (k.mars.outcome == "ONGOING" or k.busy):
		if k.ring_open and Time.get_ticks_msec() - k.ring_start > 3000:
			k._answer_ring("NONE")
		await process_frame
	await create_timer(1.0).timeout
	if k.mars.outcome == "ONGOING" or k.busy:
		print("FEHLER Sieg nach 300 s nicht erreicht (Ausgang %s, beschäftigt %s)" % [k.mars.outcome, k.busy]); fehler += 1
		print("SCHIRM833 %d Fehler" % fehler)
		quit(1); return
	await _schalte(ui, "")
	await _bild("833_3_sieg_heute")
	await _schalte(ui, "A")
	_pruefe_a(ui, "Sieg")
	if ui.zier_833.visible:
		print("FEHLER Sieg: zwei Zierlinien"); fehler += 1
	await _bild("833_3_sieg_a")
	print("SCHIRM833 %d Fehler" % fehler)
	quit(1 if fehler else 0)
