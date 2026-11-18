class_name Staffel
extends RefCounted
# 458.3 Waffenstaffel (Chef 01.11., 19:5x: „Staffel nach Stufe, Seltenheit über Material und Zeichen“; 02.11., 11:28: Modelle und
# Staffel passen): je Waffenart 2-4 Formen aus den Kaufpaketen, gebaut von tools/blender348/waffen_staffel.py (SPIEL=1) nach
# daten/waffen/<art>_<form>.bin, Griff im Ursprung wie waffen.py. Welche Form ab welcher Stufe gilt, steht in daten/waffen/staffel.json
# (aus der Spalte formen des Katalogs); die Stufe ist die des Gegenstands (ilvl). Seltenheit: dasselbe Netz, je Klasse des Materials
# (metall, beschlag, holz, leder, akzent; Material „<klasse>.<n>“) eine toenung aus staffel.json; das Bild trägt nur die Zeichnung.
# Schlüssel eines Gegenstands: „<datei>#<SELTENHEIT>“ für eine Staffelform, sonst die Grundform (waffen.py, Vertexfarben) wie bisher.

const DATEI := "res://daten/waffen/staffel.json"
const WAFFE := "res://daten/waffen/%s.bin"

static var _d = null
static var _art := {}   # Datei der Form -> Waffenart

static func daten() -> Dictionary:
	if _d == null:
		_d = {}
		if FileAccess.file_exists(DATEI):
			var j = JSON.parse_string(FileAccess.get_file_as_string(DATEI))
			if j is Dictionary: _d = j
		for a in (_d.get("waffen", {}) as Dictionary):
			for f in _d["waffen"][a]: _art[String(f["datei"])] = String(a)
	return _d

## Schlüssel des Modells für einen Gegenstand ({base, ilvl, rarity}); leer, wenn es keins gibt
static func schluessel(g) -> String:
	if not g is Dictionary: return ""
	var b := String(g.get("base", ""))
	var formen: Array = daten().get("waffen", {}).get(b, [])
	var stufe := int(g.get("ilvl", 1))
	var wahl := ""
	for f in formen:
		if int(f["ab"]) <= stufe and FileAccess.file_exists(WAFFE % String(f["datei"])): wahl = String(f["datei"])
	if wahl == "" and not formen.is_empty() and FileAccess.file_exists(WAFFE % String(formen[0]["datei"])): wahl = String(formen[0]["datei"])
	if wahl != "": return wahl + "#" + String(g.get("rarity", "COMMON"))
	return b if FileAccess.file_exists(WAFFE % b) else ""

## Datei ohne Seltenheit
static func datei(schl: String) -> String: return schl.get_slice("#", 0)

## Waffenart (Grundform) eines Schlüssels: für Regeln, Gang, Katalog
static func art(schl: String) -> String:
	daten()
	var d := datei(schl)
	return String(_art.get(d, d))

static func seltenheit(schl: String) -> String: return schl.get_slice("#", 1) if schl.contains("#") else ""

## Modell laden (wie Gebiet.lade_glb); Staffelformen tragen die Seltenheit als Marke, Gebiet.male färbt danach (faerbe)
static func lade(schl: String) -> Node3D:
	var d := Gebiet.lade_glb(WAFFE % datei(schl))
	if d != null and seltenheit(schl) != "": d.set_meta("staffel", seltenheit(schl))
	return d

## toenung je Klasse nach der Seltenheit (linear, staffel.json); nach Gebiet.male, das die Shader-Materialien anlegt
static func faerbe(n: Node) -> void:
	var t: Dictionary = daten().get("toenung", {}).get(String(n.get_meta("staffel", "COMMON")), {})
	if t.is_empty(): return
	for mi in n.find_children("*", "MeshInstance3D", true, false) + ([n] if n is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		if me == null: continue
		for i in me.get_surface_count():
			var src := me.surface_get_material(i)
			var kl := String(src.resource_name).get_slice(".", 0) if src else ""
			var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
			if sm and t.has(kl):
				var c: Array = t[kl]
				sm.set_shader_parameter("toenung", Vector3(float(c[0]), float(c[1]), float(c[2])))
	glanz(n, String(n.get_meta("staffel", "COMMON")))

# ---------------------------------------------------------------- 1613 Effekt statt Färbung für episch und höher
# Chef 02.11., 11:28: „dieses Glimmern … sieht man eigentlich nicht … als ob die Waffe einfach orange gefärbt wäre … cool, wenn man da
# irgendwie noch eine Art Effekt draufkriegen“. Zwei Bausteine zusammen (Fassung C, Vorentscheid Sokrates 18.11., 03:08,
# billigen/1613-glanz.md: Schein allein liest sich wie Färbung, erst die Funken sind ein Effekt; der Schein macht die Klinge sichtbar):
#   schein: zweiter Durchgang (shader/glanz.gdshader), Rand und ein Streifen vom Griff zur Spitze, atmet
#   glut:   Funken steigen von der Waffe auf (GPUParticles3D, Shader vfx_add aus R7 Stylized VFX v2.0, im Bau unter addons/reeboo_vfx;
#           fehlt das Paket, ein eigener weicher Punkt), bleiben beim Gehen zurück (Weltkoordinaten)
const GLANZ_FARBE := {"EPIC": Color("f29e50"), "DIVINE": Color("eac650")}   # wie menue.gd SELTEN
const VFX_ADD := "res://addons/reeboo_vfx/shaders/vfx_add.gdshader"
static var _glanz_mat := {}        # Seltenheit -> ShaderMaterial (Schein), geteilt
static var _punkt: Shader

static func glanz(n: Node, sel: String) -> void:
	if not GLANZ_FARBE.has(sel): return
	var f: Color = GLANZ_FARBE[sel]
	var netze: Array = n.find_children("*", "MeshInstance3D", true, false) + ([n] if n is MeshInstance3D else [])
	var box := AABB()
	var erst := true
	for mi in netze:
		var me := (mi as MeshInstance3D).mesh
		if me == null: continue
		var b: AABB = (n as Node3D).global_transform.affine_inverse() * (mi as MeshInstance3D).global_transform * me.get_aabb() if n.is_inside_tree() else me.get_aabb()
		box = b if erst else box.merge(b)
		erst = false
		for i in me.get_surface_count():
			var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
			if sm and sm.next_pass == null: sm.next_pass = _schein(sel, f, me.get_aabb())
	if erst: return
	var p := GPUParticles3D.new()
	p.name = "Glanz_Glut"
	p.amount = 24 if sel == "EPIC" else 32
	p.lifetime = 1.3
	p.local_coords = false
	p.position = box.get_center()
	p.visibility_aabb = AABB(-box.size * 0.5 - Vector3.ONE, box.size + Vector3.ONE * 2.0)
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = box.size * 0.45
	pm.direction = Vector3.UP
	pm.spread = 25.0
	pm.initial_velocity_min = 0.04
	pm.initial_velocity_max = 0.14
	pm.gravity = Vector3(0, 0.25, 0)
	pm.scale_min = 0.6
	pm.scale_max = 1.0
	var gr := Gradient.new()
	gr.set_color(0, Color(f.lightened(0.35), 0.0))
	gr.set_color(1, Color(f, 0.0))
	gr.add_point(0.2, Color(f.lightened(0.25), 0.9))
	gr.add_point(0.7, Color(f, 0.5))
	var gt := GradientTexture1D.new()
	gt.gradient = gr
	pm.color_ramp = gt
	p.process_material = pm
	var q := QuadMesh.new()
	q.size = Vector2(0.06, 0.06)
	var m := ShaderMaterial.new()
	if ResourceLoader.exists(VFX_ADD):
		m.shader = load(VFX_ADD)
		m.set_shader_parameter("shape", 1)   # Flare
		m.set_shader_parameter("emission_energy", 4.0)
		m.set_shader_parameter("proximity_fade", 0.0)
	else:
		if _punkt == null:
			_punkt = Shader.new()
			_punkt.code = "shader_type spatial;\nrender_mode blend_add, unshaded, cull_disabled, depth_draw_never, shadows_disabled;\n" + \
				"void vertex() { MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]); }\n" + \
				"void fragment() { float d = length(UV * 2.0 - 1.0); ALBEDO = COLOR.rgb * 2.0 * COLOR.a * (1.0 - smoothstep(0.0, 1.0, d)); }\n"
		m.shader = _punkt
	q.material = m
	p.draw_pass_1 = q
	n.add_child(p)

static func _schein(sel: String, f: Color, b: AABB) -> ShaderMaterial:
	var l := snappedf(maxf(b.end.length(), b.position.length()), 0.05)
	var k := "%s|%.2f" % [sel, l]
	if not _glanz_mat.has(k):
		var m := ShaderMaterial.new()
		m.shader = load("res://shader/glanz.gdshader")
		m.render_priority = 1
		m.set_shader_parameter("farbe", Vector3(f.r, f.g, f.b))
		m.set_shader_parameter("kraft", 0.9 if sel == "EPIC" else 1.1)
		m.set_shader_parameter("laenge", l)
		_glanz_mat[k] = m
	return _glanz_mat[k]
