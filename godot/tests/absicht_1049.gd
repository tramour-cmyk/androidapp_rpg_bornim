# 1049 (Sokrates 12.11.): die Absichten je Art aus werte.json „absichten“ statt aus Zweigen in mars.gd. Gegenprobe: die alte Wahl
# (hier als _alt nachgebaut, mars.gd vor 1049) und die neue geben bei gleichem Würfel und gleicher Lage dieselbe Absicht und
# verbrauchen gleich viel Zufall; jede Art des Spiels, je 300 Lagen (versteckt, Leben, gewählt, gerufen, kreisend, Reihe).
# Run: godot --headless --path godot -s res://tests/absicht_1049.gd   (Exit 0 = gleich)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

var tables: Dictionary


func _initialize() -> void:
	tables = Tabellen.lade()
	var arten := ["wolf", "dire_wolf", "giant_rat", "giant_bat", "ghoul", "zombie", "giant_spider", "goblin_archer", "goblin",
		"goblin_shaman", "hobgoblin_captain", "bugbear", "boar", "kobold", "skeleton", "giant_centipede", "stirge", "ochre_jelly"]
	var fehler := 0
	var n := 0
	for art in arten:
		var m := _monster(art)
		if m.is_empty():
			print("FEHLT %s in den Tabellen" % art)
			continue
		var gesehen := {}
		for k in 300:
			var a = _fight(m, 1000 + k)
			var b = _fight(m, 1000 + k)
			var lage := RandomNumberGenerator.new()
			lage.seed = k
			for x in [a, b]:
				_lage(x, lage.seed)
			var ia: Dictionary = _alt(a, a.by_id("f0"))
			var ib: Dictionary = b._pick_intent(b.by_id("f0"))
			n += 1
			gesehen[String(ib.id)] = true
			if String(ia.id) != String(ib.id) or a.dice.rng.state != b.dice.rng.state:
				fehler += 1
				if fehler < 10:
					print("FALSCH %s Lage %d: alt %s, neu %s, Zufall gleich %s" % [art, k, ia.id, ib.id, a.dice.rng.state == b.dice.rng.state])
		print("gut %s: %s" % [art, ", ".join(gesehen.keys())] if true else "")
	print("ABSICHT1049 %d Wahlen, %d abweichend" % [n, fehler])
	quit(1 if fehler > 0 else 0)


func _monster(id: String) -> Dictionary:
	for m in tables.monsters:
		if m.id == id:
			return m
	return {}


## Held und drei Gegner der Art [m] (f0 vorn, f1 vorn, f2 hinten), Würfel mit fester Saat
func _fight(m: Dictionary, saat: int):
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var merc := Mars.hero_fighter("merc", "PARTY", Vector2i(Mars.BACK, 1), sheet, 999, sheet.second, skills)
	var foes := []
	for i in 3:
		foes.append(Mars.monster_fighter("f%d" % i, Mars.SPOTS[i], m, 30))
	return Mars.new([hero, merc], foes, tables, Wuerfel.new(saat), Wuerfel.new(7))


## dieselbe zufällige Lage in beiden Kämpfen
func _lage(x, saat: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = saat
	var f0 = x.by_id("f0")
	f0.hidden = r.randf() < 0.5
	f0.hp = r.randi_range(1, f0.max_hp)
	x.chosen = r.randf() < 0.6
	x.called = r.randi_range(0, 1)
	if r.randf() < 0.3:
		x.by_id("f1").hp = 0
	if r.randf() < 0.3:
		x.by_id("f2").hp = 0
	if r.randf() < 0.5:
		x.by_id("merc").hp = 0     # ohne Söldner hinten keine Reihe
	if r.randf() < 0.3:
		x.intents["f1"] = [x.I_CIRCLE, []]


## mars.gd _pick_intent vor 1049, wortgleich bis auf [m.]
func _alt(m, foe) -> Dictionary:
	var id: String = Mars.art_of(foe.monster)
	if id == Mars.RAT or id == Mars.BAT or id == "ghoul":
		return m.I_BITE
	if id == "zombie":
		return m.I_CLAW
	if id == Mars.SHAMAN:
		id = Mars.CALLED
	if id == Mars.WOLF or id == Mars.DIRE_WOLF:
		var others: int = m.all.filter(func(x): return x.side == "FOES" and x.standing() and m.wolfig(x.monster)).size()
		var circling: bool = m.intents.values().any(func(p): return p[0].effect == "CIRCLE")
		var can := [m.I_POUNCE, m.I_POUNCE]
		if others >= 2 and not circling and m.chosen and foe.angreifbar():
			can.append(m.I_CIRCLE)
		return m.dice.pick(can)
	if id == Mars.SPIDER:
		return m.dice.pick([m.I_VENOM, m.I_WEB])
	if id == Mars.SCOUT:
		return m.I_AIM if foe.hidden else m.dice.pick([m.I_AIM, m.I_AIM, m.I_SHADOW])
	var lineup: bool = not m._covered().is_empty()
	var plain: Dictionary = m.I_SLASH if id == Mars.CALLED else m.I_STAB
	if id == Mars.CALLED:
		var can2 := [plain, plain]
		if lineup:
			can2.append(m.I_FLANK)
		return m.dice.pick(can2)
	if id != Mars.GRAK:
		return plain
	var can3 := [m.I_HEAVY, m.I_HEAVY]
	if lineup:
		can3.append(m.I_BREAKTHROUGH)
	if m.called < Mars.CALL_MAX and m._free_foe_spot() != null:
		can3.append(m.I_CALL)
	if foe.hp * 2 < foe.max_hp:
		can3.append(m.I_GATHER)
	return m.dice.pick(can3)
