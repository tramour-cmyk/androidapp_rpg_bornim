# 348.7: rules the Kotlin MARS lacked and the port adds (Test 89.2), checked by counting the hero's attack rolls.
# Run: godot --headless --path godot -s res://tests/mars_regeln.gd   (exit code 0 = all as the SRD says)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

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
