extends SceneTree
# 431 Beleglauf (Lotte): linke Faust des Jägerkinds (Zwerg) im Hauptmenü mit Kurzbogen, nah von vorn und außen; AUS=<ordner>,
# NAME=<datei>, BOGEN_ALT=1 Lage des Bogens vor 431 (Tragen.bogen_alt). Mit Fenster (xvfb-run), PNG <AUS>/<NAME>_vorn|aussen.png
func _initialize() -> void: _lauf.call_deferred()
func _lauf() -> void:
	Tragen.bogen_alt = OS.get_environment("BOGEN_ALT") == "1"
	var hm := HauptmenueHelden.new(400.0)
	root.add_child(hm)
	for i in 6: await process_frame
	var v: SubViewport = hm._v
	v.size = Vector2i(800, 800)
	for trg in hm.figuren:
		if not String(trg.get_meta("haltung", "")).ends_with("bogen"): continue
		var m := trg.get_child(0) as Node3D
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var f := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("hand_l")).origin
		var f2 := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("middle_01_l")).origin
		var ziel := (f + f2) * 0.5
		for seite in [["vorn", Vector3(0, 0.05, 0.45)], ["aussen", Vector3(0.45, 0.05, 0.0)]]:
			var kam := Camera3D.new()
			kam.fov = 30.0
			v.add_child(kam)
			kam.global_position = ziel + (trg.global_basis.orthonormalized() * (seite[1] as Vector3))
			kam.look_at(ziel)
			kam.current = true
			v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			for i in 6: await process_frame
			await RenderingServer.frame_post_draw
			var p := OS.get_environment("AUS").path_join("%s_%s.png" % [OS.get_environment("NAME"), seite[0]])
			v.get_texture().get_image().save_png(p)
			print("BILD ", p)
			kam.free()
	quit(0)
