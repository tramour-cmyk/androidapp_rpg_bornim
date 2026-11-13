extends SceneTree
# 841 (807 A, 807a A; STORY-K1-FERTIGKEITEN.md „Einschüchtern: Goblin-Späher“): mit einem Goblin-Späher wartet der Kampf zu Beginn auf
# „Kämpfen“ oder „Verjag den Späher (Einschüchtern)“. Gelingt es, flieht der Späher ([807.spaeher.ja]), der Kampf geht ohne ihn weiter;
# misslingt es, bleibt er ([807.spaeher.nein]). Nie gegen Krogg, Grak; nicht in kampf/probe.gd. Ohne Bild, im Spiel wie aus dem Reiter Test.
# Aufruf im Ordner godot: --headless -s res://tests/einschuechtern_841.gd   (Exit 0 = alles richtig)

const Wuerfel = preload("res://regeln/wuerfel.gd")
const Mars = preload("res://regeln/mars.gd")

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FALSCH %s %s" % [was, wie])
	else: print("ok %s" % was)

func _initialize() -> void: _lauf.call_deferred()


func _kampf(spiel, alt, gegner: String) -> Object:
	spiel.test_tat("probe", [gegner, "Wachsoldat", 3])
	var t0 := Time.get_ticks_msec()
	while (spiel.kampf == null or spiel.kampf == alt or spiel.kampf.mars == null) and Time.get_ticks_msec() - t0 < 15000: await process_frame
	for i in 3: await process_frame
	return spiel.kampf if spiel.kampf != alt else null


func _weg(spiel, k) -> void:
	k.finish()
	var t1 := Time.get_ticks_msec()
	while spiel.kampf != null and Time.get_ticks_msec() - t1 < 10000: await process_frame
	for i in 5: await process_frame


func _texte(k) -> Array:
	var r := []
	for b in k.ui.orders.find_children("*", "Button", true, false): r.append(String(b.text))
	return r


func _bis_ruhig(k) -> void:
	var t0 := Time.get_ticks_msec()
	while (k.busy or k.playing or not k.beats.is_empty()) and Time.get_ticks_msec() - t0 < 20000: await process_frame


## [wurf]: die Zahl, die der Würfel der Probe gibt (0 gelingt immer, 99 misslingt immer)
func _verjagen(spiel, alt, wurf: int) -> Object:
	var k = await _kampf(spiel, alt, "SCOUT")
	if k == null: pruefe("Kampf gegen Späher kommt", false); return null
	pruefe("Wahl zu Beginn steht (Wurf %d)" % wurf, String(k.tor) == "einschuechtern" and not k.busy, "tor %s busy %s" % [k.tor, k.busy])
	var texte := _texte(k)
	pruefe("Knöpfe „Kämpfen“ und „Verjag den Späher (Einschüchtern)“", texte.has("KÄMPFEN") and texte.has("VERJAG DEN SPÄHER (EINSCHÜCHTERN)"), str(texte))
	var s = k.mars.spaeher_zum_verjagen()
	var h = k.mars.lead()
	print("Chance %.0f %% (Einschüchtern %d, Stufe %d gegen %d)" % [k.mars.einschuechtern_chance(h, s), int(h.b.get("fert", {}).get("Einschüchtern", 0)), int(h.b.get("stufe", 1)), int(s.b.get("stufe", 1))])
	# 1084 (1051 A): 30 % + 0,6 je Punkt Einschüchtern + 5 je Stufe über dem Späher, 5 bis 95
	var soll := clampf(30.0 + 0.6 * float(h.b.get("fert", {}).get("Einschüchtern", 0)) + 5.0 * float(int(h.b.get("stufe", 1)) - int(s.b.get("stufe", 1))), 5.0, 95.0)
	pruefe("Chance nach 1051 A (%.1f %%)" % soll, absf(k.mars.einschuechtern_chance(h, s) - soll) < 0.01, "%.2f" % k.mars.einschuechtern_chance(h, s))
	var echt = k.mars.dice
	k.mars.dice = Wuerfel.new([wurf])
	k.tor_wahl(true)
	await _bis_ruhig(k)
	k.mars.dice = echt
	return k


func _lauf() -> void:
	Engine.time_scale = 8.0
	Testmodus.probe_zug = ""; Testmodus.probe_ausweichen = false; Testmodus.probe_soeldner = ""
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	# gelingt: der Späher flieht mit einer Zeile aus [807.spaeher.ja], der Goblin bleibt, der Kampf geht weiter
	var k = await _verjagen(spiel, null, 0)
	if k == null: quit(1); return
	var s = k.mars.find("scout")
	pruefe("gelingt: Späher geflohen und verjagt", s != null and s.fled and s.verjagt and not s.standing())
	pruefe("gelingt: Goblin bleibt, Kampf läuft", k.mars.outcome == "ONGOING" and k.mars.find("gob1").standing(), k.mars.outcome)
	var zeilen := " | ".join(k.ui.lines.map(func(l): return str(l)))
	pruefe("gelingt: Zeile aus [807.spaeher.ja]", Mars.MSG841_JA.any(func(v): return zeilen.contains(String(v[0]))), zeilen.left(300))
	pruefe("Einschüchtern geübt (Kampfuebung)", Kampfuebung.benutzt({"cue": "INTIMIDATE", "actor": "hero", "target": "scout"}, {}, {}) == ["Einschüchtern"])
	k.mars.set_autopilot(true)
	if not k.busy: k.go_on()
	var t0 := Time.get_ticks_msec()
	while k.mars.outcome == "ONGOING" and Time.get_ticks_msec() - t0 < 60000:
		await process_frame
		if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
			if k.mars.pilot_next() or k.mars.set_autopilot(true): k.go_on()
	await _bis_ruhig(k)
	pruefe("gelingt: Kampf gegen den Rest zu Ende", k.mars.outcome != "ONGOING", k.mars.outcome)
	if k.mars.outcome == "WON":
		pruefe("gelingt: Erfahrung auch für den Späher", int(k.reward.get("xp", 0)) > 0, str(k.reward.get("lines", [])))
	var alt = k
	await _weg(spiel, k)
	# misslingt: der Späher bleibt mit einer Zeile aus [807.spaeher.nein]
	k = await _verjagen(spiel, alt, 99)
	if k == null: quit(1); return
	s = k.mars.find("scout")
	pruefe("misslingt: Späher bleibt", s != null and s.standing() and not s.verjagt)
	zeilen = " | ".join(k.ui.lines.map(func(l): return str(l)))
	pruefe("misslingt: Zeile aus [807.spaeher.nein]", Mars.MSG841_NEIN.any(func(v): return zeilen.contains(String(v[0]))), zeilen.left(300))
	pruefe("misslingt: Kampf läuft mit allen", k.mars.outcome == "ONGOING" and k.mars.started)
	alt = k
	await _weg(spiel, k)
	# „Kämpfen“: kein Versuch, Kampf wie bisher
	k = await _kampf(spiel, alt, "SCOUT")
	if k != null:
		k.tor_wahl(false)
		await _bis_ruhig(k)
		pruefe("Kämpfen: kein Versuch, Späher steht", k.mars.find("scout").standing() and k.mars.started and String(k.tor) == "")
		alt = k
		await _weg(spiel, k)
	# nie gegen Grak; ohne Späher keine Wahl
	for g in ["GRAK", "WOLVES"]:
		k = await _kampf(spiel, alt, g)
		if k == null: pruefe("Kampf %s kommt" % g, false); continue
		pruefe("%s: keine Wahl zu Beginn" % g, String(k.tor) == "" and (k.busy or k.mars.started), "tor %s busy %s started %s" % [k.tor, k.busy, k.mars.started])
		alt = k
		await _weg(spiel, k)
	Engine.time_scale = 1.0
	print("EINSCHUECHTERN841 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
