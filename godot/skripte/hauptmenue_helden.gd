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
const BILD_HOEHE := 2.3        # Meter, die das Bild hoch zeigt (Stab, Hut), Fuesse unten mit Rand
var _v: SubViewport
var _bilder := 0
var figuren: Array[Node3D] = []

func _init(breite_dp := 330.0) -> void:
	custom_minimum_size = Vector2(breite_dp, breite_dp * 0.625) * DP   # Seitenverhaeltnis des alten Bilds (600 x 375)
	var licht := TextureRect.new()   # Lichtkegel: warmer Schein am Boden, nach aussen ins Schwarz
	var g := Gradient.new()
	g.set_color(0, Color(0.28, 0.19, 0.10))
	g.set_color(1, Color(0, 0, 0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.82)
	gt.fill_to = Vector2(0.5, 0.0)
	licht.texture = gt
	licht.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	licht.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	licht.stretch_mode = TextureRect.STRETCH_SCALE
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
	var fr := HeldFigur.frisuren(g)
	if not fr.is_empty() and String(fr[0]) != "": a["frisur"] = fr[0]
	var bt := HeldFigur.baerte(g)
	if g == "m" and String(h["volk"]) == "Zwerg" and bt.size() > 1: a["bart"] = bt[1]
	return {"herkunft": String(h["herkunft"]), "volk": HeldFigur.volk_modell(String(h["volk"])), "aussehen": a, "ausruestung": b.ausruestung}

func _process(_dt: float) -> void:
	if _v and _bilder < 8:   # Standbild: erst zeichnen, wenn Groesse und Haltung stehen, dann aus
		_bilder += 1
		if _bilder == 8: _v.render_target_update_mode = SubViewport.UPDATE_DISABLED
