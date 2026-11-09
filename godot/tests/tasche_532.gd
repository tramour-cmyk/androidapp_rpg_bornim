extends SceneTree
# 532 ohne Bild (Durchspielregel 488, „532a jetzt“): die ganze Tasche im MARS-Kampf wie im alten (Battle.useItem). Großer Heiltrank
# heilt mehr als der einfache, der Kräutertrank nimmt Zustände (der Rausch bleibt), voll und ohne Zustände ist er nicht wählbar;
# Alchemistenfeuer trifft immer und setzt in Brand, Weihwasser nur gegen Untote; aufruf.gd nimmt aus lage „tasche“ nur, was im
# Kampf geht (kein Ausdauertrank, kein Leuchtfunke).
# Aufruf: im Ordner godot mit -s res://tests/tasche_532.gd -> „TASCHE532 ok“
const Mars = preload("res://regeln/mars.gd")
const AufrufS = preload("res://kampf/aufruf.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

var f := 0

func pruefe(was: String, ist, soll) -> void:
	if ist == soll:
		print("ok ", was)
	else:
		f += 1
		print("FEHLER %s: %s statt %s" % [was, str(ist), str(soll)])

func _initialize() -> void: _lauf.call_deferred()

func _kampf(tab, a, skills, monsters, seed: int, tasche: Dictionary):
	var held = a._kaempfer("hero", tab.probe.FIGHTER.hero.hero, int(tab.probe.FIGHTER.hero.hp), Vector2i(Mars.FRONT, 0), skills)
	var foes = AufrufS.gegner("RATTE", monsters, Wuerfel.new(seed + 1))
	var m = Mars.new([held], foes, tab, Wuerfel.new(seed), Wuerfel.new(seed + 279), 0, false, "HERO_FIRST")
	for k in tasche: m.potions[k] = int(tasche[k])
	m.start(func(_t, _x): return "NONE")
	return m

func _lauf() -> void:
	var tab = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var skills := {}
	for s in tab.skills: skills[s.id] = s
	var monsters := {}
	for m in tab.monsters: monsters[m.id] = m
	var a = AufrufS.new()
	a.tabellen = tab
	var voll := {"potion": 1, "greater_potion": 1, "superior_potion": 1, "remedy": 1, "alchemist_fire": 2, "holy_water": 1}

	# Tasche: Tränke trinkbar, Feuer werfbar, Weihwasser ohne Untote nicht
	var m = _kampf(tab, a, skills, monsters, 1, voll)
	var held = m.find("hero")
	var ratte = m.all.filter(func(x): return x.side == "FOES")[0]
	pruefe("trinkbar", m.drinkable(), ["potion", "greater_potion", "superior_potion", "remedy"])
	pruefe("werfbar ohne Untote", m.throwable(), ["alchemist_fire"])
	pruefe("Weihwasser ohne Ziel", m.throw_targets("holy_water").size(), 0)
	pruefe("voll: Heiltrank bringt nichts", m.drink_helps("potion", held), false)
	pruefe("voll ohne Zustände: Kräutertrank bringt nichts", m.drink_helps("remedy", held), false)

	# Kräutertrank: Gift weg, Rausch bleibt
	held.status = {"POISON": 3, "DRUNK": Mars.LASTING}
	pruefe("mit Gift: Kräutertrank hilft", m.drink_helps("remedy", held), true)
	if m.outcome == "ONGOING" and m.current() == held:
		m.act(["drink", "remedy", "hero"], func(_t, _x): return "NONE")
		pruefe("Gift geheilt", held.status.has("POISON"), false)
		pruefe("Rausch bleibt", held.status.has("DRUNK"), true)
		pruefe("Kräutertrank verbraucht", int(m.potions["remedy"]), 0)
	else:
		f += 1; print("FEHLER Held nicht am Zug (Kräutertrank)")

	# Alchemistenfeuer: trifft immer, Brand (je Würfelfolge)
	var getroffen := 0
	var brand := 0
	var versuche := 0
	for seed in 60:
		var m2 = _kampf(tab, a, skills, monsters, 100 + seed, {"alchemist_fire": 1})
		var h2 = m2.find("hero")
		if m2.outcome != "ONGOING" or m2.current() != h2:
			continue
		versuche += 1
		var r = m2.all.filter(func(x): return x.side == "FOES" and x.standing())[0]
		var vor: int = r.hp
		var log: Array = m2.act(["throw", "alchemist_fire", r.id], func(_t, _x): return "NONE")
		if r.hp < vor or not r.standing(): getroffen += 1
		if log.any(func(e): return e.cue == "STATUS" and e.target == r.id): brand += 1
		if int(m2.potions["alchemist_fire"]) != 0: f += 1; print("FEHLER Feuer nicht verbraucht")
		if seed == 0: print("  ", log.map(func(e): return e.text).slice(0, 4))
	print("Alchemistenfeuer: %d Würfe, %d Treffer, %d Brand" % [versuche, getroffen, brand])
	pruefe("Feuer trifft immer", versuche > 0 and getroffen == versuche, true)
	pruefe("Feuer setzt in Brand (wer stehen bleibt)", brand > 0, true)

	# Großer Heiltrank heilt mehr als der einfache
	var heil := {"potion": 0, "greater_potion": 0}
	for id in heil:
		for seed in 40:
			var m3 = _kampf(tab, a, skills, monsters, 300 + seed, {id: 1})
			var h3 = m3.find("hero")
			if m3.outcome != "ONGOING" or m3.current() != h3: continue
			h3.hp = 1
			m3.act(["drink", id, "hero"], func(_t, _x): return "NONE")
			heil[id] += h3.hp - 1
	print("Heilung über 40 Kämpfe: ", heil)
	pruefe("Großer Heiltrank heilt mehr", heil.greater_potion > heil.potion, true)

	# Weihwasser gegen Untote
	var m4 = _kampf(tab, a, skills, monsters, 7, {"holy_water": 1})
	var r4 = m4.all.filter(func(x): return x.side == "FOES")[0]
	r4.monster = (r4.monster as Dictionary).duplicate()
	r4.monster["undead"] = true
	pruefe("Weihwasser gegen Untote werfbar", m4.throwable(), ["holy_water"])

	# aufruf.gd: nur, was im Kampf geht
	var held_d = tab.probe.FIGHTER.hero.hero
	root.add_child(a)
	var ok: bool = a.starte("RATTE", held_d, null, "wald", "tag", 0, int(tab.probe.FIGHTER.hero.hp), -1, 5, Callable(),
			{"tasche": {"potion": 2, "stamina_potion": 1, "spark_potion": 1, "alchemist_fire": 1, "raw_meat": 3}})
	pruefe("Kampf beginnt", ok, true)
	if ok:
		pruefe("Tasche im Kampf", a.kampf.mars.potions, {"potion": 2, "alchemist_fire": 1})
	print("TASCHE532 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
