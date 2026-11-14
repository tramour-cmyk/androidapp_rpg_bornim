class_name Fackel
extends Node3D
# 1140 (Chef 13.11., 14:26, Höhle: „eine Fackel ausgerüstet, die sah ich aber nicht an meinem Avatar … im Spiel in der Hand, aber
# nicht im Rahmen der Ausrüstung“): eine Fackel für Welt, Ausrüstung und Kampfort (999.1), bisher nur in held.gd gebaut. Stiel,
# Pechkopf, Flamme (flamme.gdshader) und Licht wie held.gd Runde 5 bis 5c; richte() hält den Stiel in der linken Faust halb
# aufgerichtet und die Flamme aufrecht. Alt: HeroFigure.kt torch (die Fackel am Helden auch im Menü).
# Welt: held.gd baut sie mit an() und ruft richte() nach jedem Schritt (Tempo, Zeit vom Helden). Menü und Kampfort: selbst = true,
# die Fackel richtet sich jedes Bild selbst und flackert im eigenen Takt.

const VOR := 0.25   # Licht 25 cm vor der Flamme in Blickrichtung (held.gd FACKEL_VOR)

var flamme: MeshInstance3D
var licht: OmniLight3D
var koerper: Node3D          # wessen Blickrichtung die Fackel folgt (der Held oder seine Figur)
var knochen := ""
var griff := Vector3.ZERO    # Knochenraum der Faust (HeldFigur.faust, held-info.json faust_L)
var achse := Vector3.ZERO
var tempo := 0.0             # m/s: die Flamme weht beim Laufen nach hinten
var zeit := 0.0
var selbst := false          # Menü, Kampfort: eigener Takt in _process
var kraft := 1.0             # Lichtstärke ohne Flackern (Welt: held.gd fackel_kraft)

## baut die Fackel an die Faust [kn] von [sk]: BoneAttachment3D mit Knoten „Fackel“ darunter; gibt die Fackel zurück
static func an(sk: Skeleton3D, kn: String, gr: Vector3, ac: Vector3, wer: Node3D) -> Fackel:
	var ba := BoneAttachment3D.new()
	ba.bone_name = kn
	sk.add_child(ba)
	var f := Fackel.new()
	f.name = "Fackel"
	f.knochen = kn; f.griff = gr; f.achse = ac; f.koerper = wer
	ba.add_child(f)
	var t: Node3D = f
	var stiel := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.022; cm.bottom_radius = 0.016; cm.height = 0.42
	stiel.mesh = cm
	var wm := StandardMaterial3D.new()
	wm.albedo_color = Color(0.42, 0.28, 0.16)
	stiel.material_override = wm
	stiel.position = Vector3(0, 0.06, 0)
	stiel.layers = 2                                   # die eigene Flamme beleuchtet den Stiel nicht (sonst gluehte er, Licht vor der Flamme)
	t.add_child(stiel)
	# Runde 5b (Helfer: schwarzer Stummel im Flammenfuss, die Flamme deckt nicht): Pechkopf glimmt am Stielende
	var glut := MeshInstance3D.new()
	var gm := SphereMesh.new()
	gm.radius = 0.03; gm.height = 0.05
	glut.mesh = gm
	var glm := StandardMaterial3D.new()
	glm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glm.albedo_color = Color(0.85, 0.32, 0.08)
	glut.material_override = glm
	glut.position = Vector3(0, 0.27, 0)
	glut.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	t.add_child(glut)
	# Helfer: Flamme „wie Papier“ (ein blassgelber Kegel, flackert kaum): aussen orange, innen hell, beide flackern verschieden
	# Runde 5 (Helfer Runde 3: noch mattes Dreieck mit schwarzer Kontur): additiv leuchtend ohne Tusche (flamme.gdshader), mit Schein
	f.flamme = MeshInstance3D.new()
	f.flamme.position = Vector3(0, 0.36, 0)
	t.add_child(f.flamme)
	var fl: Shader = load("res://shader/flamme.gdshader")
	# Runde 5b (Helfer: glattes Dreieck „wie ein Papierwimpel“): Kern, Mantel und drei Zungen mit eigenem Takt; ueber dem Gras
	# (Gras ist durchsichtig und wurde davor gezeichnet), unter der Tusche
	var form := [[0.055, 0.24, 0.0, 0.0], [0.03, 0.14, 0.0, -0.04], [0.022, 0.15, 0.022, 0.05], [0.02, 0.13, -0.024, 0.04], [0.016, 0.11, 0.0, 0.07]]
	for k in 6:
		var kegel := MeshInstance3D.new()
		var m := ShaderMaterial.new()
		m.shader = fl
		m.render_priority = 100
		if k < 5:
			# Runde 5c (Helfer: „Eistuete“, harte Unterkante, breiteste Stelle unten): Tropfen aus einer Kugel, unten rund, oben spitz
			var fm := SphereMesh.new()
			fm.radius = form[k][0]; fm.height = form[k][1]
			fm.radial_segments = 14; fm.rings = 10
			kegel.mesh = fm
			m.set_shader_parameter("hoehe", fm.height)
			m.set_shader_parameter("saat", 2.3 * k)
			if k == 1: m.set_shader_parameter("aussen", Color(1.0, 0.7, 0.25))
			m.set_shader_parameter("kraft", 0.75 if k < 2 else 0.6)   # Runde 5b (Helfer: fast weiss, ueberbelichtet)
			kegel.position = Vector3(form[k][2], form[k][3], 0.01 * (k - 3) if k >= 2 else 0.0)
		else:
			var qm := QuadMesh.new()
			qm.size = Vector2(0.7, 0.7)
			kegel.mesh = qm
			m.set_shader_parameter("glanz", 1.0)
			kegel.position = Vector3(0, -0.02, 0)
		kegel.material_override = m
		kegel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		f.flamme.add_child(kegel)
	f.licht = OmniLight3D.new()
	f.licht.position = Vector3(0, 0.45, 0)
	f.licht.light_color = Color(1.0, 0.72, 0.38)
	f.licht.omni_range = 8.0
	f.licht.omni_attenuation = 2.0
	f.licht.light_cull_mask = 0xFFFFF & ~2
	t.add_child(f.licht)
	f.licht.set_meta("reich", 4.0)   # 348.13b: Tusche nach der Fackel (am Tag unsichtbar, zaehlt dann nicht)
	f.licht.set_meta("kraft", 1.0)
	f.licht.add_to_group("tuschelicht")
	return f

## Stiel quer durch die Faust, zu zwei Dritteln aufgerichtet; Flamme aufrecht, weht mit dem Tempo; Licht vor der Flamme
func richte() -> void:
	var ba := get_parent() as BoneAttachment3D
	if ba == null or koerper == null: return
	var sk := ba.get_parent() as Skeleton3D
	if sk == null: return
	var bi := sk.find_bone(ba.bone_name)
	if bi < 0: return
	var pose := sk.global_transform * sk.get_bone_global_pose(bi)
	var ac := (pose.basis * achse).normalized()
	if ac.y < 0.0: ac = -ac
	var y := ac.lerp(Vector3.UP, 0.65).normalized()
	var gb := koerper.global_basis
	var x := (gb.x - y * gb.x.dot(y)).normalized()
	global_basis = Basis(x, y, x.cross(y))
	global_position = pose * griff
	var blick := gb.z.normalized()
	var b := Basis(Vector3.UP, atan2(blick.x, blick.z))
	b = b.rotated(gb.x.normalized(), -minf(0.6, tempo * 0.12) + 0.1 * sin(zeit * 6.1))
	b = b.rotated(gb.z.normalized(), 0.1 * sin(zeit * 8.3))
	licht.global_position = flamme.global_position + blick * VOR
	flamme.global_basis = b * Basis.from_scale(Vector3(1.0 + 0.12 * sin(zeit * 9.3), 1.0 + 0.3 * sin(zeit * 13.0) * sin(zeit * 5.1), 1.0 + 0.12 * sin(zeit * 7.7)))

## Flackern von Licht und Kern (held.gd _process)
func flackern() -> void:
	licht.light_energy = kraft * (0.88 + 0.12 * sin(zeit * 17.0) * sin(zeit * 7.3))
	(flamme.get_child(1) as Node3D).scale = Vector3.ONE * (0.85 + 0.2 * sin(zeit * 17.0 + 1.3))

func _process(dt: float) -> void:
	if not selbst: return
	zeit += dt
	flackern()
	richte()
