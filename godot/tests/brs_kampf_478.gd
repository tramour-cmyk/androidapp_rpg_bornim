extends SceneTree
# 478 ohne Bild: der Rechenkern des Kampfs nach dem BRS (regeln/brs_kampf.gd, mars.gd brs) rechnet wie die Simulation 444.
# Teil 1: Formeln und Werte (Rechenbeispiele aus werte.json, wie sim.py). Teil 2: MARS-Kämpfe nach BRS, der Held allein (Stufe 1,
# Startfertigkeiten seiner Herkunft) gegen einen Gegner, Züge wie „Held Auto“ (mars.gd _auto_order); Siegquote gegen die der Simulation (sim.py kampf,
# derselbe Held, 2000 Kämpfe, Keim 478, gerechnet 08.11.). MARS ist kein Zweikampf wie die Simulation (Zugfolge nach Initiative,
# Ansagen, Ringe, Zustände, Fähigkeiten der Klasse), darum nur gemeldet, Grenze GRENZE_QUOTE.
# Aufruf: im Ordner godot mit -s res://tests/brs_kampf_478.gd (Exit 0 = Teil 1 richtig, Teil 2 innerhalb der Grenze)

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Aufruf = preload("res://kampf/aufruf.gd")
const BrsKampf = preload("res://regeln/brs_kampf.gd")
const Brs = preload("res://regeln/brs.gd")

const KAEMPFE := 300
const GRENZE_QUOTE := 0.2
## Simulation (sim.py kampf, Held mit 21 Punkten, Stufe 1, Startfertigkeiten), Siegquote je Gruppe des Probekampfs
const SOLL := {
	"FIGHTER": {"RATTE": 1.0, "BOARS": 1.0, "CENTIPEDES": 1.0, "FLEDERMAUS": 1.0, "SPINNE": 0.18, "KROGG": 0.01, "GRAK": 0.0, "LEECHES": 1.0, "SLUGS": 0.72},     # 870.5: Schleim widersteht Klingen nicht mehr (Bestiarium 870a 8), sim.py neu 0,72
	"ROGUE": {"RATTE": 1.0, "BOARS": 1.0, "CENTIPEDES": 1.0, "FLEDERMAUS": 0.41, "SPINNE": 0.02, "KROGG": 0.0, "GRAK": 0.0, "LEECHES": 1.0, "SLUGS": 0.07},
	"WIZARD": {"RATTE": 1.0, "BOARS": 1.0, "CENTIPEDES": 1.0, "FLEDERMAUS": 0.5, "SPINNE": 0.02, "KROGG": 0.0, "GRAK": 0.0, "LEECHES": 1.0, "SLUGS": 0.08},
	"CLERIC": {"RATTE": 1.0, "BOARS": 1.0, "CENTIPEDES": 1.0, "FLEDERMAUS": 0.99, "SPINNE": 0.1, "KROGG": 0.01, "GRAK": 0.0, "LEECHES": 1.0, "SLUGS": 0.65},
}
## Klassen ohne festen Vergleich (die Simulation kennt ihre Zauber und Fähigkeiten nicht so wie MARS): nur melden
const NUR_MELDEN := ["ROGUE", "WIZARD", "CLERIC"]
## 870.5: Gruppen mit Gegenwirkung, die die Simulation noch nicht kennt (Schleim teilt sich): nur melden
const GEGEN_MELDEN := ["SLUGS"]

var fehler := 0
var tables: Dictionary
var skills := {}


func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut:
		fehler += 1
	print(("ok     " if gut else "FALSCH ") + was + ((" (" + wie + ")") if wie != "" else ""))


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	if Brs.lade().is_empty():
		print("BRS478 FALSCH daten/werte.json fehlt")
		quit(1)
		return
	tables = Tabellen.lade()
	for s in tables.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	# ---- Teil 1: Werte und Formeln
	var h: Dictionary = (tables.probe.FIGHTER.hero.hero as Dictionary).duplicate(true)
	h.level = 1
	var b := BrsKampf.held(h)
	pruefe("Kämpfer = Wachsoldat", b.herkunft == "Wachsoldat", b.herkunft)
	pruefe("Grundwerte wie sim.py (Kraft 6, Gewandtheit 4, Zähigkeit 6)", b.werte.kraft == 6 and b.werte.gewandtheit == 4 and b.werte.zaehigkeit == 6, str(b.werte))
	pruefe("Leben Stufe 1: 10 + 5 + 2 × 6 = 27", BrsKampf.leben_held(b) == 27, str(BrsKampf.leben_held(b)))
	pruefe("Schild in der Hand", b.schild)
	# der Held nach BRS aus dem Spielstand (zustand.brs, BrsHeld.als_daten): seine Herkunft und Werte statt der Klasse
	var bh = load("res://regeln/brs_held.gd").neu("Zwerg", "Jägerkind")
	var bd := BrsKampf.held(h, bh.als_daten())
	pruefe("Held aus dem Spielstand: Herkunft Jägerkind, Bogen 10, Werte wie BrsHeld", bd.herkunft == "Jägerkind" and int(bd.fert.get("Bogen", 0)) == 10 and bd.werte == bh.werte(), "%s %s" % [bd.herkunft, bd.fert])
	b.ruestung = "Mittlere Rüstung"
	pruefe("Abzug Mittlere Rüstung und Schild 3 × 1,1 + 2 × 1,1 = 5,5", is_equal_approx(BrsKampf.held_abzug(b, true), 5.5), str(BrsKampf.held_abzug(b, true)))
	var abw: Array = BrsKampf.held_abwehr(b, "nah", "Einhänder", true)
	pruefe("Abwehr gegen Nahkampf: Schild 10 (Ausweichen 0 + 2 × 4 = 8, Parieren 5)", abw[0] == "Schild" and is_equal_approx(float(abw[1]), 10.0), str(abw))
	var wolf := BrsKampf.gegner(monsters.wolf, monsters.wolf)
	pruefe("Wolf nach dem Bestiarium: Stufe 2, Leben 25, Angriff 15", int(wolf.stufe) == 2 and int(wolf.leben) == 25 and int(wolf.angriff) == 15, str(wolf))
	var jung: Dictionary = monsters.wolf.duplicate(true)
	jung.scale = 0.55
	jung.chance = 0.5
	jung.rudel = "Jungwolf"     # 870.3: Werte aus werte.json „merkmale“ „rudel“
	jung.anfuehrer = "wolf"
	var bj := BrsKampf.gegner(jung, monsters.wolf)
	pruefe("Jungwolf: Angriff 15 − 10, Schaden 6 × 0,29, halbe Leben", is_equal_approx(float(bj.angriff), 5.0) and is_equal_approx(float(bj.schaden), 6.0 * 0.29) and int(bj.leben) == 12, str(bj))
	# Schlag wie Brs.schaden (gleiche Würfel in gleicher Folge)
	var gleich := true
	for i in 300:
		var r1 := RandomNumberGenerator.new()
		r1.seed = 4780 + i
		var r2 := RandomNumberGenerator.new()
		r2.seed = 4780 + i
		var a := Brs.schaden(r1, 10.0, 12.0, 12.0, -1.0, 1.0, 0.0, 4.0)
		var e := BrsKampf.schlag(r2, 10.0, 12.0, 12.0, -1.0, 1.0, 0.0, 4.0)
		if not is_equal_approx(a, float(e.schaden)) or (a > 0.0 and not e.treffer):
			gleich = false
	pruefe("Schlag wie Brs.schaden (300 Würfelfolgen)", gleich)
	# ---- Teil 2: MARS nach BRS gegen die Simulation
	for cls in SOLL:
		for foe in SOLL[cls]:
			var siege := 0
			var leben := 0.0
			for k in KAEMPFE:
				var dice := Wuerfel.new(4780 + k)
				var foes: Array = Aufruf.gegner(foe, monsters, dice)
				var hs: Dictionary = (tables.probe[cls].hero.hero as Dictionary).duplicate(true)
				hs.level = 1
				var party := [Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), hs, int(tables.probe[cls].hero.hp), hs.second, skills)]
				var mars = Mars.new(party, foes, tables, dice, Wuerfel.new(77 + k))
				mars.brs_einrichten()
				mars.chosen = true
				var react := func(_t, _i) -> String: return Mars.NONE
				mars.start(react)
				var zuege := 0
				while mars.outcome == "ONGOING" and zuege < 200:
					zuege += 1
					mars.act(mars._auto_order(mars.current()), react)     # wie „Held Auto“: Heilung, Zaubertrick, sonst Angriff
				if mars.outcome == "WON":
					siege += 1
					leben += float(party[0].hp) / party[0].max_hp
			var q := float(siege) / KAEMPFE
			var soll: float = SOLL[cls][foe]
			pruefe("%s Stufe 1 gegen %s: Siegquote MARS %.2f, Simulation %.2f%s" % [cls, foe, q, soll,
					(", Leben am Ende %.0f %%" % (100.0 * leben / siege)) if siege > 0 else ""], absf(q - soll) <= GRENZE_QUOTE or cls in NUR_MELDEN or foe in GEGEN_MELDEN)
	# 870.5: ohne SRD-Zweig braucht jeder Gegner der Tabelle seine Werte nach dem BRS
	var ohne := []
	for m in tables.monsters:
		if BrsKampf.gegner(m, m).is_empty():
			ohne.append(String(m.id))
	pruefe("jeder Gegner hat Werte nach dem BRS", ohne.is_empty(), ", ".join(ohne))
	print("BRS478 %s" % ("gut" if fehler == 0 else "%d FALSCH" % fehler))
	quit(1 if fehler > 0 else 0)
