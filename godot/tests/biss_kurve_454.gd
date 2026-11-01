# 454: Schnauze, Kopf und Rumpf des Kaufwolfs über den Biss (ohne Bild): x = quer (links +, Blick +Z), z = vorn, in Modellmetern
# Run: godot --headless --path godot -s res://tests/biss_kurve_454.gd   [BEWEGUNG=Biss]
extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	if doc.append_from_file("res://kampf/daten/kaufwolf-grau.bin", st) != OK:
		print("Bisskurve 454: ohne Kaufwolf")
		quit(0)
		return
	var n := doc.generate_scene(st)
	root.add_child(n)
	var ap: AnimationPlayer = n.find_children("*", "AnimationPlayer", true, false)[0]
	var sk: Skeleton3D = n.find_children("*", "Skeleton3D", true, false)[0]
	var nm := OS.get_environment("BEWEGUNG") if OS.get_environment("BEWEGUNG") != "" else "Biss"
	var L := ap.get_animation(nm).length
	for i in int(L * 30) + 1:
		ap.play(nm)
		ap.seek(i / 30.0, true)
		ap.pause()
		await process_frame
		await process_frame
		var out := ""
		for b in ["Wolf_Head_JawEndSHJnt", "kopf", "hals", "Wolf_Spine_02SHJnt", "Wolf_Spine_01SHJnt"]:
			var k := sk.find_bone(b)
			if k < 0:
				out += " %s:-" % b
				continue
			var p: Vector3 = (n as Node3D).global_transform.affine_inverse() * sk.global_transform * sk.get_bone_global_pose(k).origin
			out += " %s x%+.3f z%+.3f" % [b.replace("Wolf_", "").replace("SHJnt", ""), p.x, p.z]
		print("%.2f%s" % [i / 30.0, out])
	quit(0)
