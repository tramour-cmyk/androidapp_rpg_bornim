extends SceneTree
# 930.6 (DESIGN-GLUT.md 10 Stufe 1, Prüfpunkt „Kerntests je Regel, je Regelnummer oben ein Test“): der Regelkern regeln/kerbe.gd im
# Kampf mars.gd mit Schalter kerbe, je Regel 1–22 aus DESIGN-GLUT.md 3 und 4, dazu Ansage lesen (5), Vorschlag der Bedienung (7.1)
# und der Schalter selbst. Treffer, wo nötig, sicher oder nie (Trefferchance kurz auf 100 bzw. 0 %), sonst feste Würfel.
# Regel 18 (Mittel der Langsamen) baut Stufe 3 (Bauplan 10), hier nur vermerkt.
# Run: godot --headless --path godot -s res://tests/kerbe_930.gd   (Exit 0 = alle gut)

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Kerbe = preload("res://regeln/kerbe.gd")
const Brs = preload("res://regeln/brs.gd")

var tab: Dictionary
var skills := {}
var monsters := {}
var fehler := 0
var gut := 0
var ringe := 0
var ring_antwort := Mars.NONE
var K0 := {}


func _initialize() -> void:
	tab = Tabellen.lade()
	for s in tab.skills:
		skills[s.id] = s
	for mo in tab.monsters:
		monsters[mo.id] = mo
	K0 = (Brs.lade()["kampf"] as Dictionary).duplicate()
	for t in [_r1, _r2, _r3, _r4, _r5, _r6, _r7, _r8, _r9, _r10, _r11, _r12, _r13, _r14, _r15, _r16, _r17, _r18, _r19, _r20, _r21,
			_r22, _lesen, _vorschlag, _schalter]:
		_treffer(-1)
		t.call()
	_treffer(-1)
	print("KERBE930 %s: %d gut, %d falsch" % ["gut" if fehler == 0 else "FALSCH", gut, fehler])
	quit(0 if fehler == 0 else 1)


func ok(regel: String, bed: bool, was: String) -> void:
	if bed:
		gut += 1
		print("gut %s: %s" % [regel, was])
	else:
		fehler += 1
		print("FALSCH %s: %s" % [regel, was])


## Trefferchance: 1 immer, 0 nie, -1 wie werte.json
func _treffer(a: int) -> void:
	var k: Dictionary = Brs.lade()["kampf"]
	k.trefferchance_min = K0.trefferchance_min if a < 0 else (100 if a == 1 else 0)
	k.trefferchance_max = K0.trefferchance_max if a < 0 else (100 if a == 1 else 0)


func _react() -> Callable:
	return func(_t, _i) -> String:
		ringe += 1
		return ring_antwort


func _held(o := {}) -> Mars.Fighter:
	var waffe: String = o.get("waffe", "Einhänder")
	var W := Brs.lade()
	var k := {"stufe": int(o.get("stufe", 2)), "werte": o.get("werte", {"kraft": 5, "gewandtheit": 4, "zaehigkeit": 5, "verstand": 3, "wille": 4, "wahrnehmung": 4}),
		"fert": o.get("fert", {waffe: 10, "Ausweichen": 10}), "herkunft": "Wachsoldat", "ruestung": {"art": o.get("ruestung", "keine")},
		"schild": {}, "faehigkeiten": o.get("zauber", []), "waffe": {"gruppe": waffe, "art": W.waffen[waffe].art}, "leben": int(o.get("leben", 500)),
		"mana": 40, "volk": "Mensch"}
	var sheet: Dictionary = (tab.probe.FIGHTER.hero.hero as Dictionary).duplicate(true)
	sheet.main = {"id": "x", "de": "x", "en": "x", "atk": 0, "dmg": [1, 4, 0], "ranged": W.waffen[waffe].art == "fern", "reach": false, "two": false, "type": "SLASHING"}
	sheet.second = null
	sheet.level = k.stufe
	sheet.skills = []
	sheet.sp = 0
	sheet.sp_max = 0
	sheet.schild = ""
	sheet.brs = k
	return Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, k.leben, null, skills)


## Ein Kampf im Kerbensystem mit dem Helden [h] gegen [ids] (Kennungen; Leben hoch, damit keiner fällt, außer [leben])
func _kampf(h, ids: Array, o := {}) -> Mars:
	var foes := []
	for i in ids.size():
		var mo: Dictionary = (monsters[ids[i]] as Dictionary).duplicate(true)
		mo.erase("special")
		foes.append(Mars.monster_fighter("g%d" % i, Vector2i(i % 2, i / 2), mo, 1))
	var m := Mars.new([h], foes, tab, Wuerfel.new(int(o.get("seed", 7))), Wuerfel.new(8), 0, false, String(o.get("opening", "NORMAL")))
	m.kerbe = true
	ringe = 0
	ring_antwort = String(o.get("ring", Mars.NONE))
	if bool(o.get("nur_einrichten", false)):
		m.gk = Kerbe.new(m)
		m.gk.react = _react()
		m.gk._einrichten()
		m.gk.runde = 1
	else:
		m.start(_react())
	for f in foes:
		f.max_hp = int(o.get("leben", 999))
		f.hp = f.max_hp
	return m


func _zug(m: Mars, h) -> void:
	m.gk.zug_beginnen(h)


func _plan(g, gross: bool, art := "schlag") -> void:
	g.gl.plan = {"gross": gross, "art": art, "zeigt_gross": gross, "ziel": "hero"}


func _cues(m: Mars) -> Array:
	return m._take_log().map(func(e): return e.cue if e.cue != null else "")


# ---------------------------------------------------------------- Regeln

func _r1() -> void:
	ok("Regel 1", Kerbe.zug_kerben(0) == 3 and Kerbe.zug_kerben(1) == 2 and Kerbe.zug_kerben(2) == 1 and Kerbe.zug_kerben(5) == 1,
		"drei Kerben, Umreißen und Netz nehmen je eine, nie unter 1 (%d %d %d %d)" % [Kerbe.zug_kerben(0), Kerbe.zug_kerben(1), Kerbe.zug_kerben(2), Kerbe.zug_kerben(5)])
	var h := _held()
	var m := _kampf(h, ["goblin"], {"nur_einrichten": true})
	h.gl.betaeubt = 1
	ok("Regel 1", not m.gk.zug_beginnen(h) and m.gk.zug_beginnen(h) and int(h.gl.kerben) == 3, "betäubt: der Zug fällt aus, danach wieder drei")


func _r2() -> void:
	var t := [Kerbe.tempo_held({"werte": {"gewandtheit": 6}, "ruestung": "keine"}), Kerbe.tempo_held({"werte": {"gewandtheit": 4}, "ruestung": "keine"}),
		Kerbe.tempo_held({"werte": {"gewandtheit": 6}, "ruestung": "Schwere Rüstung"})]
	ok("Regel 2", t == ["schnell", "normal", "langsam"] and Kerbe.frei("schnell") == 2 and Kerbe.frei("normal") == 1 and Kerbe.frei("langsam") == 0,
		"Tempo und freie Felder: %s" % str(t))
	_treffer(0)
	var h := _held()
	var m := _kampf(h, ["goblin"], {"nur_einrichten": true})
	var g = m.all[1]
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WAFFE, "ziel": g.id, "haltung": Kerbe.GEGENSCHLAG})
	ok("Regel 2", int(g.gl.ab) == Kerbe.NAH and int(h.gl.bereit) == 2, "fern -> nah mit dem freien Schritt, Tun 1, Rest 2 (%d)" % int(h.gl.bereit))
	m = _kampf(_held(), ["goblin"], {"nur_einrichten": true})
	h = m.all[0]
	g = m.all[1]
	g.gl.ab = Kerbe.WEIT
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WAFFE, "ziel": g.id, "haltung": Kerbe.GEGENSCHLAG})
	ok("Regel 2", int(g.gl.ab) == Kerbe.NAH and int(h.gl.bereit) == 1, "weit -> nah: freier Schritt und eine Kerbe, Tun 1, Rest 1 (%d)" % int(h.gl.bereit))


func _r3() -> void:
	_treffer(1)
	var h := _held()
	var m := _kampf(h, ["zombie"], {"nur_einrichten": true})
	var g = m.all[1]
	g.gl.ab = Kerbe.NAH
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "loesen": true, "haltung": Kerbe.WEHR})
	ok("Regel 3", int(g.gl.ab) == Kerbe.FERN and int(h.gl.bereit) == 2, "Lösen kostet 1, der Langsame ist fern, Rest 2 in Wehr")
	for wehr in [false, true]:
		h = _held()
		m = _kampf(h, ["wolf"], {"nur_einrichten": true})
		g = m.all[1]
		g.gl.ab = Kerbe.NAH
		_zug(m, h)
		var hp: int = h.hp
		m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "loesen": true, "haltung": Kerbe.WEHR if wehr else Kerbe.GEGENSCHLAG})
		ok("Regel 3", (h.hp == hp) == wehr, "schneller Wolf setzt nach: %s (Haltung %s)" % ["nein" if h.hp == hp else "ja", "Wehr" if wehr else "Gegenschlag"])


func _r4() -> void:
	var m := _kampf(_held(), ["goblin", "goblin_archer"], {"nur_einrichten": true})
	ok("Regel 4", int(m.all[1].gl.ab) == Kerbe.FERN and int(m.all[2].gl.ab) == Kerbe.WEIT, "Beginn fern; der Späher bleibt weit (letzte Stufe)")
	m = _kampf(_held(), ["bugbear"], {"nur_einrichten": true})
	ok("Regel 4", int(m.all[1].gl.ab) == Kerbe.NAH, "Überfall (Krogg): nah")
	m = _kampf(_held(), ["goblin"], {"nur_einrichten": true, "opening": "AMBUSHED"})
	ok("Regel 4", int(m.all[1].gl.ab) == Kerbe.NAH, "überrascht: nah")


func _r5() -> void:
	var h := _held()
	var m := _kampf(h, ["goblin"], {"nur_einrichten": true})
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "tausch": Vector2i(Mars.BACK, 0), "haltung": Kerbe.WEHR})
	ok("Regel 5", h.place == Vector2i(Mars.BACK, 0) and int(h.gl.frei) == 0 and int(h.gl.bereit) == 3, "Platztausch kostet den freien Schritt, keine Kerbe")


func _r6() -> void:
	ok("Regel 6", Kerbe.tun_kosten("Funkenpfeil") == 1 and Kerbe.tun_kosten("Glutstrahlen") == 2 and Kerbe.tun_kosten("Wuchtschlag") == 2
		and Kerbe.tun_kosten("Zwei auf einmal") == 2, "Tun 1, schwere Handlungen 2")
	_treffer(0)
	var h := _held({"zauber": ["Funkenpfeil"], "fert": {"Evokation": 10, "Faustkampf": 10}, "waffe": "Faustkampf"})
	var m := _kampf(h, ["goblin"], {"nur_einrichten": true})
	var g = m.all[1]
	_zug(m, h)
	var sp: int = h.sp
	m.gk.held_zug(h, {"tun": "Z_FUNKEN", "ziel": g.id, "haltung": Kerbe.WACHSCHUSS})
	ok("Regel 6", int(h.gl.bereit) == 2 and h.sp == sp - int(Brs.lade().zauber.Funkenpfeil.kosten) and int(g.gl.ab) == Kerbe.FERN,
		"Funkenpfeil aus fern: ein Tun, Mana ab, Rest 2 im Wachschuss")


func _r7() -> void:
	ok("Regel 7", is_equal_approx(Kerbe.vertiefen_faktor(0), 1.0) and is_equal_approx(Kerbe.vertiefen_faktor(2), 1.0 + 2.0 * float(Kerbe.w().vertiefen)),
		"Vertiefen je Kerbe +%d %%" % roundi(float(Kerbe.w().vertiefen) * 100))
	ok("Regel 7", is_equal_approx(Kerbe.antwort_faktor(24), 0.5) and is_equal_approx(Kerbe.antwort_faktor(25), 1.0), "Antwort halb, ab Geselle voll")
	# Vertiefen: gleicher Würfel, mehr Schaden
	_treffer(1)
	var dmg := []
	for nd in [0, 2]:
		var h := _held()
		var m := _kampf(h, ["goblin"], {"nur_einrichten": true, "seed": 3})
		var g = m.all[1]
		g.gl.ab = Kerbe.NAH
		_zug(m, h)
		m.gk.held_zug(h, {"tun": Kerbe.WAFFE, "ziel": g.id, "vertiefen": nd, "haltung": Kerbe.GEGENSCHLAG})
		dmg.append([g.max_hp - g.hp, int(h.gl.bereit), int(m.gk.zaehler.vertieft)])
	ok("Regel 7", dmg[1][0] > dmg[0][0] and dmg[1][1] == 0 and dmg[1][2] == 2 and dmg[0][1] == 2, "Vertiefen 2: Schaden %d statt %d, keine Haltung" % [dmg[1][0], dmg[0][0]])
	# Gegenschlag: der Goblin rückt heran und schlägt, der Held schlägt vorher
	var h := _held()
	var m := _kampf(h, ["goblin"], {"nur_einrichten": true})
	var g = m.all[1]
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.GEGENSCHLAG})
	_plan(g, false)
	m._take_log()
	m.gk.gegner_zug()
	var c := _cues(m)
	ok("Regel 7", int(m.gk.zaehler.gegenschlag) == 1 and int(h.gl.bereit) == 2 and c.find("KERBE_GEGENSCHLAG") >= 0, "Gegenschlag beim Herankommen, eine Kerbe")
	# Wachschuss: Bogen, der Goblin rückt ein Feld vor
	h = _held({"waffe": "Bogen", "fert": {"Bogen": 10, "Ausweichen": 10}})
	m = _kampf(h, ["goblin"], {"nur_einrichten": true})
	g = m.all[1]
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.WACHSCHUSS})
	_plan(g, false)
	m.gk.gegner_zug()
	ok("Regel 7", int(m.gk.zaehler.wachschuss) == 1, "Wachschuss, wenn er vorrückt")
	# Wehr: je Kerbe ein Schlag mit Ungunst, verfällt mit dem eigenen nächsten Zug
	h = _held()
	m = _kampf(h, ["goblin"], {"nur_einrichten": true})
	g = m.all[1]
	g.gl.ab = Kerbe.NAH
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.WEHR})
	_plan(g, false)
	m.gk.gegner_zug()
	ok("Regel 7", int(m.gk.zaehler.wehr) == 1 and int(h.gl.bereit) == 2, "Wehr: eine Kerbe je Schlag")
	m.gk.zug_beginnen(h)
	ok("Regel 7", int(h.gl.bereit) == 0 and int(m.gk.zaehler.verfallen) == 2, "Haltung verfällt mit dem eigenen nächsten Zug")
	# Wehr: Ungunst im Treffer (Trefferchance wie werte.json)
	_treffer(-1)
	var ch := []
	for wehr in [false, true]:
		h = _held()
		m = _kampf(h, ["goblin"], {"nur_einrichten": true})
		g = m.all[1]
		h.gl.bereit = 1 if wehr else 0
		h.gl.haltung = Kerbe.WEHR
		m._take_log()
		m.gk.auf_held(g, h)
		var roll = m._take_log().filter(func(e): return e.roll != null)[0].roll
		ch.append(int(roll[3]))
	ok("Regel 7", ch[0] - ch[1] == -int(Kerbe.w().wehr_ungunst), "Wehr: Trefferchance %d statt %d" % [ch[1], ch[0]])
	# Antworten nie kritisch
	_treffer(1)
	var krit := []
	for antwort in [false, true]:
		h = _held({"werte": {"kraft": 5, "gewandtheit": 40, "zaehigkeit": 5, "verstand": 3, "wille": 4, "wahrnehmung": 4}, "fert": {"Einhänder": 100}})
		m = _kampf(h, ["goblin"], {"nur_einrichten": true})
		m._take_log()
		m.gk.held_schlag(h, m.all[1], Kerbe.WAFFE, 0.0, 1.0, antwort)
		krit.append(bool(m._take_log().filter(func(e): return e.roll != null)[0].roll[7]))
	ok("Regel 7", krit == [true, false], "Antwort nie kritisch (Schlag %s, Antwort %s)" % krit)


func _r8() -> void:
	_treffer(1)
	var h := _held()
	var m := _kampf(h, ["goblin"], {"nur_einrichten": true})
	var g = m.all[1]
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.GEGENSCHLAG})
	g.hp = 1
	_plan(g, false)
	var hp: int = h.hp
	m.gk.gegner_zug()
	ok("Regel 8", not g.standing() and h.hp == hp, "Gegenschlag tötet: kein Angriff mehr")


func _r9() -> void:
	_treffer(1)
	var h := _held()
	var m := _kampf(h, ["goblin", "goblin", "goblin"], {"nur_einrichten": true})
	for i in [1, 2, 3]:
		m.all[i].gl.ab = Kerbe.NAH
		_plan(m.all[i], true)
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.WEHR})
	ringe = 0
	m.gk.gegner_zug()
	ok("Regel 9", ringe == 2 and int(m.gk.zaehler.ringe_gekappt) == 1, "drei große Schläge: zwei Ringe, der dritte ohne (%d Ringe)" % ringe)


func _r10() -> void:
	_treffer(0)
	var h := _held()
	h.hp = 100
	var m := _kampf(h, ["goblin"], {"nur_einrichten": true})
	var g = m.all[1]
	g.gl.ab = Kerbe.NAH
	m.potions["potion"] = 1
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WAFFE, "ziel": g.id, "trank": "potion", "haltung": Kerbe.WEHR})
	ok("Regel 10", int(m.potions["potion"]) == 0 and h.hp > 100 and int(h.gl.bereit) == 1, "Trank 1, Schlag 1, Wehr 1 in einem Zug")


func _r11() -> void:
	var h := _held()
	var m := _kampf(h, ["goblin"], {"nur_einrichten": true})
	_zug(m, h)
	var uses: int = h.uses.get("H_KRAFT", 0)
	m.gk.held_zug(h, {"tun": "H_KRAFT", "ziel": h.id, "haltung": Kerbe.WEHR})
	ok("Regel 11", uses > 0 and int(h.uses["H_KRAFT"]) == uses - 1 and int(h.gl.bereit) == 2, "Kraft schöpfen kostet 1 (einmal je Kampf)")


func _r12() -> void:
	_treffer(1)
	for stufe in [3, 4]:
		var h := _held({"stufe": stufe})
		var m := _kampf(h, ["goblin"], {"nur_einrichten": true, "ring": Mars.PERFECT})
		var g = m.all[1]
		g.gl.ab = Kerbe.NAH
		_zug(m, h)
		m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.WEHR})
		_plan(g, true)
		m.gk.gegner_zug()
		m.gk.zug_beginnen(h)
		var soll := 4 if stufe >= 4 else 3
		ok("Regel 12", int(h.gl.kerben) == soll, "Goldkerbe nach perfektem Ring auf Stufe %d: %d Kerben" % [stufe, int(h.gl.kerben)])
		if stufe == 4:
			_plan(g, true)
			m.gk.gegner_zug()
			m.gk.zug_beginnen(h)
			ok("Regel 12", int(h.gl.kerben) == 3, "Goldkerbe nur einmal je Kampf")


func _r13() -> void:
	var m := _kampf(_held(), ["bugbear"], {"nur_einrichten": true})
	ok("Regel 13", not m.can_flee(m.all[0]), "nie vor einem Boss")
	var h := _held()
	m = _kampf(h, ["goblin"], {"nur_einrichten": true})
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.FLIEHEN})
	ok("Regel 13", int(h.gl.kerben) == 0 and int(h.gl.bereit) == 0, "Fliehen kostet alle Kerben (%s)" % m.outcome)


func _r14() -> void:
	var m := _kampf(_held(), ["goblin"], {"nur_einrichten": true})
	var mb := _kampf(_held({"waffe": "Bogen", "fert": {"Bogen": 10}}), ["goblin"], {"nur_einrichten": true})
	var o: Array = m._auto_order(m.all[0])
	ok("Regel 14", m.gk.haltungen(m.all[0]) == [Kerbe.GEGENSCHLAG, Kerbe.WEHR] and mb.gk.haltungen(mb.all[0]) == [Kerbe.WACHSCHUSS, Kerbe.WEHR]
		and o[0] == "KERBE", "keine Abwehr-Taste: Wehr ist eine Haltung")


func _r15() -> void:
	var m := _kampf(_held(), ["goblin", "bugbear"], {"nur_einrichten": true})
	ok("Regel 15", Kerbe.gegner_kerben(false) == 2 and Kerbe.gegner_kerben(true) == 3 and int(m.all[1].gl.kerben) == 2 and int(m.all[2].gl.kerben) == 3,
		"gewöhnliche Gegner 2, Bosse 3")


func _r16() -> void:
	_treffer(1)
	for gross in [false, true]:
		var h := _held()
		var m := _kampf(h, ["goblin"], {"nur_einrichten": true})
		var g = m.all[1]
		g.gl.ab = Kerbe.NAH
		_zug(m, h)
		m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.WEHR})
		_plan(g, gross)
		ringe = 0
		m.gk.gegner_zug()
		ok("Regel 16", ringe == (1 if gross else 0), "%s Schlag: %d Ring" % ["großer" if gross else "kleiner", ringe])


func _r17() -> void:
	_treffer(1)
	var h := _held()
	var m := _kampf(h, ["kobold"], {"nur_einrichten": true})
	var g = m.all[1]
	m.gk.planen()
	ok("Regel 17", String(g.gl.plan.art) == "lauern", "Kobold fern: lauert")
	m.gk.gegner_zug()
	_zug(m, h)
	m._take_log()
	var hp: int = h.hp
	m.gk.held_zug(h, {"tun": Kerbe.WAFFE, "ziel": g.id, "haltung": Kerbe.WEHR})
	var c := _cues(m)
	ok("Regel 17", h.hp < hp and c.find("KERBE_LAUERN") >= 0, "wer heranrückt, läuft in seinen Schlag")


func _r18() -> void:
	print("offen Regel 18: Mittel der Langsamen auf Abstand (Wiedergänger ruft Nachschub, Schnecke spuckt Säure) baut Stufe 3 (Bauplan 10)")


func _r19() -> void:
	_treffer(1)
	var h := _held()
	var m := _kampf(h, ["goblin"], {"nur_einrichten": true})
	var g = m.all[1]
	g.gl.ab = Kerbe.NAH
	_plan(g, true)
	var b1: bool = m.gk.brechen(g)
	_plan(g, false)
	var b2: bool = m.gk.brechen(g)
	_plan(g, true)
	m.gk.brechen(g)
	ringe = 0
	m.gk.gegner_zug()
	ok("Regel 19", b1 and not b2 and ringe == 0, "Brechen: der große Schlag geht ins Leere (kein Ring), ein kleiner nicht")


func _r20() -> void:
	var T: Dictionary = Kerbe.w().taeuschen
	var alt := float(T.anteil)
	T.anteil = 1.0
	var m := _kampf(_held(), ["goblin_archer"], {"nur_einrichten": true})
	var g = m.all[1]
	m.gk.planen()
	var p: Dictionary = g.gl.plan
	g.gl.stufe_lesen = 2
	var s2: Array = m.gk.gesehen(g)
	g.gl.stufe_lesen = 3
	var s3: Array = m.gk.gesehen(g)
	T.anteil = alt
	ok("Regel 20", g.gl.taeuscht and p.zeigt_gross != p.gross and s2[0] == p.zeigt_gross and s3[0] == p.gross,
		"Späher täuscht: Stufe 2 sieht %s, Stufe 3 sieht %s" % ["groß" if s2[0] else "klein", "groß" if s3[0] else "klein"])


func _r21() -> void:
	_treffer(1)
	# Spinne: Netz aus fern (Ring), zieht heran, nimmt eine Kerbe
	var h := _held()
	var m := _kampf(h, ["giant_spider"], {"nur_einrichten": true, "ring": Mars.NONE})
	var g = m.all[1]
	m.gk.planen()
	m.gk.gegner_zug()
	ok("Regel 21", String(g.gl.plan.art) == "netz" and int(g.gl.ab) == Kerbe.NAH and m.gk.zug_beginnen(h) and int(h.gl.kerben) == 2, "Spinne: Netz zieht heran, eine Kerbe weniger")
	# Fledermaus: beißt und löst sich
	m = _kampf(_held(), ["giant_bat"], {"nur_einrichten": true})
	g = m.all[1]
	g.gl.ab = Kerbe.NAH
	m.gk.planen()
	m.gk.gegner_zug()
	ok("Regel 21", int(g.gl.ab) == Kerbe.FERN, "Fledermaus: beißt und löst sich")
	# Krogg: Prankenhieb, Wehr hilft nicht, schleudert auf fern, danach offen
	h = _held()
	m = _kampf(h, ["bugbear"], {"nur_einrichten": true, "ring": Mars.NONE})
	g = m.all[1]
	g.gl.erster = false
	_zug(m, h)
	m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.WEHR})
	_plan(g, true, "prankenhieb")
	m.gk.gegner_zug()
	ok("Regel 21", int(m.gk.zaehler.wehr) == 0 and int(g.gl.ab) == Kerbe.FERN and g.gl.offen, "Krogg: Prankenhieb ohne Wehr, schleudert, offen")
	# Schamane heilt
	m = _kampf(_held(), ["kobold", "goblin_shaman"], {"nur_einrichten": true})
	var k = m.all[1]
	k.hp = 100
	_plan(m.all[2], false, "heilen")
	_plan(k, false, "lauern")
	m.gk.gegner_zug()
	ok("Regel 21", k.hp == 100 + int(Kerbe.w().plan.schamane_heilung), "Schamane heilt um %d" % int(Kerbe.w().plan.schamane_heilung))


func _r22() -> void:
	var m := _kampf(_held(), ["kobold", "goblin_shaman"], {"nur_einrichten": true})
	m.all[1].gl.ab = Kerbe.NAH
	var mb := _kampf(_held({"waffe": "Bogen", "fert": {"Bogen": 10}}), ["kobold", "goblin_shaman"], {"nur_einrichten": true})
	ok("Regel 22", m.gk.vorschlag_ziel(m.all[0]) == m.all[1] and mb.gk.vorschlag_ziel(mb.all[0]) == mb.all[2],
		"gemischt: nah zuerst; mit Bogen der Schamane")


func _lesen() -> void:
	var b := {"werte": {"wahrnehmung": 4}, "fert": {}}
	var sp := {"werte": {"wahrnehmung": 4}, "fert": {"Spähen": 25}}
	var r := [Kerbe.lesestufe(b, "Wolf", false), Kerbe.lesestufe(b, "Goblin", false), Kerbe.lesestufe(b, "Grak", true),
		Kerbe.lesestufe({"werte": {"wahrnehmung": 1}, "fert": {}}, "Skelett", false), Kerbe.lesestufe(sp, "Goblin", false)]
	ok("Abschnitt 5", r == [2, 2, 1, 1, 3], "Lesestufe Wolf, Goblin, Grak (Boss), Skelett mit Wahrnehmung 1, Goblin mit Spähen Geselle: %s" % str(r))
	var m := _kampf(_held(), ["goblin"], {"nur_einrichten": true})
	var g = m.all[1]
	_plan(g, false)
	g.gl.stufe_lesen = 0
	var s0: Array = m.gk.gesehen(g)
	_plan(g, true)
	var s0g: Array = m.gk.gesehen(g)
	ok("Abschnitt 5", s0[1] == null and s0g[1] != null, "Stufe 0 ohne Art; große Schläge mindestens Stufe 1")


func _vorschlag() -> void:
	var m := _kampf(_held(), ["goblin"], {"nur_einrichten": true})
	var g = m.all[1]
	_plan(g, true)
	var a: String = m.gk.vorschlag_haltung(m.all[0])
	_plan(g, false)
	var b: String = m.gk.vorschlag_haltung(m.all[0])
	var ms := _kampf(_held(), ["wolf", "goblin_archer"], {"nur_einrichten": true})
	_plan(ms.all[1], false)
	_plan(ms.all[2], false)
	var c: String = ms.gk.vorschlag_haltung(ms.all[0])
	ok("Bedienung 7.1", a == Kerbe.WEHR and b == Kerbe.GEGENSCHLAG and c == Kerbe.WEHR, "Vorschlag: groß -> Wehr, klein -> Gegenschlag, Schütze -> Wehr (%s %s %s)" % [a, b, c])


func _schalter() -> void:
	var h := _held()
	var foes := [Mars.monster_fighter("g0", Vector2i(0, 0), monsters["goblin"], 1)]
	var m := Mars.new([h], foes, tab, Wuerfel.new(1), Wuerfel.new(2), 0, false)
	ok("Schalter", not Kerbe.an() and not m.kerbe, "werte.json „kerbe“ „an“ aus: der alte Kampf")
	m.start(Callable())
	ok("Schalter", m.gk == null and m._auto_order(m.current())[0] != "KERBE", "alter Kampf ohne Regelkern")
	var m2 := _kampf(_held(), ["goblin"])
	ok("Schalter", m2.gk != null and m2.current() == m2.all[0] and int(m2.all[0].gl.kerben) == 3 and m2.gk.runde == 1, "an: Runde 1, der Held wählt mit drei Kerben")
	var log1: Array = m2.act(["attack", "g0"], _react())
	ok("Schalter", not log1.is_empty() and m2.gk.runde == 2,
		"an: der Befehl „Angriff“ des alten Kampfs wird ein Plan, dann Gegnerzug, Runde 2")
	m2.set_autopilot(true)
	var r0: int = m2.gk.runde
	m2.proceed(_react())
	ok("Schalter", m2.gk.runde == r0 + 1 or m2.outcome != "ONGOING", "an: Autopilot spielt über proceed den Vorschlag")
