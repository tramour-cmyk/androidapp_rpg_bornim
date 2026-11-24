extends SceneTree
# 431 Schritt 3 (Auftrag 24.11., 08:31): Bilder zum Beleglauf, Renderer wie am Handy (mobile), Bildschirm 540x1170.
#   erschaffung_<volk>_<m|w>_<alt|neu>.png: die echte Erschaffung (ErschaffungBrs) mit Volk und Geschlecht, Herkunft Wachsoldat,
#     Held angehalten in derselben Drehung und Pose; alt = Menschenkoerper wie vor 431 (HeldFigur.ohne_volk), neu = Volkskoerper
#   reihe_vorn.png, reihe_seite.png, reihe_hinten.png: alle zehn Figuren nebeneinander in wahrer Groesse (Spielfigur, Toon-Licht, Tusche),
#     vorn und von der Seite in der Startausruestung, hinten der Wachsoldat in Platte (Brustplatte, Panzerhandschuhe, Beinschienen; ohne Umhang, Sokrates 24.11., 09:39)
# Beschriftung setzt godot.yml (ImageMagick). Aufruf: AUS=<ordner> godot --path . --rendering-method mobile --resolution 540x1170 -s res://tests/voelker_bild_431.gd
const VOELKER := ["Mensch", "Elf", "Zwerg", "Hügelvolk", "Orkblütiger"]
const DREH := 25.0       # Grad: Drehung des Helden im Teller (leicht von der Seite, Umriss)
const ZEIT := 0.4        # s in „Stehen“
var aus := OS.get_environment("AUS")

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if aus == "" or not HeldFigur.da():
		print("VOELKERBILD431 ohne AUS oder ohne Kaufmodelle"); quit(0); return
	DirAccess.make_dir_recursive_absolute(aus)
	Sprache.lang = "de"   # deutsch wie beim Chef, ohne die Einstellung zu speichern
	for v in VOELKER:
		for g in ["m", "w"]:
			for art in ["alt", "neu"]:
				HeldFigur.ohne_volk = art == "alt"
				var e := ErschaffungBrs.new()
				root.add_child(e)
				await process_frame
				e.volk_waehlen(v)
				e.geschlecht_waehlen(g)
				for i in 3: await process_frame
				var t := e.teller
				t.dreht = false
				t.teller.rotation.y = deg_to_rad(DREH)
				_pose(t.teller)
				for i in 4: await process_frame
				await RenderingServer.frame_post_draw
				var img := root.get_texture().get_image()
				var p := aus.path_join("erschaffung_%s_%s_%s.png" % [_datei(v), g, art])
				img.save_png(p)
				print("BILD ", p, " Modell ", _modell(t.teller))
				e.queue_free()
				await process_frame
	HeldFigur.ohne_volk = false
	await _reihe("vorn")
	await _reihe("seite")
	await _reihe("hinten")
	print("VOELKERBILD431 fertig")
	quit(0)

func _datei(v: String) -> String: return HeldFigur.kennung(v).to_lower()

func _modell(n: Node) -> String:
	for c in n.get_children():
		if c.has_meta("tracht"): return String(c.get_meta("tracht"))
	return "-"

# Pose anhalten: alle AnimationPlayer auf ZEIT in „Stehen“
func _pose(n: Node) -> void:
	for ap in n.find_children("*", "AnimationPlayer", true, false):
		var a := ap as AnimationPlayer
		if a.current_animation == "": continue
		a.seek(ZEIT, true)
		a.pause()

# alle zehn Figuren in einer Reihe, wahre Groesse; hinten: Wachsoldat in Platte von hinten
func _reihe(ansicht: String) -> void:
	var hinten := ansicht == "hinten"
	var sv := SubViewport.new()
	sv.size = Vector2i(1170, 540)
	sv.own_world_3d = true
	sv.msaa_3d = Viewport.MSAA_4X
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sv)
	var welt := WorldEnvironment.new()
	welt.environment = Environment.new()
	welt.environment.background_mode = Environment.BG_COLOR
	welt.environment.background_color = Color(0.05, 0.045, 0.04)
	welt.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	welt.environment.ambient_light_color = Color(0.55, 0.5, 0.45)
	sv.add_child(welt)
	var sonne := DirectionalLight3D.new()   # wie der Drehteller, von der Kamera aus
	sonne.light_color = Color(1.0, 0.92, 0.8)
	sonne.rotation_degrees = Vector3(-40, -30 + (180.0 if hinten else 0.0), 0)
	sv.add_child(sonne)
	var boden := MeshInstance3D.new()
	var pm := PlaneMesh.new(); pm.size = Vector2(20, 6)
	var bm := StandardMaterial3D.new(); bm.albedo_color = Color(0.16, 0.14, 0.11)
	pm.material = bm
	boden.mesh = pm
	sv.add_child(boden)
	var kam := Camera3D.new()
	kam.fov = 26.0
	var breite := 8.2   # m im Bild; Abstand aus dem waagrechten Blickwinkel
	var d := (breite / 2.0) / (tan(deg_to_rad(kam.fov) / 2.0) * 1170.0 / 540.0)
	kam.position = Vector3(0, 1.0, d if not hinten else -d)
	sv.add_child(kam)
	kam.look_at(Vector3(0, 0.95, 0), Vector3.UP)
	var i := 0
	for v in VOELKER:
		for g in ["m", "w"]:
			var b := BrsHeld.neu(v, "Wachsoldat")
			b.ausstatten()
			var ausr: Dictionary = b.ausruestung
			if hinten: ausr = load("res://tests/voelker_431.gd").platte(ausr)
			var vm := HeldFigur.volk_modell(v)
			var mats := []
			var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": vm, "aussehen": HeldFigur.vorgabe("Wachsoldat", g, vm), "ausruestung": ausr}, mats)
			if m == null: continue
			for x in mats:
				(x as ShaderMaterial).set_shader_parameter("metall", 1.0)
				(x as ShaderMaterial).set_shader_parameter("licht_dir", Basis.from_euler(sonne.rotation).z)
			var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			if ap and ap.has_animation("Stehen"): ap.play("Stehen")
			sv.add_child(m)
			m.position = Vector3((4.5 - i if hinten else i - 4.5) * 0.8, 0, 0)   # von hinten auch der Mensch links im Bild
			if ansicht == "seite": m.rotation.y = PI / 2.0   # Blick nach rechts im Bild
			i += 1
	for k in 3: await process_frame
	_pose(sv)
	for k in 4: await process_frame
	await RenderingServer.frame_post_draw
	var p := aus.path_join("reihe_%s.png" % ansicht)
	var img := sv.get_texture().get_image()
	img.save_png(p)
	print("BILD ", p)
	sv.queue_free()
	await process_frame
