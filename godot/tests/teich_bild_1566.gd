extends SceneTree
# 1566 Beleg (t298.5 Chef 18.11., 14:31 „fail“): Blutzahnhöhle cave:5:10:DOWN, 19:13, Spielkamera in Handygröße, mit Fenster
# (xvfb-run, --resolution 540x1170, Aufruf mit „-- --bild=1566“, sonst Hauptmenü). Je Drehung (0, 90, 180, 270 Grad) zwei Bilder im selben Lauf: neu (Stand der Arbeitskopie, kit_selbst wie gebiet.gd) und alt
# (kit_selbst 0,6 wie vor 34de75f8f; das war dessen einzige Spieländerung). PNG nach BILD1566_AUS: 1566_<grad>_neu.png, 1566_<grad>_alt.png;
# 1566 Runde 2 (Messlauf 22.11., 21:05): alt auch ohne Nebel im Wasser (kit_nebel_groesse 0 = Shader vor der Behebung), nur unter
# Mobile (Renderer des Handys) und nur mit Kit-Fläche gültig. Die Zeile HELL1566 nennt Mittel und hellsten Punkt im Teichrahmen.
# die Zeile TEICHRECHT1566 nennt den Bildausschnitt des Teichs (Kacheln „~“ 2–3/13–14 auf den Schirm projiziert).
func _initialize() -> void: _lauf.call_deferred()

func wasser(spiel) -> Array:
	var aus := []
	for mi in (spiel.gebiet as Node).find_children("*Wasser*", "MeshInstance3D", true, false):
		aus.append(mi)
	return aus

var teich := Rect2i(0, 567, 73, 68)   # roter Rahmen aus 3bf905261

func knipse(p: String, spiel) -> void:
	spiel.zustand.minuten = 19 * 60 + 13   # die Uhr läuft im Lauf weiter; im Bild 19:13 wie der Fund
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	img.save_png(p)
	var su := 0.0; var he := 0.0; var n := 0
	for y in range(teich.position.y, teich.end.y):
		for x in range(teich.position.x, teich.end.x):
			if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height(): continue
			var c := img.get_pixel(x, y)
			var l := (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) * 255.0
			su += l; he = maxf(he, l); n += 1
	print("BILD ", p)
	print("HELL1566 %s Mittel %.2f hellster %.1f (%d Punkte)" % [p.get_file(), su / maxf(n, 1), he, n])

func _lauf() -> void:
	if RenderingServer.get_current_rendering_method() != "mobile":
		print("FEHLER TEICHBILD1566 Renderer %s statt mobile" % RenderingServer.get_current_rendering_method())
		quit(1)
		return
	var aus := OS.get_environment("BILD1566_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	DirAccess.make_dir_recursive_absolute(aus)
	Testmodus.an = true
	Testmodus.geladen = true
	Grafik.lade(); Grafik.wahl = "auto"; Grafik.auto_stufe = Grafik.HOCH   # ohne Einmessen (unter lavapipe hing der Lauf 600 s); Stufe Hoch
	var spiel = (load("res://spiel.tscn") as PackedScene).instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	print("TEICHBILD1566 Lage")
	await spiel.lage_herstellen({"ort": "cave:5:10:DOWN", "uhr": "19:13"})
	# mit Argument hinter „--“ folgt das Licht nicht der Uhr (spiel.gd licht_nach_uhr), darum wie ausgang_bild_1091 selbst stellen
	var k_nacht: float = 1.0 - spiel.tageslicht(19 * 60 + 13)
	spiel.licht.ziel = k_nacht; spiel.licht.stelle(k_nacht); spiel._nacht(k_nacht)
	print("TEICHBILD1566 Nacht %.2f" % k_nacht)
	await create_timer(2.5).timeout   # Blende nach dem Betreten (Sekunden, wie ausgang_bild_1091)
	var k = spiel.ui.get("mess")
	if k: k.visible = false
	var kit := 0
	var ms := []
	for mi in wasser(spiel):
		for s in (mi as MeshInstance3D).mesh.get_surface_count():
			var m := (mi as MeshInstance3D).get_surface_override_material(s) as ShaderMaterial
			if m and m.shader.code.contains("kit_selbst"): kit += 1; ms.append(m)
	print("TEICH1566 Karte %s, Uhr %d, Wasser %d, Kit-Flächen %d" % [spiel.karte.id, spiel.zustand.minuten, wasser(spiel).size(), kit])
	if kit == 0:
		print("FEHLER TEICHBILD1566 keine Kit-Fläche (addons/water_kit fehlt)")
		quit(1)
		return
	# Sokrates 22.11., 21:49 (Chef 21:47: die Kamera dreht in 45-Grad-Schritten): vier Drehungen, je Drehung Rahmen neu, alt und neu
	var cam := root.get_viewport().get_camera_3d()
	for grad in [0, 90, 180, 270]:
		if grad > 0: spiel.kamera.drehe(90.0)
		spiel.kamera.springe()
		for i in 20: await process_frame
		var rf := Rect2(); var erst := true
		for t in [Vector2i(2, 13), Vector2i(3, 13), Vector2i(2, 14), Vector2i(3, 14)]:   # „~“ der Karte cave
			var c: Vector3 = spiel.karte.kachel_pos(t)
			for d in [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5), Vector3(-0.5, 0, 0.5), Vector3(0.5, 0, 0.5)]:
				var p := cam.unproject_position(c + d * Karte.TS)
				if erst: rf = Rect2(p, Vector2.ZERO); erst = false
				else: rf = rf.expand(p)
		teich = Rect2i(rf).intersection(Rect2i(Vector2i.ZERO, root.get_texture().get_size()))
		print("TEICHRECHT1566 %d Grad: %d %d %d %d (gieren %.1f)" % [grad, teich.position.x, teich.position.y, teich.end.x, teich.end.y, spiel.kamera.gieren])
		await knipse(aus + "/1566_%d_neu.png" % grad, spiel)
		var vorher := []
		for m in ms:
			vorher.append([m.get_shader_parameter("kit_selbst"), m.get_shader_parameter("kit_nebel_groesse")])
			m.set_shader_parameter("kit_selbst", 0.6)
			m.set_shader_parameter("kit_nebel_groesse", Vector2.ZERO)
		for i in 5: await process_frame
		await knipse(aus + "/1566_%d_alt.png" % grad, spiel)
		for q in ms.size():
			ms[q].set_shader_parameter("kit_selbst", vorher[q][0]); ms[q].set_shader_parameter("kit_nebel_groesse", vorher[q][1])
	print("TEICHBILD1566 fertig")
	quit(0)
