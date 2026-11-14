extends SceneTree
# 756 A (Chef 09.11., 17:46: „Probebild Merkmale jetzt, Sperren zeigen“; Vorschlag Sokrates 14:28): Probebild der Merkmale am Stueck,
# so gebaut, wie es im Spiel aussehen soll (Menue.merkmale), am Rechner mit Fenster (xvfb-run), 1080 × 2340:
#   756_tasche     Reiter Tasche: Gueten (Schlecht, Normal, Gut, Meisterhaft), 2H, Zustand (Benutzt ohne Balken, Beschaedigt, Defekt),
#                  nicht tragbar (Stufe 3 bei Heldenstufe 2) abgedunkelt
#   756_fenster    Gegenstandsfenster des beschaedigten, guten Langschwerts der Stufe 3: Guete, Zustand, Sperre „Erst ab Heldenstufe 3.“
#   756_ausruestung  Reiter Ausruestung: Plaetze mit denselben Zeichen
# PNG nach BILD756_AUS (Vorgabe user://).

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 30: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD756_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _ding(z: Zustand, base: String, rar: String, ilvl: int, guete: int, zustand: int, rolls: Array, saat: int) -> Dictionary:
	return z.ausruestung_dazu({"uid": 0, "base": base, "rarity": rar, "ilvl": ilvl, "guete": guete, "zustand": zustand, "rolls": rolls,
		"unique": null, "name_seed": saat})

func _lauf() -> void:
	Sprache.setze("de")
	Menue.merkmale = true
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 40
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	Testmodus.stufe_setzen(hw, z, 2)
	# angelegt: Kapuze gut, Kurzschwert meisterhaft und beschaedigt, Lederruestung benutzt
	for x in [["hood", "COMMON", 1, 1, 0], ["shortsword", "COMMON", 1, 2, 2], ["leather", "COMMON", 1, 0, 1]]:
		var g := _ding(z, x[0], x[1], x[2], x[3], x[4], [], 1)
		z.beutel.erase(g)
		hw.anlegen(g)
	var schwert := _ding(z, "longsword", "UNCOMMON", 3, 1, 2, [["CRIT", 3]], 4)   # gut, beschaedigt, Stufe 3: nicht tragbar
	_ding(z, "greatsword", "COMMON", 2, 2, 0, [], 2)                               # meisterhaft, 2H
	_ding(z, "round_shield", "COMMON", 1, 0, 3, [], 3)                             # defekt
	_ding(z, "chain_shirt", "COMMON", 1, -1, 1, [], 5)                             # schlecht (kommt mit 976), benutzt
	_ding(z, "ring", "UNCOMMON", 2, 0, 0, [["HP", 5]], 6)                          # ohne Zeichen
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	m.reiter = "tasche"
	m.baue()
	await _bild("756_tasche")
	m.frage_stueck(schwert)
	await _bild("756_fenster")
	m.get_child(m.get_child_count() - 1).free()
	m.reiter = "ausruestung"
	m.baue()
	await _bild("756_ausruestung")
	Menue.merkmale = false
	quit(0)
