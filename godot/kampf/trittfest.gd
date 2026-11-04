# 438 (Chef 31.10., 23:31, Film 403: die Wölfe „wie als ob sie wieder gleiten würden“; Messung tests/wolf_mess_438.gd): im Gehen und
# Rennen rutschten die aufgesetzten Pfoten auch bei passendem Tempo noch, weil die Quelle die Pfote in der Stützphase ungleich schnell
# nach hinten führt (gemessen 0,78–1,01 m/s je Lauf). Solange eine Pfote aufsetzt (höchstens KONTAKT über ihrem tiefsten Stand),
# bleibt sie am Boden, wo sie aufgesetzt hat; die zwei Glieder darüber beugen sich dazu (pfotenhalt.gd _ik). Hebt sie ab, geht sie in
# LOESEN s zur Bewegung zurück. Reicht das Bein nicht mehr (WEIT mal Lauflänge), lässt es sie los.
extends SkeletonModifier3D

const PH = preload("res://kampf/pfotenhalt.gd")
const PFOTEN := ["vpfoteL", "vpfoteR", "hpfoteL", "hpfoteR"]
const KONTAKT := 0.035       # m über dem tiefsten Stand der Pfote (Welt)
const LOESEN := 0.08         # s
const WEIT := 0.35           # mal Lauflänge
const GAENGE := ["Gehen", "Rennen"]

var figur: Node3D
var fest := {}               # Prüflauf: Name -> Ort (Welt), solange gehalten

var _b: Array = []           # je Pfote [Pfote, Glied darüber, Glied darüber]
var _n: Array = []
var _lauf: Array = []
var _boden: Array = []       # tiefster Stand je Pfote über dem Ursprung der Figur (m)
var _halt: Array = []        # Ort am Boden (Welt), wenn gehalten
var _an: Array = []          # gehalten?
var _los: Array = []         # s seit dem Abheben (< 0: nicht im Lösen)
var _von: Array = []


func _process_modification_with_delta(delta: float) -> void:
	var sk := get_skeleton()
	if sk == null or figur == null:
		return
	if _b.is_empty() and not _knochen(sk):
		return
	var anim: AnimationPlayer = figur.anim
	var gang: bool = anim != null and String(anim.current_animation) in GAENGE and not figur.down
	var xs := sk.global_transform
	var y0: float = figur.global_position.y
	for i in _b.size():
		var soll: Vector3 = xs * sk.get_bone_global_pose(_b[i][0]).origin
		var h: float = soll.y - y0
		_boden[i] = minf(_boden[i], h)
		if not gang:
			_an[i] = false
			_los[i] = -1.0
			continue
		var auf: bool = h < _boden[i] + KONTAKT
		if auf and not _an[i]:
			_an[i] = true
			_halt[i] = soll
			_los[i] = -1.0
		elif _an[i] and (not auf or _flach(_halt[i] - soll) > WEIT * _lauf[i]):
			_an[i] = false
			_von[i] = _halt[i]
			_los[i] = 0.0
		var ziel := soll
		if _an[i]:
			ziel = Vector3(_halt[i].x, soll.y, _halt[i].z)
		elif _los[i] >= 0.0:
			_los[i] += delta
			var u: float = clampf(_los[i] / LOESEN, 0.0, 1.0)
			ziel = Vector3(_von[i].x, soll.y, _von[i].z).lerp(soll, smoothstep(0.0, 1.0, u))
			if u >= 1.0:
				_los[i] = -1.0
		else:
			fest.erase(_n[i])
			continue
		PH._ik(sk, xs, _b[i], ziel)
		fest[_n[i]] = xs * sk.get_bone_global_pose(_b[i][0]).origin     # wo sie nach dem Beugen wirklich ist
	if not gang:
		fest.clear()


func _flach(v: Vector3) -> float:
	return Vector2(v.x, v.z).length()


func _knochen(sk: Skeleton3D) -> bool:
	var sc: float = sk.global_basis.get_scale().x
	for nm in PFOTEN:
		var c := sk.find_bone(nm)
		var b := PH._hoch(sk, c) if c >= 0 else -1
		var a := PH._hoch(sk, b) if b >= 0 else -1
		if a < 0:
			continue
		var pc := sk.get_bone_global_pose(c).origin
		var pb := sk.get_bone_global_pose(b).origin
		var pa := sk.get_bone_global_pose(a).origin
		_b.append([c, b, a])
		_n.append(nm)
		_lauf.append(maxf((pa.distance_to(pb) + pb.distance_to(pc)) * sc, 0.05))
		_boden.append(INF)
		_halt.append(Vector3.ZERO)
		_an.append(false)
		_los.append(-1.0)
		_von.append(Vector3.ZERO)
	if _b.size() != PFOTEN.size():
		_b.clear()
		return false
	return true
