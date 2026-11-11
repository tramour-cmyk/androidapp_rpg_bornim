extends SceneTree
# 525 Probe mit Bild am Rechner (nicht im Bau): Morwens Hütte, Seite Brauen (je Zutat Bild und hat/braucht, „Fehlt: …“,
# „Reicht für n×“) und der Braukasten nach „Alle“. Zum Vergleich mit ShopScreen.kt 384–408 (BrewList).
# PNG nach OBERFLAECHE_AUS. Aufruf: im Ordner godot, mit Fenster (xvfb-run), --resolution 1080x2340

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("OBERFLAECHE_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 23
	z.dazu("herbs", 7)
	z.dazu("potion", 2)
	z.dazu("bat_wing", 0)
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var l := LadenSchirm.new(hw, z, Laden.new(["herbs", "potion", "remedy"], true))
	ebene.add_child(l)
	await process_frame
	l.seite = "brauen"; l.baue()
	await _bild("525_brauen")
	var heil: Dictionary = Laden.rezepte().filter(func(r): return String(r["ergebnis"]) == "potion")[0]
	l.braukasten(heil, 3, true)
	await _bild("525_braukasten")
	quit(0)
