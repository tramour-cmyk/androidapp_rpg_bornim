extends SceneTree
# 376.1 ohne Bild: je Klasse die Figur (heldfigur.gd) mit Grundausruestung und Aussehen; prueft Bewegungen, Formschluessel, Haar,
# Bart, Toenung, Waffen auf dem Ruecken und dass die Figur auf dem Boden steht. Braucht daten/held_*.bin (held_klassen.py).
# godot --headless --path godot -s res://tests/held_klassen_376.gd   -> „HELDKLASSEN gut“ oder „FALSCH …“, Ende 0/1

var falsch := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		falsch += 1
		print("FALSCH ", was)

func _init() -> void:
	var info := HeldFigur.lade_info()
	if info.is_empty():
		print("HELDKLASSEN ohne Daten (held-klassen.json fehlt)")
		quit(0)
		return
	for k in ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]:
		pruefe(HeldFigur.da(k), k + " fehlt")
		if not HeldFigur.da(k): continue
		var hw := Heldwerte.erschaffe("Test", "HUMAN", k)
		# Beispielkopf je Klasse (Chef 23:0x): eigene Vorgabe, Haut nicht „Hell“
		pruefe(int(HeldFigur.vorgabe(k)["haut"]) > 0, "%s: Vorgabe Haut Hell" % k)
		for a in [{}, {"form": "rund", "frisur": "Hair_Buzzed", "bart": "Hair_Beard", "haut": 3, "haarfarbe": 2}, {"form": "hager", "frisur": "", "bart": ""}]:
			var mats := []
			var w := {"klasse": k, "volk": "HUMAN", "aussehen": a, "ausruestung": hw.ausruestung}
			var m := HeldFigur.baue(w, mats)
			pruefe(m != null, "%s %s: keine Figur" % [k, a])
			if m == null: continue
			root.add_child(m)
			var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			for b in ["Stehen", "Gehen", "Rennen"]: pruefe(ap != null and ap.has_animation(b), "%s: Bewegung %s fehlt" % [k, b])
			pruefe(float(m.get_meta("gehen_m_je_s")) > 0.5 and float(m.get_meta("gehen_m_je_s")) < 2.0, "%s: Gehtempo %s" % [k, m.get_meta("gehen_m_je_s")])
			pruefe((m.get_meta("faust_L") as Dictionary).has("knochen"), "%s: linke Faust fehlt" % k)
			var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
			var haare := sk.find_children("Haar_*", "BoneAttachment3D", false, false).size()
			var soll := int(String(HeldFigur.aussehen_voll(a, k)["frisur"]) != "") + int(String(HeldFigur.aussehen_voll(a, k)["bart"]) != "")
			pruefe(haare == soll, "%s %s: %d Haarteile statt %d" % [k, a, haare, soll])
			# Formschluessel: die gewaehlte Form steht auf 1 an Haut und Haar
			var form := String(HeldFigur.aussehen_voll(a, k)["form"])
			var gesetzt := 0
			var mit_form := 0
			for mi in m.find_children("*", "MeshInstance3D", true, false):
				var me := (mi as MeshInstance3D).mesh as ArrayMesh
				if me == null or me.get_blend_shape_count() == 0: continue
				mit_form += 1
				for i in me.get_blend_shape_count():
					if (mi as MeshInstance3D).get_blend_shape_value(i) > 0.5: gesetzt += 1
			pruefe(mit_form >= 3, "%s: nur %d Netze mit Formschluesseln" % [k, mit_form])
			pruefe((gesetzt > 0) == (form != ""), "%s %s: Form gesetzt %d" % [k, form, gesetzt])
			# Toenung an Haut und Haar
			var getoent := 0
			for x in mats:
				var t = (x as ShaderMaterial).get_shader_parameter("toenung")
				if t is Vector3 and (t as Vector3).distance_to(Vector3.ONE) > 0.01: getoent += 1
			pruefe(getoent >= 2, "%s %s: nur %d Materialien getoent" % [k, a, getoent])
			# Grundausruestung sichtbar: Waffe (und Schild) auf dem Ruecken
			var waffe := sk.find_children("RueckenWaffe", "", false, false).size()
			var schild := sk.find_children("RueckenSchild", "", false, false).size()
			pruefe(waffe == 1, "%s: Waffe auf dem Ruecken %d" % [k, waffe])
			pruefe(schild == (1 if k in ["FIGHTER", "CLERIC"] else 0), "%s: Schild auf dem Ruecken %d" % [k, schild])
			# steht auf dem Boden, aufrecht, etwa menschengross
			ap.play("Stehen")
			ap.seek(0.0, true)
			var fuss := sk.get_bone_global_pose(sk.find_bone("foot_l")).origin
			var kopf := sk.get_bone_global_pose(sk.find_bone("Head")).origin
			pruefe(absf(fuss.y) < 0.2 and kopf.y > 1.4 and kopf.y < 1.9, "%s: Fuss %.2f, Kopf %.2f m" % [k, fuss.y, kopf.y])
			# Chef 23:0x („trägt keine Robe“): die Robe des Magiers faellt zwischen den Beinen bis unter die Waden
			if k == "WIZARD" and a.is_empty():
				var tief := 9.0
				for mi in m.find_children("*", "MeshInstance3D", true, false):
					if not String(mi.name).begins_with("Kleid"): continue
					for v in ((mi as MeshInstance3D).mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
						var p: Vector3 = HeldFigur.im_raum(m, mi) * v
						if absf(p.x) < 0.05: tief = minf(tief, p.y)
				pruefe(tief < 0.35, "WIZARD: Robe endet zwischen den Beinen bei %.2f m" % tief)
			print("%s %s: Gehen %.2f m/s, Kopf %.2f m, %d Netze mit Form, %d getoent" % [k, a, m.get_meta("gehen_m_je_s"), kopf.y, mit_form, getoent])
			m.free()
	var v := {}
	for k in HeldFigur.KLASSEN_VORGABE: v[str(HeldFigur.KLASSEN_VORGABE[k])] = k
	pruefe(v.size() == 4, "Vorgaben der Klassen nicht verschieden")
	print("HELDKLASSEN gut" if falsch == 0 else "HELDKLASSEN %d FALSCH" % falsch)
	quit(0 if falsch == 0 else 1)
