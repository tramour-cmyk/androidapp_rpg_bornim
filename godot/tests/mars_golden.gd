# 348.7: replays the MARS fights recorded in the Kotlin core (core MarsGoldenTest, tools/godot/mars-golden.sh) with
# the same numbers and checks the GDScript port says the same, message for message, with the same state after each.
# Run: godot --headless --path godot -s res://tests/mars_golden.gd   (exit code 0 = all the same)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")


func _init() -> void:
	var tables: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var cases: Array = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden/kaempfe.json"))
	var failed := 0
	var lines := 0
	for c in cases:
		print("spiele ", c.name)
		var r := _replay(c, tables)
		lines += r.lines
		if r.error != "":
			failed += 1
			print("FEHLER ", c.name, ": ", r.error)
		else:
			print("gleich ", c.name, " (", r.lines, " Zeilen, ", c.outcome, ")")
	print("MARS golden: %d Kämpfe, %d Zeilen, %d abweichend" % [cases.size(), lines, failed])
	quit(1 if failed > 0 or cases.is_empty() else 0)


static func _spot(s: Vector2i) -> String:
	return ("F" if s.x == Mars.FRONT else "B") + str(s.y)


static func _place(row: String, slot) -> Vector2i:
	return Vector2i(Mars.FRONT if row == "FRONT" or row == "F" else Mars.BACK, int(slot))


## The message as the Kotlin test writes it, through JSON so numbers compare alike.
static func _compact(e: Dictionary) -> String:
	var d := {"t": e.text}
	if e.actor != null:
		d["a"] = e.actor
	if e.target != null:
		d["g"] = e.target
	if e.damage != 0:
		d["d"] = e.damage
	if e.roll != null:
		d["r"] = e.roll
	if e.answer:
		d["ans"] = true
	if e.wound:
		d["w"] = true
	if e.spell != null:
		d["fx"] = e.spell
	if e.cue != null:
		d["cue"] = e.cue
	var s := []
	for id in e.hp:
		s.append("%s=%d@%s" % [id, e.hp[id], _spot(e.places[id])])
	d["s"] = " ".join(s)
	var i := []
	for id in e.intents:
		i.append("%s>%s:%s" % [id, e.intents[id][0].id, ",".join(e.intents[id][1])])
	d["i"] = " ".join(i)
	d["q"] = " ".join(e.queue)
	if e.sp.values().any(func(v): return v > 0):
		var sp := []
		for id in e.sp:
			sp.append("%s=%d" % [id, e.sp[id]])
		d["sp"] = " ".join(sp)
	return JSON.stringify(JSON.parse_string(JSON.stringify(d)), "", true)


static func _golden(e: Dictionary) -> String:
	return JSON.stringify(e, "", true)


func _replay(c: Dictionary, tables: Dictionary) -> Dictionary:
	var dice = Wuerfel.new(c.dice)
	var words = Wuerfel.new(c.words)
	var monsters := {}
	var skills := {}
	for m in tables.monsters:
		monsters[m.id] = m
	for s in tables.skills:
		skills[s.id] = s
	var party := []
	var foes := []
	# Skirmish.probe rolls the foes' life points first, in their order
	for sh in c.fighters:
		if sh.has("monster"):
			var m: Dictionary = monsters[sh.monster]
			var hp: int = dice.roll_expr(m.hp)
			if hp != int(sh.hp):
				return {"error": "LP %s: %d statt %d" % [sh.id, hp, int(sh.hp)], "lines": 0}
			foes.append(Mars.monster_fighter(sh.id, _place(sh.row, sh.slot), m, hp))
	for sh in c.fighters:
		if sh.has("hero"):
			party.append(Mars.hero_fighter(sh.id, sh.side, _place(sh.row, sh.slot), sh.hero, int(sh.hp), sh.hero.second, skills))
	var mars = Mars.new(party, foes, tables, dice, words, 0, false)
	mars.srd_attacks = false
	mars.statuses = false
	for k in c.potions:
		mars.potions[k] = int(c.potions[k])
	var merc = mars.find("merc")
	merc.auto = c.mercAuto
	var heard := []
	mars.listener = func(e): heard.append(e)
	var rings: Array = c.rings
	var ring_at := [0]
	var react := func(_t, _i):
		var r: String = rings[ring_at[0]] if ring_at[0] < rings.size() else "NONE"
		ring_at[0] += 1
		return r
	var lines := 0
	for n in c.steps.size():
		var step: Dictionary = c.steps[n]
		var o: Array = step["do"]
		heard.clear()
		match o[0]:
			"quick":
				heard.append_array(mars.quick().events)
			"start":
				mars.start(react)
			"proceed":
				mars.proceed(react)
			"auto":
				merc.auto = o[2]
			"pilot":
				mars.set_autopilot(o[1])
			"testEnd":
				mars.test_end(o[1])
			"act":
				var order := []
				match o[1]:
					"swap":
						order = ["swap", _place(o[2][0], o[2].substr(1)), o[3]]
					"use":
						order = ["use", o[2], o[3]]
					_:
						order = o.slice(1)
				mars.act(order, react)
		var want: Array = step.ev
		for k in maxi(want.size(), heard.size()):
			var got: String = _compact(heard[k]) if k < heard.size() else "(keine Zeile)"
			var expect: String = _golden(want[k]) if k < want.size() else "(keine Zeile)"
			if got != expect:
				return {"error": "Schritt %d %s, Zeile %d:\n  erwartet %s\n  erhalten %s\n  Würfel %s" % [n, str(o), k, expect, got, dice.fault], "lines": lines}
			lines += 1
	if mars.outcome != c.outcome:
		return {"error": "Ausgang %s statt %s" % [mars.outcome, c.outcome], "lines": lines}
	if mars.knockouts != int(c.knockouts):
		return {"error": "Bewusstlose %d statt %d" % [mars.knockouts, int(c.knockouts)], "lines": lines}
	if dice.fault != "" or dice.pos != c.dice.size():
		return {"error": "Würfel: %d von %d verbraucht %s" % [dice.pos, c.dice.size(), dice.fault], "lines": lines}
	if words.fault != "" or words.pos != c.words.size():
		return {"error": "Fassungen: %d von %d verbraucht %s" % [words.pos, c.words.size(), words.fault], "lines": lines}
	if ring_at[0] != rings.size():
		return {"error": "Ringe: %d von %d" % [ring_at[0], rings.size()], "lines": lines}
	return {"error": "", "lines": lines}
