extends SceneTree
# 1215 (Chef 13.11., 16:17/16:25/19:41 zu 1141): Probe physikalisches Sterben (kampf/ragdoll.gd) auf einem Gerüst mit den Knochen des
# Goblins (UAL-Namen), ohne Modelle, einmal in Meterskala und einmal 1,32-fach (Kampfort, _foe_scale). Gemessen: er fällt (Becken
# unten), die Knie knicken, nichts sinkt unter den Boden, der Stoß schiebt ihn zur Seite des Stoßes, er liegt still und eingefroren
# vor LIEGEN_S + 0,5 s, danach ändert sich keine Haltung mehr und die Physik ist aus. Ohne Bild, Sekunden.
# Aufruf: im Ordner godot mit -s res://tests/ragdoll_1215.gd   (Exit 0 = gut)

const Ragdoll = preload("res://kampf/ragdoll.gd")

## Name, Eltern, Ort im Elternknochen, umgedreht (die y-Achse nach unten: Arme und Beine hängen; wie die UAL-Knochen aus Blender
## zeigt die y-Achse jedes Knochens zu seinem Kind)
const KNOCHEN := [
	["root", "", Vector3(0, 0, 0), false], ["pelvis", "root", Vector3(0, 0.55, 0), false], ["spine_01", "pelvis", Vector3(0, 0.08, 0), false],
	["spine_02", "spine_01", Vector3(0, 0.1, 0), false], ["spine_03", "spine_02", Vector3(0, 0.12, 0), false],
	["neck_01", "spine_03", Vector3(0, 0.14, 0), false], ["Head", "neck_01", Vector3(0, 0.08, 0), false],
	["clavicle_l", "spine_03", Vector3(0.04, 0.1, 0), false], ["upperarm_l", "clavicle_l", Vector3(0.1, 0, 0), true],
	["lowerarm_l", "upperarm_l", Vector3(0, 0.2, 0), false], ["hand_l", "lowerarm_l", Vector3(0, 0.18, 0), false],
	["clavicle_r", "spine_03", Vector3(-0.04, 0.1, 0), false], ["upperarm_r", "clavicle_r", Vector3(-0.1, 0, 0), true],
	["lowerarm_r", "upperarm_r", Vector3(0, 0.2, 0), false], ["hand_r", "lowerarm_r", Vector3(0, 0.18, 0), false],
	["thigh_l", "pelvis", Vector3(0.08, -0.03, 0), true], ["calf_l", "thigh_l", Vector3(0, 0.26, 0), false],
	["foot_l", "calf_l", Vector3(0, 0.24, 0), false], ["ball_l", "foot_l", Vector3(0, 0.03, 0.1), false],
	["thigh_r", "pelvis", Vector3(-0.08, -0.03, 0), true], ["calf_r", "thigh_r", Vector3(0, 0.26, 0), false],
	["foot_r", "calf_r", Vector3(0, 0.24, 0), false],
]

var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _pruef(name: String, gut: bool, wert: String) -> void:
	print("RAGDOLL1215 %s: %s (%s)" % [name, "gut" if gut else "FEHLER", wert])
	if not gut:
		fehler += 1


func _gerust(skala: float) -> Array:
	var halter := Node3D.new()
	halter.scale = Vector3.ONE * skala
	root.add_child(halter)
	var s := Skeleton3D.new()
	for k in KNOCHEN:
		var b := s.add_bone(k[0])
		if k[1] != "":
			s.set_bone_parent(b, s.find_bone(k[1]))
		s.set_bone_rest(b, Transform3D(Basis(Vector3.RIGHT, PI) if k[3] else Basis.IDENTITY, k[2]))
	s.reset_bone_poses()
	halter.add_child(s)
	return [halter, s]


func _y(s: Skeleton3D, n: String) -> float:
	return (s.global_transform * s.get_bone_global_pose(s.find_bone(n)).origin).y


func _knie(s: Skeleton3D, seite: String) -> float:
	var h := s.get_bone_global_pose(s.find_bone("thigh_" + seite)).origin
	var k := s.get_bone_global_pose(s.find_bone("calf_" + seite)).origin
	var f := s.get_bone_global_pose(s.find_bone("foot_" + seite)).origin
	var w := rad_to_deg((k - h).angle_to(f - k))
	# richtig herum: der Fuß hinter der Linie Hüfte -> Knie (vorn ist +z, die Zehen); nach vorn geknickt zählt negativ
	var vorn := (s.get_bone_global_pose(s.find_bone("pelvis")).basis * Vector3.BACK)
	var seitlich := (k - h).cross(f - k)
	return w if (f - k).dot(vorn) <= (k - h).dot(vorn) + 0.001 or w < 5.0 else -w


func _run() -> void:
	for skala in [1.0, 1.32]:
		var g := _gerust(skala)
		var halter: Node3D = g[0]
		var s: Skeleton3D = g[1]
		await process_frame
		var r = Ragdoll.new()
		halter.add_child(r)
		if not r.einrichten(s, null, 1.1 * skala):
			_pruef("einrichten %.2f" % skala, false, "Gerüst nicht erkannt")
			continue
		var becken0 := _y(s, "pelvis")
		var x0: float = (s.global_transform * s.get_bone_global_pose(s.find_bone("spine_03")).origin).x
		r.stoss = Vector3(1.2, 0, 0) * skala
		r.sterben(0.0, 0.0)
		var n := 0
		var tiefste := INF
		while r.phase != "liegt" and n < 60 * 4:
			await physics_frame
			n += 1
			for k in KNOCHEN:
				tiefste = minf(tiefste, _y(s, k[0]))
		var t := n / float(Engine.physics_ticks_per_second)
		_pruef("Skala %.2f liegt still" % skala, r.phase == "liegt" and t <= Ragdoll.LIEGEN_S + 0.5, "nach %.2f s" % t)
		await process_frame
		var becken := _y(s, "pelvis")
		_pruef("Skala %.2f fällt" % skala, becken < becken0 * 0.5, "Becken %.2f m statt %.2f" % [becken, becken0])
		var knie := maxf(_knie(s, "l"), _knie(s, "r"))
		if OS.get_environment("KNIE") != "":
			for sd in ["l", "r"]:
				var th := s.get_bone_global_pose(s.find_bone("thigh_" + sd)).basis.orthonormalized()
				var ca := s.get_bone_global_pose(s.find_bone("calf_" + sd)).basis.orthonormalized()
				var y2 := th.inverse() * ca.y
				print("KNIE %s: im Oberschenkel y=%.2f z=%.2f (Winkel um x %.0f°), Wert %.0f" % [sd, y2.y, y2.z, rad_to_deg(atan2(y2.z, y2.y)), _knie(s, sd)])
		_pruef("Skala %.2f Knie knicken" % skala, knie > 10.0, "%.0f°" % knie)
		_pruef("Skala %.2f nicht im Boden" % skala, tiefste > -0.06 * skala, "tiefster Knochen %.3f m" % tiefste)
		var x: float = (s.global_transform * s.get_bone_global_pose(s.find_bone("spine_03")).origin).x
		_pruef("Skala %.2f Stoß nach rechts" % skala, x - x0 > 0.1 * skala, "Brust %+.2f m" % (x - x0))
		var vorher := []
		for b in s.get_bone_count():
			vorher.append(s.get_bone_pose(b))
		for i in 10:
			await physics_frame
		var wandert := 0.0
		for b in s.get_bone_count():
			wandert = maxf(wandert, (s.get_bone_pose(b).origin - vorher[b].origin).length())
		_pruef("Skala %.2f eingefroren" % skala, wandert < 0.001 and not r.sim.is_simulating_physics(), "%.4f m, Physik %s" % [wandert, r.sim.is_simulating_physics()])
		halter.queue_free()
	print("RAGDOLL1215 %s" % ("alles gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
