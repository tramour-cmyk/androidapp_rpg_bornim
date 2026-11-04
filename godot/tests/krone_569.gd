extends SceneTree
# 569 (Chef 04.11., 19:44, Bild 558 Probe 4 Wald Tag: Baumkronen „ein einziger Brei“, oben ohne Umriss): eine Kugel als Krone
# mit dem Laub-Shader (toon.gdshader, kontur 1, Sonne von oben wie im Spiel).
# Gemessen wird die Tusche am Rand oben (Lichtseite), seitlich und unten (Schattenseite): wie viel dunkler als die Mitte der Krone.
# Je einmal kontur_licht 0 (bis 569) und Gebiet.KRONE_LICHT. Grenze: oben mindestens OBEN_MIN der Schattenseite; Busch bleibt 0.
# Aufruf: im Ordner godot mit Fenster: xvfb-run godot --path . --resolution 800x800 -s res://tests/krone_569.gd (Exit 0 = gut)

const OBEN_MIN := 0.35
var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _pruef(was: String, gut: bool, info := "") -> void:
	print(("gut " if gut else "FALSCH ") + was + ("" if info == "" else ": " + info))
	if not gut:
		fehler += 1


func _krone(pos: Vector3, licht: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = 1.0
	s.height = 2.0
	s.radial_segments = 48
	s.rings = 24
	mi.mesh = s
	var m := ShaderMaterial.new()
	m.shader = load("res://shader/toon.gdshader")
	var weiss := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	weiss.fill(Color(0.45, 0.62, 0.3))   # Laubgrün
	m.set_shader_parameter("tex", ImageTexture.create_from_image(weiss))
	m.set_shader_parameter("kontur", 1.0)
	m.set_shader_parameter("kontur_licht", licht)
	m.set_shader_parameter("licht_dir", Vector3(0.3, 1.0, 0.4).normalized())
	mi.material_override = m
	mi.position = pos
	return mi


func _hell(img: Image, p: Vector2i) -> float:
	var c := img.get_pixelv(p.clamp(Vector2i.ZERO, img.get_size() - Vector2i.ONE))
	return c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722


## dunkelster Wert auf dem Strahl von der Mitte nach außen bis zum Rand (Umriss), gegen die Mitte
func _tusche(img: Image, mitte: Vector2, r_px: float, richtung: Vector2) -> float:
	var innen := _hell(img, Vector2i(mitte + richtung * r_px * 0.5))
	var tief := innen
	for i in range(int(r_px * 0.75), int(r_px) + 1):
		tief = minf(tief, _hell(img, Vector2i(mitte + richtung * i)))
	return clampf((innen - tief) / maxf(innen, 0.01), 0.0, 1.0)


func _lauf() -> void:
	# Lauf 2 (19:51): ohne das stand der Schirm auf 2340 × 2340, das Bild 800 × 800, gemessen wurde neben der Kugel
	DisplayServer.window_set_size(Vector2i(800, 800))
	root.size = Vector2i(800, 800)
	root.content_scale_size = Vector2i(800, 800)
	await process_frame
	var welt := Node3D.new()
	root.add_child(welt)
	var cam := Camera3D.new()
	cam.fov = 40
	welt.add_child(cam)
	cam.look_at_from_position(Vector3(0, 2.5, 8), Vector3.ZERO)
	cam.make_current()
	var sonne := DirectionalLight3D.new()
	welt.add_child(sonne)
	sonne.look_at_from_position(Vector3.ZERO, -Vector3(0.3, 1.0, 0.4), Vector3.FORWARD)
	var umgebung := WorldEnvironment.new()
	umgebung.environment = Environment.new()
	umgebung.environment.background_mode = Environment.BG_COLOR
	umgebung.environment.background_color = Color(1, 1, 1)   # weiß: Kantenpixel mischen heller, nur Tusche macht dunkler
	umgebung.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	umgebung.environment.ambient_light_color = Color(0.4, 0.4, 0.4)
	welt.add_child(umgebung)
	var werte := {}
	for licht in [0.0, Gebiet.KRONE_LICHT]:
		var a := _krone(Vector3.ZERO, licht)
		welt.add_child(a)
		for i in 10: await process_frame
		await RenderingServer.frame_post_draw
		var img := root.get_texture().get_image()
		var m := cam.unproject_position(a.position)
		var r_px: float = m.distance_to(cam.unproject_position(a.position + cam.global_basis.x * 1.0))
		print("Mitte %s, Halbmesser %.0f px, Bild %s" % [m, r_px, img.get_size()])
		var oben := _tusche(img, m, r_px, Vector2.UP)
		var seite := _tusche(img, m, r_px, Vector2.LEFT)
		var unten := _tusche(img, m, r_px, Vector2(-0.5, 0.86).normalized())
		werte[licht] = [oben, seite, unten]
		print("kontur_licht %.1f: Tusche oben %.2f, seitlich %.2f, unten %.2f (Anteil dunkler als innen)" % [licht, oben, seite, unten])
		if OS.get_environment("KRONE_AUS") != "":
			img.save_png(OS.get_environment("KRONE_AUS") + "/krone_569_%d.png" % int(licht * 10))
		a.free()
	var neu: Array = werte[Gebiet.KRONE_LICHT]
	var alt: Array = werte[0.0]
	_pruef("bis 569 oben fast keine Tusche (Ursache nachgestellt)", alt[0] < 0.5 * alt[2], "oben %.2f, unten %.2f" % [alt[0], alt[2]])
	_pruef("neu oben umrissen", neu[0] >= OBEN_MIN * neu[2] and neu[0] > alt[0] + 0.05, "oben %.2f, unten %.2f" % [neu[0], neu[2]])
	_pruef("Schattenseite unverändert", absf(neu[2] - alt[2]) < 0.05, "%.2f gegen %.2f" % [neu[2], alt[2]])
	print("KRONE569 %d Fehler" % fehler)
	quit(1 if fehler else 0)
