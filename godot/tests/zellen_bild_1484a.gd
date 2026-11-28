extends SceneTree
# 1484a Bilder alt gegen neu (Vorentscheid A 18.11.: drei Stellen vor dem Build, Aussehen gleich): je Stelle mittags ein Bild in der
# Spielkamera, Renderer wie am Handy, ohne Leiste. Läuft im alten Stand (ein Netz) und im neuen (Zellen) gleich.
# Aufruf im Ordner godot: godot --rendering-driver vulkan --rendering-method mobile --resolution 540x1170 -s res://tests/zellen_bild_1484a.gd -- --aus=<ordner>

const STELLEN := [["forest", Vector2i(11, 19)], ["forest", Vector2i(9, 12)], ["village", Vector2i(12, 12)]]


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
		var k: Vector2i = s[1]
		spiel.zustand.minuten = 12 * 60
		spiel.betrete(s[0], k, "DOWN")
		await create_timer(1.5).timeout
		for i in 80:
			if not spiel.ui.spricht() and spiel.szene.is_empty(): break
			spiel.ui.naechste()
			await process_frame
		spiel.zustand.minuten = 12 * 60
		for i in 40: await process_frame
		var img: Image = root.get_texture().get_image()
		var p := "%s/%s_%d_%d.png" % [aus, s[0], k.x, k.y]
		img.save_png(p)
		print("BILD1484A ", p, " Aufrufe ", RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			" Dreiecke ", RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
	quit()
