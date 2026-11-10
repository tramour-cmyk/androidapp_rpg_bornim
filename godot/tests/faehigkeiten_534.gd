# 534 (Abgleich 512 zu Build 249, Sokrates): was der alte Weltkampf (Battle.kt) konnte und MARS fehlte, Teil 1 ohne Zauber:
# Lebensraub (Anteil des Schadens als Heilung, höchstens 30 %), Schadensminderung der Ausrüstung gegen Treffer der Gegner
# (nach dem BRS nicht unter 0), Unerbittlichkeit der Orkblütigen (einmal je Kampf mit 1 TP stehen), Einschüchtern zu Kampfbeginn (8 % je
# Charisma-Punkt, nie Boss, nie im Hinterhalt). Prüfung ohne Grafik.
# Aufruf: im Ordner godot mit -s res://tests/faehigkeiten_534.gd (Exit 0 = richtig)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

var fehler := 0
var tab: Dictionary
var monsters := {}
var skills := {}


func _initialize() -> void:
	tab =JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	for m in tab.monsters:
		monsters[m.id] = m
	for s in tab.skills:
		skills[s.id] = s
	_minderung()
	_lebensraub()
	_unerbittlich()
	_einschuechtern()
	print("FAEHIGKEITEN_534 %d Fehler" % fehler)
	quit(1 if fehler else 0)


func _soll(gut: bool, was: String) -> void:
	print(("ok     " if gut else "FEHLER ") + was)
	if not gut:
		fehler += 1


func _kampf(extra: Dictionary, foe_ids: Array, seed: int, opening := "NORMAL"):
	var held: Dictionary = tab.probe.FIGHTER.hero.hero.duplicate(true)
	held.merge(extra, true)
	var h = Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), held, 999, held.second, skills)
	var foes := []
	for i in foe_ids.size():
		foes.append(Mars.monster_fighter("f%d" % i, Mars.SPOTS[i], monsters[foe_ids[i]], 999))
	var m = Mars.new([h], foes, tab, Wuerfel.new(seed), Wuerfel.new(7), 0, false, opening)
	m.chosen = true
	m.brs_einrichten()     # 870.5: nur nach dem BRS; der Held bleibt bei 999 Leben im Maß 1, so zählen Minderung und Raub wie gesetzt
	h.max_hp = 999
	h.hp = 999
	h.srd_hp = 999
	return m


func _bisse(reduction: int) -> Array:
	var m = _kampf({"reduction": reduction}, ["wolf"], 21)
	var h = m.all[0]
	var out := []
	for i in 300:
		h.hp = 999
		m._strike(m.all[1], h, m.I_STAB, Mars.NONE)
		out.append(999 - h.hp)
	return out


func _minderung() -> void:
	var ohne := _bisse(0)
	var mit := _bisse(3)
	var gut := true
	var treffer := 0
	for i in ohne.size():
		if ohne[i] > 0:
			treffer += 1
			gut = gut and mit[i] == maxi(0, ohne[i] - 3)     # 478: nach dem BRS kein Mindestschaden
		else:
			gut = gut and mit[i] == 0
	_soll(gut and treffer > 50, "Schadensminderung 3: jeder Biss 3 weniger, nicht unter 0 (%d Treffer)" % treffer)


func _lebensraub() -> void:
	var m = _kampf({"lifesteal": 20}, ["wolf"], 5)
	var h = m.all[0]
	var gut := true
	var geheilt := 0
	for i in 300:
		h.hp = 500
		m.all[1].hp = 999
		m._weapon_attack(h, m.all[1])
		var dealt: int = 999 - m.all[1].hp
		var soll: int = maxi(1, dealt * 20 / 100) if dealt > 0 else 0
		gut = gut and h.hp - 500 == soll
		if soll > 0:
			geheilt += 1
	_soll(gut and geheilt > 50, "Lebensraub 20 %%: Heilung = Schaden × 0,2, mindestens 1 (%d Treffer)" % geheilt)
	var voll = _kampf({"lifesteal": 20}, ["wolf"], 5)
	var hv = voll.all[0]
	hv.hp = hv.max_hp
	voll.all[1].hp = 999
	for i in 20:
		voll._weapon_attack(hv, voll.all[1])
	_soll(hv.hp == hv.max_hp, "Lebensraub heilt nicht über das Höchstmaß")


func _unerbittlich() -> void:
	var m = _kampf({"race": "HALF_ORC"}, ["wolf"], 3)
	var h = m.all[0]
	h.hp = 4
	m._hurt(h, 10, "f0", "x")
	_soll(h.hp == 1 and m.outcome == "ONGOING", "Orkblütig: erster tödlicher Treffer lässt 1 TP (%d, %s)" % [h.hp, m.outcome])
	m._hurt(h, 10, "f0", "x")
	_soll(h.hp == 0 and m.outcome == "LOST", "Orkblütig: der zweite fällt ihn (%d, %s)" % [h.hp, m.outcome])
	var mensch = _kampf({"race": "HUMAN"}, ["wolf"], 3)
	mensch.all[0].hp = 4
	mensch._hurt(mensch.all[0], 10, "f0", "x")
	_soll(mensch.all[0].hp == 0, "Mensch fällt gleich")


func _eingeschuechtert(cha: int, foes: Array, opening: String) -> int:
	var n := 0
	for s in 400:
		var m = _kampf({"cha": cha}, foes, 100 + s, opening)
		m._cow()
		n += m.surprised.size() - (foes.size() if opening == "HERO_FIRST" else 0)
	return n


func _einschuechtern() -> void:
	var n := _eingeschuechtert(5, ["wolf", "wolf"], "NORMAL")
	_soll(n > 120 and n < 200, "Charisma +5: %d von 400 Kämpfen ein Gegner eingeschüchtert (soll etwa 160)" % n)
	_soll(_eingeschuechtert(0, ["wolf"], "NORMAL") == 0, "ohne Charisma nie")
	_soll(_eingeschuechtert(5, ["dire_wolf"], "NORMAL") == 0, "nie ein Boss")
	_soll(_eingeschuechtert(5, ["wolf"], "AMBUSHED") == 0, "nie im Hinterhalt")
