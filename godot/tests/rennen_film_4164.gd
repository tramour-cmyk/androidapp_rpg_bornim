extends SceneTree
# 416.4 Vergleichsfilm Rennen (Chef 31.10., Build 143: „als würde er Hochsprung machen“): je Fassung des Helden ein Feld nebeneinander,
# Stehen, Gehen, Anlaufen und Rennen wie held.gd (Tempo 2,13 und 4,27 m/s, 5 m/s², Überblendung 0,6 s im selben Schritt, speed_scale
# aus held-info.json, damit die Füße nicht gleiten); erst Spielansicht (30° von oben, Nordwest), dann von der Seite, dann Zeitlupe.
# Boden mit Kachellinien (1,16 m): daran sieht man Tempo und Gleiten. Am Rechner (Bildlauf, PROBE=416.4):
#   HELDE="<Titel>|<Ordner mit held.glb, held-info.json>;…" xvfb-run -a godot --path godot --resolution 1200x900 \
#     --write-movie <x.avi> --fixed-fps 30 -s res://tests/rennen_film_4164.gd
const GEHEN := 1.84 * Karte.TS
const RENNEN := 3.68 * Karte.TS
const BESCHL := 5.0
const FPS := 30.0
# Abschnitte: [Titel, Sekunden, Ansicht, Zeitfaktor]
const TEILE := [["Spielansicht · Echtzeit", 7.0, "spiel", 1.0], ["von der Seite · Echtzeit", 4.0, "seite", 1.0],
	["von der Seite · halbe Geschwindigkeit", 5.0, "seite", 0.5]]

var felder := []
var kopf: Label
var bild := 0
var t_sim := 0.0

func _initialize() -> void: _bau.call_deferred()

func _bau() -> void:
	var helde := OS.get_environment("HELDE").split(";", false)
	var reihe := HBoxContainer.new()
	reihe.set_anchors_preset(Control.PRESET_FULL_RECT)
	reihe.add_theme_constant_override("separation", 4)
	root.add_child(reihe)
	var breite := int(root.get_visible_rect().size.x - 4 * (helde.size() - 1)) / helde.size()
	var hoehe := int(root.get_visible_rect().size.y)
	for e in helde:
		var teil := e.split("|")
		felder.append(_feld(reihe, teil[0], teil[1], Vector2i(breite, hoehe)))
	kopf = Label.new()
	kopf.position = Vector2(0, 8)
	kopf.size = Vector2(root.get_visible_rect().size.x, 40)
	kopf.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kopf.add_theme_font_size_override("font_size", 26)
	kopf.add_theme_color_override("font_color", Color(0.93, 0.8, 0.45))
	root.add_child(kopf)
	process_frame.connect(_schritt)

func _feld(reihe: HBoxContainer, titel: String, ordner: String, px: Vector2i) -> Dictionary:
	var box := SubViewportContainer.new()
	box.stretch = true
	box.custom_minimum_size = Vector2(px)
	reihe.add_child(box)
	var vp := SubViewport.new()
	vp.own_world_3d = true
	vp.size = px
	vp.msaa_3d = Viewport.MSAA_4X
	box.add_child(vp)
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.16, 0.17, 0.16)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.66, 0.75)
	env.ambient_light_energy = 0.75
	we.environment = env
	vp.add_child(we)
	var sonne := DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-50, 30, 0)
	sonne.shadow_enabled = true
	sonne.light_energy = 1.2
	vp.add_child(sonne)
	vp.add_child(_boden())
	var held := Node3D.new()
	held.rotation.y = PI / 2   # läuft nach +X
	vp.add_child(held)
	var modell := Gebiet.lade_glb(ordner + "/held.glb")
	held.add_child(modell)
	var mats := []
	Gebiet.male(modell, null, 2, mats)
	for m in mats: (m as ShaderMaterial).set_shader_parameter("metall", 1.0)
	var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ordner + "/held-info.json"))
	var anim := Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	Gebiet.bewegungen(anim, ["Gehen", "Stehen", "Rennen"])
	anim.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	anim.play("Stehen")
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	cam.near = 0.5
	cam.far = 120.0
	vp.add_child(cam)
	var schild := Label.new()
	schild.text = titel
	schild.position = Vector2(0, px.y - 92)
	schild.size = Vector2(px.x, 80)
	schild.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	schild.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	schild.add_theme_font_size_override("font_size", 22)
	schild.add_theme_color_override("font_color", Color(0.95, 0.93, 0.88))
	box.add_child(schild)
	return {"held": held, "anim": anim, "cam": cam, "gang": float(info["gehen_m_je_s"]), "renn": float(info["rennen_m_je_s"]),
		"tempo": 0.0}

func _boden() -> MeshInstance3D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGB8)
	img.fill(Color(0.36, 0.42, 0.24))
	for i in 64:
		for k in 2:
			img.set_pixel(i, k, Color(0.22, 0.26, 0.15)); img.set_pixel(k, i, Color(0.22, 0.26, 0.15))
	var tex := ImageTexture.create_from_image(img)
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(400, 40)
	m.uv1_scale = Vector3(400 / Karte.TS, 40 / Karte.TS, 1)
	mesh.material = m
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(190, 0, 0)
	return mi

func _teil(t: float) -> Array:
	var a := 0.0
	for e in TEILE:
		if t < a + e[1]: return [e, t - a]
		a += e[1]
	return []

func _schritt() -> void:
	var t := bild / FPS
	bild += 1
	var tl := _teil(t)
	if tl.is_empty(): quit(); return
	var e: Array = tl[0]
	kopf.text = e[0]
	var dt: float = e[3] / FPS
	t_sim += dt
	for f in felder: _held(f, dt, e[2])

# wie held.gd _process: Stehen 0,5 s, Gehen bis 1,6 s, dann Anlauf auf Rennen
func _held(f: Dictionary, dt: float, ansicht: String) -> void:
	var held: Node3D = f["held"]
	var anim: AnimationPlayer = f["anim"]
	var soll := 0.0 if t_sim < 0.5 else (GEHEN if t_sim < 1.6 else RENNEN)
	var moving := soll > 0.0
	f["tempo"] = 0.0 if not moving else (minf(soll, GEHEN) if f["tempo"] <= 0.0 else move_toward(f["tempo"], soll, BESCHL * dt))
	var tempo: float = f["tempo"]
	held.position.x += tempo * dt
	var rennt := moving and tempo > GEHEN * 1.45
	var want := ("Rennen" if rennt else "Gehen") if moving else "Stehen"
	var cur := anim.current_animation
	if cur != want:
		var phase := anim.current_animation_position / maxf(0.001, anim.current_animation_length) if cur != "" else 0.0
		var schritt := cur.begins_with("Gehen") or cur.begins_with("Rennen")
		anim.play(want, 0.6 if schritt and moving else (0.5 if cur.begins_with("Stehen") else 0.25))
		if schritt and moving: anim.seek(phase * anim.get_animation(want).length)
	anim.speed_scale = (tempo / (f["renn"] if rennt else f["gang"])) if moving else 1.0
	anim.advance(dt)
	var cam: Camera3D = f["cam"]
	var ziel := held.position + Vector3(0, 0.9, 0)
	if ansicht == "spiel":
		cam.rotation_degrees = Vector3(-30, Kamera.NORD, 0)
		cam.size = Kamera.NAH
	else:
		cam.rotation_degrees = Vector3(-4, 0, 0)
		cam.size = 2.6
	cam.position = ziel + cam.global_transform.basis.z * 20.0
