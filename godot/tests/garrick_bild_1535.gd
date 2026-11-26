extends SceneTree
# 1535 Rückläufer (Chef 18.11., 15:33, Build 299: Garrick hebt in der Ruhe den Arm, „zieht sich da auch wieder irgendwas von der
# Jacke … so einen Faden“): Garrick (HeldFigur.person, wie im Spiel) in seinen Ruhebewegungen, je Bewegung einige Bilder, einmal mit
# daten/held_L_garrick_M.bin (alt), einmal mit der Datei aus --neu=<glb>. Nur mit Fenster und Kaufdaten, im Ordner godot:
#   PROBE=1535 MODELLSPEICHER=0 xvfb-run -a godot --path . --resolution 600x700 -s res://tests/garrick_bild_1535.gd -- --aus=<ordner> --neu=<glb>
var aus := ""
var neu := ""
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
	welt.environment.ambient_light_color = Color(0.55, 0.5, 0.45)
	root.add_child(welt)
	var sonne := DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-35, -25, 0)
	root.add_child(sonne)
	var kam := Camera3D.new()
	kam.fov = 30.0
	kam.position = Vector3(0, 1.2, 3.0)
	root.add_child(kam)
	kam.look_at(Vector3(0, 1.05, 0))
	var datei := ProjectSettings.globalize_path("res://daten/held_L_garrick_M.bin")
	var sicher := datei + ".alt1535"
	DirAccess.copy_absolute(datei, sicher)
	for fassung in ["alt", "neu"]:
		if fassung == "neu":
			if neu == "": break
			DirAccess.copy_absolute(neu, datei)
		var m := HeldFigur.person("garrick", [])
		if m == null:
			print("GARRICK1535 fehlt"); break
		root.add_child(m)
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		for i in 6: await process_frame
		for bew in ["Stehen_2", "Ruhe_Trinken"]:
			if not ap.has_animation(bew): continue
			var L := ap.get_animation(bew).length
			for b in 6:
				ap.play(bew, 0.0)
				ap.seek(L * float(b) / 6.0, true)
				ap.speed_scale = 0.0
				await knips("%s_%s_%d" % [fassung, bew, b])
		m.queue_free()
		for i in 3: await process_frame
	DirAccess.copy_absolute(sicher, datei)
	DirAccess.remove_absolute(sicher)
	quit(0)
