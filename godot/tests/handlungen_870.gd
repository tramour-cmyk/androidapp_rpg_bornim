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
	tab = Tabellen.lade()
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
	_zauber()
	_schwaechen()
	_wissen_960()
	_gegenwirkungen()
	_regeln_870c()
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


## 870.5 Zauber nach dem BRS: bekannt nach Kampfblatt und Schule, Mana, Kosten, Wirkung
func _zauber() -> void:
	var Z: Dictionary = BrsKampf.w()["zauber"]
	var m = _kampf("Einhänder", {"Evokation": 25, "Heilmagie": 25, "Schutzmagie": 10}, ["wolf"])
	var h = m.by_id("hero")
	h.b.zauber = ["Funkenpfeil", "Wundsegen", "Bannschild"]
	# 870.4 (DESIGN-BRS.md 7, [870.14.ding.metall]): in Metall (mittlere, schwere Rüstung) keine Evokation, Illusion, Beschwörung
	m._brs_zauber_kennen(h)
	var in_metall: Array = m.moves(h)
	pruefe("Mittlere Rüstung: keine Evokation, Heil- und Schutzmagie bleiben",
			not ("Z_FUNKEN" in in_metall or "Z_STRAHLEN" in in_metall or "Z_FAECHER" in in_metall) and "Z_WUND" in in_metall and "Z_BANN" in in_metall, str(in_metall))
	h.b.ruestung = "Schwere Rüstung"
	m._brs_zauber_kennen(h)
	pruefe("Schwere Rüstung: keine Evokation", not ("Z_FUNKEN" in m.moves(h)), str(m.moves(h)))
	h.b.ruestung = "Leichte Rüstung"
	m._brs_zauber_kennen(h)
	var mv: Array = m.moves(h)
	pruefe("Zauber aus dem Kampfblatt und nach Schule (Evokation 25: Glutstrahlen, Flammenfächer; nicht Glutkugel ab 40)",
			"Z_FUNKEN" in mv and "Z_WUND" in mv and "Z_BANN" in mv and "Z_STRAHLEN" in mv and "Z_FAECHER" in mv and not ("Z_GLUT" in mv), str(mv))
	var soll_mana := int(BrsKampf.w()["held"]["mana_basis"]) + int(BrsKampf.w()["held"]["mana_je_wille"]) * 3
	pruefe("Mana voll ohne Angabe der Welt (10 + 5 × Wille)", h.sp == soll_mana and h.max_sp == soll_mana, "%d/%d statt %d" % [h.sp, h.max_sp, soll_mana])
	m.start()
	var vor: int = h.sp
	m._perform(h, ["use", "Z_FUNKEN", "f0"])
	pruefe("Funkenpfeil kostet %d Mana" % int(Z["Funkenpfeil"]["kosten"]), h.sp == vor - int(Z["Funkenpfeil"]["kosten"]), "%d -> %d" % [vor, h.sp])
	h.hp = 5
	var heil := roundi((float(Z["Wundsegen"]["heilung"]) + 3.0) * 1.25)
	m._perform(h, ["use", "Z_WUND", "hero"])
	pruefe("Wundsegen heilt (6 + Wille) × (1 + Heilmagie/100)", h.hp == 5 + heil, "%d statt %d" % [h.hp, 5 + heil])
	m._perform(h, ["use", "Z_BANN", "hero"])
	pruefe("Bannschild: Schutz und nur einmal je Kampf", h.schutz > 0.0 and m.blocked(h, "Z_BANN") != null, "%.1f" % h.schutz)
	h.sp = 0
	pruefe("ohne Mana gesperrt", m.blocked(h, "Z_FUNKEN") != null)
	# Beistand: +Treffer für seine Runden
	var b = _kampf("Einhänder", {"Einhänder": 25, "Heilmagie": 25}, ["wolf"])
	var bh = b.by_id("hero")
	b.start()
	var ohne := _chance(b, ["attack", "f0"])
	b._perform(bh, ["use", "Z_BEISTAND", "hero"])
	var mit := _chance(b, ["attack", "f0"])
	pruefe("Beistand: +%d auf die Trefferchance" % int(Z["Beistand"]["treffer"]), mit == mini(95, ohne + int(Z["Beistand"]["treffer"])), "%d, %d" % [ohne, mit])
	# Mana der Welt im selben Anteil hinein und zurück
	var w = _kampf("Einhänder", {"Evokation": 10}, ["wolf"])
	var wh = w.by_id("hero")
	wh.hero["sp_max"] = 10
	wh.sp = 5
	w._brs_zauber_kennen(wh)
	pruefe("Mana im Anteil der Zauberpunkte (5 von 10)", wh.sp == roundi(wh.max_sp * 0.5), "%d von %d" % [wh.sp, wh.max_sp])
	wh.sp = 0
	pruefe("nach dem Kampf zurück in Zauberpunkte", Mars.sp_nach(wh) == 0)
	wh.sp = wh.max_sp
	pruefe("volles Mana = volle Zauberpunkte", Mars.sp_nach(wh) == 10)


## 870.5 (870a 8 A): Schwäche, Stärke, immun nach Schadensart, Zeile einmal je Art, Wort im Kasten
func _schwaechen() -> void:
	var m = _kampf("Einhänder", {"Evokation": 25}, ["wolf"])
	m.start()
	var h = m.by_id("hero")
	var zeilen := []
	var kasten := []
	m.listener = func(e):
		if String(e.text).contains("verwundbar"):
			zeilen.append(e.text)
		if e.roll != null and Mars.ist_angriff(e.roll) and e.roll[4]:
			kasten.append(e.roll.size() > 8 and float(e.roll[8]) == 1.5)
	Mars.gegner_ohne_rettung = true
	for i in 3:
		m._brs_zauber(h, m.by_id("f0"), BrsKampf.w()["zauber"]["Funkenpfeil"])
	Mars.gegner_ohne_rettung = false
	pruefe("Wolf verwundbar gegen Feuer: eine Zeile bei drei Treffern", zeilen.size() == 1, str(zeilen))
	pruefe("Wolf verwundbar: Faktor 1,5 im Kasten jedes Treffers", kasten.size() == 3 and not kasten.has(false), str(kasten))
	var x = _kampf("Einhänder", {"Einhänder": 25}, ["skeleton"])
	x.start()
	var info := []
	pruefe("Skelett: Stich halb, Wucht anderthalb, Gift nichts", x._schwaeche(x.by_id("hero"), x.by_id("f0"), "stich", info) == 0.5
			and x._schwaeche(x.by_id("hero"), x.by_id("f0"), "wucht", info) == 1.5 and x._schwaeche(x.by_id("hero"), x.by_id("f0"), "gift", info) == 0.0)


## 960 (870d): Ziel-Tipp nennt Schwäche, Stärke und Gegenwirkung ab Verstand 6, sonst „unbekannt“, bis der Kampf eine nennt
func _wissen_960() -> void:
	var m = _kampf("Einhänder", {"Evokation": 25}, ["wolf"])
	m.by_id("hero").b.werte["verstand"] = 3
	m.start()
	pruefe("960 Verstand 3: Wolf unbekannt", m.wissen(m.by_id("f0"), 0) == "Schwächen: unbekannt.", m.wissen(m.by_id("f0"), 0))
	Mars.gegner_ohne_rettung = true
	m._brs_zauber(m.by_id("hero"), m.by_id("f0"), BrsKampf.w()["zauber"]["Funkenpfeil"])
	Mars.gegner_ohne_rettung = false
	pruefe("960 Verstand 3, nach dem Feuer: Wolf verwundbar gegen Feuer", m.wissen(m.by_id("f0"), 0).begins_with("Verwundbar: Feuer. Widersteht: –."), m.wissen(m.by_id("f0"), 0))
	var x = _kampf("Einhänder", {"Einhänder": 25}, ["skeleton"])
	x.by_id("hero").b.werte["verstand"] = 6
	x.start()
	pruefe("960 Verstand 6: Skelett vorher bekannt", x.wissen(x.by_id("f0"), 0) == "Verwundbar: Wucht. Widersteht: Stich, Gift.", x.wissen(x.by_id("f0"), 1))
	var w = _kampf("Einhänder", {"Einhänder": 25}, ["wolf"])
	w.by_id("hero").b.werte["verstand"] = 7
	w.start()
	pruefe("960 Verstand 7: Wolf mit Vorsicht (englisch)", w.wissen(w.by_id("f0"), 1).ends_with("Beware: fire drives off the pack, loot, experience and all, once its leader is half dead."), w.wissen(w.by_id("f0"), 1))


## 870.5 (870a 8 A): Gegenwirkungen
func _gegenwirkungen() -> void:
	var Z: Dictionary = BrsKampf.w()["zauber"]["Funkenpfeil"]
	Mars.gegner_ohne_rettung = true
	# Wolf und Feuer (870c 3 A): erst, wenn der Leitwolf unter halbem Leben ist, flieht das Rudel; Kampf gewonnen, kein Lohn
	var w = _kampf("Einhänder", {"Evokation": 25}, ["wolf", "wolf"])
	w.start()
	w._brs_zauber(w.by_id("hero"), w.by_id("f0"), Z)
	pruefe("Wolf und Feuer, Leitwolf über halbem Leben: Rudel bleibt", w.outcome == "ONGOING" and not w.by_id("f1").fled, w.outcome)
	w.by_id("f0").hp = 49000
	w._brs_zauber(w.by_id("hero"), w.by_id("f0"), Z)
	pruefe("Wolf und Feuer, Leitwolf unter halbem Leben: Rudel fort, Kampf vorbei, kein Lohn", w.outcome == "WON" and w.kein_lohn and w.by_id("f1").fled, "%s %s" % [w.outcome, w.kein_lohn])
	# Jungwolf folgt dem Leitwolf: Feuer auf ihn zählt das Leben des Leitwolfs
	var j = _kampf("Einhänder", {"Evokation": 25}, ["wolf", "wolf"])
	j.by_id("f1").follows = "f0"
	j.start()
	j._brs_zauber(j.by_id("hero"), j.by_id("f1"), Z)
	pruefe("Feuer auf den Jungwolf, Leitwolf heil: Rudel bleibt", j.outcome == "ONGOING" and not j.by_id("f0").fled, j.outcome)
	# Wildschwein und Feuer: rasend
	var b = _kampf("Einhänder", {"Evokation": 25}, ["boar"])
	b.start()
	b._brs_zauber(b.by_id("hero"), b.by_id("f0"), Z)
	pruefe("Wildschwein und Feuer: rasend", b.by_id("f0").rasend)
	# Zombie und Feuer: kein Zäher Tod
	var z = _kampf("Einhänder", {"Evokation": 25}, ["zombie"])
	z.start()
	z._brs_zauber(z.by_id("hero"), z.by_id("f0"), Z)
	pruefe("Zombie und Feuer: steht nicht wieder auf", z.by_id("f0").kein_zaeh)
	Mars.gegner_ohne_rettung = false
	# Schleim und Schnitt: teilt sich einmal
	var s = _kampf("Einhänder", {"Einhänder": 25}, ["ochre_jelly"])
	s.start()
	var vor: int = s.all.size()
	for i in 30:
		if not s.by_id("f0").standing():
			break
		s._perform(s.by_id("hero"), ["attack", "f0"])
		if s.all.size() > vor:
			break
	var teile: Array = s.all.filter(func(x): return x.side == "FOES" and x.monster != null and String(x.monster.id) == "ochre_jelly")
	pruefe("Schleim und Schnitt: teilt sich in zwei", teile.size() == 2, str(teile.size()))
	for i in 10:
		var ziele: Array = s.targets(s.by_id("hero"))
		if ziele.is_empty() or s.outcome != "ONGOING":
			break
		s._perform(s.by_id("hero"), ["attack", ziele[0].id])
	pruefe("Schleim teilt sich nur einmal", s.all.filter(func(x): return x.side == "FOES").size() <= 2)


## 870c (Vorentscheid Sokrates 10.11., 1 A, 2 A): Grak ruft höchstens einen Goblin; der Schütze allein vorn ohne Nachteil, mit Gefährten
## neben ihm mit Nachteil (Feuer und Leitwolf: _gegenwirkungen)
func _regeln_870c() -> void:
	pruefe("Grak ruft höchstens einen Goblin", Mars.CALL_MAX == 1, str(Mars.CALL_MAX))
	var a = _kampf("Bogen", {"Bogen": 25}, ["wolf"])
	a.start()
	var h = a.by_id("hero")
	h.hero.main = {"id": "shortbow", "de": "Kurzbogen", "en": "Shortbow", "atk": 0, "dmg": [1, 6, 0], "ranged": true, "reach": false, "two": true}
	pruefe("Schütze allein vorn: kein Nachteil", a._row_mode(h, a.by_id("f0"), true) == 0, str(a._row_mode(h, a.by_id("f0"), true)))
	var b = _kampf("Bogen", {"Bogen": 25}, ["wolf"], 3, false, true)
	b.start()
	var hb = b.by_id("hero")
	hb.hero.main = h.hero.main
	pruefe("Schütze vorn mit Gefährten daneben: Nachteil", b._row_mode(hb, b.by_id("f0"), true) == -1, str(b._row_mode(hb, b.by_id("f0"), true)))
