# 438a (Chef 01.11., 20:1x, Archiv 438a: Hinfallen 1 und Aufstehen 1 aus dem Paket der Waffe; „bei fast allem geht das Schild durch den
# Körperteil … das Schwert … durch den Kopf“): der Kaufheld mit Schwert und Schild (Kämpfer, Kleriker) fällt im Kampfort rücklings hin
# (SS_DeathBack) und steht aus der Rückenlage auf (SS_GetBackUpBack). Ohne Bild, jedes Bild gemessen: Körper oder Kleidung durch den
# Schild (Netz, wie schild_406.gd), Klinge in einer Körperkapsel (ohne den rechten Arm, der sie hält), Schild oder Klinge im Boden,
# Hände im Boden (bodenhalt.gd) und wie weit Waffe und Schild sich von Bild zu Bild aus Boden und Körper drehen (figur.gd _boden_schutz).
# Aufruf: godot headless mit 30 Bildern je Sekunde, Skript res://tests/sturz_438a.gd (Ende 0 = alles in den Grenzen; ohne Kauf 0)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Schild406 = preload("res://tests/schild_406.gd")
const GRENZE_M := 0.02       # Grundstand E3: höchstens 2 cm je Bild
const NETZ_GRENZE_M := 0.06  # Schildnetz wie schild_406.gd KAMPF_M (Kleidung liegt über den Kapseln)
const BODEN_M := 0.02
const OHNE_KLINGE := [9, 11]     # MENSCH_KAPSELN: rechter Ober- und Unterarm halten das Schwert
const ZUCK_GRAD := 6.0           # Waffe und Schild in der Welt: hin und gleich wieder zurück höchstens so viel (Zucken); schnell in eine
# Richtung dürfen sie (der Schild schlägt beim Aufprall flach auf, wie die Bewegung des Satzes ihn in den Boden führt)
const HAND_GRENZE := 0.02        # bodenhalt.gd: Handgelenk und Fingerglieder höchstens so tief im Boden

var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok     " if ok else "FEHLER ") + what)
	if not ok:
		fails += 1


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin") or not HeldFigur.da("FIGHTER"):
		print("Sturz 438a: ohne Kauf, nichts zu prüfen")
		quit(0)
		return
	var hilfe = Schild406.new()
	for k in ["FIGHTER", "CLERIC"]:
		var p = Probe.new()
		p.hero_cls = k
		p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
		p.foe = "WOLVES"
		root.add_child(p)
		await process_frame
		p._start(7)
		for i in 6:
			await process_frame
		var fig = p.fight.figures.get("hero")
		_check(fig != null and fig.anim.has_animation("SS_DeathBack") and fig.anim.has_animation("SS_GetBackUpBack"), "%s: Hinfallen und Aufstehen aus Sword & Shield da" % k)
		if fig == null or not fig.anim.has_animation("SS_DeathBack"):
			continue
		var sk := fig._find(fig.model, "Skeleton3D") as Skeleton3D
		hilfe._haut_lesen(sk)
		var schild: Node = fig.model.find_child("Schild", true, false)
		var sm: Node3D = (schild.find_children("*", "MeshInstance3D", true, false)[0] if not schild is MeshInstance3D else schild) if schild else null
		var klinge: Node3D = null
		for at in fig.find_children("*", "BoneAttachment3D", true, false):
			if String(at.get_meta("was", "")) in ["longsword", "shortsword", "quarterstaff"]:
				klinge = at
		var boden: float = fig.global_position.y
		var werte := {}     # Bewegung -> [Schildnetz m, Klinge in Kapsel m, im Boden m]
		# nach den Schichten (skeleton_updated, nach figur.gd): die Pose, die man sieht, mit bodenhalt.gd
		var mess := {"vorher": {}, "vorvorher": {}, "sprung": 0.0, "zuck": 0.0, "hand": -INF, "wo": "", "zwo": "", "q": {}, "qq": {}, "satz": 0.0}
		var nach := func() -> void:
			for t in fig._boden_teile:     # 438a: Waffe und Schild drehen sich aus Boden und Körper ohne Zucken
				# wie man sie sieht: Lage in der Welt (die Korrektur selbst darf gegen eine Hand, die beim Aufprall federt, hin und her gehen)
				var gw: Transform3D = sk.global_transform * sk.get_bone_global_pose(t[4]) * ((t[0] as Node3D).transform)
				var korr := gw.basis.orthonormalized().get_rotation_quaternion()
				var hier := "%s %.2f s %s" % [fig.anim.current_animation, fig.anim.current_animation_position, t[5]]
				if mess.vorher.has(t[0]):
					var q1: Quaternion = mess.vorher[t[0]]
					var gr := rad_to_deg(q1.angle_to(korr))
					if gr > mess.sprung:
						mess.sprung = gr
						mess.wo = hier
					if mess.vorvorher.has(t[0]):
						var q0: Quaternion = mess.vorvorher[t[0]]
						var z := rad_to_deg(q0.angle_to(q1)) + gr - rad_to_deg(q0.angle_to(korr))
						if z > mess.zuck:
							mess.zuck = z
							mess.zwo = hier
					mess.vorvorher[t[0]] = q1
				mess.vorher[t[0]] = korr
				# dasselbe ohne Korrektur (Lage aus dem Griff): wie sehr zuckt schon die Bewegung des Satzes selbst
				var qs := (sk.global_transform * sk.get_bone_global_pose(t[4]) * (t[1] as Transform3D)).basis.orthonormalized().get_rotation_quaternion()
				if mess.q.has(t[0]) and mess.qq.has(t[0]):
					var a0: Quaternion = mess.qq[t[0]]
					var a1: Quaternion = mess.q[t[0]]
					mess.satz = maxf(mess.satz, rad_to_deg(a0.angle_to(a1) + a1.angle_to(qs) - a0.angle_to(qs)))
				if mess.q.has(t[0]):
					mess.qq[t[0]] = mess.q[t[0]]
				mess.q[t[0]] = qs
			for nm in ["hand_l", "hand_r", "middle_03_r", "index_03_r", "middle_03_l", "index_03_l"]:
				var bi := sk.find_bone(nm)
				if bi >= 0:
					mess.hand = maxf(mess.hand, boden - (sk.global_transform * sk.get_bone_global_pose(bi).origin).y)
		sk.skeleton_updated.connect(nach)
		fig.knocked_down()
		var ab := String(fig.anim.current_animation)
		_check(ab == "SS_DeathBack", "%s: knocked_down spielt %s" % [k, ab])
		var fall: float = fig.anim.get_animation("SS_DeathBack").length
		var lang: float = fall + fig.anim.get_animation("SS_GetBackUpBack").length + 1.0
		var aufgestanden := false
		for n in int(lang * 30):
			await process_frame
			if not aufgestanden and n >= int((fall + 0.4) * 30):
				fig.rise()
				aufgestanden = true
			var b := String(fig.anim.current_animation)
			var e: Array = werte.get(b, [-INF, -INF, -INF])
			if sm:
				e[0] = maxf(e[0], hilfe._netz_tiefe(sm, hilfe._haut_ecken(sk))[0])
				for q in hilfe._ecken(schild):
					e[2] = maxf(e[2], boden - q.y)
			if klinge:
				var kap := []
				for c in hilfe._kapseln(sk):
					if not c[3] in OHNE_KLINGE:
						kap.append(c)
				var ecken: PackedVector3Array = hilfe._ecken(klinge)
				e[1] = maxf(e[1], hilfe._tiefe(ecken, kap)[0])
				for q in ecken:
					e[2] = maxf(e[2], boden - q.y)
			werte[b] = e
		for b in werte:
			if not String(b).begins_with("SS_DeathBack") and not String(b).begins_with("SS_GetBackUp"):
				continue
			var e: Array = werte[b]
			_check(e[0] <= NETZ_GRENZE_M, "%s %s: Körper höchstens %.3f m im Schild (Netz)" % [k, b, e[0]])
			_check(e[1] <= GRENZE_M, "%s %s: Klinge höchstens %.3f m im Körper" % [k, b, e[1]])
			_check(e[2] <= BODEN_M, "%s %s: Schild und Klinge höchstens %.3f m im Boden" % [k, b, e[2]])
		_check(werte.has("SS_GetBackUpBack"), "%s: steht aus der Rückenlage auf" % k)
		sk.skeleton_updated.disconnect(nach)
		_check(mess.zuck <= maxf(ZUCK_GRAD, mess.satz), "%s: Waffe und Schild zucken höchstens %.1f° hin und zurück (%s; der Satz selbst %.1f°); je Bild höchstens %.1f° (%s)" % [k, mess.zuck, mess.zwo, mess.satz, mess.sprung, mess.wo])
		_check(mess.hand <= HAND_GRENZE, "%s: Hände höchstens %.3f m im Boden" % [k, mess.hand])
		p.queue_free()
		await process_frame
	print("STURZ 438a %s" % ("gut" if fails == 0 else "FALSCH %d" % fails))
	quit(1 if fails > 0 else 0)
