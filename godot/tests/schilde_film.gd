# 406 (Chef 29.10., 11:13, Archiv 408): alle Schilde der Bibliothek drehend in einem Film, Chef wählt. Liest die Schilde aus
# kampf/daten/schilde/ (tools/blender348/schilde_bestand.py, Kaufdateien, nie im Repository) und zeichnet sie wie im Kampf (Toon wie
# Held und Söldner, figur.gd _toon: Partei, Tusche nach Licht; Farbe aus der Textur, sonst aus der Grundfarbe des Pakets),
# 7 × 3 nebeneinander, jeder dreht sich in DREH_S einmal ganz, darunter Nummer und Paket.
# Nur als Probelauf (389) mit --write-movie: PROBE=406 xvfb-run godot --path godot --resolution 1280x720 --write-movie <datei>.avi
# --fixed-fps 30 -s res://tests/schilde_film.gd
extends SceneTree

const Figur = preload("res://kampf/figur.gd")
const ORDNER := "res://kampf/daten/schilde/"
const DREH_S := 8.0
const SPALTEN := 7
const ABSTAND := 0.85


func _initialize() -> void:
	_run.call_deferred()


func _farbe(src: Material) -> Array:
	var tex: Texture2D = null
	var c := Color(0.7, 0.7, 0.7)
	if src is BaseMaterial3D:
		tex = (src as BaseMaterial3D).albedo_texture
		c = (src as BaseMaterial3D).albedo_color
	return [tex, c]


func _male(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var f := _farbe(mi.mesh.surface_get_material(i))
			var m := ShaderMaterial.new()
			m.shader = Figur.toon_mark()
			m.set_shader_parameter("fill", 0.42)
			if f[0]:
				m.set_shader_parameter("tex", f[0])
			else:
				var img := Image.create(4, 4, false, Image.FORMAT_RGB8)
				img.fill(f[1])
				m.set_shader_parameter("tex", ImageTexture.create_from_image(img))
			mi.set_surface_override_material(i, m)
	for c in n.get_children():
		_male(c)


func _run() -> void:
	var liste: Array = JSON.parse_string(FileAccess.get_file_as_string(ORDNER + "schilde.json"))
	var welt := Node3D.new()
	root.add_child(welt)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.05, 0.05, 0.05)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.55, 0.52, 0.48)
	env.environment.ambient_light_energy = 0.6
	welt.add_child(env)
	var sonne := DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-50, 35, 0)
	sonne.light_energy = 1.2
	welt.add_child(sonne)
	var zeilen := ceili(liste.size() / float(SPALTEN))
	var dreher: Array = []
	for i in liste.size():
		var e: Dictionary = liste[i]
		var doc := GLTFDocument.new()
		var st := GLTFState.new()
		if doc.append_from_file(ORDNER + String(e.kennung) + ".glb", st) != OK:
			continue
		var s := doc.generate_scene(st) as Node3D
		_male(s)
		var d := Node3D.new()
		d.position = Vector3((i % SPALTEN - (SPALTEN - 1) / 2.0) * ABSTAND, ((zeilen - 1) / 2.0 - i / SPALTEN) * ABSTAND * 1.15, 0)
		d.add_child(s)
		welt.add_child(d)
		dreher.append(d)
		var l := Label3D.new()
		l.text = "%d  %s" % [i + 1, String(e.paket)]
		l.font_size = 22
		l.pixel_size = 0.0022
		l.modulate = Color(0.86, 0.74, 0.45)
		l.position = d.position + Vector3(0, -0.4, 0.2)
		welt.add_child(l)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = zeilen * ABSTAND * 1.15 + 0.2
	cam.position = Vector3(0, 1.2, 6.0)
	cam.look_at_from_position(cam.position, Vector3(0, 0, 0))
	welt.add_child(cam)
	cam.current = true
	var n := int(DREH_S * 30.0)
	for k in n + 15:
		for d in dreher:
			d.rotation.y = TAU * minf(k, n) / n
		await process_frame
	print("Schilde-Film: %d Schilde, %d Bilder" % [dreher.size(), n + 15])
	quit(0)
