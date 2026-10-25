class_name Kamera
extends Camera3D
# 348.6: schraeger Blick von oben (30 Grad), rechtwinklig wie das alte Spiel; drehen in 45-Grad-Schritten oder mit zwei
# Fingern, Fern (Gebietskarte, etwa sechs Kacheln quer) und Nah (Gesicht, Haende); Tusche als Bildschirmflaeche davor.

const FERN := 9.0                      # Bildbreite in Metern
const NAH := 3.4

var ziel: Node3D
var gieren := 45.0
var gieren_ziel := 45.0
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
	tusche = MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(2, 2)
	tusche.mesh = qm
	tusche.extra_cull_margin = 16384.0
	tusche.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := ShaderMaterial.new()
	m.shader = load("res://shader/tusche.gdshader")
	tusche.material_override = m
	tusche.position = Vector3(0, 0, -1)
	add_child(tusche)
	if "--ohnetusche" in OS.get_cmdline_user_args(): tusche.visible = false

func drehe(grad: float) -> void: gieren_ziel += grad

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
