extends SceneTree
# 1694 (Auftrag 25.11., 20:36; Chef 19:55 „Film alt/neu nah und Spielkamera“): Bildfolge für den Film, Großaxt Stufe 1, WACHE_M, Stehen
# im Dorf (der Held atmet). Erst NAH Bilder mit der Nahkamera von der Seite auf die rechte Hand, dann NAH Bilder Spielkamera (Handygröße
# mit --resolution 540x1170). Bilder nach FILMAUS=<ordner>/nah_0000.png … spiel_0000.png; zusammengesetzt von tools/film_griff_1694.sh.
#   FILMAUS=<ordner> xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 540x1170 -s res://tests/film_griff_1694.gd -- --bild1694

const NAH := 75

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var aus := OS.get_environment("FILMAUS")
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 13 * 60
	spiel.licht_nach_uhr(true)
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	if hw.get("aussehen") is Dictionary: hw.aussehen["geschlecht"] = "m"
	hw.ausruestung["MAIN_HAND"] = {"uid": 9601, "base": "greataxe", "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
	spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
	spiel.held_figur_neu("")
	spiel.held.richtung = Vector3.ZERO
	var sk := Gebiet.finde(spiel.held.modell, "Skeleton3D") as Skeleton3D
	for f in 80: await process_frame
	var t: Tragen = null
	for n in sk.get_children(): if n is Tragen: t = n
	print("FILM1694 Tracht %s, Waffe %s, gang %s" % [spiel.held.modell.get_meta("tracht", "?"), t.waffe.name if t and t.waffe else "FEHLT", t.gang if t else "?"])
	var hand: Vector3 = sk.global_transform * sk.get_bone_global_pose(sk.find_bone("middle_01_r")).origin
	var rechts: Vector3 = spiel.held.modell.global_basis * Vector3.LEFT
	var vorn: Vector3 = spiel.held.modell.global_basis * Vector3.BACK
	var kam := Camera3D.new(); root.add_child(kam); kam.fov = 30.0
	kam.global_position = hand + rechts * 0.42 + vorn * 0.08 + Vector3.UP * 0.04
	kam.look_at(hand, Vector3.UP)
	kam.make_current()
	for f in 4: await process_frame
	for f in NAH:
		await RenderingServer.frame_post_draw
		root.get_viewport().get_texture().get_image().save_png("%s/nah_%04d.png" % [aus, f])
		await process_frame
	spiel.kamera.springe()
	spiel.kamera.make_current()
	for f in 4: await process_frame
	for f in NAH:
		await RenderingServer.frame_post_draw
		root.get_viewport().get_texture().get_image().save_png("%s/spiel_%04d.png" % [aus, f])
		await process_frame
	print("FILM1694 fertig %s" % aus)
	quit(0)
