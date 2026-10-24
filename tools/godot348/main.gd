extends Node3D
# 348.4 Probe-App: Held v3 (Blender, Skelett, Gehen/Stehen) auf einem Dorfstueck Bornim, Tag und Nacht mit Fackel,
# Tippen = hingehen (Wegsuche auf den Kacheln), Ziehen = Joystick; Nahstufe; Anzeige Bildrate und Speicher.
# Modelle kommen als glTF (Zentimeter) und werden zur Laufzeit geladen (daten/*.bin), Look als Shader (toon, tusche).

const S := 0.01                       # Zentimeter -> Meter
const FERN := 9.5                     # Kamerahoehe des Bildausschnitts in Metern (Gebietskarte)
const NAH := 2.4                      # Nahstufe: Gesicht und Haende
const TEMPO := 1.08 * 1.4             # m/s; Gehen wird gleich schneller abgespielt, die Fuesse gleiten nicht

var info: Dictionary
var ts := 1.16
var held: Node3D
var anim: AnimationPlayer
var cam: Camera3D
var sun: DirectionalLight3D
var env: Environment
var lamps: Array = []
var torch: OmniLight3D
var flame: MeshInstance3D
var glas: ShaderMaterial
var toon: Shader
var astar := AStarGrid2D.new()
var path: Array = []
var night := 0.0
var night_goal := 0.0
var near := false
var zoom := FERN
var hud: Label
var joy_from := Vector2.ZERO
var joy_vec := Vector2.ZERO
var touch_down := false
var dragging := false
var joy_draw: Control
var torch_set := false
var times: Array = []
var t_all := 0.0

func _ready() -> void:
	toon = load("res://toon.gdshader")
	info = JSON.parse_string(FileAccess.get_file_as_string("res://daten/dorf-info.json"))
	ts = float(info["kachel_cm"]) * S
	var dorf := load_glb("res://daten/dorf.bin")
	dorf.scale = Vector3.ONE * S
	add_child(dorf)
	paint(dorf)
	held = load_glb("res://daten/held.bin")
	held.scale = Vector3.ONE * S
	add_child(held)
	paint(held)
	anim = find(held, "AnimationPlayer") as AnimationPlayer
	for n in ["Gehen", "Stehen"]:
		if anim and anim.has_animation(n): anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
	if anim: anim.play("Stehen")
	var st: Dictionary = info["start"]
	held.position = tile_pos(Vector2i(int(st["spalte"]), int(st["zeile"])))
	setup_grid()
	setup_light()
	setup_torch()
	setup_cam()
	setup_hud()
	shots()

# Am Rechner: godot -- --bilder=<ordner> legt Standbilder ab (Tag fern, Gehen, Nacht fern, Nacht nah) und beendet sich
func shots() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--bilder="): dir = a.substr(9)
	if dir == "": return
	await get_tree().create_timer(1.0).timeout
	await snap(dir + "/tag.png")
	go_to(held.position + Vector3(3.0, 0, -2.0))
	await get_tree().create_timer(0.8).timeout
	await snap(dir + "/gehen.png")
	night_goal = 1.0
	await get_tree().create_timer(2.5).timeout
	await snap(dir + "/nacht.png")
	_on_near()
	await get_tree().create_timer(1.5).timeout
	await snap(dir + "/nacht-nah.png")
	night_goal = 0.0
	await get_tree().create_timer(2.0).timeout
	await snap(dir + "/tag-nah.png")
	get_tree().quit()

func snap(p: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(p)
	print("BILD ", p, " ", hud.text.replace("\n", " | "))

func load_glb(p: String) -> Node3D:
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", state)
	if err != OK: push_error("glTF %s: %d" % [p, err])
	return doc.generate_scene(state) as Node3D

func find(n: Node, cls: String) -> Node:
	if n.get_class() == cls: return n
	for c in n.get_children():
		var r := find(c, cls)
		if r: return r
	return null

func paint(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var m := ShaderMaterial.new()
		m.shader = toon
		if String(mi.name).contains("Glas"):
			glas = m
		for i in mi.mesh.get_surface_count(): mi.set_surface_override_material(i, m)
	for c in n.get_children(): paint(c)

# ---------------------------------------------------------------- Kacheln, Wegsuche
func tile_pos(t: Vector2i) -> Vector3:
	return Vector3((t.x + 0.5) * ts, 0.02, (t.y + 0.5) * ts)
func pos_tile(p: Vector3) -> Vector2i:
	return Vector2i(floori(p.x / ts), floori(p.z / ts))
func walkable(t: Vector2i) -> bool:
	if t.x < 0 or t.y < 0 or t.y >= int(info["zeilen"]) or t.x >= int(info["spalten"]): return false
	return int(info["begehbar"][t.y][t.x]) == 1
func setup_grid() -> void:
	astar.region = Rect2i(0, 0, int(info["spalten"]), int(info["zeilen"]))
	astar.cell_size = Vector2.ONE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()
	for y in int(info["zeilen"]):
		for x in int(info["spalten"]):
			if not walkable(Vector2i(x, y)): astar.set_point_solid(Vector2i(x, y))
func go_to(p: Vector3) -> void:
	var a := pos_tile(held.position)
	var b := pos_tile(p)
	if not walkable(b) or not walkable(a): return
	path.clear()
	var ids := astar.get_id_path(a, b)
	for k in range(1, ids.size()): path.append(tile_pos(ids[k]))
	if path.size() > 0: path[path.size() - 1] = Vector3(p.x, 0.02, p.z)
	else: path.append(Vector3(p.x, 0.02, p.z))

# ---------------------------------------------------------------- Licht, Tag und Nacht
func setup_light() -> void:
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 25, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 40.0
	add_child(sun)
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	for l in info["lichter"]:
		if l["art"] != "laterne": continue
		var o := OmniLight3D.new()
		var p: Array = l["pos"]
		o.position = Vector3(p[0], p[2], -p[1]) * S
		o.omni_range = 7.0
		o.light_color = Color(1.0, 0.7, 0.38)
		o.omni_attenuation = 1.2
		add_child(o)
		lamps.append(o)
	apply_night()

func apply_night() -> void:
	var k := night
	sun.light_energy = lerpf(1.25, 0.22, k)
	sun.light_color = Color(1.0, 0.94, 0.82).lerp(Color(0.55, 0.65, 1.0), k)
	env.ambient_light_color = Color(0.62, 0.66, 0.75).lerp(Color(0.16, 0.2, 0.36), k)
	env.ambient_light_energy = lerpf(0.55, 0.45, k)
	env.background_color = Color(0.36, 0.42, 0.34).lerp(Color(0.03, 0.04, 0.08), k)
	for o in lamps: (o as OmniLight3D).light_energy = 2.6 * k
	if glas: glas.set_shader_parameter("glow", 1.5 * k)
	if torch:
		torch.light_energy = 2.2 * k
		torch.visible = k > 0.02
		flame.visible = k > 0.02

func setup_torch() -> void:
	# Fackel in der rechten Hand: Stiel, Flamme (leuchtet), Licht; haengt am Knochen des Handgelenks
	var sk := find(held, "Skeleton3D") as Skeleton3D
	var ba := BoneAttachment3D.new()
	ba.bone_name = "foR-wrR"
	sk.add_child(ba)
	var t := Node3D.new()
	t.name = "Fackel"
	ba.add_child(t)
	var stick := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.022; cm.bottom_radius = 0.016; cm.height = 0.52
	stick.mesh = cm
	var wm := StandardMaterial3D.new()
	wm.albedo_color = Color(0.22, 0.14, 0.08)
	stick.material_override = wm
	stick.position = Vector3(0, 0.12, 0)
	t.add_child(stick)
	flame = MeshInstance3D.new()
	var fm := SphereMesh.new()
	fm.radius = 0.05; fm.height = 0.16
	flame.mesh = fm
	var em := StandardMaterial3D.new()
	em.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	em.albedo_color = Color(1.0, 0.62, 0.2)
	flame.material_override = em
	flame.position = Vector3(0, 0.42, 0)
	t.add_child(flame)
	torch = OmniLight3D.new()
	torch.position = Vector3(0, 0.48, 0)
	torch.light_color = Color(1.0, 0.6, 0.3)
	torch.omni_range = 6.0
	torch.omni_attenuation = 1.4
	t.add_child(torch)

func fix_torch() -> void:
	# einmal, wenn die Pose steht: Fackel senkrecht in die Faust, danach dreht sie mit dem Arm
	var t := held.find_child("Fackel", true, false) as Node3D
	var ba := t.get_parent() as Node3D
	t.global_basis = Basis(Vector3.UP, held.rotation.y).rotated(held.global_basis.x.normalized(), deg_to_rad(-12))
	t.global_position = ba.global_position + Vector3(0, -0.07, 0)
	torch_set = true

# ---------------------------------------------------------------- Kamera
func setup_cam() -> void:
	cam = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = zoom
	cam.near = 0.5
	cam.far = 120.0
	cam.rotation_degrees = Vector3(-30, 45, 0)
	add_child(cam)
	# Tusche: Bildschirmflaeche vor der Kamera
	var q := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(2, 2)
	q.mesh = qm
	q.extra_cull_margin = 16384.0
	q.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := ShaderMaterial.new()
	m.shader = load("res://tusche.gdshader")
	q.material_override = m
	cam.add_child(q)
	q.position = Vector3(0, 0, -1)
	follow(1.0)

func follow(k: float) -> void:
	var target := held.position + Vector3(0, 0.9 if near else 0.0, 0)
	var want := target + cam.global_basis.z * 40.0
	cam.position = cam.position.lerp(want, k)
	cam.size = lerpf(cam.size, zoom, k)

# ---------------------------------------------------------------- Bedienung
func setup_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(24, 60)
	hud.add_theme_font_size_override("font_size", 30)
	hud.add_theme_color_override("font_color", Color(1, 0.86, 0.5))
	hud.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	hud.add_theme_constant_override("outline_size", 8)
	layer.add_child(hud)
	var box := VBoxContainer.new()
	box.position = Vector2(760, 60)
	layer.add_child(box)
	for spec in [["Tag / Nacht", "_on_night"], ["Nah / Fern", "_on_near"]]:
		var b := Button.new()
		b.text = spec[0]
		b.custom_minimum_size = Vector2(290, 110)
		b.add_theme_font_size_override("font_size", 34)
		b.pressed.connect(Callable(self, spec[1]))
		box.add_child(b)
	joy_draw = Control.new()
	joy_draw.set_anchors_preset(Control.PRESET_FULL_RECT)
	joy_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	joy_draw.draw.connect(_draw_joy)
	layer.add_child(joy_draw)

func _on_night() -> void: night_goal = 0.0 if night_goal > 0.5 else 1.0
func _on_near() -> void:
	near = not near
	zoom = NAH if near else FERN

func _draw_joy() -> void:
	if not dragging: return
	joy_draw.draw_circle(joy_from, 110, Color(0, 0, 0, 0.25))
	joy_draw.draw_arc(joy_from, 110, 0, TAU, 48, Color(1, 0.86, 0.5, 0.6), 4)
	joy_draw.draw_circle(joy_from + joy_vec * 110, 46, Color(1, 0.86, 0.5, 0.55))

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventScreenTouch:
		var t := e as InputEventScreenTouch
		if t.index != 0: return
		if t.pressed:
			touch_down = true; dragging = false; joy_from = t.position; joy_vec = Vector2.ZERO
		else:
			if not dragging: tap(t.position)
			touch_down = false; dragging = false; joy_vec = Vector2.ZERO
		joy_draw.queue_redraw()
	elif e is InputEventScreenDrag and touch_down:
		var d := (e as InputEventScreenDrag).position - joy_from
		if d.length() > 28: dragging = true; path.clear()
		joy_vec = d / 110.0
		if joy_vec.length() > 1.0: joy_vec = joy_vec.normalized()
		joy_draw.queue_redraw()

func tap(sp: Vector2) -> void:
	var o := cam.project_ray_origin(sp)
	var n := cam.project_ray_normal(sp)
	if absf(n.y) < 1e-4: return
	var p := o + n * (-o.y / n.y)
	go_to(p)

# ---------------------------------------------------------------- Lauf
func _process(dt: float) -> void:
	t_all += dt
	if not torch_set and t_all > 0.2: fix_torch()
	night = move_toward(night, night_goal, dt / 1.5)
	apply_night()
	if torch: torch.light_energy = 2.2 * night * (0.88 + 0.12 * sin(t_all * 17.0) * sin(t_all * 7.3))
	var dir := Vector3.ZERO
	if dragging and joy_vec.length() > 0.15:
		var r := cam.global_basis.x; r.y = 0
		var f := -cam.global_basis.z; f.y = 0
		dir = (r.normalized() * joy_vec.x - f.normalized() * joy_vec.y)
		if dir.length() > 1.0: dir = dir.normalized()
	elif path.size() > 0:
		var to: Vector3 = path[0] - held.position; to.y = 0
		if to.length() < 0.06:
			path.pop_front()
		else:
			dir = to.normalized()
	var moving := dir.length() > 0.05
	if moving:
		var step := dir * TEMPO * dt
		var np := held.position + step
		var probe := np + dir.normalized() * 0.3
		if walkable(pos_tile(probe)) and walkable(pos_tile(np)):
			held.position = np
		elif walkable(pos_tile(held.position + Vector3(step.x, 0, 0) + Vector3(signf(step.x) * 0.3, 0, 0))):
			held.position.x += step.x
		elif walkable(pos_tile(held.position + Vector3(0, 0, step.z) + Vector3(0, 0, signf(step.z) * 0.3))):
			held.position.z += step.z
		else:
			path.clear()
		var yaw := atan2(dir.x, dir.z)
		held.rotation.y = lerp_angle(held.rotation.y, yaw, minf(1.0, dt * 12.0))
	if anim:
		var want := "Gehen" if moving else "Stehen"
		if anim.current_animation != want: anim.play(want, 0.18)
		anim.speed_scale = (TEMPO / 1.08) * clampf(dir.length(), 0.5, 1.0) if moving else 1.0
	follow(minf(1.0, dt * 5.0))
	measure(dt)

func measure(dt: float) -> void:
	times.append(dt)
	if times.size() > 240: times.pop_front()
	if Engine.get_process_frames() % 15 != 0: return
	var s := times.duplicate()
	s.sort()
	var avg := 0.0
	for x in s: avg += x
	avg /= s.size()
	var p95: float = s[int(s.size() * 0.95) - 1] if s.size() > 20 else s[s.size() - 1]
	hud.text = "Bilder/s %d  (Mittel %.1f ms, 95 %% unter %.1f ms)\nSpeicher %.0f MB, Grafik %.0f MB\nZeichenaufrufe %d, Dreiecke %dk\n%s · %s" % [
		Engine.get_frames_per_second(), avg * 1000.0, p95 * 1000.0,
		OS.get_static_memory_usage() / 1048576.0,
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME) / 1000.0),
		RenderingServer.get_video_adapter_name(), ProjectSettings.get_setting("rendering/renderer/rendering_method")]
