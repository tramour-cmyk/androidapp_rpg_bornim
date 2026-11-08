extends SceneTree
# 499 (Chef 03.11., 07:14, Build 204, Erschaffung: „da schwebt das Schild wunderschön und über dem Schild schwebt dann das Schwert“):
# der Held im Drehteller (Erschaffung, Menü Held, Ausrüstung) mit der Grundausrüstung jeder Klasse. Je Waffe und Schild: Abstand zur
# Faust (Tragen, 417) bzw. zum Rücken (RueckenSchild, an spine_03), Größe gegen die Figur. Mit Fenster: je Klasse ein Bild in drei
# Drehungen nebeneinander (PNG nach OBERFLAECHE_AUS). Soll: Waffe höchstens 3 cm von der Faust, Schild höchstens 6 cm vom Rücken,
# Größe wie die Figur (± 2 %). Aufruf: im Ordner godot mit -s res://tests/drehteller_499.gd -> „DREHTELLER499 n Fehler“

const KLASSEN := ["FIGHTER", "CLERIC", "ROGUE", "WIZARD"]
# 417a (Archiv 417, 03.11., 06:54 „417 passt“, Stand 3b29ac0cb): Waffe in der Hand, Schild auf dem Ruecken; Schwert mit dem Einhandgang
const GANG := {"FIGHTER": "einhand", "CLERIC": "", "ROGUE": "einhand", "WIZARD": ""}
const SCHILD := {"FIGHTER": true, "CLERIC": true, "ROGUE": false, "WIZARD": false}
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
	for k in KLASSEN:
		var z := Zustand.new()
		var hw := Heldwerte.erschaffe("Thora", "HUMAN", k, {}, z.neue_uid)
		var w := HeldFigur.wahl(hw, z)
		var dt := Drehteller.new(w, 1.6)
		dt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(dt)
		for i in 20: await process_frame
		var modell: Node3D = dt.teller.get_child(0) if dt.teller and dt.teller.get_child_count() > 0 else null
		if modell == null: fehler += 1; print("FEHLER %s: kein Held im Drehteller" % k); dt.queue_free(); continue
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
			var d := tr.waffe.global_position.distance_to(tr.faust_welt)
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
					print("  Schild-Spalt: unten %.3f m, oben %.3f m (Höhe %.2f bis %.2f)" % [du, do_, y0, y1])
					pruefe(du <= SPALT_M, "%s: Schild unten %.0f cm vom Rücken" % [k, du * 100])
		if bild:
			var bilder: Array[Image] = []
			for winkel in [0.0, 90.0, 200.0]:
				dt.teller.rotation.y = deg_to_rad(winkel)
				dt.set_process(false)
				for i in 4: await process_frame
				await RenderingServer.frame_post_draw
				bilder.append(dt.get_child(0).get_texture().get_image())
			var b := bilder[0].get_width(); var h := bilder[0].get_height()
			var ges := Image.create(b * 3, h, false, Image.FORMAT_RGBA8)
			ges.fill(Color(0.05, 0.04, 0.03))
			for i in 3:
				var x := bilder[i]; x.convert(Image.FORMAT_RGBA8)
				ges.blend_rect(x, Rect2i(0, 0, b, h), Vector2i(b * i, 0))
			ges.save_png(aus + "/499_%s.png" % k)
			print("BILD ", aus + "/499_%s.png" % k)
		dt.queue_free()
		for i in 3: await process_frame
	print("DREHTELLER499 %d Fehler" % fehler)
	quit(1 if fehler else 0)
