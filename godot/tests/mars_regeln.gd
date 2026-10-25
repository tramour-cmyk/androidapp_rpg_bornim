# 348.7: rules the Kotlin MARS lacked and the port adds (Test 89.2), checked by counting the hero's attack rolls.
# Run: godot --headless --path godot -s res://tests/mars_regeln.gd   (exit code 0 = all as the SRD says)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Lohn = preload("res://regeln/lohn.gd")
const Kampfort = preload("res://kampf/kampfort.gd")

var tables: Dictionary
var failed := 0


func _init() -> void:
	tables = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	# 89.2 (c): fighter level 3 with two weapons: Attack 2 blows, Action Surge 3 (SRD: two actions, one bonus action)
	_check("ein Schwert, Angriff", _blows(false, [], ["attack"]), 1)
	_check("zwei Waffen, Angriff", _blows(true, [], ["attack"]), 2)
	_check("zwei Waffen, Tatendrang", _blows(true, [], ["use", "ACTION_SURGE"]), 3)
	_check("ein Schwert, Tatendrang", _blows(false, [], ["use", "ACTION_SURGE"]), 2)
	_check("Stufe 5, zwei Waffen, Angriff", _blows(true, ["EXTRA_ATTACK"], ["attack"]), 3)
	_check("Stufe 5, zwei Waffen, Tatendrang", _blows(true, ["EXTRA_ATTACK"], ["use", "ACTION_SURGE"]), 5)
	_check("zwei Waffen, Armbrust gezogen", _blows(true, [], ["attack"], true), 1)
	# 296.2: getting away as in the old fight, never from a boss; who strikes first
	_flight()
	_openings()
	# 296.2: the statuses of the old fight
	_statuses()
	# 296.2 (Test 89.2 b): never a fight without life points; what a won fight brings
	_no_life()
	_rewards()
	print("MARS Regeln: %d abweichend" % failed)
	quit(1 if failed > 0 else 0)


func _check(what: String, got: int, want: int) -> void:
	if got != want:
		failed += 1
		print("FEHLER %s: %d Hiebe statt %d" % [what, got, want])
	else:
		print("gleich %s: %d" % [what, got])


## The hero's attack rolls in its first turn against wolves too tough to fall.
func _blows(two: bool, extra: Array, order: Array, drawn := false) -> int:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	sheet.skills.append_array(extra)
	if two:
		sheet["off"] = {"id": "shortsword", "de": "Kurzschwert", "en": "Shortsword", "atk": 5, "dmg": [1, 6, 0], "ranged": false, "reach": false, "two": false}
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var wolf: Dictionary
	for m in tables.monsters:
		if m.id == "wolf":
			wolf = m
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	hero.drawn = drawn
	var foes := [Mars.monster_fighter("w1", Vector2i(Mars.FRONT, 0), wolf, 999), Mars.monster_fighter("w2", Vector2i(Mars.FRONT, 1), wolf, 999)]
	var mars = Mars.new([hero], foes, tables, Wuerfel.new(7), Wuerfel.new(7))
	var heard := []
	mars.listener = func(e): heard.append(e)
	mars.start()
	assert(mars.current() == hero)
	heard.clear()
	var o: Array = order.duplicate()
	o.append("w1")
	if o[0] == "use":
		assert(mars.blocked(hero, o[1]) == null)
	mars.act(o)
	var n := 0
	for e in heard:
		if e.actor == "hero" and e.roll != null and e.roll[0] == "ATTACK":
			n += 1
		elif e.actor != "hero" and n > 0:
			break
	return n


func _monster(id: String) -> Dictionary:
	for m in tables.monsters:
		if m.id == id:
			return m
	return {}


func _fight(sheet: Dictionary, foe_ids: Array, tape, opening := "NORMAL"):
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var foes := []
	for i in foe_ids.size():
		foes.append(Mars.monster_fighter("f%d" % i, Mars.SPOTS[i], _monster(foe_ids[i]), 999))
	return Mars.new([hero], foes, tables, Wuerfel.new(tape), Wuerfel.new(7), 0, false, opening)


func _flight() -> void:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var wolf := _monster("wolf")
	var dc: int = 10 + int(wolf.dex)
	# initiative: hero 20, wolf 1; then the flight roll
	for c in [[dc - int(sheet.dex), "FLED"], [dc - int(sheet.dex) - 1, "ONGOING"]]:
		var m = _fight(sheet, ["wolf"], [20, 1] + _ones())
		m.start()
		# the flight roll comes first on the tape once the hero chooses
		m.dice.tape = [c[0]] + _ones()
		m.dice.pos = 0
		m.act(["flee"])
		var got: String = m.outcome
		_check_s("Flucht mit %d" % c[0], got, c[1])
	var rogue: Dictionary = tables.probe.ROGUE.hero.hero.duplicate(true)
	var r = _fight(rogue, ["wolf"], [20, 1] + _ones())
	r.start()
	if r.current().id == "hero":
		r.act(["flee"])
	_check_s("Schurke (Gerissenheit)", r.outcome, "FLED" if "CUNNING_ACTION" in rogue.skills else "ONGOING")
	var b = _fight(sheet, ["hobgoblin_captain"], 1)
	_check_s("Flucht vor Grak", str(b.can_flee(b.by_id("hero"))), "false")


func _ones() -> Array:
	return range(200).map(func(_i): return 1)


func _openings() -> void:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var a = _fight(sheet, ["wolf", "wolf"], 3, "AMBUSHED")
	_check_s("Hinterhalt: Gegner zuerst", ",".join(a.order.map(func(x): return x.side)), "FOES,FOES,PARTY")
	var h = _fight(sheet, ["wolf", "wolf"], 3, "HERO_FIRST")
	_check_s("Von hinten: Held zuerst", ",".join(h.order.map(func(x): return x.side)), "PARTY,FOES,FOES")
	var heard := []
	h.listener = func(e): heard.append(e.text)
	h.start()
	h.act(["wait"])
	var still := heard.filter(func(x): return "überrascht" in x).size()
	_check_s("Von hinten: Gegner verlieren den ersten Zug", str(still), "2")


func _check_s(what: String, got: String, want: String) -> void:
	if got != want:
		failed += 1
		print("FEHLER %s: %s statt %s" % [what, got, want])
	else:
		print("gleich %s: %s" % [what, got])


func _statuses() -> void:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	# a critical hit with a blade makes bleed 3 turns (2 left after the wolf's own turn) (hero 20, wolf 1; then the blow 20)
	var c = _fight(sheet, ["wolf"], [20, 1] + _ones())
	c.start()
	c.dice.tape = [20] + _ones()
	c.dice.pos = 0
	c.act(["attack", "f0"])
	_check_s("Krit mit Klinge: blutet", str(c.by_id("f0").status), str({"BLEED": 2}))
	# bleeding hurts at the start of its turn (1d4 + level / 3), then counts down; the line names it
	var b = _fight(sheet, ["wolf"], [20, 1] + _ones())
	var heard := []
	b.listener = func(e): heard.append(e)
	b.by_id("f0").status["BLEED"] = 3
	b.start()
	b.act(["wait"])
	var bled: Array = heard.filter(func(e): return "verliert Blut" in e.text)
	_check_s("Blutung schadet", str(bled.map(func(e): return e.damage)), "[2]")
	_check_s("Blutung zählt herunter", str(b.by_id("f0").status), str({"BLEED": 2}))
	_check_s("Zeichen im Ereignis", str(bled[0].status.get("f0", {})), str({"BLEED": 2}))
	# bleeding to death ends the fight
	var d = _fight(sheet, ["wolf"], [20, 1] + _ones())
	d.by_id("f0").hp = 2
	d.by_id("f0").status["BLEED"] = 3
	d.start()
	d.act(["wait"])
	_check_s("Verblutet: Sieg", d.outcome, "WON")
	# a stunned hero loses the turn, and is not stunned again for three turns
	var s = _fight(sheet, ["wolf"], [20, 1] + _ones())
	var lines := []
	s.listener = func(e): lines.append(e.text)
	var hero = s.by_id("hero")
	hero.status["STUN"] = 1
	hero.stun_guard = 3
	s.start()
	_check_s("Betäubt: Zug verloren", str(lines.filter(func(x): return "kann nicht handeln" in x).size()), "1")
	_check_s("Betäubt: dann wieder dran", str(s.current() == hero and s.outcome == "ONGOING"), "true")
	_check_s("Betäubt: Schutz vor neuer Betäubung", str(s._inflict(hero, "STUN", 1)), "false")
	# slowed: −2 on armor class and attack; weakened: −2 on attack and damage
	var w = _fight(sheet, ["wolf"], 1)
	var foe = w.by_id("f0")
	var ac: int = foe.ac()
	foe.status["SLOW"] = 2
	_check_s("Verlangsamt: RK −2", str(ac - foe.ac()), "2")
	foe.status["WEAK"] = 2
	_check_s("Verlangsamt und geschwächt: Angriff −4", str(w._penalty(foe)), "4")
	# a foe immune to it takes none; a boss shakes off a stun half the time
	var i = _fight(sheet, ["wolf"], 1)
	var im = i.by_id("f0")
	im.monster = im.monster.duplicate()
	im.monster["immune"] = ["BLEED"]
	_check_s("Immun gegen Blutung", str(i._inflict(im, "BLEED", 3)), "false")
	var g = _fight(sheet, ["hobgoblin_captain"], 1)
	_tape(g, [0])
	_check_s("Boss schüttelt Betäubung ab", str(g._inflict(g.by_id("f0"), "STUN", 1)), "false")
	# a dwarf resists poison half the time, a save above the DC resists it
	var dw: Dictionary = sheet.duplicate(true)
	dw["race"] = "DWARF"
	var z = _fight(dw, ["wolf"], 1)
	_tape(z, [0])
	_check_s("Zwerg widersteht Gift", str(z._inflict(z.by_id("hero"), "POISON", 3)), "false")
	var sv = _fight(sheet, ["wolf"], 1)
	_tape(sv, [20])
	_check_s("Rettungswurf gelingt", str(sv._inflict(sv.by_id("hero"), "POISON", 3, ["CON", 11])), "false")
	var fl = _fight(sheet, ["wolf"], 1)
	_tape(fl, [1, 999])
	_check_s("Rettungswurf misslingt", str(fl._inflict(fl.by_id("hero"), "POISON", 3, ["CON", 11])), "true")


## The next numbers of [m]'s dice, from here on.
func _tape(m, numbers: Array) -> void:
	m.dice.tape = numbers
	m.dice.pos = 0


func _no_life() -> void:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var m = _fight(sheet, ["wolf", "wolf"], 1)
	m.all[0].hp = 0
	_check_s("Held ohne LP darf nicht kämpfen", str(Mars.can_fight([m.all[0]])), "false")
	m.start()
	_check_s("Held ohne LP: Kampf endet sofort", m.outcome, "LOST")
	var k = Kampfort.new()
	_check_s("Kampfort nimmt Held ohne LP nicht", str(k.setup([m.all[0]], m.all.slice(1), tables, {}, Callable())), "false")
	k.free()
	_check_s("Held mit LP darf kämpfen", str(Mars.can_fight([_fight(sheet, ["wolf"], 1).all[0]])), "true")


## A won fight of the probe's fighter (level 3) against [foe_ids], the hero's experience [xp] before, from [tape].
func _won(foe_ids: Array, xp: int, tape: Array, level := 3) -> Dictionary:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	sheet.level = level
	var m = _fight(sheet, foe_ids, 1)
	m.test_end(true)
	return Lohn.reward(m, xp, Wuerfel.new(tape))


func _rewards() -> void:
	# a leader wolf and two of its pack: 50 × (1 + 0,3 × 2) = 80 EP; gold 1W6 (4); potion no (500), meat yes (100), pelt yes (0)
	var r := _won(["wolf", "wolf", "wolf"], 450, [4, 500, 100, 0])
	_check_s("Rudel: EP", str(r.xp), "80")
	_check_s("Rudel: Gold", str(r.gold), "4")
	_check_s("Rudel: Beute", str(r.items), "[\"raw_meat\", \"wolf_pelt\"]")
	_check_s("Rudel: Zeilen", " | ".join(r.lines), "Ansgar erhält 80 EP. | Du erbeutest 4 Gold. | Beute: Rohes Fleisch! | Beute: Wolfsfell!")
	# over the threshold of level 4 (1350): level up, full again, two ability points
	var up := _won(["wolf"], 1300, [1, 999, 999, 999])
	_check_s("Aufstieg: Stufe", str(up.level), "4")
	_check_s("Aufstieg: Zeilen", " | ".join(up.lines.filter(func(l): return not l.begins_with("Neue"))),
		"Ansgar erhält 50 EP. | Du erbeutest 1 Gold. | Ansgar erreicht Stufe 4! | TP und ZP von Ansgar sind vollständig aufgefüllt! | +2 Attributspunkt(e) – verteile sie im Menü.")
	# at the cap of chapter 1 (level 6, 7000 EP) nothing more, and it is said
	var cap := _won(["wolf"], 7000, [1, 999, 999, 999], 6)
	_check_s("Höchststufe: EP", str(cap.xp), "0")
	_check_s("Höchststufe: Zeile", str(cap.lines[0]), Lohn.CAPPED[0])
	# just below the cap: only what was missing counts
	var near := _won(["wolf"], 6980, [1, 999, 999, 999], 5)
	_check_s("Kurz vor Höchststufe: EP", "%d, Stufe %d" % [near.xp, near.level], "20, Stufe 6")
	# Grak's called goblins are worth nothing: the captain alone, 450 EP
	var g = _fight(tables.probe.FIGHTER.hero.hero.duplicate(true), ["hobgoblin_captain", "goblin"], 1)
	g.all[2].called_in = true
	g.test_end(true)
	_check_s("Grak mit Gerufenem: EP", str(Lohn.reward(g, 0, Wuerfel.new([1] + _ones())).xp), "450")
