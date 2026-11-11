extends SceneTree
# 473 ohne Bild: Monsterwerte nach dem BRS (Brs, regeln/brs.gd) rechnen wie die Simulation 444 (tools/sim444/sim.py).
# Sollwerte mit sim.py gerechnet (02.11.); Zahlen aus daten/werte.json. Aufruf: im Ordner godot mit -s res://tests/brs_473.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	var gleich: bool = is_equal_approx(float(ist), float(soll)) if (ist is float or soll is float) else ist == soll
	if not gleich:
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if Brs.lade().is_empty():
		print("FALSCH daten/werte.json fehlt"); quit(1); return
	# jede Art des Spiels (tabellen.json, Monsters.kt) hat Werte im Bestiarium
	var tab: Dictionary = Tabellen.lade()
	for m in tab.monsters:
		pruefe("Werte für %s" % m.id, Brs.monster(m.id).is_empty(), false)
	var ken: Array = (Brs.lade().get("kennungen", {}) as Dictionary).keys().filter(func(k): return not String(k).begins_with("_"))
	pruefe("18 Kennungen (870.3)", ken.size(), 18)
	for id in ken:
		pruefe("Kennung %s mit Name und Gruppe" % id, Brs.name(id) != "" and Brs.name(id, 1) != "" and String(Brs.kennung(id).get("gruppe", "")) != "", true)
	pruefe("Stirge heißt Riesenegel, Ockergallerte Säureschnecke ([870.15.namen.monster])", [Brs.name("stirge"), Brs.name("ochre_jelly", 1)], ["Riesenegel", "Acid Slug"])
	var lw := Brs.begleiter("Leibwache", "dire_wolf")
	pruefe("Leibwache: Wolf, Angriff Grimmzahn − 10, Schaden 7 × 0,31, 55 %", [int(lw.stufe), int(lw.leben), float(lw.angriff), snappedf(float(lw.schaden), 0.01), float(lw.chance)], [2, 25, 12.0, 2.17, 0.55])
	var jw := Brs.begleiter("Jungwolf", "wolf")
	pruefe("Jungwolf: Wolf mit halben Leben, Angriff − 10, Schaden 6 × 0,29, 50 %", [int(jw.leben), float(jw.angriff), snappedf(float(jw.schaden), 0.01), float(jw.chance)], [12, 5.0, 1.74, 0.5])
	for id in ken:
		var w := Brs.monster(id)
		pruefe("Art %s im Bestiarium" % id, w.is_empty(), false)
		if w.is_empty(): continue
		for feld in ["stufe", "leben", "ruestung", "schaden", "angriff", "abwehr", "wachsamkeit"]:
			pruefe("%s.%s ganz, nicht unter 0" % [id, feld], float(w[feld]) >= 0.0 and float(w[feld]) == floorf(float(w[feld])), true)
		pruefe("%s Stufe 1–6 (Kapitelgrenze)" % id, Brs.stufe(id) >= 1 and Brs.stufe(id) <= 6, true)
	# Stichproben aus dem Bestiarium „Werte 2.0“ (427, Chef 02.11., 18:54; werte.json seit 427.1)
	var wolf := Brs.monster("wolf")
	pruefe("Wolf", [wolf.stufe, wolf.leben, wolf.ruestung, wolf.schaden, wolf.angriff, wolf.abwehr, wolf.wachsamkeit], [2.0, 25.0, 1.0, 6.0, 15.0, 12.0, 30.0])
	var grak := Brs.monster("hobgoblin_captain")
	pruefe("Grak", [grak.stufe, grak.leben, grak.angriff, grak.abwehr, Brs.boss("hobgoblin_captain")], [6.0, 60.0, 25.0, 38.0, true])     # 870c 1 A: Leben 75 -> 60
	pruefe("Skelett gegen Stumpfes", Brs.monster("skeleton").get("schwaeche", {}).get("wucht"), 1.5)
	pruefe("Skelett gegen Stich", Brs.monster("skeleton").get("schwaeche", {}).get("stich"), 0.5)     # 870.5: Schadensarten (870a 8 A)
	pruefe("Säureschnecke gegen Feuer", Brs.monster("ochre_jelly").get("schwaeche", {}).get("feuer"), 1.5)
	pruefe("unbekannt leer", Brs.monster("drache").is_empty(), true)
	# Rundung wie Python: halbe auf die gerade
	pruefe("runde", [Brs.runde(4.5), Brs.runde(5.5), Brs.runde(2.4), Brs.runde(2.6), Brs.runde(0.5)], [4, 6, 2, 3, 0])
	# Regeln Modell D gegen sim.py
	pruefe("stufenfaktor", [Brs.stufenfaktor(-3), Brs.stufenfaktor(0), Brs.stufenfaktor(2), Brs.stufenfaktor(-12)], [0.7, 1.0, 1.2, 0.0])
	var tc := [Brs.trefferchance(10, 5), Brs.trefferchance(15, 38), Brs.trefferchance(40, 5, 10), Brs.trefferchance(200, 0), Brs.trefferchance(0, 200)]
	for i in 5: pruefe("trefferchance %d" % i, tc[i], [0.725, 0.585, 0.95, 0.95, 0.05][i])
	pruefe("schaden_roh 1", Brs.schaden_roh(7, 15, -1, 0.5, 1.0, 0.5), 7.245)
	pruefe("schaden_roh Glückstreffer", Brs.schaden_roh(7, 15, -12, 0.005, 1.0, 0.5), 8.05)
	pruefe("schaden_roh kritisch", Brs.schaden_roh(10, 20, 2, 0.5, 0.01, 1.0, 5), 25.92)
	pruefe("schaden_roh Streuung unten", Brs.schaden_roh(4, 10, 0, 0.9, 1.0, 0.0), 3.52)
	pruefe("endschaden", [Brs.endschaden(5.5, 1), Brs.endschaden(6.5, 1), Brs.endschaden(2.5, 3), Brs.endschaden(7.2, 1.3)], [4.0, 6.0, 0.0, 6.0])
	pruefe("Erfahrung Wolf", [Brs.erfahrung(1, "wolf"), Brs.erfahrung(2, "wolf"), Brs.erfahrung(11, "wolf")], [44.0, 40.0, 0.0])
	pruefe("Erfahrung Wolf Stufe 5", Brs.erfahrung(5, "wolf"), 26.666666666666668)
	pruefe("Erfahrung Grak", [Brs.erfahrung(6, "hobgoblin_captain"), Brs.erfahrung(4, "hobgoblin_captain"), Brs.erfahrung(1, "hobgoblin_captain")], [1080.0, 1296.0, 1620.0])
	# Würfeln: Wolf gegen Held Stufe 1, Abwehr 12, Abzug 3; sim.py mit 400 000 Schlägen (Werte 2.0): Mittel 3,281, Treffer 71,5 %
	var rng := RandomNumberGenerator.new()
	rng.seed = 473
	var n := 100000
	var summe := 0.0
	var treffer := 0
	for i in n:
		var s := Brs.monsterschlag(rng, "wolf", 1, 12, 3)
		summe += s
		if s > 0.0: treffer += 1
	var mittel := summe / n
	pruefe("Wolfsbiss Mittel 3,28 ± 0,05 (ist %.3f)" % mittel, absf(mittel - 3.281) < 0.05, true)
	pruefe("Wolfsbiss Treffer 71,5 %% ± 0,6 (ist %.3f)" % (float(treffer) / n), absf(float(treffer) / n - 0.7146) < 0.006, true)
	print("BRS473 ", "gut" if fehler == 0 else "%d FALSCH" % fehler)
	quit(1 if fehler else 0)
