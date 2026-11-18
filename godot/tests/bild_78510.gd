# 785.10 Bilder für den Chef (Renderer wie am Handy): (1) leichter Kampf zu Beginn, Zeile [259T.frage], „Kämpfen“ und „Schnell“,
# Kasten des Helden mit Erfahrungsbalken und „St. n“; (2) am Zug der Gruppe der Eckknopf „Schnell ›“ unten links; (3) Siegschirm
# nach „Schnell“: Verlust je Gefährte, Beute in Seltenheitsfarbe (ein Stück je Seltenheit Gewöhnlich bis Episch, nur für das Bild).
# Aufruf: godot --path godot --rendering-driver vulkan --rendering-method mobile --resolution 540x1170 -s res://tests/bild_78510.gd -- --aus=<ordner>
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")


func _initialize() -> void:
	_lauf.call_deferred()


func _knips(pfad: String) -> void:
	for i in 12:
		await process_frame
	var img: Image = root.get_texture().get_image()
	img.save_png(pfad)
	print("BILD78510 ", pfad)


func _lauf() -> void:
	var aus := "/tmp"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	DirAccess.make_dir_recursive_absolute(aus)
	seed(7)
	var p = Probe.new()
	root.add_child(p)
	await process_frame
	var skills := {}
	for s_ in p.tables.skills: skills[s_.id] = s_
	var monsters := {}
	for m_ in p.tables.monsters: monsters[m_.id] = m_
	var hs: Dictionary = p.tables.probe["FIGHTER"].hero
	var sheet: Dictionary = hs.hero.duplicate(true)
	sheet["level"] = 7
	var party := [Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, int(hs.hp), sheet.second, skills)]
	var foes: Array = load("res://kampf/aufruf.gd").gegner("RATS", monsters, Wuerfel.new(8))
	var stand := {"stufe": 7, "ep": 180.0, "toepfe": {}}
	var beute := func(_m: Variant) -> Array:
		var namen := [["Kurzschwert", "COMMON", "Gewöhnlich"], ["Lederkappe", "UNCOMMON", "Ungewöhnlich"], ["Ring", "RARE", "Selten"], ["Amulett", "EPIC", "Episch"]]
		return namen.map(func(x: Array) -> Dictionary: return {"gear": {"rarity": x[1]}, "name": x[0], "rarity": x[2]})
	var kf = load("res://kampf/kampfort.gd").new()
	kf.setup(party, foes, p.tables, {"potion": 2}, func(_o: Variant) -> void: pass, 7, {"stand": stand, "beute": beute})
	root.add_child(kf)
	var n := 0
	while kf.verhuellt and n < 600:
		n += 1
		await process_frame
	for i in 60:
		await process_frame
	kf.ui.refresh()
	await _knips(aus + "/1_beginn.png")
	kf.tor_wahl(false)
	n = 0
	while (kf.busy or kf.ring_open) and kf.mars.outcome == "ONGOING" and n < 3000:
		n += 1
		if kf.ring_open: kf.tap()
		await process_frame
	kf.ui.refresh()
	await _knips(aus + "/2_eckknopf.png")
	if kf.mars.outcome == "ONGOING":
		if OS.get_environment("VERLUST_1567") != "":     # 1567: Verlust vor „Schnell ›“ (wie ein Biss davor) zählt auf der Tafel mit
			kf.mars.all[0].hp -= int(OS.get_environment("VERLUST_1567"))
		kf.schnell()
	n = 0
	while (kf.busy or kf.mars.outcome == "ONGOING") and n < 3000:
		n += 1
		await process_frame
	for i in 120:
		await process_frame
	kf.ui.refresh()
	await _knips(aus + "/3_sieg.png")
	print("BILD78510 fertig %s" % kf.mars.outcome)
	quit(0)
