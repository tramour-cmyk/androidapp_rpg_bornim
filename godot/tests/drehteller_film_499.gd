extends "res://tests/drehteller_499.gd"
# 499 (Chef 08.11., 12:41: „Und wie bewegen die sich dann mit beim Gehen?“; 646: Bewegung als Film): Kaempfer und Kleriker mit der
# Grundausruestung (Schild auf dem Ruecken, Waffe in der Hand wie 417a) gehen geradeaus ueber eine Wiese im Gehen ihres Waffenpakets,
# ohne Gleiten (Tempo der Bewegung); die Kamera (schraeg von oben, 30 Grad wie kamera.gd, Bildbreite 2,6 m) folgt und kreist in 8 s
# einmal um den Helden, so sieht man den Schild von allen Seiten. Licht wie der Drehteller (Erschaffung), ohne Tusche (645).
# Film:      xvfb-run godot --path godot --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 -s res://tests/drehteller_film_499.gd
# Probebild: BILDER=<ordner> ohne --write-movie: je Held ein Streifen aus vier Bildern derselben Szene (nach 1, 3, 5, 7 s Gehen)
# Messung (immer): je Sekunde Spalt des Schilds zum Koerper an Unter- und Oberkante, Oberkante gegen die Schultern

const FOLGE := ["Wachsoldat", "Klosterschüler"]
const NAMEN := {"Wachsoldat": "Kämpfer · Gehen, Schild auf dem Rücken", "Klosterschüler": "Kleriker · Gehen, Schild auf dem Rücken"}
const STEHEN_S := 1.0
const GEHEN_S := 8.0
const DT := 1.0 / 30.0
const BREITE := 2.6
const NEIGUNG := 30.0
const BILD_ZEITEN := [1.0, 3.0, 5.0, 7.0]

var welt: Node3D
var kam: Camera3D
var sonne: DirectionalLight3D
var schrift: Label

func _lauf() -> void:
	Sprache.lade()
	var bilder := OS.get_environment("BILDER")
	var mit_bild := DisplayServer.get_name() != "headless" and bilder != ""
	baue_welt()
	for k in FOLGE: await geh(k, mit_bild, bilder)
	print("DREHTELLER499 Gehen %d Fehler" % fehler)
	quit(1 if fehler else 0)

func baue_welt() -> void:
	welt = Node3D.new()
	root.add_child(welt)
	var we := WorldEnvironment.new()
	we.environment = Environment.new()
	we.environment.background_mode = Environment.BG_COLOR
	we.environment.background_color = Color(0.05, 0.04, 0.03)
	we.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	we.environment.ambient_light_color = Color(0.55, 0.5, 0.45)
	welt.add_child(we)
	sonne = DirectionalLight3D.new()
	sonne.light_color = Color(1.0, 0.92, 0.8)
	sonne.rotation_degrees = Vector3(-40, -30, 0)
	sonne.shadow_enabled = true
	welt.add_child(sonne)
	var boden := MeshInstance3D.new()
	var pm := PlaneMesh.new(); pm.size = Vector2(40, 40)
	boden.mesh = pm
	var bm := StandardMaterial3D.new(); bm.albedo_color = Color(0.22, 0.24, 0.15); bm.roughness = 1.0
	boden.material_override = bm
	welt.add_child(boden)
	# Steine je Meter links und rechts des Wegs, damit man das Vorankommen sieht
	var sm := StandardMaterial3D.new(); sm.albedo_color = Color(0.36, 0.33, 0.29); sm.roughness = 1.0
	for z in range(-2, 18):
		for x in [-0.9, 0.9]:
			var st := MeshInstance3D.new()
			var bx := BoxMesh.new(); bx.size = Vector3(0.14, 0.03, 0.1)
			st.mesh = bx; st.material_override = sm
			st.position = Vector3(x + 0.07 * sin(z * 2.3), 0.015, float(z) + 0.2 * cos(z * 1.7))
			welt.add_child(st)
	kam = Camera3D.new()
	kam.projection = Camera3D.PROJECTION_ORTHOGONAL
	kam.keep_aspect = Camera3D.KEEP_WIDTH
	kam.size = BREITE
	kam.near = 0.5; kam.far = 60.0
	welt.add_child(kam)
	kam.current = true
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	schrift = Label.new()
	schrift.position = Vector2(16, 24)
	schrift.add_theme_font_size_override("font_size", 26)
	schrift.add_theme_color_override("font_color", Color(0.85, 0.72, 0.42))
	ebene.add_child(schrift)

func stelle_kamera(ziel: Vector3, gieren: float) -> void:
	var g := deg_to_rad(gieren); var n := deg_to_rad(NEIGUNG)
	kam.look_at_from_position(ziel + Vector3(sin(g) * cos(n), sin(n), cos(g) * cos(n)) * 12.0, ziel)

func geh(k: String, mit_bild: bool, bilder: String) -> void:
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", k, z.neue_uid)
	var w := HeldFigur.wahl(hw, z)
	var mats := []
	var modell := HeldFigur.baue(w, mats)
	if modell == null: fehler += 1; print("FEHLER %s: kein Held" % k); return
	welt.add_child(modell)
	for m in mats:
		(m as ShaderMaterial).set_shader_parameter("metall", 1.0)
		(m as ShaderMaterial).set_shader_parameter("licht_dir", Basis.from_euler(sonne.rotation).z)
	var anim := Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
	if anim == null or sk == null: fehler += 1; print("FEHLER %s: ohne Bewegung" % k); modell.queue_free(); return
	Gebiet.bewegungen(anim, ["Gehen", "Stehen"])
	var gang := String(modell.get_meta("gang", ""))
	var bew := "Gehen_" + gang if gang != "" and anim.has_animation("Gehen_" + gang) else "Gehen"
	var v := float(modell.get_meta("gang_gehen_m_je_s", 0.0)) if bew != "Gehen" else 0.0
	if v <= 0.01: v = HeldFigur._eigen(bew)
	if v <= 0.01: v = 1.08
	print("Film 499 %s: %s, %.2f m/s" % [k, bew, v])
	schrift.text = NAMEN[k]
	anim.play("Stehen")
	var t := 0.0
	var streifen: Array[Image] = []
	var naechste := 0
	var schild := sk.find_children("RueckenSchild*", "", false, false)
	var ul := sk.find_bone("upperarm_l"); var ur := sk.find_bone("upperarm_r")
	var gemessen := -1
	while t < STEHEN_S + GEHEN_S:
		var geht := t >= STEHEN_S
		if geht and anim.current_animation != bew: anim.play(bew, 0.25)
		var tg := maxf(0.0, t - STEHEN_S)
		modell.position = Vector3(0, 0, tg * v)
		stelle_kamera(modell.position + Vector3(0, 0.9, 0), 45.0 + 360.0 * tg / GEHEN_S)
		await process_frame
		t += DT
		if geht and int(tg) != gemessen and not schild.is_empty():
			gemessen = int(tg)
			miss(k, tg, modell, sk, schild[0], ul, ur)
		if mit_bild and geht and naechste < BILD_ZEITEN.size() and tg >= BILD_ZEITEN[naechste]:
			naechste += 1
			await RenderingServer.frame_post_draw
			var b := root.get_texture().get_image(); b.convert(Image.FORMAT_RGBA8)
			streifen.append(b)
	if mit_bild and not streifen.is_empty():
		var bb := streifen[0].get_width(); var hh := streifen[0].get_height()
		var ges := Image.create(bb * streifen.size(), hh, false, Image.FORMAT_RGBA8)
		for i in streifen.size(): ges.blit_rect(streifen[i], Rect2i(0, 0, bb, hh), Vector2i(bb * i, 0))
		ges.save_png(bilder + "/499_gehen_%s.png" % k)
		print("BILD ", bilder + "/499_gehen_%s.png" % k)
	modell.queue_free()
	for i in 3: await process_frame

# Spalt an Unter- und Oberkante (je die kleinste Entfernung von 8 Ecken des Bands zur Haut) und Oberkante gegen die Schultergelenke
func miss(k: String, tg: float, modell: Node3D, sk: Skeleton3D, ba: Node, ul: int, ur: int) -> void:
	for mi in ba.find_children("*", "MeshInstance3D", true, false):
		var gt := (mi as MeshInstance3D).global_transform
		var pts: Array[Vector3] = []
		var me := (mi as MeshInstance3D).mesh
		for s in me.get_surface_count():
			for vv in me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]: pts.append(gt * vv)
		var y0 := INF; var y1 := -INF
		for p in pts: y0 = minf(y0, p.y); y1 = maxf(y1, p.y)
		var band := func(unten: bool) -> float:
			var sel := pts.filter(func(p): return p.y < y0 + 0.05 if unten else p.y > y1 - 0.05)
			var best := INF
			for i in range(0, sel.size(), maxi(1, sel.size() / 8)): best = minf(best, koerper_abstand(modell, sel[i]))
			return best
		var du: float = band.call(true); var do_: float = band.call(false)
		var sy := 0.0
		if ul >= 0 and ur >= 0:
			sy = ((sk.global_transform * sk.get_bone_global_pose(ul)).origin.y + (sk.global_transform * sk.get_bone_global_pose(ur)).origin.y) * 0.5
		print("  %s Gehen %.0f s: Spalt unten %.3f m, oben %.3f m; Oberkante %.2f m, Schultergelenke %.2f m (%+.0f cm)" % [k, tg, du, do_, y1, sy, (y1 - sy) * 100])
		pruefe(du <= SPALT_M + 0.02, "%s Gehen %.0f s: Schild unten %.0f cm vom Ruecken" % [k, tg, du * 100])
		pruefe(y1 - sy >= -0.02, "%s Gehen %.0f s: Oberkante %.0f cm unter den Schultern" % [k, tg, (sy - y1) * 100])
		break
