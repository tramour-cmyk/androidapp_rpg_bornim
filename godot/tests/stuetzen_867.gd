extends SceneTree
# 867 (Sokrates 13.11., 00:25 „B mit Mitte“): Wachsoldatin stuetzt beide Haende auf das Schwert (HauptmenueHelden.SchwertStuetzen) an
# der freien Grundfigur der UAL (CC0, Quaternius), mit Schwert und Schild aus den Massen von regeln/halt.json als Kasten und Scheibe,
# wenn daten/waffen fehlt. Misst ohne Bild: Faust neben dem Ziel (fehl), Spitze ueber dem Boden, Schild neben dem Bein.
# Am Rechner (im Ordner godot):
#   godot --headless --path . -s res://tests/stuetzen_867.gd -- --ual=<UAL1_Standard.glb>
# Massgeblich ist die Zeile STUETZEN867.

var ual := ""

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ual="): ual = a.substr(6)
	_lauf.call_deferred()

func kasten(groesse: Vector3, mitte: Vector3, farbe: Color) -> Node3D:
	var n := Node3D.new()
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = groesse
	mi.mesh = bm
	mi.position = mitte
	var mt := StandardMaterial3D.new()
	mt.albedo_color = farbe
	mi.material_override = mt
	n.add_child(mi)
	return n

func _lauf() -> void:
	var fehler := 0
	if ual == "" or not FileAccess.file_exists(ual):
		print("STUETZEN867 ohne Grundfigur (--ual=)"); quit(0); return
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	doc.append_from_file(ual, st)
	var m := doc.generate_scene(st) as Node3D
	var trg := Node3D.new()
	trg.rotation.y = deg_to_rad(35.0)
	root.add_child(trg)
	trg.add_child(m)
	var sk := m.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	var ap := m.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	var bew := "Idle_Loop" if ap.has_animation("Idle_Loop") else String(ap.get_animation_list()[0])
	ap.play(bew)
	var s := HauptmenueHelden.SchwertStuetzen.new()
	s.modell = trg
	s.faeuste = {"r": HeldFigur.faust(sk, "r"), "l": HeldFigur.faust(sk, "l")}
	s.halt = Halt.gegenstand("longsword")
	if s.halt.is_empty(): s.halt = Halt.aus_feld(Halt.feld().get("longsword", {}))
	s.schild_halt = Halt.gegenstand("round_shield")
	if s.schild_halt.is_empty(): s.schild_halt = Halt.aus_feld(Halt.feld().get("round_shield", {}))
	var hs: AABB = s.halt["kasten"]
	s.waffe = kasten(Vector3(0.05, hs.size.y, 0.012), hs.get_center(), Color(0.8, 0.8, 0.85))
	s.waffe.top_level = true
	trg.add_child(s.waffe)
	var ks: AABB = s.schild_halt["kasten"]
	s.schild = kasten(ks.size, ks.get_center(), Color(0.6, 0.4, 0.15))
	s.schild.top_level = true
	trg.add_child(s.schild)
	s.kamera = Vector3(1.32, 1.07, 4.98)   # wie im Hauptmenue: die Wachsoldatin steht bei x -1,32
	sk.add_child(s)
	s.protokoll = "--protokoll" in OS.get_cmdline_user_args()
	for k in 2: await process_frame
	s.protokoll = false
	for k in 4: await process_frame
	print("STUETZEN867 Bewegung %s, Faust rechts %.1f cm neben dem Ziel, links %.1f cm, Spitze %.1f cm ueber dem Boden, %d-mal zur Schulter gerueckt" % [bew, s.fehl_r * 100.0, s.fehl_l * 100.0, s.spitze_hoehe * 100.0, s.gerueckt])
	if s.fehl_r > 0.03 or s.fehl_l > 0.03:
		print("FEHLER Faust nicht am Griff"); fehler += 1
	if absf(s.spitze_hoehe) > 0.02:
		print("FEHLER Spitze nicht am Boden"); fehler += 1
	var nah := schild_abstand(s, sk)
	print("STUETZEN867 Schild seite %.2f vor %.2f neig %.0f: %s" % [s.schild_seite, s.schild_vor, s.schild_neig, nah[1]])
	if nah[0] < 0.07:
		print("FEHLER Schild im Bein oder Arm (Knochenlinie unter 7 cm)"); fehler += 1
	if "--proben" in OS.get_cmdline_user_args():
		for c in [[0.34, 0.10, 15.0], [0.42, 0.10, 10.0], [0.38, 0.18, 10.0], [0.36, 0.24, 8.0], [0.44, 0.16, 8.0], [0.40, 0.22, 6.0], [0.46, 0.06, 8.0]]:
			s.schild_seite = c[0]; s.schild_vor = c[1]; s.schild_neig = c[2]
			for k in 3: await process_frame
			print("STUETZEN867 Probe seite %.2f vor %.2f neig %.0f: %s" % [c[0], c[1], c[2], schild_abstand(s, sk)[1]])
	for sd in ["r", "l"]:
		var A := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("upperarm_" + sd)).origin
		var l1 := sk.get_bone_rest(sk.find_bone("lowerarm_" + sd)).origin.length()
		var l2 := sk.get_bone_rest(sk.find_bone("hand_" + sd)).origin.length()
		var f: Dictionary = s.faeuste[sd]
		print("STUETZEN867 Schulter %s %s, Arm %.3f + %.3f, Faust %s, Massstab %s" % [sd, A, l1, l2, f.get("griff"), sk.global_basis.get_scale()])
	print("STUETZEN867 %d Fehler" % fehler)
	quit(1 if fehler else 0)


## Schild als Scheibe (Mitte, Normale, Halbmesser) gegen die Knochenlinien von Beinen und linkem Arm: kleinster Abstand; dazu die
## Waagrechte der Raender im Hauptmenue (die Wachsoldatin steht dort bei x -1,32; der Zauberlehrling ab etwa -0,69)
func schild_abstand(s, sk: Skeleton3D) -> Array:
	var sm: Vector3 = s.schild.global_transform * (s.schild_halt["kasten"] as AABB).get_center()
	var sn: Vector3 = s.schild.global_basis.z.normalized()
	var rad: float = (s.schild_halt["kasten"] as AABB).size.x * 0.5
	var nah := 99.0
	var wo := ""
	for kette in [["thigh_l", "calf_l", "foot_l"], ["thigh_r", "calf_r", "foot_r"], ["upperarm_l", "lowerarm_l", "hand_l"]]:
		for i in 2:
			var a := sk.global_transform * sk.get_bone_global_pose(sk.find_bone(kette[i])).origin
			var b := sk.global_transform * sk.get_bone_global_pose(sk.find_bone(kette[i + 1])).origin
			for t in 11:
				var q := a.lerp(b, t / 10.0)
				var r := q - sm
				var e := r - sn * r.dot(sn)
				var d := Vector2(maxf(0.0, e.length() - rad), r.dot(sn)).length()
				if d < nah: nah = d; wo = kette[i]
	var xr: Vector3 = s.schild.global_basis.x.normalized() * rad
	var w := rad_to_deg(Vector2(sn.x, sn.z).angle_to(Vector2(s.kamera.x - sm.x, s.kamera.z - sm.z)))
	return [nah, "naechster Knochen %s %.1f cm, Flaeche zur Kamera %.0f Grad daneben, im Menue x %.2f bis %.2f, z %.2f" % [wo, nah * 100.0, w, minf((sm - xr).x, (sm + xr).x) - 1.32, maxf((sm - xr).x, (sm + xr).x) - 1.32, sm.z]]
