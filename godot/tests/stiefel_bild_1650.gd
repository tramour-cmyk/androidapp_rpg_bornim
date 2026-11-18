extends SceneTree
# 1650 Bild an den Chef (Läufe frei 18.11., 16:46): Hose gegen Stiefelschaft bei den Leuten mit Kaufstiefeln, je Person alt
# (daten/held_L_<id>_M.bin) und neu (--neu=<ordner>/held_L_<id>_M.glb), Ruhebewegung Stehen, Unterschenkel von vorn und hinten.
# Nur mit Fenster und Kaufdaten, im Ordner godot:
#   PROBE=1650 MODELLSPEICHER=0 xvfb-run -a godot --path . --resolution 400x400 -s res://tests/stiefel_bild_1650.gd -- --aus=<ordner> --neu=<ordner>
var aus := ""
var neu := ""
const LEUTE := ["borin", "pim", "bram", "garrick", "jorin"]
func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
		if a.begins_with("--neu="): neu = a.substr(6)
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
	welt.environment.ambient_light_color = Color(0.6, 0.55, 0.5)
	root.add_child(welt)
	var sonne := DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-35, -25, 0)
	root.add_child(sonne)
	var kam := Camera3D.new()
	kam.fov = 30.0
	root.add_child(kam)
	for id in LEUTE:
		var datei := ProjectSettings.globalize_path("res://daten/held_L_%s_M.bin" % id)
		var sicher := datei + ".alt1650"
		DirAccess.copy_absolute(datei, sicher)
		for fassung in ["alt", "neu"]:
			if fassung == "neu": DirAccess.copy_absolute(neu + "/held_L_%s_M.glb" % id, datei)
			var m := HeldFigur.person(id, [])
			if m == null: continue
			root.add_child(m)
			var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			for i in 6: await process_frame
			if ap.has_animation("Stehen"):
				ap.play("Stehen", 0.0); ap.seek(0.0, true); ap.speed_scale = 0.0
			var h := 0.28 * m.scale.y
			for w in [0.0, 180.0]:
				var r := deg_to_rad(w)
				kam.position = Vector3(sin(r) * 1.3, h + 0.05, cos(r) * 1.3)
				kam.look_at(Vector3(0, h, 0))
				await knips("%s_%s_%d" % [id, fassung, int(w)])
			m.queue_free()
			for i in 3: await process_frame
		DirAccess.copy_absolute(sicher, datei)
		DirAccess.remove_absolute(sicher)
	quit(0)
