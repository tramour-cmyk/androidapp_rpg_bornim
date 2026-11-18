extends SceneTree
# 785.12 (alt SkirmishScreen 582–588, 705–725, 1257–1262, 1321–1328; MarsTips firstRing, tapNow): Ring erklärt und Urteil je Ergebnis.
# (1) die erste Ansage mit Ring gegen den selbst gesteuerten Helden bringt [219T.erster] einmal je Spielstand, vor der Eingebung;
# (2) gegen einen Helden auf Automatik nicht; (3) [219T.jetzt] steht über dem ersten Ring je Spielstand, danach nicht mehr;
# (4) Urteil in der Farbe des Ergebnisses, „Gut“ allein, wenn der Schlag nach gutem Ring verfehlt, die Antwort der Klasse darunter.
# Aufruf: im Ordner godot mit -s res://tests/ring_785.gd
const Aufruf = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")
const KampfUi = preload("res://kampf/kampf_ui.gd")

func _initialize() -> void: _lauf.call_deferred()

func _start(flaggen: Dictionary):
	var tab = Tabellen.lade()
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST", "flaggen": flaggen}):
		print("FEHLER nicht gestartet"); return null
	await process_frame
	return a

func _ende(a) -> void:
	a.kampf.mars.listener = func(_e): pass
	a.kampf.queue_free()
	a.queue_free()
	await process_frame

## Meldungen zweier Ansagen „Schwerer Hieb“ (mit Ring) des ersten Wolfs auf den Helden
func _ansagen(a, auto: bool) -> Array:
	var m = a.kampf.mars
	var aus := []
	m.listener = func(e): aus.append(e)
	var wolf = null
	for f in m.all:
		if f.side == "FOES": wolf = f; break
	m.lead().auto = auto
	var eigene := []
	for i in 2:
		var vor := aus.size()
		m.intents[wolf.id] = [m.I_HEAVY, [m.lead().id]]
		m._say_announce(wolf)
		eigene.append_array(aus.slice(vor))
	return eigene

func _lauf() -> void:
	var f := 0
	var erster: String = Mars.MSG219_ERSTER[0]
	# (1)
	var flaggen := {}
	var a = await _start(flaggen)
	if a == null: quit(1); return
	flaggen.erase(Mars.GESEHEN_RING)
	flaggen.erase(Mars.GESEHEN_EINGEBUNG + "heavy")
	var e1: Array = await _ansagen(a, false)
	var i_r := -1
	var i_e := -1
	var n_r := 0
	for i in e1.size():
		if e1[i].text == erster: n_r += 1; i_r = i
		if e1[i].text == Mars.EINGEBUNG["heavy"][0]: i_e = i
	print("(1) %d Meldungen, Ringerklärung %d× an %d (cue %s), Eingebung an %d, Flagge %s" % [e1.size(), n_r, i_r,
		e1[i_r].cue if i_r >= 0 else "-", i_e, flaggen.has(Mars.GESEHEN_RING)])
	if n_r != 1 or i_e < 0 or i_r > i_e or e1[i_r].cue != "RING_ERSTER" or not flaggen.has(Mars.GESEHEN_RING):
		f += 1
	# (3), (4) am Bedienfeld dieses Kampfs
	var ui = a.kampf.ui
	var wolf_id := ""
	for x in a.kampf.mars.all:
		if x.side == "FOES": wolf_id = x.id; break
	flaggen.erase(Mars.GESEHEN_RING_JETZT)
	ui.ring_open(a.kampf.mars.lead().id, {})
	var hilfe1: bool = ui.ring_hilfe
	ui.ring_verdict("GOOD")
	var gut_farbe: Color = ui.verdict.get_theme_color("font_color")
	var gut_text: String = ui.verdict.text
	ui.ring_folge({"actor": wolf_id, "target": "hero", "roll": ["BRS", 80, 0, 40, false, 0], "text": "Wolf verfehlt.", "answer": false})
	var gut_daneben: String = ui.verdict.text
	ui.ring_close()
	ui.ring_open(a.kampf.mars.lead().id, {})
	var hilfe2: bool = ui.ring_hilfe
	ui.ring_verdict("PERFECT")
	var perf_farbe: Color = ui.verdict.get_theme_color("font_color")
	ui.ring_folge({"actor": "hero", "target": wolf_id, "roll": null, "text": "Alrik weicht dem Schlag aus und schlägt zurück.", "answer": true})
	var antwort: String = ui.verdict_antwort.text if ui.verdict_antwort.visible else ""
	ui.ring_close()
	ui.ring_open(a.kampf.mars.lead().id, {})
	ui.ring_verdict("NONE")
	var none_farbe: Color = ui.verdict.get_theme_color("font_color")
	var antwort_weg: bool = not ui.verdict_antwort.visible
	ui.ring_close()
	print("(3) Wort über dem ersten Ring %s, über dem zweiten %s, Flagge %s" % [hilfe1, hilfe2, flaggen.has(Mars.GESEHEN_RING_JETZT)])
	if not hilfe1 or hilfe2 or not flaggen.has(Mars.GESEHEN_RING_JETZT):
		f += 1
	print("(4) gut „%s“ %s, daneben „%s“; perfekt %s, Antwort „%s“; verpasst %s, Antwort weg %s" % [gut_text, gut_farbe.to_html(false),
		gut_daneben, perf_farbe.to_html(false), antwort, none_farbe.to_html(false), antwort_weg])
	if gut_farbe != KampfUi.TEXT or perf_farbe != KampfUi.BRIGHT or none_farbe != KampfUi.WARN or gut_text != "Gut: halber Schaden" \
			or gut_daneben != "Gut" or antwort != "Alrik weicht dem Schlag aus und schlägt zurück." or not antwort_weg:
		f += 1
	await _ende(a)
	# zweiter Kampf, selber Spielstand: keine Ringerklärung mehr
	a = await _start(flaggen)
	var e2: Array = await _ansagen(a, false)
	var n2 := e2.filter(func(e): return e.text == erster).size()
	await _ende(a)
	# (2) neuer Spielstand, Held auf Automatik
	var flaggen3 := {}
	a = await _start(flaggen3)
	flaggen3.erase(Mars.GESEHEN_RING)
	var e3: Array = await _ansagen(a, true)
	var n3 := e3.filter(func(e): return e.text == erster).size()
	await _ende(a)
	print("(1b) zweiter Kampf %d, (2) Automatik %d Ringerklärungen" % [n2, n3])
	if n2 != 0 or n3 != 0:
		f += 1
	print("RING785 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
