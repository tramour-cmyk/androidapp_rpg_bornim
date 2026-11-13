extends SceneTree
# 856 Probe mit Bild am Rechner (nicht im Bau): Intro mit dem Satz unter Bild 2 ohne Goldrand und die Rückfrage „Überspringen?“
# nach 549a, dazu die Tempelszene. PNG nach OBERFLAECHE_AUS. Aufruf: im Ordner godot, mit Fenster (xvfb-run), --resolution 1080x2340

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
	for art in ["intro", "tempel"]:
		var z := Zwischenbild.new(art)
		root.add_child(z)
		await process_frame
		z.ms = 7200 + 4000   # Bild 2, der Satz steht ganz
		await _bild("856_%s_satz" % art)
		z.frage()
		await _bild("856_%s_frage" % art)
		z.queue_free()
		await process_frame
	quit(0)
