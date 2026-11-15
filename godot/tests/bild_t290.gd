extends SceneTree
# t290 (1337, Jerry 1331: Bilder 290.3, 290.6 und Film 290.5 vom Stand claude/build-290): Aussehen als Bild bzw. Film wie im Spiel,
# 1080 × 2340, mit den Kaufmodellen; mit Fenster (xvfb-run). T290=satt (290.3, 785.22: Leiste im Dorf nach dem Essen, dazu Gift),
# faecher (290.6, 1309: Reiter Ausrüstung, neun göttliche Stücke), stab (290.5, 1304: Reiter Ausrüstung, Kampfstab und Fackel im
# Drehteller, 6 s für --write-movie). BILD_AUS=<ordner>

func _initialize() -> void: _lauf.call_deferred()

func _bild(n: String) -> void:
	if DisplayServer.get_name() == "headless": print("BILD ohne Fenster ", n); return
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus.path_join(n + ".png"))
	print("BILD ", aus.path_join(n + ".png"))

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	match OS.get_environment("T290"):
		"satt": await _satt()
		"faecher": await _menue(true)
		"faecher_tipp": await _menue(true, "LEGS")
		"stab": await _menue(false)
	quit(0)

func _satt() -> void:
	# nur die Leiste wie oben im Spiel (das ganze Dorf mit Fenster warf am Rechner Fehler), auf dunklem Grund
	var grund := ColorRect.new(); grund.color = Color(0.12, 0.14, 0.1); grund.size = Vector2(1080, 2340)
	root.add_child(grund)
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	var l := Leiste.new()
	root.add_child(l)
	await process_frame
	z.satt = true
	z.leiden["POISON"] = 2
	l.zeige(hw, z, false)
	for i in 10: await process_frame
	await _bild("290_3_satt")

func _menue(faecher: bool, tipp := "") -> void:
	var z := Zustand.new()
	z.name = "Thora"
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER if faecher else "Klosterschüler", z.neue_uid)
	if faecher:
		var lang := {"HEAD": "leather_cap", "CLOAK": "mantle", "CHEST": "splint", "ARMS": "gauntlets", "LEGS": "chain_leggings",
			"AMULET": "talisman", "RING": "signet", "MAIN_HAND": "warhammer", "OFF_HAND": "holy_symbol"}
		for pl in lang: hw.ausruestung[pl] = {"uid": z.neue_uid(), "base": lang[pl], "rarity": "DIVINE", "ilvl": 10, "rolls": [], "name_seed": 4}
	else:
		hw.ausruestung["MAIN_HAND"] = {"uid": z.neue_uid(), "base": "quarterstaff", "rarity": "COMMON", "ilvl": 1, "rolls": []}
		hw.ausruestung["OFF_HAND"] = {"uid": z.neue_uid(), "base": "torch", "rarity": "COMMON", "ilvl": 1, "rolls": []}
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	m.reiter = "ausruestung"
	ebene.add_child(m)
	if faecher:
		for i in 40: await process_frame
		for d in root.find_children("*", "SubViewportContainer", true, false):
			if d is Drehteller:
				d.dreht = false
				if d.teller: d.teller.rotation.y = -0.5
		for i in 4: await process_frame
		if tipp != "":
			await _bild("290_6_faecher_vorher")
		if tipp != "":   # 1341: der Name steht beim Antippen des Fachs (Fenster mit Namen und Werten), im Fach nur Bild und Platz
			m.tippe_fach(tipp)
			for i in 20: await process_frame
		await _bild("290_6_faecher" + ("_" + tipp.to_lower() if tipp != "" else ""))
	else:
		for i in 200: await process_frame   # mit --fixed-fps 30 etwa 6,5 s
