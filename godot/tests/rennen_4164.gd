extends SceneTree
# 416.4 (Chef 31.10., Build 143: Rennen des Helden wirkt „als würde er Hochsprung machen“): ohne Bild gemessen an der UAL (CC0, Pfad in
# UAL=…): je Lauf-Bewegung Tempo ohne Gleiten (Standfuss gleitet zurueck wie schritt_tempo in held_klassen.py), Hub des Beckens, Schritte
# Anteil ohne Bodenkontakt, Rumpfneigung; dazu, wie schnell held.gd sie im Rennen abspielt (Rennen 3,68 Kacheln/s × 1,16 m). Aufruf im Ordner godot:
# UAL=<UAL1_Standard.glb> godot --headless --path . -s res://tests/rennen_4164.gd
# Ergebnis 01.11. (UAL Standard): Jog_Fwd_Loop (Rennen seit 376.1) 0,93 s, Tempo 5,7 m/s, Beckenhub 24 cm, 76 % ohne Boden, Neigung 25°,
# im Spiel 0,75-fach (gedehnt); Sprint_Loop 0,67 s, 5,8 m/s (von Hand; die Messart hier und in held_klassen.py gibt 0,73, der Fuss liegt nie zwei Bilder am Tiefstand), Hub 14 cm, 65 %, Neigung 39°; Walk_Loop 1,33 s, 0,95 m/s, Hub 5 cm

const RENN := 3.68 * 1.16

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var pfad := OS.get_environment("UAL")
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	if doc.append_from_file(pfad, st) != OK: print("FEHLER laden ", pfad); quit(1); return
	var szene := doc.generate_scene(st)
	root.add_child(szene)
	await process_frame
	var ap: AnimationPlayer = szene.find_children("*", "AnimationPlayer", true, false)[0]
	var sk: Skeleton3D = szene.find_children("*", "Skeleton3D", true, false)[0]
	var namen := Array(ap.get_animation_list()).filter(func(n): return (n.contains("Jog") or n.contains("Sprint") or n.contains("Run") or n.contains("Walk") or n in ["Gehen", "Rennen"]))
	print("ALLE ", ", ".join(PackedStringArray(Array(ap.get_animation_list()).filter(func(n): return n.contains("Loop")))))
	# Spike 01.11.: Bodenkontakt am Ballen (ball_l, ball_r), nicht am Knoechel: im Lauf hebt sich die Ferse im Stand, der Knoechel
	# stieg dann ueber 2 cm und galt als Flug (gedaempfte Fassung: 88 % Flug, Tempo 9,5 m/s, am Ballen 56 %, 5,1 m/s)
	var fl := sk.find_bone("ball_l" if "--knoechel" not in OS.get_cmdline_user_args() else "foot_l")
	var fr := sk.find_bone("ball_r" if "--knoechel" not in OS.get_cmdline_user_args() else "foot_r")
	var pe := sk.find_bone("pelvis")
	var hals := sk.find_bone("neck_01")
	for n in namen:
		ap.play(n)
		var a := ap.get_animation(n)
		var schritte := 60
		var dt := a.length / schritte
		var fuesse := {fl: [], fr: []}
		var becken := []
		var neig := []
		for i in schritte + 1:
			ap.seek(i * dt, true)
			ap.advance(0)
			for f in [fl, fr]: fuesse[f].append(sk.global_transform * sk.get_bone_global_pose(f).origin)
			becken.append((sk.global_transform * sk.get_bone_global_pose(pe).origin).y)
			var v: Vector3 = (sk.global_transform * sk.get_bone_global_pose(hals).origin) - (sk.global_transform * sk.get_bone_global_pose(pe).origin)
			neig.append(rad_to_deg(atan2(v.z, v.y)))
		var vs := []
		var luft := 0
		for f in [fl, fr]:
			var p: Array = fuesse[f]
			var tief: float = p.map(func(q): return q.y).min()
			for j in schritte:
				if p[j].y < tief + 0.04 and p[j + 1].y < tief + 0.04: vs.append(absf(p[j].z - p[j + 1].z) / dt)
		for j in schritte:
			var tl: float = fuesse[fl].map(func(q): return q.y).min(); var tr: float = fuesse[fr].map(func(q): return q.y).min()
			if fuesse[fl][j].y > tl + 0.04 and fuesse[fr][j].y > tr + 0.04: luft += 1
		vs.sort()
		var v: float = vs[vs.size() / 2] if not vs.is_empty() else 0.0
		var hub: float = becken.max() - becken.min()
		var takt := RENN / maxf(v, 0.01)
		print("%s: %.2f s, Tempo %.2f m/s, Beckenhub %.1f cm, Flug %d %%, Neigung %.0f°, im Rennen %.2f-fach, Hub je s %.0f cm" % [n, a.length, v, hub * 100,
			luft * 100 / schritte, neig.reduce(func(s, x): return s + x, 0.0) / neig.size(), takt, hub * 100 * 2 * takt / a.length])
	quit()
