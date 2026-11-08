extends SceneTree
# 565 (Chef 04.11., 17:10: „unten sehe ich gar nicht, welcher von den beiden es ist … Umrandung irgendwie hervorheben“): Vorschlag
# (kampf_ui.gd am_zug_565) im Probekampf wie das Vergleichsbild (Kleriker Mira, Söldner Kämpfer, Wölfe). Prüft ohne Bild: genau der
# Kasten dessen, der in der Zugleiste das ▶ trägt, ist hervorgehoben, beim Gegner keiner; Mira, ein Gegner, der Söldner am Zug.
# Aufruf: im Ordner godot --headless -s res://tests/am_zug_565.gd (braucht daten/ und kampf/daten/ wie im Bau). Exit 0 = richtig.
# Die Bilder dazu macht tests/am_zug_565_bild.gd (gleicher Ablauf).


var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

## ohne Bild; am_zug_565_bild.gd legt hier das Bild ab
func _bild(_n: String) -> void:
	await process_frame

func _zeige(ui, art: String) -> void:
	ui.am_zug_565 = art
	ui.refresh()
	await process_frame
	await process_frame

## ▶ in der Zugleiste und hervorgehobene Kästen müssen zusammenpassen
func _pruefe(k, was: String) -> void:
	var vorn = _vorn(k)
	var hell := []
	for f in k.mars.fighters():
		if f.side == "PARTY" and k.ui._am_zug(f):
			hell.append(f.id)
	var soll: Array = [vorn.id] if vorn != null and vorn.side == "PARTY" else []
	# und die gebauten Kästen: Goldrand 1,5 dp und „▶“ nur am Kasten dessen, der vorn steht (Kästen in der Reihenfolge der Gruppe)
	var gruppe: Array = k.mars.fighters().filter(func(f): return f.side == "PARTY")
	var kaesten: Array = k.ui.party_row.get_children().filter(func(c): return not c.is_queued_for_deletion())
	var gold := []
	for i in kaesten.size():
		var sb: StyleBoxFlat = kaesten[i].get_theme_stylebox("panel")
		var namen: Array = kaesten[i].find_children("*", "Label", true, false)
		if sb.border_color == k.ui.GOLD and namen.size() > 0 and namen[0].text.begins_with("▶ "):
			gold.append(gruppe[i].id)
	if gold != soll:
		print("FEHLER %s: Kasten mit Goldrand und ▶ %s, soll %s" % [was, gold, soll])
		fehler += 1
	print("%s: vorn %s, hervorgehoben %s" % [was, vorn.id if vorn else "-", hell])
	if hell != soll:
		print("FEHLER %s: hervorgehoben %s, soll %s" % [was, hell, soll])
		fehler += 1

## wer in der Zugleiste vorn steht (das ▶ trägt): der Erste der gezeigten Zugfolge, der noch steht
func _vorn(k):
	for id in k.shown.get("queue", []):
		var o = k.mars.find(id)
		if o != null and k.shown.hp.get(id, o.hp) > 0:
			return o
	return null

## bis [seite] (und [id]) in der Zugleiste vorn steht; die Gruppe ist ruhig und wartet auf einen Befehl, der Gegner spielt seinen Zug;
## ist ein anderer der Gruppe dran, wehrt er ab
func _warte(k, seite: String, id := "") -> bool:
	Engine.time_scale = 8.0
	var bis := Time.get_ticks_msec() + 240000
	while Time.get_ticks_msec() < bis and k.mars.outcome == "ONGOING":
		var c = k.mars.current()
		var v = _vorn(k)
		var ruhig: bool = not k.busy and not k.playing
		var gut: bool = v != null and v.side == seite and (id == "" or v.id == id)
		if seite == "PARTY":
			gut = gut and ruhig and c == v
		if gut:
			break
		if k.ring_open and Time.get_ticks_msec() - k.ring_start > 3000:
			k._answer_ring("NONE")
		if ruhig and c.side == "PARTY":
			_angriff(k)
		await process_frame
	Engine.time_scale = 1.0
	if seite == "PARTY":
		await create_timer(0.6).timeout
	var v = _vorn(k)
	print("warte %s %s: vorn %s, Ausgang %s, %d ms" % [seite, id, v.id if v else "-", k.mars.outcome, Time.get_ticks_msec()])
	return k.mars.outcome == "ONGOING"

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
		print("FEHLER Kampf vorbei, bevor Mira dran war")
		quit(1)
		return
	var ui = k.ui
	await _zeige(ui, "")
	await _bild("565_held_jetzt")
	await _zeige(ui, "A")
	_pruefe(k, "Mira")
	await _bild("565_held_a")
	await _zeige(ui, "B")
	await _bild("565_held_b")
	await _zeige(ui, "A")
	# weiter: Mira wehrt ab; dann die Wölfe und der Söldner
	_angriff(k)
	if await _warte(k, "FOES"):
		await create_timer(0.3).timeout
		_pruefe(k, "Gegner")
		await _bild("565_gegner_a")
	if await _warte(k, "PARTY", "merc"):
		_pruefe(k, "Söldner")
		await _bild("565_soeldner_a")
	print("AMZUG565 %d Fehler" % fehler)
	quit(1 if fehler else 0)

## ein Zug dessen, der dran ist: Abwehr (wie ein Tipp auf ABWEHR); ein Angriff kann den Leitwolf fällen, dann flieht das Rudel
func _angriff(k) -> void:
	k.order(["wait"])
