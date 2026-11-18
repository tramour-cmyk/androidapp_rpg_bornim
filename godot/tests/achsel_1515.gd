# 1515 (Chef 17.11., 07:32, Bild Hauptmenü Build 295): vor dem Schild der Wachsoldatin „ein weißes Etwas“. Ursache (Messung Tom 08:06):
# Dreiecke des Kettenhemds an der Achsel verbanden Ecken am Unterarm mit Ecken an der Brust; ging der Arm vom Körper weg, spannte sich
# das Stück vom Gürtel zum Arm. Ohne Bild: je Tracht der Menühelden die Dreiecke der Kleidung, deren Ecken (nach dem größten Gewicht) an
# Unterarm oder Hand und zugleich an Becken oder Rumpf hängen; dazu die Leute (held_L_*, 1535). Erlaubt: keins.
# Run: godot --headless --path godot -s res://tests/achsel_1515.gd   (ohne Kaufdateien „ohne Kauf“, 0)
extends SceneTree

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	if not HauptmenueHelden.da():
		print("ACHSEL1515 ohne Kauf, 0 Fehler")
		quit(0)
		return
	for h in HauptmenueHelden.HELDEN:
		var m: Node3D = HeldFigur.baue(HauptmenueHelden.wahl(h), [])
		if m == null: continue
		root.add_child(m)
		await process_frame
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		for me_ in sk.find_children("*", "MeshInstance3D", true, false):
			var me := me_ as MeshInstance3D
			if me.skin == null or me.mesh == null: continue
			var n := _bruecken(sk, me)
			if n > 0 or String(me.name) == "Kleid": print("ACHSEL1515 %s %s: %d Dreiecke Unterarm–Rumpf" % [h["herkunft"], me.name, n])
			if n > 0:
				print("FEHLER %s %s: %d Dreiecke verbinden Unterarm und Rumpf" % [h["herkunft"], me.name, n])
				fehler += 1
		m.queue_free()
		await process_frame
	# 1535 (Chef 17.11., 09:18: Kleidung hängt auch bei anderen Leuten in der Ruhebewegung an einer Hand): die Leute auf dem Kaufkörper
	var d := DirAccess.open("res://daten")
	if d:
		for f in d.get_files():
			if not (f.begins_with("held_L_") and f.ends_with(".bin")): continue
			var sc := Gebiet.lade_glb("res://daten/" + f)
			if sc == null: continue
			root.add_child(sc)
			await process_frame
			var sk2 := Gebiet.finde(sc, "Skeleton3D") as Skeleton3D
			if sk2:
				for me_ in sk2.find_children("*", "MeshInstance3D", true, false):
					var me := me_ as MeshInstance3D
					if me.skin == null or me.mesh == null: continue
					var n := _bruecken(sk2, me)
					if n > 0:
						print("FEHLER %s %s: %d Dreiecke verbinden Unterarm und Rumpf" % [f, me.name, n])
						fehler += 1
			sc.queue_free()
			await process_frame
	print("ACHSEL1515 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func _bruecken(sk: Skeleton3D, me: MeshInstance3D) -> int:
	var bind := []
	for i in me.skin.get_bind_count():
		var bn := me.skin.get_bind_name(i)
		bind.append(sk.find_bone(bn) if bn != "" else me.skin.get_bind_bone(i))
	var zahl := 0
	for s in me.mesh.get_surface_count():
		var a := me.mesh.surface_get_arrays(s)
		var vs: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		var bs = a[Mesh.ARRAY_BONES]; var ws = a[Mesh.ARRAY_WEIGHTS]
		var ix = a[Mesh.ARRAY_INDEX]
		if bs == null or ws == null or ix == null or vs.is_empty(): continue
		var n := int(bs.size() / vs.size())
		var art := PackedInt32Array()   # 1 Unterarm/Hand, 2 Rumpf, 0 sonst
		art.resize(vs.size())
		for vi in vs.size():
			var best := -1; var bw := 0.0
			for k in n:
				if ws[vi * n + k] > bw: bw = ws[vi * n + k]; best = bind[bs[vi * n + k]]
			var bn := sk.get_bone_name(best) if best >= 0 else ""
			# 1515 Runde 2 (Chef 21:45): Finger zaehlen zur Hand, Oberschenkel und alles ausser Arm und Schluesselbein zum Koerper
			# (Wache W: 13 Flaechen Oberschenkel–Daumen, 70 cm, fing der alte Test nicht)
			var hand := bn.begins_with("lowerarm") or bn.begins_with("hand_")
			for f in ["thumb", "index", "middle", "ring", "pinky"]: hand = hand or bn.begins_with(f)
			var armkette := hand or bn.begins_with("upperarm") or bn.begins_with("clavicle") or bn == ""
			art[vi] = 1 if hand else (0 if armkette else 2)
		for t in range(0, ix.size(), 3):
			var g := [art[ix[t]], art[ix[t + 1]], art[ix[t + 2]]]
			if not (1 in g and 2 in g): continue
			var p0 := vs[ix[t]]; var p1 := vs[ix[t + 1]]; var p2 := vs[ix[t + 2]]
			if maxf(p0.distance_to(p1), maxf(p1.distance_to(p2), p2.distance_to(p0))) > 0.12: zahl += 1
	return zahl
