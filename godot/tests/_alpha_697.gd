extends SceneTree
# Nachstellen 697 (Chef 08.11., 15:23: Held im Drehteller halbtransparent): deckendes Netz im durchsichtigen SubViewport wie drehteller.gd,
# Alpha in der Mitte und zusammengesetzt im SubViewportContainer vor weissem und schwarzem Grund (gleich = deckend). Nur Zahlen.
func _initialize() -> void: _lauf.call_deferred()
func probe(mat: Material, msaa: int, name_: String) -> void:
	var farben := []
	var alpha := -1.0
	for grund in [Color.WHITE, Color.BLACK]:
		var aussen := SubViewport.new(); aussen.size = Vector2i(64, 64); aussen.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(aussen)
		var cr := ColorRect.new(); cr.color = grund; cr.size = Vector2(64, 64); aussen.add_child(cr)
		var box := SubViewportContainer.new(); box.stretch = true; box.size = Vector2(64, 64); aussen.add_child(box)
		var v := SubViewport.new()
		v.own_world_3d = true; v.transparent_bg = true; v.msaa_3d = msaa
		box.add_child(v)
		var welt := WorldEnvironment.new(); welt.environment = Environment.new()
		welt.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		welt.environment.ambient_light_color = Color(0.55, 0.5, 0.45)
		v.add_child(welt)
		var s := DirectionalLight3D.new(); s.rotation_degrees = Vector3(-40, -30, 0); v.add_child(s)
		var k := Camera3D.new(); k.position = Vector3(0, 0, 3); v.add_child(k)
		var mi := MeshInstance3D.new(); mi.mesh = BoxMesh.new(); mi.material_override = mat; mi.rotation_degrees = Vector3(20, 30, 0); v.add_child(mi)
		for i in 8: await process_frame
		alpha = v.get_texture().get_image().get_pixel(32, 32).a
		farben.append(aussen.get_texture().get_image().get_pixel(32, 32))
		aussen.queue_free()
		await process_frame
	var w: Color = farben[0]; var b: Color = farben[1]
	print("ALPHA697 %-10s msaa=%d innen a=%.3f | vor weiss %.3f %.3f %.3f | vor schwarz %.3f %.3f %.3f" % [name_, msaa, alpha, w.r, w.g, w.b, b.r, b.g, b.b])
func _lauf() -> void:
	print("ALPHA697 Zeichner: ", RenderingServer.get_current_rendering_method())
	var std := StandardMaterial3D.new()
	var toon := ShaderMaterial.new(); toon.shader = load("res://shader/toon.gdshader")
	var mark := ShaderMaterial.new(); mark.shader = Gebiet.toon_mark(2)
	var held := ShaderMaterial.new(); held.shader = Gebiet.toon_mark(2)
	held.set_shader_parameter("metall", 1.0); held.set_shader_parameter("rueck", 0.04); held.set_shader_parameter("fill", 0.3)
	for msaa in [Viewport.MSAA_DISABLED, Viewport.MSAA_4X]:
		await probe(std, msaa, "standard")
		await probe(toon, msaa, "toon")
		await probe(mark, msaa, "toon_mark2")
		await probe(held, msaa, "wie_held")
	quit(0)
