# 1215 (Chef 13.11., 16:17 und 16:25 zu 1141: „eine Richtung mitgeben auf ein Modell und dann den letzten Tick die Physik übernehmen
# lassen … es kommt ein Schlag von rechts … den schieben wir noch ein bisschen nach rechts und dann lassen wir ihn physisch richtig
# zusammenbrechen“; 19:41: die Beine knicken nicht): Probe physikalisches Sterben. Die gebackene Sterbebewegung (Tod, Tod2 …) spielt
# bis UEBERGABE ihrer Länge, dann übernimmt Godot-Physik (PhysicalBone3D je Glied, Gelenkgrenzen je Glied wie beim Menschen): die
# Glieder sinken schlaff, die Knie knicken, ein Stoß aus der Richtung des Treffers schiebt nach (Stärke nach Waffe und kritischem
# Treffer). Liegt er still (oder nach LIEGEN_S), wird die Lage eingefroren: die Haltung jedes Knochens bleibt, die Physik ist aus
# (kein Rechnen mehr beim Liegen). Boden: eine waagerechte Ebene in Fußhöhe (Kampfort ohne Gelände). Nur Zweibeiner auf dem
# UAL-Gerüst (Goblin, Späher, Schamane, Kobold); andere Gerüste bleiben bei der gebackenen Bewegung, bis die Probe entschieden ist.
extends Node

## Anteil der Sterbebewegung, ab dem die Physik übernimmt („den letzten Tick“)
const UEBERGABE := 0.55
const LIEGEN_S := 2.2
## still: alle Glieder langsamer als das (m/s), so lange (s)
const STILL_MPS := 0.08
const STILL_S := 0.35
## Glieder: Knochen, Kind (für Länge und Richtung), Radius (Anteil der Größe), Masse (Anteil), Gelenk, Grenzen in Grad
## Gelenk: "kegel" [Schwung, Drehung], "scharnier" [unten, oben] um die x-Achse des Knochens
const GLIEDER := [
	["pelvis", "spine_01", 0.085, 0.16, "", []],
	["spine_02", "spine_03", 0.08, 0.14, "kegel", [25.0, 15.0]],
	["spine_03", "neck_01", 0.085, 0.14, "kegel", [20.0, 15.0]],
	["Head", "", 0.065, 0.07, "kegel", [35.0, 30.0]],
	["upperarm_l", "lowerarm_l", 0.035, 0.035, "kegel", [70.0, 30.0]],
	["lowerarm_l", "hand_l", 0.03, 0.025, "scharnier", [-140.0, 0.0]],
	["upperarm_r", "lowerarm_r", 0.035, 0.035, "kegel", [70.0, 30.0]],
	["lowerarm_r", "hand_r", 0.03, 0.025, "scharnier", [-140.0, 0.0]],
	["thigh_l", "calf_l", 0.05, 0.1, "kegel", [50.0, 20.0]],
	["calf_l", "foot_l", 0.04, 0.05, "scharnier", [0.0, 140.0]],
	["thigh_r", "calf_r", 0.05, 0.1, "kegel", [50.0, 20.0]],
	["calf_r", "foot_r", 0.04, 0.05, "scharnier", [0.0, 140.0]],
]
## Stoß: Grundstärke (m/s auf den Rumpf), mal Waffe (schwer 1,5), kritisch 1,6
const STOSS_MPS := 1.4
## er sackt in sich zusammen: Becken und Rumpf beginnen mit so viel Fallgeschwindigkeit (m/s je m Größe), so knicken die Knie
const SACKEN_MPS := 0.9
## Anschub der Scharniere beim Übergang (rad/s)
const KNICK_RAD_S := 4.0
const SCHICHT := 1 << 19      # eigene Kollisionsschicht: Glieder und Boden, sonst nichts

var sk: Skeleton3D
var sim: PhysicalBoneSimulator3D
var boden: StaticBody3D
var knochen := {}           # Name -> PhysicalBone3D
var gross := 1.0             # Größe der Figur (m), für Radien
var phase := ""              # "", "fall", "physik", "liegt"
var _still := 0.0
var _zeit := 0.0
var _lage := {}             # Knochen -> Haltung (lokal), eingefroren
var anim: AnimationPlayer
var stoss := Vector3.ZERO    # Welt, m/s
var stoss_knochen := "spine_03"
var bilder_physik := 0       # Messung: so viele Bilder lief die Physik


## Gerüst prüfen und Glieder anlegen (noch ohne Physik); false: kein UAL-Zweibeiner
func einrichten(s: Skeleton3D, a: AnimationPlayer, groesse_m: float) -> bool:
	sk = s
	anim = a
	gross = maxf(groesse_m, 0.3)
	for g in GLIEDER:
		if sk.find_bone(g[0]) < 0:
			return false
	sim = PhysicalBoneSimulator3D.new()
	sim.name = "Ragdoll"
	sim.active = false
	sk.add_child(sim)
	var welt_skala := sk.global_transform.basis.get_scale().x
	for g in GLIEDER:
		var b := sk.find_bone(g[0])
		var pb := PhysicalBone3D.new()
		pb.name = "R_" + String(g[0])
		pb.bone_name = g[0]
		pb.collision_layer = SCHICHT
		pb.collision_mask = SCHICHT
		pb.mass = maxf(float(g[3]) * 30.0, 0.3)
		pb.friction = 0.9
		pb.bounce = 0.0
		pb.linear_damp = 0.6
		pb.angular_damp = 2.5
		var lang := 0.12 * gross / maxf(welt_skala, 0.01)
		if String(g[1]) != "" and sk.find_bone(g[1]) >= 0:
			lang = (sk.get_bone_global_rest(sk.find_bone(g[1])).origin - sk.get_bone_global_rest(b).origin).length()
		var r := float(g[2]) * gross / maxf(welt_skala, 0.01)
		var cs := CollisionShape3D.new()
		var kap := CapsuleShape3D.new()
		kap.radius = clampf(r, 0.01, lang * 0.5 if lang > 0.02 else r)
		kap.height = maxf(lang, kap.radius * 2.0 + 0.001)
		cs.shape = kap
		pb.add_child(cs)
		# die Kapsel längs des Knochens (y), Mitte auf halber Länge (body_offset: Körper im Raum des Knochens)
		pb.body_offset = Transform3D(Basis.IDENTITY, Vector3(0, lang * 0.5, 0))
		match String(g[4]):
			"kegel":
				pb.joint_type = PhysicalBone3D.JOINT_TYPE_CONE
				pb.set("joint_constraints/swing_span", float(g[5][0]))
				pb.set("joint_constraints/twist_span", float(g[5][1]))
			"scharnier":
				# Knie und Ellbogen knicken nur in eine Richtung: die Seite aus dem Gerüst (Fuß nach hinten, Hand nach vorn), nicht
				# aus der Tabelle (die Achsen der Knochen sind je Gerüst anders)
				pb.joint_type = PhysicalBone3D.JOINT_TYPE_HINGE
				pb.joint_rotation = Vector3(0, PI / 2.0, 0)     # das Scharnier dreht um z des Gelenks: z auf x des Knochens
				var grenze: float = maxf(absf(float(g[5][0])), absf(float(g[5][1])))
				var vor := _knickt_vor(b, String(g[0]).begins_with("lower"))
				pb.set("joint_constraints/angular_limit_enabled", true)
				pb.set("joint_constraints/angular_limit_lower", 0.0 if vor else -grenze)
				pb.set("joint_constraints/angular_limit_upper", grenze if vor else 0.0)
				pb.set_meta("knick", 1.0 if vor else -1.0)
			_:
				pb.joint_type = PhysicalBone3D.JOINT_TYPE_NONE
		pb.joint_offset = Transform3D(Basis.IDENTITY, Vector3(0, -lang * 0.5, 0))     # Gelenk am Ursprung des Knochens
		sim.add_child(pb)
		knochen[g[0]] = pb
	return true


## vorn der Figur im Raum des Skeletts: von der Ferse zu den Zehen (UAL ball_l), sonst +z (glTF schaut nach +z)
func _vorn() -> Vector3:
	var f := sk.find_bone("foot_l")
	var z := sk.find_bone("ball_l")
	if f >= 0 and z >= 0:
		var d := sk.get_bone_global_rest(z).origin - sk.get_bone_global_rest(f).origin
		d.y = 0.0
		if d.length() > 0.001:
			return d.normalized()
	return Vector3.BACK


## ob eine positive Drehung um die x-Achse des Knochens [b] sein Kind (längs y) dorthin bringt, wohin das Gelenk knicken soll:
## Ellbogen ([hand]) bringen die Hand nach vorn, Knie den Fuß nach hinten
func _knickt_vor(b: int, hand: bool) -> bool:
	var bas := sk.get_bone_global_rest(b).basis.orthonormalized()
	var hin := bas * Vector3(0, 0, -1)     # Godots Scharniergrenze: positiv bringt y nach −z des Knochens (gemessen, ragdoll_1215)
	var soll := _vorn() * (1.0 if hand else -1.0)
	return hin.dot(soll) >= 0.0


## im Tod nach [nach_s] die Physik übernehmen lassen; [fuss] Welt-Höhe des Bodens
func sterben(nach_s: float, fuss: float) -> void:
	phase = "fall"
	_zeit = -nach_s
	_boden(fuss)


func _boden(fuss: float) -> void:
	if boden != null:
		return
	boden = StaticBody3D.new()
	boden.name = "RagdollBoden"
	boden.collision_layer = SCHICHT
	boden.collision_mask = SCHICHT
	var cs := CollisionShape3D.new()
	cs.shape = WorldBoundaryShape3D.new()
	boden.add_child(cs)
	boden.top_level = true
	add_child(boden)
	boden.global_transform = Transform3D(Basis.IDENTITY, Vector3(0, fuss, 0))


func _physics_process(delta: float) -> void:
	_zeit += delta
	match phase:
		"fall":
			if _zeit >= 0.0:
				_los()
		"physik":
			bilder_physik += 1
			var schnell := 0.0
			for n in knochen:
				schnell = maxf(schnell, (knochen[n] as PhysicalBone3D).linear_velocity.length())
			_still = _still + delta if schnell < STILL_MPS * gross else 0.0
			if _still >= STILL_S or _zeit >= LIEGEN_S:
				_einfrieren()


func _los() -> void:
	phase = "physik"
	_zeit = 0.0
	if anim != null:
		anim.pause()
	sim.active = true
	sim.physical_bones_start_simulation()
	# Schwung der Bewegung mitnehmen ist Sache der Engine nicht: die Glieder beginnen in Ruhe; der Stoß gibt die Richtung
	for n in knochen:
		var pb := knochen[n] as PhysicalBone3D
		var rumpf: bool = String(n).begins_with("spine") or n == "Head" or n == "pelvis"
		var anteil := 1.0 if n == stoss_knochen else (0.6 if rumpf else 0.25)
		pb.linear_velocity = stoss * anteil + Vector3.DOWN * (SACKEN_MPS * gross * (1.0 if rumpf else 0.4))
		if pb.has_meta("knick"):     # Knie und Ellbogen anknicken, in die Richtung, in die sie dürfen (gestreckt fällt er sonst steif)
			pb.angular_velocity = pb.global_transform.basis.x.normalized() * (-float(pb.get_meta("knick")) * KNICK_RAD_S)


## die Lage, wie die Physik sie hinterlassen hat, bleibt; die Physik geht aus
func _einfrieren() -> void:
	phase = "liegt"
	# Lage aus den Körpern (Knochen = Körper · body_offset⁻¹), im Raum des Skeletts; Knochen ohne Körper behalten ihre Haltung
	var inv := sk.global_transform.affine_inverse()
	var aus_physik := {}
	for n in knochen:
		var pb := knochen[n] as PhysicalBone3D
		var g: Transform3D = inv * (pb.global_transform * pb.body_offset.affine_inverse())
		aus_physik[sk.find_bone(n)] = Transform3D(g.basis.orthonormalized(), g.origin)
	sim.physical_bones_stop_simulation()
	sim.active = false
	var glob := {}
	for b in sk.get_bone_count():     # Eltern stehen im Gerüst vor den Kindern
		var p := sk.get_bone_parent(b)
		var lokal := sk.get_bone_pose(b)
		var gp: Transform3D = glob[p] if p >= 0 and glob.has(p) else Transform3D.IDENTITY
		if aus_physik.has(b):
			glob[b] = aus_physik[b]
			var l: Transform3D = gp.affine_inverse() * aus_physik[b]
			sk.set_bone_pose_position(b, l.origin)
			sk.set_bone_pose_rotation(b, l.basis.orthonormalized().get_rotation_quaternion())
		else:
			glob[b] = gp * lokal
		_lage[b] = glob[b]
	if boden != null:
		boden.queue_free()
		boden = null
	print("1215 Ragdoll: liegt nach %d Bildern Physik" % bilder_physik)
