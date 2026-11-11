extends SceneTree
# 870.5 (LISTE-UMZUG-BRS.md Schritt 5, Prüfung: „Simulation 444 neu: Rudel, Krogg, Grak je Herkunft, Ergebnis zum Chef vor B1“):
# derselbe Kampf wie im Spiel (mars.gd nach dem BRS, Gegner wie aufruf.gd: Rudel mit Jungwölfen, Krogg, Grimmzahn mit Leibwache,
# Grak), der Held je Herkunft aus BrsHeld.kampfblatt() auf Heldenstufe 1–6 mit den mittleren Fertigkeiten der Simulation 444
# (sim.py --json, Spalte „21“ wie BrsHeld.neu, „fortschritt“ „fert_bei“; das Volk Mensch gibt im Spiel einen Punkt mehr). Der Spieler ist der Autopilot (mars.gd _auto_order, auch gegen Bosse), ohne Tränke,
# ohne Söldner; den Ring trifft er nie (NONE) oder immer gut (GOOD, RING=gut); KRAFT=aus: ohne Kraft schöpfen wie die Simulation. Zelle: Sieg % (Simulation 444 %).
# Aufruf: tools/sim444/sim.py --ohne-wirtschaft --json /pfad/sim.json, dann im Ordner godot
#   SIM=/pfad/sim.json [N=200] [RING=gut] [NUR=Krogg] [KRAFT=aus] godot --headless -s res://tests/sim444_870.gd   (Tabelle, Exit 0)

const Aufruf = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const BrsHeldS = preload("res://regeln/brs_held.gd")
const Brs = preload("res://regeln/brs.gd")

## Gruppe im Spiel (aufruf.gd gegner) -> Zeile der Simulation 444
const GEGNER := {"RUDEL": "Rudel", "KROGG": "Krogg", "GRIMM": "Grimmzahn", "GRAK": "Grak"}
const HERKUENFTE := ["Wachsoldat", "Jägerkind", "Zauberlehrling", "Klosterschüler", "Kräutersammler", "Schmiedelehrling", "Herumtreiber", "Wanderer"]
## Waffengruppe der Herkunft -> Grundform im Blatt (Fernkampf, Modell); Gruppe und Schaden rechnet brs_kampf.gd aus dem Kampfblatt
const GRUNDFORM := {"Einhänder": "longsword", "Bogen": "shortbow", "Stumpfe Waffen": "mace", "Dolche": "dagger", "Faustkampf": ""}


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	var W := Brs.lade()
	if W.is_empty():
		print("SIM444 daten/werte.json fehlt")
		quit(1)
		return
	var sim := {}
	var pfad := OS.get_environment("SIM")
	if pfad != "" and FileAccess.file_exists(pfad):
		sim = JSON.parse_string(FileAccess.get_file_as_string(pfad))["21"]     # 21 Punkte wie BrsHeld (Entscheidung 77)
	else:
		print("ohne SIM: Startfertigkeiten auf jeder Stufe, keine Vergleichszahlen")
	var n := int(OS.get_environment("N")) if OS.get_environment("N") != "" else 200
	var ring := Mars.GOOD if OS.get_environment("RING") == "gut" else Mars.NONE
	var nur := OS.get_environment("NUR")
	var tab: Dictionary = Tabellen.lade()
	var skills := {}
	for s in tab.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tab.monsters:
		monsters[m.id] = m
	print("Ring: %s, je Zelle %d Kämpfe; Zelle Sieg %% (Simulation 444 %%) · Züge · Leben am Ende %%" % [ring, n])
	for g in GEGNER:
		if nur != "" and not (g + GEGNER[g]).contains(nur):
			continue
		print("\n%s (Simulation: %s)" % [g, GEGNER[g]])
		print("%-17s %s" % ["Herkunft", "  ".join(range(1, 7).map(func(s): return "%-22s" % ("Stufe %d" % s)))])
		for hk in HERKUENFTE:
			var zeile := "%-17s" % hk
			for s in range(1, 7):
				var fert := {}
				var soll := "–"
				if sim.has(hk):
					var fb: Dictionary = sim[hk]["fortschritt"]["fert_bei"]
					fert = fb.get(str(s), {}) if not (fb.get(str(s), {}) as Dictionary).is_empty() else fb[str(fb.keys().map(func(k): return int(k)).max())]
					var c = sim[hk]["matrix"].get("%s|%d" % [GEGNER[g], s])
					if c != null:
						soll = "%d" % roundi(float(c.quote) * 100)
				var z := _messe(g, hk, s, fert, n, ring, tab, skills, monsters)
				zeile += " %-22s" % ("%3d (%s) · %s · %s" % [z.siege * 100 / n, soll, ("%.1f" % (float(z.zuege) / z.siege)) if z.siege > 0 else "–",
					("%d" % roundi(100.0 * z.leben / z.siege)) if z.siege > 0 else "–"])
			print(zeile)
	quit(0)


func _blatt(hk: String, s: int, fert: Dictionary, tab: Dictionary) -> Dictionary:
	var bh = BrsHeldS.neu("Mensch", hk)
	if hk == "Wanderer":     # verteilt selbst; gerechnet wie 444 als Kampfbau (werte.json „herkuenfte“ „Wanderer“ plus, plus_variante)
		var d: Dictionary = Brs.lade().herkuenfte.Wanderer
		for teil in ["plus", "plus_variante"]:
			for g in d.get(teil, {}):
				for i in int(d[teil][g]):
					bh.hoch(g)
	var k: Dictionary = bh.kampfblatt(s, {}, fert)
	var sheet: Dictionary = (tab.probe.FIGHTER.hero.hero as Dictionary).duplicate(true)
	var gf: String = GRUNDFORM.get(String(k.waffe.gruppe), "longsword")
	sheet.main = {"id": gf, "de": gf, "en": gf, "atk": 0, "dmg": [1, 4, 0], "ranged": k.waffe.art == "fern", "reach": false, "two": false, "type": "BLUDGEONING"}
	sheet.second = null
	sheet.level = s
	sheet.skills = []
	sheet.schild = "shield" if not (k.schild as Dictionary).is_empty() else ""
	sheet.brs = k
	return sheet


func _messe(g: String, hk: String, s: int, fert: Dictionary, n: int, ring: String, tab: Dictionary, skills: Dictionary, monsters: Dictionary) -> Dictionary:
	var z := {"siege": 0, "zuege": 0, "leben": 0.0}
	var sheet := _blatt(hk, s, fert, tab)
	var react := func(_t, _i): return ring
	for i in n:
		var seed := s * 100003 + i * 7 + 1
		var foes: Array = Aufruf.gegner(g, monsters, Wuerfel.new(seed))
		var hero = Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, int(sheet.brs.leben), null, skills)
		var mars = Mars.new([hero], foes, tab, Wuerfel.new(seed + 1), Wuerfel.new(seed + 2), 0, false)
		if OS.get_environment("KRAFT") == "aus":     # wie die Simulation 444 (Teile 1–6 ohne Kampfhandlungen)
			hero.uses["H_KRAFT"] = 0
		mars.start(react)
		var zuege := 0
		while mars.outcome == "ONGOING" and zuege < 200:
			zuege += 1
			mars.act(mars._auto_order(mars.current()), react)
		if mars.outcome == "WON":
			z.siege += 1
			z.zuege += zuege
			z.leben += float(hero.hp) / maxf(1.0, hero.max_hp)
	return z
