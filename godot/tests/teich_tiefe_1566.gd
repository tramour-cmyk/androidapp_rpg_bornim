extends SceneTree
# 1566 (Lauf 22.11., 21:05: unter rotem Nebel funkelt der Teich weiter, Wasser vor dem Nebel sortiert ändert nichts): ohne Bild.
# Der Nebel (nebel.gdshader) liest je Bildpunkt die Tiefe der deckenden Flächen; das Kit-Wasser ist durchsichtig (blend_mix) und
# fehlt darin, also nimmt der Nebel am Teich die Lage des Bodens unter dem Wasser, entlang des Blicks verschoben. Druckt Wasserhöhe,
# Boden darunter und die Nebeldeckung, die der Shader an Wasseroberfläche und Boden liest (Wert der Nebelkarte, 1 schwarz).
func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Testmodus.an = true
	Testmodus.geladen = true
	var spiel = (load("res://spiel.tscn") as PackedScene).instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	await spiel.lage_herstellen({"ort": "cave:5:10:DOWN", "uhr": "19:13"})
	for i in 30: await process_frame
	var cam := root.get_viewport().get_camera_3d()
	var blick := -cam.global_transform.basis.z
	var nb = spiel.nebel
	var gr: Vector2 = nb.mat.get_shader_parameter("groesse")
	var img: Image = (nb.mat.get_shader_parameter("nebel") as Texture2D).get_image()
	var deck := func(w: Vector3) -> float:
		var uv := Vector2(w.x, w.z) / gr
		var p := Vector2i(clampi(int(uv.x * img.get_width()), 0, img.get_width() - 1), clampi(int(uv.y * img.get_height()), 0, img.get_height() - 1))
		return img.get_pixel(p.x, p.y).r
	for mi in (spiel.gebiet as Node).find_children("*Wasser*", "MeshInstance3D", true, false):
		var bb: AABB = mi.global_transform * mi.get_aabb()
		var oben := bb.end.y
		# tiefste Fläche unter dem Teich: alle anderen Netze, deren Kiste die Teichmitte überdeckt
		var unten := INF
		var c := bb.get_center()
		for o in (spiel.gebiet as Node).find_children("*", "MeshInstance3D", true, false):
			if o == mi or not o.visible: continue
			var ob: AABB = o.global_transform * o.get_aabb()
			if ob.position.x <= c.x and ob.end.x >= c.x and ob.position.z <= c.z and ob.end.z >= c.z and ob.position.y < oben:
				unten = minf(unten, ob.position.y)
		print("TIEFE1566 %s Kiste %s, Oberfläche y %.2f, tiefste Fläche darunter y %.2f, Blick %s, Kartengröße %s" % [mi.name, bb, oben, unten, blick, gr])
		for t in [Vector2(0.25, 0.25), Vector2(0.5, 0.5), Vector2(0.75, 0.75)]:
			var w := Vector3(bb.position.x + bb.size.x * t.x, oben, bb.position.z + bb.size.z * t.y)
			var zeile := "TIEFE1566 Punkt %s: Deckung an der Oberfläche %.2f" % [w, deck.call(w)]
			for d in [0.5, 1.0, 2.0, 4.0]:
				var s: Vector3 = w + blick * (d / maxf(-blick.y, 0.01))   # d Meter tiefer entlang des Blicks
				zeile += ", %.1f m tiefer %.2f" % [d, deck.call(s)]
			print(zeile)
	# was hängt am Wasser und was liegt sonst über dem Teich (Teilchen, Lichter, Glitzer), mit Material-Priorität
	for mi in (spiel.gebiet as Node).find_children("*Wasser*", "Node3D", true, false):
		print("TIEFE1566 Knoten %s (%s), Kinder %d" % [mi.get_path(), mi.get_class(), mi.get_child_count()])
		for k in mi.find_children("*", "", true, false): print("TIEFE1566   Kind %s (%s)" % [k.name, k.get_class()])
	for o in root.find_children("*", "GeometryInstance3D", true, false):
		var g := o as GeometryInstance3D
		if not g.is_visible_in_tree(): continue
		var bb: AABB = g.global_transform * g.get_aabb()
		if bb.end.x > 2.3 and bb.position.x < 4.7 and bb.end.z > 15.0 and bb.position.z < 18.6 and bb.size.length() < 30.0:
			var pr := []
			if g.material_override: pr.append("over %d" % g.material_override.render_priority)
			if g is MeshInstance3D and g.mesh:
				for s in g.mesh.get_surface_count():
					var m = (g as MeshInstance3D).get_active_material(s)
					if m: pr.append("%s %d" % [m.get_class(), m.render_priority])
			print("TIEFE1566 über dem Teich: %s (%s) %s %s" % [g.get_path(), g.get_class(), bb, pr])
	quit(0)
