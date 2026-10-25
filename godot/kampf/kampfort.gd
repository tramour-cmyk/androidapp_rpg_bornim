# 348.7 (Umzug Godot): der Kampfort von MARS. Vorgabe ist der heutige Kampfschirm (app SkirmishScreen.kt, core FightCamera.kt):
# eine Kamera aus 25° von oben, die Kampflinie 30° nach rechts, die Helden vorn links, die Gegner hinten rechts in zwei
# Reihen; darunter Kampfbericht, Lebensbalken und Knöpfe; der Ring beim angesagten Schlag. Die Regeln laufen in einem
# eigenen Faden (wie ProbeRun), der Schirm spielt ihre Meldungen nacheinander ab.
# Aufruf: Kampfort.new(party, foes, tables, potions, rueckkehr) als Kind eines Knotens; rueckkehr(outcome) am Ende.
extends Node3D

const Mars = preload("res://regeln/mars.gd")
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
const NEAR_M := 1.0
const ALONE_HERO_B := 0.35
const FOE_SIZE := 1.5
const WOLF_SIZE := 0.88
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


func setup(party: Array, foes: Array, p_tables: Dictionary, potions: Dictionary, p_on_end: Callable, seed := -1) -> void:
	tables = p_tables
	on_end = p_on_end
	var dice = Wuerfel.new(null if seed < 0 else seed)
	var words = Wuerfel.new(null if seed < 0 else seed + 279)
	mars = Mars.new(party, foes, tables, dice, words, lang, false)
	for k in potions:
		mars.potions[k] = int(potions[k])
	mars.listener = func(e): _post({"say": e})


func _ready() -> void:
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
	env.background_color = Color(0.10, 0.13, 0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.60, 0.62)
	env.ambient_light_energy = 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color(0.12, 0.15, 0.11)
	env.fog_density = 0.035
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 25, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 30.0
	sun.light_energy = 1.2
	sun.light_color = Color(1.0, 0.94, 0.82)
	add_child(sun)
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(80, 80)
	ground.mesh = pm
	var gm := ShaderMaterial.new()
	gm.shader = load("res://kampf/toon.gdshader")
	gm.set_shader_parameter("tex", _plain(Color(0.30, 0.34, 0.20)))
	ground.material_override = gm
	ground.position = _ground(0, 0) + Vector3(0, -0.01, 0)
	add_child(ground)
	cam = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_FRUSTUM
	cam.near = 0.1
	cam.far = 120.0
	add_child(cam)
	var q := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(2, 2)
	q.mesh = qm
	q.extra_cull_margin = 16384.0
	q.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var tm := ShaderMaterial.new()
	tm.shader = load("res://kampf/tusche.gdshader")
	q.material_override = tm
	q.position = Vector3(0, 0, -1)
	cam.add_child(q)


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
	var b := (0.0 if foe else ALONE_HERO_B) if alone else (-HALF_M if slot == 0 else HALF_M)
	return Vector2(row, b) if foe else Vector2(-row - NEAR_M, b)


func _spot_pos(f, spot: Vector2i) -> Vector3:
	var alone := true
	for o in mars.fighters():
		if o != f and o.side == f.side and shown.places.has(o.id) and shown.places[o.id].x == spot.x and _present(o):
			alone = false
	var ab := _stand(f.side == "FOES", spot.x == Mars.BACK, spot.y, alone)
	return _ground(ab.x, ab.y)


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
	return {"hp": hp, "places": places, "intents": mars.intents.duplicate(), "queue": mars.queue(), "sp": sp}


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
		figures[id].announce(e.intents[id][0])
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


func _done() -> void:
	shown.queue = mars.queue()
	busy = false
	if mars.outcome == "ONGOING" and mars.pilot_next():
		go_on()
	ui.refresh()


func again() -> void:
	var fn := again_fn
	queue_free()
	if fn.is_valid():
		fn.call()


func finish() -> void:
	if on_end.is_valid():
		on_end.call(mars.outcome)
	queue_free()
