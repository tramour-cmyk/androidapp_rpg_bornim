extends SceneTree
# 1655 Sichtbarkeit (Durchstechprüfung 1631: Morwens Kapuze und Kopf durchdringen sich, 1,6–1,7 m): Morwen wie im Spiel
# (HeldFigur.person), Ruhebewegung Stehen, drei Zeitpunkte, Kopf von vorn, Seite und hinten. Nur mit Fenster und Kaufdaten, im Ordner godot:
#   PROBE=1655 xvfb-run -a godot --path . --resolution 500x500 -s res://tests/kopf_bild_1655.gd -- --aus=<ordner> [--id=morwen]
var aus := ""
var id := "morwen"
func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
		if a.begins_with("--id="): id = a.substr(5)
	_lauf.call_deferred()

func knips(n: String) -> void:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	var welt := WorldEnvironment.new()
	welt.environment = Environment.new()
	welt.environment.background_mode = Environment.BG_COLOR
	welt.environment.background_color = Color(0.08, 0.07, 0.06)
	welt.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	welt.environment.ambient_light_color = Color(0.55, 0.5, 0.45)
	root.add_child(welt)
	var sonne := DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-35, -25, 0)
	root.add_child(sonne)
	var kam := Camera3D.new()
	kam.fov = 30.0
	root.add_child(kam)
	var m := HeldFigur.person(id, [])
	if m == null:
		print("KOPF1655 fehlt"); quit(1); return
	root.add_child(m)
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	for i in 6: await process_frame
	var L := ap.get_animation("Stehen").length if ap.has_animation("Stehen") else 1.0
	for b in 3:
		ap.play("Stehen", 0.0); ap.seek(L * float(b) / 3.0, true); ap.speed_scale = 0.0
		for i in 3: await process_frame
		var kb := sk.find_bone("Head") if sk.find_bone("Head") >= 0 else sk.find_bone("head")
		var kopf := (sk.global_transform * sk.get_bone_global_pose(kb)).origin + Vector3(0, 0.08, 0)
		print("KOPF1655 ", kopf)
		for w in [0.0, 90.0, 180.0]:
			var r := deg_to_rad(w)
			kam.position = kopf + Vector3(sin(r) * 1.1, 0.05, cos(r) * 1.1)
			kam.look_at(kopf)
			await knips("%s_%d_%d" % [id, b, int(w)])
	quit(0)
