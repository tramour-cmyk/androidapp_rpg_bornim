extends SceneTree
# 532 ohne Bild (Durchspielregel 488; t273.13): die ganze Tasche im MARS-Kampf wie im alten (Battle.useItem), nach dem BRS (870.4:
# Heilung des Helden aus werte.json „welt“ „heilung“). Großer Heiltrank heilt mehr als der einfache, der Kräutertrank nimmt
# Zustände (der Rausch bleibt), voll und ohne Zustände ist er nicht wählbar; aufruf.gd nimmt aus lage „tasche“ nur, was man im
# Kampf trinkt (kein Ausdauertrank, kein Leuchtfunke, kein Fleisch; Wurfmittel erst mit 935). Die Liste der Tasche im Kampfort
# (kampf_ui.gd „bag“) läuft nicht aus dem Schirm und lässt den Kasten gleich hoch.
# Aufruf: im Ordner godot mit -s res://tests/tasche_532.gd -> „TASCHE532 ok“; BILD=<datei.png> mit Fenster: Bild der offenen Tasche
const Mars = preload("res://regeln/mars.gd")
const AufrufS = preload("res://kampf/aufruf.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

var f := 0

func pruefe(was: String, ist, soll) -> void:
	if ist == soll:
		print("ok ", was)
	else:
		f += 1
		print("FEHLER %s: %s statt %s" % [was, str(ist), str(soll)])

func _initialize() -> void: _lauf.call_deferred()

func _kampf(tab, a, skills, monsters, seed: int, tasche: Dictionary):
	var held = a._kaempfer("hero", tab.probe.FIGHTER.hero.hero, int(tab.probe.FIGHTER.hero.hp), Vector2i(Mars.FRONT, 0), skills)
	var foes = AufrufS.gegner("RATTE", monsters, Wuerfel.new(seed + 1))
	var m = Mars.new([held], foes, tab, Wuerfel.new(seed), Wuerfel.new(seed + 279), 0, false, "HERO_FIRST")
	for k in tasche: m.potions[k] = int(tasche[k])
	m.start(func(_t, _x): return "NONE")
	return m

func _lauf() -> void:
	var tab = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var skills := {}
	for s in tab.skills: skills[s.id] = s
	var monsters := {}
	for m in tab.monsters: monsters[m.id] = m
	var a = AufrufS.new()
	a.tabellen = tab
	var voll := {"potion": 1, "greater_potion": 1, "superior_potion": 1, "remedy": 1, "alchemist_fire": 2}

	# Tasche: Tränke trinkbar, Wurfmittel noch nicht (935)
	var m = _kampf(tab, a, skills, monsters, 1, voll)
	var held = m.find("hero")
	pruefe("trinkbar", m.drinkable(), ["potion", "greater_potion", "superior_potion", "remedy"])
	pruefe("Tasche", m.bag(), ["potion", "greater_potion", "superior_potion", "remedy"])
	pruefe("voll: Heiltrank bringt nichts", m.drink_helps("potion", held), false)
	pruefe("voll ohne Zustände: Kräutertrank bringt nichts", m.drink_helps("remedy", held), false)

	# Kräutertrank: Gift weg, Rausch bleibt
	held.status = {"POISON": 3, "DRUNK": Mars.LASTING}
	pruefe("mit Gift: Kräutertrank hilft", m.drink_helps("remedy", held), true)
	if m.outcome == "ONGOING" and m.current() == held:
		m.act(["drink", "remedy", "hero"], func(_t, _x): return "NONE")
		pruefe("Gift geheilt", held.status.has("POISON"), false)
		pruefe("Rausch bleibt", held.status.has("DRUNK"), true)
		pruefe("Kräutertrank verbraucht", int(m.potions["remedy"]), 0)
	else:
		f += 1; print("FEHLER Held nicht am Zug (Kräutertrank)")

	# Großer Heiltrank heilt mehr als der einfache, der überragende mehr als der große
	var heil := {"potion": 0, "greater_potion": 0, "superior_potion": 0}
	for id in heil:
		for seed in 20:
			var m3 = _kampf(tab, a, skills, monsters, 300 + seed, {id: 1})
			var h3 = m3.find("hero")
			if m3.outcome != "ONGOING" or m3.current() != h3: continue
			h3.max_hp = 200
			h3.hp = 1
			m3.act(["drink", id, "hero"], func(_t, _x): return "NONE")
			heil[id] += h3.hp - 1
	print("Heilung über 20 Kämpfe: ", heil)
	pruefe("Großer Heiltrank heilt mehr", heil.greater_potion > heil.potion, true)
	pruefe("Überragender heilt mehr", heil.superior_potion > heil.greater_potion, true)

	# aufruf.gd: nur, was man im Kampf trinkt
	var held_d = tab.probe.FIGHTER.hero.hero
	root.add_child(a)
	var ok: bool = a.starte("RATTE", held_d, null, "wald", "tag", 0, int(tab.probe.FIGHTER.hero.hp), -1, 5, Callable(),
			{"tasche": {"potion": 2, "remedy": 1, "stamina_potion": 1, "spark_potion": 1, "alchemist_fire": 1, "raw_meat": 3}})
	pruefe("Kampf beginnt", ok, true)
	if ok:
		pruefe("Tasche im Kampf", a.kampf.mars.potions, {"potion": 2, "remedy": 1})
		# die Liste der Tasche: zehn Dinge, der Kasten bleibt gleich hoch, keine Zeile ragt aus dem Schirm
		var k = a.kampf
		for i in 1800:     # bis der Held wählt (Blende und Eröffnung laufen)
			await process_frame
			if k.ui != null and not k.busy and not k.playing and k.beats.is_empty() and k.mars.current() == k.mars.find("hero"):
				break
		var ui = k.ui
		if ui == null:
			f += 1; print("FEHLER kein Kampf-UI")
		else:
			for id in ["potion", "greater_potion", "superior_potion", "remedy"]:
				k.mars.potions[id] = 10
			ui.pick = "main"
			ui._build_orders()
			for i in 3:
				await process_frame
			var h0: float = ui.panel.size.y
			ui._set_pick("bag")
			for i in 3:
				await process_frame
			var breite: float = root.get_visible_rect().size.x
			var raus := 0
			var knoepfe := 0
			for b in ui.orders.find_children("*", "Button", true, false):
				if not b.is_visible_in_tree():
					continue
				knoepfe += 1
				if b.get_global_rect().end.x > breite + 0.5:
					raus += 1
			if OS.get_environment("BILD") != "":     # Probebild am Rechner (mit Fenster): die offene Tasche
				for i in 10:
					await process_frame
				root.get_texture().get_image().save_png(OS.get_environment("BILD"))
			pruefe("Knöpfe der Tasche (4 Dinge, Zurück)", knoepfe, 5)
			pruefe("keine Zeile aus dem Schirm", raus, 0)
			pruefe("Kasten gleich hoch (%.0f gegen %.0f px)" % [ui.panel.size.y, h0], absf(ui.panel.size.y - h0) <= 2.0, true)
			ui._set_pick("main")
			for i in 3:
				await process_frame
			pruefe("Bericht wieder da", ui.log_box.visible, true)
	print("TASCHE532 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
