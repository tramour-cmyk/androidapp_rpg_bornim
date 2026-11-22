extends SceneTree
# 1720 Bilder alt gegen neu (Chef 18.11., 23:14, Bilder t300.3 Wald 11/19, t300.4 Hoehle): Vordergrund deckte bis zur halben
# Bildflaeche schwarz ab. Je Stelle mittags ein Bild in der Spielkamera (540 x 1170 wie am Handy); laeuft im alten und neuen Stand gleich.
# Aufruf im Ordner godot: godot --resolution 540x1170 -s res://tests/vordergrund_bild_1720.gd -- --aus=<ordner>

const STELLEN := [["forest", Vector2i(11, 19)], ["forest", Vector2i(9, 12)], ["station", "Krogg"], ["cave", Vector2i(10, 9)],
	["village", Vector2i(12, 12)]]


func _initialize() -> void: _lauf.call_deferred()


func _lauf() -> void:
	var aus := "/tmp"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	DirAccess.make_dir_recursive_absolute(aus)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	Herde.beachten_nicht = true
	for s in STELLEN:
		spiel.zustand.minuten = 12 * 60
		var name := ""
		if s[0] == "station":
			await spiel.test_tat("station", [s[1]])
			name = "hoehle_%s" % s[1]
		else:
			spiel.betrete(s[0], s[1], "DOWN")
			name = "%s_%d_%d" % [s[0], s[1].x, s[1].y]
		await create_timer(1.5).timeout
		for i in 80:
			if not spiel.ui.spricht() and spiel.szene.is_empty(): break
			spiel.ui.naechste()
			await process_frame
		spiel.zustand.minuten = 12 * 60
		if spiel.karte.id == "cave": spiel.held.fackel_neu(true, false, true)   # t300.4: mit Fackel
		for i in 40: await process_frame
		var img: Image = root.get_texture().get_image()
		var p := "%s/%s.png" % [aus, name]
		img.save_png(p)
		print("BILD1720 ", p, " ", spiel.karte.id, " ", spiel.held.kachel, " Aufrufe ",
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			" Dreiecke ", RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
	quit()
