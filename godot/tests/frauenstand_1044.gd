extends SceneTree
# 1044 Kandidatenblatt (Chef 12.11., 16:08 über Sokrates: „Die Damen posen im Stand … wenn es keine Kampfpose sein soll, jetzt am
# Beispiel Lyra“; Weg (1): gekaufte Pakete nach ruhiger Standpose sichten). Lyra (HeldFigur.person, Kaufkörper wie im Spiel) in jeder
# Stehbewegung, die die Pakete haben: „Stehen“ von heute (vorher), die Idle-Bewegungen der UAL (daten/k1044/*UAL*.bin) und die
# übertragenen Protofactor-Bewegungen (daten/k1044/pf_*.bin, zauber385.py); je Kandidat ein Bild von vorn und eins 35 Grad gedreht.
# Nur mit Fenster und Kaufdaten (godot.yml „Frauenstand (1044)“), im Ordner godot:
#   PROBE=1044 xvfb-run -a godot --path . --resolution 720x900 -s res://tests/frauenstand_1044.gd -- --aus=<ordner>

var aus := ""
var lyra: Node3D
var sk: Skeleton3D
var ap: AnimationPlayer
var halter: Node3D


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	_lauf.call_deferred()


func knips(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	img.save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")


## die Bewegung n aus der Datei auf Lyra wie HeldFigur.bewegungen (nur Drehungen, Becken im Verhaeltnis der Beckenhoehe)
func uebertrage(datei: String, n: String, als: String) -> bool:
	var sc := Gebiet.lade_glb(datei)
	if sc == null: return false
	var ap0 := Gebiet.finde(sc, "AnimationPlayer") as AnimationPlayer
	var sk0 := Gebiet.finde(sc, "Skeleton3D") as Skeleton3D
	if ap0 == null or sk0 == null or not ap0.has_animation(n) or sk0.find_bone("pelvis") < 0:
		sc.free(); return false
	var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / maxf(0.01, sk0.get_bone_rest(sk0.find_bone("pelvis")).origin.length())
	var an := ap0.get_animation(n).duplicate(true) as Animation
	sc.free()
	var pfad := String(lyra.get_path_to(sk))
	for t in range(an.get_track_count() - 1, -1, -1):
		var bn := String(an.track_get_path(t)).get_slice(":", 1)
		an.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
		var ty := an.track_get_type(t)
		if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]) or sk.find_bone(bn) < 0:
			an.remove_track(t)
		elif ty == Animation.TYPE_POSITION_3D:
			for i in an.track_get_key_count(t): an.track_set_key_value(t, i, an.track_get_key_value(t, i) * f)
	an.loop_mode = Animation.LOOP_LINEAR
	if not ap.has_animation_library("k1044"): ap.add_animation_library("k1044", AnimationLibrary.new())
	ap.get_animation_library("k1044").add_animation(als, an)
	return true


func _lauf() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	var welt := WorldEnvironment.new()
	welt.environment = Environment.new()
	welt.environment.background_mode = Environment.BG_COLOR
	welt.environment.background_color = Color(0.08, 0.07, 0.06)
	welt.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	welt.environment.ambient_light_color = Color(0.55, 0.5, 0.45)
	root.add_child(welt)
	var sonne := DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-35, -25, 0)
	root.add_child(sonne)
	var kam := Camera3D.new()
	kam.fov = 30.0
	kam.position = Vector3(0, 0.95, 4.2)
	root.add_child(kam)
	kam.look_at(Vector3(0, 0.85, 0))
	var mats := []
	lyra = HeldFigur.person("lyra", mats)
	if lyra == null:
		print("FRAUEN1044 Lyra fehlt (ohne Kaufdaten)"); quit(1); return
	halter = Node3D.new()
	root.add_child(halter)
	halter.add_child(lyra)
	sk = Gebiet.finde(lyra, "Skeleton3D") as Skeleton3D
	ap = Gebiet.finde(lyra, "AnimationPlayer") as AnimationPlayer
	for k in lyra.find_children("Getragen*", "", true, false): k.visible = false   # nur der Stand, ohne Stab
	var kandidaten := []   # [Name im Blatt, Bewegung im AnimationPlayer]
	if ap.has_animation("Stehen"): kandidaten.append(["0_heute_Stehen", "Stehen"])
	var ordner := "res://daten/k1044"
	var dir := DirAccess.open(ordner)
	var dateien := Array(dir.get_files()) if dir else []
	dateien.sort()
	for d in dateien:
		if not String(d).ends_with(".bin"): continue
		var sc := Gebiet.lade_glb(ordner + "/" + d)
		if sc == null: continue
		var a0 := Gebiet.finde(sc, "AnimationPlayer") as AnimationPlayer
		var namen: Array = Array(a0.get_animation_list()) if a0 else []
		sc.free()
		print("FRAUEN1044 Datei %s: %d Bewegungen: %s" % [d, namen.size(), ", ".join(namen.map(func(x): return String(x)))])
		for n in namen:
			var nn := String(n)
			var low := nn.to_lower()
			var pf := String(d).begins_with("pf_")
			if not pf and (not low.contains("idle") or low.contains("crouch") or low.contains("torch") or low.contains("sit") or low.contains("swim")):
				continue
			if pf and nn == "RESET": continue
			var als := "%d_%s" % [kandidaten.size(), (String(d).get_basename() + "_" + nn) if pf else nn]
			if uebertrage(ordner + "/" + d, nn, als): kandidaten.append([als, "k1044/" + als])
	print("FRAUEN1044 %d Kandidaten" % kandidaten.size())
	for k in kandidaten:
		ap.play(String(k[1]))
		ap.seek(ap.get_animation(String(k[1])).length * 0.4, true)
		halter.rotation_degrees.y = 0.0
		await knips("%s_vorn" % k[0])
		halter.rotation_degrees.y = -35.0
		await knips("%s_schraeg" % k[0])
	print("FRAUEN1044 fertig")
	quit()
