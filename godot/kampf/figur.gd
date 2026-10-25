# 348.7: eine Figur am Kampfort: Modell (Wolf aus tools/blender348/wolf.py, Held aus rig.py), Platz, Bewegungen zu den
# Meldungen: Stehen, Hocke beim angesagten Sprung, Sprung oder Biss zum Ziel und zurück, Treffer, Ausweichen, Sturz, Tod.
extends Node3D

const Mars = preload("res://regeln/mars.gd")
# Schlagzeiten (SkirmishScreen.kt): Biss eines Tiers mit Anlauf 1,0 s, Hieb 0,8 s, Stich 0,6 s
const BEAST_LUNGE_MS := 1000
const BLOW_MS := 800
const STAB_MS := 600
const GLIDE_S := 0.4
const FALL_MS := 900
const FADE_MS := 600
const WOLF_COATS := ["grau", "dunkel", "rost", "asche"]
## 348.9 Entwurf: ERSATZ=boar zeigt das Wolfsrudel mit einem anderen Vierbeiner (Modell und Größe, Regeln bleiben die des Wolfs)
const ERSATZ_FELLE := {"boar": ["dunkel", "grau", "rost"], "giant_rat": ["braun", "grau", "schwarz"]}
## Bewegungen eines Vierbeiners, die beim Wolf anders heißen (wildschwein.py: Hauerstoß statt Biss, Rammen statt Sprung)
const ALIAS := {"Biss": "Hauer", "Sprung": "Ansturm", "Lefzen": "Schnauben", "Heulen": "Drohen"}
# Chef 25.10., 08:57 (2): halb seitlich (−35°) sah er aus, als wolle er weglaufen; jetzt fast zum Gegner
const WOLF_TURN := -12.0

var fighter
var kampfort
var model: Node3D
var anim: AnimationPlayer
var home := Vector3.ZERO
var pouncing := false
var dead_at := -1
var down := false
var mats: Array = []
var tween: Tween
var aim = null          # Figur, die das Tier laut Ansage angreift; Kopf und Rumpf zeigen dorthin
var neck = null         # kopfdreh.gd am Skelett
var fidget_at := 0      # Chef 08:57 (8): in Ruhe ab und zu Lefzen zeigen oder scharren (ms)
var paws: Array = []    # Runde 14: Kontaktschatten je Pfote [Knochen, Länge, Fleck]


func setup(f, k) -> void:
	fighter = f
	kampfort = k
	model = _load_model()
	add_child(model)
	model.scale = Vector3.ONE * _scale()
	if fighter.monster == null:
		_arm()
	else:
		var sk: Skeleton3D = _find(model, "Skeleton3D")
		if sk:
			neck = preload("res://kampf/kopfdreh.gd").new()
			sk.add_child(neck)
	_face()
	_idle()
	_ground_shadow()
	# Prüfschalter GLUEH=1: Gegner leuchten, damit der Prüflauf ihre Bildpunkte vom Hintergrund trennt (Helligkeit messen)
	if OS.has_environment("GLUEH") and fighter.monster != null:
		for m in mats:
			m.set_shader_parameter("glow", 1.0)


## Weicher Bodenschatten unter der Figur wie im alten Kampf (Prüfer Stand 9: Wölfe schweben); der Schlagschatten der hohen
## Sonne fällt fast ganz unter den Körper. Ohne Tiefe, darum ohne Tusche; folgt der Figur (Kind), bleibt beim Sprung am Boden.
static var shadow_shader: Shader

func _ground_shadow() -> void:
	if shadow_shader == null:
		shadow_shader = Shader.new()
		shadow_shader.code = """shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
uniform float dichte = 0.78;
void fragment() {
	float r = length(UV - 0.5) * 2.0;
	ALBEDO = vec3(0.02, 0.03, 0.01);
	ALPHA = dichte * (1.0 - smoothstep(0.45, 1.0, r));     // Prüfer: im alten Bild deutlich dunkler
}"""
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	var wolf: bool = fighter.monster != null and fighter.monster.id == Mars.WOLF
	# Wolf: Rumpf 1,1 m lang, 0,4 m breit (mal Größe); Mensch: 0,7 m rund
	# Runde 15 (Prüfer Runde 14: Pfotenschatten „unsichtbar im Rumpfschatten“): schmaler (0,7 statt 1,0), die Pfoten stehen am weichen Rand
	pm.size = Vector2(0.7, 1.5) * _scale() if wolf else Vector2(0.95, 0.95)
	mi.mesh = pm
	var m := ShaderMaterial.new()
	m.shader = shadow_shader
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = Vector3(0, 0.02, 0.15 * _scale() if wolf else 0.0)     # Rumpfmitte des Wolfs liegt 0,15 m vor dem Ursprung
	mi.name = "Bodenschatten"
	add_child(mi)
	if wolf and OS.get_environment("PFOTENSCHATTEN") != "0":     # Prüflauf: PFOTENSCHATTEN=0 ohne
		_paw_shadows()


## Runde 14 (Prüfer Runde 13: „kein Kontaktschatten unter den Pfoten“, der weiche Fleck liegt nur unter dem Rumpf): ein kleiner
## dunkler Fleck unter jeder Pfote, folgt dem Knochen und blasst aus, wenn die Pfote sich hebt (Scharren, Sprung).
const PAW_BONES := {"vpfoteL": 0.135, "vpfoteR": 0.135, "hpfoteL": 0.19, "hpfoteR": 0.19}

func _paw_shadows() -> void:
	var sk: Skeleton3D = _find(model, "Skeleton3D")
	if sk == null:
		return
	for b in PAW_BONES:
		var i := sk.find_bone(b)
		if i < 0:
			continue
		var mi := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = Vector2(0.26, 0.32) * _scale()     # Runde 15: der Fleck direkt unter der Pfote ist von oben von ihr verdeckt; als Rand um sie herum sichtbar (0,11 × 0,14 rot gemessen: etwa 115 Bildpunkte je Pfote)
		mi.mesh = pm
		var m := ShaderMaterial.new()
		m.shader = shadow_shader
		m.set_shader_parameter("dichte", 0.0)
		mi.material_override = m
		if OS.get_environment("PFOTENSCHATTEN") == "rot":     # Prüflauf: Pfotenschatten rot
			var rot := StandardMaterial3D.new(); rot.albedo_color = Color.RED; rot.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mi.material_override = rot
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.top_level = true
		mi.name = "Pfotenschatten"
		add_child(mi)
		paws.append([sk, i, PAW_BONES[b], mi])


func _paw_shadow_update() -> void:
	for pw in paws:
		var sk: Skeleton3D = pw[0]
		var g: Transform3D = sk.global_transform * sk.get_bone_global_pose(pw[1])
		var tip: Vector3 = g.origin + g.basis.y.normalized() * pw[2] * _scale()
		var h: float = tip.y - global_position.y
		var mi: MeshInstance3D = pw[3]
		mi.global_transform = Transform3D(Basis(Vector3.UP, rotation.y), Vector3(tip.x, global_position.y + 0.025, tip.z))
		mi.visible = not down and dead_at < 0
		if mi.material_override is ShaderMaterial:
			(mi.material_override as ShaderMaterial).set_shader_parameter("dichte", 0.95 * clampf(1.0 - (h - 0.03) / 0.12, 0.0, 1.0))


func _scale() -> float:
	if fighter.monster == null:
		return 0.01     # held.glb der Probe ist in Zentimetern; Meter liefert Tom mit 348.6 (Modellregel 1)
	return kampfort.foe_scale(fighter)


func _model_path() -> String:
	if fighter.monster == null:
		return "res://kampf/daten/held.bin"
	if fighter.monster.id == Mars.WOLF:
		var n: int = maxi(fighter.nr, 1) - 1
		var ersatz := OS.get_environment("ERSATZ")
		if ERSATZ_FELLE.has(ersatz):
			return "res://kampf/daten/%s-%s.bin" % [ersatz, ERSATZ_FELLE[ersatz][n % ERSATZ_FELLE[ersatz].size()]]
		return "res://kampf/daten/wolf-%s.bin" % WOLF_COATS[n % WOLF_COATS.size()]
	return "res://kampf/daten/%s.bin" % fighter.monster.id


func _load_model() -> Node3D:
	var p := _model_path()
	if FileAccess.file_exists(p):
		var doc := GLTFDocument.new()
		var st := GLTFState.new()
		if doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", st) == OK:
			# Runde 15: unveränderliche Spuren behalten; sonst fehlten im Scharren die ruhenden Knochen (rechter Vorderlauf) und blieben
			# in der Haltung der vorigen Bewegung stehen (Prüfer: „Hasensprung“, zweite Vorderpfote in der Luft)
			var n := doc.generate_scene(st, 30.0, false, false) as Node3D
			_paint(n)
			anim = _find(n, "AnimationPlayer") as AnimationPlayer
			if anim:
				for a in ["Stehen", "Gehen", "Hocke"]:
					if anim.has_animation(a):
						anim.get_animation(a).loop_mode = Animation.LOOP_LINEAR
			return n
	# noch ohne Modell (Goblin, Spinne …): ein Körper in der Größe, damit der Ablauf sichtbar bleibt
	var mi := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.3
	cm.height = 1.5
	mi.mesh = cm
	mi.position.y = 0.75
	var m := _toon(Color(0.35, 0.3, 0.25))
	mi.material_override = m
	mats.append(m)
	var root := Node3D.new()
	root.add_child(mi)
	return root


# Waffe und Schild an den Händen (Modellregel 4): Startausrüstung je Klasse wie Hero.create; die Waffe aus dem Bogen
# (main.id), sonst die der Klasse. Griff in der Handfläche (held3.py hand(): Handmitte 3,6 cm hinter dem Handgelenk,
# Unterarmknochen fo-wr 12,1 cm, Finger um die Achse vorn-hinten gekrümmt), also liegt der Griff vorn-hinten in der Hand.
const OFF_HAND := {"FIGHTER": "shield", "CLERIC": "round_shield"}
const GRIP_CM := 15.7
const PALM_CM := 2.4
const STAFFS := ["quarterstaff", "staff"]

func _arm() -> void:
	var sk := _find(model, "Skeleton3D") as Skeleton3D
	if sk == null:
		return
	var main: String = fighter.hero.main.id if fighter.hero.has("main") and not fighter.hero.main.ranged else ""
	if main != "":
		_hold(sk, "R", main)
	var off: String = OFF_HAND.get(fighter.hero.get("cls", ""), "")
	if off != "":
		_hold(sk, "L", off)


## Hangs [what] (a .glb in metres, grip at its origin) on the forearm of [side]; the model is in centimetres (held.glb).
func _hold(sk: Skeleton3D, side: String, what: String) -> void:
	var p := "res://kampf/daten/%s.bin" % what
	var bi := sk.find_bone("fo%s-wr%s" % [side, side])
	if bi < 0 or not FileAccess.file_exists(p):
		return
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	if doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", st) != OK:
		return
	var w := doc.generate_scene(st) as Node3D
	_paint(w)
	var at := BoneAttachment3D.new()
	at.bone_name = sk.get_bone_name(bi)
	sk.add_child(at)
	at.add_child(w)
	# directions of the figure (+Z forward, +Y up, inward to the body) in the bone's own space
	# in the pose it stands in (Stehen), not the rest pose: the hanging arm turns the forearm (Prüfer: Klinge 40° nach oben)
	var rest := sk.get_bone_global_pose(bi).basis.orthonormalized().inverse()
	var down := rest * Vector3.DOWN
	var fwd := rest * Vector3.BACK
	var inward := rest * (Vector3.RIGHT if side == "R" else Vector3.LEFT)
	var b: Basis
	var o: Vector3
	if what.contains("shield"):
		# Schild am Unterarm außen: Vorderseite nach außen, oben nach oben, die Fessel um den Unterarm
		b = Basis(fwd, -down, -inward)
		o = Vector3(0, GRIP_CM * 0.35, 0) - inward * 4.0
	elif what in STAFFS:
		# Stab senkrecht neben dem Körper, in der Mitte gefasst
		b = Basis(fwd, -down, fwd.cross(-down))
		o = Vector3(0, GRIP_CM, 0) + inward * PALM_CM
	else:
		# Klinge wie die alte Bereitschaft (HeroFigure.READY weapon = 0,2 außen, 0,85 oben, 0,45 vorn), Schneide vorn und hinten;
		# nie waagerecht nach vorn auf Hüfthöhe (DESIGN-ABNAHME, Silhouetten)
		var ax := (-inward * 0.2 - down * 0.85 + fwd * 0.45).normalized()
		var edge := (fwd - ax * fwd.dot(ax)).normalized()
		b = Basis(edge, ax, edge.cross(ax))
		o = Vector3(0, GRIP_CM, 0) + inward * PALM_CM
	w.transform = Transform3D(b.scaled(Vector3.ONE * 100.0), o)
	w.name = "Waffe" if side == "R" else "Schild"


# Schablone wie Toms gebiet.gd toon_mark: 2 = Held, Söldner und ihre Waffen mit feinerer Tusche (Prüfer Stand 7: Tusche frass
# Stab, Klinge und Schild), im Schatten aufgehellt wie held.gd (fill 0,42 am Tag)
static var marked: Shader

static func toon_mark() -> Shader:
	if marked == null:
		var toon: Shader = load("res://kampf/toon.gdshader")
		marked = Shader.new()
		marked.code = toon.code.replace("render_mode cull_disabled, specular_disabled;", "render_mode cull_disabled, specular_disabled;\nstencil_mode write, compare_always, 2;")
	return marked


func _toon(c: Color) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	if fighter != null and fighter.side == "PARTY":
		m.shader = toon_mark()
		m.set_shader_parameter("fill", 0.42)
	else:
		m.shader = load("res://kampf/toon.gdshader")
	var img := Image.create(4, 4, false, Image.FORMAT_RGB8)
	img.fill(c)
	m.set_shader_parameter("tex", ImageTexture.create_from_image(img))
	m.set_shader_parameter("glow_col", Color(0.9, 0.1, 0.05))
	return m


func _paint(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(i)
			var tex: Texture2D = null
			if src is BaseMaterial3D:
				tex = (src as BaseMaterial3D).albedo_texture
			var m := _toon(Color.WHITE)
			if tex:
				m.set_shader_parameter("tex", tex)
			mi.set_surface_override_material(i, m)
			mats.append(m)
	for c in n.get_children():
		_paint(c)


func _find(n: Node, cls: String) -> Node:
	if n.get_class() == cls:
		return n
	for c in n.get_children():
		var r := _find(c, cls)
		if r:
			return r
	return null


func _face(dir := Vector3.ZERO) -> void:
	var d: Vector3 = dir if dir != Vector3.ZERO else kampfort.facing(fighter.side == "FOES")
	# Wölfe in Ruhe halb seitlich wie im alten Bild: von vorn verkürzt las sich der Rumpf als Buckel ohne Hals (Prüfer Runde 10)
	var look := 0.0
	if dir == Vector3.ZERO and fighter.monster != null and fighter.monster.id == Mars.WOLF:
		var turn: float = float(OS.get_environment("WOLFDREH")) if OS.has_environment("WOLFDREH") else WOLF_TURN
		if aim != null and is_instance_valid(aim) and not aim.down and aim.dead_at < 0:
			# Mit Ziel: Rumpf zum Ziel, aber nur im Bereich, in dem die Kamera ihn halb seitlich sieht (zur Kamera hin gedreht
			# las er sich frontal als Säule ohne Hals, Prüfer Runde 12); den Rest dreht der Hals, so blickt jeder auf sein Ziel
			var to: float = rad_to_deg(d.signed_angle_to(aim.position - position, Vector3.UP))
			var body := clampf(to, turn - 20.0, turn + 20.0)
			look = to - body
			turn = body
		d = d.rotated(Vector3.UP, deg_to_rad(turn))
	if neck:
		neck.want = look
	rotation.y = atan2(d.x, d.z)


## Runde 16 (Prüfer Runde 15: beim schwarzen kreuzte der gehobene Lauf das Standbein): scharren mit dem Vorderlauf, der der Kamera
## näher ist (Modell: links = +X); der ferne lag von hier aus vor dem nahen
func scharren_name() -> String:
	var cam := get_viewport().get_camera_3d()
	if cam == null or anim == null or not anim.has_animation("ScharrenR"):
		return "Scharren"
	var local := global_transform.basis.inverse() * (cam.global_position - global_position)
	return "Scharren" if local.x > 0.0 else "ScharrenR"


func _play(name: String, blend := 0.15) -> void:
	if anim and not anim.has_animation(name):
		name = ALIAS.get(name, name)
	if anim and anim.has_animation(name):
		anim.play(name, blend)


func _idle() -> void:
	if down:
		return
	_play("Hocke" if pouncing else "Stehen")


# Prüfer Runde 25: Blick und Rumpf wurden nur bei der Ansage gerichtet; rückte das Ziel danach auf seinen Platz, sah der Wolf
# daneben (Hals 52° bei Ziel 35°). In Ruhe darum jedes Bild neu.
func _process(_dt: float) -> void:
	if not paws.is_empty():
		_paw_shadow_update()
	if aim != null and neck and not down and not (tween and tween.is_running()):
		_face()
	if anim and anim.has_animation("Lefzen") and not down and not pouncing and anim.current_animation == "Stehen":
		var now := Time.get_ticks_msec()
		if fidget_at == 0:
			fidget_at = now + randi_range(4000, 9000)
		elif now >= fidget_at:
			fidget_at = 0
			_play("Lefzen" if randf() < 0.5 else scharren_name(), 0.2)
			anim.queue("Stehen")


func snap_to(p: Vector3) -> void:
	home = p
	position = p


func glide_to(p: Vector3) -> void:
	if p.is_equal_approx(home):
		return
	home = p
	if tween and tween.is_running():
		return     # a lunge brings it back to its new home
	var t := create_tween()
	t.tween_property(self, "position", p, GLIDE_S).set_trans(Tween.TRANS_SINE)


## Ground under the figure where no grass grows (halm.gdshader spots): x, z, radius.
func grass_spot() -> Vector3:
	var wolf: bool = fighter.monster != null and fighter.monster.id == Mars.WOLF
	var c := to_global(Vector3(0, 0, 0.15 * _scale() if wolf else 0.0))
	return Vector3(c.x, c.z, 0.5 * _scale() if wolf else 0.3)


func falling() -> bool:
	return dead_at >= 0 and Time.get_ticks_msec() - dead_at < FALL_MS + FADE_MS


## The announced intent (or none): a wolf about to pounce crouches.
func announce(intent, at = null) -> void:
	var p: bool = intent != null and intent.effect == "POUNCE"
	var turned: bool = at != aim
	aim = at
	if turned and not (tween and tween.is_running()):
		_face()
	if p != pouncing:
		pouncing = p
		_idle()


## A blow, bite, shot or spell at [other]; returns how long it takes (ms).
func strike(other, e: Dictionary) -> int:
	var spell: bool = e.spell != null
	var ranged: bool = fighter.ranged()
	if spell or ranged:
		_face(other.position - position)
		_play("Ausholen")
		get_tree().create_timer(0.6).timeout.connect(func(): _face(); _idle())
		return 700
	var leap: bool = fighter.monster != null and pouncing and fighter.monster.id == Mars.WOLF
	var ms := BEAST_LUNGE_MS if fighter.monster != null else BLOW_MS
	var to: Vector3 = other.position
	var reach := (to - position) * (0.8 if leap else 0.6)
	var there := position + reach
	_face(to - position)
	_play("Sprung" if leap else ("Biss" if fighter.monster != null else "Hieb"), 0.05)
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position", there, ms * 0.42 / 1000.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(ms * 0.16 / 1000.0)
	tween.tween_callback(func(): _face(home - position))
	tween.tween_property(self, "position", home, ms * 0.42 / 1000.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): _face(); _idle())
	if leap:
		pouncing = false
	return ms


func hurt(after_ms: int, dies: bool) -> void:
	await get_tree().create_timer(after_ms / 1000.0).timeout
	for m in mats:
		m.set_shader_parameter("glow", 1.2)
	get_tree().create_timer(0.18).timeout.connect(func():
		for m in mats:
			m.set_shader_parameter("glow", 0.0))
	if dies:
		die()
	else:
		_play("Treffer", 0.05)
		get_tree().create_timer(0.45).timeout.connect(_idle)


func dodge(after_ms: int) -> void:
	await get_tree().create_timer(after_ms / 1000.0).timeout
	_play("Ausweichen", 0.05)
	get_tree().create_timer(0.45).timeout.connect(_idle)


func die() -> void:
	down = true
	dead_at = Time.get_ticks_msec()
	if anim and anim.has_animation("Tod"):
		anim.play("Tod", 0.05)
	else:
		var t := create_tween()
		t.tween_property(model, "rotation:z", deg_to_rad(80), FALL_MS / 1000.0)
	if fighter.side == "FOES":
		# MARS: eigene Sterbebilder, dann ausgeblendet (LISTE-MARS.md)
		await get_tree().create_timer((FALL_MS + FADE_MS) / 1000.0).timeout
		visible = false


func knocked_down() -> void:
	_play("Sturz" if anim and anim.has_animation("Sturz") else "Treffer", 0.1)


func rise() -> void:
	_play("Aufstehen" if anim and anim.has_animation("Aufstehen") else "Stehen", 0.2)


func howl() -> void:
	_play("Heulen", 0.1)
	get_tree().create_timer(1.4).timeout.connect(_idle)


## Where to put the name and bar above the figure (world).
func head() -> Vector3:
	var h := 1.12 if fighter.monster != null and fighter.monster.id == Mars.WOLF else 1.9     # Ohrspitzen des Wolfs (0,9 lag seit den größeren Ohren, Runde 1 nach Chef, unter dem Balken; davor 60 px darüber)
	return position + Vector3(0, h * (_scale() if fighter.monster != null else 1.0), 0)
