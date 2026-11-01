# 453 r3 (Prüfer Film r3, 01.11., 23:2x: Rücken im Film nur 0,3–0,5 px): wohin bewegt die Atemschicht die Haut des Wolfs, in Metern,
# ohne Bild: je Wolf bei voller Einatmung gegen ohne Schicht, getrennt nach Rückenlinie (oberste Haut über dem Rumpf), Bauchlinie
# (unterste) und Flanke (quer). Run: godot --headless --path godot --fixed-fps 30 -s res://tests/atem_ruecken_453.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")


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
	await process_frame
	if not FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json"):
		print("ATEMRUECKEN ohne Kaufwolf")
		quit(0)
		return
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	var wl := []
	for f in kf.figures.values():
		if f.fighter.monster != null and f.atem != null:
			var sk: Skeleton3D = f._find(f.model, "Skeleton3D")
			var m := Merker.new()
			sk.add_child(m)
			sk.move_child(m, f.atem.get_index())
			var e := {"f": f, "sk": sk, "m": m, "nach": []}
			f.atem.modification_processed.connect(func():
				var l := []
				var k := []
				for b in sk.get_bone_count():
					l.append(sk.get_bone_global_pose(b))
				for b in sk.get_bone_count():
					var t := Transform3D(Basis(sk.get_bone_pose_rotation(b)).scaled(sk.get_bone_pose_scale(b)), sk.get_bone_pose_position(b))
					var par := sk.get_bone_parent(b)
					k.append(t if par < 0 else k[par] * t)
				e["nach"] = l if OS.get_environment("LOKAL") == "" else k)
			wl.append(e)
	for i in int(OS.get_environment("WARTE") if OS.get_environment("WARTE") != "" else "50"):
		await process_frame
	Engine.time_scale = 0.0001
	for e in wl:
		e["f"].atem.phase = e["f"].atem.EIN_ANTEIL
		e["f"].atem.anstrengung = 0.0
	for i in 4:
		await process_frame
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	for e in wl:
		_bericht(e, kf.cam)
	quit(0)


func _bericht(e: Dictionary, cam: Camera3D) -> void:
	var sk: Skeleton3D = e["sk"]
	var mi: MeshInstance3D = null
	for c in e["f"].model.find_children("*", "MeshInstance3D", true, false):
		if (c as MeshInstance3D).skin != null and (mi == null or c.mesh.get_faces().size() > mi.mesh.get_faces().size()):
			mi = c
	var arr := mi.mesh.surface_get_arrays(0)
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var bo = arr[Mesh.ARRAY_BONES]
	var we = arr[Mesh.ARRAY_WEIGHTS]
	var n_je: int = bo.size() / vs.size()
	var bind := []
	for i in mi.skin.get_bind_count():
		var bn := mi.skin.get_bind_bone(i)
		if bn < 0:
			bn = sk.find_bone(mi.skin.get_bind_name(i))
		bind.append([bn, mi.skin.get_bind_pose(i)])
	var gt := sk.global_transform
	var vor := []
	var nach := []
	for v in vs.size():
		var a := Vector3()
		var b := Vector3()
		for j in n_je:
			var w: float = we[v * n_je + j]
			if w <= 0.0:
				continue
			var bi: Array = bind[bo[v * n_je + j]]
			a += w * (gt * (e["m"].posen[bi[0]] * (bi[1] * vs[v])))
			b += w * (gt * (e["nach"][bi[0]] * (bi[1] * vs[v])))
		vor.append(a)
		nach.append(b)
	# Rumpf längs: zwischen Hüfte und Schulter (Spine_01 .. Spine_04 in Welt), Mitte 60 % davon
	var s1: Vector3 = gt * e["m"].posen[sk.find_bone("Wolf_Spine_01SHJnt")].origin
	var s4: Vector3 = gt * e["m"].posen[sk.find_bone("Wolf_Spine_04SHJnt")].origin
	var ax := s4 - s1
	ax.y = 0
	var lang := ax.length()
	ax = ax.normalized()
	var quer := ax.cross(Vector3.UP)
	var oben_max := -INF
	var unten_min := INF
	for v in vor:
		var t: float = (v - s1).dot(ax) / lang
		if t > 0.2 and t < 0.8:
			oben_max = maxf(oben_max, v.y)
			unten_min = minf(unten_min, v.y)
	var hoch := oben_max - unten_min
	var r := [0.0, 0.0, 0.0, 0]
	var bauch := [0.0, 0]
	var breit := 0.0
	var px := [0.0, 0.0, 0]
	for i in vor.size():
		var t: float = (vor[i] - s1).dot(ax) / lang
		if t < 0.2 or t > 0.8:
			continue
		var d: Vector3 = nach[i] - vor[i]
		if vor[i].y > oben_max - 0.04:
			r[0] += d.y
			r[3] += 1
			r[1] = maxf(r[1], d.y)
			var sv := cam.unproject_position(nach[i]) - cam.unproject_position(vor[i])
			px[0] += sv.length()
			px[1] = maxf(px[1], sv.length())
			px[2] += 1
		if vor[i].y < unten_min + 0.06 and vor[i].y > 0.15:
			bauch[0] += d.y
			bauch[1] += 1
		breit = maxf(breit, absf(d.dot(quer)))
	print("ATEMRUECKEN %s: Rumpf %.2f m lang, %.2f m hoch; Rückenlinie hebt sich im Mittel %.1f mm (höchstens %.1f, %d Punkte), Bauchlinie %.1f mm (%d Punkte), Flanke quer höchstens %.1f mm; Rückenlinie im Bild der Kampfkamera (1080 × 2340) im Mittel %.2f px, höchstens %.2f px; Blick der Kamera %.0f° nach unten, Abstand %.1f m" % [
		e["f"].fighter.id, lang, hoch, 1000.0 * r[0] / maxf(r[3], 1), 1000.0 * r[1], r[3], 1000.0 * bauch[0] / maxf(bauch[1], 1), bauch[1], 1000.0 * breit, px[0] / maxf(px[2], 1), px[1], rad_to_deg(asin(-cam.global_basis.z.y)) * -1.0, cam.global_position.distance_to(s1)])
