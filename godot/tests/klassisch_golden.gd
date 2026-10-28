# 390: spielt die klassischen Kämpfe aus core ClassicGoldenTest mit denselben Zahlen nach und prüft, dass der Port
# (regeln/klassisch.gd) dasselbe sagt, Schritt für Schritt, mit denselben Zahlen danach.
# Run: godot --headless --path godot -s res://tests/klassisch_golden.gd   (exit code 0 = alles gleich)
extends SceneTree

const Klassisch = preload("res://regeln/klassisch.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")


func _init() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden/klassisch.json"))
	var failed := 0
	var lines := 0
	for c in data.cases:
		var r := _replay(c, data.tables)
		lines += r.lines
		if r.error != "":
			failed += 1
			print("ABWEICHUNG ", c.name, ": ", r.error)
	print("Klassisch golden: %d Kämpfe, %d Zeilen, %d abweichend" % [data.cases.size(), lines, failed])
	quit(1 if failed > 0 else 0)


static func _n(v) -> String:
	return str(int(v))


## Ein Schritt des Ports in der Form, die ClassicGoldenTest.step schreibt.
static func _form(s: Dictionary) -> Dictionary:
	var o := {"t": s.t, "n": "%d %d %d %d %d" % [s.hh, s.eh, s.sp, s.p, s.pa]}
	if s.a != "NONE":
		o["a"] = s.a
	if s.lead:
		o["lead"] = true
	if s.heavy:
		o["heavy"] = true
	if s.fx != null:
		var f := [s.fx.kind, "hero" if s.fx.on_hero else "foe"]
		if s.fx.crit:
			f.append("crit")
		if s.fx.past != null:
			f.append(s.fx.past)
		o["fx"] = f
	if s.rar != null:
		o["rar"] = s.rar
	if s.item != null:
		o["item"] = s.item
	if s.roll != null:
		o["r"] = s.roll
	if not s.sh.is_empty():
		o["sh"] = " ".join(s.sh.keys().map(func(k): return "%s=%d" % [k, s.sh[k]]))
	if not s.sf.is_empty():
		o["sf"] = " ".join(s.sf.keys().map(func(k): return "%s=%d" % [k, s.sf[k]]))
	return o


static func _same(a, b) -> bool:
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for i in a.size():
			if not _same(a[i], b[i]):
				return false
		return true
	if (a is float or a is int) and (b is float or b is int):
		return is_equal_approx(float(a), float(b))
	if a is bool or b is bool:
		return bool(a) == bool(b) and typeof(a) == typeof(b)
	return str(a) == str(b)


func _replay(c: Dictionary, tables: Dictionary) -> Dictionary:
	var k = Klassisch.new()
	var d = Wuerfel.new(c.dice)
	var after: Dictionary = c.after
	k.max_after = func(_l): return [int(after.maxHp), int(after.maxSp)]
	k.gear_drops = c.gear
	var st: Dictionary = c.state.duplicate(true)
	st["gold"] = 0
	k.setup(c.hero.duplicate(true), st, c.monster, d, int(c.level), int(c.area), c.opening, c.pack, int(c.packSize), c.kitAttack, tables)
	var lines := 0
	for step in c.steps:
		var got: Array
		match step["do"][0]:
			"start":
				got = k.start()
			"testEnd":
				got = k.test_end(true)
			"attack", "defend", "wait", "flee":
				got = k.act([step["do"][0]])
			_:
				got = k.act(step["do"])
		var want: Array = step.st
		for i in maxi(got.size(), want.size()):
			lines += 1
			if i >= got.size():
				return {"lines": lines, "error": "%s: fehlt %s" % [step["do"], want[i]]}
			if i >= want.size():
				return {"lines": lines, "error": "%s: zu viel %s" % [step["do"], _form(got[i])]}
			var g := _form(got[i])
			var w: Dictionary = want[i]
			for key in ["t", "n", "a", "lead", "heavy", "fx", "rar", "item", "r", "sh", "sf"]:
				if g.has(key) != w.has(key) or (g.has(key) and not _same(g[key], w[key])):
					return {"lines": lines, "error": "%s Schritt %d %s: %s statt %s (Text „%s“)" % [step["do"], i, key, g.get(key), w.get(key), w.t]}
		if d.fault != "":
			return {"lines": lines, "error": "%s: Würfel %s" % [step["do"], d.fault]}
	if k.outcome != c.outcome:
		return {"lines": lines, "error": "Ausgang %s statt %s" % [k.outcome, c.outcome]}
	return {"lines": lines, "error": ""}
