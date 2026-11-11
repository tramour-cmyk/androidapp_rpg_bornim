extends SceneTree
# 416.4 Vergleichsfilm Rennen (Chef 31.10., Build 143: „als würde er Hochsprung machen“): je Fassung des Helden ein Feld nebeneinander,
# Stehen, Gehen, Anlaufen und Rennen wie held.gd (Tempo 2,13 und 4,27 m/s, 5 m/s², Überblendung 0,6 s im selben Schritt, speed_scale
# aus held-info.json, damit die Füße nicht gleiten); erst Spielansicht (30° von oben, Nordwest), dann von der Seite, dann Zeitlupe.
# Boden mit Kachellinien (1,16 m): daran sieht man Tempo und Gleiten. Feld „<Titel>|kauf:<Fassung>“: Kaufkoerper wie im Spiel
# (HeldFigur.RENNEN_ARTEN; Lauf tom-probe-4164.yml). Am Rechner (Bildlauf, PROBE=416.4):
#   HELDE="<Titel>|<Ordner mit held.glb, held-info.json>;…" xvfb-run -a godot --path godot \
#     --write-movie <x.avi> --fixed-fps 30 -s res://tests/rennen_film_4164.gd
const GEHEN := 1.84 * Karte.TS
const RENNEN := 3.68 * Karte.TS
const BESCHL := 5.0
const FPS := 30.0
# Abschnitte: [Titel, Sekunden, Ansicht, Zeitfaktor]
const TEILE := [["Spielansicht · Echtzeit", 7.0, "spiel", 1.0], ["von der Seite · Echtzeit", 7.0, "seite", 1.0],
	["von der Seite · halbe Geschwindigkeit", 14.0, "seite", 0.5]]

var felder := []
var kopf: Label
var bild := 0
var t_sim := 0.0

func _initialize() -> void: _bau.call_deferred()

func _bau() -> void:
	var helde := OS.get_environment("HELDE").split(";", false)
	# Felder untereinander im Hochformat des Spiels (Fenster aus project.godot; Lauf 10:40: Breite aus get_visible_rect, die mit
	# stretch „expand“ nicht das Bild ist: drei Felder zu 777 px in 1080, zu sehen war nur das erste)
	var fenster := Vector2i(int(ProjectSettings.get_setting("display/window/size/viewport_width")),
		int(ProjectSettings.get_setting("display/window/size/viewport_height")))
	var reihe := VBoxContainer.new()
	reihe.position = Vector2.ZERO
	reihe.size = Vector2(fenster)
	reihe.add_theme_constant_override("separation", 6)
	root.add_child(reihe)
	var oben := 70
	var breite := fenster.x
	var hoehe := (fenster.y - oben - 6 * helde.size()) / helde.size()
	var rand := Control.new()
	rand.custom_minimum_size = Vector2(0, oben - 6)
	reihe.add_child(rand)
	for e in helde:
		var teil := e.split("|")
		var fd := _feld(reihe, teil[0], teil[1], Vector2i(breite, hoehe))
		fd["alt"] = teil.size() > 2 and teil[2] == "alt"   # 416.4: Uebergaenge wie vor dem 01.11. (sofort los, ohne Bremsen, 0,25 s in den Stand)
		fd["bisher"] = teil.size() > 2 and teil[2] == "bisher"   # 416.4 vor dem Abbremsen in Stufen (Chef 20:3x): Rennen -> Gehen mit BESCHL
		if not fd["alt"] and not fd["bisher"]: Held.baue_aus(fd["anim"])
		felder.append(fd)
	kopf = Label.new()
	kopf.position = Vector2(0, 12)
	kopf.size = Vector2(fenster.x, 50)
	kopf.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kopf.add_theme_font_size_override("font_size", 38)
	kopf.add_theme_color_override("font_color", Color(0.93, 0.8, 0.45))
	root.add_child(kopf)
	process_frame.connect(_schritt)

func _feld(reihe: VBoxContainer, titel: String, ordner: String, px: Vector2i) -> Dictionary:
	var box := SubViewportContainer.new()
	box.stretch = true
	box.custom_minimum_size = Vector2(px)
	reihe.add_child(box)
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
	Licht.zur_sonne = sonne.basis.z.normalized()   # 416.4 Grundstand A1: Tusche nach dieser Sonne (Kamera)
	vp.add_child(_boden())
	var held := Node3D.new()
	held.rotation.y = PI / 2   # läuft nach +X
	vp.add_child(held)
	var modell: Node3D
	var info := {}
	var anim: AnimationPlayer
	if ordner.begins_with("kauf:"):
		# Tom 01.11.: der Held, wie er im Spiel laeuft (Kaufkoerper, heldfigur.gd), Kaempfer; Fassung nach „kauf:“
		var z := Zustand.new()
		var hw := BrsHeld.fuer_spiel("Probe", "Mensch", "Wachsoldat", z.neue_uid)
		var w := HeldFigur.wahl(hw, z)
		w["rennen"] = ordner.trim_prefix("kauf:")
		w["ausruestung"] = {}   # ohne Waffen: Tragart ist 417
		var km := []
		modell = HeldFigur.baue(w, km)
		if modell == null: print("FILM FEHLER Kaufkoerper fehlt"); quit(1); return {}
		for m in km: (m as ShaderMaterial).set_shader_parameter("metall", 1.0)   # wie held.gd
		held.add_child(modell)
		info = {"gehen_m_je_s": modell.get_meta("gehen_m_je_s"), "rennen_m_je_s": modell.get_meta("rennen_m_je_s")}
		anim = Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
		var a := anim.get_animation("Rennen")
		print("FILM ", titel, " Rennen ", snappedf(a.length, 0.001), " s, rennen_m_je_s ", snappedf(float(info["rennen_m_je_s"]), 0.001))
	else:
		modell = Gebiet.lade_glb(ordner + "/held.glb")
		held.add_child(modell)
		var mats := []
		Gebiet.male(modell, null, 2, mats)
		for m in mats: (m as ShaderMaterial).set_shader_parameter("metall", 1.0)
		info = JSON.parse_string(FileAccess.get_file_as_string(ordner + "/held-info.json"))
		anim = Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
		Gebiet.bewegungen(anim, ["Gehen", "Stehen", "Rennen"])
	anim.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	anim.play("Stehen")
	# 416.4 Grundstand A1 (457.1): Spielkamera mit Tusche nach Licht (Welt Schablone 0, Held 2) statt einer blanken Camera3D
	var cam := Kamera.new()
	vp.add_child(cam)
	var schild := Label.new()
	schild.text = titel
	schild.position = Vector2(24, 14)
	schild.size = Vector2(px.x - 48, 60)
	schild.add_theme_font_size_override("font_size", 36)
	schild.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	schild.add_theme_constant_override("outline_size", 8)
	schild.add_theme_color_override("font_color", Color(0.95, 0.93, 0.88))
	box.add_child(schild)
	return {"box": box, "vp": vp, "held": held, "anim": anim, "cam": cam, "gang": float(info["gehen_m_je_s"]), "renn": float(info["rennen_m_je_s"]),
		"tempo": 0.0}

func _boden() -> MeshInstance3D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGB8)
	img.fill(Color(0.36, 0.42, 0.24))
	for i in 64:
		for k in 2:
			img.set_pixel(i, k, Color(0.22, 0.26, 0.15)); img.set_pixel(k, i, Color(0.22, 0.26, 0.15))
	var tex := ImageTexture.create_from_image(img)
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(400, 200)
	m.uv1_scale = Vector3(400 / Karte.TS, 200 / Karte.TS, 1)
	mesh.material = m
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(190, 0, 0)
	return mi

func _teil(t: float) -> Array:
	var a := 0.0
	for e in TEILE:
		if t < a + e[1]: return [e, t - a]
		a += e[1]
	return []

func _schritt() -> void:
	var t := bild / FPS
	bild += 1
	if bild == 5 and OS.has_environment("LAGE"):   # Prüfung ohne Bild: Lage der Felder, Kamera je Feld
		for f in felder:
			var vp: SubViewport = f["vp"]
			print("FELD ", (f["box"] as Control).get_global_rect(), " vp ", vp.size, " kamera ", vp.get_camera_3d() == f["cam"], " held ", (f["held"] as Node3D).global_position)
		print("FENSTER ", root.get_visible_rect(), " ", root.size)
	var tl := _teil(t)
	if tl.is_empty(): quit(); return
	var e: Array = tl[0]
	kopf.text = e[0]
	var dt: float = e[3] / FPS
	t_sim += dt
	for f in felder: _held(f, dt, e[2])

# wie held.gd _process (416.4, Chef 01.11., 13:1x: „von Stehen zu Gehen oder Laufen muss weich sein“): je ZYKLUS Stehen, Gehen,
# Rennen, Gehen, Bremsen am Ende des Wegs, Stehen; Tempo und Ueberblendung aus held.gd (Held.tempo_schritt, Held.bremse,
# Held.ueberblendung), Feld „alt“ wie vorher
const ZYKLUS := 7.0
const FOLGE := [[0.8, 0.0], [2.4, 1.0], [4.4, 2.0], [6.2, 1.0], [7.0, 0.0]]   # bis Sekunde, 0 Stehen, 1 Gehen, 2 Rennen
func _held(f: Dictionary, dt: float, ansicht: String) -> void:
	var held: Node3D = f["held"]
	var anim: AnimationPlayer = f["anim"]
	var z := fmod(t_sim, ZYKLUS)
	var art := 0.0; var bis := 0.0; var naechste := 0.0
	for i in FOLGE.size():
		if z < FOLGE[i][0]:
			art = FOLGE[i][1]; bis = FOLGE[i][0]; naechste = FOLGE[i + 1][1] if i + 1 < FOLGE.size() else 0.0
			break
	var soll: float = [0.0, GEHEN, RENNEN][int(art)]
	var moving := soll > 0.0
	var alt: bool = f.get("alt", false)
	var neu: bool = not alt and not f.get("bisher", false)
	var ab := Held.ABBREMS if neu else BESCHL   # 416.4 wie held.gd: langsamer werden ohne Halt gut 1 s
	if moving and naechste == 0.0 and not alt:   # Ende des Wegs: so weit, wie er noch im Gehtempo kaeme
		var b := Held.bremse(soll, (bis - z) * GEHEN, GEHEN)
		if b < soll - 0.001: ab = BESCHL
		soll = b
	var vor: float = f["tempo"]
	var abbremsen: bool = neu and ab == Held.ABBREMS and vor > soll + 0.05 and soll <= GEHEN * 1.45
	if alt: f["tempo"] = 0.0 if not moving else (minf(soll, GEHEN) if f["tempo"] <= 0.0 else move_toward(f["tempo"], soll, BESCHL * dt))
	else: f["tempo"] = Held.tempo_schritt(f["tempo"], soll, GEHEN, dt, ab)
	var tempo: float = f["tempo"]
	held.position.x += tempo * dt
	var rennt := moving and tempo > GEHEN * 1.45
	if neu: rennt = Held.rennt_jetzt(anim, moving, tempo, soll, GEHEN, tempo < vor - 1e-5, abbremsen, f["renn"], f["gang"])
	var want := ("Rennen" if rennt else "Gehen") if moving else "Stehen"
	var cur := anim.current_animation
	var v: float = f["renn"] if rennt else f["gang"]
	var sp := (tempo / v) if moving else 1.0
	if cur != want and not alt: Held.wechsel(anim, want, moving, sp, neu)   # 416.4: Ueberblendung in echter Zeit, Schritt nach Tritten; neu: sanft
	elif cur != want:
		var phase := anim.current_animation_position / maxf(0.001, anim.current_animation_length) if cur != "" else 0.0
		var schritt := cur.begins_with("Gehen") or cur.begins_with("Rennen")
		anim.play(want, 0.6 if schritt and moving else (0.5 if cur.begins_with("Stehen") else 0.25))
		if schritt and moving: anim.seek(phase * anim.get_animation(want).length)
	if moving and anim.has_meta("halt"): anim.remove_meta("halt")
	anim.speed_scale = (Held.takt(anim, tempo, v, dt) if not alt else sp) if moving else (Held.stand_takt(anim, dt) if neu else 1.0)
	anim.advance(dt)
	var cam: Camera3D = f["cam"]
	var ziel := held.position + Vector3(0, 0.9, 0)
	if ansicht == "spiel":
		cam.rotation_degrees = Vector3(-30, Kamera.NORD, 0)
		cam.size = Kamera.NAH
	else:
		cam.rotation_degrees = Vector3(-12, 0, 0)
		cam.size = Kamera.NAH
	cam.position = ziel + cam.global_transform.basis.z * 20.0
