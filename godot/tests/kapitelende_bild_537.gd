extends SceneTree
# 537 Probe mit Bild am Rechner (nicht im Bau): der Schirm „Kapitelende“ (KapitelSchirm) wie alt ChapterEndScreen, Held Stufe 6.
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
	var hw := BrsHeld.fuer_spiel("Thora", "Elf", "Zauberlehrling", z.neue_uid)
	Testmodus.stufe_setzen(hw, z, 5)
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	ebene.add_child(KapitelSchirm.new(hw, Geschichte.CHAPTER_END_TEXT))
	await _bild("537_kapitelende")
	quit(0)
