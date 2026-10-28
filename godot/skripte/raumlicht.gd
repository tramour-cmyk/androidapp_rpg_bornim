class_name Raumlicht
extends Node3D
# 399.5 (Chef 28.10., 21:5x: „Innenräume … mit den Lichtquellen …, wie es vorher war. Und auch so schön mit Licht und Schatten“):
# Licht im Grundriss wie alt MapLight.sources, aus raum.py (<id>-info.json „lichter“, „waende“):
# - Kamin und Kerzen brennen Tag und Nacht und flackern (Flammen wie die Fackel, flamme.gdshader); der Kamin wirft Schatten;
# - Tageslicht faellt durch Fenster und Tuer (Licht von draussen mit Schatten, das Fensterkreuz auf dem Boden), nachts schwach Mond;
#   die Scheiben innen tags hell, nachts dunkelblau;
# - Waende: hinter dem Raum hoch, vor ihm nur die Bruestung (alt 5h.1), nach der Blickrichtung der Kamera, auch gedreht.

var gebiet: Node3D
var feuer: Array = []        # [OmniLight3D, Grundkraft, Saat]
var flammen: Array = []      # [Node3D Kern, Saat]
var fenster: Array = []      # [SpotLight3D, Kraft, Tuer?]
var scheiben: Array[ShaderMaterial] = []
var an_wand := {}            # hohe Fassung (Name) -> [Licht, Flammenkerne], gehen mit der Wand (Simskerze)
var waende: Array = []       # [hoch, tief, glas, innen (Godot, waagrecht), was mit der hohen Fassung geht]
var zeit := 0.0
var nacht_k := 0.0
static var flamme_shader: Shader

static func baue(g: Node3D, info: Dictionary, netz: Node3D) -> Raumlicht:
	var r := Raumlicht.new()
	r.name = "Raumlicht"
	r.gebiet = g
	for l in info.get("lichter", []): r.licht(l)
	for w in info.get("waende", []):
		var h := netz.find_child(String(w["hoch"]), true, false) as Node3D
		var t := netz.find_child(String(w["tief"]), true, false) as Node3D
		var s := netz.find_child(String(w["glas"]), true, false) as Node3D
		var n := Vector3(float(w["innen"][0]), 0, float(w["innen"][1]))
		var mit: Array = []   # geht mit der hohen Fassung: Kleinkram der Wand, Feuerloch des Kamins
		for k in ["klein", "herd"]:
			var x := netz.find_child(String(w.get(k, "-")), true, false) if w.has(k) else null
			if x: mit.append(x)
		r.waende.append([h, t, s, n, mit])
		if s: r.sammle_scheiben(s)
	r.ohne_schatten(netz)
	return r

# Kleinkram (raum.py Klein_…: Krug, Kerze, Buch) wirft keinen Schatten: Kamin und Fenster zeichnen den Raum sonst je Licht noch einmal
func ohne_schatten(n: Node) -> void:
	if n is MeshInstance3D and String(n.name).begins_with("Klein_"):
		(n as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in n.get_children(): ohne_schatten(c)

static func gpos(p: Array) -> Vector3:
	return Vector3(float(p[0]), float(p[2]), -float(p[1]))

func licht(l: Dictionary) -> void:
	var art := String(l["art"])
	var ts := Karte.TS
	if art == "kamin" or art == "kerze":
		var o := OmniLight3D.new()
		o.position = gpos(l["pos"])
		# Kerze: kraeftiger, Licht tief ueber dem Tisch, damit der Boden darum hell wird (Pruefer Lauf 2, 3: keine Inseln am Boden)
		o.omni_range = float(l.get("reich", 2.0)) * ts
		var k := float(l.get("kraft", 0.6))
		var kraft := k * (3.2 if art == "kamin" else 4.0)
		o.light_energy = kraft
		o.light_color = Color(1.0, 0.56, 0.26) if art == "kamin" else Color(1.0, 0.72, 0.42)
		# Kerzen: Lichtinsel um den Tisch (Pruefer Lauf 1: keine Inseln), steiler abfallend als der Kamin
		o.omni_attenuation = 1.2 if art == "kamin" else 1.0   # Lauf 3: bei 1,9 und kurzer Reichweite kam kein Licht am Boden an
		o.shadow_enabled = art == "kamin"
		o.shadow_bias = 0.06
		add_child(o)
		feuer.append([o, kraft, randf() * 10.0])
		o.add_to_group("tuschelicht")   # 348.13b: Tusche nach dem Licht
		o.set_meta("reich", o.omni_range); o.set_meta("kraft", k)
		var teile: Array = [o]
		for f in l.get("flammen", []):
			teile.append(flamme(gpos(f), 2.0 if art == "kamin" else 0.32, art == "kamin"))
		if l.has("wand"): an_wand[String(l["wand"])] = an_wand.get(String(l["wand"]), []) + teile
	elif art == "tageslicht" or art == "tuer":
		var s := SpotLight3D.new()
		var von := gpos(l["pos"]); var zu := gpos(l["ziel"])
		add_child(s)
		s.look_at_from_position(von, zu, Vector3.UP)
		s.spot_range = von.distance_to(zu) * 1.8
		s.spot_angle = 30.0 if art == "tageslicht" else 26.0
		s.spot_attenuation = 0.6
		s.shadow_enabled = true
		s.shadow_bias = 0.05
		fenster.append([s, float(l.get("kraft", 0.55)), art == "tuer"])

func flamme(p: Vector3, gross: float, kamin: bool) -> Node3D:
	if flamme_shader == null: flamme_shader = load("res://shader/flamme.gdshader")
	var kern := Node3D.new()
	kern.position = p + Vector3(0, 0.1 * gross, 0)   # Fuss der Flamme auf Docht oder Scheit
	kern.scale = Vector3.ONE * gross
	add_child(kern)
	# wie held.gd Fackel (Runde 5b): Kern, Mantel, Zungen mit eigenem Takt; beim Kamin mehr Zungen nebeneinander
	var form := [[0.055, 0.24, 0.0, 0.0], [0.03, 0.14, 0.0, -0.04], [0.022, 0.15, 0.022, 0.05], [0.02, 0.13, -0.024, 0.04], [0.016, 0.11, 0.0, 0.07]]
	if kamin: form += [[0.04, 0.2, -0.05, -0.01], [0.04, 0.19, 0.05, -0.01], [0.025, 0.13, -0.08, -0.03], [0.025, 0.12, 0.08, -0.03]]
	for k in form.size() + 1:
		var mi := MeshInstance3D.new()
		var m := ShaderMaterial.new()
		m.shader = flamme_shader
		m.render_priority = 100
		if k < form.size():
			var fm := SphereMesh.new()
			fm.radius = form[k][0]; fm.height = form[k][1]
			fm.radial_segments = 10; fm.rings = 8
			mi.mesh = fm
			m.set_shader_parameter("hoehe", fm.height)
			m.set_shader_parameter("saat", 2.3 * k + p.x * 7.0)
			if k == 1: m.set_shader_parameter("aussen", Color(1.0, 0.7, 0.25))
			m.set_shader_parameter("kraft", 0.75 if k < 2 else 0.6)
			mi.position = Vector3(form[k][2], form[k][3], 0.01 * (k - 3) if k >= 2 else 0.0)
		else:
			var qm := QuadMesh.new()
			qm.size = Vector2(0.7, 0.7)
			mi.mesh = qm
			m.set_shader_parameter("glanz", 1.0)
			m.set_shader_parameter("kraft", 0.5 if kamin else 0.55)
			mi.position = Vector3(0, 0.08, 0)
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		kern.add_child(mi)
	flammen.append([kern, p.x * 3.0 + p.z])
	return kern

func sammle_scheiben(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var m := mi.get_surface_override_material(i) as ShaderMaterial
			if m: scheiben.append(m)
	for c in n.get_children(): sammle_scheiben(c)

func nacht(k: float) -> void:
	nacht_k = k
	for f in fenster:
		var s: SpotLight3D = f[0]
		var tag := 1.0 - k
		# MapLight WINDOW/DOOR: Tageslicht nur am Tag (grau-weiss); nachts Mond kuehl und schwach (MOON_RGB, 0,5)
		s.light_energy = f[1] * (5.0 * tag + 2.0 * k)
		s.light_color = Color(0.92, 0.95, 1.0).lerp(Color(0.64, 0.71, 0.9), k)
		s.visible = s.light_energy > 0.02
	for m in scheiben:
		m.set_shader_parameter("glow", 0.85 * (1.0 - k) + 0.3 * k)
		m.set_shader_parameter("glow_col", Color(0.86, 0.9, 0.96).lerp(Color(0.2, 0.26, 0.45), k))

func _process(dt: float) -> void:
	zeit += dt
	for f in feuer:
		var o: OmniLight3D = f[0]
		var t: float = zeit + f[2]
		o.light_energy = f[1] * (0.86 + 0.09 * sin(t * 13.0) * sin(t * 5.3) + 0.05 * sin(t * 29.0))
	for f in flammen:
		var kern: Node3D = f[0]
		var innen := kern.get_child(1) as Node3D
		innen.scale = Vector3.ONE * (0.85 + 0.2 * sin(zeit * 17.0 + f[1]))
	var kam := get_viewport().get_camera_3d()
	if kam == null: return
	var blick := -kam.global_basis.z
	blick.y = 0.0
	if blick.length() < 0.01: return
	blick = blick.normalized()
	for w in waende:
		# Innenseite zur Kamera (die Wand steht hinter dem Raum): hoch; die Wand vor dem Raum (wir blicken auf ihre Aussenseite): tief
		var hoch: bool = (w[3] as Vector3).dot(blick) < 0.3
		if w[0]: (w[0] as Node3D).visible = hoch
		if w[1]: (w[1] as Node3D).visible = not hoch
		if w[2]: (w[2] as Node3D).visible = hoch
		for x in w[4]: (x as Node3D).visible = hoch   # Kleinkram der Wand, Feuerloch
		if w[0]:
			for t in an_wand.get(String((w[0] as Node3D).name), []): (t as Node3D).visible = hoch
