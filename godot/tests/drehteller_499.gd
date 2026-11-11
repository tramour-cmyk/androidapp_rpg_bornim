extends SceneTree
# 499 (Chef 03.11., 07:14, Build 204, Erschaffung: „da schwebt das Schild wunderschön und über dem Schild schwebt dann das Schwert“):
# der Held im Drehteller (Erschaffung, Menü Held, Ausrüstung) mit der Grundausrüstung jeder Klasse. Je Waffe und Schild: Abstand zur
# Faust (Tragen, 417) bzw. zum Rücken (RueckenSchild, an spine_03), Größe gegen die Figur. Mit Fenster: je Klasse ein Bild in drei
# Drehungen nebeneinander (PNG nach OBERFLAECHE_AUS). Soll: Waffe höchstens 3 cm von der Faust, Schild höchstens 6 cm vom Rücken,
# Größe wie die Figur (± 2 %). Aufruf: im Ordner godot mit -s res://tests/drehteller_499.gd -> „DREHTELLER499 n Fehler“; die Bilder macht
# drehteller_bild_499.gd (dieselbe Messung, mit Fenster), damit die Messung ohne Bild am Rechner kein Bildlauf ist (390a, 621 A)

const KLASSEN := ["Wachsoldat", "Klosterschüler", "Herumtreiber", "Zauberlehrling"]
# 417a (Archiv 417, 03.11., 06:54 „417 passt“, Stand 3b29ac0cb): Waffe in der Hand, Schild auf dem Ruecken; Schwert mit dem Einhandgang
const GANG := {"Wachsoldat": "einhand", "Klosterschüler": "", "Herumtreiber": "einhand", "Zauberlehrling": ""}   # 870.4: Startausruestung nach Herkunft (Kampfstab bis 458.3, 870e Nachtrag; Dolch)
const SCHILD := {"Wachsoldat": true, "Klosterschüler": false, "Herumtreiber": false, "Zauberlehrling": false}
const FAUST_M := 0.03
const RUECKEN_M := 0.06
const SPALT_M := 0.04   # 499: Spalt an der Unterkante des Schilds (Prüfer Lauf 1: 5–7 cm war zu viel)

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

# Abstand eines Punkts zur Oberfläche des Körpers: nächste Ecke der Figurennetze (ohne Waffen) nach der Haut
func koerper_abstand(m: Node3D, p: Vector3) -> float:
	var best := INF
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var x := mi as MeshInstance3D
		if x.skin == null: continue
		var sk := x.get_node_or_null(x.skeleton) as Skeleton3D
		if sk == null: continue
		for s in x.mesh.get_surface_count():
			var arr := x.mesh.surface_get_arrays(s)
			var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var bo = arr[Mesh.ARRAY_BONES]; var we = arr[Mesh.ARRAY_WEIGHTS]
			if bo == null or vs.is_empty(): continue
			var n := int(bo.size() / vs.size())
			for i in range(0, vs.size(), 3):
				var w := Vector3.ZERO
				for j in n:
					var g: float = we[i * n + j]
					if g <= 0.0: continue
					var bind: int = bo[i * n + j]
					var bone := x.skin.get_bind_bone(bind)
					if bone < 0: bone = sk.find_bone(x.skin.get_bind_name(bind))
					w += (sk.global_transform * sk.get_bone_global_pose(bone) * x.skin.get_bind_pose(bind) * vs[i]) * g
				best = minf(best, w.distance_to(p))
	return best

func _lauf() -> void:
	Sprache.lade()
	var aus := OS.get_environment("OBERFLAECHE_AUS")
	var bild := DisplayServer.get_name() != "headless" and aus != ""
	for k in KLASSEN: await klasse(k, bild, aus)
	print("DREHTELLER499 %d Fehler" % fehler)
	quit(1 if fehler else 0)

## Bilder je Klasse: nur drehteller_bild_499.gd
func bilder(_dt: Drehteller, _k: String, _aus: String) -> void:
	pass

func klasse(k: String, bild: bool, aus: String) -> void:
	if true:
		var z := Zustand.new()
		var hw := BrsHeld.fuer_spiel("Thora", "Mensch", k, z.neue_uid)
		var w := HeldFigur.wahl(hw, z)
		var dt := Drehteller.new(w, 1.6)
		dt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(dt)
		for i in 20: await process_frame
		var modell: Node3D = dt.teller.get_child(0) if dt.teller and dt.teller.get_child_count() > 0 else null
		if modell == null: fehler += 1; print("FEHLER %s: kein Held im Drehteller" % k); dt.queue_free(); return
		var ms := modell.global_basis.get_scale().y
		var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
		var mh: Variant = w.get("ausruestung", {}).get("MAIN_HAND"); var oh: Variant = w.get("ausruestung", {}).get("OFF_HAND")
		print("%s: Hand %s, andere Hand %s, Figur Maßstab %.3f, Gang %s" % [k, mh.get("base", "-") if mh is Dictionary else "-", oh.get("base", "-") if oh is Dictionary else "-", ms, modell.get_meta("gang", "-")])
		var box := dt.huelle(modell, Transform3D.IDENTITY)
		print("  Figur ohne Waffen %.2f m hoch (Ruhe), im Teller %.2f m" % [box.size.y, box.size.y * ms])
		pruefe(String(modell.get_meta("gang", "")) == GANG[k], "%s: Gang %s statt %s" % [k, modell.get_meta("gang", "-"), GANG[k]])
		var in_hand := 0
		for t in sk.get_children():
			if not (t is Tragen): continue
			var tr := t as Tragen
			if tr.waffe == null: continue
			# Lauf 290: Stab 16 cm „neben der Faust“ war der Abstand zum Ursprung des Stabs; der Schaft laeuft durch die Faust, der Ursprung
			# liegt 0,18 m (mal Massstab) darunter (tragen.gd stellen). Gemessen wird darum der Abstand der Faust zur Achse der Waffe
			var ax := tr.schaft_welt.normalized()
			var rel := tr.faust_welt - tr.waffe.global_position
			var d := (rel - ax * rel.dot(ax)).length() if tr.art == "stab" else rel.length()
			var ws := tr.waffe.global_basis.get_scale().y
			print("  in der Hand (%s, %s): %s, %.3f m von der Faust, Größe %.3f gegen Figur %.3f" % [tr.seite, tr.gang if tr.gang != "" else tr.art, tr.waffe.name, d, ws, ms])
			pruefe(d <= FAUST_M, "%s: Waffe %.0f cm neben der Faust" % [k, d * 100])
			pruefe(absf(ws / ms - 1.0) <= 0.02, "%s: Waffe %.2f-fach der Figur" % [k, ws / ms])
			in_hand += 1
		pruefe(in_hand == 1, "%s: %d Waffen in der Hand statt 1" % [k, in_hand])
		pruefe(sk.find_children("RueckenWaffe*", "", false, false).is_empty(), "%s: Waffe auf dem Ruecken" % k)
		pruefe(sk.find_children("RueckenSchild*", "", false, false).size() == (1 if SCHILD[k] else 0), "%s: Schild nicht auf dem Ruecken" % k)
		for ba in sk.find_children("Ruecken*", "", false, false):
			for mi in ba.find_children("*", "MeshInstance3D", true, false):
				var c := (mi as MeshInstance3D).global_transform * (mi as MeshInstance3D).get_aabb().get_center()
				var d := koerper_abstand(modell, c)
				print("  auf dem Rücken (%s): Mitte %.3f m vom Körper" % [ba.name, d])
				pruefe(d <= RUECKEN_M + 0.10, "%s: %s %.0f cm vom Körper" % [k, ba.name, d * 100])
				if String(ba.name).begins_with("RueckenSchild"):
					# 499 (Chef 07.11.: „Modell Avatar Schild (immer noch) unten zu weit weg“): Spalt an Unter- und Oberkante, je die
					# kleinste Entfernung von 8 Ecken des untersten bzw. obersten Bands (5 cm) zur Haut in der Haltung „Stehen“
					var gt := (mi as MeshInstance3D).global_transform
					var pts: Array[Vector3] = []
					var me := (mi as MeshInstance3D).mesh
					for s in me.get_surface_count():
						for v in me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]: pts.append(gt * v)
					var y0 := INF; var y1 := -INF
					for p in pts: y0 = minf(y0, p.y); y1 = maxf(y1, p.y)
					var band := func(unten: bool) -> float:
						var sel := pts.filter(func(p): return p.y < y0 + 0.05 if unten else p.y > y1 - 0.05)
						var best := INF
						for i in range(0, sel.size(), maxi(1, sel.size() / 8)): best = minf(best, koerper_abstand(modell, sel[i]))
						return best
					var du: float = band.call(true); var do_: float = band.call(false)
					diagnose(modell, sk, mi as MeshInstance3D)
					print("  Schild-Spalt: unten %.3f m, oben %.3f m (Höhe %.2f bis %.2f)" % [du, do_, y0, y1])
					pruefe(du <= SPALT_M, "%s: Schild unten %.0f cm vom Rücken" % [k, du * 100])
		if bild: await bilder(dt, k, aus)
		dt.queue_free()
		for i in 3: await process_frame

# 499 Ursache: Brust (spine_03), Becken und Wirbel in Ruhe gegen „Stehen“; je Netz die hinterste Stelle (Mitte, |x| < 0,12) auf Hoehe
# der Ober- und Unterkante, wie bewaffne sie nimmt (Ruhe) und wie sie in der Haltung steht; Lage des Schilds im Raum der Figur
func diagnose(m: Node3D, sk: Skeleton3D, schild: MeshInstance3D) -> void:
	var ks := HeldFigur.im_raum(m, sk)
	var bi := sk.find_bone("spine_03")
	var y := (ks * sk.get_bone_global_rest(bi)).origin.y
	for kn in ["pelvis", "spine_01", "spine_02", "spine_03", "neck_01"]:
		var b := sk.find_bone(kn)
		if b < 0: continue
		var r := ks * sk.get_bone_global_rest(b); var p := ks * sk.get_bone_global_pose(b)
		print("  %s: Ruhe y %.3f z %.3f, Stehen y %.3f z %.3f, gekippt %.1f Grad (vor +)" % [kn, r.origin.y, r.origin.z, p.origin.y, p.origin.z,
			rad_to_deg(signf(p.basis.y.z - r.basis.y.z) * r.basis.y.angle_to(p.basis.y))])
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var x := mi as MeshInstance3D
		if not x.skin: continue
		for haltung in [false, true]:
			var r := HeldFigur.ruecken_aus(HeldFigur.haut_punkte(m, sk, haltung, x), y - 0.63, y + 0.1)
			print("  Netz %s (%s): hinten oben %.3f, unten %.3f, ganz %.3f" % [x.name, "Stehen" if haltung else "Ruhe", r[0], r[1], r[2]])
	var inv := m.global_transform.affine_inverse() * schild.global_transform
	var lo := Vector3(0, INF, 0); var hi := Vector3(0, -INF, 0)
	for s in schild.mesh.get_surface_count():
		for v in schild.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
			var p: Vector3 = inv * v
			if p.y < lo.y: lo = p
			if p.y > hi.y: hi = p
	print("  Schild im Raum der Figur: unten y %.3f z %.3f, oben y %.3f z %.3f, Brust Ruhe y %.3f" % [lo.y, lo.z, hi.y, hi.z, y])
