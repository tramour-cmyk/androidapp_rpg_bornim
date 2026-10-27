# 348.12f r4 (Chef 27.10., 21:26, Archiv: offene Befunde der Ratte beheben; Prüfer Ratte r2 und Kaufwolf r1: beim Umdrehen auf der
# Stelle drehen die Pfoten 15–25 cm mit, ohne Schritt; die Quellen haben keine Drehbewegung): solange das Tier sich auf der Stelle
# dreht (drehen), bleibt jede Pfote am Boden, wo sie steht, und tritt nach, sobald der Rumpf sie AB weit verdreht hat: diagonal je zwei
# zugleich (vorn links mit hinten rechts), in SCHRITT s im Bogen HUB hoch, mit Vorhalt auf die Drehung. Je Lauf werden die zwei
# Glieder über der Pfote gebeugt (Kosinussatz, das Knie bleibt auf seiner Seite); die Pfote behält ihre Haltung aus der Bewegung.
# Nach der Drehung treten verdrehte Pfoten noch einmal nach (los(true)), oder sie gleiten in LOS s zur Bewegung zurück (los(false),
# wenn das Tier danach losläuft).
extends SkeletonModifier3D

const PFOTEN := ["vpfoteL", "vpfoteR", "hpfoteL", "hpfoteR"]
const PAARE := [[0, 3], [1, 2]]
const SCHRITT := 0.09        # s je Tritt
const AB := 0.22             # tritt nach ab so viel Abstand (mal Lauflänge) zur Stelle, an der die Bewegung die Pfote hätte
const HUB := 0.22            # Höhe des Tritts (mal Lauflänge)
const RUHIG := 0.04          # nach der Drehung: so nah (mal Lauflänge) gilt die Pfote als daheim
const LOS := 0.1             # s, in denen gehaltene Pfoten zur Bewegung zurückgleiten

var figur: Node3D            # die Figur (Mitte und Drehung für den Vorhalt)
var drehen := false
var wirkt := false           # Pfoten werden gerade gehalten
var ort := {}                # Pfotenschatten und Prüflauf: Ort je Pfote (Welt), solange wirkt
var tritte := 0              # Prüflauf: Tritte seit dem Start

var _b: Array = []           # je Pfote [Pfote, Glied darüber, Glied darüber], Knochennummern
var _n: Array = []           # Name je Pfote
var _lauf: Array = []        # Lauflänge (Welt, m)
var _halt: Array = []        # Ort am Boden (Welt)
var _von: Array = []
var _nach: Array = []
var _t: Array = []           # Zeit im Tritt (s), < 0: steht
var _gier := 0.0
var _w := 0.0                # Drehung der Figur (rad/s), geglättet
var _aus := -1.0             # Zeit seit los(false), < 0: nicht


func an() -> void:
	drehen = true
	_aus = -1.0


func los(nachtreten: bool) -> void:
	drehen = false
	if wirkt and not nachtreten and _aus < 0.0:
		_aus = 0.0


func _process_modification_with_delta(delta: float) -> void:
	var sk := get_skeleton()
	if sk == null or figur == null:
		return
	if _b.is_empty() and not _knochen(sk):
		return
	delta = maxf(delta, 1e-4)
	var g := wrapf(figur.global_rotation.y - _gier, -PI, PI)
	_gier = figur.global_rotation.y
	_w = lerpf(_w, g / delta, 0.5)
	var xs := sk.global_transform
	var soll: Array = []     # wo die Bewegung die Pfote hat (Welt)
	for e in _b:
		soll.append(xs * sk.get_bone_global_pose(e[0]).origin)
	if not wirkt:
		if not drehen:
			return
		wirkt = true
		for i in _b.size():
			_halt[i] = soll[i]
			_t[i] = -1.0
	var weich := 0.0
	if _aus >= 0.0:
		_aus += delta
		weich = _aus / LOS
		if weich >= 1.0:
			_ende()
			return
	for i in _b.size():
		if _t[i] >= 0.0:
			_t[i] += delta
			if _t[i] >= SCHRITT:
				_t[i] = -1.0
				_halt[i] = _nach[i]
	if _aus < 0.0 and not _tritt(PAARE[0]) and not _tritt(PAARE[1]):
		var best := -1
		var weit := 0.0
		for p in PAARE.size():
			for i in PAARE[p]:
				var d: float = _flach(_halt[i] - soll[i]) / _lauf[i]
				if d > weit:
					weit = d
					best = p
		if best >= 0 and weit > (AB if drehen else RUHIG):
			for i in PAARE[best]:
				if _flach(_halt[i] - soll[i]) / _lauf[i] > RUHIG * 0.5:
					_von[i] = _halt[i]
					_nach[i] = _vorhalt(soll[i], 2.0 * SCHRITT if drehen else 0.0)
					_t[i] = 0.0
					tritte += 1
		elif not drehen:
			_ende()
			return
	for i in _b.size():
		var p: Vector3 = _halt[i]
		if _t[i] >= 0.0:
			var u: float = _t[i] / SCHRITT
			p = (_von[i] as Vector3).lerp(_nach[i], smoothstep(0.0, 1.0, u)) + Vector3.UP * HUB * _lauf[i] * sin(PI * u)
		if weich > 0.0:
			p = p.lerp(soll[i], smoothstep(0.0, 1.0, weich))
		ort[_n[i]] = p
		_ik(sk, xs, _b[i], p)


func _ende() -> void:
	wirkt = false
	_aus = -1.0
	ort.clear()


func _tritt(paar: Array) -> bool:
	for i in paar:
		if _t[i] >= 0.0:
			return true
	return false


func _flach(v: Vector3) -> float:
	return Vector2(v.x, v.z).length()


## Wo die Pfote nach [dt] s Drehung im jetzigen Tempo steht (um die Mitte der Figur)
func _vorhalt(s: Vector3, dt: float) -> Vector3:
	var o := figur.global_position
	var r := Vector3(s.x - o.x, 0.0, s.z - o.z).rotated(Vector3.UP, _w * dt)
	return Vector3(o.x + r.x, s.y, o.z + r.z)


## Je Pfote die zwei Glieder darüber; Glieder ohne Länge (Drehknochen am selben Ort) zählen nicht
func _knochen(sk: Skeleton3D) -> bool:
	var sc: float = sk.global_basis.get_scale().x
	for nm in PFOTEN:
		var c := sk.find_bone(nm)
		var b := _hoch(sk, c) if c >= 0 else -1
		var a := _hoch(sk, b) if b >= 0 else -1
		if a < 0:
			continue
		var pc := sk.get_bone_global_pose(c).origin
		var pb := sk.get_bone_global_pose(b).origin
		var pa := sk.get_bone_global_pose(a).origin
		_b.append([c, b, a])
		_n.append(nm)
		_lauf.append(maxf((pa.distance_to(pb) + pb.distance_to(pc)) * sc, 0.05))
		_halt.append(Vector3.ZERO)
		_von.append(Vector3.ZERO)
		_nach.append(Vector3.ZERO)
		_t.append(-1.0)
	if _b.size() != PFOTEN.size():     # nur mit allen vier Läufen (die Paare)
		_b.clear()
		return false
	return true


func _hoch(sk: Skeleton3D, i: int) -> int:
	var o := sk.get_bone_global_pose(i).origin
	var p := sk.get_bone_parent(i)
	while p >= 0 and sk.get_bone_global_pose(p).origin.distance_to(o) < 0.005:
		p = sk.get_bone_parent(p)
	return p


## Beugt die zwei Glieder [e][2] (oben) und [e][1] so, dass die Pfote [e][0] auf [ziel] (Welt) steht, so weit die Glieder reichen
func _ik(sk: Skeleton3D, xs: Transform3D, e: Array, ziel: Vector3) -> void:
	var t: Vector3 = xs.affine_inverse() * ziel
	var ga := sk.get_bone_global_pose(e[2])
	var gb := sk.get_bone_global_pose(e[1])
	var gc := sk.get_bone_global_pose(e[0])
	var a := ga.origin
	var b := gb.origin
	var c := gc.origin
	var la := a.distance_to(b)
	var lb := b.distance_to(c)
	var at := t - a
	if at.length() < 1e-5 or la < 1e-5 or lb < 1e-5:
		return
	var d := clampf(at.length(), absf(la - lb) + 1e-4, (la + lb) * 0.999)
	var u := at.normalized()
	var v := (b - a) - u * (b - a).dot(u)     # Knie auf seiner Seite
	if v.length() < 1e-6:
		v = (c - b) - u * (c - b).dot(u)
		if v.length() < 1e-6:
			return
	v = v.normalized()
	var x := (la * la - lb * lb + d * d) / (2.0 * d)
	var y := sqrt(maxf(la * la - x * x, 0.0))
	var b2 := a + u * x + v * y
	var t2 := a + u * d
	var qa := Quaternion((b - a).normalized(), (b2 - a).normalized())
	var c1 := a + qa * (c - a)
	var qb := Quaternion((c1 - b2).normalized(), (t2 - b2).normalized())
	var ba := Basis(qa)
	sk.set_bone_global_pose(e[2], Transform3D(ba * ga.basis, a))
	sk.set_bone_global_pose(e[1], Transform3D(Basis(qb) * ba * gb.basis, b2))
	sk.set_bone_global_pose(e[0], Transform3D(gc.basis, t2))
