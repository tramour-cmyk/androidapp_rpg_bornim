extends "res://tests/ragdoll_1215.gd"
# Probe 1215: wie das eigene Gerüst (rig.py): Hüftknochen hängen an root statt am Becken. Bleibt das Bein am Becken?
func _run() -> void:
	for art in ["Bein am Becken (UAL)", "Bein an root (wie rig.py)"]:
		var g := _gerust(1.0)
		var s: Skeleton3D = g[1]
		if art.contains("root"):
			for sd in ["l", "r"]:
				var b := s.find_bone("thigh_" + sd)
				var glob := s.get_bone_global_rest(b)
				s.set_bone_parent(b, s.find_bone("root"))
				s.set_bone_rest(b, glob)
			s.reset_bone_poses()
		await process_frame
		var r = Ragdoll.new()
		g[0].add_child(r)
		r.einrichten(s, null, 1.1)
		var d0 := (s.get_bone_global_pose(s.find_bone("thigh_l")).origin - s.get_bone_global_pose(s.find_bone("pelvis")).origin).length()
		r.stoss = Vector3(1.2, 0, 0)
		r.sterben(0.0, 0.0)
		var dmax := 0.0
		var n := 0
		while r.phase != "liegt" and n < 300:
			await physics_frame
			n += 1
			dmax = maxf(dmax, (s.get_bone_global_pose(s.find_bone("thigh_l")).origin - s.get_bone_global_pose(s.find_bone("pelvis")).origin).length())
		print("HUEFTE1215 %s: Hüfte–Becken vorher %.3f m, größter Abstand im Fall %.3f m" % [art, d0, dmax])
		g[0].queue_free()
	quit(0)
