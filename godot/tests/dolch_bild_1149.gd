extends SceneTree
# 1149 Probebild (aus 1140, 522): der Dolch der Nebenhand am Körper, zwei Plätze zur Wahl (Chefsache 1149): oben „guertel“ (links an der
# Hüfte), unten „kreuz“ (quer über dem Kreuz); je vorn, beide Seiten, hinten; seit 1149 A nur Gürtel mit Lederscheide, Held Herumtreiber im Drehteller wie in Erschaffung und
# Ausrüstung. Nur mit Fenster und Kaufmodellen (godot.yml „Dolchbild (1149)“ bei „1149 Bild“), PNG nach BILD1149_AUS: 1149_dolch.png.
# Zeilen „DOLCH1149“: Platz, Abstand der Klingenmitte zur Haut (soll 1–6 cm, nichts im Körper)

func _initialize() -> void: _lauf.call_deferred()

func ansicht(dt: Drehteller, winkel: float) -> Image:
	dt.teller.rotation.y = deg_to_rad(winkel)
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var x: Image = (dt.get_child(0) as SubViewport).get_texture().get_image()
	x.convert(Image.FORMAT_RGBA8)
	return x

func _lauf() -> void:
	Sprache.lade()
	var aus := OS.get_environment("BILD1149_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	var reihen: Array[Image] = []
	for platz in (["guertel", "kreuz"] if OS.get_environment("DOLCH_BEIDE") == "1" else ["guertel"]):   # 1149 A (Chef 19:44): nur noch Gürtel
		HeldFigur.dolch_platz = platz
		var z := Zustand.new()
		var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Herumtreiber", z.neue_uid)
		var d := z.ausruestung_dazu({"uid": z.neue_uid(), "base": "dagger", "rarity": "COMMON", "ilvl": 1, "rolls": []})
		z.beutel.erase(d)
		hw.anlegen_nebenhand(d)
		var dt := Drehteller.new(HeldFigur.wahl(hw, z), 1.6)
		dt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(dt)
		for i in 20: await process_frame
		dt.set_process(false)
		var modell: Node3D = dt.teller.get_child(0) if dt.teller and dt.teller.get_child_count() > 0 else null
		var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D if modell else null
		var ba := sk.get_node_or_null("RueckenDolch") if sk else null
		if ba == null:
			print("DOLCH1149 %s: kein Dolch am Körper" % platz)
		else:
			for mi in ba.find_children("*", "MeshInstance3D", true, false):
				var c := (mi as MeshInstance3D).global_transform * (mi as MeshInstance3D).get_aabb().get_center()
				var best := INF
				var cm := modell.global_transform.affine_inverse() * c   # Raum der Figur; Haut in Ruhelage, nur zur Auskunft
				for p in HeldFigur.haut_punkte(modell, sk, false, null, [], INF): best = minf(best, p.distance_to(cm))
				print("DOLCH1149 %s: %s Mitte %.3f m von der Haut (Ruhelage)" % [platz, mi.name, best])
			# 1149 A mit Scheide: Abstand jeder Ecke der Scheide zur nächsten Haut (soll über 5 mm), Lage des Mundblechs
			var sc := ba.find_child("Scheide", true, false) as MeshInstance3D
			if sc == null: print("DOLCH1149 %s: keine Scheide" % platz)
			else:
				var haut := HeldFigur.haut_punkte(modell, sk, false, null, [], INF)
				var tr := modell.global_transform.affine_inverse() * sc.global_transform
				var am := INF
				var vs: PackedVector3Array = sc.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
				for v in vs:
					var q := tr * v
					for p in haut: am = minf(am, p.distance_to(q))
				print("DOLCH1149 %s: Scheide %d Ecken, nächste Haut %.3f m, Mund bei %s" % [platz, vs.size(), am, tr * Vector3(0, HeldFigur.SCHEIDE_MUND, 0)])
				# Lauf 466: Klinge ragte seitlich aus der Scheide. Jede Ecke der Klinge (Modellraum, unter dem Mundblech) muss im Querschnitt
				# der Scheide liegen: Ringe der Scheide auf derselben Höhe (größte |x| und |z| der Scheide dort)
				var wd := sc.get_parent() as Node3D
				var drau := 0
				for mi2 in wd.find_children("*", "MeshInstance3D", true, false):
					if mi2 == sc: continue
					var t2 := HeldFigur.im_raum(wd, mi2)
					for v2 in (mi2 as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
						var q2: Vector3 = t2 * v2
						if q2.y < 0.06: continue
						var w2 := HeldFigur.scheide_quer(q2.y)
						if w2 == Vector2.ZERO or pow(q2.x / w2.x, 2) + pow(q2.z / w2.y, 2) > 1.0: drau += 1
				print("DOLCH1149 %s: Klinge außerhalb der Scheide %d Ecken (soll 0)" % [platz, drau])
		var teile: Array[Image] = []
		for w in [0.0, -90.0, 90.0, 180.0]: teile.append(await ansicht(dt, w))   # vorn, beide Seiten, hinten
		var b := teile[0].get_width(); var h := teile[0].get_height()
		var r := Image.create(b * teile.size(), h, false, Image.FORMAT_RGBA8)
		r.fill(Color(0.05, 0.04, 0.03))
		for i in teile.size(): r.blend_rect(teile[i], Rect2i(0, 0, b, h), Vector2i(b * i, 0))
		reihen.append(r)
		dt.queue_free()
		for i in 3: await process_frame
	var ges := Image.create(reihen[0].get_width(), reihen[0].get_height() * reihen.size(), false, Image.FORMAT_RGBA8)
	for i in reihen.size(): ges.blit_rect(reihen[i], Rect2i(Vector2i.ZERO, reihen[i].get_size()), Vector2i(0, reihen[0].get_height() * i))
	ges.save_png(aus + "/1149_dolch.png")
	print("BILD ", aus + "/1149_dolch.png")
	quit(0)
