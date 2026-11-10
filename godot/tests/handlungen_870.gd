# 870.5 (870a 3 A, DESIGN-BRS.md 7): Kampfhandlungen an Fertigkeiten statt Klassenfähigkeiten. Prüft Freigabe (Rang „ab“ aus
# werte.json „handlungen“, Waffe in der Hand), dass Extra-Angriff, Doppelzug, Finte der Klasse und Zweiwaffenkampf fehlen, und je
# Handlung ihre Wirkung (Zahlen aus werte.json, wie tools/sim444/handlungen.py). Ohne Grafik.
# Aufruf: im Ordner godot mit -s res://tests/handlungen_870.gd (Exit 0 = richtig); braucht daten/werte.json (tools/sim444).
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const BrsKampf = preload("res://regeln/brs_kampf.gd")

var fehler := 0
var tab: Dictionary
var skills := {}
var monsters := {}
var H: Dictionary


func _initialize() -> void:
	if not BrsKampf.an():
		print("HANDLUNGEN870 FALSCH daten/werte.json fehlt")
		quit(1)
		return
	tab = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	for s in tab.skills:
		skills[s.id] = s
	for m in tab.monsters:
		monsters[m.id] = m
	H = BrsKampf.w()["handlungen"]
	_freigabe()
	_kraft()
	_naechster("H_FINTE")
	_wucht()
	_durchschlag()
	_zwei()
	_schaedel()
	_hinterhalt()
	_schildwall()
	_abstand()
	_griff()
	print("HANDLUNGEN870 %s" % ("gut" if fehler == 0 else "%d FALSCH" % fehler))
	quit(1 if fehler > 0 else 0)


func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut:
		fehler += 1
	print(("ok     " if gut else "FALSCH ") + was + ((" (" + wie + ")") if wie != "" else ""))


## Held nach Kampfblatt (870.2) mit [gruppe] in der Hand und den Fertigkeiten [fert]; Gegner [foe_ids] mit vielen Leben
func _kampf(gruppe: String, fert: Dictionary, foe_ids: Array, seed := 3, schild := false, merc := false):
	var sheet: Dictionary = tab.probe.FIGHTER.hero.hero.duplicate(true)
	sheet.skills = sheet.skills + ["EXTRA_ATTACK", "ACTION_SURGE", "FEINT", "SECOND_WIND"]
	sheet.off = {"id": "shortsword", "de": "Kurzschwert", "en": "Shortsword", "atk": 5, "dmg": [1, 6, 0], "ranged": false, "reach": false, "two": false}
	sheet.brs = {"stufe": 3, "werte": {"kraft": 6, "gewandtheit": 4, "zaehigkeit": 6, "wille": 3, "wahrnehmung": 4}, "fert": fert,
		"herkunft": "Wachsoldat", "ruestung": {"art": "Mittlere Rüstung"}, "schild": {"art": "Schild"} if schild else {},
		"faehigkeiten": [], "waffe": {"gruppe": gruppe}, "leben": 40}
	var party := [Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 40, sheet.second, skills)]
	if merc:
		var ms: Dictionary = sheet.duplicate(true)
		ms.name = "Söldner"
		party.append(Mars.hero_fighter("merc", "PARTY", Vector2i(Mars.FRONT, 1), ms, 40, ms.second, skills))
	var foes := []
	for i in foe_ids.size():
		foes.append(Mars.monster_fighter("f%d" % i, Mars.SPOTS[i], monsters[foe_ids[i]], 999))
	var m = Mars.new(party, foes, tab, Wuerfel.new(seed), Wuerfel.new(7))
	m.brs_einrichten()
	for f in foes:
		f.max_hp = 99999
		f.hp = 99999
	m.chosen = true
	return m


func _freigabe() -> void:
	var m = _kampf("Einhänder", {"Einhänder": 25, "Bogen": 25}, ["wolf"])
	var h = m.by_id("hero")
	var mv: Array = m.moves(h)
	pruefe("Kraft schöpfen für alle", "H_KRAFT" in mv, str(mv))
	pruefe("Finte mit Einhänder 25 und Einhänder in der Hand", "H_FINTE" in mv, str(mv))
	pruefe("Ruhige Hand nicht ohne Bogen in der Hand", not ("H_RUHIG" in mv), str(mv))
	for alt in ["EXTRA_ATTACK", "ACTION_SURGE", "FEINT", "SECOND_WIND"]:
		pruefe("Klassenfähigkeit %s entfällt" % alt, not h.has(alt) and not (alt in mv))
	pruefe("kein Zweiwaffenkampf", _hiebe(m, ["attack", "f0"]) == 1)
	var n = _kampf("Einhänder", {"Einhänder": 24}, ["wolf"])
	pruefe("Finte nicht unter Rang Geselle (24)", not ("H_FINTE" in n.moves(n.by_id("hero"))))
	var s = _kampf("Einhänder", {"Einhänder": 10, "Schild": 25}, ["wolf"], 3, true)
	pruefe("Schildwall mit Schild 25 und Schild", "H_SCHILDWALL" in s.moves(s.by_id("hero")))
	var o = _kampf("Einhänder", {"Einhänder": 10, "Schild": 25}, ["wolf"], 3, false)
	pruefe("Schildwall nicht ohne Schild", not ("H_SCHILDWALL" in o.moves(o.by_id("hero"))))


func _hiebe(m, o: Array) -> int:
	var n := [0]
	m.listener = func(e): if e.actor == "hero" and Mars.ist_angriff(e.roll): n[0] += 1
	m.start()
	m.act(o)
	m.listener = Callable()
	return n[0]


func _kraft() -> void:
	var m = _kampf("Einhänder", {"Einhänder": 10}, ["wolf"])
	var h = m.by_id("hero")
	m.start()
	h.hp = 10
	var soll := mini(h.max_hp - 10, roundi(h.max_hp * float(H["Kraft schöpfen"]["heilung_anteil"])))
	m._perform(h, ["use", "H_KRAFT", "hero"])
	pruefe("Kraft schöpfen: Leben + Anteil", h.hp == 10 + soll, "%d statt %d" % [h.hp, 10 + soll])
	pruefe("Kraft schöpfen: einmal je Kampf", m.blocked(h, "H_KRAFT") != null)
	h.hp = 10
	pruefe("Autopilot schöpft Kraft unter der Hälfte nicht zweimal", m._auto_order(h)[0] != "use" or m._auto_order(h)[1] != "H_KRAFT")
	var a = _kampf("Einhänder", {"Einhänder": 10}, ["wolf"])
	a.start()
	a.by_id("hero").hp = 5
	pruefe("Autopilot schöpft Kraft unter der Hälfte", a._auto_order(a.by_id("hero")) == ["use", "H_KRAFT", "hero"], str(a._auto_order(a.by_id("hero"))))


## die Chance des Schlags in der Meldung (roll[3]) für [o]
func _chance(m, o: Array) -> int:
	var c := [-1]
	m.listener = func(e): if e.actor == "hero" and Mars.ist_angriff(e.roll) and c[0] < 0: c[0] = int(e.roll[3])
	m._perform(m.by_id("hero"), o)
	m.listener = Callable()
	return c[0]


func _naechster(id: String) -> void:
	var m = _kampf("Einhänder", {"Einhänder": 25}, ["wolf"])
	m.start()
	var ohne := _chance(m, ["attack", "f0"])
	m._perform(m.by_id("hero"), ["use", id, "hero"])
	var mit := _chance(m, ["attack", "f0"])
	var dann := _chance(m, ["attack", "f0"])
	var plus := int(H[Mars.HANDLUNG[id]]["naechster_treffer"])
	pruefe("%s: nächster Schlag +%d Prozentpunkte, danach nicht mehr" % [Mars.HANDLUNG[id], plus], mit == mini(95, ohne + plus) and dann == ohne,
			"%d, %d, %d" % [ohne, mit, dann])


func _wucht() -> void:
	var m = _kampf("Zweihänder", {"Zweihänder": 25}, ["wolf"])
	m.start()
	var ohne := _chance(m, ["attack", "f0"])
	var mit := _chance(m, ["use", "H_WUCHT", "f0"])
	pruefe("Wuchtschlag: Treffer %d" % int(H["Wuchtschlag"]["treffer"]), mit == ohne + int(H["Wuchtschlag"]["treffer"]), "%d, %d" % [ohne, mit])
	pruefe("Wuchtschlag: Schaden × %s" % H["Wuchtschlag"]["schaden_faktor"], _schaden_faktor("Zweihänder", "H_WUCHT", false) > 1.3)


## mittlerer Schaden je Treffer mit der Handlung geteilt durch ohne (gleiche Würfel)
func _schaden_faktor(gruppe: String, id: String, ruestung: bool) -> float:
	var sum := [0.0, 0.0]
	for i in 2:
		var m = _kampf(gruppe, {gruppe: 25}, ["skeleton" if ruestung else "wolf"], 11)
		m.start()
		var f = m.by_id("f0")
		var treffer := 0
		for k in 400:
			var hp0: int = f.hp
			m._perform(m.by_id("hero"), ["use", id, "f0"] if i == 1 else ["attack", "f0"])
			if f.hp < hp0:
				treffer += 1
				sum[i] += hp0 - f.hp
		sum[i] /= maxf(1.0, treffer)
	return sum[1] / maxf(0.01, sum[0])


func _durchschlag() -> void:
	var r: float = _schaden_faktor("Armbrust", "H_DURCH", true)
	pruefe("Durchschlag: mehr Schaden gegen Rüstung", r > 1.0, "%.2f" % r)


func _zwei() -> void:
	var m = _kampf("Wurfwaffen", {"Wurfwaffen": 25}, ["wolf"])
	m.start()
	var n := [0]
	m.listener = func(e): if e.actor == "hero" and Mars.ist_angriff(e.roll): n[0] += 1
	m._perform(m.by_id("hero"), ["use", "H_ZWEI", "f0"])
	pruefe("Zwei auf einmal: %d Würfe" % int(H["Zwei auf einmal"]["wuerfe"]), n[0] == int(H["Zwei auf einmal"]["wuerfe"]), str(n[0]))


func _schaedel() -> void:
	var betaeubt := 0
	var treffer := 0
	for seed in 300:
		var m = _kampf("Stumpfe Waffen", {"Stumpfe Waffen": 25}, ["wolf"], seed)
		m.start()
		var f = m.by_id("f0")
		var hp0: int = f.hp
		m._perform(m.by_id("hero"), ["use", "H_SCHAEDEL", "f0"])
		if f.hp < hp0:
			treffer += 1
			if f.status.has("STUN"):
				betaeubt += 1
	var q := float(betaeubt) / maxi(1, treffer)
	var soll := float(H["Schädelstoß"]["betaeubt_chance"])
	pruefe("Schädelstoß: betäubt etwa %d %% der Treffer" % roundi(soll * 100), treffer > 50 and absf(q - soll) < 0.12, "%d von %d" % [betaeubt, treffer])


func _hinterhalt() -> void:
	var m = _kampf("Dolche", {"Dolche": 25}, ["wolf"])
	m.start()
	var h = m.by_id("hero")
	pruefe("Stich aus dem Hinterhalt: vor dem ersten Schlag frei", m.blocked(h, "H_HINTERHALT") == null)
	m._perform(h, ["attack", "f0"])
	pruefe("Stich aus dem Hinterhalt: nach dem ersten Schlag nicht mehr", m.blocked(h, "H_HINTERHALT") != null)
	m.surprised["f0"] = true
	pruefe("Stich aus dem Hinterhalt: gegen einen Überraschten wieder", m.blocked(h, "H_HINTERHALT") == null)
	var r: float = _schaden_faktor_erst()
	pruefe("Stich aus dem Hinterhalt: Schaden × %s" % H["Stich aus dem Hinterhalt"]["schaden_faktor"], r > 1.3, "%.2f" % r)


func _schaden_faktor_erst() -> float:
	var sum := [0.0, 0.0]
	var n := [0, 0]
	for i in 2:
		for seed in 400:
			var m = _kampf("Dolche", {"Dolche": 25}, ["wolf"], 1000 + seed)
			m.start()
			var f = m.by_id("f0")
			var hp0: int = f.hp
			m._perform(m.by_id("hero"), ["use", "H_HINTERHALT", "f0"] if i == 1 else ["attack", "f0"])
			if f.hp < hp0:
				n[i] += 1
				sum[i] += hp0 - f.hp
	return (sum[1] / maxi(1, n[1])) / maxf(0.01, sum[0] / maxi(1, n[0]))


func _schildwall() -> void:
	var m = _kampf("Einhänder", {"Einhänder": 10, "Schild": 25}, ["wolf"], 3, true, true)
	m.start()
	var h = m.by_id("hero")
	var s = m.by_id("merc")
	m._perform(h, ["use", "H_SCHILDWALL", "hero"])
	var ziel := [""]
	m.listener = func(e): if e.actor == "f0" and Mars.ist_angriff(e.roll): ziel[0] = String(e.target)
	m._strike(m.by_id("f0"), s, m.I_BITE, Mars.NONE)
	pruefe("Schildwall: der Schlag gegen den Gefährten daneben geht an den Helden", ziel[0] == "hero", ziel[0])
	ziel[0] = ""
	m._strike(m.by_id("f0"), s, m.I_BITE, Mars.NONE)
	pruefe("Schildwall: nur ein Schlag", ziel[0] != "hero" and not h.schildwall, ziel[0])     # ein Treffer mit 0 Schaden meldet nichts (478)


func _abstand() -> void:
	var m = _kampf("Stangenwaffen", {"Stangenwaffen": 25}, ["wolf"])
	m.start()
	var h = m.by_id("hero")
	m._perform(h, ["use", "H_ABSTAND", "f0"])
	var gegen := [0]
	m.listener = func(e): if e.actor == "hero" and Mars.ist_angriff(e.roll): gegen[0] += 1
	m._strike(m.by_id("f0"), h, m.I_BITE, Mars.NONE)
	pruefe("Auf Abstand: der Angreifer läuft zuerst in die Spitze", gegen[0] == 1, str(gegen[0]))
	m._perform(h, ["wait"])
	gegen[0] = 0
	m._strike(m.by_id("f0"), h, m.I_BITE, Mars.NONE)
	pruefe("Auf Abstand: hält nur bis zum eigenen nächsten Zug", gegen[0] == 0, str(gegen[0]))


func _griff() -> void:
	var m = _kampf("Faustkampf", {"Faustkampf": 25}, ["wolf"])
	m.start()
	var h = m.by_id("hero")
	var f = m.by_id("f0")
	m._perform(h, ["use", "H_GRIFF", "f0"])
	pruefe("Griff: Ziel gehalten", f.gegriffen_von == "hero")
	var platz: Vector2i = f.place
	f.place = Vector2i(Mars.BACK, 0)
	m._leap_forward(f)
	pruefe("Griff: kein Sprung nach vorn", f.place == Vector2i(Mars.BACK, 0), str(f.place))
	f.place = platz
	m._perform(h, ["wait"])
	pruefe("Griff: frei mit dem eigenen nächsten Zug", f.gegriffen_von == "")
