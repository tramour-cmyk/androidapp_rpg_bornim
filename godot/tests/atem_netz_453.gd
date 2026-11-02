# 453 r3: wie weit bewegt das Wolfsatmen das Netz (nicht Punkte am Knochen wie wolf_ruhe_453)? Kaufwolf grau, volle Einatmung;
# Haut auf dem Rechner nachgerechnet (Knochenpose * Bindung * Punkt, gewichtet), mit und ohne Atemschicht.
# Run: godot --headless --path godot -s res://tests/atem_netz_453.gd   (BEWEGUNG=<Name>: erstes Bild dieser Bewegung statt Ruhelage)
extends SceneTree

const Figur = preload("res://kampf/figur.gd")
const Tier = preload("res://kampf/atem_tier.gd")

var posen := []


class Merker extends SkeletonModifier3D:
	var posen := []
	func _process_modification_with_delta(_d: float) -> void:
		var sk := get_skeleton()
		posen.resize(sk.get_bone_count())
		for b in sk.get_bone_count():
			posen[b] = sk.get_bone_global_pose(b)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not FileAccess.file_exists("res://kampf/daten/kaufwolf-grau.bin"):
		print("Atem 453: ohne Kaufwolf, nichts zu messen")
		quit(0)
		return
	var st := GLTFState.new()
	var doc := GLTFDocument.new()
	doc.append_from_buffer(Figur.lade_bin("res://kampf/daten/kaufwolf-grau.bin"), "", st)
	var w := doc.generate_scene(st, 30.0, false, false) as Node3D
	root.add_child(w)
	var sk := w.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	var mi: MeshInstance3D = null
	for c in w.find_children("*", "MeshInstance3D", true, false):
		if (c as MeshInstance3D).skin != null and (mi == null or c.mesh.get_faces().size() > mi.mesh.get_faces().size()):
			mi = c
	var aps := w.find_children("*", "AnimationPlayer", true, false)
	var ap: AnimationPlayer = aps[0] if aps.size() else null
	var bewegung := OS.get_environment("BEWEGUNG")
	if ap and bewegung != "":
		ap.play(bewegung)
		ap.seek(0.0, true)
		ap.pause()
	var m := Merker.new()     # Pose direkt vor der Atemschicht, im selben Bild (sonst misst man die Bewegung mit)
	sk.add_child(m)
	var a = Tier.new()
	a.takt = 1e9
	a.phase = Tier.EIN_ANTEIL
	sk.add_child(a)
	a.modification_processed.connect(func():
		var l := []
		for b in sk.get_bone_count():
			l.append(sk.get_bone_global_pose(b))
		posen = [m.posen.duplicate(), l])
	for i in 3:
		await process_frame
	var ohne: Array = posen[0]
	var mit: Array = posen[1]
	print("tiefe %.2f" % a.tiefe)
	for n in ["Wolf_Spine_01SHJnt", "Wolf_Spine_02SHJnt", "Wolf_Spine_03SHJnt", "Wolf_Spine_04SHJnt", "hals", "kopf", "vpfoteL", "hpfoteL"]:     # 453a B
		var b := sk.find_bone(n)
		if b < 0:
			continue
		print("  %-20s Ort %.2f mm, Drehung %.3f°" % [n, (mit[b].origin - ohne[b].origin).length() * sk.global_basis.get_scale().y * 1000,
			rad_to_deg(ohne[b].basis.get_rotation_quaternion().angle_to(mit[b].basis.get_rotation_quaternion()))])
	for s in mi.mesh.get_surface_count():
		_messen(mi, sk, s, ohne, mit)
	quit(0)


func _messen(mi: MeshInstance3D, sk: Skeleton3D, s: int, ohne: Array, mit: Array) -> void:
	var arr := mi.mesh.surface_get_arrays(s)
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var bo = arr[Mesh.ARRAY_BONES]
	var we = arr[Mesh.ARRAY_WEIGHTS]
	var n_je: int = bo.size() / vs.size()
	var skin := mi.skin
	var bind := []
	for i in skin.get_bind_count():
		var bn := skin.get_bind_bone(i)
		if bn < 0:
			bn = sk.find_bone(skin.get_bind_name(i))
		bind.append([bn, skin.get_bind_pose(i)])
	var gt := sk.global_transform
	var gross := 0.0
	var summe := 0.0
	var ueber := [0, 0, 0]
	var wo := Vector3()
	var je_knochen := {}
	for v in vs.size():
		var p0 := Vector3()
		var p1 := Vector3()
		for j in n_je:
			var g: float = we[v * n_je + j]
			if g <= 0.0:
				continue
			var bi: Array = bind[bo[v * n_je + j]]
			p0 += g * (gt * (ohne[bi[0]] * (bi[1] * vs[v])))
			p1 += g * (gt * (mit[bi[0]] * (bi[1] * vs[v])))
		var d := p0.distance_to(p1)
		var dom := 0
		for j in n_je:
			if we[v * n_je + j] > we[v * n_je + dom]:
				dom = j
		var dn: String = sk.get_bone_name(bind[bo[v * n_je + dom]][0])
		var gb: Array = je_knochen.get(dn, [0.0, 0])
		je_knochen[dn] = [maxf(gb[0], d), gb[1] + 1]
		summe += d
		if d > gross:
			gross = d
			wo = p0
		for k in 3:
			if d > [0.001, 0.003, 0.006][k]:
				ueber[k] += 1
	print("Fläche %d, %d Punkte: größter Ausschlag %.1f mm bei %s, Mittel %.2f mm, über 1/3/6 mm: %s" % [s, vs.size(), gross * 1000,
		wo, summe / vs.size() * 1000, ueber])
	for dn in je_knochen:
		if je_knochen[dn][0] > 0.0005:
			print("  %-28s %4d Punkte, bis %.1f mm" % [dn, je_knochen[dn][1], je_knochen[dn][0] * 1000])
