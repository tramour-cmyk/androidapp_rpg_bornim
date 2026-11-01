# 458.3 (Archiv 458; 408, Chef 29.10., 11:19–11:26: „alle drehend in einem Film … dann sehe ich auch, wenn es sich dreht, wie es aus
# allen Perspektiven ausschaut“): alle Waffen der Waffenpakete (tools/blender348/waffen_bestand.py; Kaufdateien bleiben auf dem Runner)
# drehend, je Seite 4 × 5, geordnet nach Art (Foliant, Fackel, Armbrust, Bogen, Stab, Stangenwaffe, Hammer, Kolben, Axt, Schwert),
# jede auf 1 m Länge gebracht; darunter Nummer, Paket, Name. Gezeichnet wie Held und Söldner im Kampf (Toon, Tusche nach Licht und
# Sonne mit Schatten aus signatur.gd, 457.2), wie tests/schilde_film.gd (406).
# Nur als Probelauf (389) mit --write-movie: WAFFEN=<ordner> xvfb-run godot --path godot --resolution 1080x2340 --write-movie <datei>.avi
# --fixed-fps 30 -s res://tests/waffen_film.gd
extends SceneTree

const Figur = preload("res://kampf/figur.gd")
const Signatur = preload("res://kampf/signatur.gd")
const DREH_S := 6.0
const SPALTEN := 4
const ZEILEN := 5
const ABSTAND := 0.62
const HOCH := 1.32


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
	var ordner := OS.get_environment("WAFFEN")
	var liste: Array = JSON.parse_string(FileAccess.get_file_as_string(ordner.path_join("waffen.json")))
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
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = ZEILEN * HOCH + 0.3
	cam.position = Vector3(0, 1.2, 6.0)
	cam.look_at_from_position(cam.position, Vector3(0, 0, 0))
	welt.add_child(cam)
	cam.current = true
	Signatur.einrichten(welt, cam, Vector3.ZERO, env.environment, sonne, true)
	await process_frame
	if not Signatur.wache(welt, self, "Waffen-Film"):
		return
	var je := SPALTEN * ZEILEN
	var seiten := ceili(liste.size() / float(je))
	var bilder := 0
	for s in seiten:
		var seite := Node3D.new()
		welt.add_child(seite)
		var dreher: Array = []
		for j in je:
			var i := s * je + j
			if i >= liste.size(): break
			var e: Dictionary = liste[i]
			var doc := GLTFDocument.new()
			var st := GLTFState.new()
			if doc.append_from_file(ordner.path_join(String(e.kennung) + ".glb"), st) != OK:
				print("FEHLT ", e.kennung)
				continue
			var w := doc.generate_scene(st) as Node3D
			_male(w)
			var d := Node3D.new()
			d.position = Vector3((j % SPALTEN - (SPALTEN - 1) / 2.0) * ABSTAND, ((ZEILEN - 1) / 2.0 - j / SPALTEN) * HOCH + 0.08, 0)
			d.add_child(w)
			seite.add_child(d)
			dreher.append(d)
			var l := Label3D.new()
			l.text = "%d %s\n%s" % [i + 1, String(e.paket), String(e.name).left(18)]
			l.font_size = 20
			l.pixel_size = 0.0021
			l.modulate = Color(0.86, 0.74, 0.45)
			l.position = d.position + Vector3(0, -0.58, 0.3)
			seite.add_child(l)
		var t := Label3D.new()
		t.text = "458.3 · Waffen der Bibliothek, Seite %d von %d (alle auf 1 m gebracht)" % [s + 1, seiten]
		t.font_size = 22
		t.pixel_size = 0.0021
		t.modulate = Color(0.86, 0.74, 0.45)
		t.position = Vector3(0, (ZEILEN / 2.0) * HOCH + 0.05, 0.3)
		seite.add_child(t)
		var n := int(DREH_S * 30.0)
		for k in n + 10:
			for d in dreher:
				d.rotation.y = TAU * minf(k, n) / n
			await process_frame
			bilder += 1
		seite.queue_free()
		await process_frame
	print("Waffen-Film: %d Waffen, %d Seiten, %d Bilder" % [liste.size(), seiten, bilder])
	quit(0)
