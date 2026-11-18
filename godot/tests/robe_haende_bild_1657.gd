extends SceneTree
# 1657 Sichtbarkeit (Durchstechprüfung 1631: Hände des Zauberlehrlings in der Robe, 0,9–1,0 m):
# Zauberlehrling M und W wie im Spiel (HeldFigur.baue, Startausrüstung), Ruhebewegung Stehen, drei Zeitpunkte,
# von vorn und von der Seite, Ausschnitt Hüfte und Hände. Nur mit Fenster und Kaufdaten, im Ordner godot:
#   PROBE=1657 xvfb-run -a godot --path . --resolution 600x600 -s res://tests/robe_haende_bild_1657.gd -- --aus=<ordner>
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
	sonne.rotation_degrees = Vector3(-35, -25, 0)
	root.add_child(sonne)
	var kam := Camera3D.new()
	kam.fov = 30.0
	root.add_child(kam)
	for g in ["m", "w"]:
		if not HeldFigur.da("Zauberlehrling", g): continue
		var hw := BrsHeld.fuer_spiel("Test", "Mensch", "Zauberlehrling")
		var aus_r := hw.ausruestung.duplicate()
		var m := HeldFigur.baue({"herkunft": "Zauberlehrling", "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": aus_r}, [])
		if m == null: continue
		root.add_child(m)
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		for i in 6: await process_frame
		var L := ap.get_animation("Stehen").length if ap.has_animation("Stehen") else 1.0
		for b in 3:
			ap.play("Stehen", 0.0); ap.seek(L * float(b) / 3.0, true); ap.speed_scale = 0.0
			for w in [0.0, 70.0]:
				var r := deg_to_rad(w)
				kam.position = Vector3(sin(r) * 1.8, 1.0, cos(r) * 1.8)
				kam.look_at(Vector3(0, 0.95, 0))
				await knips("%s_%d_%d" % [g, b, int(w)])
		m.queue_free()
		for i in 3: await process_frame
	quit(0)
