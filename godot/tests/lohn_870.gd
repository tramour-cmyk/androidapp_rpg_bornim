# 870.5 (Umzug BRS Schritt 5): der Lohn eines gewonnenen Kampfs nach dem BRS (regeln/lohn.gd): Erfahrung je Gegner nach Modell D,
# Begleiter mit Anteil des Anführers, Erfahrungstopf je Gebiet, Aufstieg, weiche Kapitelgrenze, Ende; Texte [870.14.lohn.*].
# Lauf: godot --headless --path godot -s res://tests/lohn_870.gd   (Exit-Code 0 = alles wie DESIGN-BRS.md 4)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Lohn = preload("res://regeln/lohn.gd")

var tables: Dictionary
var fehler := 0


func _init() -> void:
	tables = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	_modell_d()
	_lohn()
	_rudel()
	print("LOHN870 %s" % ("gut" if fehler == 0 else "%d FALSCH" % fehler))
	quit(1 if fehler else 0)


func _soll(was: String, ist, soll) -> void:
	if str(ist) != str(soll):
		fehler += 1
		print("FALSCH %s: %s statt %s" % [was, ist, soll])
	else:
		print("ok %s: %s" % [was, ist])


func _monster(id: String) -> Dictionary:
	for m in tables.monsters:
		if m.id == id:
			return m
	return {}


## Gewonnener Kampf des Probehelden gegen [foe_ids]; die Würfel des Lohns gibt der Aufruf (Wuerfel.new(Band)).
func _kampf(foe_ids: Array) -> Variant:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)     # Ansgar, Stufe 3
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var foes := []
	for i in foe_ids.size():
		foes.append(Mars.monster_fighter("f%d" % i, Mars.SPOTS[i], _monster(foe_ids[i]), 999))
	var m = Mars.new([hero], foes, tables, Wuerfel.new(7), Wuerfel.new(7), 0, false, "NORMAL")
	m.test_end(true)
	return m


func _stand(stufe: int, ep := 0.0, toepfe := {}) -> Dictionary:
	var h := Brs.neuer_stand()
	h.stufe = stufe
	h.ep = ep
	h.toepfe = toepfe
	return h


func _modell_d() -> void:
	# 10 × Stufe², Boss × 3; Held darüber: 1 − d/9, null ab 9; Held darunter: höchstens doppelt (1 + d/10)
	_soll("Wolf (Stufe 2) für Stufe 2", Brs.erfahrung(2, "wolf"), 40.0)
	_soll("Wolf für Stufe 3", snappedf(Brs.erfahrung(3, "wolf"), 0.01), 35.56)
	_soll("Wolf für Stufe 11", Brs.erfahrung(11, "wolf"), 0.0)
	_soll("Grak (Stufe 6, Boss) für Stufe 3", snappedf(Brs.erfahrung(3, "hobgoblin_captain"), 0.01), 1404.0)


func _lohn() -> void:
	var w := ["wolf", "wolf", "wolf"]
	# drei Wölfe für Stufe 3: 3 × 35,56 = 107; Gold 1W6 (4); Trank nein (500), Fleisch ja (100), Fell ja (0)
	var r := Lohn.reward(_kampf(w), {}, Wuerfel.new([4, 500, 100, 0]))
	_soll("drei Wölfe: Zeilen", " | ".join(r.lines), "Ansgar erhält 107 EP. | Du erbeutest 4 Gold. | Beute: Rohes Fleisch! | Beute: Wolfsfell!")
	_soll("drei Wölfe: Stufe", r.level, 3)
	# Aufstieg: 280 von 300 in Stufe 3, ein Wolf (36): Heldenstufe 4, Rest 15,56, Leben und Mana voll
	var m = _kampf(["wolf"])
	var vorher := _stand(3, 280.0)
	var up := Lohn.reward(m, vorher, Wuerfel.new([1, 999, 999, 999]))
	_soll("Aufstieg: Zeilen", " | ".join(up.lines), "Ansgar erhält 36 EP. | Du erbeutest 1 Gold. | Ansgar erreicht Heldenstufe 4! | Leben und Mana von Ansgar sind wieder voll.")
	_soll("Aufstieg: Stand", "%d %.2f" % [up.stand.stufe, up.stand.ep], "4 15.56")
	_soll("Aufstieg: Stand des Aufrufers bleibt", "%d %.0f" % [vorher.stufe, vorher.ep], "3 280")
	# an die Kapitelgrenze (6): Grenze genannt
	m = _kampf(["wolf"])
	var gr := Lohn.reward(m, _stand(5, 490.0), Wuerfel.new([1, 999, 999, 999]))
	_soll("Grenze: Zeilen", " | ".join(gr.lines), "Ansgar erhält 27 EP. | Du erbeutest 1 Gold. | Ansgar erreicht Heldenstufe 6! | %s | Leben und Mana von Ansgar sind wieder voll." % Lohn.GRENZE[0])
	# über der Grenze ein Viertel: 40 × 5/9 / 4 = 5,56
	m = _kampf(["wolf"])
	_soll("weiche Grenze: EP", Lohn.reward(m, _stand(6), Wuerfel.new([1, 999, 999, 999])).xp, 6)
	# zwei Stufen darüber nichts mehr, und es wird gesagt
	m = _kampf(["wolf"])
	var ende := Lohn.reward(m, _stand(Brs.hoechste_stufe()), Wuerfel.new([1, 999, 999, 999]))
	_soll("Ende: EP und erste Zeile", "%d %s" % [ende.xp, ende.lines[0]], "0 " + Lohn.ENDE[0])
	# Topf des Gebiets: noch 10 übrig, der Wolf bringt 35,56: 10 aus dem Topf und ein Zehntel des Rests (2,56) = 13; einmal gesagt
	m = _kampf(["wolf"])
	var tp := Lohn.reward(m, _stand(3, 0.0, {"Wald": 10.0}), Wuerfel.new([1, 999, 999, 999]), "Wald")
	_soll("Topf: EP", tp.xp, 13)
	_soll("Topf: Zeile", Lohn.TOPF[0] in tp.lines, true)
	m = _kampf(["wolf"])
	var tp2 := Lohn.reward(m, tp.stand, Wuerfel.new([1, 999, 999, 999]), "Wald")
	_soll("Topf leer: EP, keine zweite Zeile", "%d %s" % [tp2.xp, Lohn.TOPF[0] in tp2.lines], "4 false")
	# voller Topf beim ersten Kampf im Gebiet
	m = _kampf(["wolf"])
	var neu := Lohn.reward(m, _stand(3), Wuerfel.new([1, 999, 999, 999]), "Wald")
	_soll("Topf voll: EP, Rest", "%d %.2f" % [neu.xp, float(neu.stand.toepfe.Wald)], "36 %.2f" % (Brs.topf_voll("Wald") - Brs.erfahrung(3, "wolf")))
	# ein Boss schöpft nicht aus dem Topf; Graks Gerufene zählen nicht
	var g = _kampf(["hobgoblin_captain", "goblin"])
	g.all[2].called_in = true
	var gl := Lohn.reward(g, _stand(3, 0.0, {"Höhle": 0.0}), Wuerfel.new([1] + range(200).map(func(_i): return 1)), "Höhle")
	_soll("Grak mit Gerufenem: EP, Topf", "%d %.0f" % [gl.xp, gl.stand.toepfe["Höhle"]], "1404 0")
	# 399.2: Ausrüstung nach den Dingen
	m = _kampf(["wolf"])
	var ga := Lohn.reward(m, {}, Wuerfel.new([4, 999, 999, 0]), "", [{"gear": {"base": "shortsword"}, "name": "Kurzschwert", "rarity": "Ungewöhnlich"}])
	_soll("Ausrüstung: Zeilen", " | ".join(ga.lines), "Ansgar erhält 36 EP. | Du erbeutest 4 Gold. | Beute: Wolfsfell! | Beute: Kurzschwert (Ungewöhnlich)!")
	_soll("Ausrüstung: Lohn", ga.gear, [{"base": "shortsword"}])
	# 870.5 Gegenwirkung: das Rudel floh vor dem Feuer, kein Lohn
	m = _kampf(["wolf"])
	m.kein_lohn = true
	var kl := Lohn.reward(m, {}, Wuerfel.new([4, 0, 0, 0]))
	_soll("kein Lohn", "%d %d %s" % [kl.xp, kl.gold, kl.items], "0 0 []")


func _rudel() -> void:
	# Begleiter ohne eigene Art: Anteil des Anführers (werte.json „erfahrung_anteil“, vorläufig wie alt 0,3 und 0,25)
	var monsters := {}
	for mo in tables.monsters:
		monsters[mo.id] = mo
	var Aufruf = load("res://kampf/aufruf.gd")
	var foes: Array = Aufruf.rudel(monsters, Wuerfel.new(3))
	var jung := foes.size() - 1
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, {})
	var m = Mars.new([hero], foes, tables, Wuerfel.new(7), Wuerfel.new(7))
	m.test_end(true)
	var soll := roundi(Brs.erfahrung(3, "wolf") * (1.0 + 0.3 * jung))
	_soll("Wolf mit %d Jungwölfen: EP" % jung, Lohn.reward(m, {}, Wuerfel.new([1] + range(200).map(func(_i): return 999))).xp, soll)
	var e := Lohn.erfahrung_des_siegs(m, 3)
	_soll("Wolf mit Jungwölfen: kein Boss", e.boss, false)
