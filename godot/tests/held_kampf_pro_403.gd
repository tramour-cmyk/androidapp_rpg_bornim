# 403 (Team Tom zu 376.1; Perikles: „Held gleitet im Kampf“, Fehler): die Kaufheldin im echten Kampfort, ohne Bild, die Regeln
# angehalten, je Klasse (Kämpfer, Kleriker, Schurke, Magier; als Held und als Söldner). Geprüft je Bild:
#  - Modell: Kaufkörper (HeldFigur) mit den Kampfbewegungen der UAL Pro, Waffe in der rechten Faust, Schild links;
#  - Platzwechsel: solange sie sich bewegt, spielt sie Gehen oder Rennen im Tempo der Beine (Füße gleiten nicht);
#  - Hieb aus zwei Entfernungen: sie geht hin, die Waffe liegt beim Aufschlag im Rand des Wolfs, danach rückwärts heim;
#  - Ausweichen zu beiden Seiten mit Ortswechsel, danach daheim; Treffer in mehreren Fassungen; Tod: liegt am Boden.
# Nur mit den Kaufmodellen (daten/held_<KLASSE>.bin, kampf/daten/held-kampf.bin) aussagekräftig; ohne sie: übersprungen (exit 0).
# Run: godot --headless --path godot -s res://tests/held_kampf_pro_403.gd   (exit code 0 = alles erfüllt)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const GLEIT := 0.12      # so weit darf das Tempo am Boden vom Tempo der Beine abweichen (Anteil)
const RAND_MIN := 0.0    # m: so tief liegt die Waffe beim Aufschlag mindestens im Rand des Ziels …
const RAND_MAX := 0.35   # … und höchstens (sonst schlägt sie durch das Ziel hindurch)
const FAUST_MAX := 0.06  # m: so weit liegt der Griff höchstens von der Mitte der Faust

var fehler := 0
## Kollision (DESIGN-ABNAHME „Selbst prüfen“: Waffe durch Körper, Kopf, Beine oder Schild), je Bewegung 24 Bilder
const KOLLISION_BEWEGUNGEN := ["Stehen", "Gehen", "Rennen", "Hieb", "Treffer", "Treffer_2", "Treffer_3", "Ausweichen", "Ausweichen links", "Ausholen"]
## Körper als Kapseln zwischen zwei Knochen (Radius m); der Waffenarm (rechts) zählt nicht
const KAPSELN := [["pelvis", "spine_02", 0.15], ["spine_02", "neck_01", 0.15], ["neck_01", "Head", 0.07], ["thigh_l", "calf_l", 0.085],
	["calf_l", "foot_l", 0.06], ["thigh_r", "calf_r", 0.085], ["calf_r", "foot_r", 0.06], ["upperarm_l", "lowerarm_l", 0.055],
	["lowerarm_l", "hand_l", 0.045]]
const KOPF_R := 0.12      # Kugel um den Kopf, 0,1 m über dem Kopfknochen


func _initialize() -> void:
	_all.call_deferred()


func _gut(ok: bool, text: String) -> void:
	print(("gut " if ok else "FEHLER ") + text)
	if not ok:
		fehler += 1


func _all() -> void:
	if not FileAccess.file_exists("res://kampf/daten/held-kampf.bin") or not HeldFigur.da("FIGHTER"):
		print("übersprungen: ohne Kaufheldin (daten/held_<KLASSE>.bin, kampf/daten/held-kampf.bin)")
		quit(0)
		return
	for paar in [["FIGHTER", "CLERIC"], ["ROGUE", "WIZARD"], ["CLERIC", "ROGUE"], ["WIZARD", "FIGHTER"]]:
		await _klassen(paar[0], paar[1])
	print("Kaufheldin 403: %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)


func _klassen(held_cls: String, merc_cls: String) -> void:
	var p = Probe.new()
	p.hero_cls = held_cls
	p.merc_cls = merc_cls
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start()
	for i in 4:
		await process_frame
	var k = p.fight
	var halt := func() -> void:     # Regeln anhalten wie probe.gd SCHAU=ort
		k.playing = true
		k.beats_lock.lock()
		k.beats.clear()
		k.beats_lock.unlock()
	for i in 30:
		halt.call()
		await process_frame
	var ziel = null
	for f in k.figures.values():
		if f.fighter.side == "FOES":
			if ziel == null:
				ziel = f
			else:
				f.visible = false
	for id in ["hero", "merc"]:
		var h = p.fig_of(id)
		var cls: String = h.fighter.hero.cls
		_gut(h.kauf_held and h.anim.has_animation("Hieb") and h.anim.has_animation("Treffer_3"), "%s (%s): Kaufkörper mit Kampfbewegungen" % [cls, id])
		if not h.kauf_held:
			continue
		var sk: Skeleton3D = h._find(h.model, "Skeleton3D")
		_gut(_faust(h, sk, "r", "Waffe") < FAUST_MAX, "%s: Griff %.3f m von der Mitte der rechten Faust" % [cls, _faust(h, sk, "r", "Waffe")])
		if h.OFF_HAND.has(cls):
			_gut(h.model.find_child("Schild", true, false) != null, "%s: Schild links" % cls)
		for nm in KOLLISION_BEWEGUNGEN:
			var r: Array = _kollision(h, sk, nm)
			_gut(r[0] == 0, "%s %s: Waffe in %d von %d Bildern im Körper oder Schild%s" % [cls, nm, r[0], r[1], (" (" + r[2] + ")") if r[0] > 0 else ""])
	var held = p.fig_of("hero")
	if not held.kauf_held:
		p.queue_free()
		return
	var cls: String = held.fighter.hero.cls
	for f in k.figures.values():     # der Söldner steht still daheim
		if f != held and f != ziel:
			f.visible = false
	# ---- Platzwechsel hin und zurück: Gehen (kurz) und Rennen (weit)
	var h0: Vector3 = held.home
	for wohin in [h0 + k.facing(true) * 0.9, h0, h0 + k.facing(true) * 2.4 + Vector3(1.0, 0, 0), h0]:
		held.glide_to(wohin)
		var bilder := 0
		var falsch := 0
		var gleit := 0.0
		var strecke := {}
		var vor: Vector3 = held.position
		var uhr: float = k.clock_ms
		var t0 := Time.get_ticks_msec()
		while held.tween and held.tween.is_running() and Time.get_ticks_msec() - t0 < 10000:
			halt.call()
			await process_frame
			var v: Vector3 = held.position - vor
			var dt: float = k.clock_ms - uhr
			vor = held.position
			uhr = k.clock_ms
			v.y = 0.0
			if v.length() < 0.002:
				continue
			bilder += 1
			var nm := String(held.anim.current_animation)
			if nm not in ["Gehen", "Rennen"]:
				falsch += 1
				continue
			var s: Array = strecke.get(nm, [0.0, 0.0])
			strecke[nm] = [s[0] + v.length(), s[1] + dt]
		for nm in strecke:
			gleit = maxf(gleit, absf(strecke[nm][0] / maxf(strecke[nm][1] / 1000.0, 0.001) / held._mps(nm) - 1.0))
		_gut(bilder > 3 and falsch == 0, "%s Platzwechsel %.1f m: %d Bilder unterwegs, %d ohne Gehen oder Rennen (%s)" % [cls, wohin.distance_to(h0), bilder, falsch, ", ".join(strecke.keys())])
		_gut(gleit < GLEIT or bilder <= 3, "%s Platzwechsel: Tempo am Boden weicht höchstens %.0f %% vom Schritt ab" % [cls, gleit * 100.0])
		_gut(held.position.distance_to(wohin) < 0.05, "%s Platzwechsel: am Ziel (%.2f m daneben)" % [cls, held.position.distance_to(wohin)])
	# ---- Hieb aus zwei Entfernungen: Waffe beim Aufschlag im Rand des Ziels, vorher gegangen, nicht geschoben
	for weit in [0.0, 1.5]:
		held.snap_to(h0 + k.facing(true) * weit)
		held._face()
		for i in 5:
			halt.call()
			await process_frame
		var ms: int = held.strike(ziel, {"spell": null})
		var lands: float = k.clock_ms + ms * 0.42
		var tief := -INF
		var hoch := 0.0
		var anims := {}
		var geschoben := 0
		var vor: Vector3 = held.position
		var nm_vor := String(held.anim.current_animation)
		while k.clock_ms < lands + 40.0:
			halt.call()
			await process_frame
			# Bewegungswechsel und Schritt fallen in dasselbe Bild (Anlauf beginnt, Hieb nach dem letzten Schritt): geschoben nur, wenn
			# weder davor noch jetzt gegangen oder gerannt wird
			var nm := nm_vor if nm_vor in ["Gehen", "Rennen"] else String(held.anim.current_animation)
			nm_vor = String(held.anim.current_animation)
			anims[nm_vor] = true
			var v: Vector3 = held.position - vor
			vor = held.position
			if Vector2(v.x, v.z).length() > 0.002 and nm not in ["Gehen", "Rennen"]:
				geschoben += 1
				print("  geschoben %.3f m in %s bei %.0f ms vor dem Aufschlag (Gang %s)" % [Vector2(v.x, v.z).length(), nm, lands - k.clock_ms, held.gang])
			if k.clock_ms >= lands - 25.0:
				var r: Array = _im_rand(held, ziel)
				if r[0] > tief:
					tief = r[0]
					hoch = r[1]
		_gut(tief >= RAND_MIN and tief <= RAND_MAX, "%s Hieb aus %.1f m weiter: Waffe beim Aufschlag %.2f m im Rand des Wolfs, %.2f m hoch (Bewegungen %s)" % [cls, weit, tief, hoch, ", ".join(anims.keys())])
		_gut(geschoben == 0, "%s Hieb: %d Bilder geschoben statt gegangen" % [cls, geschoben])
		var t0 := Time.get_ticks_msec()
		while held.tween and held.tween.is_running() and Time.get_ticks_msec() - t0 < 10000:
			halt.call()
			await process_frame
		for i in 20:
			halt.call()
			await process_frame
		_gut(held.position.distance_to(held.home) < 0.05, "%s Hieb: danach daheim (%.2f m daneben)" % [cls, held.position.distance_to(held.home)])
	# ---- Ausweichen zu beiden Seiten
	held.snap_to(h0)
	held._face()
	for nm in ["Ausweichen", "Ausweichen links"]:
		for i in 5:
			halt.call()
			await process_frame
		held.dodge(0, nm)
		var weg_max := 0.0
		var gespielt := false
		var t0 := Time.get_ticks_msec()
		await process_frame
		while held.tween and held.tween.is_running() and Time.get_ticks_msec() - t0 < 10000:
			halt.call()
			await process_frame
			gespielt = gespielt or String(held.anim.current_animation) == nm
			weg_max = maxf(weg_max, held.position.distance_to(h0))
		for i in 20:
			halt.call()
			await process_frame
		_gut(gespielt and weg_max > 0.8, "%s %s: Bewegung %s, bis %.2f m vom Platz" % [cls, nm, "gespielt" if gespielt else "FEHLT", weg_max])
		_gut(held.position.distance_to(h0) < 0.05, "%s %s: danach daheim (%.2f m daneben)" % [cls, nm, held.position.distance_to(h0)])
	# ---- Treffer: mehrere Fassungen
	var treffer := {}
	for i in 40:
		treffer[held._variante("Treffer")] = true
	_gut(treffer.size() >= 3, "%s Treffer: %d Fassungen (%s)" % [cls, treffer.size(), ", ".join(treffer.keys())])
	# ---- Tod: liegt am Boden
	held.hurt(0, true)
	var t1 := Time.get_ticks_msec()
	var sk: Skeleton3D = held._find(held.model, "Skeleton3D")
	var becken := INF
	while Time.get_ticks_msec() - t1 < 3500:
		halt.call()
		await process_frame
		becken = (sk.global_transform * sk.get_bone_global_pose(sk.find_bone("pelvis"))).origin.y
	_gut(becken < 0.3, "%s Tod: Becken liegt %.2f m über dem Boden" % [cls, becken])
	k.finish()
	p.queue_free()
	for i in 5:
		await process_frame


## Abstand (m) des Griffs (Ursprung des Dings [nm]) von der Mitte der Faust: zwischen Knöcheln und Fingerspitzen
func _faust(h, sk: Skeleton3D, s: String, nm: String) -> float:
	var w := h.model.find_child(nm, true, false) as Node3D
	if w == null:
		return INF
	var m := Vector3.ZERO
	for b in ["index_01_", "pinky_01_", "index_03_", "pinky_03_"]:
		m += (sk.global_transform * sk.get_bone_global_pose(sk.find_bone(b + s))).origin
	m *= 0.25
	# Abstand von der Achse der Waffe (+Y), ein Stab ist nicht in der Mitte gefasst (figur.gd STAB_VOR)
	var ax := w.global_basis.y.normalized()
	var o := w.global_position
	return m.distance_to(o + ax * ax.dot(m - o))


## Wie tief (m) die Waffe (Knoten „Waffe“) am Boden im Rand des Ziels liegt (> 0: darin) und in welcher Höhe ihr tiefster Punkt dort liegt
func _im_rand(held, ziel) -> Array:
	var best := -INF
	var hoch := 0.0
	var r: float = ziel.body_r()
	var w := held.model.find_child("Waffe", true, false) as Node3D
	if w == null:
		return [best, hoch]
	for m in w.find_children("*", "MeshInstance3D", true, false):
		var vs: PackedVector3Array = (m as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		for i in range(0, vs.size(), 3):
			var p: Vector3 = (m as MeshInstance3D).global_transform * vs[i]
			var d := r - Vector2(p.x - ziel.position.x, p.z - ziel.position.z).length()
			if d > best:
				best = d
				hoch = p.y
	return [best, hoch]


## In wie vielen Bildern der Bewegung [nm] die Waffe (Knoten „Waffe“) im Körper (KAPSELN, Kopf) oder im Schild steckt: [Bilder, alle, wo]
func _kollision(h, sk: Skeleton3D, nm: String) -> Array:
	var w := h.model.find_child("Waffe", true, false) as Node3D
	if w == null or not h.anim.has_animation(nm):
		return [0, 0, ""]
	var schild := h.model.find_child("Schild", true, false) as Node3D
	var pts: Array = []     # Ecken der Waffe im Raum ihrer Hand (BoneAttachment)
	for m in w.find_children("*", "MeshInstance3D", true, false):
		var t: Transform3D = w.transform * HeldFigur.im_raum(w, m)
		var vs: PackedVector3Array = (m as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		for i in range(0, vs.size(), 2):
			pts.append(t * vs[i])
	var sbox := AABB()
	var s_t := Transform3D.IDENTITY
	if schild != null:
		for m in schild.find_children("*", "MeshInstance3D", true, false):
			var bb: AABB = HeldFigur.im_raum(schild, m) * (m as MeshInstance3D).get_aabb()
			sbox = bb if sbox.size == Vector3.ZERO else sbox.merge(bb)
		sbox = sbox.grow(-0.01)
	var hb := sk.find_bone("hand_r")
	var lb := sk.find_bone("hand_l")
	var len: float = h.anim.get_animation(nm).length
	var treffer := 0
	var wo := {}
	h.anim.play(nm, 0.0)
	for f in 24:
		h.anim.seek(len * f / 23.0, true)
		sk.force_update_all_bone_transforms()
		var hand: Transform3D = sk.get_bone_global_pose(hb)
		var drin := false
		for q in pts:
			var p: Vector3 = hand * q
			for kp in KAPSELN:
				var a: Vector3 = sk.get_bone_global_pose(sk.find_bone(kp[0])).origin
				var b: Vector3 = sk.get_bone_global_pose(sk.find_bone(kp[1])).origin
				if p.distance_to(Geometry3D.get_closest_point_to_segment(p, a, b)) < kp[2]:
					drin = true
					wo[kp[0]] = true
					if OS.has_environment("KOLL_MESS"):
						print("    %s: Waffe bei y %.2f, %.3f m tief" % [kp[0], (w.transform.affine_inverse() * q).y, kp[2] - p.distance_to(Geometry3D.get_closest_point_to_segment(p, a, b))])
			var kopf: Transform3D = sk.get_bone_global_pose(sk.find_bone("Head"))
			if p.distance_to(kopf.origin + Vector3(0, 0.1, 0)) < KOPF_R:
				drin = true
				wo["Kopf"] = true
			if schild != null:
				var s_l: Vector3 = (sk.get_bone_global_pose(lb) * schild.transform).affine_inverse() * p
				if sbox.has_point(s_l):
					drin = true
					wo["Schild"] = true
		if drin:
			treffer += 1
			if OS.has_environment("KOLL_MESS"):
				print("  Kollision %s Bild %d (%.2f s)" % [nm, f, len * f / 23.0])
	h.anim.play("Stehen", 0.0)
	return [treffer, 24, ", ".join(wo.keys())]
