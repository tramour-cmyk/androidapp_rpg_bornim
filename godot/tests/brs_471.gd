extends SceneTree
# 471 ohne Bild: Fertigkeiten steigen durch Tun (regeln/brs_fertigkeit.gd) gegen die Simulation 444 (tools/sim444/sim.py Held.uebe,
# nach_sieg) und das Nachschlagewerk Abschnitt 3. Die Erwartung der Folge unten hat sim.py gerechnet (Wachsoldat, 21 Punkte):
# {"Einhänder": [32, 5.0, 49, 0], "Bogen": [18, 3.4, 24, 0], "Schild": [15, 2.0, 24, 0], ep 65, ep_fert 40, Stufe 1}.
# Braucht daten/werte.json wie im Bau. Aufruf: im Ordner godot mit -s res://tests/brs_471.gd -> „BRS471 gut“

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if typeof(ist) == TYPE_FLOAT or typeof(soll) == TYPE_FLOAT:
		if absf(float(ist) - float(soll)) < 0.0001: return
	elif ist == soll: return
	fehler += 1
	print("FALSCH %s: %s statt %s" % [was, ist, soll])

func _initialize() -> void: _lauf.call_deferred()

func arten(ev: Array) -> Array: return ev.map(func(e): return "%s %s %d" % [e["art"], e["fert"], e["wert"]])

func _lauf() -> void:
	# Regeln einzeln (NW 3, werte.json „ueben“)
	pruefe("Bedarf bei 10", BrsFertigkeit.bedarf(10), 4.0)
	pruefe("Bedarf bei 49", BrsFertigkeit.bedarf(49), 11.8)
	pruefe("Faktor gleich", BrsFertigkeit.faktor(3, 3), 1.0)
	pruefe("Faktor zu leicht", BrsFertigkeit.faktor(1, 6), 0.1)     # 971 (966 A): höchstens ein Zehntel
	pruefe("Faktor schwer", BrsFertigkeit.faktor(9, 1), 1.5)
	pruefe("Raenge", [0, 24, 25, 49, 50, 74, 75, 100].map(func(x): return BrsFertigkeit.rang(x)), [0, 0, 1, 1, 2, 2, 3, 3])
	# Folge wie sim.py (gegen471)
	var b := BrsHeld.neu("Mensch", "Wachsoldat")
	var s := BrsFertigkeit.neuer_stand(b.fertigkeiten())
	var h := Brs.neuer_stand()
	pruefe("Start", s["werte"], {"Schild": 10, "Mittlere Rüstung": 10, "Einhänder": 10})
	var ev := []
	for i in 200: ev.append_array(BrsFertigkeit.uebe(s, h, "Einhänder", 1))
	pruefe("Einhaender an der Decke", [BrsFertigkeit.wert(s, "Einhänder"), BrsFertigkeit.am_rangende(s, "Einhänder"), BrsFertigkeit.probe_offen(s, "Einhänder")], [24, true, true])
	pruefe("Puffer", float(s["uebung"]["Einhänder"]), 15.0)
	pruefe("Rangende einmal", ev.filter(func(e): return e["art"] == "rangende").size(), 1)
	pruefe("kein neuer Name", ev.filter(func(e): return e["art"] == "neu").size(), 0)
	ev = BrsFertigkeit.uebe(s, h, "Bogen", 3)
	pruefe("Bogen neu", arten(ev).slice(0, 1), ["neu Bogen 0"])
	for i in 49: BrsFertigkeit.uebe(s, h, "Bogen", 3)
	for i in 30: BrsFertigkeit.uebe(s, h, "Schild", 0)
	ev = []
	for i in 3: ev.append_array(BrsFertigkeit.nach_sieg(s, h, ["Einhänder", "Bogen"], 1))
	pruefe("Probe bestanden", arten(ev).filter(func(t): return t.begins_with("probe") or t.begins_with("rang ")), ["probe Einhänder 24", "rang Einhänder 26"])   # Puffer 15 reicht fuer zwei Punkte
	for i in 50: BrsFertigkeit.uebe(s, h, "Einhänder", 1)
	pruefe("niedriger Gegner zaehlt nicht", BrsFertigkeit.nach_sieg(s, h, ["Einhänder"], 0), [])
	var soll := {"Einhänder": [32, 5.0, 49, 0], "Bogen": [18, 3.4, 24, 0], "Schild": [15, 2.0, 24, 0], "Mittlere Rüstung": [10, 0.0, 24, 0]}
	for f in soll:
		var ist := [BrsFertigkeit.wert(s, f), snappedf(float(s["uebung"].get(f, 0.0)), 0.0001), BrsFertigkeit.decke(s, f), int(s["probe"].get(f, 0))]
		for i in 4: pruefe("%s [%d] wie sim.py" % [f, i], ist[i], soll[f][i])
	pruefe("Erfahrung wie sim.py", [snappedf(float(h["ep"]), 0.0001), snappedf(float(h["ep_fert"]), 0.0001), int(h["stufe"])], [65.0, 40.0, 1])
	pruefe("Deckel 40 %", Brs.deckel_erreicht(h), true)
	# Kapitel 1 endet bei Geselle: an 49 keine Probe mehr
	s["werte"]["Einhänder"] = 49
	pruefe("Geselle ist Kapitelende", BrsFertigkeit.probe_offen(s, "Einhänder"), false)
	# Heldenblatt nur Getanes, in der Reihenfolge der Gruppen
	pruefe("sichtbar", BrsFertigkeit.sichtbar(s), ["Einhänder", "Schild", "Bogen", "Mittlere Rüstung"])
	# im Spielstand (JSON hin und zurueck)
	var s2: Dictionary = JSON.parse_string(JSON.stringify(s))
	BrsFertigkeit.uebe(s2, h, "Bogen", 3)
	pruefe("Spielstand rechnet weiter", BrsFertigkeit.wert(s2, "Bogen") >= BrsFertigkeit.wert(s, "Bogen"), true)
	print("BRS471 ", "gut" if fehler == 0 else "%d falsch" % fehler)
	quit(1 if fehler else 0)
