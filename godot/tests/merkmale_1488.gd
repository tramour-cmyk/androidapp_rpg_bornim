# 1488 (1411b A, Chef 16.11., 20:59; DESIGN-BRS.md „Merkmale je Exemplar“): beim Kampfbeginn zieht jedes Exemplar höchstens ein
# Merkmal (etwa die Hälfte gewöhnlich), Bosse und Ockerschleim nie, kleine Gegner (Riesenratte, Riesenfledermaus) nur Leben; die
# Faktoren wirken auf Leben, Angriff, Abwehr, Schaden; dieselbe Saat gibt dieselben Merkmale, die Würfel des Kampfs bleiben gleich;
# die Anzeige nach Lesestufe: 0 nichts, 1 Pfeil, 2 Name, 3 Name und Wirkung.
# Run: godot --headless --path godot -s res://tests/merkmale_1488.gd   (Exit 0 = gut)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const KampfUi = preload("res://kampf/kampf_ui.gd")
const BrsKampf = preload("res://regeln/brs_kampf.gd")

var tables: Dictionary
var fehler := 0


func _initialize() -> void:
	tables = Tabellen.lade()
	var E: Dictionary = BrsKampf.w()["merkmale"]["exemplar"]
	for art in ["wolf", "giant_rat", "goblin", "skeleton", "ochre_jelly", "dire_wolf", "giant_bat"]:
		var m := _monster(art)
		if m.is_empty():
			_falsch("%s fehlt in den Tabellen" % art)
			continue
		var mit := 0
		var n := 0
		var namen := {}
		var boss := false
		var gruppe := ""
		for saat in 200:
			var x = _fight(m, 500 + saat)
			var y = _fight(m, 500 + saat)
			var st0: int = x.dice.rng.state
			x.brs_einrichten()
			y.brs_einrichten()
			if x.dice.rng.state != st0:
				_falsch("%s Saat %d: das Ziehen verbraucht Würfel des Kampfs" % [art, saat])
			for i in 3:
				var f = x.by_id("f%d" % i)
				var g = y.by_id("f%d" % i)
				n += 1
				boss = bool(f.b.get("boss", false))
				var a: String = x.merkmal_art(f)
				for gn in E.gruppen:
					if a in E.gruppen[gn].arten:
						gruppe = gn
				if String(f.b.get("merkmal", "")) != String(g.b.get("merkmal", "")):
					_falsch("%s Saat %d: gleiche Saat, anderes Merkmal" % [art, saat])
				if not f.b.has("merkmal"):
					continue
				mit += 1
				namen[f.b.merkmal] = true
				var basis: Dictionary = BrsKampf.gegner(f.monster)
				var fak: Dictionary = f.b.merkmal_fak
				if f.max_hp != maxi(1, roundi(float(basis.leben) * float(fak.get("leben", 1.0)))):
					_falsch("%s %s: Leben %d statt %s × %s" % [art, f.b.merkmal, f.max_hp, basis.leben, fak.get("leben", 1.0)])
				for k in ["angriff", "abwehr", "schaden"]:
					if absf(float(f.b[k]) - float(basis[k]) * float(fak.get(k, 1.0))) > 0.001:
						_falsch("%s %s: %s %s statt %s × %s" % [art, f.b.merkmal, k, f.b[k], basis[k], fak.get(k, 1.0)])
				if gruppe == "klein" and fak.keys() != ["leben"]:
					_falsch("%s: kleiner Gegner mit %s" % [art, fak.keys()])
		var anteil := float(mit) / maxf(1.0, n)
		if boss or gruppe == "":
			if mit > 0:
				_falsch("%s (Boss %s, Gruppe „%s“): %d Merkmale, erwartet keins" % [art, boss, gruppe, mit])
		elif absf(anteil - (1.0 - float(E.gewoehnlich))) > 0.08 or namen.size() < 4:
			_falsch("%s: %.0f %% mit Merkmal, %d Namen" % [art, anteil * 100.0, namen.size()])
		print("gut %s (%s): %d von %d mit Merkmal, %s" % [art, gruppe if gruppe != "" else ("Boss" if boss else "ohne"), mit, n, ", ".join(namen.keys())])
	# Anzeige nach Lesestufe
	var fj := {"leben": 0.85, "angriff": 0.90, "abwehr": 1.10}
	var soll := [[0, ""], [1, " ▼"], [2, " · jung"], [3, " · jung (Leben −15 %, Angriff −10 %, Abwehr +10 %)"]]
	for z in soll:
		var ist: String = KampfUi.merkmal_zusatz("jung", fj, z[0], 0)
		if ist != z[1]:
			_falsch("Stufe %d: „%s“ statt „%s“" % [z[0], ist, z[1]])
	if KampfUi.merkmal_zusatz("kräftig", {"leben": 1.15, "schaden": 1.15}, 1, 0) != " ▲":
		_falsch("Stufe 1 kräftig ohne ▲")
	print("MERKMALE1488 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)


func _falsch(t: String) -> void:
	fehler += 1
	print("FALSCH " + t)


func _monster(id: String) -> Dictionary:
	for m in tables.monsters:
		if m.id == id:
			return m
	return {}


func _fight(m: Dictionary, saat: int):
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var foes := []
	for i in 3:
		foes.append(Mars.monster_fighter("f%d" % i, Mars.SPOTS[i], m, 30))
	return Mars.new([hero], foes, tables, Wuerfel.new(saat), Wuerfel.new(7))
