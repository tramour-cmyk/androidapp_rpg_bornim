# 431 Stufe 1 (Chef 15.11., 12:43 „431g A“): Messung des Umhangs aus dem Kleiderschrank (kleiderschrank.py) mit Federkette
# (skripte/umhang.gd), ohne Bild: je Koerper Stehen und Gehen, je Bild die Enden der Ketten im Raum des Beckens.
# Zeilen UMHANG431 <datei> <bewegung> im Raum von spine_03: seitlich (cm, wie weit ein aeusseres Ende quer ueber seine Ruhelage hinaus
# nach aussen geht, 861: Beule), Spiegel (cm, rechtes Ende gespiegelt gegen das linke, Mittel ueber die Bilder), Mitte weg (cm, groesste
# Abweichung des mittleren Endes von der Bauform),
# Kapseln (Anzahl); mit Schild (daten/waffen/shield.bin da) ein zweites Mal frisch geladen, Schild und Schwert wie im Spiel (bewaffne),
# dazu Spalt (cm, kleinster Abstand Innenseite Schild zu Haut samt Umhang in „Stehen“). FALSCH bei Spalt über 4 cm, wenn keine Kette da ist oder ein Ende weiter als 25 cm springt.
# Aufruf: UMHANG=<ordner mit umhang_*.glb> godot --headless --path godot -s res://tests/umhang_431.gd
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
		if f.begins_with("umhang_") and f.ends_with(".glb"): dateien.append(f)
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
	var sim := Umhang.an(m, sk)
	var enden := {}
	for e in k: enden[e[0]] = sk.find_bone("umhang_%s_%d" % [e[0], e[1]])
	var bi := sk.find_bone("spine_03")
	# Bauform: Enden in der Ruhelage im Raum von spine_03 (dort haengt die Kette); Spiegelebene aus den aeusseren Enden der Ruhelage
	var bau := {}
	for s in enden: bau[s] = _ende(sk, enden[s], bi, true)
	if not (bau.has("l2") and bau.has("r2")):
		print("UMHANG431 %s FALSCH: ohne aeussere Ketten" % name); m.free(); return 1
	var nrm: Vector3 = (bau["l2"] - bau["r2"]).normalized()
	var mitte: Vector3 = (bau["l2"] + bau["r2"]) * 0.5
	var gesehen := {}
	sk.skeleton_updated.connect(func():
		for s in enden: gesehen[s] = _ende(sk, enden[s], bi, false))
	var bad := 0
	for paar in [["Stehen", "Idle_Loop", schild], ["Gehen", "Walk_Loop", schild]]:   # Namen aus held_klassen.py oder der UAL
		if paar[2] and sk.find_children("Ruecken*", "BoneAttachment3D", false, false).is_empty():
			# Lauf 9 (E8): Schild und Schwert wie im Spiel (HeldFigur.bewaffne) über dem Umhang, als Kapseln; Spalt zum Rücken samt Umhang
			ap.play(String(paar[0]) if ap.has_animation(String(paar[0])) else String(paar[1])); ap.seek(0.0, true); ap.stop()
			HeldFigur.bewaffne(m, sk, {"OFF_HAND": {"base": "shield"}, "MAIN_HAND": {"base": "longsword"}})
			for ba in sk.find_children("Ruecken*", "BoneAttachment3D", false, false):
				for d in ba.get_children(): if d is Node3D: Umhang.ruecken(sim, sk, d)
			await process_frame
			var spalt := _spalt(m, sk)
			print("UMHANG431 %s Schild: Spalt zum Rücken %.1f cm, Kapseln %d" % [name, spalt * 100, sim.get_child_count()])
			if spalt > 0.04: bad += 1; print("UMHANG431 %s FALSCH: Schild schwebt %.0f cm hinter dem Rücken" % [name, spalt * 100])
		var bew: String = paar[0] if ap.has_animation(paar[0]) else String(paar[1])
		if not ap.has_animation(bew): print("UMHANG431 %s FALSCH: ohne %s" % [name, paar[0]]); bad += 1; continue
		ap.play(bew)
		var seit := 0.0; var spiegel_v := Vector3.ZERO; var n := 0; var sack := 0.0; var sprung := 0.0; var mweg := Vector3.ZERO
		var vor := {}
		for i in int(3.0 * FPS):
			await process_frame
			if i < 15: continue   # einschwingen
			var p := gesehen.duplicate()   # Lage nach den Modifikatoren (skeleton_updated), sonst sieht man die Federung nicht
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
		print("UMHANG431 %s %s%s: seitlich %.1f cm, Spiegel %.1f cm, Mitte weg %.1f cm %s, Sprung %.1f cm je Bild, Kapseln %d" % [name, bew,
			" mit Schild" if paar[2] else "", seit * 100, sp * 100, sack * 100, str(mweg * 100).replace(" ", ""), sprung * 100, sim.get_child_count()])
		if sprung > 0.25: bad += 1; print("UMHANG431 %s FALSCH: Ende springt %.0f cm" % [name, sprung * 100])
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
