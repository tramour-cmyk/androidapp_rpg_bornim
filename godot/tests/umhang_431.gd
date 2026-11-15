# 431 Stufe 1 (Chef 15.11., 12:43 „431g A“): Messung des Umhangs aus dem Kleiderschrank (kleiderschrank.py) mit Federkette
# (skripte/umhang.gd), ohne Bild: je Koerper Stehen und Gehen, je Bild die Enden der Ketten im Raum des Beckens.
# Zeilen UMHANG431 <datei> <bewegung> im Raum von spine_03: seitlich (cm, wie weit ein aeusseres Ende quer ueber seine Ruhelage hinaus
# nach aussen geht, 861: Beule), Spiegel (cm, rechtes Ende gespiegelt gegen das linke, Mittel ueber die Bilder), Mitte weg (cm, groesste
# Abweichung des mittleren Endes von der Bauform),
# Kapseln (Anzahl). FALSCH, wenn keine Kette da ist oder ein Ende weiter als 25 cm springt.
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
		falsch += await _messe(dir.path_join(f), f)
	print("UMHANG431 %d Koerper, %d falsch" % [dateien.size(), falsch])
	quit(1 if falsch > 0 or dateien.is_empty() else 0)


func _messe(pfad: String, name: String) -> int:
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
	for paar in [["Stehen", "Idle_Loop"], ["Gehen", "Walk_Loop"]]:   # Namen aus held_klassen.py oder der UAL
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
		print("UMHANG431 %s %s: seitlich %.1f cm, Spiegel %.1f cm, Mitte weg %.1f cm %s, Sprung %.1f cm je Bild, Kapseln %d" % [name, bew,
			seit * 100, sp * 100, sack * 100, str(mweg * 100).replace(" ", ""), sprung * 100, sim.get_child_count()])
		if sprung > 0.25: bad += 1; print("UMHANG431 %s FALSCH: Ende springt %.0f cm" % [name, sprung * 100])
	m.queue_free()
	await process_frame
	return bad


func _ende(sk: Skeleton3D, b: int, bezug: int, ruhe: bool) -> Vector3:
	var t := sk.get_bone_global_rest(b) if ruhe else sk.get_bone_global_pose(b)
	var bt := sk.get_bone_global_rest(bezug) if ruhe else sk.get_bone_global_pose(bezug)
	var l := sk.get_bone_rest(b).origin.length()   # Ende des letzten Glieds: so lang wie das Glied davor
	return bt.affine_inverse() * (t * Vector3(0, l, 0))
