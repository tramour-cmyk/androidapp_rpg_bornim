# 1516 (Chef 17.11., 07:32, am Tablet, Hauptmenü): der Zauberlehrling (zweiter von links) hält den Stab nicht, der Stab schwebt etwa
# 10 cm neben der Hand. Ohne Bild: die vier Helden wie im Hauptmenü (HauptmenueHelden); je Waffe in der Hand (Tragen, nicht Schildarm)
# der Abstand des Schafts (Achse durch den Griff) zur Mitte der Faust (Handknochen und die ersten Fingerglieder, nach dem Stellen der
# Waffe, Tragen.merken), über fünf Stellen der Haltung die schlechteste. Eine geschlossene Faust um den Schaft: höchstens 3 cm.
# Run: godot --headless --path godot -s res://tests/stab_menue_1516.gd   (ohne Kaufdateien „ohne Kauf“, 0)
extends SceneTree

const GRENZE := 0.03
var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	if not HauptmenueHelden.da():
		print("STAB1516 ohne Kauf, 0 Fehler")
		quit(0)
		return
	var hm := HauptmenueHelden.new()
	root.add_child(hm)
	for i in 10: await process_frame
	for trg in hm.figuren:
		var m := trg.get_child(0) as Node3D
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		var bew := String(trg.get_meta("haltung", ""))
		for c in sk.get_children():
			if not (c is Tragen) or (c as Tragen).gang == "schildarm" or (c as Tragen).waffe == null: continue
			var tr := c as Tragen
			tr.merken = true
			var schlecht := -INF
			for st in 5:
				if ap and ap.has_animation(bew):
					ap.play(bew); ap.seek(ap.get_animation(bew).length * st / 5.0, true); ap.pause()
				for i in 3: await process_frame
				if tr.posen.is_empty(): continue
				var a := _abstand(sk, tr)
				schlecht = maxf(schlecht, a)
			var name_ := String(tr.waffe.get_child(0).name) if tr.waffe.get_child_count() > 0 else ""
			print("STAB1516 %s %s Hand %s Gang %s: Schaft %.1f cm neben der Faustmitte" % [bew, name_, tr.seite, tr.gang, schlecht * 100.0])
			if schlecht > GRENZE:
				print("FEHLER %s: Waffe %.1f cm neben der Faust (Hand %s)" % [bew, schlecht * 100.0, tr.seite])
				fehler += 1
	hm.queue_free()
	await _kampf()
	print("STAB1516 %d Fehler" % fehler)
	quit(1 if fehler else 0)

## Kampf (Chef: „auch Welt und Kampf prüfen“): der Zauberlehrling als Probeheld gegen Wölfe; der Stab hängt dort am Handgelenk
## (BoneAttachment3D, kampf/figur.gd), Abstand der Längsachse des Stabnetzes zur Faustmitte der rechten Hand
func _kampf() -> void:
	var held := Testmodus.probeheld("Zauberlehrling", 1)
	var p = load("res://kampf/aufruf.gd").new()
	root.add_child(p)
	await process_frame
	if not p.starte("WOLVES", held, null, "wald", "tag", 2, -1, -1, 3):
		print("STAB1516 Kampf: kein Kampf"); fehler += 1; return
	var w := 0
	while (p.kampf == null or not p.kampf.is_inside_tree()) and w < 60:
		await process_frame
		w += 1
	for i in 45: await process_frame
	var fig = p.kampf.figures.get("hero")
	var sk := Gebiet.finde(fig, "Skeleton3D") as Skeleton3D if fig else null
	if sk == null:
		print("STAB1516 Kampf: keine Figur"); fehler += 1; return
	var lang := 0.0
	var achse_o := Vector3.ZERO; var achse_y := Vector3.UP
	for mi in fig.find_children("*", "MeshInstance3D", true, false):
		var at: Node = mi
		while at != null and not (at is BoneAttachment3D): at = at.get_parent()
		if at == null: continue
		var bx := (mi as MeshInstance3D).get_aabb()
		var gl := (mi as MeshInstance3D).global_transform
		var ax := [gl.basis.x * bx.size.x, gl.basis.y * bx.size.y, gl.basis.z * bx.size.z]
		for a in ax:
			if (a as Vector3).length() > lang:
				lang = (a as Vector3).length(); achse_y = (a as Vector3).normalized(); achse_o = gl * bx.get_center()
	if lang < 1.0:
		print("STAB1516 Kampf: kein Stab in der Hand (längstes Stück %.2f m)" % lang); fehler += 1; return
	for s in ["r", "l"]:
		var pts := []
		for n in ["hand_", "index_01_", "middle_01_", "ring_01_", "pinky_01_", "index_02_", "middle_02_", "ring_02_", "pinky_02_"]:
			var b := sk.find_bone(n + s)
			if b >= 0: pts.append(sk.global_transform * sk.get_bone_global_pose(b).origin)
		if pts.is_empty(): continue
		var mitte := Vector3.ZERO
		for q in pts: mitte += q
		mitte /= pts.size()
		var v: Vector3 = mitte - achse_o
		var d := (v - achse_y * v.dot(achse_y)).length()
		print("STAB1516 Kampf Hand %s: Stab (%.2f m) %.1f cm neben der Faustmitte" % [s, lang, d * 100.0])
		if s == "r" and d > GRENZE:
			print("FEHLER Kampf: Stab %.1f cm neben der rechten Faust" % (d * 100.0)); fehler += 1
	p.queue_free()

## Faustmitte: Mittel aus Handknochen und den ersten Gliedern von Zeige-, Mittel-, Ring- und Kleinfinger, eingerückt zur Handfläche
## durch die gekrümmten Finger (zweite Glieder); Abstand zur Achse des Schafts in der Welt
func _abstand(sk: Skeleton3D, tr: Tragen) -> float:
	var s := tr.seite
	var pts := []
	for n in ["hand_", "index_01_", "middle_01_", "ring_01_", "pinky_01_", "index_02_", "middle_02_", "ring_02_", "pinky_02_"]:
		var b := sk.find_bone(n + s)
		if b >= 0: pts.append(sk.global_transform * tr.posen[b].origin)
	if pts.is_empty(): return INF
	var mitte := Vector3.ZERO
	for p in pts: mitte += p
	mitte /= pts.size()
	var o := tr.waffe.global_transform * Vector3(tr.halt.get("griff", Vector3.ZERO))
	var y := (tr.waffe.global_basis * Vector3(tr.halt.get("achse", Vector3.UP))).normalized()
	var v := mitte - o
	return (v - y * v.dot(y)).length()
