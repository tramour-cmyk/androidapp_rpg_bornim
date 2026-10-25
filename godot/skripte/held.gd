class_name Held
extends Node3D
# 348.6: der Held aus tools/blender348/v3 (held.glb in Metern, Skelett, Gehen/Stehen, gebackene Textur) mit Fackel;
# geht einen Weg aus Kachelmitten (Tippen) oder in eine Richtung (Joystick), stoesst nirgends durch (Karte.begehbar).
# Tempo wie im alten Spiel (FreeWalk.WALK/RUN, Terrain.stepFactor); Gehen wird so schnell abgespielt, dass nichts gleitet.

signal steht_auf(kachel: Vector2i)
signal stoesst(kachel: Vector2i)       # will auf eine Kachel, die sperrt (Game.move: Move.Blocked)

const RAND := 0.3                      # Meter: so nah kommt die Koerpermitte an Unbegehbares

var karte: Karte
var modell: Node3D
var anim: AnimationPlayer
var gang := 1.08                       # m/s, mit denen „Gehen“ ohne Gleiten laeuft (held-info.json)
var weg: Array[Vector3] = []
var richtung := Vector3.ZERO           # Joystick, Laenge 0..1
var laeuft := false
var fackel: OmniLight3D
var flamme: MeshInstance3D
var fackel_sitzt := false
var kachel := Vector2i(-1, -1)
var zeit := 0.0
var gestossen := Vector2i(-1, -1)
var stoss_zeit := -9.0

func _init(k: Karte) -> void:
	karte = k
	name = "Held"

func _ready() -> void:
	modell = Gebiet.lade_glb("res://daten/held.bin")
	add_child(modell)
	Gebiet.male(modell, null, 2, mats)
	var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/held-info.json"))
	gang = float(info.get("gehen_m_je_s", gang))
	anim = Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	for n in ["Gehen", "Stehen"]:
		if anim and anim.has_animation(n): anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
	if anim: anim.play("Stehen")
	baue_fackel()

func setze(t: Vector2i, blick := "DOWN") -> void:
	position = karte.kachel_pos(t)
	rotation.y = {"UP": PI, "DOWN": 0.0, "LEFT": -PI / 2, "RIGHT": PI / 2}.get(blick, 0.0)
	weg.clear()
	kachel = t
	steht_auf.emit(t)

func geh_zu(ziel: Vector3) -> void:
	var b := karte.pos_kachel(ziel)
	var ids := karte.weg(karte.pos_kachel(position), b)
	weg.clear()
	if ids.is_empty(): return
	for k in range(1, ids.size()): weg.append(karte.kachel_pos(ids[k]))
	if weg.is_empty(): weg.append(karte.kachel_pos(b))

func frei(p: Vector3) -> bool:
	return karte.begehbar(karte.pos_kachel(p))

func _process(dt: float) -> void:
	zeit += dt
	if not fackel_sitzt and zeit > 0.2: richte_fackel()
	var dir := Vector3.ZERO
	if richtung.length() > 0.15:
		dir = richtung
		weg.clear()
	elif weg.size() > 0:
		var to := weg[0] - position
		to.y = 0
		if to.length() < 0.06:
			position = Vector3(weg[0].x, position.y, weg[0].z)
			weg.pop_front()
		else:
			dir = to.normalized()
	var moving := dir.length() > 0.05
	var vorher := position
	var tempo := 0.0
	if moving:
		var kps := karte.laufen if laeuft else karte.gehen
		tempo = kps * Karte.TS / karte.schritt(karte.pos_kachel(position)) * clampf(dir.length(), 0.5, 1.0)
		# in kleinen Stuecken, damit ein langes Bild (dt gross) nicht ueber Kanten springt oder zu frueh anstoesst
		var d := dir.normalized()
		var rest := tempo * dt
		if weg.size() > 0 and richtung.length() <= 0.15: rest = minf(rest, Vector2(weg[0].x - position.x, weg[0].z - position.z).length())
		while rest > 1e-4:
			var step := d * minf(rest, 0.08)
			rest -= step.length()
			var np := position + step
			if frei(np) and frei(np + d * RAND):
				position = np
			elif absf(step.x) > 1e-5 and frei(position + Vector3(step.x + signf(step.x) * RAND, 0, 0)):
				position.x += step.x
			elif absf(step.z) > 1e-5 and frei(position + Vector3(0, 0, step.z + signf(step.z) * RAND)):
				position.z += step.z
			else:
				weg.clear()
				var vor := karte.pos_kachel(position + d * (RAND + 0.05))
				if vor != gestossen or zeit - stoss_zeit > 2.0:
					gestossen = vor; stoss_zeit = zeit
					stoesst.emit(vor)
				break
		rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), minf(1.0, dt * 12.0))
	if anim:
		# Runde 4 (5): gegen Schlagbaum oder Wand (Text offen) stand der Held in Gehhaltung: nur gehen, wenn er vorankommt
		if moving and (position - vorher).length() < tempo * dt * 0.2: moving = false
		var want := "Gehen" if moving else "Stehen"
		if anim.current_animation != want: anim.play(want, 0.18)
		anim.speed_scale = tempo / gang if moving else 1.0
	var k := karte.pos_kachel(position)
	if k != kachel:
		kachel = k
		steht_auf.emit(k)
	if fackel: fackel.light_energy = fackel_kraft * (0.88 + 0.12 * sin(zeit * 17.0) * sin(zeit * 7.3))
	if flamme: flamme.scale = Vector3(1.0, 1.0 + 0.18 * sin(zeit * 13.0) * sin(zeit * 5.1), 1.0)

func geht() -> bool:
	return weg.size() > 0 or richtung.length() > 0.15

# ---------------------------------------------------------------- Fackel (nachts), am Handgelenk rechts
var fackel_kraft := 0.0

var mats: Array = []   # Held im Schatten nicht nur Umriss (Probe Build 11), nachts nicht (sonst leuchtet er)

func nacht(k: float) -> void:
	fackel_kraft = 2.2 * k
	for m in mats: (m as ShaderMaterial).set_shader_parameter("fill", 0.42 * (1.0 - k))
	if fackel:
		fackel.visible = k > 0.02
		flamme.visible = k > 0.02

func baue_fackel() -> void:
	var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
	if sk == null: return
	var ba := BoneAttachment3D.new()
	ba.bone_name = "foR-wrR"
	sk.add_child(ba)
	var t := Node3D.new()
	t.name = "Fackel"
	ba.add_child(t)
	var stiel := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.022; cm.bottom_radius = 0.016; cm.height = 0.52
	stiel.mesh = cm
	var wm := StandardMaterial3D.new()
	wm.albedo_color = Color(0.42, 0.28, 0.16)
	stiel.material_override = wm
	stiel.position = Vector3(0, 0.12, 0)
	t.add_child(stiel)
	flamme = MeshInstance3D.new()
	var fm := CylinderMesh.new()
	fm.top_radius = 0.0; fm.bottom_radius = 0.055; fm.height = 0.2; fm.radial_segments = 10; fm.rings = 1
	flamme.mesh = fm
	var em := StandardMaterial3D.new()
	em.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	em.albedo_color = Color(1.0, 0.62, 0.18)
	em.emission_enabled = true
	em.emission = Color(1.0, 0.42, 0.08)
	em.emission_energy_multiplier = 3.0
	flamme.material_override = em
	flamme.position = Vector3(0, 0.46, 0)
	t.add_child(flamme)
	fackel = OmniLight3D.new()
	fackel.position = Vector3(0, 0.6, 0)
	fackel.light_color = Color(1.0, 0.72, 0.38)
	fackel.omni_range = 8.0
	fackel.omni_attenuation = 2.0
	t.add_child(fackel)
	nacht(0.0)

func richte_fackel() -> void:
	# einmal, wenn die Pose steht: Fackel senkrecht in die Faust, danach dreht sie mit dem Arm
	var t := find_child("Fackel", true, false) as Node3D
	if t == null:
		fackel_sitzt = true
		return
	var ba := t.get_parent() as Node3D
	t.global_basis = Basis(Vector3.UP, rotation.y).rotated(global_basis.x.normalized(), deg_to_rad(-12))
	t.global_position = ba.global_position + Vector3(0, -0.07, 0)
	fackel_sitzt = true
