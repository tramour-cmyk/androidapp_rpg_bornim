extends SceneTree
# 376.1 ohne Bild: je Klasse die Figur (heldfigur.gd) mit Grundausruestung und Aussehen; prueft Bewegungen, Formschluessel, Haar,
# Bart, Toenung, Waffen auf dem Ruecken und dass die Figur auf dem Boden steht. Braucht daten/held_*.bin (held_klassen.py).
# 376.1 Tracht je Herkunft: Held und Heldin je Klasse, Statur als Formschluessel, je Herkunft die Kapuze (Jaegerkind) und kein Haar darunter.
# 870.4: statt der vier Klassen die vier Herkuenfte, die bisher ihre Tracht trugen (Wachsoldat, Zauberlehrling, Herumtreiber, Klosterschueler)
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
	herkuenfte(info)
	for kg in ["Wachsoldat", "Zauberlehrling", "Herumtreiber", "Klosterschüler", "Wachsoldat:w", "Zauberlehrling:w", "Herumtreiber:w", "Klosterschüler:w"]:
		var k := String(kg).get_slice(":", 0)
		var g := "w" if String(kg).ends_with(":w") else "m"
		pruefe(HeldFigur.da(k, g), kg + " fehlt")
		if not HeldFigur.da(k, g): continue
		var hw := BrsHeld.fuer_spiel("Test", "Mensch", k)
		# Beispielkopf je Klasse (Chef 23:0x): eigene Vorgabe, Haut nicht „Hell“
		pruefe(int(HeldFigur.vorgabe(k)["haut"]) > 0, "%s: Vorgabe Haut Hell" % k)
		var mit_bart := "Hair_Beard" if g == "m" else ""
		for a in [{"geschlecht": g}, {"geschlecht": g, "form": "rund", "frisur": "Hair_Buzzed", "bart": mit_bart, "haut": 3, "haarfarbe": 2, "statur": "kraeftig"},
				{"geschlecht": g, "form": "hager", "frisur": "", "bart": "", "statur": "schlank"}]:
			var mats := []
			var w := {"herkunft": k, "volk": "HUMAN", "aussehen": a, "ausruestung": hw.ausruestung}
			var m := HeldFigur.baue(w, mats)
			pruefe(m != null, "%s %s: keine Figur" % [k, a])
			if m == null: continue
			root.add_child(m)
			var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			for b in ["Stehen", "Gehen", "Rennen"]: pruefe(ap != null and ap.has_animation(b), "%s: Bewegung %s fehlt" % [k, b])
			pruefe(float(m.get_meta("gehen_m_je_s")) > 0.5 and float(m.get_meta("gehen_m_je_s")) < 2.5, "%s: Gehtempo %s" % [k, m.get_meta("gehen_m_je_s")])
			pruefe((m.get_meta("faust_L") as Dictionary).has("knochen"), "%s: linke Faust fehlt" % k)
			var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
			var haare := sk.find_children("Haar_*", "BoneAttachment3D", false, false).size()
			var soll := int(String(HeldFigur.aussehen_voll(a, k)["frisur"]) != "" and not bool(HeldFigur.tracht(w)["kapuze"])) \
				+ int(String(HeldFigur.aussehen_voll(a, k)["bart"]) != "")
			pruefe(haare == soll, "%s %s: %d Haarteile statt %d" % [k, a, haare, soll])
			# Formschluessel: die gewaehlte Form steht auf 1 an Haut und Haar
			var form := String(HeldFigur.aussehen_voll(a, k)["form"])
			var gesetzt := 0
			var mit_form := 0
			var statur_an := {}
			var statur_da := {}
			for mi in m.find_children("*", "MeshInstance3D", true, false):
				var me := (mi as MeshInstance3D).mesh as ArrayMesh
				if me == null or me.get_blend_shape_count() == 0: continue
				mit_form += 1
				for i in me.get_blend_shape_count():
					var bn := String(me.get_blend_shape_name(i))
					if (mi as MeshInstance3D).get_blend_shape_value(i) > 0.5:
						if bn.begins_with("statur_"): statur_an[bn] = int(statur_an.get(bn, 0)) + 1
						else: gesetzt += 1
					if bn.begins_with("statur_"): statur_da[bn] = int(statur_da.get(bn, 0)) + 1
			pruefe(mit_form >= 3, "%s: nur %d Netze mit Formschluesseln" % [k, mit_form])
			pruefe((gesetzt > 0) == (form != ""), "%s %s: Form gesetzt %d" % [k, form, gesetzt])
			# Statur: beide Schluessel an jedem Netz der Figur; gewaehlt genau einer, an allen Netzen
			var st := String(a.get("statur", "normal"))
			pruefe(int(statur_da.get("statur_schlank", 0)) >= 3 and int(statur_da.get("statur_kraeftig", 0)) >= 3, "%s: Statur fehlt %s" % [kg, statur_da])
			pruefe(statur_an.keys() == ([] if st == "normal" else ["statur_" + st]), "%s %s: Statur gesetzt %s" % [kg, st, statur_an])
			if st != "normal": pruefe(int(statur_an.get("statur_" + st, 0)) == int(statur_da.get("statur_" + st, 0)), "%s: Statur nicht an allen Netzen" % kg)
			# Toenung an Haut und Haar
			var getoent := 0
			for x in mats:
				var t = (x as ShaderMaterial).get_shader_parameter("toenung")
				if t is Vector3 and (t as Vector3).distance_to(Vector3.ONE) > 0.01: getoent += 1
			pruefe(getoent >= 2, "%s %s: nur %d Materialien getoent" % [k, a, getoent])
			# Grundausruestung sichtbar: Waffe auf dem Ruecken oder (417, Stab) in der Hand, Schild auf dem Ruecken
			var waffe := sk.find_children("RueckenWaffe", "", false, false).size() + m.find_children("Getragen", "", false, false).size()
			var schild := sk.find_children("RueckenSchild", "", false, false).size()
			pruefe(waffe == 1, "%s: Waffe auf dem Ruecken oder in der Hand %d" % [k, waffe])
			pruefe(schild == (1 if k == "Wachsoldat" else 0), "%s: Schild auf dem Ruecken %d" % [kg, schild])   # 870.4: Startausruestung nach Herkunft
			# steht auf dem Boden, aufrecht, etwa menschengross
			ap.play("Stehen")
			ap.seek(0.0, true)
			var fuss := sk.get_bone_global_pose(sk.find_bone("foot_l")).origin
			var kopf := sk.get_bone_global_pose(sk.find_bone("Head")).origin
			pruefe(absf(fuss.y) < 0.2 and kopf.y > 1.4 and kopf.y < 1.9, "%s: Fuss %.2f, Kopf %.2f m" % [k, fuss.y, kopf.y])
			# Chef 23:0x („trägt keine Robe“): die Robe des Magiers faellt zwischen den Beinen bis unter die Waden
			if k == "Zauberlehrling" and a.size() == 1:
				var tief := 9.0
				for mi in m.find_children("*", "MeshInstance3D", true, false):
					if not String(mi.name).begins_with("Kleid"): continue
					for v in ((mi as MeshInstance3D).mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
						var p: Vector3 = HeldFigur.im_raum(m, mi) * v
						if absf(p.x) < 0.05: tief = minf(tief, p.y)
				pruefe(tief < 0.35, "Zauberlehrling: Robe endet zwischen den Beinen bei %.2f m" % tief)
			print("%s %s: %s, Gehen %.2f m/s, Kopf %.2f m, %d Netze mit Form, %d getoent" % [kg, a, m.get_meta("tracht"), m.get_meta("gehen_m_je_s"), kopf.y, mit_form, getoent])
			m.free()
	var v := {}
	for k in HeldFigur.HERKUNFT_VORGABE: v[str(HeldFigur.HERKUNFT_VORGABE[k])] = k
	pruefe(v.size() == 4, "Vorgaben der Herkuenfte: %d verschiedene statt 4" % v.size())
	print("HELDKLASSEN gut" if falsch == 0 else "HELDKLASSEN %d FALSCH" % falsch)
	quit(0 if falsch == 0 else 1)

# je Herkunft (held-klassen.json herkuenfte) Held und Heldin: Modell da, Kapuze nur beim Jaegerkind, darunter kein Haar
func herkuenfte(info: Dictionary) -> void:
	var hk: Dictionary = info.get("herkuenfte", {})
	pruefe(hk.size() == 8, "Herkuenfte: %d statt 8" % hk.size())
	for h in hk:
		for g in ["m", "w"]:
			var a := {"geschlecht": g, "frisur": "Hair_Long"}
			var m := HeldFigur.baue({"herkunft": h, "volk": "HUMAN", "aussehen": a, "ausruestung": {}}, [])
			pruefe(m != null, "%s %s: keine Figur" % [h, g])
			if m == null: continue
			var kap := 0
			for mi in m.find_children("*", "MeshInstance3D", true, false):
				if String(mi.name).contains("Head_Hood") and (mi as MeshInstance3D).visible: kap += 1
			var soll := bool(hk[h].get("kapuze", false))
			pruefe((kap > 0) == soll, "%s %s: Kapuze %d" % [h, g, kap])
			var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
			var haar := sk.find_children("Haar_Hair_Long", "BoneAttachment3D", false, false).size()
			pruefe(haar == (0 if soll else 1), "%s %s: Haar %d bei Kapuze %s" % [h, g, haar, soll])
			print("HERKUNFT %s %s: %s, Kapuze %d, Haar %d" % [h, g, m.get_meta("tracht"), kap, haar])
			m.free()
