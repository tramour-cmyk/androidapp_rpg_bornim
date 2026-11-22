extends SceneTree
# 1566 Beleg (t298.5 Chef 18.11., 14:31 „fail“): Blutzahnhöhle cave:5:10:DOWN, 19:13, Spielkamera in Handygröße, mit Fenster
# (xvfb-run, --resolution 540x1170). Zwei Bilder im selben Lauf: neu (Stand der Arbeitskopie, kit_selbst wie gebiet.gd) und alt
# (kit_selbst 0,6 wie vor 34de75f8f; das war dessen einzige Spieländerung). PNG nach BILD1566_AUS: 1566_neu.png, 1566_alt.png;
# die Zeile TEICHRECHT1566 nennt den Bildausschnitt des Teichs (Kacheln „~“ 2–3/13–14 auf den Schirm projiziert).
func _initialize() -> void: _lauf.call_deferred()

func wasser(spiel) -> Array:
	var aus := []
	for mi in (spiel.gebiet as Node).find_children("*Wasser*", "MeshInstance3D", true, false):
		aus.append(mi)
	return aus

func knipse(p: String, spiel) -> void:
	spiel.zustand.minuten = 19 * 60 + 13   # die Uhr läuft im Lauf weiter; im Bild 19:13 wie der Fund
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(p)
	print("BILD ", p)

func _lauf() -> void:
	var aus := OS.get_environment("BILD1566_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	Testmodus.an = true
	Testmodus.geladen = true
	Grafik.lade(); Grafik.wahl = "auto"; Grafik.auto_stufe = Grafik.HOCH   # ohne Einmessen (unter lavapipe hing der Lauf 600 s); Stufe Hoch
	var spiel = (load("res://spiel.tscn") as PackedScene).instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	print("TEICHBILD1566 Lage")
	await spiel.lage_herstellen({"ort": "cave:5:10:DOWN", "uhr": "19:13"})
	spiel.licht_nach_uhr(true)
	await create_timer(2.5).timeout   # Blende nach dem Betreten (Sekunden, wie ausgang_bild_1091)
	var k = spiel.ui.get("mess")
	if k: k.visible = false
	var cam := root.get_viewport().get_camera_3d()
	var r := Rect2()
	var erst := true
	for t in [Vector2i(2, 13), Vector2i(3, 13), Vector2i(2, 14), Vector2i(3, 14)]:   # „~“ der Karte cave
		var c: Vector3 = spiel.karte.kachel_pos(t)
		for d in [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5), Vector3(-0.5, 0, 0.5), Vector3(0.5, 0, 0.5)]:
			var p := cam.unproject_position(c + d * Karte.TS)
			if erst: r = Rect2(p, Vector2.ZERO); erst = false
			else: r = r.expand(p)
	print("TEICHRECHT1566 %d %d %d %d" % [r.position.x, r.position.y, r.end.x, r.end.y])
	print("TEICH1566 Karte %s, Uhr %d, Wasser %d" % [spiel.karte.id, spiel.zustand.minuten, wasser(spiel).size()])
	await knipse(aus + "/1566_neu.png", spiel)
	for mi in wasser(spiel):
		for s in (mi as MeshInstance3D).mesh.get_surface_count():
			var m := (mi as MeshInstance3D).get_surface_override_material(s) as ShaderMaterial
			if m and m.shader.code.contains("kit_selbst"): m.set_shader_parameter("kit_selbst", 0.6)
	for i in 5: await process_frame
	await knipse(aus + "/1566_alt.png", spiel)
	print("TEICHBILD1566 fertig")
	quit(0)
