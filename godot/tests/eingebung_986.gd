extends SceneTree
# 986 (Homer, STORY-BRS-KAMPF.md „Eingebungen der Ansagen (986)“): jede Ansage mit Eingebung bringt sie einmal je Spielstand gleich nach
# ihrer Ansage (cue EINGEBUNG), das Knurren nach seiner ersten Zeile; bite und claw ohne. Dazu die Bauhinweise: (2) der von Grak gerufene
# Goblin sagt im Bericht an; (3) Grimmzahns Leibwache sagt nie Einkreisen an, ein angreifbarer Wolf schon.
# Aufruf: im Ordner godot mit -s res://tests/eingebung_986.gd
const Aufruf = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")

func _initialize() -> void: _lauf.call_deferred()

func _kampf(gegner: String, flaggen: Dictionary):
	var tab = Tabellen.lade()     # 870.6: statt regeln/tabellen.json (Build 278)
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte(gegner, held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST", "flaggen": flaggen}):
		print("FEHLER %s nicht gestartet" % gegner); return null
	await process_frame
	return a

func _weg(a) -> void:
	a.kampf.queue_free()
	a.queue_free()
	await process_frame

func _erster_gegner(m):
	for f in m.all:
		if f.side == "FOES": return f
	return null

func _lauf() -> void:
	var f := 0
	var flaggen := {}
	# 1. jede Ansage zweimal: die Eingebung genau einmal, gleich nach der Ansage
	var a = await _kampf("WOLVES", flaggen)
	var m = a.kampf.mars
	for k in flaggen.keys():
		if str(k).begins_with(Mars.GESEHEN_EINGEBUNG): flaggen.erase(k)
	var wolf = _erster_gegner(m)
	var ids := ["heavy", "call", "gather", "stab", "slash", "bite", "claw", "pounce", "circle", "venom", "web", "aim", "shadow", "breakthrough", "flank"]
	for id in ids:
		var intent: Dictionary = m.get("I_" + id.to_upper())
		var aus := []
		m.listener = func(e): aus.append(e)
		for i in 2:
			m.intents[wolf.id] = [intent, [m.lead().id]]
			m._say_announce(wolf)
		var at := []
		for i in aus.size():
			if aus[i].get("cue") == "EINGEBUNG": at.append(i)
		var soll := 1 if Mars.EINGEBUNG.has(id) else 0
		var gut: bool = at.size() == soll and (soll == 0 or (aus[at[0]].text == Mars.EINGEBUNG[id][0] and at[0] == (aus.size() - 1) / 2 and flaggen.has(Mars.GESEHEN_EINGEBUNG + id)))
		print("%s: %d Meldungen, Eingebung an %s %s" % [id, aus.size(), at, "gut" if gut else "FALSCH"])
		if not gut: f += 1
	# Knurren: nach der ersten Zeile MSG399_GROWLS, beim zweiten Mal nicht
	var aus2 := []
	m.listener = func(e): aus2.append(e)
	for i in 2:
		m.intents[wolf.id] = [m.I_GROWL, []]
		m._foe_turn(wolf, Callable())
	var g := []
	for i in aus2.size():
		if aus2[i].get("cue") == "EINGEBUNG" and aus2[i].text == Mars.EINGEBUNG["growl"][0]: g.append(i)
	var gut_g: bool = g.size() == 1 and g[0] >= 1 and aus2[g[0] - 1].get("cue") == "GROWLS"
	print("growl: %d Meldungen, Eingebung an %s %s" % [aus2.size(), g, "gut" if gut_g else "FALSCH"])
	if not gut_g: f += 1
	await _weg(a)
	# zweiter Kampf, selber Spielstand: keine Eingebung mehr
	a = await _kampf("WOLVES", flaggen)
	m = a.kampf.mars
	wolf = _erster_gegner(m)
	var aus3 := []
	m.listener = func(e): aus3.append(e)
	for id in ["heavy", "web", "aim"]:
		m.intents[wolf.id] = [m.get("I_" + id.to_upper()), [m.lead().id]]
		m._say_announce(wolf)
	var n3 := aus3.filter(func(e): return e.get("cue") == "EINGEBUNG").size()
	print("zweiter Kampf: Eingebungen %d %s" % [n3, "gut" if n3 == 0 else "FALSCH"])
	if n3 != 0: f += 1
	await _weg(a)
	# (2) Graks Gerufener sagt im Bericht an
	a = await _kampf("GRAK", {})
	m = a.kampf.mars
	var grak = _erster_gegner(m)
	var aus4 := []
	m.listener = func(e): aus4.append(e)
	var vorher: int = m.all.size()
	m._summon(grak)
	var neu = m.all[m.all.size() - 1] if m.all.size() > vorher else null
	var sagt := neu != null and aus4.any(func(e): return e.text.begins_with(neu.name(0)) and e.text.find(m.intents[neu.id][0].name[0]) >= 0)
	print("Gerufener: %s, sagt an %s" % [neu.name(0) if neu != null else "-", "gut" if sagt else "FALSCH"])
	if not sagt: f += 1
	await _weg(a)
	# (3) Leibwache nie Einkreisen, ein angreifbarer Wolf in 200 Würfen mindestens einmal
	a = await _kampf("GRIMM", {})
	m = a.kampf.mars
	m.chosen = true
	var wache = null
	var frei = null
	for x in m.all:
		if x.side != "FOES": continue
		if not x.angreifbar(): wache = x
		elif x.monster != null and m.wolfig(x.monster): frei = x
	var kreis := {"wache": 0, "frei": 0}
	for i in 200:
		m.intents = {}
		if wache != null and m._pick_intent(wache).effect == "CIRCLE": kreis.wache += 1
		if frei != null and m._pick_intent(frei).effect == "CIRCLE": kreis.frei += 1
	var gut_w: bool = wache != null and frei != null and kreis.wache == 0 and kreis.frei > 0
	print("Leibwache: %s, angreifbarer Wolf: %s, Einkreisen %s %s" % [wache != null, frei != null, kreis, "gut" if gut_w else "FALSCH"])
	if not gut_w: f += 1
	await _weg(a)
	print("EINGEBUNG986 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
