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
