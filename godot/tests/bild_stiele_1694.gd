extends SceneTree
# 1694 (Chef 24.11., 10:30: „Vergleichsbild wegen der Axtdicke … vorher, nachher, wie viel dünner das ist … eine Hand daneben machen,
# damit ich eine Proportion dazu habe“): je Staffelform ein Bild des Stiels in Griffhöhe, gerade stehend, Spielfarbe (Gebiet.male,
# COMMON), orthografisch, für alle derselbe Maßstab; dazu die offene rechte Hand von WACHE_M (Ruhe) im selben Maßstab. Zusammengesetzt
# und beschriftet von tools/bild_stiele_1694.py.
#   VORHER=<ordner glb> NACHHER=<ordner glb> LISTE=a,b,… AUS=<ordner> PXCM=8 xvfb-run -a godot --path . -s res://tests/bild_stiele_1694.gd
# Je Form <AUS>/<id>-vorher.png, -nachher.png (Fenster B x H cm um den Griff), hand.png; dazu groß (GROSS=<id>, Faktor 2): -gross-*.png

const B := 14.0   # cm Fensterbreite
const H := 34.0   # cm Fensterhöhe (Griff in der Mitte)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var pxcm := float(OS.get_environment("PXCM")) if OS.get_environment("PXCM") != "" else 8.0
	var aus := OS.get_environment("AUS")
	var welt := Node3D.new(); root.add_child(welt)
	var we := WorldEnvironment.new(); we.environment = Environment.new()
	we.environment.background_mode = Environment.BG_COLOR; we.environment.background_color = Color8(0x8c, 0x8a, 0x86)
	we.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; we.environment.ambient_light_color = Color(0.55, 0.55, 0.58)
	welt.add_child(we)
	var li := DirectionalLight3D.new(); li.rotation_degrees = Vector3(-35, 30, 0); li.light_color = Color(1.0, 0.95, 0.85); welt.add_child(li)
	var x := 0.0
	for id in OS.get_environment("LISTE").split(","):
		for st in ["vorher", "nachher"]:
			var d := Gebiet.lade_glb(datei(OS.get_environment(st.to_upper()), id))
			if d == null or d.find_children("*", "MeshInstance3D", true, false).is_empty(): print("STIELE1694 FEHLT %s %s" % [id, st]); continue
			d.set_meta("staffel", "COMMON")
			welt.add_child(d); d.position = Vector3(x, 0, 0)
			Gebiet.male(d, null, 2, [])
			await bild(Vector3(x, 0, 0), Vector3.UP, B, H, pxcm, "%s/%s-%s.png" % [aus, id, st])
			if id == OS.get_environment("GROSS"): await bild(Vector3(x, 0, 0), Vector3.UP, B * 0.6, H * 0.5, pxcm * 2.0, "%s/%s-gross-%s.png" % [aus, id, st])
			d.visible = false
			x += 2.0
	# offene rechte Hand von WACHE_M in Ruhe, Finger nach oben, Blick auf die Handfläche
	var m := Gebiet.lade_glb("res://daten/held_WACHE_M.bin")
	welt.add_child(m); m.position = Vector3(x + 5.0, 0, 0)
	Gebiet.male(m, null, 2, [])
	await process_frame
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	sk.reset_bone_poses()
	await process_frame
	var G := sk.global_transform
	var hp := G * sk.get_bone_global_pose(sk.find_bone("hand_r")).origin
	var mp := G * sk.get_bone_global_pose(sk.find_bone("middle_01_r")).origin
	var ip := G * sk.get_bone_global_pose(sk.find_bone("index_01_r")).origin
	var pp := G * sk.get_bone_global_pose(sk.find_bone("pinky_01_r")).origin
	var f := (mp - hp).normalized()
	var n := f.cross(ip - pp).normalized()
	for s in [1.0, -1.0]:
		await bild(hp + f * 0.09, f, B, H, pxcm, "%s/hand-%s.png" % [aus, "a" if s > 0 else "b"], n * s)
		await bild(hp + f * 0.09, f, B * 0.6 * 2.0, H * 0.5 * 2.0 * 0.6, pxcm * 2.0, "%s/hand-gross-%s.png" % [aus, "a" if s > 0 else "b"], n * s)
	print("STIELE1694 fertig")
	quit(0)

# Datei der Form [id] (Schlüssel aus staffel.json „formen“) im Ordner: <art>_<id>.glb (waffen_staffel.py Kennung)
static func datei(ordner: String, id: String) -> String:
	for f in DirAccess.get_files_at(ordner):
		if f.ends_with("_" + id + ".glb") or f == id + ".glb": return ordner + "/" + f
	return ordner + "/" + id + ".glb"

# orthografisch auf [mitte], [oben] im Bild nach oben, Fenster b x h cm, Blick aus [von] (Standard: von vorn, -Z)
func bild(mitte: Vector3, oben: Vector3, b: float, h: float, pxcm: float, pfad: String, von := Vector3.BACK) -> void:
	var sv := SubViewport.new()
	sv.size = Vector2i(roundi(b * pxcm), roundi(h * pxcm)); sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sv.own_world_3d = false; sv.msaa_3d = Viewport.MSAA_4X
	root.add_child(sv)
	var k := Camera3D.new(); k.projection = Camera3D.PROJECTION_ORTHOGONAL; k.size = h / 100.0; k.keep_aspect = Camera3D.KEEP_HEIGHT
	k.near = 0.01; k.far = 4.0
	sv.add_child(k)
	k.look_at_from_position(mitte + von.normalized() * 1.0, mitte, oben)
	k.make_current()
	for i in 4: await process_frame
	sv.get_texture().get_image().save_png(pfad)
	sv.queue_free()
