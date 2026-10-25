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
# 348.9 (3489 1 a): am Rechner gegen die alten Bilder geeicht (tools/vglmass.py, Messlatte Mittel ±5 %, Streuung bis +25 %)
const TAG_SONNE := 0.455
const TAG_UMGEBUNG := 0.275
const TAG_KONTRAST := 0.87
const TAG_SAETTIGUNG := 0.95
const MOND := 0.07          # Mond flach, sonst schwarze Schatten (alt nachts 28/15, p10 16)
const NACHT_UMGEBUNG := 0.75
const NACHT_KONTRAST := 0.96   # unter 1 hebt das Schwarz an
const TIEF_UMGEBUNG := 1.1     # Morgen, Abend: Fronten im Schatten, Himmel traegt mehr
const DAEMMERUNG_UMGEBUNG := 0.18
const ALT := [[Vector2(-1.0, -0.2), 1.2], [Vector2(0.15, 1.0), 0.35], [Vector2(1.0, -0.2), 1.2]]
const NATUR := [[Vector2(-1.0, -0.3), 1.2], [Vector2(0.35, -1.0), 0.6], [Vector2(1.0, -0.3), 1.2]]
static var bahn := NATUR   # Chef 25.10., 12:25 (3486-sonne): wie in der Natur
static var stand := Stand.MITTAG
static var zur_sonne := Vector3(0, 1, 0)
static var nach_licht: Array[ShaderMaterial] = []   # werten das Licht selbst aus (Tusche nach dem Licht, toon kontur)
# 348.9 (Chefrunde 25.10., 13:26, 3489 1 a): Stimmung wie MapGrade im alten Spiel, ueber dem Bild, unter der Leiste:
# Toenung multipliziert (Tag fast weiss, Daemmerung violett, Nacht blau), Raender dunkler (MapGrade.apply)
const STIMMUNG := """shader_type canvas_item;
render_mode blend_mul, unshaded;
uniform vec3 toenung = vec3(1.0);
uniform float anteil = 0.0;
uniform float rand = 0.0;
void fragment() {
	vec2 d = UV * 2.0 - 1.0;
	float r2 = clamp(dot(d, d) / 2.0, 0.0, 1.0);
	float v = 1.0 - rand * smoothstep(0.0, 1.0, (r2 - 0.25) / 0.75);
	COLOR = vec4((vec3(1.0 - anteil) + anteil * toenung) * v, 1.0);
}
"""
var stimmung: ShaderMaterial

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
	if env: stelle(nacht)

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
	var ebene := CanvasLayer.new()
	ebene.layer = 0   # ueber der Welt, unter der Steuerung (Ebene 1)
	var flaeche := ColorRect.new()
	flaeche.set_anchors_preset(Control.PRESET_FULL_RECT)
	flaeche.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = STIMMUNG
	stimmung = ShaderMaterial.new()
	stimmung.shader = sh
	flaeche.material = stimmung
	ebene.add_child(flaeche)
	add_child(ebene)
	for a in OS.get_cmdline_user_args():
		if a == "--sonne=alt": bahn = ALT
	setze_stand(stand)
	stelle(0.0)

func umschalten() -> void:
	ziel = 0.0 if ziel > 0.5 else 1.0

func stelle(k: float) -> void:
	nacht = k
	var t := clampf((0.5 - k) / 0.28, -1.0, 1.0)
	var daemmerung := (1.0 - t * t) * (1.0 - t * t)   # wie MapGrade: am staerksten bei halbem Tageslicht
	var tief: float = 1.0 if stand == Stand.MITTAG else TIEF_UMGEBUNG   # Morgen, Abend: Fronten im Schatten, Himmel traegt mehr (alt Kirche 56/58)
	# Runde 11 (Chef 25.10., 12:12: neu viel zu hell, zu freundlich): Tag aufs alte Bildmittel geeicht (Markt alt 67, Streuung 21; neu war 87/44)
	sonne.light_energy = lerpf(TAG_SONNE, MOND, k)
	sonne.light_color = Color(1.0, 0.94, 0.82).lerp(Color(0.7, 0.76, 0.95), k).lerp(Color(1.0, 0.7, 0.45), 0.6 * daemmerung)   # Daemmerung warm braun wie alt (R−B +26), nicht rosa (Helfer r13)
	env.ambient_light_color = Color(0.62, 0.66, 0.75).lerp(Color(0.26, 0.34, 0.55), k).lerp(Color(0.58, 0.5, 0.42), 0.6 * daemmerung)
	env.ambient_light_energy = lerpf(TAG_UMGEBUNG * tief, NACHT_UMGEBUNG, k) + DAEMMERUNG_UMGEBUNG * daemmerung
	env.adjustment_contrast = lerpf(TAG_KONTRAST, NACHT_KONTRAST, k)
	env.adjustment_saturation = lerpf(TAG_SAETTIGUNG, 0.45, k) + 0.1 * daemmerung   # nachts blasser und blau wie alt
	env.background_color = Color(0.36, 0.42, 0.34).lerp(Color(0.03, 0.04, 0.08), k)
	toene(1.0 - k)
	nacht_geaendert.emit(k)

# MapGrade.of fuer das Dorf (daylight 1 Tag, 0,5 Daemmerung, 0 Nacht); Wald und Hoehle beim Bau je Ort
func toene(tag: float) -> void:
	var t := clampf((tag - 0.5) / 0.28, -1.0, 1.0)
	var daemmerung := (1.0 - t * t) * (1.0 - t * t)
	var dunkel := clampf((0.35 - tag) / 0.35, 0.0, 1.0)
	var farbe := Color8(0xFF, 0xFC, 0xF4).lerp(Color8(0xE4, 0xCC, 0xF0), daemmerung).lerp(Color8(0xD8, 0xDC, 0xF4), dunkel)
	stimmung.set_shader_parameter("toenung", Vector3(farbe.r, farbe.g, farbe.b))
	stimmung.set_shader_parameter("anteil", minf(0.25 + 0.35 * daemmerung + 0.2 * dunkel, 1.0))
	stimmung.set_shader_parameter("rand", minf(0.18 + 0.1 * daemmerung + 0.14 * dunkel, 1.0))

func _process(dt: float) -> void:
	if nacht != ziel: stelle(move_toward(nacht, ziel, dt / 1.5))
