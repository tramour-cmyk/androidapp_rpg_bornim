extends SceneTree
# 431 B1 (Lauf 5 41504744398: Orkbluetige Frau beige, die Toenung greift nicht; Chef 02.11., 20:37 „nur Orkfrau Haut nachbessern“)
# nachstellen am Rechner: die freien Koerper Superhero Mann und Frau (CC0, ohne voelker.py) mit Gebiet.male und den Werten von
# voelkerprobe.gd _eigene_haut, je Koerper vier Arten nebeneinander, Licht wie die Signatur des Kampforts (Sonne -45/55, 1,3;
# Umgebung 0,75); misst die Gesichtsfarbe im Bild wie _gesicht (5 x 5 Punkte, Median). Bildlauf (389): Vorgang davor.
#   CC0_KOERPER=<Ordner mit Superhero_*_FullBody.gltf> [HAUTBILD_AUS=<png>] Godot mit Fenster, Treiber opengl3, dieses Skript
const EICHUNG_LICHT := Vector3(0.745, 0.549, 0.619)
const ARTEN := ["ohne Toenung", "wie _eigene_haut", "ohne Hautmaske (toen_farbe 0)", "nur Faktor (toen_hell 0)"]
var figs := []

func _lin(c: Array) -> Vector3:
	var l := Color(float(c[0]), float(c[1]), float(c[2])).srgb_to_linear()
	return Vector3(l.r, l.g, l.b)

func _initialize() -> void:
	var dir := OS.get_environment("CC0_KOERPER")
	var welt := Node3D.new(); root.add_child(welt)
	var env := WorldEnvironment.new(); env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR; env.environment.background_color = Color(0.2, 0.2, 0.2)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 0.75
	welt.add_child(env)
	var sonne := DirectionalLight3D.new(); sonne.rotation_degrees = Vector3(-45, 55, 0); sonne.light_energy = 1.3; welt.add_child(sonne)
	var cam := Camera3D.new(); cam.projection = Camera3D.PROJECTION_ORTHOGONAL; cam.size = 1.0
	cam.position = Vector3(2.45, 1.5, 3.0); welt.add_child(cam); cam.current = true
	var ork := Color.html("8e9682").srgb_to_linear()
	var reihe := []
	for kb in [["Superhero_Male_FullBody", [0.6078, 0.3843, 0.2784]], ["Superhero_Female_FullBody", [0.6627, 0.4353, 0.302]]]:
		for art in ARTEN.size(): reihe.append([kb[0], kb[1], art])
	for k in reihe.size():
		var doc := GLTFDocument.new(); var st := GLTFState.new()
		var err := doc.append_from_file(dir.path_join(String(reihe[k][0]) + ".gltf"), st)
		if err != OK: print("HAUTBILD FEHLER ", err); quit(1); return
		var m := doc.generate_scene(st) as Node3D
		var mats := []
		Gebiet.male(m, null, 2, mats)
		for x in mats: (x as ShaderMaterial).set_shader_parameter("fill", 0.42)
		welt.add_child(m)
		m.position = Vector3(k * 0.7, 0, 0)
		var art: int = reihe[k][2]
		var n := 0
		for mi in m.find_children("*", "MeshInstance3D", true, false):
			var me := (mi as MeshInstance3D).mesh
			for i in me.get_surface_count():
				var src := me.surface_get_material(i)
				var rn := String(src.resource_name) if src else ""
				if not rn.contains("Superhero"): continue
				var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
				if art > 0:
					var l := _lin(reihe[k][1])
					sm.set_shader_parameter("toen_bild", l)
					sm.set_shader_parameter("toen_hell", 0.0 if art == 3 else maxf(0.01, 0.2126 * l.x + 0.7152 * l.y + 0.0722 * l.z))
					sm.set_shader_parameter("toen_farbe", 0.0 if art == 2 else 0.5)
					sm.set_shader_parameter("toenung", Vector3(ork.r, ork.g, ork.b) * EICHUNG_LICHT)
				n += 1
				print("HAUTBILD %d %s Flaeche %s/%d Material %s, %s" % [k, reihe[k][0], mi.name, i, rn, ARTEN[art]])
		if n == 0: print("HAUTBILD %d %s: keine Hautflaeche" % [k, reihe[k][0]])
		figs.append(m)
	for i in 8: await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	var aus := OS.get_environment("HAUTBILD_AUS")
	if aus != "": img.save_png(aus)
	for k in figs.size():
		var f: Node3D = figs[k]
		var sk := Gebiet.finde(f, "Skeleton3D") as Skeleton3D
		var hk := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head")).origin
		var kopf := hk + Vector3(0, 0.06, 0)
		var vorn := kopf + Vector3(0, 0, 0.12)
		var p := cam.unproject_position(vorn)
		var r := []; var g := []; var b := []
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				var c := img.get_pixel(clampi(int(p.x) + dx * 2, 0, img.get_width() - 1), clampi(int(p.y) + dy * 2, 0, img.get_height() - 1))
				r.append(c.r); g.append(c.g); b.append(c.b)
		r.sort(); g.sort(); b.sort()
		print("HAUTBILD GESICHT %d %s, %s, bei %d,%d: %d/%d/%d" % [k, reihe[k][0], ARTEN[reihe[k][2]], p.x, p.y, r[12] * 255, g[12] * 255, b[12] * 255])
	quit()
