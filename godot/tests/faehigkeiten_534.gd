# 534 (Abgleich 512 zu Build 249, Sokrates): was der alte Weltkampf (Battle.kt) konnte und MARS fehlte, Teil 1 ohne Zauber:
# Unerbittlichkeit der Orkblütigen (einmal je Kampf mit 1 TP stehen), Einschüchtern zu Kampfbeginn (8 % je
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
	tab =Tabellen.lade()
	for m in tab.monsters:
		monsters[m.id] = m
	for s in tab.skills:
		skills[s.id] = s
	# 870.6: Lebensraub und Schadensminderung der Ausrüstung entfallen (DESIGN-BRS.md 11), ihre Prüfungen mit ihnen
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
	m.brs_einrichten()     # 870.5: nur nach dem BRS; der Held bleibt bei 999 Leben
	h.max_hp = 999
	h.hp = 999
	return m


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
