extends SceneTree
# 1566 Ursache des türkisen Funkelns hinter der Wand (Frage 22.11., 17:43; Urteil Sokrates 18:07): Blutzahnhöhle cave:5:10:DOWN,
# 19:13, Handygröße, Grafik Hoch, mit Fenster wie teich_bild_1566 (xvfb-run, --resolution 540x1170, „-- --bild=1566“); Renderer Mobile
# (Vulkan, lavapipe: VK_ICD_FILENAMES=/opt/lavapipe/lvp_icd.json, --rendering-method mobile --rendering-driver vulkan) wie das Handy;
# in Kompatibilität (OpenGL, Vorgabe am Rechner) zeigt sich kein Wasser. TEICHRECHT="0 567 73 635": roter Rahmen aus 3bf905261.
# Je Abwandlung des Kit-Wassers ein Bild und die Helligkeit im Teich (Kacheln „~“ 2–3/13–14): Mittel und hellster Bildpunkt (0–255).
# Abwandlungen einzeln: kit_nacht aus (night 0), Glanz aus (specular 0), Glanz rau (roughness 0,5), Durchsicht aus (refraction_tint schwarz), Nebel aus (ohne 1),
# Wasser weg (Bezug: was dort ohne Wasser zu sehen ist). Ohne BILD1566_AUS nur Zahlen; sonst PNG dorthin: 1566_u_<name>.png
func _initialize() -> void: _lauf.call_deferred()

var spiel
var r := Rect2i()
var erstes: Image = null

func kit() -> Array:
	var aus := []
	for mi in (spiel.gebiet as Node).find_children("*Wasser*", "MeshInstance3D", true, false):
		for s in (mi as MeshInstance3D).mesh.get_surface_count():
			var m := (mi as MeshInstance3D).get_surface_override_material(s) as ShaderMaterial
			if m and m.shader.code.contains("kit_selbst"): aus.append(m)
	return aus

func miss(name: String, aus: String) -> void:
	spiel.zustand.minuten = 19 * 60 + 13
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	if aus != "": img.save_png(aus + "/1566_u_%s.png" % name)
	var summe := 0.0; var hell := 0.0; var n := 0
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height(): continue
			var c := img.get_pixel(x, y)
			var l := (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) * 255.0
			summe += l; hell = maxf(hell, l); n += 1
	# Bezug: wie viele Bildpunkte im ganzen Schirm anders als „neu“ (zeigt, dass die Abwandlung wirkt), und die über 2 im Ausschnitt
	var anders := 0; var ueber := 0
	if erstes == null: erstes = img
	for y in img.get_height():
		for x in img.get_width():
			if not img.get_pixel(x, y).is_equal_approx(erstes.get_pixel(x, y)): anders += 1
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var c := img.get_pixel(x, y)
			if (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) * 255.0 > 2.0: ueber += 1
	print("URSACHE1566 %-15s Mittel %5.2f  hellster %5.1f  über 2: %d  (%d Punkte; im ganzen Schirm anders als neu: %d)" % [name, summe / maxf(n, 1), hell, ueber, n, anders])

func _lauf() -> void:
	var aus := OS.get_environment("BILD1566_AUS")   # leer: nur Zahlen, kein Bild
	Testmodus.an = true
	Testmodus.geladen = true
	Grafik.lade(); Grafik.wahl = "auto"; Grafik.auto_stufe = Grafik.HOCH
	spiel = (load("res://spiel.tscn") as PackedScene).instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	await spiel.lage_herstellen({"ort": "cave:5:10:DOWN", "uhr": "19:13"})
	var k_nacht: float = 1.0 - spiel.tageslicht(19 * 60 + 13)
	spiel.licht.ziel = k_nacht; spiel.licht.stelle(k_nacht); spiel._nacht(k_nacht)
	await create_timer(2.5).timeout
	var k = spiel.ui.get("mess")
	if k: k.visible = false
	var cam := root.get_viewport().get_camera_3d()
	var rf := Rect2(); var erst := true
	var nb := []
	for t in [Vector2i(2, 13), Vector2i(3, 13), Vector2i(2, 14), Vector2i(3, 14)]:
		nb.append(spiel.nebel.nebel(t.x, t.y))
		var c: Vector3 = spiel.karte.kachel_pos(t)
		for d in [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5), Vector3(-0.5, 0, 0.5), Vector3(0.5, 0, 0.5)]:
			var p := cam.unproject_position(c + d * Karte.TS)
			if erst: rf = Rect2(p, Vector2.ZERO); erst = false
			else: rf = rf.expand(p)
	r = Rect2i(rf).intersection(Rect2i(Vector2i.ZERO, root.get_texture().get_size()))
	if OS.get_environment("TEICHRECHT") != "":   # Ausschnitt fest (x0 y0 x1 y1), etwa der rote Rahmen aus 3bf905261
		var z := OS.get_environment("TEICHRECHT").split(" ")
		r = Rect2i(int(z[0]), int(z[1]), int(z[2]) - int(z[0]), int(z[3]) - int(z[1]))
	var ms := kit()
	print("URSACHE1566 Karte %s, Kit-Flächen %d, Nebel der Teichkacheln %s (0 nie gesehen, 1 gesehen, 2 in Sicht), night %s, Rechteck %s" % [spiel.karte.id, ms.size(), nb, ms[0].get_shader_parameter("night") if ms.size() else "-", r])
	await miss("neu", aus)
	for m in ms: m.set_shader_parameter("night", 0.0)
	await miss("ohne_nacht", aus)
	for m in ms: m.set_shader_parameter("night", k_nacht)
	for m in ms: m.set_shader_parameter("specular", 0.0)
	await miss("ohne_glanz", aus)
	for m in ms: m.set_shader_parameter("specular", 0.6)
	for m in ms: m.set_shader_parameter("roughness", 0.5)   # Glanz breit statt spitz (Vermutung: Spitzlicht läuft im Halbfloat-Puffer über)
	await miss("glanz_rau", aus)
	for m in ms: m.set_shader_parameter("roughness", 0.03)
	for m in ms: m.set_shader_parameter("refraction_tint", Color(0, 0, 0))
	await miss("ohne_durchsicht", aus)
	for m in ms: m.set_shader_parameter("refraction_tint", Color(1, 1, 1))
	spiel.nebel.mat.set_shader_parameter("ohne", 1.0)
	await miss("ohne_nebel", aus)
	spiel.nebel.mat.set_shader_parameter("ohne", 0.0)
	for mi in (spiel.gebiet as Node).find_children("*Wasser*", "MeshInstance3D", true, false): mi.visible = false
	await miss("ohne_wasser", aus)
	print("URSACHE1566 fertig")
	quit(0)
