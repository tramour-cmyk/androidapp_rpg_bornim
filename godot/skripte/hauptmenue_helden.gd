class_name HauptmenueHelden
extends Control
# 867 (Chef 10.11., 13:48: „die 4 Figuren, die ich da sehe, sind ja noch aus Kotlin. Gehört überarbeitet. Da müssen aktuell die
# Helden hin, die wir haben“): die vier Helden des Hauptmenues aus den Figuren des Spiels (HeldFigur.baue wie Erschaffung und Drehteller)
# statt des alten Bilds (assets/menu/hauptmenue.jpg). Aufstellung wie dort: Kaempferin, Magier, Zwerg, Klerikerin, jetzt nach BRS als
# Herkunft mit ihrer Startausruestung; in wahrer Groesse (B7) nebeneinander, die aeusseren zur Mitte gewandt, im warmen Lichtkegel auf
# Schwarz. Ein Standbild: nach wenigen Bildern zeichnet der Teller nicht mehr (wie Drehteller dreht=false). Ohne Modelle (am Rechner) leer.

const DP := AktionsKnopf.DP
const HELDEN := [
	{"herkunft": "Wachsoldat", "volk": "Mensch", "geschlecht": "w", "x": -1.32, "dreh": 18.0},
	{"herkunft": "Zauberlehrling", "volk": "Mensch", "geschlecht": "m", "x": -0.44, "dreh": 6.0},
	{"herkunft": "Jägerkind", "volk": "Zwerg", "geschlecht": "m", "x": 0.44, "dreh": -6.0},
	{"herkunft": "Klosterschüler", "volk": "Elf", "geschlecht": "w", "x": 1.32, "dreh": -18.0},
]
# Schein: Mitte (0,5/0,86) im Bild, Halbachsen waagrecht 0,5, nach oben 0,86, nach unten 0,14; warm in der Mitte, aussen schwarz
const SCHEIN := """shader_type canvas_item;
uniform vec3 farbe : source_color = vec3(0.30, 0.20, 0.10);
void fragment() {
	vec2 d = UV - vec2(0.5, 0.86);
	d.x /= 0.5;
	d.y /= (d.y < 0.0) ? 0.86 : 0.14;
	float r = length(d);
	COLOR = vec4(farbe * (1.0 - smoothstep(0.0, 1.0, r)), 1.0);
}
"""
const BILD_HOEHE := 2.3        # Meter, die das Bild hoch zeigt (Stab, Hut), Fuesse unten mit Rand
var _v: SubViewport
var _bilder := 0
var figuren: Array[Node3D] = []

func _init(breite_dp := 330.0) -> void:
	custom_minimum_size = Vector2(breite_dp, breite_dp * 0.625) * DP   # Seitenverhaeltnis des alten Bilds (600 x 375)
	# 867 (Chef 12.11., 20:01: „mit einem vernünftigen Licht“; Vorlage 18:00: der Schein endete unten und seitlich mit harter Kante):
	# Schein als Ellipse um die Fuesse, nach allen Seiten weich ins Schwarz (kein Rand des Bilds sichtbar)
	var licht := ColorRect.new()
	var sh := Shader.new()
	sh.code = SCHEIN
	var sm := ShaderMaterial.new()
	sm.shader = sh
	licht.material = sm
	licht.color = Color(0, 0, 0)
	licht.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	licht.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(licht)
	var c := SubViewportContainer.new()
	c.stretch = true
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(c)
	var v := SubViewport.new()
	v.own_world_3d = true
	v.transparent_bg = true
	v.msaa_3d = Viewport.MSAA_4X
	c.add_child(v)
	_v = v
	var welt := WorldEnvironment.new()
	welt.environment = Environment.new()
	welt.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	welt.environment.ambient_light_color = Color(0.5, 0.44, 0.38)
	v.add_child(welt)
	var sonne := DirectionalLight3D.new()   # warm von vorn oben wie der Lichtkegel
	sonne.light_color = Color(1.0, 0.9, 0.76)
	sonne.rotation_degrees = Vector3(-38, -18, 0)
	v.add_child(sonne)
	# 867 (Chef 20:01; 292.3 „Gesichter erkennbar“): Lampe vorn oben, wie der Lichtkegel von oben, hellt die Gesichter auf; das dunkle
	# Gesicht des Zauberlehrlings lag in der ersten Vorlage fast ganz im Schatten
	var lampe := OmniLight3D.new()
	lampe.light_color = Color(1.0, 0.86, 0.66)
	lampe.light_energy = 1.6
	lampe.omni_range = 6.0
	lampe.omni_attenuation = 1.2
	lampe.position = Vector3(0, 2.5, 2.2)
	v.add_child(lampe)
	var kam := Camera3D.new()
	kam.fov = 26.0
	kam.position = Vector3(0, BILD_HOEHE / 2.0 - 0.08, BILD_HOEHE / 2.0 / tan(deg_to_rad(kam.fov) / 2.0))
	v.add_child(kam)
	for h in HELDEN:
		var w := wahl(h)
		var mats := []
		var m: Node3D = HeldFigur.baue(w, mats)
		if m == null: continue
		var trg := Node3D.new()
		trg.position = Vector3(float(h["x"]), 0, 0)
		trg.rotation.y = deg_to_rad(float(h["dreh"]))
		v.add_child(trg)
		trg.add_child(m)
		for mt in mats:
			(mt as ShaderMaterial).set_shader_parameter("metall", 1.0)
			(mt as ShaderMaterial).set_shader_parameter("licht_dir", Basis.from_euler(sonne.rotation).z)
		var anim := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		if anim:
			Gebiet.bewegungen(anim, ["Stehen"])
			if anim.has_animation("Stehen"):
				anim.play("Stehen")
				anim.seek(anim.get_animation("Stehen").length * (0.15 + 0.2 * figuren.size()), true)   # nicht im Gleichtakt (C3)
		figuren.append(trg)

## die Wahl eines Helden wie in der Erschaffung (erschaffung_brs.gd wahl_jetzt): Herkunft, Volk, Aussehen, Startausruestung
static func wahl(h: Dictionary) -> Dictionary:
	var b := BrsHeld.neu(String(h["volk"]), String(h["herkunft"]))
	b.ausstatten()
	var g := String(h["geschlecht"])
	var a := {"geschlecht": g}
	# Frisur, Bart, Haar- und Hautfarbe der Herkunft wie in der Erschaffung (HeldFigur.vorgabe); 867 Chef 18:23: mit derselben ersten
	# Frisur fuer alle Maenner sahen Zauberlehrling und Jaegerkind aus „wie Brüder“
	var bt := HeldFigur.baerte(g)
	if g == "m" and String(h["volk"]) == "Zwerg" and bt.size() > 1: a["bart"] = bt[1]
	return {"herkunft": String(h["herkunft"]), "volk": HeldFigur.volk_modell(String(h["volk"])), "aussehen": a, "ausruestung": b.ausruestung}

func _process(_dt: float) -> void:
	if _v and _bilder < 8:   # Standbild: erst zeichnen, wenn Groesse und Haltung stehen, dann aus
		_bilder += 1
		if _bilder == 8: _v.render_target_update_mode = SubViewport.UPDATE_DISABLED
