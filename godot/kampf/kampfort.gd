# 348.7 (Umzug Godot): der Kampfort von MARS. Vorgabe ist der heutige Kampfschirm (app SkirmishScreen.kt, core FightCamera.kt):
# eine Kamera aus 25° von oben, die Kampflinie 30° nach rechts, die Helden vorn links, die Gegner hinten rechts in zwei
# Reihen; darunter Kampfbericht, Lebensbalken und Knöpfe; der Ring beim angesagten Schlag. Die Regeln laufen in einem
# eigenen Faden (wie ProbeRun), der Schirm spielt ihre Meldungen nacheinander ab.
# Aufruf: Kampfort.new(party, foes, tables, potions, rueckkehr) als Kind eines Knotens; rueckkehr(outcome) am Ende, nach
# einem Sieg steht in [reward] der Lohn (regeln/lohn.gd), den die Welt dem Helden gutschreibt. Ein Held ohne LP kommt nie
# in den Kampf: setup gibt dann false, der Kampfort beendet sich mit "NONE" (Test 89.2 b).
extends Node3D

const Mars = preload("res://regeln/mars.gd")
const Lohn = preload("res://regeln/lohn.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Ui = preload("res://kampf/kampf_ui.gd")
const Figur = preload("res://kampf/figur.gd")

# FightCamera.kt
const PITCH := 25.0
const LENS := 1.5
const MID := 0.64
const AXIS := 30.0
const FRONT_M := 1.4
const BACK_M := 2.9
const HALF_M := 0.9
const FOE_HALF_M := 1.2         # Wölfe sind lang: mit 0,9 klebten sie aneinander, Balken lag auf dem Nachbarn (Prüfer Runde 7)
const NEAR_M := 1.0
const ALONE_HERO_B := 0.35
const BACK_GAP_A := 1.6          # 0,8 wie alt; der Wolf hinten stand im Rumpf des vorderen (Prüfer Runde 7)
const BACK_GAP_B := -0.75
const FOE_LEFT_BACK_M := 0.55
const FOE_LEFT_OUT_M := 0.45
const FOE_SIZE := 1.5
const WOLF_SIZE := 0.88         # 1,08 nach Messung (Schulter/Held alt 0,64, neu 0,52) wirkte im Bild „wie Kälber“ (Prüfer Lauf 14); zurück
# SkirmishScreen.kt
const SAY_MS := 1100
const RING_MS := 1100
const PERFECT_MS := 90
const GOOD_MS := 260

var mars
var tables: Dictionary
var on_end: Callable
## Starts the same fight anew ("Nochmal").
var again_fn: Callable
var cam: Camera3D
var ui
var figures := {}          # id -> Figur
var shown := {}            # the last message played: hp, places, intents, queue, sp
## 296.2: the hero's experience before the fight, how far above the place he stands, the level cap (null: chapter's)
var progress := {}
## 296.2: what the won fight brings ({xp, gold, items, level, levels, xp_total, lines}), empty otherwise
var reward := {}
var lang := 0

# the rules' thread and its beats (ProbeRun)
var worker: Thread
var beats: Array = []
var beats_lock := Mutex.new()
var ring_sem := Semaphore.new()
var ring_answer := Mars.NONE
var busy := false
var playing := false
var ring_open := false
var ring_start := 0
var ring_for := ""


func setup(party: Array, foes: Array, p_tables: Dictionary, potions: Dictionary, p_on_end: Callable, seed := -1, p_progress := {}) -> bool:
	tables = p_tables
	on_end = p_on_end
	progress = p_progress
	if not Mars.can_fight(party):
		return false
	var dice = Wuerfel.new(null if seed < 0 else seed)
	var words = Wuerfel.new(null if seed < 0 else seed + 279)
	mars = Mars.new(party, foes, tables, dice, words, lang, false)
	for k in potions:
		mars.potions[k] = int(potions[k])
	mars.listener = func(e): _post({"say": e})
	return true


func _ready() -> void:
	if mars == null:
		_refused.call_deferred()
		return
	_setup_world()
	ui = Ui.new()
	ui.kampfort = self
	add_child(ui)
	for f in mars.fighters():
		var fig := Figur.new()
		fig.setup(f, self)
		add_child(fig)
		figures[f.id] = fig
	shown = _state_now()
	for fig in figures.values():
		fig.snap_to(_spot_pos(fig.fighter, shown.places[fig.fighter.id]))
	get_viewport().size_changed.connect(_fit_camera)
	_fit_camera()
	ui.refresh()
	_run(func(): mars.start(_react))


func _exit_tree() -> void:
	if worker and worker.is_started():
		ring_sem.post()
		worker.wait_to_finish()


# ---------------------------------------------------------------- world: ground, light, camera, ink
func _setup_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	# Prüfer Lauf 14: obere Bildhälfte dunkel (Mittel 16–54 gegen alt 33–87); Waldinneres heller grün, Ferne wie alt oben (32/42/26)
	env.background_color = Color(0.13, 0.17, 0.10)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.66, 0.75)     # wie Toms licht.gd am Tag
	# heller als im Dorf: der alte Kampfort ist im Mittel 78 hell, neu mit Dorflicht 54, so 72 (Prüfer Stand 7: Wald zu dunkel)
	env.ambient_light_energy = 0.75
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.8
	env.adjustment_contrast = 1.06
	env.fog_enabled = true
	env.fog_light_color = Color(0.09, 0.14, 0.15)         # Waldinneres (ForestCam #14221A); Stand 9: oben doppelt so hell wie alt, grau; Runde 4: gelbstichig, kühler
	# Ferne heller im Dunst (Prüfer Lauf 14: Wald oben dunkel), aber nach Tiefe: erst ab 16 m (Gruppe 13 m, Gegner 15–17 m)
	# (Prüfer Stand 9: Gras dunstig; vorher 40 % Dunst über den Kämpfern)
	env.fog_mode = Environment.FOG_MODE_DEPTH
	env.fog_depth_begin = 16.0
	env.fog_depth_end = 70.0     # Runde 5: Wald oben flach (Streuung 23 gegen 34)
	env.fog_depth_curve = 0.4
	env.fog_density = 1.0
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	# höher und von vorn als im Dorf (licht.gd -50, 25): sonst liegt der Schatten der Bäume auf der Lichtung (Lauf 11:
	# Wölfe schwarz, grauer Wolf Helligkeit 8, ohne Baumschatten 43)
	sun.rotation_degrees = Vector3(-65, 0, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 40.0
	sun.shadow_blur = 1.5
	# Schlagschatten nicht schwarz (Prüfer Stand 7: harte schwarze Schatten), Licht bleibt aus der Sonne
	sun.shadow_opacity = 0.7
	sun.shadow_normal_bias = 1.2
	sun.light_energy = 1.3
	sun.light_color = Color(1.0, 0.94, 0.82)
	add_child(sun)
	_build_forest()
	cam = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_FRUSTUM
	cam.near = 0.1
	cam.far = 120.0
	add_child(cam)
	# Tusche wie Toms kamera.gd: Welt (Schablone 0) und Gruppe mit Waffen (Schablone 2, feiner; Probe Build 12)
	var tu: Shader = load("res://kampf/tusche.gdshader")
	var tu_held := Shader.new()
	tu_held.code = tu.code.replace("stencil_mode read, compare_equal, 0;", "stencil_mode read, compare_equal, 2;")
	if OS.get_environment("TUSCHE") != "0":     # Prüflauf: TUSCHE=0 misst, was die Linie ausmacht
		_ink(tu, 1.3, 1.25)
		_ink(tu_held, 0.8, 1.0)


func _ink(sh: Shader, width: float, thick: float) -> void:
	var q := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(2, 2)
	q.mesh = qm
	q.extra_cull_margin = 16384.0
	q.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var tm := ShaderMaterial.new()
	tm.shader = sh
	tm.set_shader_parameter("px", width)
	tm.set_shader_parameter("dick", thick)
	q.material_override = tm
	q.position = Vector3(0, 0, -1)
	cam.add_child(q)


## Die Lichtung (tools/blender348/kampfort_wald.py): Bäume, Büsche, Steine, Boden mit Weg und Sonnentupfen, Grasbüschel.
## Der Wald-Knoten liegt in der Kampfmitte, um 60° gedreht: örtlich x = zu den Gegnern (a), z = quer nach rechts (b).
var forest: Node3D

func _build_forest() -> void:
	forest = Node3D.new()
	forest.rotation.y = deg_to_rad(90.0 - AXIS)
	add_child(forest)
	var p := "res://kampf/daten/kampfort-wald.bin"
	if FileAccess.file_exists(p):
		var doc := GLTFDocument.new()
		var st := GLTFState.new()
		if doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", st) == OK:
			var n := doc.generate_scene(st) as Node3D
			_toon_all(n)
			forest.add_child(n)
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(140, 140)
	pm.subdivide_width = 8
	pm.subdivide_depth = 8
	ground.mesh = pm
	var gm := ShaderMaterial.new()
	gm.shader = load("res://kampf/wald_boden.gdshader")
	gm.set_shader_parameter("maske", _picture("wald-maske", Color(0, 0, 0, 0)))
	gm.set_shader_parameter("gras", _picture("gras", Color(0.30, 0.38, 0.20)))
	gm.set_shader_parameter("erde", _picture("erde", Color(0.42, 0.34, 0.24)))
	ground.material_override = gm
	ground.position.y = -0.01
	forest.add_child(ground)
	_grass()


func _toon_all(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(i)
			var m := ShaderMaterial.new()
			var rn: String = src.resource_name if src else ""
			# ferne Bäume ohne Tuschelinie: Schablone 1 wie Blüten (kampfort_wald.py FERN)
			m.shader = _inkless_toon() if rn.ends_with("_fern") else load("res://kampf/toon.gdshader")
			if src is BaseMaterial3D and (src as BaseMaterial3D).albedo_texture:
				m.set_shader_parameter("tex", (src as BaseMaterial3D).albedo_texture)
			else:
				m.set_shader_parameter("tex", _plain(Color.WHITE))
			if rn.begins_with("laub"):
				m.set_shader_parameter("sway", 1.0)
			mi.set_surface_override_material(i, m)
	for c in n.get_children():
		_toon_all(c)


var _inkless: Shader = null
func _inkless_toon() -> Shader:
	if _inkless == null:
		_inkless = Shader.new()
		var code: String = (load("res://kampf/toon.gdshader") as Shader).code
		_inkless.code = code.replace("render_mode cull_disabled, specular_disabled;", "render_mode cull_disabled, specular_disabled;\nstencil_mode write, compare_always, 1;")
	return _inkless


## A painted picture from tex.py (or the mask), stored as .bild so Godot does not import it.
func _picture(name: String, fallback: Color) -> Texture2D:
	var p := "res://kampf/daten/%s.bild" % name
	if FileAccess.file_exists(p):
		var img := Image.new()
		if img.load_png_from_buffer(FileAccess.get_file_as_bytes(p)) == OK:
			img.generate_mipmaps()
			return ImageTexture.create_from_image(img)
	return _plain(fallback)


## Grasbüschel wie Toms gebiet.gd (halm.gdshader), nur wo die Kamera hinsieht und nicht auf dem Weg.
func _grass() -> void:
	var mask := Image.new()
	var mp := "res://kampf/daten/wald-maske.bild"
	if not FileAccess.file_exists(mp) or mask.load_png_from_buffer(FileAccess.get_file_as_bytes(mp)) != OK:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 3487
	var xf: Array[Transform3D] = []
	var cu: Array[Color] = []
	var d := 15.0
	var cam_l := Vector2(-0.866 * d, 0.5 * d)
	var view := Vector2(0.866, -0.5)
	var side := Vector2(0.5, 0.866)
	var fwd := 8.0
	while fwd < 60.0:
		var half := 0.22 * fwd + 1.0
		var per := 5 if fwd < 30 else 2
		for k in int(half * 2.0 * per * 0.5):
			var q := cam_l + view * (fwd + rng.randf() * 0.5) + side * rng.randf_range(-half, half)
			var px := mask.get_pixel(clampi(int((q.x + 70.0) * 6.0), 0, mask.get_width() - 1), clampi(int((q.y + 70.0) * 6.0), 0, mask.get_height() - 1))
			if px.r > 0.3:
				continue
			var s := rng.randf_range(0.16, 0.34)
			var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s, s * rng.randf_range(0.75, 1.2), s))
			xf.append(Transform3D(b, Vector3(q.x, 0.0, q.y)))
			var g := rng.randf_range(0.85, 1.2) * (1.0 - px.b * 0.4)
			cu.append(Color(0.95 * g, 1.0 * g, 0.85 * g, 1))
		fwd += 0.5
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for a in [0.0, PI * 0.5]:
		var r := Vector3(cos(a), 0, sin(a)) * 0.5
		var quad := [-r, r, r + Vector3.UP, -r + Vector3.UP]
		var uv := [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
		for k in [0, 1, 2, 0, 2, 3]:
			st.set_normal(Vector3.UP)
			st.set_uv(uv[k])
			st.add_vertex(quad[k])
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = st.commit()
	mm.instance_count = xf.size()
	for i in xf.size():
		mm.set_instance_transform(i, xf[i])
		mm.set_instance_custom_data(i, cu[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var hm := ShaderMaterial.new()
	hm.shader = load("res://kampf/halm.gdshader")
	hm.set_shader_parameter("tex", _picture("halme", Color(0.34, 0.39, 0.24)))
	mmi.material_override = hm
	forest.add_child(mmi)


func _plain(c: Color) -> ImageTexture:
	var img := Image.create(4, 4, false, Image.FORMAT_RGB8)
	img.fill(c)
	return ImageTexture.create_from_image(img)


## The scene above the orders, in viewport pixels.
func scene_rect() -> Rect2:
	var vs := get_viewport().get_visible_rect().size
	var below: float = ui.panel_height() if ui else vs.y * 0.33
	return Rect2(0, 0, vs.x, maxf(vs.y - below, vs.y * 0.4))


# FightCamera: f from the old lens, the middle of the fight at MID of the scene, the horizon f·tan(PITCH) above it;
# a level camera with shifted lens, so upright things stay upright.
var f_px := 1.0
var d0 := 14.0
var eye := 6.0
var horizon_y := 0.0

func _fit_camera() -> void:
	var vs := get_viewport().get_visible_rect().size
	var sr := scene_rect()
	var w := sr.size.x
	var h := sr.size.y
	var u := w / 412.0
	f_px = (h * 0.72 - h * 0.40) / tan(deg_to_rad(15.0)) * LENS
	var mid_y := h * MID
	horizon_y = mid_y - f_px * tan(deg_to_rad(PITCH))
	var per_m0 := 120.0 * u / 1.75
	d0 = f_px / per_m0
	eye = d0 * tan(deg_to_rad(PITCH))
	cam.position = Vector3(0, eye, 0)
	cam.rotation = Vector3.ZERO
	cam.size = cam.near * vs.y / f_px
	cam.frustum_offset = Vector2(0, (horizon_y - vs.y / 2.0) * cam.near / f_px)
	if forest:
		forest.position = _ground(0, 0)
	for fig in figures.values():
		fig.snap_to(_spot_pos(fig.fighter, shown.places[fig.fighter.id]))


## Where (a, b) lies: a metres along the fight towards the foes, b across to the right (FightCamera.ground).
func _ground(a: float, b: float) -> Vector3:
	var ax := sin(deg_to_rad(AXIS))
	var ad := cos(deg_to_rad(AXIS))
	return Vector3(a * ax + b * ad, 0, -(d0 + a * ad - b * ax))


## The way a figure of [foe] faces, in the world.
func facing(foe: bool) -> Vector3:
	var ax := sin(deg_to_rad(AXIS))
	var ad := cos(deg_to_rad(AXIS))
	var d := Vector3(ax, 0, -ad)
	return -d if foe else d


## FightCamera.stand
func _stand(foe: bool, back: bool, slot: int, alone: bool) -> Vector2:
	var row := BACK_M if back else FRONT_M
	if not foe and back and not alone:
		return Vector2(-row - NEAR_M + 0.6, 0.6 + (-0.7 if slot == 0 else 0.7))
	var half := FOE_HALF_M if foe else HALF_M
	var b := (0.0 if foe else ALONE_HERO_B) if alone else (-half if slot == 0 else half)
	# Gegner vorn links ein Stück weiter weg: sonst stand der Kopf des Söldners zwischen seinen Vorderläufen (Prüfer Runde 8)
	if foe and not back and not alone and slot == 0:
		row += FOE_LEFT_BACK_M
		b -= FOE_LEFT_OUT_M
	return Vector2(row, b) if foe else Vector2(-row - NEAR_M, b)


func _spot_pos(f, spot: Vector2i) -> Vector3:
	var alone := _alone(f, spot.x)
	var ab := _stand(f.side == "FOES", spot.x == Mars.BACK, spot.y, alone)
	# a foe alone in the back behind two in front stands between and behind them, not hidden behind the right one
	# (SkirmishScreen.kt BACK_GAP_A, BACK_GAP_B, Build 89)
	if f.side == "FOES" and spot.x == Mars.BACK and alone and not _alone(null, Mars.FRONT, "FOES"):
		ab = Vector2(ab.x + BACK_GAP_A, BACK_GAP_B)
	return _ground(ab.x, ab.y)


func _alone(f, row: int, side := "") -> bool:
	var sd: String = f.side if f != null else side
	var n := 0
	for o in mars.fighters():
		if o != f and o.side == sd and shown.places.has(o.id) and shown.places[o.id].x == row and _present(o):
			n += 1
	return n == 0 if f != null else n <= 1


func _present(f) -> bool:
	return shown.hp.get(f.id, f.hp) > 0 or figures.has(f.id) and figures[f.id].falling()


## Screen point of a world position (for names, signs, the ring).
func screen_of(p: Vector3) -> Vector2:
	return cam.unproject_position(p)


func foe_scale(f) -> float:
	if f.monster == null:
		return 1.0
	return FOE_SIZE * (WOLF_SIZE if f.monster.id == Mars.WOLF else 1.0)


# ---------------------------------------------------------------- the rules' thread (ProbeRun)
func _post(b: Dictionary) -> void:
	beats_lock.lock()
	beats.append(b)
	beats_lock.unlock()


func _react(t, intent) -> String:
	_post({"ring": t.id, "intent": intent})
	ring_sem.wait()
	return ring_answer


func _run(block: Callable) -> void:
	busy = true
	ui.refresh()
	if worker and worker.is_started():
		worker.wait_to_finish()
	worker = Thread.new()
	worker.start(func():
		block.call()
		_post({"done": true}))


func order(o: Array) -> void:
	if busy or mars.outcome != "ONGOING":
		return
	_run(func(): mars.act(o, _react))


func go_on() -> void:
	if busy or mars.outcome != "ONGOING":
		return
	_run(func(): mars.proceed(_react))


func test_end(win: bool) -> void:
	if busy or mars.outcome != "ONGOING":
		return
	_run(func(): mars.test_end(win))


func tap() -> void:
	if not ring_open:
		return
	var off := absi(Time.get_ticks_msec() - (ring_start + RING_MS))
	_answer_ring(Mars.PERFECT if off <= PERFECT_MS else (Mars.GOOD if off <= GOOD_MS else Mars.NONE))


func _answer_ring(r: String) -> void:
	if not ring_open:
		return
	ring_open = false
	ring_answer = r
	ui.ring_verdict(r)
	ring_sem.post()


func _state_now() -> Dictionary:
	var hp := {}
	var places := {}
	var sp := {}
	for f in mars.fighters():
		hp[f.id] = f.hp
		places[f.id] = f.place
		sp[f.id] = f.sp
	return {"hp": hp, "places": places, "intents": mars.intents.duplicate(), "queue": mars.queue(), "sp": sp, "status": mars._statuses()}


# ---------------------------------------------------------------- playing the beats one after another
func _process(_dt: float) -> void:
	if ring_open and Time.get_ticks_msec() > ring_start + RING_MS + GOOD_MS + 60:
		_answer_ring(Mars.NONE)
	if playing:
		return
	beats_lock.lock()
	var b = beats.pop_front() if not beats.is_empty() else null
	beats_lock.unlock()
	if b == null:
		return
	playing = true
	if b.has("say"):
		await _play_say(b.say)
	elif b.has("ring"):
		await _play_ring(b.ring, b.intent)
	elif b.has("done"):
		_done()
	playing = false


func _play_say(e: Dictionary) -> void:
	var before: Dictionary = shown.hp
	shown = e
	for f in mars.fighters():
		# called to the fight (Rudel rufen); the rules' thread may already hold one this message does not know yet
		if not figures.has(f.id) and e.places.has(f.id):
			var fig := Figur.new()
			fig.setup(f, self)
			add_child(fig)
			figures[f.id] = fig
			fig.snap_to(_spot_pos(f, e.places[f.id]) + facing(true) * -3.0)
	if e.text != "":
		ui.log_line(e.text)
	var actor = e.actor
	var target = e.target
	var by = mars.find(actor) if actor != null else null
	var tg = mars.find(target) if target != null else null
	var across: bool = by != null and tg != null and actor != target and by.side != tg.side
	var lunge_ms := 0
	if across and (e.roll != null or e.spell != null or e.cue == "DUCKED"):
		lunge_ms = figures[actor].strike(figures[target], e)
	for id in e.intents:
		var aimed: Array = e.intents[id][1]
		figures[id].announce(e.intents[id][0], figures.get(aimed[0]) if aimed.size() > 0 else null)
	for id in figures:
		if not e.intents.has(id):
			figures[id].announce(null)
	if e.cue == "POUNCED" and target != null:
		figures[target].knocked_down()
	elif e.cue == "RISES" and actor != null:
		figures[actor].rise()
	elif e.cue == "CIRCLE" and actor != null:
		figures[actor].howl()
	var lands := int(lunge_ms * 0.42)
	for id in e.hp:
		if not figures.has(id):
			continue
		var was: int = before.get(id, e.hp[id])
		if e.hp[id] < was:
			figures[id].hurt(lands, e.hp[id] <= 0)
		elif target == id and e.roll != null and not e.roll[4] and across:
			figures[id].dodge(lands)
	for f in mars.fighters():
		if figures.has(f.id) and e.places.has(f.id):
			figures[f.id].glide_to(_spot_pos(f, e.places[f.id]))
	ui.refresh()
	ui.show_roll(e)
	await get_tree().create_timer(maxf(SAY_MS, lunge_ms) / 1000.0).timeout


func _play_ring(target_id: String, intent: Dictionary) -> void:
	ring_for = target_id
	ring_start = Time.get_ticks_msec()
	ring_open = true
	ui.ring_open(target_id, intent)
	while ring_open:
		await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	ui.ring_close()


func _refused() -> void:
	if on_end.is_valid():
		on_end.call("NONE")
	queue_free()


func _done() -> void:
	shown.queue = mars.queue()
	busy = false
	if mars.outcome == "WON" and reward.is_empty():
		reward = Lohn.reward(mars, int(progress.get("xp", 0)), mars.dice, int(progress.get("over", 0)), progress.get("cap"))
	if mars.outcome == "ONGOING" and mars.pilot_next():
		go_on()
	ui.refresh()


func again() -> void:
	var fn := again_fn
	queue_free()
	if fn.is_valid():
		fn.call()


func finish() -> void:
	if mars == null:
		return
	if on_end.is_valid():
		on_end.call(mars.outcome)
	queue_free()
