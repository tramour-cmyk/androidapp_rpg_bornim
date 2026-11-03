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
# Runde 3 (Prüfer Runde 2, 02.11.: Stab quer durch die Beine, Schwert knapp durchs Bein, Finger vorn durch den Schild, Hand liegend offen,
# Schild klappt in 4 Bildern 90°): gemessen an Haut und Kleidung wie man sie sieht, nicht nur an den Kapseln
const HAUT_GRENZE := 0.01        # Waffe höchstens so tief in Haut oder Kleidung (ohne den rechten Arm, der sie hält)
const FINGER_GRENZE := 0.003     # Finger der Schildhand höchstens so weit vor der Vorderseite des Schilds
const OFFEN_GRENZE := 0.03       # Fingerspitzen der Schwerthand höchstens so viel weiter vom Griff als in der Kampfhaltung
const SPRUNG_GRAD := 15.0        # Waffe oder Schild je Bild höchstens so viel gedreht …
const SPRUNG_PLUS := 5.0         # … oder höchstens so viel mehr, als der Satz selbst in diesem Bild dreht

var fails := 0
var _hilfe = null


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
	_hilfe = hilfe
	# Lauf 190: je Klasse der Schutz wie gebaut (V0) und der Vergleich V1 (figur.gd schutz_variante); Lauf 197: V1 half nicht (12 cm,
	# Zucken 69,6°), jetzt V2 (je Punkt der Achse gegen alle Beinecken) und Schwertarm beim Aufstehen abgespreizt (A15, A30, bodenhalt.gd);
	# Lauf 200: Arm abgespreizt schob den Griff ins Kleid (verworfen), V2 sah die Tiefe, _loesen machte sie größer: V2 im Gitter, V3 = V2
	# mit der besten Lage aller Schritte, V4 = wie gebaut mit der besten Lage
	# Lauf 201: das Gitter blieb leer (V2, V3 ohne Haut), V4 wie V0; Lauf 203: V3 sieht 11,3 cm, findet keinen Schritt hinaus; V5 probiert
	# feste Drehungen um den Griff zuerst
	for kv in [["FIGHTER", 0, 0.0], ["FIGHTER", 3, 0.0], ["FIGHTER", 5, 0.0], ["CLERIC", 5, 0.0]]:
		var p = Probe.new()
		p.hero_cls = kv[0]
		var k: String = kv[0] + ("" if kv[1] == 0 else " V%d" % kv[1]) + ("" if kv[2] == 0.0 else " A%d" % int(kv[2]))
		p.merc_cls = "FIGHTER" if kv[0] != "FIGHTER" else "CLERIC"
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
		fig.messen = true
		fig.schutz_variante = kv[1]
		fig.spreizen_grad = kv[2]
		var schild: Node = fig.model.find_child("Schild", true, false)
		var sm: Node3D = (schild.find_children("*", "MeshInstance3D", true, false)[0] if not schild is MeshInstance3D else schild) if schild else null
		var klinge: Node3D = null
		for at in fig.find_children("*", "BoneAttachment3D", true, false):
			if String(at.get_meta("was", "")) in ["longsword", "shortsword", "quarterstaff"]:
				klinge = at
		var boden: float = fig.global_position.y
		var haut := _haut_maske(sk, _teilbaum(sk, ["upperarm_r"]), false)     # Haut und Kleidung ohne den rechten Arm
		var finger := _haut_maske(sk, _teilbaum(sk, ["hand_l"]).filter(func(b): return sk.get_bone_name(b) != "hand_l"), true)
		var werte := {}     # Bewegung -> [Schildnetz m, Klinge in Kapsel m, im Boden m, Waffe in Haut m, Finger vor dem Schild m, Hand offen m, wo]
		# nach den Schichten (skeleton_updated, nach figur.gd): die Pose, die man sieht, mit bodenhalt.gd
		var mess := {"vorher": {}, "vorvorher": {}, "sprung": 0.0, "zuck": 0.0, "hand": -INF, "wo": "", "zwo": "", "q": {}, "qq": {}, "satz": 0.0, "ueber": -INF, "uwo": "",
			"us": 0, "us_sum": 0, "us_n": 0}
		var nach := func() -> void:
			mess.us = maxi(mess.us, fig.mess_us)     # 438a V2: was der Schutz je Bild kostet
			mess.us_sum += fig.mess_us
			mess.us_n += 1
			# Runde 3 (Lauf 160: Fingerspitzen unverändert, obwohl bodenhalt.gd die Faust hält): Knochen nur hier so, wie man sie sieht;
			# außerhalb von skeleton_updated liest man die Pose ohne die Modifier (bodenhalt.gd)
			_runde3(fig, sk, klinge, schild, haut, finger, werte, String(fig.anim.current_animation))
			for t in fig._boden_teile:     # 438a: Waffe und Schild drehen sich aus Boden und Körper ohne Zucken
				# wie man sie sieht: Lage in der Welt (die Korrektur selbst darf gegen eine Hand, die beim Aufprall federt, hin und her gehen)
				var gw: Transform3D = sk.global_transform * sk.get_bone_global_pose(t[4]) * ((t[0] as Node3D).transform)
				var korr := gw.basis.orthonormalized().get_rotation_quaternion()
				var hier := "%s %.2f s %s" % [fig.anim.current_animation, fig.anim.current_animation_position, t[5]]
				# dasselbe ohne Korrektur (Lage aus dem Griff): wie sehr dreht und zuckt schon die Bewegung des Satzes selbst
				var qs := (sk.global_transform * sk.get_bone_global_pose(t[4]) * (t[1] as Transform3D)).basis.orthonormalized().get_rotation_quaternion()
				if mess.vorher.has(t[0]):
					var q1: Quaternion = mess.vorher[t[0]]
					var gr := rad_to_deg(q1.angle_to(korr))
					# Runde 4 (Lauf 164: Schild 34,5° in einem Bild beim Aufprall): gezählt wird, was über SPRUNG_GRAD liegt und mehr als
					# SPRUNG_PLUS über der Drehung, die der Satz in diesem Bild selbst macht (die Faust schlägt mit dem Arm auf)
					var gs_: float = rad_to_deg((mess.q[t[0]] as Quaternion).angle_to(qs)) if mess.q.has(t[0]) else 0.0
					var ueber := minf(gr - SPRUNG_GRAD, gr - gs_ - SPRUNG_PLUS)
					if ueber > mess.ueber:
						mess.ueber = ueber
						mess.uwo = "%s: %.1f°, der Satz %.1f°" % [hier, gr, gs_]
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
		fig.anim.play("SS_IdleCombat", 0.2)     # wie film_438a: erst Kampfhaltung (Finger durch den Schild schon hier, Prüfer 1,2 s)
		for n in 24:
			await process_frame
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
			var e: Array = werte.get(b, [-INF, -INF, -INF, -INF, -INF, -INF, ""])
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
		var griff_ruhe: float = werte.get("SS_IdleCombat", [0, 0, 0, 0, 0, 0.0])[5]
		for b in werte:
			var e: Array = werte[b]
			if e.size() > 7:
				print("  %s %s: Waffe in Haut %.3f m (%s), Finger vor dem Schild %.3f m, Fingerspitzen vom Griff %.3f m, Waffe flachste %.0f° zur Waagrechten" % [k, b, e[3], e[6], e[4], e[5], e[7]])
			_check(e[3] <= HAUT_GRENZE, "%s %s: Waffe höchstens %.3f m in Haut oder Kleidung" % [k, b, e[3]])
			_check(e[4] <= FINGER_GRENZE, "%s %s: Finger der Schildhand höchstens %.3f m vor dem Schild" % [k, b, e[4]])
			_check(e[5] <= griff_ruhe + OFFEN_GRENZE, "%s %s: Schwerthand geschlossen, Fingerspitzen %.3f m vom Griff (Kampfhaltung %.3f)" % [k, b, e[5], griff_ruhe])
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
		_check(mess.ueber <= 0.0, "%s: Waffe und Schild je Bild höchstens %.0f° oder %.0f° über dem Satz gedreht (schlimmstes Bild %s; größte Drehung %.1f° bei %s)" % [k, SPRUNG_GRAD, SPRUNG_PLUS, mess.uwo, mess.sprung, mess.wo])
		_check(mess.hand <= HAND_GRENZE, "%s: Hände höchstens %.3f m im Boden" % [k, mess.hand])
		print("  %s: Schutz je Bild höchstens %.1f ms, im Mittel %.2f ms (Rechner des Ablaufs)" % [k, mess.us / 1000.0, mess.us_sum / 1000.0 / maxf(mess.us_n, 1)])
		p.queue_free()
		await process_frame
	print("STURZ 438a %s" % ("gut" if fails == 0 else "FALSCH %d" % fails))
	quit(1 if fails > 0 else 0)


## Knochen, deren Kette einen der Namen in [wurzeln] enthält (mit ihm selbst)
func _teilbaum(sk: Skeleton3D, wurzeln: Array) -> Array:
	var out := []
	for i in sk.get_bone_count():
		var p := i
		while p >= 0:
			if sk.get_bone_name(p) in wurzeln:
				out.append(i)
				break
			p = sk.get_bone_parent(p)
	return out


## Haut und Kleidung wie schild_406 _haut_lesen, mit Normalen; [drin]: nur Ecken mit mindestens halbem Gewicht auf [knochen], sonst
## nur Ecken mit weniger als 0,3 darauf
func _haut_maske(sk: Skeleton3D, knochen: Array, drin: bool) -> Array:
	var out := []
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.skin == null or m.get_parent() is BoneAttachment3D:
			continue
		for s in m.mesh.get_surface_count():
			var ar := m.mesh.surface_get_arrays(s)
			if ar[Mesh.ARRAY_BONES] == null or ar[Mesh.ARRAY_NORMAL] == null:
				continue
			var nb: int = ar[Mesh.ARRAY_BONES].size() / ar[Mesh.ARRAY_VERTEX].size()
			var idx := PackedInt32Array()
			for v in ar[Mesh.ARRAY_VERTEX].size():
				var w := 0.0
				for j in nb:
					var bb: int = m.skin.get_bind_bone(ar[Mesh.ARRAY_BONES][v * nb + j])
					if bb < 0:
						bb = sk.find_bone(m.skin.get_bind_name(ar[Mesh.ARRAY_BONES][v * nb + j]))
					if bb in knochen:
						w += ar[Mesh.ARRAY_WEIGHTS][v * nb + j]
				if (w >= 0.5) if drin else (w < 0.3):
					idx.append(v)
			if not idx.is_empty():
				out.append([m, m.skin, ar[Mesh.ARRAY_VERTEX], ar[Mesh.ARRAY_NORMAL], ar[Mesh.ARRAY_BONES], ar[Mesh.ARRAY_WEIGHTS], nb, idx])
	return out


## Lage der Ecken in der Welt: [Orte, Normalen, Netzname je Ecke]; nur Ecken in [box] (leer: alle)
func _haut_welt(sk: Skeleton3D, haut: Array, box: AABB) -> Array:
	var pos := PackedVector3Array()
	var nor := PackedVector3Array()
	var wer := PackedStringArray()
	var g := sk.global_transform
	for h in haut:
		var skin: Skin = h[1]
		var tr := []
		for i in skin.get_bind_count():
			var bb := skin.get_bind_bone(i)
			if bb < 0:
				bb = sk.find_bone(skin.get_bind_name(i))
			tr.append(g * sk.get_bone_global_pose(bb) * skin.get_bind_pose(i))
		var vs: PackedVector3Array = h[2]
		var ns: PackedVector3Array = h[3]
		var nb: int = h[6]
		for v in h[7]:
			var p := Vector3.ZERO
			var n := Vector3.ZERO
			var stark := -1     # Lauf 183: Waffe 5–12,5 cm in Haut, aber wo am Körper? stärkster Knochen der Ecke
			var sw := 0.0
			for j in nb:
				var w: float = h[5][v * nb + j]
				if w > 0.0:
					var t: Transform3D = tr[h[4][v * nb + j]]
					p += t * vs[v] * w
					n += t.basis * ns[v] * w
					if w > sw:
						sw = w
						stark = h[4][v * nb + j]
			if box.size != Vector3.ZERO and not box.has_point(p):
				continue
			pos.append(p)
			nor.append(n.normalized())
			var kn := ""
			if stark >= 0:
				kn = String(skin.get_bind_name(stark))
				if kn == "" and skin.get_bind_bone(stark) >= 0:
					kn = sk.get_bone_name(skin.get_bind_bone(stark))
			wer.append("%s/%s" % [String(h[0].name), kn])
	return [pos, nor, wer]


## Runde 3: je Bild Waffe in Haut und Kleidung, Finger der Schildhand vor dem Schild, Fingerspitzen der Schwerthand vom Griff
func _runde3(fig, sk: Skeleton3D, klinge: Node3D, schild: Node, haut: Array, finger: Array, werte: Dictionary, b: String) -> void:
	var e: Array = werte.get(b, [-INF, -INF, -INF, -INF, -INF, -INF, ""])
	while e.size() < 8:
		e.append(-INF if e.size() < 6 else ("" if e.size() == 6 else INF))
	if klinge:
		# Achse der Waffe: die beiden am weitesten auseinander liegenden Ecken; Halbmesser: Mittelwert des Abstands der Ecken zur Achse
		var ecken: PackedVector3Array = _hilfe._ecken(klinge)
		var mitte := Vector3.ZERO
		for q in ecken:
			mitte += q
		mitte /= maxf(ecken.size(), 1)
		var a := mitte
		for q in ecken:
			if q.distance_to(mitte) > a.distance_to(mitte):
				a = q
		var z := a
		for q in ecken:
			if q.distance_to(a) > z.distance_to(a):
				z = q
		var ab := []
		for q in ecken:
			ab.append(q.distance_to(Geometry3D.get_closest_point_to_segment(q, a, z)))
		ab.sort()
		var r: float = ab[ab.size() / 2] if not ab.is_empty() else 0.01
		var box := AABB(a, Vector3.ZERO).expand(z).grow(0.12)
		var hw: Array = _haut_welt(sk, haut, box)
		var pos: PackedVector3Array = hw[0]
		var l := a.distance_to(z)
		var wo_neu := ""
		var g_ab := INF
		var g_tief := -INF
		for i in int(l / 0.015) + 1:
			var s := a.lerp(z, i * 0.015 / maxf(l, 0.001))
			var best := -1
			var bd := 0.12
			for j in pos.size():
				var d := s.distance_to(pos[j])
				if d < bd:
					bd = d
					best = j
			if best >= 0:
				var t: float = r - (s - pos[best]).dot(hw[1][best])
				# Lauf 187 (Runde 5 kaum besser: Aufstehen 12,9 cm): wie weit die tiefste Stelle vom Griff liegt, wie tief der Griff
				# selbst steckt und wie weit _boden_schutz die Waffe gedreht hat; steckt schon die Faust im Kleid, hilft kein Drehen
				var ab_griff := s.distance_to(klinge.global_position)
				if ab_griff < g_ab:
					g_ab = ab_griff
					g_tief = t
				if t > e[3]:
					e[3] = t
					wo_neu = "%s %.2f s; %.2f m vom Griff" % [hw[2][best], fig.anim.current_animation_position, ab_griff]
		if wo_neu != "":
			# Lauf 189: „gedreht ?“, klinge ist der BoneAttachment3D, in _boden_teile steht das Netz darunter
			var gedreht := "?"
			for bt in fig._boden_teile:
				var wn: Node3D = bt[0]
				if is_instance_valid(wn) and (wn == klinge or klinge.is_ancestor_of(wn)):
					gedreht = "%.0f°" % rad_to_deg((bt[1] as Transform3D).basis.orthonormalized().get_rotation_quaternion().angle_to(wn.transform.basis.orthonormalized().get_rotation_quaternion()))
			var ms: Dictionary = fig.mess_schutz
			var schutz := "Schutz: Sturz %s, korrigiert %s, %d Hautpunkte, %d Kapseln; Haut vorher %.3f, nach _loesen %.3f (gedreht %s, %.0f°), zum letzten Bild %.0f°, Stufe %s, Ende %.3f m" % [
				ms.get("sturz"), ms.get("korr"), ms.get("haut", -1), ms.get("nah", -1), ms.get("vor", NAN), ms.get("loesen", NAN), ms.get("gedreht"),
				ms.get("will", NAN), ms.get("zum_letzten", NAN), ms.get("stufe", "?"), ms.get("ende", NAN)] if not ms.is_empty() else "Schutz: nichts"
			e[6] = "%s, Griff %.3f m in Haut, gedreht %s; %s" % [wo_neu, g_tief, gedreht, schutz]
		# Prüfer Runde 2 (Kämpfer von vorn: Klinge waagrecht vor dem Bauch): flachster Winkel der Achse zur Waagrechten
		e[7] = minf(e[7], rad_to_deg(asin(clampf(absf((z - a).normalized().y), 0.0, 1.0))))
		# Fingerspitzen der Schwerthand zur Achse (offen liegende Hand, Prüfer 7,1–9,0 s)
		for nm in ["index_03_r", "middle_03_r", "ring_03_r"]:
			var bi := sk.find_bone(nm)
			if bi >= 0:
				var p: Vector3 = sk.global_transform * sk.get_bone_global_pose(bi).origin
				e[5] = maxf(e[5], p.distance_to(Geometry3D.get_closest_point_to_segment(p, a, z)))
	if schild and not finger.is_empty():
		# im Raum des Schilds (vorn +z) je Feld von 2 cm die vorderste Ecke; nur Felder mitten im Schild (alle 8 Nachbarn da)
		var inv := (schild as Node3D).global_transform.affine_inverse()
		var feld := {}
		for p in _hilfe._ecken(schild):
			var q: Vector3 = inv * p
			var k := Vector2i(floori(q.x / 0.02), floori(q.y / 0.02))
			feld[k] = maxf(feld.get(k, -INF), q.z)
		var fw: Array = _haut_welt(sk, finger, AABB())
		for p in fw[0]:
			var q: Vector3 = inv * p
			var k := Vector2i(floori(q.x / 0.02), floori(q.y / 0.02))
			if not feld.has(k):
				continue
			var innen := true
			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if not feld.has(k + Vector2i(dx, dy)):
						innen = false
			if innen and q.z - float(feld[k]) < 0.05:
				e[4] = maxf(e[4], q.z - float(feld[k]))
	werte[b] = e
