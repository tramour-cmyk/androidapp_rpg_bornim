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
## Glieder je Gerüst: Knochen, Ende (Knochen, dessen Ursprung das Ende des Glieds ist; "" = aus der Größe), Verlängerung (Ende mal so
## weit wie bis zum Ende-Knochen), Radius (Anteil der Größe), Masse (Anteil), Gelenk, Grenzen in Grad. Länge und Richtung des Körpers
## aus den Ursprüngen (nicht aus der Achse des Knochens); Gelenk: "kegel" [Schwung, Drehung], "knie"/"ellbogen" [Grenze]: Scharnier quer
## zu Glied und Blickrichtung, Knie knicken den Fuß nach hinten, Ellbogen die Hand nach vorn
## UAL (Quaternius, GERUEST=cc0)
const GLIEDER_UAL := [
	["pelvis", "spine_01", 1.0, 0.085, 0.16, "", []],
	["spine_02", "spine_03", 1.0, 0.08, 0.14, "kegel", [25.0, 15.0]],
	["spine_03", "neck_01", 1.0, 0.085, 0.14, "kegel", [20.0, 15.0]],
	["Head", "", 1.0, 0.065, 0.07, "kegel", [35.0, 30.0]],
	["upperarm_l", "lowerarm_l", 1.0, 0.035, 0.035, "kegel", [70.0, 30.0]],
	["lowerarm_l", "hand_l", 1.0, 0.03, 0.025, "ellbogen", [140.0]],
	["upperarm_r", "lowerarm_r", 1.0, 0.035, 0.035, "kegel", [70.0, 30.0]],
	["lowerarm_r", "hand_r", 1.0, 0.03, 0.025, "ellbogen", [140.0]],
	["thigh_l", "calf_l", 1.0, 0.05, 0.1, "kegel", [50.0, 20.0]],
	["calf_l", "foot_l", 1.0, 0.04, 0.05, "knie", [140.0]],
	["thigh_r", "calf_r", 1.0, 0.05, 0.1, "kegel", [50.0, 20.0]],
	["calf_r", "foot_r", 1.0, 0.04, 0.05, "knie", [140.0]],
]
## eigenes Gerüst (v3/rig.py: je Strecke zwischen zwei Gelenkpunkten ein Knochen „a-b“; Goblin, Späher, Schamane, Kobold); der Unterarm
## endet am Handgelenk wr, das keinen eigenen Knochen hat: zweimal so weit wie bis fo (Mitte)
const GLIEDER_STRECKE := [
	["pelvis-waist", "belly-chest", 1.0, 0.085, 0.16, "", []],
	["belly-chest", "chestTop-neck", 1.0, 0.085, 0.2, "kegel", [25.0, 15.0]],
	["neck-neckTop", "", 1.0, 0.065, 0.07, "kegel", [35.0, 30.0]],
	["upL-elL", "elL-foL", 1.0, 0.035, 0.035, "kegel", [70.0, 30.0]],
	["elL-foL", "foL-wrL", 2.0, 0.03, 0.025, "ellbogen", [140.0]],
	["upR-elR", "elR-foR", 1.0, 0.035, 0.035, "kegel", [70.0, 30.0]],
	["elR-foR", "foR-wrR", 2.0, 0.03, 0.025, "ellbogen", [140.0]],
	["hipL-thighL", "kneeL-calfL", 1.0, 0.05, 0.1, "kegel", [50.0, 20.0]],
	["kneeL-calfL", "ankleL-heelL", 1.0, 0.04, 0.05, "knie", [140.0]],
	["hipR-thighR", "kneeR-calfR", 1.0, 0.05, 0.1, "kegel", [50.0, 20.0]],
	["kneeR-calfR", "ankleR-heelR", 1.0, 0.04, 0.05, "knie", [140.0]],
]
## Ferse und Ballen (für vorn), Brust (Ziel des Stoßes) je Gerüst
const MARKEN := {"ual": ["foot_l", "ball_l", "spine_03"], "strecke": ["ankleL-heelL", "ballL-toeL", "belly-chest"]}
var geruest := ""

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


## Gerüst erkennen (UAL oder eigenes) und Glieder anlegen (noch ohne Physik); false: kein bekanntes Zweibeiner-Gerüst
func einrichten(s: Skeleton3D, a: AnimationPlayer, groesse_m: float) -> bool:
	sk = s
	anim = a
	gross = maxf(groesse_m, 0.3)
	var glieder := []
	for kand in [["ual", GLIEDER_UAL], ["strecke", GLIEDER_STRECKE]]:
		var da := true
		for g in kand[1]:
			if sk.find_bone(g[0]) < 0 or (String(g[1]) != "" and sk.find_bone(g[1]) < 0): da = false
		for n in MARKEN[kand[0]]:
			if sk.find_bone(n) < 0: da = false
		if da:
			geruest = kand[0]
			glieder = kand[1]
			break
	if glieder.is_empty():
		return false
	stoss_knochen = String(MARKEN[geruest][2])
	sim = PhysicalBoneSimulator3D.new()
	sim.name = "Ragdoll"
	sim.active = false
	sk.add_child(sim)
	var welt_skala := sk.global_transform.basis.get_scale().x
	var vorn := _vorn()
	for g in glieder:
		var b := sk.find_bone(g[0])
		var rest := sk.get_bone_global_rest(b)
		var rb := rest.basis.orthonormalized()
		var pb := PhysicalBone3D.new()
		pb.name = "R_" + String(g[0])
		pb.bone_name = g[0]
		pb.collision_layer = SCHICHT
		pb.collision_mask = SCHICHT
		pb.mass = maxf(float(g[4]) * 30.0, 0.3)
		pb.friction = 0.9
		pb.bounce = 0.0
		pb.linear_damp = 0.6
		pb.angular_damp = 2.5
		# Richtung und Länge im Raum des Knochens: zum Ursprung des Ende-Knochens; ohne Ende längs y des Knochens
		var d := Vector3(0, 0.12 * gross / maxf(welt_skala, 0.01), 0)
		if String(g[1]) != "":
			var dg: Vector3 = (sk.get_bone_global_rest(sk.find_bone(g[1])).origin - rest.origin) * float(g[2])
			d = rb.inverse() * dg / maxf(rest.basis.get_scale().x, 0.0001)
		var lang := d.length()
		var r := float(g[3]) * gross / maxf(welt_skala, 0.01)
		var cs := CollisionShape3D.new()
		var kap := CapsuleShape3D.new()
		kap.radius = clampf(r, 0.01, lang * 0.5 if lang > 0.02 else r)
		kap.height = maxf(lang, kap.radius * 2.0 + 0.001)
		cs.shape = kap
		pb.add_child(cs)
		# der Körper (Kapsel längs seiner y) von Ursprung zu Ende: y auf d, z quer zu Glied und Blick, Mitte auf halber Strecke
		var by := d.normalized()
		var bz := by.cross(rb.inverse() * vorn)
		if bz.length() < 0.01:
			bz = by.cross(Vector3.RIGHT if absf(by.x) < 0.9 else Vector3.UP)
		bz = bz.normalized()
		var bx := by.cross(bz).normalized()     # ≈ −vorn (hinten)
		pb.body_offset = Transform3D(Basis(bx, by, bz), d * 0.5)
		match String(g[5]):
			"kegel":
				pb.joint_type = PhysicalBone3D.JOINT_TYPE_CONE
				pb.set("joint_constraints/swing_span", float(g[6][0]))
				pb.set("joint_constraints/twist_span", float(g[6][1]))
			"knie", "ellbogen":
				# Scharnier um z des Körpers (aus der Geometrie, nicht aus den Achsen der Knochen, die je Gerüst anders liegen):
				# Ellbogen nur nach vorn, Knie nur nach hinten
				pb.joint_type = PhysicalBone3D.JOINT_TYPE_HINGE
				pb.joint_rotation = Vector3.ZERO
				# Godots Scharnierwinkel: positiv dreht das Kind gegen den Uhrzeigersinn um die Achse (gemessen 13.11. mit ragdoll_1215:
				# positiv bringt y nach −z bei Achse x), hier also y nach +x = hinten
				var grenze := float(g[6][0])
				var hinten_pos: bool = String(g[5]) == "knie"
				pb.set("joint_constraints/angular_limit_enabled", true)
				pb.set("joint_constraints/angular_limit_lower", 0.0 if hinten_pos else -grenze)
				pb.set("joint_constraints/angular_limit_upper", grenze if hinten_pos else 0.0)
				pb.set_meta("knick", 1.0 if hinten_pos else -1.0)     # Seite, auf der der Winkel erlaubt ist
			_:
				pb.joint_type = PhysicalBone3D.JOINT_TYPE_NONE
		pb.joint_offset = Transform3D(Basis.IDENTITY, Vector3(0, -lang * 0.5, 0))     # Gelenk am Ursprung des Knochens
		sim.add_child(pb)
		knochen[g[0]] = pb
	return true


## vorn der Figur im Raum des Skeletts: von der Ferse zu den Zehen, sonst +z (glTF schaut nach +z)
func _vorn() -> Vector3:
	var f := sk.find_bone(String(MARKEN[geruest][0]))
	var z := sk.find_bone(String(MARKEN[geruest][1]))
	if f >= 0 and z >= 0:
		var d := sk.get_bone_global_rest(z).origin - sk.get_bone_global_rest(f).origin
		d.y = 0.0
		if d.length() > 0.001:
			return d.normalized()
	return Vector3.BACK


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
			pb.angular_velocity = pb.global_transform.basis.z.normalized() * (-float(pb.get_meta("knick")) * KNICK_RAD_S)     # erlaubte Seite: Drehung gegen die Achse


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
