# 454 (Chef 01.11., 11:05: „wenn die Wölfe zubeißen, dass eigentlich die Ausrichtung des Wolfes, wenn ich seine Achse betrachte,
# dass die gar nicht auf dem Helden geht, dass die immer irgendwie perspektivisch rechts daneben ein bisschen beißen“): erst messen.
# Ohne Bild (Kamera nur zum Umrechnen): je Biss im Kampfort mit Kaufwolf und Kaufheld, auf Autopilot, im Augenblick, in dem die
# Schnauze am weitesten vorn ist:
#   Winkel  = Wolfsachse (Blick des Rumpfs, waagerecht) gegen die Richtung zur Mitte des Ziels (Becken), + = Ziel rechts vom Wolf
#   seitlich = wie weit die Schnauze neben der Körpermitte des Ziels liegt, quer zur Biss-Richtung (m, + = rechts vom Wolf)
#   Bild    = am Schirm (1080 × 2340): Schnauze waagerecht neben der Zielmitte in Bildpunkten (+ = rechts im Bild)
# Run: godot --headless --fixed-fps 30 --path godot -s res://tests/biss_achse_454.gd   [KLASSEN=FIGHTER,CLERIC SEED=7 BILDER=3000]
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const SCHNAUZE := ["Wolf_Head_JawEndSHJnt", "Wolf_Head_TopSHJnt", "kopf"]
const RUMPF := ["Wolf_Spine_02SHJnt", "Wolf_Spine_01SHJnt", "ROOT"]

var bisse := []        # [Klasse, Wolf, Ziel, Bewegung, Winkel, seitlich m, Bild px, Abstand m]
var gesehen := {}
var quer_je := {}      # Bewegung -> [Summe Schnauze quer m, Bilder]
var laufend := {}      # Wolf -> [beste Vorlage dieses Bisses, größte Reichweite]
var anfang := {}       # Wolf -> [Zielmitte, Drehung des Wolfs, Ort des Wolfs] im ersten Bild des Bisses


func _initialize() -> void:
	_run.call_deferred()


func _knochen(sk: Skeleton3D, namen: Array) -> Vector3:
	for nm in namen:
		var i := sk.find_bone(nm)
		if i >= 0:
			return sk.global_transform * sk.get_bone_global_pose(i).origin
	return Vector3.INF


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	if not FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json"):
		print("Biss 454: ohne Kaufwolf, nichts zu messen")
		quit(0)
		return
	for k in (OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(["FIGHTER", "CLERIC", "ROGUE", "WIZARD"])):
		var p = Probe.new()
		p.hero_cls = k
		p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
		p.foe = "WOLVES"
		root.add_child(p)
		await process_frame
		p._start(int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7)
		for i in 4:
			await process_frame
		var kf = p.fight
		kf.mars.find("merc").auto = true
		kf.mars.set_autopilot(true)
		if not kf.busy:
			kf.go_on()
		var n := 0
		while n < (int(OS.get_environment("BILDER")) if OS.get_environment("BILDER") != "" else 3000):
			await process_frame
			n += 1
			_bild(kf, k)
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
					kf.go_on()
				else:
					var c = kf.mars.current()
					var ts: Array = kf.mars.targets(c)
					kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		for w in laufend.keys():
			bisse.append(laufend[w][0])
		laufend.clear()
		print("Kampf %s: %s nach %d Bildern" % [k, kf.mars.outcome, n])
		kf.queue_free()
		p.queue_free()
		await process_frame
	_bilanz()
	quit(0)


func _bild(kf, k: String) -> void:
	var cam := root.get_viewport().get_camera_3d()
	for f in kf.figures.values():
		if f.fighter.monster == null or not f.visible or f.down:
			continue
		var a := String(f.anim.current_animation) if f.anim else ""
		var id := "%s/%s" % [k, f.fighter.id]
		if OS.get_environment("SPUR") != "" and a != "":
			gesehen[a] = gesehen.get(a, 0) + 1
			if a in ["Biss", "Sprungbiss"] and not gesehen.has("aim " + str(f.aim != null)):
				gesehen["aim " + str(f.aim != null)] = 1
				var sk0 := f._find(f.model, "Skeleton3D") as Skeleton3D
				print("Knochen ", sk0.get_bone_name(0), " … ", [sk0.find_bone(SCHNAUZE[0]), sk0.find_bone(RUMPF[0])])
		# Schnauze quer zur Achse des Wolfs je Bewegung (links +, aus Sicht des Wolfs): gehört der Versatz zum Modell oder zum Biss?
		var sk1 := f._find(f.model, "Skeleton3D") as Skeleton3D
		if sk1 != null and a != "":
			var sn := _knochen(sk1, SCHNAUZE)
			var vv: Vector3 = f.global_transform.basis.z
			vv.y = 0.0
			var q := (Vector3(sn.x, 0, sn.z) - Vector3(f.global_position.x, 0, f.global_position.z)).dot(vv.normalized().cross(Vector3.DOWN))
			var e: Array = quer_je.get(a, [0.0, 0])
			quer_je[a] = [e[0] + q, e[1] + 1]
		# Ziel: der Mensch, auf den das Tier beim Beginn des Bisses blickt (kleinster Abstand zur Blicklinie vor ihm), für den ganzen
		# Biss fest; die Ansage (aim) kann einem anderen gelten (Kleriker: Ansage Held, Biss an den Söldner)
		var ziel_f = null
		if anfang.has(id) and is_instance_valid(anfang[id][4]):
			ziel_f = anfang[id][4]
		else:
			var blick: Vector3 = f.global_transform.basis.z
			blick.y = 0.0
			blick = blick.normalized().rotated(Vector3.UP, -deg_to_rad(float(f.bite.get("Biss", [0, 0, 0])[2])))
			var best := INF
			for g in kf.figures.values():
				if g.fighter.monster != null or not g.visible or g.down:
					continue
				var zu: Vector3 = g.global_position - f.global_position
				zu.y = 0.0
				if zu.dot(blick) <= 0.0:
					continue
				var quer_ab: float = (zu - blick * zu.dot(blick)).length()
				if quer_ab < best:
					best = quer_ab
					ziel_f = g
		if not a in ["Biss", "Sprungbiss"] or ziel_f == null:
			if laufend.has(id):
				bisse.append(laufend[id][0])
				laufend.erase(id)
			anfang.erase(id)
			continue
		var sk := f._find(f.model, "Skeleton3D") as Skeleton3D
		var tsk = ziel_f._find(ziel_f.model, "Skeleton3D") as Skeleton3D
		if sk == null or tsk == null:
			continue
		var schnauze := _knochen(sk, SCHNAUZE)
		var rumpf := _knochen(sk, RUMPF)
		var ziel := _knochen(tsk, ["pelvis", "spine_01", "Hips"])
		if schnauze == Vector3.INF or ziel == Vector3.INF:
			continue
		var pos: Vector3 = f.global_position
		if not anfang.has(id):
			anfang[id] = [ziel, f.rotation.y, pos, f.bite.get(a, f.bite.get("Biss", [0, 0, 0]))[2], ziel_f]
		var a0: Array = anfang[id]
		var ziel_weg := Vector2(ziel.x - a0[0].x, ziel.z - a0[0].z).length()
		var dreh := rad_to_deg(wrapf(f.rotation.y - a0[1], -PI, PI))
		var soll := wrapf(rad_to_deg(atan2(a0[0].x - a0[2].x, a0[0].z - a0[2].z) - f.rotation.y) + float(a0[3]), -180.0, 180.0)
		var reich: float = Vector2(schnauze.x - pos.x, schnauze.z - pos.z).length()
		if laufend.has(id) and reich <= laufend[id][1]:
			continue
		var vorn: Vector3 = f.global_transform.basis.z
		vorn.y = 0.0
		vorn = vorn.normalized()
		var zum: Vector3 = ziel - pos
		zum.y = 0.0
		var winkel := rad_to_deg(vorn.signed_angle_to(zum.normalized(), Vector3.DOWN))     # + = Ziel rechts vom Wolf (von oben)
		# seitlich: Schnauze gegen die Achse Wolf → Ziel, quer dazu (rechts vom Wolf +)
		var quer := zum.normalized().cross(Vector3.UP)
		var seit := (Vector3(schnauze.x, 0, schnauze.z) - Vector3(ziel.x, 0, ziel.z)).dot(-quer)
		var px := 0.0
		if cam and rumpf != Vector3.INF:
			var s2 := cam.unproject_position(schnauze)
			var z2 := cam.unproject_position(ziel)
			px = s2.x - z2.x     # + = Schnauze rechts von der Zielmitte im Bild
		var sz := Vector2(schnauze.x - ziel.x, schnauze.z - ziel.z).length()
		# Schnauze gegen den Rumpf des Wolfs: wie weit sie quer zu seinem Blick steht (links +, aus Sicht des Wolfs)
		var links := vorn.cross(Vector3.DOWN)     # Blick +Z: links des Wolfs ist +X
		var kopfquer := (Vector3(schnauze.x, 0, schnauze.z) - Vector3(pos.x, 0, pos.z)).dot(links)
		laufend[id] = [[k, f.fighter.id, ziel_f.fighter.id, a, winkel, seit, px, zum.length(), sz, kopfquer, ziel_weg, dreh, soll], reich]


func _bilanz() -> void:
	print("— 454 Bisse: %d %s" % [bisse.size(), gesehen if OS.get_environment("SPUR") != "" else ""])
	for a in quer_je:
		print("Schnauze quer zum Wolf in %s: %+.2f m (Mittel über %d Bilder)" % [a, quer_je[a][0] / quer_je[a][1], quer_je[a][1]])
	if bisse.is_empty():
		return
	var sw := 0.0; var ss := 0.0; var sp := 0.0
	var rechts := 0
	for b in bisse:
		print("Biss %s %s → %s (%s): Winkel %+.1f°, Schnauze seitlich %+.2f m, im Bild %+.0f px, Abstand %.2f m, Schnauze–Zielmitte %.2f m, Schnauze quer zum Wolf %+.2f m; Ziel seit Bissbeginn %.2f m gewandert, Wolf %+.1f° gedreht, Drehung gegen Soll %+.1f°" % b)
		sw += b[4]; ss += b[5]; sp += b[6]
		if b[6] > 0: rechts += 1
	var n := float(bisse.size())
	print("— 454 Mittel: Winkel %+.1f°, seitlich %+.2f m, im Bild %+.0f px; Schnauze rechts der Zielmitte im Bild: %d von %d" % [sw / n, ss / n, sp / n, rechts, bisse.size()])
