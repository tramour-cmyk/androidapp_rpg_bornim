class_name Kamera
extends Camera3D
# 348.6: schraeger Blick von oben (30 Grad), rechtwinklig wie das alte Spiel; drehen in 45-Grad-Schritten oder mit zwei
# Fingern, Fern (Gebietskarte, etwa sechs Kacheln quer) und Nah (Gesicht, Haende); Tusche als Bildschirmflaeche davor.

const FERN := 9.0                      # Bildbreite in Metern
const NAH := 3.4
const NORD := 180.0                    # Grundansicht nach Sueden (Chef 25.10., 12:25; vorher 45: nach Nordwesten); Windrose: Tippen dreht dorthin zurueck

var ziel: Node3D
var gieren := NORD
var gieren_ziel := NORD
var zoom := FERN
var nah := false
var tusche: MeshInstance3D

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
	tusche = tusche_flaeche(tu, 1.3, 1.25)
	tusche_flaeche(tu_held, 0.8, 1.0)

func tusche_flaeche(sh: Shader, breite: float, dick: float) -> MeshInstance3D:
	var q := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(2, 2)
	q.mesh = qm
	q.extra_cull_margin = 16384.0
	q.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("px", breite)
	m.set_shader_parameter("dick", dick)
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
