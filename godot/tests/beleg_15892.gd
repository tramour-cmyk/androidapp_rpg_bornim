# 1589.2 Beleglauf (kein Logiktest): Wolfsrudel (Leitwolf mit Jungwölfen, aufruf.gd rudel) und Goblins (zwei Goblins, Späher,
# Schamane), Gruppe Held vorn links, Söldner vorn rechts, Magierin hinten (wenig Leben). Je Gegnerzug das angesagte Ziel, einmal
# mit der alten Wahl (arena_an false: dice.pick aus der vorderen Reihe) und einmal über die Arena; die Gruppe schlägt je Runde den
# vordersten Gegner mit festem Schaden (im Zug des Helden), danach enden die Züge von Held, Söldner, Magierin, damit Flucht und Fall
# vorkommen und eine angesagte Flucht erst nach dem Zug der Gruppe gilt (Prüfer 22.11., 19:42).
# Run: godot --headless --path godot -s res://tests/beleg_15892.gd
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Aufruf = preload("res://kampf/aufruf.gd")

var tables: Dictionary


func _initialize() -> void:
	tables = Tabellen.lade()
	for art in ["rudel", "goblins"]:
		for saat in [1, 2]:
			var alt := _lauf(art, saat, false)
			var neu := _lauf(art, saat, true)
			print("== %s Saat %d" % [art, saat])
			for i in maxi(alt.size(), neu.size()):
				print("  %-34s | %s" % [alt[i] if i < alt.size() else "", neu[i] if i < neu.size() else ""])
	quit(0)


func _monster(id: String) -> Dictionary:
	for m in tables.monsters:
		if m.id == id:
			return m
	return {}


func _held(id: String, platz: Vector2i, hp := 999):
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	return Mars.hero_fighter(id, "PARTY", platz, sheet, hp, sheet.second, skills)


func _lauf(art: String, saat: int, arena: bool) -> Array:
	var d := Wuerfel.new(saat)
	var foes: Array
	if art == "rudel":
		var mons := {}
		for m in tables.monsters:
			mons[m.id] = m
		foes = Aufruf.rudel(mons, d)
	else:
		foes = []
		for i in 4:
			var id: String = ["goblin", "goblin", "goblin_archer", "goblin_shaman"][i]
			foes.append(Mars.monster_fighter("%s%d" % [id, i], Mars.SPOTS[i], _monster(id), 18))
	var party := [_held("hero", Vector2i(Mars.FRONT, 0)), _held("merc", Vector2i(Mars.FRONT, 1)), _held("mage", Vector2i(Mars.BACK, 0))]
	var m = Mars.new(party, foes, tables, d, Wuerfel.new(7))
	m.arena_an = arena
	m.by_id("mage").hp = 6
	m.chosen = true
	var zeilen := [("NEU (Arena)" if arena else "ALT (dice.pick)")]
	for runde in 6:
		for f in m.all.filter(func(x): return x.side == "FOES" and x.standing()):
			if m.outcome != "ONGOING":
				break
			var p = m.intents.get(f.id, null)
			var was := "-" if p == null else String(p[0].id)
			var wen := "" if p == null or p[1].is_empty() else String(p[1][0])
			zeilen.append("R%d %s: %s %s" % [runde + 1, f.id, was, wen])
			m._foe_turn(f, Callable())
			if was == "flee" and f.standing():
				zeilen.append("   %s bleibt (Gruppe seit Ansage noch nicht am Zug)" % f.id)
		if m.outcome != "ONGOING":
			break
		var vorn = null
		for f in m.all.filter(func(x): return x.side == "FOES" and x.standing() and x.angreifbar()):
			if vorn == null or (f.place.x < vorn.place.x):
				vorn = f
		m.turn = m.order.find(m.by_id("hero"))
		if vorn != null:
			m._hurt(vorn, 14, "hero", "")
			zeilen.append("R%d Gruppe trifft %s (%s)" % [runde + 1, vorn.id, "fällt" if vorn.hp <= 0 else "%d Leben" % vorn.hp])
		for p in ["hero", "merc", "mage"]:     # die Züge der Gruppe enden (Held zuerst, in dessen Zug der Treffer fiel)
			m.turn = m.order.find(m.by_id(p))
			m._next_turn()
	for f in m.all.filter(func(x): return x.side == "FOES" and x.fled):
		zeilen.append("geflohen: %s%s" % [f.id, " (von selbst)" if f.von_selbst else ""])
	zeilen.append("Ausgang " + m.outcome)
	return zeilen
