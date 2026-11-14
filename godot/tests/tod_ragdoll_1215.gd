extends SceneTree
# 1215: physikalisches Sterben am echten Goblin im Kampfort (braucht die gebauten Modelle, darum nicht im Logiksatz). Je Goblin
# ein Tod mit Stoß von links, einer von rechts (RAGDOLL an): die Physik übernimmt, er liegt und friert ein; gemessen Knie (Winkel
# Oberschenkel zu Unterschenkel), tiefster Knochen gegen den Boden, Weg der Brust in Stoßrichtung, Zeit bis zum Liegen, Bilder mit
# Physik. Meldet und hält bei Fehlern an (Exit 1). Aufruf: im Ordner godot mit -s res://tests/tod_ragdoll_1215.gd

const Probe = preload("res://kampf/probe.gd")
const Figur = preload("res://kampf/figur.gd")

var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _pruef(name: String, gut: bool, wert: String) -> void:
	print("TODRAGDOLL1215 %s: %s (%s)" % [name, "gut" if gut else "FEHLER", wert])
	if not gut:
		fehler += 1


## Knochennamen je Gerüst (wie ragdoll.gd): Brust, je Seite Hüfte, Knie, Knöchel, Ballen; tiefste Punkte
const NAMEN := {
	"ual": {"brust": "spine_03", "l": ["thigh_l", "calf_l", "foot_l", "ball_l"], "r": ["thigh_r", "calf_r", "foot_r", "ball_r"],
		"tief": ["pelvis", "spine_01", "spine_02", "spine_03", "Head", "calf_l", "calf_r", "foot_l", "foot_r", "hand_l", "hand_r"]},
	"strecke": {"brust": "belly-chest", "l": ["hipL-thighL", "kneeL-calfL", "ankleL-heelL", "ballL-toeL"], "r": ["hipR-thighR", "kneeR-calfR", "ankleR-heelR", "ballR-toeR"],
		"tief": ["pelvis-waist", "belly-chest", "chestTop-neck", "neck-neckTop", "kneeL-calfL", "kneeR-calfR", "ankleL-heelL", "ankleR-heelR", "foL-wrL", "foR-wrR"]},
}


func _pos(sk: Skeleton3D, n: String) -> Vector3:
	return sk.global_transform * sk.get_bone_global_pose(sk.find_bone(n)).origin


func _run() -> void:
	Figur.ragdoll_probe = true
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "GOBLINS"
	root.add_child(p)
	await process_frame
	p._start(5)
	for i in 12:
		await process_frame
	var kf = p.fight
	var feinde: Array = kf.figures.values().filter(func(f): return f.fighter.monster != null)
	for k in mini(2, feinde.size()):
		var fig = feinde[k]
		var sk: Skeleton3D = fig._find(fig.model, "Skeleton3D")
		if k == 0:
			var nn := []
			for b in sk.get_bone_count():
				nn.append(sk.get_bone_name(b))
			print("TODRAGDOLL1215 Knochen: ", nn)
		var nm: Dictionary = NAMEN["ual" if sk.find_bone("spine_03") >= 0 else "strecke"]
		var vorn0: Vector3 = ((_pos(sk, nm.l[3]) - _pos(sk, nm.l[2])) * Vector3(1, 0, 1)).normalized()
		var quer: Vector3 = (kf.facing(true).cross(Vector3.UP)).normalized() * (1.0 if k == 0 else -1.0)
		fig.tod_stoss = quer * 1.4
		var brust0 := _pos(sk, nm.brust)
		var boden: float = fig.global_position.y
		seed(3 + k)
		fig.die()
		if fig.ragdoll == null:
			_pruef("%s Ragdoll" % fig.fighter.id, false, "nicht eingerichtet")
			continue
		var n := 0
		var tiefste := INF
		while fig.ragdoll.phase != "liegt" and n < 60 * 8:
			await physics_frame
			n += 1
			if fig.ragdoll.phase == "physik":
				# in der Physik aus den Körpern (die Haltung im Skelett zeigt dann noch den Stand vor der Übernahme)
				for bn in fig.ragdoll.knochen:
					if bn in nm.tief:
						var pb: PhysicalBone3D = fig.ragdoll.knochen[bn]
						tiefste = minf(tiefste, (pb.global_transform * pb.body_offset.affine_inverse()).origin.y - boden)
		for bn in nm.tief:
			tiefste = minf(tiefste, _pos(sk, bn).y - boden)
		await process_frame
		var id: String = fig.fighter.id
		_pruef("%s liegt" % id, fig.ragdoll.phase == "liegt", "nach %.2f s, %d Bilder Physik, %s" % [n / 60.0, fig.ragdoll.bilder_physik, fig.tod_name])
		var knick := 0.0
		for sd in ["l", "r"]:
			var h := _pos(sk, nm[sd][0])
			var kn := _pos(sk, nm[sd][1])
			var f := _pos(sk, nm[sd][2])
			# Knie nach hinten: der Unterschenkel weicht zur Seite der Ferse aus (gegen die Zehen, im Raum des Oberschenkels)
			var th := sk.get_bone_global_pose(sk.find_bone(nm[sd][0])).basis.orthonormalized()
			var th0 := sk.get_bone_global_rest(sk.find_bone(nm[sd][0])).basis.orthonormalized()
			var v := sk.global_transform.basis.orthonormalized() * (th * (th0.inverse() * (sk.global_transform.basis.orthonormalized().inverse() * vorn0)))
			var w := rad_to_deg((kn - h).angle_to(f - kn))
			var seite := -1.0 if (f - kn).dot(v) > (kn - h).normalized().dot(v) * (f - kn).length() + 0.005 and w > 5.0 else 1.0
			print("TODRAGDOLL1215 %s Knie %s: %.0f° %s" % [id, sd, w, "nach hinten" if seite > 0 else "NACH VORN"])
			knick = maxf(knick, w * seite)
			_pruef("%s Knie %s nicht nach vorn" % [id, sd], seite > 0 or w < 5.0, "%.0f°" % w)
		_pruef("%s Knie knicken" % id, knick > 10.0, "%.0f°" % knick)
		_pruef("%s nicht im Boden" % id, tiefste > -0.08, "tiefster %.3f m" % tiefste)
		var lage := []
		for bn in nm.tief:
			lage.append("%s %.2f" % [bn, _pos(sk, bn).y - boden])
		print("TODRAGDOLL1215 %s Lage am Ende (Höhe über Boden): %s" % [id, ", ".join(lage)])
		var weg := (_pos(sk, nm.brust) - brust0).dot(quer)
		_pruef("%s fällt mit dem Stoß" % id, weg > 0.05, "Brust %+.2f m quer" % weg)
		var vorher := []
		for b in sk.get_bone_count():
			vorher.append(sk.get_bone_pose(b))
		for i in 20:
			await process_frame
		var wandert := 0.0
		for b in sk.get_bone_count():
			wandert = maxf(wandert, (sk.get_bone_pose(b).origin - vorher[b].origin).length())
		_pruef("%s eingefroren" % id, wandert < 0.002, "%.4f" % wandert)
	print("TODRAGDOLL1215 %s" % ("alles gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
