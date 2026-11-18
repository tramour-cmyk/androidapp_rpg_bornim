extends "res://tests/drehteller_film_499.gd"
# 1619 (Chef 18.11., 07:29 zu Film 458.3: „warum der Held gar so stakst“): Vergleich in einem Bild. Zwei Kämpfer gehen parallel
# im Spieltempo (karte.gehen × TS = 2,13 m/s, ohne Gleiten) über die Wiese: oben (4 m dahinter) wie bisher (Paketbewegung ganz, kurzer
# Schritt), unten neu (HeldFigur.waffen_gehen „A“: Beine und Rumpf aus Gehen, Arme aus dem Paket). Erst Langschwert, dann Großaxt.
# Kamera von der Seite (30 Grad Neigung wie kamera.gd), folgt; Hochformat wie das Spiel (der Filmschreiber nimmt die Fenstergröße
# des Projekts 1080×2340, nicht --resolution). Licht wie Drehteller 499, ohne Tusche.
# Film:      xvfb-run godot --rendering-driver vulkan --rendering-method mobile --path godot --resolution 1080x2340
#            --write-movie <x.avi> --fixed-fps 30 -s res://tests/gang_film_1619.gd
# Probebild: BILDER=<ordner> ohne --write-movie: ein Bild nach 2 s

const V := 1.84 * 1.16
const ABSCHNITT_S := 6.0
const WAFFEN := [["longsword", 1, "COMMON", "Langschwert"], ["greataxe", 1, "COMMON", "Großaxt"]]
const SEITEN := [["paket", -4.0, "bisher"], ["A", 0.0, "neu"]]

var marken: Array[Label] = []

func _lauf() -> void:
	Sprache.lade()
	var bilder := OS.get_environment("BILDER")
	baue_welt()
	kam.size = 2.6
	var sm := StandardMaterial3D.new(); sm.albedo_color = Color(0.36, 0.33, 0.29); sm.roughness = 1.0
	for zz in range(-2, 32):
		for x in [-4.6, -3.4, -0.9, 0.9]:
			var st := MeshInstance3D.new()
			var bx := BoxMesh.new(); bx.size = Vector3(0.14, 0.03, 0.1)
			st.mesh = bx; st.material_override = sm
			st.position = Vector3(x + 0.07 * sin(zz * 2.3), 0.015, float(zz) + 0.2 * cos(zz * 1.7))
			welt.add_child(st)
	(welt.get_child(2) as MeshInstance3D).mesh.size = Vector2(60, 80)
	var gr := root.get_visible_rect().size
	schrift.position = Vector2(gr.x * 0.03, gr.y * 0.03)
	schrift.add_theme_font_size_override("font_size", int(gr.x * 0.045))
	for i in 2:
		var l := Label.new()
		l.add_theme_font_size_override("font_size", int(gr.x * 0.06))
		l.add_theme_color_override("font_color", Color(0.85, 0.72, 0.42))
		l.add_theme_constant_override("outline_size", 6)
		l.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03))
		l.position = Vector2(gr.x * 0.05, gr.y * (0.09 if i == 0 else 0.86))
		schrift.get_parent().add_child(l)
		marken.append(l)
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var t := 0.0
	for e in WAFFEN:
		var figuren := []
		for s in SEITEN:
			HeldFigur.waffen_gehen = s[0]
			var w := HeldFigur.wahl(hw, z)
			var aus: Dictionary = (w.get("ausruestung", {}) as Dictionary).duplicate()
			aus.erase("OFF_HAND")
			aus["MAIN_HAND"] = {"base": e[0], "ilvl": e[1], "rarity": e[2]}
			w["ausruestung"] = aus
			var mats := []
			var m := HeldFigur.baue(w, mats)
			if m == null: fehler += 1; print("FEHLER kein Held"); quit(1); return
			welt.add_child(m)
			for mm in mats:
				(mm as ShaderMaterial).set_shader_parameter("metall", 1.0)
				(mm as ShaderMaterial).set_shader_parameter("licht_dir", Basis.from_euler(sonne.rotation).z)
			var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			var gang := String(m.get_meta("gang", ""))
			var bew := "Gehen_" + gang if gang != "" and ap.has_animation("Gehen_" + gang) else "Gehen"
			var v := float(m.get_meta("gang_gehen_m_je_s", 0.0)) if bew != "Gehen" else float(m.get_meta("gehen_m_je_s", V))
			ap.play(bew)
			ap.speed_scale = V / maxf(0.01, v)   # wie held.gd takt: Spieltempo ohne Gleiten
			var sps := 2.0 / ap.get_animation(bew).length * ap.speed_scale
			print("GANGFILM1619 %s %s: %s, %.2f Schritte/s" % [e[0], s[0], bew, sps])
			figuren.append([m, s[1]])
			marken[figuren.size() - 1].text = "%s\n%s Schritte/s" % [s[2], ("%.1f" % sps).replace(".", ",")]
		HeldFigur.waffen_gehen = "A"
		schrift.text = "Kämpfer · %s · Gehen im Spieltempo" % e[3]
		var t0 := t
		var gemacht := false
		while t < t0 + ABSCHNITT_S:
			var zpos := (t - t0) * V
			for f in figuren: (f[0] as Node3D).position = Vector3(f[1], 0, zpos)
			stelle_kamera(Vector3(-2.0, 0.9, zpos), 90.0)
			await process_frame
			t += DT
			if bilder != "" and not gemacht and t - t0 >= 2.0:
				gemacht = true
				await RenderingServer.frame_post_draw
				var b := root.get_texture().get_image()
				b.save_png(bilder + "/1619_%s.png" % e[0])
				print("BILD ", bilder + "/1619_%s.png" % e[0])
		for f in figuren: (f[0] as Node3D).queue_free()
		await process_frame
	print("GANGFILM1619 %d Fehler" % fehler)
	quit(1 if fehler else 0)
