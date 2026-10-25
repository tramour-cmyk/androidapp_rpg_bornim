class_name Licht
extends Node3D
# 348.6: Sonne mit Schatten, Umgebung, Tag und Nacht (wie Probe Build 11); nachts tragen Laternen, Fenster und Fackel.

signal nacht_geaendert(k: float)

var sonne: DirectionalLight3D
var env: Environment
var nacht := 0.0
var ziel := 0.0

func _ready() -> void:
	name = "Licht"
	sonne = DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-50, 25, 0)
	sonne.shadow_enabled = true
	sonne.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sonne.directional_shadow_max_distance = 20.0
	sonne.shadow_blur = 1.5
	sonne.shadow_normal_bias = 1.2
	add_child(sonne)
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
	stelle(0.0)

func umschalten() -> void:
	ziel = 0.0 if ziel > 0.5 else 1.0

func stelle(k: float) -> void:
	nacht = k
	sonne.light_energy = lerpf(1.3, 0.15, k)   # Mond; alt nachts etwa 0,43 der Tageshelle (Helfer 25.10.: neu war nur 0,65)
	sonne.light_color = Color(1.0, 0.94, 0.82).lerp(Color(0.7, 0.76, 0.95), k)
	env.ambient_light_color = Color(0.62, 0.66, 0.75).lerp(Color(0.26, 0.34, 0.55), k)
	env.ambient_light_energy = lerpf(0.55, 0.6, k)
	env.adjustment_saturation = lerpf(0.8, 0.45, k)   # nachts blasser und blau wie alt
	env.background_color = Color(0.36, 0.42, 0.34).lerp(Color(0.03, 0.04, 0.08), k)
	nacht_geaendert.emit(k)

func _process(dt: float) -> void:
	if nacht != ziel: stelle(move_toward(nacht, ziel, dt / 1.5))
