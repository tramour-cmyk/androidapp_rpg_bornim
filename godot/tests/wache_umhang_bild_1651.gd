extends SceneTree
# 1651 Sichtbarkeit (Durchstechprüfung 1631: Kettenhemd der Wache liegt in der Bewegung an der Schulter vor dem Umhang, 1,3–1,5 m):
# Wachsoldat und Wachsoldatin wie im Spiel (HeldFigur.baue, Startausrüstung mit Umhang), Ruhebewegung Stehen, drei Zeitpunkte,
# von hinten und schräg hinten, Ausschnitt Schultern. Nur mit Fenster und Kaufdaten, im Ordner godot:
#   PROBE=1651 xvfb-run -a godot --path . --resolution 600x600 -s res://tests/wache_umhang_bild_1651.gd -- --aus=<ordner>
var aus := ""
func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
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
	sonne.rotation_degrees = Vector3(-35, 155, 0)
	root.add_child(sonne)
	var kam := Camera3D.new()
	kam.fov = 30.0
	root.add_child(kam)
	for g in ["m", "w"]:
		if not HeldFigur.da("Wachsoldat", g): continue
		var hw := BrsHeld.fuer_spiel("Test", "Mensch", "Wachsoldat")
		var aus_r := hw.ausruestung.duplicate()
		aus_r["CLOAK"] = {"base": "cloak"}
		var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": aus_r}, [])
		if m == null: continue
		root.add_child(m)
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		for i in 6: await process_frame
		var L := ap.get_animation("Stehen").length if ap.has_animation("Stehen") else 1.0
		for b in 3:
			ap.play("Stehen", 0.0); ap.seek(L * float(b) / 3.0, true); ap.speed_scale = 0.0
			for w in [180.0, 135.0]:
				var r := deg_to_rad(w)
				kam.position = Vector3(sin(r) * 2.0, 1.45, cos(r) * 2.0)
				kam.look_at(Vector3(0, 1.3, 0))
				await knips("%s_%d_%d" % [g, b, int(w)])
		m.queue_free()
		for i in 3: await process_frame
	quit(0)
