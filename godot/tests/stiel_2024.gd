extends SceneTree
# 2024 (Chef 25.11., 09:54 „2024 A“; Systemfrage): eine Waffe, die im Modell an einem eigenen Knochen hängt (Krogg „waffe“,
# krogg_gestalt.py; Grak „axt“, grak_gestalt.py), verlässt in keiner Bewegung die rechte Faust, außer im Tod.
# Gemessen am gezeichneten Netz: Abstand der Faustmitte (Mittel der Mittelglieder von Zeige-, Mittel-, Ringfinger und Daumen, wie
# krogg_gestalt.py „faust“) zum nächsten Punkt der Dreiecke der Waffe.
#  A: jede Bewegung von Krogg und Grak außer Tod, jedes Bild bei 30 Bildern/s, wie gezeichnet (nach den Schichten, skeleton_updated).
#  B: Krogg im Kampf mit erzwungenem Prankenhieb (Mars.test_gegnerzug „paw“), jedes gezeichnete Bild nach allen Schichten
#     (skeleton_updated), solange er lebt.
# Grenze GRENZE_M; Ausgabe „STIEL2024 n Bilder, k über der Grenze“.
# Nur mit den Modellen aus dem Bau (kampf/daten); ohne: übersprungen (exit 0). Nie abschalten.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/stiel_2024.gd   (exit 0 = alles erfüllt)

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const FPS := 30.0
## Faustmitte bis Stiel (m): mehr ist ein Spalt zwischen Faust und Griff
const GRENZE_M := 0.04
const FAUST := ["index_02_r", "middle_02_r", "ring_02_r", "thumb_02_r"]
## nur Dreiecke so nah am Griff (im Raum der Waffe, m) prüfen; weiter weg zählt der Abstand zum Griffpunkt
const NAH_M := 0.35

var fehler := 0
var bilder := 0
var ueber := 0
var schlimmst := {}     # Figur/Bewegung -> [Abstand, Zeit]


class Waffe:
	var knochen := -1          # Knochen, an dem das Netz hängt
	var rel := Transform3D()   # Netz im Raum dieses Knochens
	var tris := PackedVector3Array()
	var griff := Vector3.ZERO  # im Raum des Netzes
	var nah := PackedVector3Array()


func _initialize() -> void:
	_lauf.call_deferred()


func _figur(foe: String, id: String):
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = foe
	root.add_child(p)
	await process_frame
	p._start(2024)
	for i in 4:
		await process_frame
	var kf = p.fight
	for f in kf.figures.values():
		if f.fighter.monster != null and String(f.fighter.monster.id) == id:
			return [p, kf, f]
	return [p, kf, null]


## Waffennetz am eigenen Knochen (nicht Schild), mit Dreiecken im Raum des Netzes
func _waffe(fig, sk: Skeleton3D) -> Waffe:
	for at in sk.find_children("*", "BoneAttachment3D", true, false):
		var was := String(at.get_meta("was", ""))
		if was.to_lower().contains("shield"):
			continue
		for m in at.find_children("*", "MeshInstance3D", true, false):
			if m.mesh == null:
				continue
			var w := Waffe.new()
			w.knochen = sk.find_bone(at.bone_name)
			w.rel = (sk.global_transform * sk.get_bone_global_pose(w.knochen)).affine_inverse() * m.global_transform
			for s in m.mesh.get_surface_count():
				var a: Array = m.mesh.surface_get_arrays(s)
				var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
				var ix = a[Mesh.ARRAY_INDEX]
				if ix == null or (ix as PackedInt32Array).is_empty():
					w.tris.append_array(v)
				else:
					for i in ix:
						w.tris.append(v[i])
			print("STIEL2024 %s: Waffe „%s“ am Knochen %s (%s), %d Dreiecke" % [fig.fighter.id, m.name, at.bone_name, was, w.tris.size() / 3])
			return w
	return null


func _faust(sk: Skeleton3D) -> Vector3:
	var s := Vector3.ZERO
	for nm in FAUST:
		s += (sk.global_transform * sk.get_bone_global_pose(sk.find_bone(nm))).origin
	return s / FAUST.size()


## Faustmitte im Raum des Netzes
func _lokal(sk: Skeleton3D, w: Waffe) -> Vector3:
	return ((sk.global_transform * sk.get_bone_global_pose(w.knochen)) * w.rel).affine_inverse() * _faust(sk)


func _naechst(p: Vector3, tris: PackedVector3Array) -> float:
	var best := INF
	for i in range(0, tris.size(), 3):
		best = minf(best, p.distance_to(_tri_punkt(p, tris[i], tris[i + 1], tris[i + 2])))
	return best


## nächster Punkt des Dreiecks a, b, c zu p (Ericson, Real-Time Collision Detection 5.1.5)
func _tri_punkt(p: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	var ab := b - a
	var ac := c - a
	var ap := p - a
	var d1 := ab.dot(ap)
	var d2 := ac.dot(ap)
	if d1 <= 0.0 and d2 <= 0.0:
		return a
	var bp := p - b
	var d3 := ab.dot(bp)
	var d4 := ac.dot(bp)
	if d3 >= 0.0 and d4 <= d3:
		return b
	var vc := d1 * d4 - d3 * d2
	if vc <= 0.0 and d1 >= 0.0 and d3 <= 0.0:
		return a + ab * (d1 / (d1 - d3))
	var cp := p - c
	var d5 := ab.dot(cp)
	var d6 := ac.dot(cp)
	if d6 >= 0.0 and d5 <= d6:
		return c
	var vb := d5 * d2 - d1 * d6
	if vb <= 0.0 and d2 >= 0.0 and d6 <= 0.0:
		return a + ac * (d2 / (d2 - d6))
	var va := d3 * d6 - d5 * d4
	if va <= 0.0 and (d4 - d3) >= 0.0 and (d5 - d6) >= 0.0:
		return b + (c - b) * ((d4 - d3) / ((d4 - d3) + (d5 - d6)))
	var dn := 1.0 / (va + vb + vc)
	return a + ab * (vb * dn) + ac * (vc * dn)


## Griff: Punkt der Waffe nächst der Faust in Stehen, Bild 0; Dreiecke nahe dem Griff
func _griff(sk: Skeleton3D, w: Waffe) -> void:
	var p := _lokal(sk, w)
	var best := INF
	for i in range(0, w.tris.size(), 3):
		var q := _tri_punkt(p, w.tris[i], w.tris[i + 1], w.tris[i + 2])
		if p.distance_to(q) < best:
			best = p.distance_to(q)
			w.griff = q
	for i in range(0, w.tris.size(), 3):
		if w.griff.distance_to((w.tris[i] + w.tris[i + 1] + w.tris[i + 2]) / 3.0) < NAH_M:
			w.nah.append(w.tris[i])
			w.nah.append(w.tris[i + 1])
			w.nah.append(w.tris[i + 2])


## Abstand der Faust zur Waffe in der Welt (m); das Netz trägt die Skala der Figur
func _abstand(sk: Skeleton3D, w: Waffe) -> float:
	var p := _lokal(sk, w)
	var m: float = ((sk.global_transform * sk.get_bone_global_pose(w.knochen)) * w.rel).basis.get_scale().x
	var d := p.distance_to(w.griff) if p.distance_to(w.griff) > NAH_M else _naechst(p, w.nah)
	return d * m


func _zaehle(wer: String, wo: String, d: float, t: float) -> void:
	bilder += 1
	var k := "%s %s" % [wer, wo]
	if not schlimmst.has(k) or d > float(schlimmst[k][0]):
		schlimmst[k] = [d, t]
	if d > GRENZE_M:
		ueber += 1


## A: jede Bewegung außer Tod, jedes Bild
func _bewegungen(foe: String, id: String) -> bool:
	var r: Array = await _figur(foe, id)
	var fig = r[2]
	if fig == null or fig.anim == null:
		print("übersprungen: %s ohne Modell (kampf/daten)" % foe)
		r[0].queue_free()
		return false
	var sk: Skeleton3D = fig._find(fig.model, "Skeleton3D")
	fig.set_process(false)
	var ap: AnimationPlayer = fig.anim
	ap.play("Stehen", 0.0)
	ap.seek(0.0, true)
	var w := _waffe(fig, sk)
	if w == null or sk.find_bone(FAUST[0]) < 0:
		fehler += 1
		print("FEHLER %s: keine Waffe am Knochen oder keine Finger" % foe)
		r[0].queue_free()
		return false
	_griff(sk, w)
	var mess := [NAN]
	var merke := func(): mess[0] = _abstand(sk, w)
	sk.skeleton_updated.connect(merke)
	ap.speed_scale = 0.0
	for nm in ap.get_animation_list():
		if String(nm).begins_with("Tod") or String(nm) == "RESET":
			continue
		var a := ap.get_animation(nm)
		var n := int(a.length * FPS)
		ap.play(nm, 0.0)
		for f in n + 1:
			ap.seek(minf(f / FPS, a.length), true)
			mess[0] = NAN
			await process_frame
			var d: float = mess[0] if not is_nan(mess[0]) else _abstand(sk, w)
			_zaehle(fig.fighter.id, nm, d, f / FPS)
			if OS.get_environment("SCHAU_2024") == String(nm):
				print("2024 %s %s %.2f s: %.3f m" % [fig.fighter.id, nm, f / FPS, d])
	sk.skeleton_updated.disconnect(merke)
	r[0].queue_free()
	await process_frame
	return true


## B: Krogg im Kampf, nur Prankenhieb, jedes gezeichnete Bild
var _b_sk: Skeleton3D = null
var _b_w: Waffe = null
var _b_fig = null
var _b_t := 0.0
var _b_hieb := 0

func _gezeichnet() -> void:
	if _b_fig == null or _b_fig.down:
		return
	var cur := String(_b_fig.anim.current_animation)
	_zaehle(_b_fig.fighter.id, "Kampf/%s" % cur, _abstand(_b_sk, _b_w), _b_t)


func _kampf() -> void:
	seed(2024)
	var r: Array = await _figur("KROGG", "bugbear")
	var fig = r[2]
	if fig == null or fig.anim == null:
		r[0].queue_free()
		return
	var kf = r[1]
	kf.mars.find("merc").auto = true
	_b_sk = fig._find(fig.model, "Skeleton3D")
	fig.anim.play("Stehen", 0.0)
	fig.anim.seek(0.0, true)
	_b_w = _waffe(fig, _b_sk)
	_griff(_b_sk, _b_w)
	_b_fig = fig
	_b_sk.skeleton_updated.connect(_gezeichnet)
	var war := false
	Mars.test_gegnerzug = "paw"
	var n := 0
	while n < int(FPS) * 120 and _b_hieb < 3:
		await process_frame
		n += 1
		_b_t = n / FPS
		if Mars.test_gegnerzug == "":
			Mars.test_gegnerzug = "paw"
		var hieb: bool = fig.gang == "hieb"
		if hieb and not war:
			_b_hieb += 1
		war = hieb
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				kf.order(["wait"])
	Mars.test_gegnerzug = ""
	_b_fig = null
	print("STIEL2024 Kampf: %d Prankenhiebe gesehen" % _b_hieb)
	if _b_hieb == 0:
		fehler += 1
		print("FEHLER kein Prankenhieb im Kampf")
	r[0].queue_free()


func _lauf() -> void:
	var a := await _bewegungen("KROGG", "bugbear")
	var b := await _bewegungen("GRAK", "hobgoblin_captain")
	if a:
		await _kampf()
	if not a and not b:
		quit(0)
		return
	var keys := schlimmst.keys()
	keys.sort()
	for k in keys:
		var d: float = schlimmst[k][0]
		print("%s %s: höchstens %.3f m (bei %.2f s)" % ["FEHLER" if d > GRENZE_M else "gut", k, d, schlimmst[k][1]])
	fehler += 1 if ueber > 0 else 0
	print("STIEL2024 %d Bilder, %d über der Grenze %.2f m, %s" % [bilder, ueber, GRENZE_M, "gut" if fehler == 0 else "%d FEHLER" % fehler])
	quit(1 if fehler > 0 else 0)
