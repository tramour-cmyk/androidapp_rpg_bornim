extends SceneTree
# 470 Probe mit Bild am Rechner (nicht im Bau): Seite „Neues Spiel“ nach BRS 1.1 von oben bis unten, einmal Mensch als Wachsoldat
# (Vorgabe, +1 frei, eine Fertigkeit zu waehlen), einmal Elf als Wanderer (alle Werte auf 3, zwei Fertigkeiten zu waehlen).
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
	var e := ErschaffungBrs.new()
	root.add_child(e)
	await _bild("470_mensch_oben")
	for stelle in [0.33, 0.66, 1.0]:
		e.rolle.scroll_vertical = int(e.rolle.get_v_scroll_bar().max_value * stelle)
		await _bild("470_mensch_%d" % int(stelle * 100))
	e.b.volk = "Elf"
	e.b.waehle_herkunft("Wanderer")
	e.b.hoch("wille"); e.b.hoch("wille"); e.b.hoch("wille")
	e.b.waehle("Bogen")
	e.baue()
	for i in 3: await process_frame   # baue() stellt die alte Rollstelle nach einem Bild wieder her
	e.rolle.scroll_vertical = 0
	await _bild("470_wanderer_oben")
	e.rolle.scroll_vertical = int(e.rolle.get_v_scroll_bar().max_value * 0.3)
	await _bild("470_wanderer_30")
	for stelle in [0.5, 1.0]:
		e.rolle.scroll_vertical = int(e.rolle.get_v_scroll_bar().max_value * stelle)
		await _bild("470_wanderer_%d" % int(stelle * 100))
	quit(0)
