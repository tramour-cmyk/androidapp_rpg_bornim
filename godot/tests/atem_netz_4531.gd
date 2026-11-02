# 453.1 Tor 461a (Prüfer Lauf 173: Kleriker atmet im Bild schwächer als der Kämpfer, das Gelenk beider gleich): die Messung der Haut
# über der Schulter (atem.gd _netz_messen) an einem gebauten Skelett ohne Kaufdateien:
#  - Haut am Schlüsselbein: hebt sich wie fest am Schlüsselbein, Ausgleich 1
#  - Haut nur am Rücken (spine_02, Tracht über den Schultern): hebt sich weniger, Ausgleich über 1, höchstens NETZ_MAX
#  - nach der Messung steht die Pose wieder wie vorher (die Schicht dreht nur einmal je Bild)
# Run: godot --headless --path godot -s res://tests/atem_netz_4531.gd   (exit code 0 = alles richtig)
extends SceneTree

const Atem = preload("res://kampf/atem.gd")
var fails := 0


func _check(ok: bool, what: String) -> void:
	print(("ok     " if ok else "FEHLER ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	_run.call_deferred()


## Skelett wie die UAL: Becken, Rücken, Hals, Kopf, Schlüsselbeine, Oberarme; Haut als Punkte über den Schultern an [traeger]
func _figur(traeger: String) -> Array:
	var sk := Skeleton3D.new()
	var teile := [["pelvis", "", Vector3(0, 1.0, 0)], ["spine_02", "pelvis", Vector3(0, 0.15, 0)], ["spine_03", "spine_02", Vector3(0, 0.15, 0)],
		["neck_01", "spine_03", Vector3(0, 0.2, 0)], ["Head", "neck_01", Vector3(0, 0.1, 0)],
		["clavicle_l", "spine_03", Vector3(0.03, 0.15, 0)], ["upperarm_l", "clavicle_l", Vector3(0.15, 0, 0)],
		["clavicle_r", "spine_03", Vector3(-0.03, 0.15, 0)], ["upperarm_r", "clavicle_r", Vector3(-0.15, 0, 0)]]
	for t in teile:
		var b := sk.add_bone(t[0])
		if t[1] != "":
			sk.set_bone_parent(b, sk.find_bone(t[1]))
		sk.set_bone_rest(b, Transform3D(Basis(), t[2]))
		sk.set_bone_pose_position(b, t[2])
	sk.reset_bone_poses()
	var skin := Skin.new()
	for b in sk.get_bone_count():
		skin.add_named_bind(sk.get_bone_name(b), sk.get_bone_global_rest(b).affine_inverse())
	# Punkte 2–8 cm über beiden Schultergelenken
	var vs := PackedVector3Array()
	var bo := PackedInt32Array()
	var we := PackedFloat32Array()
	var tb := sk.find_bone(traeger)
	for seite in [1.0, -1.0]:
		for x in [0.12, 0.16, 0.20]:
			for y in [0.02, 0.05, 0.08]:
				var g := sk.get_bone_global_rest(sk.find_bone("upperarm_l" if seite > 0 else "upperarm_r")).origin
				vs.append(Vector3(seite * x, g.y + y, 0))
				var t2 := tb if traeger != "clavicle" else sk.find_bone("clavicle_l" if seite > 0 else "clavicle_r")
				bo.append_array([t2, 0, 0, 0])
				we.append_array([1.0, 0, 0, 0])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vs
	arr[Mesh.ARRAY_BONES] = bo
	arr[Mesh.ARRAY_WEIGHTS] = we
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, arr)
	var mi := MeshInstance3D.new()
	mi.mesh = m
	mi.skin = skin
	sk.add_child(mi)
	mi.skeleton = NodePath("..")
	var a = Atem.new()
	a.eigen_kampf(5)
	a.phase = 0.0     # Ausatmung zu Ende: die Messung allein bewegt nichts
	sk.add_child(a)
	a.netz_messen([mi])
	root.add_child(sk)
	return [sk, a]


func _run() -> void:
	var gerade := []
	for traeger in ["clavicle", "spine_02"]:
		var f := _figur(traeger)
		var sk: Skeleton3D = f[0]
		var a = f[1]
		var vor := sk.get_bone_global_pose(sk.find_bone("upperarm_l"))
		for i in 3:
			await process_frame
		var n: float = a.netz
		print("Haut an %s: gemessen %.2f, Ausgleich %.2f" % [traeger, a.netz_roh, n])
		if traeger == "clavicle":
			_check(absf(a.netz_roh - 1.0) < 0.1, "Haut am Schlüsselbein hebt sich wie fest daran (%.2f)" % a.netz_roh)
			_check(absf(n - 1.0) < 0.1, "dann kein Ausgleich (%.2f)" % n)
		else:
			_check(a.netz_roh > 1.2, "Haut nur am Rücken hebt sich weniger (%.2f)" % a.netz_roh)
			_check(n > 1.2 and n <= Atem.NETZ_MAX, "dann Ausgleich über 1, höchstens %.1f (%.2f)" % [Atem.NETZ_MAX, n])
		gerade.append(sk.get_bone_global_pose(sk.find_bone("upperarm_l")).origin.distance_to(vor.origin) < 0.003)
		sk.queue_free()
	_check(not gerade.has(false), "nach der Messung steht die Pose wie vorher (bis 3 mm, Ausatmung)")
	print("Atemnetz 453.1: %d Fehler" % fails)
	quit(1 if fails > 0 else 0)
