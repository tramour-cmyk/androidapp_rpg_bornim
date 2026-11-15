# 431 Tuch: Standbilder je Körper von hinten, von der Seite und von vorn (Stehen; mit BEW=<Bewegung> eine andere, ZEIT=<s> Zeitpunkt),
# nur zum Selbstansehen vor dem Film (Sokrates 15.11., 17:29, Bedingung 3). Aufruf (nicht headless, Vulkan):
#   UMHANG=<ordner> BILD=<ordner> [NUR=<teil des namens>] godot --path godot -s res://tests/tuch_bild_431.gd
extends SceneTree

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var dir := OS.get_environment("UMHANG")
	var aus := OS.get_environment("BILD")
	var bew := OS.get_environment("BEW") if OS.get_environment("BEW") != "" else "Idle_Loop"
	var zeit := float(OS.get_environment("ZEIT")) if OS.get_environment("ZEIT") != "" else 2.0
	var nur := OS.get_environment("NUR")
	DirAccess.make_dir_recursive_absolute(aus)
	root.size = Vector2i(900, 1000)
	var env := WorldEnvironment.new(); env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR; env.environment.background_color = Color(0.55, 0.55, 0.58)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; env.environment.ambient_light_color = Color(0.6, 0.6, 0.6)
	root.add_child(env)
	var li := DirectionalLight3D.new(); li.rotation_degrees = Vector3(-40, 30, 0); root.add_child(li)
	var cam := Camera3D.new(); root.add_child(cam); cam.current = true
	var dateien := []
	for f in DirAccess.get_files_at(dir):
		if f.begins_with("umhang_") and f.ends_with(".glb") and (nur == "" or f.contains(nur)): dateien.append(f)
	dateien.sort()
	for f in dateien:
		var m := Gebiet.lade_glb(dir.path_join(f))
		root.add_child(m)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		HeldFigur.bewegungen(m, sk)
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		Umhang.an(m, sk)
		if ap.has_animation(bew): ap.play(bew)
		else: print("TUCHBILD ohne ", bew, " in ", f)
		var h := 0.0
		for mi in m.find_children("*", "MeshInstance3D", true, false): h = maxf(h, (mi as MeshInstance3D).get_aabb().end.y)
		for i in int(zeit * 30): await process_frame
		ap.pause()
		for ansicht in [["hinten", Vector3(0, 0, -1)], ["seite", Vector3(1, 0, 0)], ["vorn", Vector3(0, 0, 1)]]:
			var d: Vector3 = ansicht[1]
			cam.position = Vector3(0, h * 0.55, 0) + d * (h * 1.6)
			cam.look_at(Vector3(0, h * 0.5, 0))
			cam.fov = 40
			for i in 3: await process_frame
			var img := root.get_texture().get_image()
			img.save_png(aus.path_join("%s_%s_%s.png" % [f.get_basename(), bew, ansicht[0]]))
		m.free()
		await process_frame
	print("TUCHBILD OK ", dateien.size())
	quit(0)
