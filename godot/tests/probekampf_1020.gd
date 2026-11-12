extends SceneTree
# 1020.2 B (Chef 12.11., 08:09; Vorlage 1020 B): Probekampf-Baukasten im Reiter „Test“. Ohne Bild: Held und Söldner nach der Wahl
# (Volk, Herkunft, Waffe auch Bogen und Zweihänder, andere Hand, Söldner keiner oder eigene Herkunft, Tasche, Leben), der Reiter zeigt
# die Schalter ohne Überlappung und ohne zu breiten Knopftext, „Probekampf starten“ sendet die Wahl mit dem Zeichen für „Zurück zum
# Testmenü“, der Kampfort kennt den Text des Knopfs. Aufruf im Ordner godot: --headless -s res://tests/probekampf_1020.gd

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FALSCH %s %s" % [was, wie])
	else: print("ok %s" % was)

func _kampf_da(spiel, alt) -> Object:
	var t0 := Time.get_ticks_msec()
	while (spiel.kampf == null or spiel.kampf == alt or spiel.kampf.mars == null) and Time.get_ticks_msec() - t0 < 15000: await process_frame
	return spiel.kampf if spiel.kampf != alt else null

func _zu_ende(k) -> void:
	k.mars.set_autopilot(true)
	if not k.busy: k.go_on()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 60000:
		await process_frame
		if k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty(): break
		if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
			if k.mars.pilot_next() or k.mars.set_autopilot(true): k.go_on()
			else:
				var ts: Array = k.mars.targets(k.mars.current())
				k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])

## im Spiel wie aus dem Reiter: Bogen, kein Söldner, volle Tasche, halbes Leben, Nacht; nach dem Kampf „Nochmal“ (derselbe Aufbau),
## dann „Zurück zum Testmenü“ (das Menü steht auf dem Reiter Test)
func _im_spiel() -> void:
	Engine.time_scale = 30.0
	Testmodus.probe_volk = "Mensch"; Testmodus.probe_waffe = "longbow"; Testmodus.probe_neben = "*"; Testmodus.probe_soeldner = ""
	Testmodus.probe_tasche = "voll"; Testmodus.probe_leben = "halb"; Testmodus.probe_zeit = "nacht"
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.test_tat("probe", ["WOLVES", "Herumtreiber", 3, true])
	var vorige = null
	for runde in 2:
		var k = await _kampf_da(spiel, vorige)
		if k == null: pruefe("Kampf %d kommt" % (runde + 1), false); return
		var party: Array = k.mars.fighters().filter(func(f): return f.side == "PARTY")
		var held = k.mars.find("hero")
		pruefe("Runde %d: ohne Söldner" % (runde + 1), party.size() == 1, str(party.size()))
		pruefe("Runde %d: höchstens halbes Leben" % (runde + 1), held != null and held.hp > 0 and held.hp * 2 <= held.max_hp + 1, "%d/%d" % [held.hp, held.max_hp] if held else "")
		pruefe("Runde %d: Nacht" % (runde + 1), String(k.tageszeit) == "nacht", String(k.tageszeit))
		pruefe("Runde %d: Brandflaschen in der Tasche" % (runde + 1), int(k.mars.potions.get("alchemist_fire", 0)) > 0, str(k.mars.potions))
		pruefe("Runde %d: Knopf heißt „Zurück zum Testmenü“" % (runde + 1), k.again_fn.is_valid() and k.zurueck_text.size() == 2 and String(k.zurueck_text[0]) == "Zurück zum Testmenü")
		await _zu_ende(k)
		vorige = k
		if runde == 0: k.again()
		else: k.finish()
	var t0 := Time.get_ticks_msec()
	var menue: Node = null
	while menue == null and Time.get_ticks_msec() - t0 < 15000:
		await process_frame
		var ms: Array = spiel.find_children("*", "Menue", true, false)
		if not ms.is_empty(): menue = ms[0]
	pruefe("zurück im Testmenü", menue != null and String(menue.reiter) == "test", String(menue.reiter) if menue else "kein Menü")
	if menue: menue.zu.emit()
	for i in 10: await process_frame
	await _erzwingen(spiel)
	Engine.time_scale = 1.0

## 1020.2 C: der erzwungene Gegnerzug kommt im ersten passenden Augenblick, im echten Spiel nie
func _erzwingen(spiel) -> void:
	var Mars = load("res://regeln/mars.gd")
	Testmodus.probe_waffe = "*"; Testmodus.probe_soeldner = "*"; Testmodus.probe_tasche = "zwei"; Testmodus.probe_leben = "voll"; Testmodus.probe_zeit = ""
	var faelle := [["GRAK", "heavy"], ["WOLVES", "pounce"], ["GOBLINS", "reihe"], ["GOBLINS", "flucht"]]
	var vorige = spiel.kampf
	for fa in faelle:
		Testmodus.probe_zug = String(fa[1])
		Mars.test_erzwungen.clear()
		spiel.test_tat("probe", [String(fa[0]), "Wachsoldat", 3])
		var k = await _kampf_da(spiel, vorige)
		if k == null: pruefe("Kampf %s kommt" % fa[0], false); return
		vorige = k
		var gesehen := false
		k.mars.set_autopilot(true)
		if not k.busy: k.go_on()
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 60000 and not gesehen:
			await process_frame
			gesehen = Mars.test_erzwungen.has(String(fa[1]))
			if k.mars.outcome != "ONGOING" and not gesehen: break
			if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
				if k.mars.pilot_next() or k.mars.set_autopilot(true): k.go_on()
		if String(fa[1]) == "flucht":
			pruefe("alle geflohen, gewonnen", k.mars.outcome == "WON" and k.mars.fighters().filter(func(f): return f.side == "FOES").all(func(f): return f.fled))
		pruefe("erzwungen: %s gegen %s" % [fa[1], fa[0]], gesehen)
		pruefe("nur einmal: %s" % fa[1], Mars.test_gegnerzug == "", Mars.test_gegnerzug)
		await _zu_ende(k)
		k.finish()
		var t1 := Time.get_ticks_msec()
		while spiel.kampf != null and Time.get_ticks_msec() - t1 < 10000: await process_frame
	# Held weicht aus: der erste Angriff auf ihn geht fehl (Leben nicht prüfbar: der Regelfaden rechnet voraus)
	Testmodus.probe_zug = ""; Testmodus.probe_ausweichen = true; Testmodus.probe_soeldner = ""
	Mars.test_erzwungen.clear()
	spiel.test_tat("probe", ["WOLVES", "Klosterschüler", 3])
	var k1 = await _kampf_da(spiel, vorige)
	if k1 != null:
		vorige = k1
		k1.mars.set_autopilot(true)
		if not k1.busy: k1.go_on()
		var t2 := Time.get_ticks_msec()
		while Mars.test_ausweichen and k1.mars.outcome == "ONGOING" and Time.get_ticks_msec() - t2 < 60000:
			await process_frame
			if not k1.busy and not k1.playing and k1.beats.is_empty() and k1.mars.outcome == "ONGOING":
				if k1.mars.pilot_next() or k1.mars.set_autopilot(true): k1.go_on()
		pruefe("Held weicht dem ersten Angriff aus", not Mars.test_ausweichen and Mars.test_erzwungen.has("ausweichen"), str(Mars.test_erzwungen))
		await _zu_ende(k1)
		k1.finish()
		var t3 := Time.get_ticks_msec()
		while spiel.kampf != null and Time.get_ticks_msec() - t3 < 10000: await process_frame
	Testmodus.probe_ausweichen = false
	Testmodus.probe_zug = "flucht"
	spiel.test_tat("kampf", ["GOBLINS"])
	var k2 = await _kampf_da(spiel, vorige)
	pruefe("im beschworenen Kampf nichts erzwungen", k2 != null and Mars.test_gegnerzug == "" and not Mars.test_ausweichen)
	Testmodus.probe_zug = ""

func _basis(h: BrsHeld, platz: String) -> String:
	var g = h.ding(platz)
	return String(g["base"]) if g != null else ""

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	# wie bisher: Söldner wie der Held, 2 Heiltränke, volles Leben, Ausrüstung der Herkunft
	var a := Testmodus.probe_aufbau("Wachsoldat", 3)
	var h: BrsHeld = a["held"]
	pruefe("Vorgabe Held", h.herkunft == "Wachsoldat" and h.stufe == 3 and h.volk == "Mensch" and h.leben == h.max_leben(), "%s %d %s %d/%d" % [h.herkunft, h.stufe, h.volk, h.leben, h.max_leben()])
	pruefe("Vorgabe Söldner wie der Held", a["soeldner"] != null and (a["soeldner"] as BrsHeld).herkunft == "Wachsoldat")
	pruefe("Vorgabe Tasche", a["tasche"] == {"potion": 2}, str(a["tasche"]))
	pruefe("Vorgabe Tageszeit Spieluhr", String(a["zeit"]) == "")
	var start := Testmodus.probeheld("Wachsoldat", 3)
	pruefe("Vorgabe Waffe der Herkunft", _basis(h, "MAIN_HAND") == _basis(start, "MAIN_HAND") and _basis(h, "OFF_HAND") == _basis(start, "OFF_HAND"),
		"%s/%s" % [_basis(h, "MAIN_HAND"), _basis(h, "OFF_HAND")])
	# Bogen: zweihändig, die andere Hand bleibt leer, auch mit Schild gewählt; Kampfblatt mit Waffengruppe Bogen
	Testmodus.probe_waffe = "longbow"; Testmodus.probe_neben = "shield"
	h = Testmodus.probe_aufbau("Wachsoldat", 3)["held"]
	var blatt: Dictionary = h.kampfblatt(h.stufe, h.getragen(), h.geuebt)
	pruefe("Bogen", _basis(h, "MAIN_HAND") == "longbow" and _basis(h, "OFF_HAND") == "", "%s/%s" % [_basis(h, "MAIN_HAND"), _basis(h, "OFF_HAND")])
	pruefe("Bogen im Kampfblatt", str(blatt).contains("Bogen"), str(blatt.get("waffe", {})))
	Testmodus.probe_waffe = "greatsword"; Testmodus.probe_neben = "*"
	h = Testmodus.probe_aufbau("Herumtreiber", 5)["held"]
	pruefe("Zweihänder", _basis(h, "MAIN_HAND") == "greatsword" and _basis(h, "OFF_HAND") == "", "%s/%s" % [_basis(h, "MAIN_HAND"), _basis(h, "OFF_HAND")])
	Testmodus.probe_waffe = "longsword"
	for n in ["", "shield", "round_shield", "dagger"]:
		Testmodus.probe_neben = n
		h = Testmodus.probe_aufbau("Wachsoldat", 3)["held"]
		pruefe("Langschwert und andere Hand „%s“" % n, _basis(h, "MAIN_HAND") == "longsword" and _basis(h, "OFF_HAND") == n, "%s/%s" % [_basis(h, "MAIN_HAND"), _basis(h, "OFF_HAND")])
	Testmodus.probe_waffe = ""; Testmodus.probe_neben = ""
	h = Testmodus.probe_aufbau("Wachsoldat", 3)["held"]
	pruefe("ohne Waffe", _basis(h, "MAIN_HAND") == "" and _basis(h, "OFF_HAND") == "")
	# Söldner keiner, eigene Herkunft; Tasche, Leben, Volk, Tageszeit
	Testmodus.probe_waffe = "*"; Testmodus.probe_neben = "*"
	Testmodus.probe_soeldner = ""
	pruefe("kein Söldner", Testmodus.probe_aufbau("Wachsoldat", 3)["soeldner"] == null)
	Testmodus.probe_soeldner = "Zauberlehrling"
	var s = Testmodus.probe_aufbau("Wachsoldat", 3)["soeldner"]
	pruefe("Söldner eigene Herkunft", s != null and (s as BrsHeld).herkunft == "Zauberlehrling" and (s as BrsHeld).stufe == 3)
	Testmodus.probe_tasche = "voll"
	var ta: Dictionary = Testmodus.probe_aufbau("Wachsoldat", 3)["tasche"]
	pruefe("Tasche mit Brandflaschen", int(ta.get("alchemist_fire", 0)) > 0 and int(ta.get("potion", 0)) > 0, str(ta))
	Testmodus.probe_tasche = "keine"
	pruefe("Tasche leer", (Testmodus.probe_aufbau("Wachsoldat", 3)["tasche"] as Dictionary).is_empty())
	Testmodus.probe_leben = "halb"
	h = Testmodus.probe_aufbau("Wachsoldat", 3)["held"]
	pruefe("Leben halb", h.leben == roundi(h.max_leben() * 0.5), "%d/%d" % [h.leben, h.max_leben()])
	Testmodus.probe_leben = "knapp"
	h = Testmodus.probe_aufbau("Wachsoldat", 3)["held"]
	pruefe("Leben knapp", h.leben >= 1 and h.leben <= h.max_leben() / 4, "%d/%d" % [h.leben, h.max_leben()])
	var voelker: Array = BrsHeld.voelker()
	Testmodus.probe_volk = String(voelker[voelker.size() - 1])
	h = Testmodus.probe_aufbau("Wachsoldat", 3)["held"]
	pruefe("Volk", h.volk == Testmodus.probe_volk, "%s %s" % [h.volk, str(voelker)])
	Testmodus.probe_zeit = "nacht"
	pruefe("Tageszeit Nacht", String(Testmodus.probe_aufbau("Wachsoldat", 3)["zeit"]) == "nacht")
	# Reiter: jede Gruppe gilt als da (sonst fehlt der Abschnitt ohne gebaute Modelle), Liste der Waffen offen
	var foes: Dictionary = load("res://kampf/probe.gd").FOES
	for g in foes: Testmodus._gruppe_da[g] = true
	Testmodus.an = true; Testmodus.geladen = true
	Testmodus.probe_waffen_auf = true
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", "Zauberlehrling", z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	m.reiter = "test"; m.baue()
	for i in 8: await process_frame
	var worte: Array = m.inhalt.find_children("*", "Zeichenknopf", true, false).map(func(k): return String(k.wort))
	for w in ["Herkunft", "Volk", "Waffe", "Andere Hand", "Söldner", "Tasche", "Leben", "Tageszeit", "Eröffnung", "Kampfort"]:
		pruefe("Schalter %s" % w, worte.has(w), str(worte))
	var knoepfe: Array = m.inhalt.find_children("*", "Button", true, false).filter(func(b): return not (b is Zeichenknopf))
	var texte: Array = knoepfe.map(func(b): return String(b.text).to_upper())
	pruefe("Bogen und Zweihänder in der Liste", texte.any(func(x): return x.begins_with("LANGBOGEN")) and texte.any(func(x): return x.begins_with("ZWEIHÄNDER")), str(texte))
	var vor: Control = null
	for c in m.inhalt.get_children():
		if not (c is Control) or not c.visible: continue
		if vor != null and c.get_global_rect().position.y < vor.get_global_rect().end.y - 0.5: pruefe("Überlappung", false, String(c.get_class()))
		vor = c
	for b in knoepfe:
		if String(b.text) == "": continue
		var f: Font = b.get_theme_font("font")
		var w := f.get_multiline_string_size(b.text, HORIZONTAL_ALIGNMENT_CENTER, b.size.x - 12 * Menue.DP, b.get_theme_font_size("font_size"),
			-1, TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND if b.autowrap_mode != TextServer.AUTOWRAP_OFF else TextServer.BREAK_MANDATORY)
		if not (w.x <= b.size.x - 12 * Menue.DP + 1 and w.y <= b.size.y): pruefe("Knopftext", false, "„%s“" % b.text)
	var gesendet := []
	m.test.connect(func(was, mit): gesendet.append([was, mit]))
	var los = knoepfe.filter(func(b): return String(b.text).to_upper() == "PROBEKAMPF STARTEN")
	pruefe("Knopf Probekampf starten", los.size() == 1)
	if los.size() == 1:
		los[0].pressed.emit()
		for i in 2: await process_frame
		pruefe("startet mit der Wahl", gesendet.size() == 1 and gesendet[0][0] == "probe" and (gesendet[0][1] as Array).size() == 4 and bool(gesendet[0][1][3]), str(gesendet))
	var k = load("res://kampf/kampfort.gd").new()
	pruefe("Kampfort kennt den Text für „Zurück“", "zurueck_text" in k and "again_fn" in k)
	k.free()
	m.queue_free()
	await _im_spiel()
	print("PROBEKAMPF1020 ", "gut" if fehler == 0 else "FALSCH %d" % fehler)
	quit(1 if fehler else 0)
