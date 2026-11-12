# 535 (Abgleich 512 zu Build 249, Sokrates: „Ratten und Fledermäuse als Wölfe, Schamane ohne Heilen“): Riesenratten,
# Riesenfledermäuse, Kobolde und Goblin-Schamanen kämpfen mit den Werten, dem Namen und dem Lohn ihrer eigenen Art (alt
# Monsters.kt), im Körper von Wolf und Goblin; Ratte und Fledermaus beißen nur (kein Anspringen, kein Einkreisen, kein Umwerfen),
# die Fledermaus weicht einem Nahkampfhieb zu 20 % aus und blendet zu 20 % (EVASIVE), Kobolde zählen als Rudel (je 0,4).
# Prüfung ohne Grafik. Aufruf: im Ordner godot mit -s res://tests/gruppen_535.gd (Exit 0 = richtig)
extends SceneTree

const AufrufS = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Lohn = preload("res://regeln/lohn.gd")

var fehler := 0
var tab: Dictionary
var monsters := {}
var skills := {}


func _initialize() -> void:
	tab = Tabellen.lade()
	for m in tab.monsters:
		monsters[m.id] = m
	for s in tab.skills:
		skills[s.id] = s
	_werte()
	_ansagen()
	_flattern()
	_blenden()
	_lohn()
	print("GRUPPEN_535 %d Fehler" % fehler)
	quit(1 if fehler else 0)


func _soll(gut: bool, was: String) -> void:
	print(("ok     " if gut else "FEHLER ") + was)
	if not gut:
		fehler += 1


func _kampf(gruppe: String, seed: int):
	var held: Dictionary = tab.probe.FIGHTER.hero.hero.duplicate(true)
	var h = Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), held, 999, held.second, skills)
	var foes: Array = AufrufS.gegner(gruppe, monsters, Wuerfel.new(seed))
	return Mars.new([h], foes, tab, Wuerfel.new(seed), Wuerfel.new(7))


func _werte() -> void:
	for c in [["RATS", "giant_rat", Mars.WOLF, "Riesenratte", 12, 25], ["BATS", "giant_bat", Mars.WOLF, "Riesenfledermaus", 13, 50],
			["KOBOLDS", "kobold", Mars.CALLED, "Kobold", 12, 25], ["SHAMANS", "goblin_shaman", Mars.CALLED, "Goblin-Schamane", 12, 100]]:
		_soll(monsters.has(c[1]), "tabellen.json kennt %s" % c[1])
		var foes: Array = AufrufS.gegner(c[0], monsters, Wuerfel.new(3))
		var f = foes[0]
		_soll(foes.size() == 3 and foes.all(func(x): return Mars.art_of(x.monster) == c[1] and x.monster.id == c[1] and Mars.koerper_of(x.monster) == c[2] and x.monster.de == c[3]),
			"%s: Kennung %s (577), Körper %s, Name %s" % [c[0], f.monster.id, Mars.koerper_of(f.monster), f.monster.de])
		# 870.6: RK und EP der alten Fassung gibt es nicht mehr (Werte nach BRS: brs_473, Lohn: lohn_870)
	# Wölfe und Grimmzahn bleiben, wie sie waren
	var w: Array = AufrufS.gegner("WOLVES", monsters, Wuerfel.new(3))
	_soll(Mars.art_of(w[0].monster) == Mars.WOLF and Mars.koerper_of(w[0].monster) == Mars.WOLF and not w[0].monster.has("koerper"), "Wölfe im eigenen Körper")


func _ansagen() -> void:
	for c in [["RATS", ["bite"]], ["BATS", ["bite"]], ["KOBOLDS", ["stab"]], ["SHAMANS", ["slash", "flank"]], ["WOLVES", ["pounce", "circle"]]]:
		var m = _kampf(c[0], 5)
		m.chosen = true
		var ids := {}
		for i in 200:
			ids[String(m._pick_intent(m.all[1 + i % 3]).id)] = true
		var fremd: Array = ids.keys().filter(func(x): return not x in c[1])
		_soll(fremd.is_empty() and ids.has(c[1][0]), "%s sagt an: %s" % [c[0], ids.keys()])


func _hiebe(gruppe: String, fern: bool) -> Array:
	var m = _kampf(gruppe, 11)
	var gesagt := []
	m.listener = func(e): gesagt.append(String(e.text))
	var h = m.all[0]
	var ziel = m.all[1]
	ziel.monster.ac = 2     # trifft immer außer mit der 1
	var w: Dictionary = (h.hero.main as Dictionary).duplicate(true)
	w.ranged = fern
	var flattert := 0
	var treffer := 0
	for i in 2000:
		ziel.hp = 999
		gesagt.clear()
		m._weapon_attack(h, ziel, false, false, w)
		if gesagt.any(func(t): return "flattert davon" in t):
			flattert += 1
		elif ziel.hp < 999:
			treffer += 1
	return [flattert, treffer]


func _flattern() -> void:
	var nah := _hiebe("BATS", false)
	var anteil := float(nah[0]) / float(nah[0] + nah[1])
	_soll(anteil > 0.16 and anteil < 0.24, "Fledermaus weicht Nahkampf aus: %d von %d (%.0f %%)" % [nah[0], nah[0] + nah[1], anteil * 100])
	var fern := _hiebe("BATS", true)
	_soll(fern[0] == 0, "Fledermaus gegen Schüsse: %d ausgewichen" % fern[0])
	var ratte := _hiebe("RATS", false)
	_soll(ratte[0] == 0, "Ratte weicht nicht flatternd aus: %d" % ratte[0])


func _blenden() -> void:
	for c in [["BATS", true], ["RATS", false]]:
		var m = _kampf(c[0], 13)
		var h = m.all[0]
		var geblendet := 0
		for i in 1000:
			h.status.erase("BLIND")
			m._foe_wounds(m.all[1], h)
			if h.status.has("BLIND"):
				geblendet += 1
		_soll((geblendet > 20 and geblendet < 250) if c[1] else geblendet == 0, "%s blendet: %d von 1000" % [c[0], geblendet])
	# die Ratte wirft nicht um wie der Wolf (sein Sprung ist ein eigener Angriff, den sie nicht ansagt; geprüft in _ansagen)


func _lohn() -> void:
	# 870.5: nach dem BRS zählt jeder Gegner seiner Art (lohn.gd, Brs.erfahrung für den Probehelden der Stufe 3), drei je Gruppe
	for c in [["RATS", "giant_rat"], ["BATS", "giant_bat"], ["KOBOLDS", "kobold"], ["SHAMANS", "goblin_shaman"]]:
		var m = _kampf(c[0], 17)
		m.test_end(true)
		var r: Dictionary = Lohn.reward(m, {}, Wuerfel.new(1))
		var soll := roundi(3 * Brs.erfahrung(3, c[1]))
		_soll(int(r.xp) == soll and soll > 0, "%s: %s EP (soll %d)" % [c[0], r.xp, soll])
