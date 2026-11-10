# 477 (MuMu schwarz, Verdacht Vulkan im Emulator): kompilieren alle Shader auch im Compatibility-Renderer (x86_64 nutzt ihn, project.godot)?
# Je .gdshader ein Netz mit dem Material, drei Bilder zeichnen; SHADER ERROR steht dann im Protokoll. Ohne Bild.
# Run: xvfb-run godot --path godot --rendering-driver opengl3 --rendering-method gl_compatibility -s res://tests/shader_477.gd
extends SceneTree

func _initialize() -> void:
	_lauf.call_deferred()

func _shader(d: String, out: Array) -> void:
	for f in DirAccess.get_files_at(d):
		if f.ends_with(".gdshader"): out.append(d.path_join(f))
	for s in DirAccess.get_directories_at(d):
		if not s.begins_with("."): _shader(d.path_join(s), out)

func _lauf() -> void:
	var welt := Node3D.new()
	root.add_child(welt)
	var cam := Camera3D.new()
	cam.position = Vector3(0, 0, 6)
	welt.add_child(cam)
	cam.make_current()
	var liste: Array = []
	_shader("res://", liste)
	var i := 0
	for p in liste:
		var sh := load(p) as Shader
		if sh == null: continue
		var mi := MeshInstance3D.new()
		mi.mesh = BoxMesh.new()
		var m := ShaderMaterial.new()
		m.shader = sh
		mi.material_override = m
		mi.position = Vector3((i % 6) - 2.5, (i / 6) - 1.0, 0)
		welt.add_child(mi)
		i += 1
	for k in 3: await process_frame
	print("SHADER477 %d Shader gezeichnet, Renderer %s" % [i, RenderingServer.get_current_rendering_method()])
	quit(0)
