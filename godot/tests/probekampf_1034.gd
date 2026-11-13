extends SceneTree
# 1034 (Chef 12.11., 14:34–14:38): ein Probekampf für alles. Ohne Bild, im Spiel wie aus dem Reiter „Test“:
# (1) Testheld gegen Grak: Held mit dem Namen des eigenen Helden, Söldner mit Namen aus [72.10a.5.namen] (nie „Probe“), das Siegfenster
#     sagt zuerst „ohne Folgen“, keine Geschichtsgegenstände als Beute, Gold und Siege im Spielstand bleiben.
# (2) Spielheld gegen Wölfe mit Söldner wie der Held: zählt im Spielstand (Siege), „Nochmal“ schreibt gut und startet denselben Kampf,
#     nach einer Niederlage kein „Nochmal“, danach „Zurück zum Testmenü“.
# Aufruf im Ordner godot: --headless -s res://tests/probekampf_1034.gd

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FALSCH %s %s" % [was, wie])
	else: print("ok %s" % was)

func _kampf_da(spiel, alt) -> Object:
	var t0 := Time.get_ticks_msec()
	while (spiel.kampf == null or spiel.kampf == alt or spiel.kampf.mars == null) and Time.get_ticks_msec() - t0 < 15000: await process_frame
	return spiel.kampf if spiel.kampf != alt else null

## Autopilot für den Helden; der Söldner steht im Kampf auf „selbst“ (Fighter.auto), ohne Auto wartet MARS auf seinen Befehl
func _zu_ende(k) -> void:
	var mc = k.mars.find("merc")
	if mc != null: mc.auto = true
	k.mars.set_autopilot(true)
	if not k.busy: k.go_on()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 90000:
		await process_frame
		if k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty(): break
		if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
			if k.mars.pilot_next() or k.mars.set_autopilot(true): k.go_on()
			else:
				var ts: Array = k.mars.targets(k.mars.current())
				k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])

func _menue(spiel) -> Node:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 15000:
		await process_frame
		var ms: Array = spiel.find_children("*", "Menue", true, false)
		if not ms.is_empty(): return ms[0]
	return null

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var Mars = load("res://regeln/mars.gd")
	var Lohn = load("res://regeln/lohn.gd")
	Engine.time_scale = 30.0
	Mars.held_unsterblich = true; Mars.held_immer_krit = true
	Testmodus.probe_soeldner = "*"; Testmodus.probe_zug = ""; Testmodus.probe_ausweichen = false
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.name = "Mira"
	spiel.held_werte().name = "Mira"
	var gold0: int = spiel.zustand.gold
	var siege0: int = spiel.zustand.siege
	# (1) Testheld
	spiel.test_tat("probe", ["GRAK", "Wachsoldat", 11, true, "test"])
	var k = await _kampf_da(spiel, null)
	if k == null: pruefe("Testheld: Kampf kommt", false); _schluss(); return
	var held = k.mars.find("hero")
	var merc = k.mars.find("merc")
	pruefe("Testheld heißt wie der eigene Held", held != null and held.name(0) == "Mira", held.name(0) if held else "")
	pruefe("Söldner mit Namen, nicht „Probe“", merc != null and merc.name(0) == "Bertram", merc.name(0) if merc else "kein Söldner")
	pruefe("Testheld: ohne Folgen", bool(k.ohne_folgen))
	await _zu_ende(k)
	pruefe("Testheld gewinnt gegen Grak", k.mars.outcome == "WON", String(k.mars.outcome))
	var zeilen: Array = k.reward.get("lines", [])
	pruefe("Siegfenster sagt zuerst „ohne Folgen“", not zeilen.is_empty() and String(zeilen[0]) == String(Lohn.PROBE[0]), str(zeilen))
	# 1096: zweite Zeile grau „Ein echter Kampf brächte: … EP, … Gold“, dann nur Beute; keine Stufen, Grenze, Heilsatz
	var echt: String = String(Lohn.ECHT[0]).replace("{0}", "")
	var zweite: String = String(zeilen[1]) if zeilen.size() > 1 else ""
	pruefe("1096: zweite Zeile „Ein echter Kampf brächte“, grau", zweite.begins_with(echt) and k.reward.get("grau", []) == [1], str(zeilen))
	var verboten: Array = []
	for z in zeilen:
		var zz := String(z)
		if " erreicht Heldenstufe " in zz or zz == String(Lohn.GRENZE[0]) or "wieder voll" in zz or " erhält " in zz or zz.begins_with("Du erbeutest"):
			verboten.append(zz)
	pruefe("1096: keine Stufen, Grenze, Heilsatz, EP- oder Goldzeile", verboten.is_empty(), str(verboten))
	var schluessel: Array = (k.reward.get("items", []) as Array).filter(func(it): return Lohn._schluessel(String(it)))
	pruefe("keine Geschichtsgegenstände als Probebeute", schluessel.is_empty(), str(k.reward.get("items", [])))
	k.finish()
	var m = await _menue(spiel)
	pruefe("Testheld: Spielstand unberührt", spiel.zustand.gold == gold0 and spiel.zustand.siege == siege0, "Gold %d→%d, Siege %d→%d" % [gold0, spiel.zustand.gold, siege0, spiel.zustand.siege])
	if m: m.zu.emit()
	for i in 10: await process_frame
	# (2) Spielheld mit Söldner wie der Held, zweimal (Nochmal), dann zurück
	spiel.test_tat("probe", ["WOLVES", "Wachsoldat", 3, true, "spiel"])
	var vorige = k
	for runde in 2:
		var k2 = await _kampf_da(spiel, vorige)
		if k2 == null: pruefe("Spielheld: Kampf %d kommt" % (runde + 1), false); break
		vorige = k2
		var h2 = k2.mars.find("hero")
		var s2 = k2.mars.find("merc")
		pruefe("Runde %d: der eigene Held" % (runde + 1), h2 != null and h2.name(0) == "Mira", h2.name(0) if h2 else "")
		pruefe("Runde %d: Söldner wie der Held" % (runde + 1), s2 != null and s2.name(0) == "Bertram" and String(s2.hero.get("herkunft", "")) == spiel.held_werte().herkunft,
			"%s %s" % [s2.name(0), str(s2.hero.get("herkunft", ""))] if s2 else "kein Söldner")
		pruefe("Runde %d: zählt im Spielstand" % (runde + 1), not bool(k2.ohne_folgen) and k2.again_fn.is_valid() and bool(k2.again_nicht_nach_niederlage))
		await _zu_ende(k2)
		pruefe("Runde %d: gewonnen" % (runde + 1), k2.mars.outcome == "WON", String(k2.mars.outcome))
		var z2: Array = k2.reward.get("lines", [])
		pruefe("Runde %d: kein „ohne Folgen“" % (runde + 1), z2.is_empty() or String(z2[0]) != String(Lohn.PROBE[0]), str(z2))
		pruefe("Runde %d: Spielheld ohne „Ein echter Kampf“ (1096)" % (runde + 1), not z2.any(func(z): return String(z).begins_with("Ein echter Kampf")), str(z2))
		if runde == 0:
			k2.again()
			for i in 5: await process_frame
			pruefe("Nochmal: der Sieg ist gutgeschrieben", spiel.zustand.siege == siege0 + 1, "Siege %d→%d" % [siege0, spiel.zustand.siege])
		else: k2.finish()
	var m2 = await _menue(spiel)
	pruefe("Spielheld: zwei Siege im Spielstand", spiel.zustand.siege == siege0 + 2, "Siege %d→%d" % [siege0, spiel.zustand.siege])
	pruefe("zurück im Testmenü", m2 != null and String(m2.reiter) == "test", String(m2.reiter) if m2 else "kein Menü")
	Mars.held_unsterblich = false; Mars.held_immer_krit = false
	_schluss()

func _schluss() -> void:
	Engine.time_scale = 1.0
	print("PROBEKAMPF1034 ", "gut" if fehler == 0 else "FALSCH %d" % fehler)
	quit(1 if fehler else 0)
