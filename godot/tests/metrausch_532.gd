extends SceneTree
# 532 ohne Bild: Metrausch wie alt (Battle.drunk, Status.DRUNK): aus der Welt betrunken (aufruf.gd lage „betrunken“) trägt der
# Held „Betrunken“ den ganzen Kampf, greift mit Nachteil an, flieht mit Nachteil; danach bleibt nichts davon in den Leiden.
# Aufruf: im Ordner godot mit -s res://tests/metrausch_532.gd
const Mars = preload("res://regeln/mars.gd")
const AufrufS = preload("res://kampf/aufruf.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var f := 0
	var tab = Tabellen.lade()
	var skills := {}
	for s in tab.skills: skills[s.id] = s
	var monsters := {}
	for m in tab.monsters: monsters[m.id] = m
	var a = AufrufS.new()
	a.tabellen = tab
	var flucht := [0, 0]
	var modus := [0, 0]
	for betrunken in [false, true]:
		var i := 1 if betrunken else 0
		for seed in 400:
			var held = a._kaempfer("hero", tab.probe.FIGHTER.hero.hero, int(tab.probe.FIGHTER.hero.hp), Vector2i(Mars.FRONT, 0), skills)
			if betrunken:
				held.status["DRUNK"] = Mars.LASTING
			var foes = AufrufS.gegner("RATTE", monsters, Wuerfel.new(seed + 1))
			var m = Mars.new([held], foes, tab, Wuerfel.new(seed), Wuerfel.new(seed + 279), 0, false, "HERO_FIRST")
			m.start(func(_t, _x): return "NONE")
			if seed == 0:
				modus[i] = m._row_mode(held, foes[0], true)
			if m.outcome == "ONGOING" and m.current() == held and m.can_flee(held):
				m.act(["flee"], func(_t, _x): return "NONE")
				if m.outcome == "FLED":
					flucht[i] += 1
			if seed == 0 and betrunken and not held.status.has("DRUNK"):
				f += 1
				print("FEHLER Betrunken verging im Kampf")
	print("Angriff: nüchtern %d, betrunken %d; Flucht gelungen: nüchtern %d, betrunken %d von 400" % [modus[0], modus[1], flucht[0], flucht[1]])
	if modus[1] != modus[0] - 1: f += 1
	if flucht[1] >= flucht[0]: f += 1
	var bleibt := {}
	var h2 = a._kaempfer("hero", tab.probe.FIGHTER.hero.hero, 10, Vector2i(Mars.FRONT, 0), skills)
	h2.status = {"DRUNK": Mars.LASTING, "POISON": 2}
	bleibt = AufrufS.leiden_nach(h2, "WON", 0)
	print("nach dem Kampf in den Leiden: ", bleibt)
	if bleibt.has("DRUNK"): f += 1
	print("METRAUSCH 532 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
