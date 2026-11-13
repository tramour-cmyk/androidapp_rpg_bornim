extends SceneTree
# 764 (t282.12, Chef 13.11., 10:25: „Betrunken“ stand senkrecht; 16:28: Aussehen als Bild statt am Handy): Bild des Heldenreiters
# mit dem Zustand „Betrunken“ wie im Spiel nach Met bei Rowena. Am Rechner mit Fenster (xvfb-run), 1080 × 2340, PNG nach
# BILD764_AUS (Vorgabe user://): 764_held

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	z.name = "Thora"
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	z.met = Rast.BETRUNKEN
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	await process_frame
	m.reiter = "held"
	m.baue()
	for i in 10: await process_frame
	# zum Abschnitt Zustände rollen, wie ein Spieler
	for s in m.find_children("*", "ScrollContainer", true, false):
		for l in m.inhalt.find_children("*", "Label", true, false):
			if String(l.text).contains("ZUSTÄNDE"):
				(s as ScrollContainer).ensure_control_visible(l)
	for i in 30: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD764_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/764_held.png")
	print("BILD ", aus + "/764_held.png")
	quit(0)
