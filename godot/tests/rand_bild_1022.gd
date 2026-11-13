extends SceneTree
# 1022 Bilder (Chef 12.11., 17:00: „sinnvolle Bilder von innen auf den Kartenrand nach außen“): Spielansicht, Kamera so gedreht, dass
# der Blick vom Helden über den Rand nach außen geht (Rand oben im Bild), an den Fundstellen des Chefs aus Build 280 (Dorf Nord am
# Schlagbaum, Dorf Süd an der Brücke, Kornfeld, Fluss) und im Osten und Süden der Wälder; je Stelle ein Bild bei Tag. godot.yml
# „Randbilder (1022)“ knipst damit vorher (Stand Build 280) und nachher.
# Aufruf: xvfb-run ~/godot/godot --path godot --rendering-driver vulkan --rendering-method mobile --resolution 540x1170
#         -s res://tests/rand_bild_1022.gd -- --rand=<ordner>

# Karte, Kachel des Helden (Weg oder kurzes Gras: kein Überfall im hohen Gras), Blick, Name; Gieren: Norden 0, Westen 90, Süden 180, Osten 270
const BLICK := {"UP": 0.0, "LEFT": 90.0, "DOWN": 180.0, "RIGHT": 270.0}
const ORTE := [
	["village", Vector2i(17, 5), "UP", "1_dorf_nord_schlagbaum"],
	["village", Vector2i(17, 27), "DOWN", "2_dorf_sued_bruecke"],
	["village", Vector2i(26, 28), "DOWN", "3_dorf_sued_kornfeld"],
	["village", Vector2i(2, 24), "LEFT", "4_dorf_fluss_west"],
	["village", Vector2i(33, 24), "RIGHT", "5_dorf_fluss_ost"],
	["forest", Vector2i(14, 9), "RIGHT", "6_wald_ost"],
	["forest", Vector2i(10, 28), "DOWN", "7_wald_sued"],
	["deep_forest", Vector2i(41, 30), "RIGHT", "8_tiefwald_ost"],
	["deep_forest", Vector2i(35, 33), "DOWN", "9_tiefwald_sued"],
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
	var nur := OS.get_environment("RAND_NUR")   # 1022 Rest: nur diese Stellen (Nummern vorn im Namen, mit Komma), leer = alle
	for o in ORTE:
		if nur != "" and not (String(o[3]).get_slice("_", 0) in nur.split(",")): continue
		if spiel.karte.id != o[0]:
			spiel.betrete(o[0], o[1], o[2])
			await create_timer(1.5).timeout
		if spiel.herde: spiel.herde.process_mode = Node.PROCESS_MODE_DISABLED   # kein Kampf während der Aufnahme
		spiel.held.setze(o[1], o[2])
		spiel.kamera.nah = false
		spiel.kamera.zoom = spiel.kamera.fern
		spiel.kamera.gieren_ziel = BLICK[o[2]]
		spiel.kamera.springe()
		spiel.ui.mess.visible = false
		spiel.ui.oben.visible = false
		spiel.ui.leiste.visible = false
		await create_timer(1.2).timeout
		await spiel.knips("%s/%s.png" % [dir, o[3]])
	quit(0)
