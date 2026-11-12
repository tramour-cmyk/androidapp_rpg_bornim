extends SceneTree
# 1022 Bilder am Rechner: Kartenrand jeder Gebietskarte aus Sicht des Helden, je Seite ein Bild (Tag), fuer das Bildpaar vorher/nachher.
# Aufruf: xvfb-run ~/godot/godot --path godot --rendering-driver vulkan --rendering-method mobile --resolution 540x1170
#         -s res://tests/rand_bild_1022.gd -- --rand=<ordner>

const ORTE := [
	["village", Vector2i(17, 4), "norden"], ["village", Vector2i(1, 20), "westen"], ["village", Vector2i(34, 15), "osten"], ["village", Vector2i(17, 30), "sueden"],
	["forest", Vector2i(9, 2), "norden"], ["forest", Vector2i(4, 12), "westen"], ["forest", Vector2i(18, 15), "osten"], ["forest", Vector2i(9, 30), "sueden"],
	["deep_forest", Vector2i(21, 3), "norden"], ["deep_forest", Vector2i(1, 18), "westen"], ["deep_forest", Vector2i(41, 30), "osten"], ["deep_forest", Vector2i(18, 35), "sueden"],
]

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var dir := "/tmp/rand1022"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--rand="): dir = a.substr(7)
	DirAccess.make_dir_recursive_absolute(dir)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	for o in ORTE:
		if spiel.karte.id != o[0]:
			spiel.betrete(o[0], o[1], "UP")
			await create_timer(1.5).timeout
		spiel.held.setze(o[1], "UP")
		spiel.ui.mess.visible = false
		spiel.ui.oben.visible = false
		spiel.ui.leiste.visible = false
		await create_timer(1.2).timeout
		await spiel.knips("%s/%s_%s.png" % [dir, o[0], o[2]])
	quit(0)
