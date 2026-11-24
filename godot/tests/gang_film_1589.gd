extends SceneTree
# 1589.3 Beleg (Figurenprobe): Held Mann und Frau auf dem Kaufkoerper von der Seite, je links alt (Gehen rueckwaerts abgespielt wie
# kampf/figur.gd 1741, 3369) und rechts neu (HeldFigur.gang_wahl), jede der fuenf Bewegungen dreimal, das Gesicht vorn (Blick nach
# rechts im Bild). Gleiches Tempo am Boden in alt und neu, neu ohne Gleiten (speed_scale = Tempo / m_je_s). Boden mit Kachellinien.
# Dazu je Feld und Bewegung das Gleiten des Standfusses (Median, cm/s): „GLEITEN …“.
# Am Rechner: COMMIT=<kurz> xvfb-run -a ~/godot/godot --path godot --write-movie <x.avi> --fixed-fps 30 -s res://tests/gang_film_1589.gd
const FPS := 30.0
const TAKT := 1.12                 # speed_scale der neuen Bewegungen: dreimal je Bewegung in 15 s
const FOLGE := [[deg_to_rad(180.0), "Rückwärts"], [deg_to_rad(135.0), "Rückwärts schräg links"], [deg_to_rad(-135.0), "Rückwärts schräg rechts"],
	[deg_to_rad(90.0), "Seitschritt links"], [deg_to_rad(-90.0), "Seitschritt rechts"]]
const VOR := 0.4                   # s Stehen am Anfang

var felder := []
var kopf: Label
var bild := 0
var dauer := 0.0                   # s je Bewegung (drei Umlaeufe)

func _initialize() -> void: _bau.call_deferred()

func _bau() -> void:
	var fenster := Vector2i(int(ProjectSettings.get_setting("display/window/size/viewport_width")),
		int(ProjectSettings.get_setting("display/window/size/viewport_height")))
	var oben := 110
	var px := Vector2i(fenster.x / 2 - 3, (fenster.y - oben) / 2 - 3)
	var gitter := GridContainer.new()
	gitter.columns = 2
	gitter.position = Vector2(0, oben)
	gitter.add_theme_constant_override("h_separation", 6)
	gitter.add_theme_constant_override("v_separation", 6)
	root.add_child(gitter)
	for g in ["m", "w"]:
		for alt in [true, false]:
			var fd := _feld(gitter, g, alt, px)
			if fd.is_empty(): quit(1); return
			felder.append(fd)
	var an: Animation = (felder[1]["anim"] as AnimationPlayer).get_animation("Rueckwaerts")
	dauer = 3.0 * an.length / TAKT
	kopf = Label.new()
	kopf.position = Vector2(0, 10)
	kopf.size = Vector2(fenster.x, 90)
	kopf.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kopf.add_theme_font_size_override("font_size", 36)
	kopf.add_theme_color_override("font_color", Color(0.93, 0.8, 0.45))
	root.add_child(kopf)
	print("FILM Dauer je Bewegung %.2f s, gesamt %.1f s" % [dauer, VOR + dauer * FOLGE.size()])
	process_frame.connect(_schritt)

func _feld(gitter: GridContainer, g: String, alt: bool, px: Vector2i) -> Dictionary:
	var box := SubViewportContainer.new()
	box.stretch = true
	box.custom_minimum_size = Vector2(px)
	gitter.add_child(box)
	var vp := SubViewport.new()
	vp.own_world_3d = true
	vp.size = px
	vp.msaa_3d = Viewport.MSAA_4X
	box.add_child(vp)
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.16, 0.17, 0.16)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.66, 0.75)
	env.ambient_light_energy = 0.75
	we.environment = env
	vp.add_child(we)
	var sonne := DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-50, 30, 0)
	sonne.shadow_enabled = true
	sonne.light_energy = 1.2
	vp.add_child(sonne)
	Licht.zur_sonne = sonne.basis.z.normalized()
	vp.add_child(_boden())
	var held := Node3D.new()
	held.rotation.y = PI / 2   # Blick nach +X (im Bild rechts)
	vp.add_child(held)
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Probe", "Mensch", "Wachsoldat", z.neue_uid)
	var w := HeldFigur.wahl(hw, z)
	w["aussehen"] = {"geschlecht": g}
	w["ausruestung"] = {}   # ohne Schild: der Fall ohne Schildsatz
	var km := []
	var modell := HeldFigur.baue(w, km)
	if modell == null: print("FILM FEHLER Kaufkoerper fehlt"); return {}
	for m in km: (m as ShaderMaterial).set_shader_parameter("metall", 1.0)
	held.add_child(modell)
	var anim := Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	anim.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	anim.play("Stehen")
	var cam := Kamera.new()
	vp.add_child(cam)
	var schild := Label.new()
	schild.position = Vector2(18, 12)
	schild.size = Vector2(px.x - 36, 120)
	schild.autowrap_mode = TextServer.AUTOWRAP_WORD
	schild.add_theme_font_size_override("font_size", 30)
	schild.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	schild.add_theme_constant_override("outline_size", 8)
	schild.add_theme_color_override("font_color", Color(0.95, 0.93, 0.88))
	box.add_child(schild)
	return {"held": held, "anim": anim, "cam": cam, "schild": schild, "alt": alt, "g": "Mann" if g == "m" else "Frau",
		"sk": Gebiet.finde(modell, "Skeleton3D"), "akt": -1, "proben": {}}

func _boden() -> MeshInstance3D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGB8)
	img.fill(Color(0.36, 0.42, 0.24))
	for i in 64:
		for k in 2:
			img.set_pixel(i, k, Color(0.22, 0.26, 0.15)); img.set_pixel(k, i, Color(0.22, 0.26, 0.15))
	var m := StandardMaterial3D.new()
	m.albedo_texture = ImageTexture.create_from_image(img)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(200, 200)
	m.uv1_scale = Vector3(200 / Karte.TS, 200 / Karte.TS, 1)
	mesh.material = m
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	return mi

func _schritt() -> void:
	var t := bild / FPS
	bild += 1
	var dt := 1.0 / FPS
	var i := int(floorf((t - VOR) / dauer)) if t >= VOR else -1
	if i >= FOLGE.size():
		_auswertung()
		quit()
		return
	var commit := OS.get_environment("COMMIT")
	kopf.text = "1589.3 · Commit %s\n%s" % [commit, "Stehen" if i < 0 else "%s (%d von 5)" % [FOLGE[i][1], i + 1]]
	for f in felder: _held(f, i, dt)

func _held(f: Dictionary, i: int, dt: float) -> void:
	var held: Node3D = f["held"]
	var anim: AnimationPlayer = f["anim"]
	var neu_ap: AnimationPlayer = felder[1]["anim"]
	if i >= 0:
		var w: float = FOLGE[i][0]
		var r := HeldFigur.gang_wahl(neu_ap, w)
		var v: float = float(r["m_je_s"]) * TAKT   # Tempo am Boden, alt wie neu
		if f["akt"] != i:
			f["akt"] = i
			if f["alt"]:
				anim.play("Gehen", 0.2, -v / HeldFigur.TAKT_GEHEN)
				f["schild"].text = "%s · alt: Gehen rückwärts abgespielt" % f["g"]
			else:
				anim.play(String(r["name"]), 0.2, TAKT)
				f["schild"].text = "%s · neu: %s" % [f["g"], r["name"]]
		var welt := held.global_transform.basis * Vector3(sin(w), 0, cos(w))   # Weg im Winkel w zur Blickrichtung (+Z der Figur)
		held.position += welt * v * dt
		_probe(f, i)
	else:
		if f["schild"].text == "": f["schild"].text = "%s · %s" % [f["g"], "alt" if f["alt"] else "neu"]
		f["kopf0"] = _kopf_gier(f)
	anim.advance(dt)
	var cam: Camera3D = f["cam"]
	cam.rotation_degrees = Vector3(-12, -25, 0)   # von der Seite, leicht schraeg: auch der Seitschritt kommt sichtbar voran
	cam.size = Kamera.NAH
	cam.position = held.position + Vector3(0, 0.9, 0) + cam.global_transform.basis.z * 20.0

# Ballen beider Fuesse in der Welt je Bild (Gleiten: Tempo des Fusses am Boden, wenn er hoechstens 2 cm ueber seinem Tiefstand ist)
func _probe(f: Dictionary, i: int) -> void:
	var sk: Skeleton3D = f["sk"]
	var p: Dictionary = f["proben"]
	if not p.has(i): p[i] = {"l": [], "r": []}
	for s in ["l", "r"]:
		var b := sk.find_bone("ball_" + s)
		p[i][s].append((sk.global_transform * sk.get_bone_global_pose(b)).origin)
	if not f.has("kopf"): f["kopf"] = {}
	var d := absf(rad_to_deg(angle_difference(float(f["kopf0"]), _kopf_gier(f))))
	f["kopf"][i] = maxf(float(f["kopf"].get(i, 0.0)), d)

# Gier des Kopfs (Achse Z des Kopfknochens in der Welt, waagrecht) gegen die Figur
func _kopf_gier(f: Dictionary) -> float:
	var sk: Skeleton3D = f["sk"]
	var z := (sk.global_transform.basis * sk.get_bone_global_pose(sk.find_bone("Head")).basis).z
	return atan2(z.x, z.z) - float((f["held"] as Node3D).rotation.y)

func _auswertung() -> void:
	for f in felder:
		for i in f["proben"]:
			var vs := []
			for s in ["l", "r"]:
				var ps: Array = f["proben"][i][s]
				var tief: float = ps.map(func(o): return o.y).min()
				for j in range(1, ps.size()):
					if ps[j].y < tief + 0.02 and ps[j - 1].y < tief + 0.02:
						vs.append(Vector2(ps[j].x - ps[j - 1].x, ps[j].z - ps[j - 1].z).length() * FPS)
			vs.sort()
			print("GLEITEN %s %s %s: Standfuss %.1f cm/s (Median, %d Bilder), Kopf hoechstens %.0f Grad aus dem Blick im Stehen" % [f["g"],
				"alt" if f["alt"] else "neu", FOLGE[i][1], 100.0 * float(vs[vs.size() / 2]) if vs.size() > 0 else -1.0, vs.size(), float(f["kopf"][i])])
