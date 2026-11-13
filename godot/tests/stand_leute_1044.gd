extends SceneTree
# 1044 (Fund t283.3, Chef 13.11., 15:38/15:42: „Wie steht Osric? … ist das nicht der Kampfstand?“): ohne Bild. Jede Person des Dorfs
# auf dem Kaufkörper wie im Spiel (HeldFigur.person): hat ihr AnimationPlayer jede Ruhebewegung aus HeldFigur.ruhe_von (fehlt eine,
# lässt Gebiet.ruhe_naechste sie still weg)? Und wie stehen die Arme: je Bewegung bei 0, ¼, ½, ¾ der Länge der Winkel des Oberarms
# gegen die Senkrechte (abgespreizt), die Beugung im Ellbogen und der Abstand der Füße, dazu dieselben Werte in der Ruhelage
# (ohne Bewegung) und im Kampfstehen des Helden zum Vergleich. Rot nur, wenn eine Ruhebewegung fehlt oder eine Person nicht baut.
# Nur mit Kaufdaten (im Bau); am Rechner ohne sie übersprungen. Aufruf im Ordner godot: -s res://tests/stand_leute_1044.gd
# -> „STAND1044 n Fehler“

var fehler := 0

func _initialize() -> void: _lauf.call_deferred()

func winkel(sk: Skeleton3D, a: String, b: String) -> float:
	var pa := sk.get_bone_global_pose(sk.find_bone(a)).origin
	var pb := sk.get_bone_global_pose(sk.find_bone(b)).origin
	return rad_to_deg((pb - pa).normalized().angle_to(Vector3.DOWN))

func beuge(sk: Skeleton3D, s: String) -> float:
	var o := sk.get_bone_global_pose(sk.find_bone("upperarm_" + s)).origin
	var u := sk.get_bone_global_pose(sk.find_bone("lowerarm_" + s)).origin
	var h := sk.get_bone_global_pose(sk.find_bone("hand_" + s)).origin
	return 180.0 - rad_to_deg((o - u).angle_to(h - u))

func fuesse(sk: Skeleton3D) -> float:
	return sk.get_bone_global_pose(sk.find_bone("foot_l")).origin.distance_to(sk.get_bone_global_pose(sk.find_bone("foot_r")).origin)

func lage(sk: Skeleton3D) -> String:
	return "Arm L %3.0f° R %3.0f°, Ellbogen L %3.0f° R %3.0f°, Füße %.2f m" % [winkel(sk, "upperarm_l", "lowerarm_l"), winkel(sk, "upperarm_r", "lowerarm_r"),
		beuge(sk, "l"), beuge(sk, "r"), fuesse(sk)]

func _lauf() -> void:
	var ids: Array = ["osric", "aldric", "rowena", "thessa", "jorin", "borin", "garrick", "morwen", "gwenna", "pim", "bram", "liska", "lyra"]
	var gebaut := 0
	for id in ids:
		var m := HeldFigur.person(String(id), [])
		if m == null:
			print("STAND1044 %s: ohne Kaufmodell" % id)
			continue
		gebaut += 1
		root.add_child(m)
		for i in 2: await process_frame
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var ap := m.get_node_or_null("AnimationPlayer") as AnimationPlayer
		if sk == null or ap == null:
			print("FEHLER %s: kein Skelett oder AnimationPlayer" % id); fehler += 1; m.queue_free(); continue
		for b in ["upperarm_l", "lowerarm_l", "hand_l", "upperarm_r", "lowerarm_r", "hand_r", "foot_l", "foot_r"]:
			if sk.find_bone(b) < 0: print("FEHLER %s: Knochen %s fehlt" % [id, b]); fehler += 1
		ap.stop()
		sk.reset_bone_poses()
		print("STAND1044 %s Ruhelage: %s" % [id, lage(sk)])
		var soll: Array = HeldFigur.ruhe_von(String(id))
		var fehlt := soll.filter(func(n): return not ap.has_animation(n))
		if not fehlt.is_empty():
			var da: Array = []
			for n in ap.get_animation_list():
				if ["Stehen", "Ruhe", "Gesten", "Drehen"].any(func(v): return String(n).begins_with(v)): da.append(String(n))
			print("FEHLER %s: Ruhebewegung fehlt im Modell: %s (vorhanden: %s)" % [id, fehlt, ", ".join(PackedStringArray(da))])
			fehler += 1
		for n in soll:
			if not ap.has_animation(n): continue
			var a := ap.get_animation(n)
			ap.play(n)
			for q in [0.0, 0.25, 0.5, 0.75]:
				ap.seek(a.length * q, true)
				print("STAND1044 %s %s %.2f: %s" % [id, n, q, lage(sk)])
		m.queue_free()
		await process_frame
	# Vergleich: der Held im Kampfstehen (kampf-bewegungen)
	if ResourceLoader.exists("res://daten/kampf-bewegungen.bin") or FileAccess.file_exists("res://daten/kampf-bewegungen.bin"):
		var kb := Gebiet.lade_glb("res://daten/kampf-bewegungen.bin")
		if kb != null:
			root.add_child(kb)
			await process_frame
			var kap := Gebiet.finde(kb, "AnimationPlayer") as AnimationPlayer
			var ksk := Gebiet.finde(kb, "Skeleton3D") as Skeleton3D
			if kap and ksk and kap.has_animation("Kampfstehen"):
				kap.play("Kampfstehen"); kap.seek(0.5, true)
				print("STAND1044 Vergleich Kampfstehen: %s" % lage(ksk))
	if gebaut == 0: print("STAND1044 keine Kaufmodelle (am Rechner ohne Bau)")
	print("STAND1044 %d Fehler" % fehler)
	quit(1 if fehler else 0)
