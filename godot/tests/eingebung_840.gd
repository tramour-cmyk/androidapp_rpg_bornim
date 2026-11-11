extends SceneTree
# 840 (830 A, 210 B): Eingebung [830.sprung] direkt nach der ersten Ansage „Anspringen“, einmal je Spielstand. Kampf mit Flaggen wie aus
# spiel.gd, die Ansage zweimal: die Eingebung kommt einmal, gleich nach der Ansage und ihrem Zeichen, die Flagge steht; ein zweiter Kampf
# mit denselben Flaggen bringt sie nicht mehr. Aufruf: im Ordner godot mit -s res://tests/eingebung_840.gd
const Aufruf = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")

func _initialize() -> void: _lauf.call_deferred()

## Meldungen zweier Ansagen „Anspringen“ des ersten Wolfs auf den Helden
func _ansagen(flaggen: Dictionary, erst: bool) -> Array:
	var tab = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST", "flaggen": flaggen}):
		print("FEHLER nicht gestartet"); return []
	await process_frame
	var m = a.kampf.mars
	# der Kampf kann schon beim Start „Anspringen“ ansagen (dann ist die Flagge gesetzt); für den ersten Kampf von vorn
	if erst: flaggen.erase(Mars.GESEHEN_EINGEBUNG + "pounce")
	var aus := []
	m.listener = func(e): aus.append(e)
	var wolf = null
	for f in m.all:
		if f.side == "FOES": wolf = f; break
	for i in 2:
		m.intents[wolf.id] = [m.I_POUNCE, [m.lead().id]]
		m._say_announce(wolf)
	a.kampf.queue_free()
	a.queue_free()
	await process_frame
	return aus

func _lauf() -> void:
	var f := 0
	var flaggen := {}
	var text: String = Mars.EINGEBUNG["pounce"][0]
	var e1: Array = await _ansagen(flaggen, true)
	var idx := []
	for i in e1.size():
		if e1[i].text == text: idx.append(i)
	print("erster Kampf: %d Meldungen, Eingebung an %s (cue %s); Flagge %s" % [e1.size(), idx, e1[idx[0]].cue if not idx.is_empty() else "-", flaggen.has(Mars.GESEHEN_EINGEBUNG + "pounce")])
	# Ansage, Zeichen, Eingebung; dann Ansage, Zeichen
	if idx != [2] or e1.size() != 5 or e1[2].cue != "EINGEBUNG" or not flaggen.has(Mars.GESEHEN_EINGEBUNG + "pounce"):
		f += 1
	var e2: Array = await _ansagen(flaggen, false)
	var n2 := e2.filter(func(e): return e.text == text).size()
	print("zweiter Kampf, selber Spielstand: %d Meldungen, Eingebungen %d" % [e2.size(), n2])
	if n2 != 0 or e2.size() != 4:
		f += 1
	print("EINGEBUNG840 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
