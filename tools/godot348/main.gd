extends Node3D
# 348.5 Probe-App: Held (Blender, Skelett, Gehen/Stehen, gebackene Textur) im Dorf Bornim mit gemalten Texturen,
# Tag und Nacht mit Fackel, Gras, Schmetterlinge, Rauch, Gluehwuermchen; Tippen = hingehen, Ziehen = Joystick;
# zwei Finger = drehen und zoomen, Knoepfe drehen in 45-Grad-Schritten; Nahstufe; Anzeige Bildrate und Speicher.
# Modelle kommen als glTF (Zentimeter) und werden zur Laufzeit geladen (daten/*.bin, Bilder daten/*.bild), Look als Shader.

const S := 0.01                       # Zentimeter -> Meter
const FERN := 9.0                     # Bildbreite in Metern (Gebietskarte, etwa sechs Kacheln quer)
const NAH := 3.4                      # Nahstufe: Gesicht und Haende
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
var dorf_mats: Array = []
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
var yaw := 45.0
var yaw_goal := 45.0
var touches := {}
var pinch_d := 0.0
var pinch_a := 0.0
var wasser: ShaderMaterial
var halm_mat: ShaderMaterial
var falter: Array = []
var rauch: Array = []
var gluehen: Array = []
var texcache := {}

func _ready() -> void:
	toon = load("res://toon.gdshader")
	info = JSON.parse_string(FileAccess.get_file_as_string("res://daten/dorf-info.json"))
	ts = float(info["kachel_cm"]) * S
	var dorf := load_glb("res://daten/dorf.bin")
	dorf.scale = Vector3.ONE * S
	add_child(dorf)
	paint(dorf)
	var wiese := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(160, 160)
	wiese.mesh = pm
	var wm := StandardMaterial3D.new()
	wm.albedo_color = Color(0.1, 0.13, 0.07)    # Waldboden ausserhalb der Karte
	wm.roughness = 1.0
	wiese.material_override = wm
	wiese.position = Vector3(float(info["spalten"]) * ts / 2, -0.03, float(info["zeilen"]) * ts / 2)
	add_child(wiese)
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
	setup_life()
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
	_on_near()
	yaw_goal += 135.0
	await get_tree().create_timer(2.0).timeout
	await snap(dir + "/gedreht.png")
	go_to(tile_pos(Vector2i(18, 15)))
	yaw_goal -= 135.0
	await get_tree().create_timer(6.0).timeout
	await snap(dir + "/brunnen.png")
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

func bild(name: String) -> ImageTexture:
	if texcache.has(name): return texcache[name]
	var img := Image.new()
	img.load_png_from_buffer(FileAccess.get_file_as_bytes("res://daten/%s.bild" % name))
	if not img.has_mipmaps(): img.generate_mipmaps()
	var t := ImageTexture.create_from_image(img)
	texcache[name] = t
	return t

func mip(t: Texture2D) -> Texture2D:
	# Bilder aus dem glTF bekommen Mipmaps (sonst flimmern Muster in der Ferne)
	if t == null: return null
	if texcache.has(t): return texcache[t]
	var img := t.get_image()
	if img == null: return t
	if img.is_compressed(): img.decompress()
	if not img.has_mipmaps(): img.generate_mipmaps()
	var r := ImageTexture.create_from_image(img)
	texcache[t] = r
	return r

func paint(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var nm := String(mi.name)
		for i in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(i)
			var m := ShaderMaterial.new()
			if nm.contains("Boden"):
				m.shader = load("res://boden.gdshader")
				m.set_shader_parameter("maske", bild("boden-maske"))
				for k in ["gras", "erde", "pflaster"]: m.set_shader_parameter(k, bild(k))
				m.set_shader_parameter("karte", Vector2(float(info["spalten"]), float(info["zeilen"])) * ts)
			elif nm.contains("Wasser"):
				m.shader = load("res://wasser.gdshader")
				wasser = m
			else:
				m.shader = toon
				var tex: Texture2D = null
				if src is BaseMaterial3D: tex = (src as BaseMaterial3D).albedo_texture
				m.set_shader_parameter("tex", mip(tex) if tex else bild("weiss"))
				if src and String(src.resource_name).begins_with("laub"): m.set_shader_parameter("sway", 1.0)
				if nm.contains("Glas"): glas = m
				if nm.begins_with("Dorf"): dorf_mats.append(m)
			mi.set_surface_override_material(i, m)
		print("NETZ ", nm, " Flaechen ", mi.mesh.get_surface_count())
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
	sun.directional_shadow_max_distance = 20.0
	sun.shadow_blur = 1.5
	sun.shadow_normal_bias = 1.2
	add_child(sun)
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.8
	env.adjustment_contrast = 1.06
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
		o.omni_attenuation = 0.8
		add_child(o)
		lamps.append(o)
	apply_night()

func apply_night() -> void:
	var k := night
	sun.light_energy = lerpf(1.3, 0.5, k)
	sun.light_color = Color(1.0, 0.94, 0.82).lerp(Color(0.7, 0.76, 0.95), k)
	env.ambient_light_color = Color(0.62, 0.66, 0.75).lerp(Color(0.22, 0.26, 0.36), k)
	env.ambient_light_energy = lerpf(0.55, 1.2, k)
	env.background_color = Color(0.36, 0.42, 0.34).lerp(Color(0.03, 0.04, 0.08), k)
	for o in lamps: (o as OmniLight3D).light_energy = 16.0 * k
	if glas: glas.set_shader_parameter("glow", 1.5 * k)
	if wasser: wasser.set_shader_parameter("night", k)
	for f in falter: (f["n"] as Node3D).visible = k < 0.5
	for g in gluehen: (g as CPUParticles3D).emitting = k > 0.6
	for r in rauch: (r as CPUParticles3D).color = Color(0.70, 0.68, 0.65, 0.55).lerp(Color(0.31, 0.29, 0.28, 0.5), k)
	if torch:
		torch.light_energy = 3.0 * k
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
	wm.albedo_color = Color(0.42, 0.28, 0.16)
	stick.material_override = wm
	stick.position = Vector3(0, 0.12, 0)
	t.add_child(stick)
	flame = MeshInstance3D.new()
	var fm := CylinderMesh.new()
	fm.top_radius = 0.0; fm.bottom_radius = 0.055; fm.height = 0.2; fm.radial_segments = 10; fm.rings = 1
	flame.mesh = fm
	var em := StandardMaterial3D.new()
	em.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	em.albedo_color = Color(1.0, 0.62, 0.18)
	em.emission_enabled = true
	em.emission = Color(1.0, 0.42, 0.08)
	em.emission_energy_multiplier = 3.0
	flame.material_override = em
	flame.position = Vector3(0, 0.46, 0)
	t.add_child(flame)
	torch = OmniLight3D.new()
	torch.position = Vector3(0, 0.6, 0)
	torch.light_color = Color(1.0, 0.72, 0.38)
	torch.omni_range = 8.0
	torch.omni_attenuation = 2.0
	t.add_child(torch)

func fix_torch() -> void:
	# einmal, wenn die Pose steht: Fackel senkrecht in die Faust, danach dreht sie mit dem Arm
	var t := held.find_child("Fackel", true, false) as Node3D
	var ba := t.get_parent() as Node3D
	t.global_basis = Basis(Vector3.UP, held.rotation.y).rotated(held.global_basis.x.normalized(), deg_to_rad(-12))
	t.global_position = ba.global_position + Vector3(0, -0.07, 0)
	torch_set = true
	print("FACKEL ", t.global_position, " Held ", held.global_position, " Hand ", ba.global_position, " Massstab ", t.global_basis.get_scale())

# ---------------------------------------------------------------- Leben: Gras, Korn, Schmetterlinge, Rauch, Gluehwuermchen (WorldScreen.kt)
func cross_mesh() -> ArrayMesh:
	# zwei gekreuzte Flaechen, 1 m breit und hoch, Fuss bei y = 0
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for a in [0.0, PI * 0.5]:
		var r := Vector3(cos(a), 0, sin(a)) * 0.5
		var q := [-r, r, r + Vector3.UP, -r + Vector3.UP]
		var uv := [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
		for k in [0, 1, 2, 0, 2, 3]:
			st.set_normal(Vector3.UP); st.set_uv(uv[k]); st.add_vertex(q[k])
	return st.commit()

func setup_life() -> void:
	var karte: Array = info["karte"]
	var mimg := Image.new()
	mimg.load_png_from_buffer(FileAccess.get_file_as_bytes("res://daten/boden-maske.bild"))
	var rng := RandomNumberGenerator.new(); rng.seed = 348
	var xf: Array = []; var cu: Array = []
	for r in int(info["zeilen"]):
		var row: String = karte[r]
		for c in int(info["spalten"]):
			var t := row[c]
			var n := 0
			var korn := t == "c"
			if t == "." or t == "f": n = 9
			elif t == "T": n = 5
			elif korn: n = 46
			for k in n:
				var x := (c + rng.randf()) * ts; var z := (r + rng.randf()) * ts
				if not korn:
					var px := mimg.get_pixel(clampi(int(x / ts * 16), 0, mimg.get_width() - 1), clampi(int(z / ts * 16), 0, mimg.get_height() - 1))
					if px.r > 0.3 or px.g > 0.25: continue
				var s := rng.randf_range(0.8, 1.05) if korn else rng.randf_range(0.16, 0.34)
				var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s * (0.6 if korn else 1.0), s * rng.randf_range(0.75, 1.2), s * (0.6 if korn else 1.0)))
				xf.append(Transform3D(b, Vector3(x, 0.0, z)))
				var g := rng.randf_range(0.85, 1.2)
				if korn: cu.append(Color(1.95 * g, 1.45 * g, 0.55, 1))
				else: cu.append(Color(0.95 * g, 1.0 * g, 0.85 * g, 1))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = cross_mesh()
	mm.instance_count = xf.size()
	for i in xf.size():
		mm.set_instance_transform(i, xf[i]); mm.set_instance_custom_data(i, cu[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	halm_mat = ShaderMaterial.new(); halm_mat.shader = load("res://halm.gdshader")
	halm_mat.set_shader_parameter("tex", bild("halme"))
	mmi.material_override = halm_mat
	add_child(mmi)
	print("HALME ", xf.size())
	# Schmetterlinge an den Blumen (weiss, gelb, orange, blau)
	var cols := [Color(0.97, 0.96, 0.92), Color(0.97, 0.88, 0.38), Color(0.94, 0.63, 0.25), Color(0.5, 0.72, 0.97)]
	var spots: Array = []
	for l in info["lichter"]:
		if l["art"] == "blumen" or l["art"] == "heu": spots.append(l["pos"])
	for k in spots.size():
		var p: Array = spots[k]
		var n := Node3D.new()
		var wm := StandardMaterial3D.new()
		wm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		wm.cull_mode = BaseMaterial3D.CULL_DISABLED
		wm.albedo_color = cols[k % cols.size()]
		var wings: Array = []
		for sgn in [-1, 1]:
			var piv := Node3D.new()
			n.add_child(piv)
			var w := MeshInstance3D.new()
			var qm := QuadMesh.new(); qm.size = Vector2(0.055, 0.045)
			w.mesh = qm; w.material_override = wm
			w.rotation_degrees = Vector3(-90, 0, 0)
			w.position = Vector3(0.03 * sgn, 0, 0)
			piv.add_child(w)
			wings.append([piv, sgn])
		add_child(n)
		falter.append({"n": n, "w": wings, "c": Vector3(float(p[0]), float(p[2]), -float(p[1])) * S, "ph": rng.randf() * TAU, "sp": rng.randf_range(0.6, 1.0), "r": rng.randf_range(0.6, 1.4)})
	# Rauch aus den Schornsteinen, Gluehwuermchen ueber den Wiesen
	for l in info["lichter"]:
		var p: Array = l["pos"]
		var at := Vector3(float(p[0]), float(p[2]), -float(p[1])) * S
		if l["art"] == "rauch":
			var pr := CPUParticles3D.new()
			pr.amount = 24; pr.lifetime = 6.0; pr.preprocess = 6.0
			pr.direction = Vector3(0, 1, 0); pr.spread = 12.0
			pr.initial_velocity_min = 0.18; pr.initial_velocity_max = 0.3
			pr.gravity = Vector3(0.09, 0.03, 0.04)
			pr.scale_amount_min = 0.5; pr.scale_amount_max = 0.8
			var cv := Curve.new(); cv.add_point(Vector2(0, 0.35)); cv.add_point(Vector2(1, 1.6)); pr.scale_amount_curve = cv
			var gr := Gradient.new(); gr.set_color(0, Color(1, 1, 1, 0)); gr.add_point(0.15, Color(1, 1, 1, 0.55)); gr.set_color(gr.get_point_count() - 1, Color(1, 1, 1, 0))
			pr.color_ramp = gr
			var qm := QuadMesh.new(); qm.size = Vector2(0.45, 0.45)
			var sm := StandardMaterial3D.new()
			sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			sm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
			sm.vertex_color_use_as_albedo = true
			sm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
			sm.albedo_texture = soft_dot()
			qm.material = sm
			pr.mesh = qm
			pr.position = at
			add_child(pr); rauch.append(pr)
		elif l["art"] == "blumen":
			var ff := CPUParticles3D.new()
			ff.amount = 7; ff.lifetime = 2.2; ff.emitting = false
			ff.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX; ff.emission_box_extents = Vector3(2.2, 0.4, 2.2)
			ff.gravity = Vector3.ZERO; ff.direction = Vector3(1, 0.3, 0); ff.spread = 180.0
			ff.initial_velocity_min = 0.03; ff.initial_velocity_max = 0.12
			var gr := Gradient.new(); gr.set_color(0, Color(0.97, 1, 0.78, 0)); gr.add_point(0.3, Color(0.97, 1, 0.78, 1)); gr.add_point(0.6, Color(0.88, 0.97, 0.47, 0.9)); gr.set_color(gr.get_point_count() - 1, Color(0.88, 0.97, 0.47, 0))
			ff.color_ramp = gr
			var qm := QuadMesh.new(); qm.size = Vector2(0.07, 0.07)
			var sm := StandardMaterial3D.new()
			sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			sm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
			sm.vertex_color_use_as_albedo = true
			sm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
			sm.albedo_texture = soft_dot()
			qm.material = sm
			ff.mesh = qm
			ff.position = at + Vector3(0, 0.7, 0)
			add_child(ff); gluehen.append(ff)

var _dot: ImageTexture
func soft_dot() -> ImageTexture:
	if _dot: return _dot
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for y in 32:
		for x in 32:
			var d := Vector2(x - 15.5, y - 15.5).length() / 16.0
			img.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - d, 0, 1) ** 1.6))
	_dot = ImageTexture.create_from_image(img)
	return _dot

func life(dt: float) -> void:
	for f in falter:
		var n: Node3D = f["n"]
		if not n.visible: continue
		var t: float = t_all * float(f["sp"]) + float(f["ph"])
		var r: float = f["r"]
		var c: Vector3 = f["c"]
		var p := c + Vector3(sin(t * 0.7) * r, 0.45 + 0.25 * sin(t * 2.3) + 0.1 * sin(t * 5.1), sin(t * 1.4) * r * 0.5)
		var v := p - n.position
		n.position = p
		if v.length() > 1e-4: n.rotation.y = atan2(v.x, v.z)
		var flap := sin(t_all * 26.0 + float(f["ph"])) * 1.1
		for w in f["w"]: (w[0] as Node3D).rotation.z = flap * float(w[1])
	if halm_mat:
		halm_mat.set_shader_parameter("cut_on", 0.0)

# ---------------------------------------------------------------- Kamera
func setup_cam() -> void:
	cam = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	cam.size = zoom
	cam.near = 0.5
	cam.far = 120.0
	cam.rotation_degrees = Vector3(-30, yaw, 0)
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
	yaw = lerpf(yaw, yaw_goal, minf(1.0, k * 1.6))
	cam.rotation_degrees = Vector3(-30, yaw, 0)
	var target := held.position + Vector3(0, 0.9 if near else 0.0, 0)
	var want := target + cam.global_basis.z * 40.0
	cam.position = cam.position.lerp(want, k)
	cam.size = lerpf(cam.size, zoom, k)
	for dm in dorf_mats:
		(dm as ShaderMaterial).set_shader_parameter("cut_on", 1.0 if near else 0.0)
		(dm as ShaderMaterial).set_shader_parameter("cut_pos", held.position)

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
	for spec in [["Tag / Nacht", "_on_night"], ["Nah / Fern", "_on_near"], ["Drehen \u25C0", "_on_left"], ["Drehen \u25B6", "_on_right"]]:
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

func _on_left() -> void: yaw_goal -= 45.0
func _on_right() -> void: yaw_goal += 45.0
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
		if t.pressed: touches[t.index] = t.position
		else: touches.erase(t.index)
		if touches.size() >= 2:
			two_start()
			touch_down = false; dragging = false; joy_vec = Vector2.ZERO
		elif t.index == 0:
			if t.pressed:
				touch_down = true; dragging = false; joy_from = t.position; joy_vec = Vector2.ZERO
			else:
				if touch_down and not dragging: tap(t.position)
				touch_down = false; dragging = false; joy_vec = Vector2.ZERO
		joy_draw.queue_redraw()
	elif e is InputEventScreenDrag:
		var dg := e as InputEventScreenDrag
		touches[dg.index] = dg.position
		if touches.size() >= 2:
			var ks := touches.keys()
			var a: Vector2 = touches[ks[0]]; var b: Vector2 = touches[ks[1]]
			var d := a.distance_to(b); var an := (b - a).angle()
			if pinch_d > 1.0:
				yaw_goal += rad_to_deg(angle_difference(pinch_a, an))
				zoom = clampf(zoom * pinch_d / maxf(d, 1.0), NAH * 0.8, FERN * 1.6)
				near = zoom < (NAH + FERN) * 0.5
			pinch_d = d; pinch_a = an
			return
		if touch_down and dg.index == 0:
			var d := dg.position - joy_from
			if d.length() > 28: dragging = true; path.clear()
			joy_vec = d / 110.0
			if joy_vec.length() > 1.0: joy_vec = joy_vec.normalized()
			joy_draw.queue_redraw()

func two_start() -> void:
	var ks := touches.keys()
	var a: Vector2 = touches[ks[0]]; var b: Vector2 = touches[ks[1]]
	pinch_d = a.distance_to(b); pinch_a = (b - a).angle()

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
	if flame: flame.scale = Vector3(1.0, 1.0 + 0.18 * sin(t_all * 13.0) * sin(t_all * 5.1), 1.0)
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
		var hy := atan2(dir.x, dir.z)
		held.rotation.y = lerp_angle(held.rotation.y, hy, minf(1.0, dt * 12.0))
	if anim:
		var want := "Gehen" if moving else "Stehen"
		if anim.current_animation != want: anim.play(want, 0.18)
		anim.speed_scale = (TEMPO / 1.08) * clampf(dir.length(), 0.5, 1.0) if moving else 1.0
	follow(minf(1.0, dt * 5.0))
	life(dt)
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
		RenderingServer.get_video_adapter_name(), RenderingServer.get_current_rendering_method()]
