class_name Licht
extends Node3D
# 348.6: Sonne mit Schatten, Umgebung, Tag und Nacht (wie Probe Build 11); nachts tragen Laternen, Fenster und Fackel.

signal nacht_geaendert(k: float)

var sonne: DirectionalLight3D
var env: Environment
var nacht := 0.0
var ziel := 0.0

# 348.6 Runde 11 (Chef 25.10., 12:12: Sonnenstand und Schatten falsch, neu kurz nach rechts statt alt lang nach links unten):
# drei Staende wie MapSun.Stand (Schattenrichtung auf der Karte, x Osten, z Sueden; Laenge je Meter Hoehe), gewechselt nur an
# einem Schnitt (Kartenwechsel). ALT wie das alte Spiel (mittags Sonne im Norden), NATUR mittags von Sued-Suedwest (Chefsache 3486-sonne)
enum Stand { MORGEN, MITTAG, ABEND }
const TAG_SONNE := 0.55
const TAG_UMGEBUNG := 0.33
const TAG_KONTRAST := 0.86
const ALT := [[Vector2(-1.0, -0.2), 1.2], [Vector2(0.15, 1.0), 0.35], [Vector2(1.0, -0.2), 1.2]]
const NATUR := [[Vector2(-1.0, -0.3), 1.2], [Vector2(0.35, -1.0), 0.6], [Vector2(1.0, -0.3), 1.2]]
static var bahn := ALT
static var stand := Stand.MITTAG
static var zur_sonne := Vector3(0, 1, 0)
static var nach_licht: Array[ShaderMaterial] = []   # werten das Licht selbst aus (Tusche nach dem Licht, toon kontur)

# zur Sonne (Welt), fuer Materialien, die das Licht selbst auswerten (Busch-Tusche)
static func richtung() -> Vector3: return zur_sonne

static func stand_um(minute: int) -> Stand:
	var h := posmod(minute, 24 * 60) / 60
	return Stand.MORGEN if h < 10 else (Stand.MITTAG if h < 15 else Stand.ABEND)

func setze_stand(s: Stand) -> void:
	stand = s
	var b: Array = bahn[s]
	var h: Vector2 = (b[0] as Vector2).normalized()
	var e := atan(1.0 / float(b[1]))                     # Hoehe der Sonne aus der Schattenlaenge
	var fall := Vector3(h.x * cos(e), -sin(e), h.y * cos(e))   # Licht faellt in Schattenrichtung und nach unten
	zur_sonne = -fall
	sonne.look_at_from_position(Vector3.ZERO, fall, Vector3.UP if absf(fall.y) < 0.99 else Vector3.FORWARD)
	for m in nach_licht: m.set_shader_parameter("licht_dir", zur_sonne)

func _ready() -> void:
	name = "Licht"
	sonne = DirectionalLight3D.new()
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
	for a in OS.get_cmdline_user_args():
		if a == "--sonne=natur": bahn = NATUR
	setze_stand(stand)
	stelle(0.0)

func umschalten() -> void:
	ziel = 0.0 if ziel > 0.5 else 1.0

func stelle(k: float) -> void:
	nacht = k
	# Runde 11 (Chef 25.10., 12:12: neu viel zu hell, zu freundlich): Tag aufs alte Bildmittel geeicht (Markt alt 67, Streuung 21; neu war 87/44)
	sonne.light_energy = lerpf(TAG_SONNE, 0.26, k)   # Mond; 348.6: Bildmittel nachts wie alt (29), am Rechner gemessen
	sonne.light_color = Color(1.0, 0.94, 0.82).lerp(Color(0.7, 0.76, 0.95), k)
	env.ambient_light_color = Color(0.62, 0.66, 0.75).lerp(Color(0.26, 0.34, 0.55), k)
	env.ambient_light_energy = lerpf(TAG_UMGEBUNG, 0.5, k)
	env.adjustment_contrast = lerpf(TAG_KONTRAST, 1.06, k)
	env.adjustment_saturation = lerpf(0.8, 0.45, k)   # nachts blasser und blau wie alt
	env.background_color = Color(0.36, 0.42, 0.34).lerp(Color(0.03, 0.04, 0.08), k)
	nacht_geaendert.emit(k)

func _process(dt: float) -> void:
	if nacht != ziel: stelle(move_toward(nacht, ziel, dt / 1.5))
