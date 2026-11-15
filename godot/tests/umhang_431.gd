# 431 Stufe 1 (Chef 15.11., 12:43 „431g A“): Messung des Umhangs aus dem Kleiderschrank (kleiderschrank.py) mit Federkette
# (skripte/umhang.gd), ohne Bild: je Koerper Stehen und Gehen, je Bild die Enden der Ketten im Raum des Beckens.
# Zeilen UMHANG431 <datei> <bewegung> im Raum von spine_03: seitlich (cm, wie weit ein aeusseres Ende quer ueber seine Ruhelage hinaus
# nach aussen geht, 861: Beule), Spiegel (cm, rechtes Ende gespiegelt gegen das linke, Mittel ueber die Bilder), Mitte weg (cm, groesste
# Abweichung des mittleren Endes von der Bauform),
# Kapseln (Anzahl); mit Schild (daten/waffen/shield.bin da) ein zweites Mal frisch geladen, Schild und Schwert wie im Spiel (bewaffne),
# dazu Spalt (cm, kleinster Abstand Innenseite Schild zu Haut samt Umhang in „Stehen“). Hinweis bei Spalt über 4 cm (1297), FALSCH, wenn keine Kette da ist oder ein Ende weiter als 25 cm springt.
# 431 Tuch (Sokrates 15.11., 17:29): dazu „Arm gehoben“ (Sword_Attack) und Zeilen UMHANG431 TUCH: Kantenecken links/rechts (cm, Höhe und
# Abstand zur Rumpfachse der unteren Ecken), Sprung im Raum der Figur (FALSCH über 25 cm je Bild), mit Schild: wie weit Tuch außen vor
# dem Schild liegt (durchstößt). Tuch gegen Haut misst kleiderschrank.py mit Flächen (posen_messen; hier mit Ecken unzuverlässig).
# Aufruf: UMHANG=<ordner mit umhang_*.glb> [NUR=<teil des namens>] godot --headless --path godot -s res://tests/umhang_431.gd
extends SceneTree

const FPS := 30.0

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var dir := OS.get_environment("UMHANG")
	var da := DirAccess.open(dir)
	if da == null:
		print("UMHANG431 FALSCH: kein Ordner UMHANG=", dir)
		quit(1)
		return
	var dateien := []
	for f in da.get_files():
		if f.begins_with("umhang_") and f.ends_with(".glb") and (OS.get_environment("NUR") == "" or f.contains(OS.get_environment("NUR"))): dateien.append(f)
	dateien.sort()
	var falsch := 0
	for f in dateien:
		falsch += await _messe(dir.path_join(f), f, false)
		if FileAccess.file_exists("res://daten/waffen/shield.bin"): falsch += await _messe(dir.path_join(f), f, true)   # frisch geladen
	print("UMHANG431 %d Koerper, %d falsch" % [dateien.size(), falsch])
	quit(1 if falsch > 0 or dateien.is_empty() else 0)


func _messe(pfad: String, name: String, schild: bool) -> int:
	var m := Gebiet.lade_glb(pfad)
	root.add_child(m)
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	HeldFigur.bewegungen(m, sk)
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	var k := Umhang.ketten(sk)
	if k.is_empty() or ap == null:
		print("UMHANG431 %s FALSCH: ohne Kette oder Bewegungen" % name)
		m.free()
		return 1
	var sim: SpringBoneSimulator3D = null if OS.get_environment("TUCH_OHNE_FEDER") != "" else Umhang.an(m, sk)   # nur zur Ursachensuche
	var enden := {}
	for e in k: enden[e[0]] = sk.find_bone("umhang_%s_%d" % [e[0], e[1]])
	var bi := sk.find_bone("spine_03")
	# Chef 15.11., 14:32 (Lauf 9, Zwerg und Orkblütiger „katastrophal mit den Armen und dem Umhang“): wie tief Ober- und Unterarm in
	# die äußeren Ketten greifen (Abstand Glied zu Armachse unter Armdicke + Gliedradius, cm, größter Wert je Bewegung)
	var arme := []   # [Knochen, Kindknochen, Dicke]
	var dicke := {}
	for e in Umhang.kapseln(m, sk, ["upperarm_l", "upperarm_r", "lowerarm_l", "lowerarm_r"]): dicke[e["knochen"]] = float(e["radius"])
	for a in [["upperarm_l", "lowerarm_l"], ["upperarm_r", "lowerarm_r"], ["lowerarm_l", "hand_l"], ["lowerarm_r", "hand_r"]]:
		if sk.find_bone(a[0]) >= 0 and sk.find_bone(a[1]) >= 0 and dicke.has(a[0]): arme.append([sk.find_bone(a[0]), sk.find_bone(a[1]), dicke[a[0]]])
	var aussen := []
	for e in k:
		if String(e[0]) in ["l2", "r2", "l1", "r1"]:
			for j in range(2, int(e[1]) + 1): aussen.append(sk.find_bone("umhang_%s_%d" % [e[0], j]))
	var arm_tief := [0.0]
	# Chef 15.11., 16:55 („der linke und rechte Saum … nicht gerade … als ob er überall eingerissen wäre“): Knick der Randketten l2, r2
	# (misst das Fallen der Kette, nicht das Aufreißen des Netzes; das zeigt nur das Standbild von hinten),
	# größter Abstand eines Gelenks von der Geraden Anfang–Ende (cm)
	var rand := {}
	for e in k:
		if String(e[0]) in ["l2", "r2"]:
			var g := []
			for j in range(1, int(e[1]) + 1): g.append(sk.find_bone("umhang_%s_%d" % [e[0], j]))
			rand[e[0]] = g
	var knick := [0.0]
	# Bauform: Enden in der Ruhelage im Raum von spine_03 (dort haengt die Kette); Spiegelebene aus den aeusseren Enden der Ruhelage
	var bau := {}
	for s in enden: bau[s] = _ende(sk, enden[s], bi, true)
	if not (bau.has("l2") and bau.has("r2")):
		print("UMHANG431 %s FALSCH: ohne aeussere Ketten" % name); m.free(); return 1
	var nrm: Vector3 = (bau["l2"] - bau["r2"]).normalized()
	var mitte: Vector3 = (bau["l2"] + bau["r2"]) * 0.5
	# 431 Tuch (Sokrates 15.11., 17:29, Bedingung 2): Kantenecken von hinten spiegelgleich (±1 cm), Kragen liegt auf (Abstand Netz–Haut
	# über Schulter und Oberarm ≤ 3 cm), kein Durchstoßen von Haut (Rumpf, Arm) und Schild, auch mit gehobenem Arm (Sword_Attack)
	var tuch_mi := []
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var x := mi as MeshInstance3D
		if x.skin == null or x.get_parent() is BoneAttachment3D: continue
		var rn := ""
		for si in x.mesh.get_surface_count():
			var mt := x.mesh.surface_get_material(si)
			if mt: rn += String(mt.resource_name)
		if String(x.name).contains("Kleid") or rn.contains("held"): tuch_mi.append(x)
	var ecke := []   # [links, rechts] Index der unteren Ecken, beim ersten Bild im Stehen bestimmt (die Ruhelage ist gegen das Stehen gekippt)
	var mess := {"an": false, "ecke": 0.0, "n_ecke": 0, "schild": 0.0}
	var gesehen := {}
	var gesehen_w := {}   # Enden im Raum der Figur: Sprung dort (im Raum von spine_03 ist ein Nachschwingen beim Drehen des Rumpfs kein Sprung)
	sk.skeleton_updated.connect(func():
		if mess["an"]:
			mess["an"] = false
			_tuch_mess(sk, tuch_mi, mess, ecke)
		for s in enden:
			gesehen[s] = _ende(sk, enden[s], bi, false)
			gesehen_w[s] = sk.get_bone_global_pose(enden[s]) * Vector3(0, sk.get_bone_rest(enden[s]).origin.length(), 0)
		for sp in rand:
			var g: Array = rand[sp]
			var p0 := sk.get_bone_global_pose(g[0]).origin
			var pe := sk.get_bone_global_pose(g[-1]) * Vector3(0, sk.get_bone_rest(g[-1]).origin.length(), 0)
			for b in g.slice(1):
				var q := sk.get_bone_global_pose(b).origin
				knick[0] = maxf(knick[0], q.distance_to(Geometry3D.get_closest_point_to_segment(q, p0, pe)))
		for a in arme:
			var p0 := sk.get_bone_global_pose(a[0]).origin; var p1 := sk.get_bone_global_pose(a[1]).origin
			for g in aussen:
				var q := sk.get_bone_global_pose(g).origin
				arm_tief[0] = maxf(arm_tief[0], float(a[2]) + Umhang.GLIED_RADIUS - q.distance_to(Geometry3D.get_closest_point_to_segment(q, p0, p1))))
	var bad := 0
	for paar in [["Stehen", "Idle_Loop", schild], ["Gehen", "Walk_Loop", schild], ["Arm gehoben", "Sword_Attack", schild]]:   # Namen aus held_klassen.py oder der UAL
		if paar[2] and sk.find_children("Ruecken*", "BoneAttachment3D", false, false).is_empty():
			# Lauf 9 (E8): Schild und Schwert wie im Spiel (HeldFigur.bewaffne) über dem Umhang, als Kapseln; Spalt zum Rücken samt Umhang
			ap.play(String(paar[0]) if ap.has_animation(String(paar[0])) else String(paar[1])); ap.seek(0.0, true); ap.stop()
			HeldFigur.bewaffne(m, sk, {"OFF_HAND": {"base": "shield"}, "MAIN_HAND": {"base": "longsword"}})
			for ba in sk.find_children("Ruecken*", "BoneAttachment3D", false, false):
				for d in ba.get_children(): if d is Node3D: Umhang.ruecken(sim, sk, d)
			await process_frame
			var spalt := _spalt(m, sk)
			print("UMHANG431 %s Schild: Spalt zum Rücken %.1f cm, Kapseln %d" % [name, spalt * 100, (sim.get_child_count() if sim else 0)])
			if spalt > 0.04: print("UMHANG431 %s Hinweis (1297, nicht 431): Schild %.0f cm hinter dem Rücken" % [name, spalt * 100])
		var bew: String = paar[0] if ap.has_animation(paar[0]) else String(paar[1])
		if not ap.has_animation(bew): print("UMHANG431 %s FALSCH: ohne %s" % [name, paar[0]]); bad += 1; continue
		ap.play(bew)
		var seit := 0.0; var spiegel_v := Vector3.ZERO; var n := 0; var sack := 0.0; var sprung := 0.0; var mweg := Vector3.ZERO
		var vor := {}; var vor_w := {}; var sprung_w := 0.0
		mess["ecke"] = 0.0; mess["schild"] = 0.0; mess["n_ecke"] = 0
		for i in int(3.0 * FPS):
			if i == 15: arm_tief[0] = 0.0; knick[0] = 0.0
			if i >= 15 and i % 6 == 0: mess["an"] = true
			if OS.get_environment("TUCH_T0") != "" and paar[0] == "Stehen": ap.seek(0.0, true)
			await process_frame
			if i < 15: continue   # einschwingen
			var p := gesehen.duplicate()   # Lage nach den Modifikatoren (skeleton_updated), sonst sieht man die Federung nicht
			var pw := gesehen_w.duplicate()
			for s in pw:
				if vor_w.has(s): sprung_w = maxf(sprung_w, (pw[s] - vor_w[s]).length())
			vor_w = pw
			if p.is_empty(): continue
			# seitlich: wie weit ein aeusseres Ende quer ueber seine Ruhelage hinaus nach aussen geht
			seit = maxf(seit, maxf((p["l2"] - bau["l2"]).dot(nrm), -(p["r2"] - bau["r2"]).dot(nrm)))
			# Spiegel: rechtes Ende an der Ebene gespiegelt gegen das linke (Mittel ueber die Schritte)
			var r: Vector3 = p["r2"] - 2.0 * (p["r2"] - mitte).dot(nrm) * nrm
			spiegel_v += r - p["l2"]; n += 1
			if p.has("m") and (bau["m"] - p["m"]).length() > sack: sack = (bau["m"] - p["m"]).length(); mweg = p["m"] - bau["m"]
			for s in p:
				if vor.has(s): sprung = maxf(sprung, (p[s] - vor[s]).length())
			vor = p
		var sp := (spiegel_v / maxf(n, 1)).length()   # 0: links und rechts gleich
		print("UMHANG431 %s %s%s: seitlich %.1f cm, Spiegel %.1f cm, Mitte weg %.1f cm %s, Sprung %.1f cm je Bild, Arm im Umhang %.1f cm, Saum Knick %.1f cm, Kapseln %d" % [name, bew,
			" mit Schild" if paar[2] else "", seit * 100, sp * 100, sack * 100, str(mweg * 100).replace(" ", ""), sprung * 100, arm_tief[0] * 100, knick[0] * 100, (sim.get_child_count() if sim else 0)])
		# 431 Tuch: Sprung im Raum der Figur (FALSCH über 25 cm je Bild); der Wert im Raum von spine_03 steht oben
		if sprung_w > 0.25: bad += 1; print("UMHANG431 %s FALSCH: Ende springt %.0f cm" % [name, sprung_w * 100])
		var ek: float = mess["ecke"] / maxf(mess["n_ecke"], 1)
		print("UMHANG431 TUCH %s %s%s: Kantenecken links/rechts %.1f cm, Sprung %.1f cm je Bild%s" % [name, bew,
			" mit Schild" if paar[2] else "", ek * 100, sprung_w * 100, (", durch den Schild %.1f cm" % (mess["schild"] * 100)) if paar[2] else ""])
	m.queue_free()
	await process_frame
	return bad


func _ende(sk: Skeleton3D, b: int, bezug: int, ruhe: bool) -> Vector3:
	var t := sk.get_bone_global_rest(b) if ruhe else sk.get_bone_global_pose(b)
	var bt := sk.get_bone_global_rest(bezug) if ruhe else sk.get_bone_global_pose(bezug)
	var l := sk.get_bone_rest(b).origin.length()   # Ende des letzten Glieds: so lang wie das Glied davor
	return bt.affine_inverse() * (t * Vector3(0, l, 0))


## kleinster Abstand zwischen der Innenseite des Rückenschilds und der Haut samt Umhang (Raum der Figur, Mitte ±20 cm)
func _spalt(m: Node3D, sk: Skeleton3D) -> float:
	var lagen := HeldFigur.haltung_lagen(m, sk, "Stehen")   # wie bewaffne: Haut in der Haltung, in der der Schild gelegt wird
	var haut := HeldFigur.haut_punkte(m, sk, not lagen.is_empty(), null, lagen)
	var weg := INF
	for ba in sk.find_children("RueckenSchild", "BoneAttachment3D", false, false):
		for mi in (ba as Node3D).find_children("*", "MeshInstance3D", true, false):
			var t := m.global_transform.affine_inverse() * (mi as MeshInstance3D).global_transform
			var mesh := (mi as MeshInstance3D).mesh
			for s in mesh.get_surface_count():
				var vs: PackedVector3Array = mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]
				for i in range(0, vs.size(), maxi(1, vs.size() / 400)):
					var v := t * vs[i]
					for h in haut:
						if absf(h.y - v.y) < 0.05: weg = minf(weg, h.distance_to(v))
	return weg


## Netze mit Haut im Raum des Skeletts (Ruhelage oder jetzige Lage), dazu Normalen und je Ecke, ob sie am Arm hängt (stärkstes Gewicht)
func _skin(mis: Array, sk: Skeleton3D, ruhe: bool) -> Array:
	var pos := PackedVector3Array(); var nrm := PackedVector3Array(); var arm := PackedByteArray(); var idx := PackedInt32Array()
	var gl := []
	for b in sk.get_bone_count(): gl.append(sk.get_bone_global_rest(b) if ruhe else sk.get_bone_global_pose(b))
	for mi in mis:
		var x := mi as MeshInstance3D
		for s in x.mesh.get_surface_count():
			var ar := x.mesh.surface_get_arrays(s)
			var vs: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
			var ns: PackedVector3Array = ar[Mesh.ARRAY_NORMAL]
			var bo: PackedInt32Array = ar[Mesh.ARRAY_BONES]; var we: PackedFloat32Array = ar[Mesh.ARRAY_WEIGHTS]
			if bo.is_empty(): continue
			var n := bo.size() / vs.size()
			var off := pos.size()
			var ix = ar[Mesh.ARRAY_INDEX]
			if ix != null:
				for e in (ix as PackedInt32Array): idx.append(off + e)
			for i in vs.size():
				var p := Vector3.ZERO; var q := Vector3.ZERO; var best := 0.0; var bb := -1
				for j in n:
					var g: float = we[i * n + j]
					if g <= 0.0: continue
					var bind: int = bo[i * n + j]
					var bone := x.skin.get_bind_bone(bind)
					if bone < 0: bone = sk.find_bone(x.skin.get_bind_name(bind))
					var t: Transform3D = gl[bone] * x.skin.get_bind_pose(bind)
					p += (t * vs[i]) * g; q += (t.basis * ns[i]) * g
					if g > best: best = g; bb = bone
				pos.append(p); nrm.append(q.normalized())
				var bn := sk.get_bone_name(bb) if bb >= 0 else ""
				arm.append(1 if (bn.begins_with("upperarm") or bn.begins_with("lowerarm") or bn.begins_with("hand")) else 0)
	return [pos, nrm, arm, idx]


## untere Ecken des Tuchs in der Ruhelage: tiefste Reihe, äußerste links und rechts (x > 0 und x < 0)
func _ecken(p: PackedVector3Array) -> Array:
	var y0 := INF
	for v in p: y0 = minf(y0, v.y)
	var l := -1; var r := -1
	for i in p.size():
		if p[i].y > y0 + 0.01: continue
		if l < 0 or p[i].x > p[l].x: l = i
		if r < 0 or p[i].x < p[r].x: r = i
	return [l, r]


func _tuch_mess(sk: Skeleton3D, tuch_mi: Array, mess: Dictionary, ecke: Array) -> void:
	var t := _skin(tuch_mi, sk, false)
	var tp: PackedVector3Array = t[0]
	var sh := sk.get_bone_global_pose(sk.find_bone("spine_03")).origin
	# Kantenecken von hinten: gleich hoch und gleich weit von der Achse des Rumpfs (senkrecht durch spine_03), größerer Unterschied
	if ecke.is_empty(): ecke.append_array(_ecken(tp))
	if ecke[0] >= 0 and ecke[1] >= 0:
		var a := tp[ecke[0]]; var b := tp[ecke[1]]
		var da := Vector2(a.x - sh.x, a.z - sh.z).length(); var db := Vector2(b.x - sh.x, b.z - sh.z).length()
		mess["ecke"] += maxf(absf(a.y - b.y), absf(da - db)); mess["n_ecke"] += 1
	# Schild durchstoßen: eine Tuchecke liegt im Umriss des Schilds weiter außen (vom Rücken weg) als seine Außenseite
	for ba in sk.find_children("RueckenSchild", "BoneAttachment3D", false, false):
		var pts := PackedVector3Array()
		for mi in (ba as Node3D).find_children("*", "MeshInstance3D", true, false):
			var x := mi as MeshInstance3D
			var tr := sk.global_transform.affine_inverse() * x.global_transform
			for si in x.mesh.get_surface_count():
				for v in (x.mesh.surface_get_arrays(si)[Mesh.ARRAY_VERTEX] as PackedVector3Array): pts.append(tr * v)
		if pts.size() < 8: continue
		var c := Vector3.ZERO
		for q in pts: c += q
		c /= pts.size()
		var aus := (c - sh); aus.y = 0.0; aus = aus.normalized()   # vom Rücken weg
		var u := Vector3.UP.cross(aus).normalized(); var w := Vector3.UP
		const ZS := 0.02
		var aussen := {}   # Zelle (u, w) -> größte Höhe längs aus
		for q in pts:
			var kz := Vector2i(floori((q - c).dot(u) / ZS), floori((q - c).dot(w) / ZS))
			aussen[kz] = maxf(aussen.get(kz, -INF), (q - c).dot(aus))
		for v in tp:
			var kz := Vector2i(floori((v - c).dot(u) / ZS), floori((v - c).dot(w) / ZS))
			if aussen.has(kz):
				mess["schild"] = maxf(mess["schild"], (v - c).dot(aus) - float(aussen[kz]))

