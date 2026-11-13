extends SceneTree
# 756 Vorlage (Chef 12.11., 20:23: „Vorlage … mit rostbraun oder dunkelrot oder halbvoll oder voll oder Ring … entweder auf dem
# Ausrüstungsschirm … oder aus der Tasche“): Reiter Tasche, wie im Spiel (Menue.merkmale), am Rechner mit Fenster (xvfb-run),
# 1080 × 2340. Je Stück eine Variante für Schlecht (Menue.SCHLECHT: Ring rostbraun, Ring dunkelrot, halbvoll dunkelrot, voll
# dunkelrot), daneben Normal ohne Zeichen, Gut ●, Meisterhaft ●●, ein defektes Stück zum Vergleich.
# PNG nach BILD756_AUS (Vorgabe user://) als 756_schlecht.png; druckt je Stück „STUECK <Name> <y>“ für die Beschriftung.

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 30: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD756_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _ding(z: Zustand, base: String, guete: int, zustand: int, art: int, saat: int) -> Dictionary:
	var g := {"uid": 0, "base": base, "rarity": "COMMON", "ilvl": 1, "guete": guete, "zustand": zustand, "rolls": [],
		"unique": null, "name_seed": saat}
	if art >= 0: g["schlecht_art"] = art
	return z.ausruestung_dazu(g)

func _lauf() -> void:
	Sprache.setze("de")
	Menue.merkmale = true
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 40
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	Testmodus.stufe_setzen(hw, z, 2)
	_ding(z, "chain_shirt", -1, 0, 0, 1)    # Schlecht: Ring rostbraun
	_ding(z, "leather", -1, 0, 1, 2)        # Schlecht: Ring dunkelrot
	_ding(z, "round_shield", -1, 0, 2, 3)   # Schlecht: halbvoll dunkelrot
	_ding(z, "shortsword", -1, 0, 3, 4)     # Schlecht: voll dunkelrot
	_ding(z, "hood", 0, 0, -1, 5)           # Normal: kein Zeichen
	_ding(z, "mace", 1, 0, -1, 6)           # Gut
	_ding(z, "greatsword", 2, 0, -1, 7)     # Meisterhaft, 2H
	_ding(z, "longsword", 0, 3, -1, 8)      # Defekt, zum Vergleich
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	m.reiter = "tasche"
	m.baue()
	await _bild("756_schlecht")
	for l in m.find_children("*", "Label", true, false):
		var t := (l as Label).text
		if (l as Label).is_visible_in_tree() and t.length() > 2 and t.length() < 40 and int((l as Label).get_theme_font_size("font_size")) >= 16:
			print("STUECK ", t, " ", int((l as Label).get_global_rect().position.y))
	quit(0)
