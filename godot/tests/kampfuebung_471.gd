extends SceneTree
# 471 ohne Bild: Fertigkeiten steigen durch Tun im Kampf (skripte/kampfuebung.gd). Prueft (1) welche Meldung des MARS welche Fertigkeit
# uebt (wie tools/sim444/sim.py kampf), (2) Gutschrift nur nach einem Sieg, mit Notiz „Einhänder ↑ 11“, (3) Spielstand speichert den
# Stand, (4) ein echter Kampf aus dem Aufruf (Wachsoldat gegen das Rudel, Autopilot) zaehlt Benutzungen und schreibt sie gut.
# Braucht daten/werte.json wie im Bau. Aufruf: im Ordner godot mit -s res://tests/kampfuebung_471.gd -> „KAMPFUEBUNG471 gut“

const Aufruf = preload("res://kampf/aufruf.gd")
var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist == soll: return
	fehler += 1
	print("FALSCH %s: %s statt %s" % [was, ist, soll])

func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()

func _lauf() -> void:
	var b := {"fert": {"Einhänder": 10, "Schild": 10, "Ausweichen": 0}, "werte": {"gewandtheit": 2}, "ruestung": "Mittlere Rüstung",
		"schild": true, "stufe": 1}
	var lage := {"waffe": "Einhänder", "in_hand": true, "art": "nah", "heiler": false, "feind": true}
	var ziel := {"actor": "hero", "target": "foe1", "damage": 4, "roll": ["BRS", 30, 0, 60, true], "spell": null, "cue": null}
	pruefe("Treffer mit der Waffe", Kampfuebung.benutzt(ziel, b, lage), ["Einhänder"])
	ziel = {"actor": "hero", "target": "foe1", "damage": 0, "roll": ["ATTACK", 3, 4, 13, false], "spell": null, "cue": null}
	pruefe("Fehlschlag uebt nichts", Kampfuebung.benutzt(ziel, b, lage), [])
	ziel = {"actor": "hero", "target": "foe1", "damage": 6, "roll": ["ATTACK", 15, 4, 13, true], "spell": "FIRE_BOLT", "cue": null}
	pruefe("Zauber uebt die Schule", Kampfuebung.benutzt(ziel, b, lage), ["Evokation"])
	ziel = {"actor": "foe1", "target": "hero", "damage": 3, "roll": ["ATTACK", 15, 4, 13, true], "spell": null, "cue": null}
	pruefe("Treffer auf den Helden", Kampfuebung.benutzt(ziel, b, lage), ["Mittlere Rüstung", "Schild"])
	ziel = {"actor": "foe1", "target": "hero", "damage": 0, "roll": ["ATTACK", 2, 4, 13, false], "spell": null, "cue": null}
	pruefe("Abwehr gegen Fehlschlag", Kampfuebung.benutzt(ziel, b, lage), ["Schild"])
	pruefe("Abwehr ohne Schild in der Hand", Kampfuebung.benutzt(ziel, b, lage.merged({"in_hand": false}, true)), ["Einhänder"])
	pruefe("Soeldner zaehlt nicht", Kampfuebung.benutzt(ziel, b, lage.merged({"feind": false}, true)), [])
	pruefe("Ansage ohne Wurf", Kampfuebung.benutzt({"actor": "foe1", "target": "hero", "damage": 0, "roll": null, "spell": null, "cue": "GROWL"}, b, lage), [])

	# Gutschrift: 12 Treffer mit dem Einhänder gegen Stufe 1 bei Heldenstufe 1 = 12 Uebung: 10 -> 11 (4), 11 -> 12 (4,2), Rest 3,8
	var u := Kampfuebung.new()
	u.zaehler = {"Einhänder|1": 12}
	u.gegner_hoechst = 1
	var s := BrsFertigkeit.neuer_stand({"Einhänder": 10})
	var h := Brs.neuer_stand()
	pruefe("verloren schreibt nichts gut", u.gutschreiben("LOST", s, h), [])
	pruefe("nach Niederlage gleich", BrsFertigkeit.wert(s, "Einhänder"), 10)
	var ev := u.gutschreiben("WON", s, h)
	pruefe("nach Sieg gestiegen", BrsFertigkeit.wert(s, "Einhänder"), 12)
	pruefe("Notiz", Kampfuebung.notiz(ev), ErschaffungBrs.fert_name("Einhänder") + " ↑ 12")

	# Spielstand
	var z := Zustand.new()
	z.brs = BrsHeld.neu("Mensch", "Wachsoldat").als_daten()
	var st := z.fertigkeiten_stand()
	pruefe("Stand aus den Startfertigkeiten", BrsFertigkeit.wert(st, "Einhänder"), 10)
	st["werte"]["Einhänder"] = 17
	var z2 := Zustand.aus_daten(JSON.parse_string(JSON.stringify(z.als_daten())))
	pruefe("Spielstand behaelt den Wert", BrsFertigkeit.wert(z2.fertigkeiten_stand(), "Einhänder"), 17)
	pruefe("Spielstand spiegelt in brs", int(z2.brs["fertigkeiten"]["Einhänder"]), 17)

	# ausserhalb des Kampfs: Handeln im Laden (Kauf und Verkauf je einmal Uebung, Ziel der eigenen Stufe), Notiz danach leer
	z2.gold = 500
	var la := Laden.new(["potion"], false)
	for i in 5: la.kaufe(z2, BrsHeld.fuer_spiel("Alrik", "Mensch", "Wachsoldat"), "potion")
	pruefe("Handeln bekannt und gestiegen", BrsFertigkeit.wert(z2.fert, "Handeln"), 2)
	pruefe("Heldenreiter liest Handeln", int(z2.brs["fertigkeiten"].get("Handeln", -1)), 2)
	pruefe("Notiz Handeln", z2.fert_notiz(), ErschaffungBrs.fert_name("Handeln") + " ↑ 2")
	pruefe("Notiz danach leer", z2.fert_notiz(), "")
	var ohne := Zustand.new()
	ohne.gold = 500
	la.kaufe(ohne, BrsHeld.fuer_spiel("Alrik", "Mensch", "Wachsoldat"), "potion")
	pruefe("ohne BRS-Held kein Stand", ohne.fert.is_empty(), true)

	# echter Kampf: Blatt des Probekampfs (Kaempfer) mit dem Helden nach BRS, Autopilot bis zum Ende
	var tab: Dictionary = Tabellen.lade()
	var a = Aufruf.new()
	root.add_child(a)
	var ende := []
	a.ende.connect(func(e, _tp, _lohn): ende.append(e))
	var held: Dictionary = tab.probe.FIGHTER.hero
	if not a.starte("RUDEL", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"brs": z.brs}):
		pruefe("Kampf gestartet", false, true)
	else:
		var k = a.kampf
		var ku := Kampfuebung.new()
		var vorher: Callable = k.mars.listener
		k.mars.listener = func(e):
			ku.hoere(e, k.mars, z.brs)
			if vorher.is_valid(): vorher.call(e)
		await process_frame
		await process_frame
		k.mars.set_autopilot(true)
		if not k.busy: k.go_on()
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 60000:
			await process_frame
			if k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty(): break
			if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
				if k.mars.pilot_next() or k.mars.set_autopilot(true): k.go_on()
				else:
					var c = k.mars.current()
					var ts: Array = k.mars.targets(c)
					k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		print("Kampf: %s, gezaehlt %s, Gegnerstufe hoechstens %d" % [k.mars.outcome, ku.zaehler, ku.gegner_hoechst])
		pruefe("Kampf zaehlt Benutzungen", ku.zaehler.is_empty(), false)
		pruefe("Gegnerstufe erkannt", ku.gegner_hoechst >= 1, true)
		var s2 := BrsFertigkeit.neuer_stand(z.brs["fertigkeiten"])
		var vor := (s2["werte"] as Dictionary).duplicate()
		var ev2 := ku.gutschreiben("WON", s2, Brs.neuer_stand())
		print("Nach Sieg: %s  Notiz „%s“" % [s2["werte"], Kampfuebung.notiz(ev2)])
		var summe := 0
		for f in s2["werte"]: summe += int(s2["werte"][f]) - int(vor.get(f, 0))
		for f in s2["uebung"]: summe += int(float(s2["uebung"][f]) > 0.0)     # 870.6: ein kurzer Sieg füllt erst die Übung (Würfelfolge anders)
		pruefe("Sieg schreibt Übung gut (Werte oder Übung)", summe > 0, true)
		k.finish()
		await process_frame
	print("KAMPFUEBUNG471 gut" if fehler == 0 else "KAMPFUEBUNG471 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
