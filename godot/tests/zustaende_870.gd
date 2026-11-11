extends SceneTree
# 870.6 (Zu 870.6 von Tom 02:13, Sokrates 01:59, 20:05): im Kampf rechnet nichts mehr im Maß der alten Trefferpunkte. Gift, Brand,
# Blutung als Anteil am vollen Leben (werte.json „zustaende“), Tränke heilen fest für jeden, Schwächung und Sättigung als Faktor,
# Gegenwirkung Riesenspinne: Feuer verbrennt die Spinnseide, der Lohn hat dann keine. Dinge ohne Würfel im Text. Ohne Grafik.
# Aufruf: im Ordner godot mit -s res://tests/zustaende_870.gd -> „ZUSTAENDE870 n Fehler“ (Exit 0 = richtig)

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Lohn = preload("res://regeln/lohn.gd")
const BrsKampf = preload("res://regeln/brs_kampf.gd")

var fehler := 0
var tab: Dictionary
var monsters := {}
var skills := {}

func _initialize() -> void:
	tab = Tabellen.lade()
	for m in tab.monsters: monsters[m.id] = m
	for s in tab.skills: skills[s.id] = s
	Sprache.lade()
	_zustaende()
	_schwach_satt()
	_spinnseide()
	_dinge()
	# 870.6 (Sokrates 20:05): tabellen.json ist gelöscht, Tabellen.lade() liefert die Monster nach BRS
	pruefe(not FileAccess.file_exists("res://regeln/tabellen.json"), "regeln/tabellen.json gibt es nicht mehr")
	for m in tab.monsters:
		pruefe(int(m.hp[0]) == 0 and int(m.hp[2]) == int(Brs.monster(String(m.id)).get("leben", -1)), "%s: Leben nach BRS, kein Würfel (%s)" % [m.id, m.hp])
		pruefe(String(m.de) == Brs.name(String(m.id)), "%s heißt nach BRS: %s" % [m.id, m.de])
	print("ZUSTAENDE870 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		print("FALSCH " + was)
		fehler += 1

func _kampf(foe_ids: Array, seed: int):
	var held: Dictionary = tab.probe.FIGHTER.hero.hero.duplicate(true)
	var h = Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), held, 60, held.second, skills)
	var foes := []
	for i in foe_ids.size():
		foes.append(Mars.monster_fighter("f%d" % i, Mars.SPOTS[i], monsters[foe_ids[i]], 30))
	var m = Mars.new([h], foes, tab, Wuerfel.new(seed), Wuerfel.new(7), 0, false, "NORMAL")
	m.chosen = true
	m.brs_einrichten()
	return m

func _zustaende() -> void:
	var z: Dictionary = BrsKampf.w()["zustaende"]
	for st in ["POISON", "BURN", "BLEED"]:
		var m = _kampf(["wolf"], 3)
		var h = m.all[0]
		h.hp = h.max_hp
		h.status[st] = 3
		m._tick(h)
		var gift: float = h.gift if st == "POISON" else 1.0     # schwächeres Gift nach seiner Stärke
		var soll := maxi(1, roundi(float(h.max_hp) * float(z["schaden_anteil"][st]) * gift))
		pruefe(h.max_hp - h.hp == soll, "%s: %d Schaden statt %d (Anteil am vollen Leben %d)" % [st, h.max_hp - h.hp, soll, h.max_hp])
	var m = _kampf(["wolf"], 3)
	var h = m.all[0]
	h.hp = 1
	pruefe(m._heilung(m.all[1], "potion", {}) == int(BrsKampf.w()["welt"]["heilung"]["potion"]), "Heiltrank heilt jeden fest (auch Gegner, Söldner)")

func _schwach_satt() -> void:
	var m = _kampf(["wolf"], 5)
	var h = m.all[0]
	var f: Dictionary = BrsKampf.w()["zustaende"]["schaden_faktor"]
	pruefe(is_equal_approx(m._schaden_faktor(h), 1.0), "ohne Zustand Faktor 1")
	h.status["WEAK"] = 2
	pruefe(is_equal_approx(m._schaden_faktor(h), float(f["WEAK"])), "geschwächt: Faktor %s" % m._schaden_faktor(h))
	pruefe(is_equal_approx(m._treffer_mod(h), float(BrsKampf.w()["zustaende"]["treffer"]["WEAK"])), "geschwächt: Trefferchance %s" % m._treffer_mod(h))
	h.status.erase("WEAK")
	m.fed = true
	pruefe(is_equal_approx(m._schaden_faktor(h), float(f["satt"])), "satt: Faktor %s" % m._schaden_faktor(h))
	pruefe(is_equal_approx(m._treffer_mod(h, true), float(BrsKampf.w()["zustaende"]["treffer"]["satt"])), "satt: Trefferchance")

func _lohn_mit_seide(verbrannt: bool) -> int:
	var n := 0
	for s in 200:
		var m = _kampf(["giant_spider"], 100 + s)
		var sp = m.all[1]
		if verbrannt: m._gegenwirkung(m.all[0], sp, "feuer")
		sp.hp = 0
		m.outcome = "WON"
		var r: Dictionary = Lohn.reward(m, {}, m.dice)
		if "spider_silk" in r.items: n += 1
	return n

func _spinnseide() -> void:
	var m = _kampf(["giant_spider"], 9)
	var sp = m.all[1]
	m._gegenwirkung(m.all[0], sp, "feuer")
	pruefe(sp.seide_weg, "Feuer auf die Riesenspinne verbrennt die Seide")
	var mit := _lohn_mit_seide(false)
	var ohne := _lohn_mit_seide(true)
	pruefe(mit > 50, "Spinnseide ist Beute der Riesenspinne (%d von 200)" % mit)
	pruefe(ohne == 0, "verbrannt: keine Spinnseide (%d von 200)" % ohne)

func _dinge() -> void:
	var r := RegEx.create_from_string("\\d+[Wd]\\d+|gleißend|radiant")
	for id in Sprache.texte.get("dinge", {}):
		var d: Dictionary = Sprache.texte["dinge"][id]
		for k in ["name", "info", "kurz"]:
			if d.get(k) is Dictionary:
				for sp in ["de", "en"]:
					var t := String(d[k].get(sp, ""))
					pruefe(r.search(t) == null, "Ding %s %s nennt Würfel oder alten Namen: %s" % [id, k, t])
	pruefe(Sprache.t(Sprache.texte["dinge"]["alchemist_fire"]["name"]) != "", "Brandflasche hat einen Namen")
