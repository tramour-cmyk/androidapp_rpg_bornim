class_name Kamera
extends Camera3D
# 348.6: schraeger Blick von oben (30 Grad), rechtwinklig wie das alte Spiel; drehen in 45-Grad-Schritten oder mit zwei
# Fingern, Fern (Gebietskarte, etwa sechs Kacheln quer) und Nah (Gesicht, Haende); Tusche als Bildschirmflaeche davor.

const FERN := 9.0                      # Bildbreite in Metern
const NAH := 3.4
const NORD := 45.0                     # Grundansicht wie alt, Blick nach Nordwesten (Chefrunde 25.10., 13:26, 3486 a: Tueren und Fronten zum Betrachter); Windrose: Tippen dreht dorthin zurueck

var ziel: Node3D
var gieren := NORD
var gieren_ziel := NORD
var zoom := FERN
var nah := false
var tusche: MeshInstance3D
var tusche_mats: Array[ShaderMaterial] = []   # 348.13: bekommen die Sonnenrichtung (Tusche nach der Lichtrichtung)

func _ready() -> void:
	name = "Kamera"
	projection = PROJECTION_ORTHOGONAL
	keep_aspect = KEEP_WIDTH
	size = zoom
	near = 0.5
	far = 120.0
	# Tusche: Bildschirmflaechen davor, Welt (Schablone 0) und Held (Schablone 2, feiner; Probe Build 12)
	var tu: Shader = load("res://shader/tusche.gdshader")
	var tu_held := Shader.new()
	tu_held.code = tu.code.replace("stencil_mode read, compare_equal, 0;", "stencil_mode read, compare_equal, 2;")
	# 348.13: Schattenseite kraeftiger als bisher (1,25), Lichtseite duenn (duenn im Shader); --tuschealt: wie vorher, nur nach Helligkeit
	var alt := "--tuschealt" in OS.get_cmdline_user_args()
	tusche = tusche_flaeche(tu, 1.3, 1.25 if alt else 1.7)
	tusche_flaeche(tu_held, 0.8, 1.0 if alt else 1.5)
	for m in tusche_mats: m.set_shader_parameter("richtung", 0.0 if alt else 1.0)
	if "--umrissblass" in OS.get_cmdline_user_args():   # 348.13: Vergleich mit Lauf 100
		for m in tusche_mats: m.set_shader_parameter("umriss_licht", 0.0)
	if "--zoomdick0" in OS.get_cmdline_user_args():   # 348.13: Verdoppelung im Schatten bei jedem Zoom wie 832ad3959
		for m in tusche_mats: m.set_shader_parameter("zoomdick", 0.0)
	if "--tuscheaussen" in OS.get_cmdline_user_args():   # 348.13: Umriss beidseits der Kante wie d08456e7d
		for m in tusche_mats: m.set_shader_parameter("innen", 0.0)

func _process(_d: float) -> void:
	for m in tusche_mats:
		m.set_shader_parameter("licht_dir", Licht.richtung())
		m.set_shader_parameter("breite_m", size)

func tusche_flaeche(sh: Shader, breite: float, dick: float) -> MeshInstance3D:
	var q := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(2, 2)
	q.mesh = qm
	q.extra_cull_margin = 16384.0
	q.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := ShaderMaterial.new()
	m.shader = sh
	m.render_priority = 127   # zuletzt, auch nach der Flamme (held.gd, 100), die sich mit Schablone 1 ausnimmt
	m.set_shader_parameter("px", breite)
	m.set_shader_parameter("dick", dick)
	tusche_mats.append(m)
	q.material_override = m
	q.position = Vector3(0, 0, -1)
	add_child(q)
	if "--ohnetusche" in OS.get_cmdline_user_args(): q.visible = false
	return q

func drehe(grad: float) -> void: gieren_ziel += grad

# auf die naechste Standardansicht, ohne ganze Umdrehungen nachzuholen
func nach_norden() -> void: gieren_ziel = NORD + roundf((gieren_ziel - NORD) / 360.0) * 360.0

# Norden (Karte oben, -z) auf dem Bildschirm, im Uhrzeigersinn von oben; flach wie eine Kartenrose, bei Gieren 0 oben
func nord_winkel() -> float: return deg_to_rad(gieren)

func nah_fern() -> void:
	nah = not nah
	zoom = NAH if nah else FERN

func kneifen(faktor: float) -> void:
	zoom = clampf(zoom * faktor, NAH * 0.8, FERN * 1.6)
	nah = zoom < (NAH + FERN) * 0.5

func folge(k: float) -> void:
	if ziel == null: return
	gieren = lerpf(gieren, gieren_ziel, minf(1.0, k * 1.6))
	rotation_degrees = Vector3(-30, gieren, 0)
	var auf := ziel.position + Vector3(0, 0.9 if nah else 0.0, 0)
	position = position.lerp(auf + global_basis.z * 40.0, k)
	size = lerpf(size, zoom, k)

func springe() -> void:
	gieren = gieren_ziel
	folge(1.0)

# Punkt am Boden unter einem Bildschirmpunkt
func boden(sp: Vector2) -> Variant:
	var o := project_ray_origin(sp)
	var n := project_ray_normal(sp)
	if absf(n.y) < 1e-4: return null
	return o + n * (-o.y / n.y)

# Joystick (Bildschirm) -> Richtung am Boden
func richtung(v: Vector2) -> Vector3:
	var r := global_basis.x; r.y = 0
	var f := -global_basis.z; f.y = 0
	var d := r.normalized() * v.x - f.normalized() * v.y
	return d.normalized() * minf(1.0, d.length()) if d.length() > 0.0 else d
