extends SceneTree
# 1515 (Chef 17.11., 07:32, Bild Hauptmenü Build 295): vor dem Schild der Wachsoldatin „ein weißes Etwas“. Messung (Tom 08:06): vorn im
# Bildfeld liegt der Kettensaum des Kettenhemds (Kleid, Knochen thigh_l, Metallmarke Kette) an der linken Hüfte, seit 1417 nicht mehr vom
# hängenden Arm verdeckt, mit dem Kettenglanz (glanz_kette) hell. Probebild: Wachsoldatin (1) jetzt, (2) ohne Kettenglanz am Kleid,
# (3) Arm hängend wie Build 294 (schild_abspreiz 0), nebeneinander. Nur mit Fenster:
#   PROBE=1515 xvfb-run -a godot --path . --rendering-driver vulkan --rendering-method mobile -s res://tests/wache_bild_1515.gd -- --aus=<ordner>
var aus := ""
func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	_l.call_deferred()
func knips(hm: HauptmenueHelden, n: String) -> void:
	hm._bilder = 0
	hm._v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	for k in 6: await process_frame
	await RenderingServer.frame_post_draw
	hm._v.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")
func _l() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	var hm := HauptmenueHelden.new(600)
	root.add_child(hm)
	for i in 12: await process_frame
	var m := hm.figuren[0].get_child(0) as Node3D
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	await knips(hm, "1515_jetzt")
	var kleid := m.find_child("Kleid", true, false) as MeshInstance3D
	var mat := kleid.get_active_material(0) as ShaderMaterial
	var g = mat.get_shader_parameter("glanz_kette")
	mat.set_shader_parameter("glanz_kette", 0.0)
	await knips(hm, "1515_ohne_glanz")
	mat.set_shader_parameter("glanz_kette", g)
	for c in sk.get_children():
		if c is Tragen and (c as Tragen).gang == "schildarm": (c as Tragen).schild_abspreiz = 0.0
	await knips(hm, "1515_arm_haengt")
	quit(0)
