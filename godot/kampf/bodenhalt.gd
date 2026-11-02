# 438a (Chef 01.11., 20:1x, Archiv 438a: Hinfallen und Aufstehen aus dem Paket; Messung 02.11. sturz_438a): der Satz „Sword & Shield“
# ist für seinen Darsteller gebaut; am Kaufhelden (andere Arme, andere Beckenhöhe) stützt die Schwerthand beim Aufstehen bis 9 cm unter
# dem Boden auf, die Finger bis 15 cm, und mit ihr steckt das Schwert im Boden. Liegt ein Finger oder das Handgelenk tiefer als
# FREI über dem Boden, hebt sich die Hand so weit; Ober- und Unterarm beugen sich dazu (pfotenhalt.gd _ik), die Hand behält ihre
# Richtung. Im Stehen und Kämpfen liegt keine Hand am Boden, dann ändert sich nichts.
# Ebenso die Schwertfaust in einem Bein (Messung: beim Hinfallen und Aufstützen lag die Schwertfaust mit Knauf und Parierstange bis 6 cm im
# rechten Oberschenkel): sie geht aus der Beinkapsel (figur.gd MENSCH_KAPSELN), vor dem Boden. Und ginge der Schild in der
# Lage aus dem Griff in den Boden, hebt sich die Schildhand bis WAFFE_HEBEN, wie ein Arm, der auf dem Schild aufliegt.
extends SkeletonModifier3D

const PH = preload("res://kampf/pfotenhalt.gd")
const FREI := 0.012          # m über dem Boden (Fingerdicke)
const FINGER := ["thumb", "index", "middle", "ring", "pinky"]
const FAUST := 0.06          # m, Halbmesser um den Griff (Faust, Parierstange)
const BEINE := [4, 5, 6, 7]  # MENSCH_KAPSELN: Ober- und Unterschenkel
const WAFFE_HEBEN := 0.12    # m: so weit hebt sich die Schildhand, wenn der Schild sonst in den Boden ginge; den Rest dreht figur.gd
# _boden_schutz die Waffe um den Griff (sturz_438a: nur gedreht schlug der Schild beim Aufprall in zwei Bildern 60° hin und her)

var figur: Node3D
var gehoben := {}            # Prüflauf: Seite -> m, um die die Hand im letzten Bild gehoben wurde

var _arm: Array = []         # je Seite [Hand, Unterarm, Oberarm]
var _spitzen: Array = []     # je Seite die Fingerglieder [vorletztes, letztes]
var _mitte: Array = []       # je Seite der Mittelfingerknöchel
var _finger: Array = []      # je Seite alle Fingerglieder (Knochen)
var _griff: Array = [{}, {}] # je Seite Knochen -> Drehung im Kampf (die Faust um Griff oder Schildgriff), zuletzt außerhalb des Sturzes


func _process_modification_with_delta(_delta: float) -> void:
	var sk := get_skeleton()
	if sk == null or figur == null:
		return
	if _arm.is_empty() and not _knochen(sk):
		return
	# 438a Runde 3 (Prüfer Runde 2: liegend hält die Hand das Schwert nicht, offen; Kleriker legt die Hand flach auf den Stab;
	# sturz_438a: Fingerspitzen beim Aufstehen bis 24 cm vom Griff, im Kampf 4 bis 8 cm): wer etwas hält, behält beim Hinfallen,
	# Liegen und Aufstehen die Faust aus dem Kampf; der Satz öffnet sie, weil seine eigene Waffe anders sitzt
	var sturz: bool = figur.sturz_jetzt()
	for i in _arm.size():
		if not figur.griff_ort.has("L" if i == 0 else "R"):
			continue
		for bi in _finger[i]:
			if not sturz:
				_griff[i][bi] = sk.get_bone_pose_rotation(bi)
			elif _griff[i].has(bi):
				sk.set_bone_pose_rotation(bi, _griff[i][bi])
	var xs := sk.global_transform
	var y0: float = figur.global_position.y + FREI
	var beine := []
	for j in BEINE:
		var c: Array = figur.MENSCH_KAPSELN[j]
		var a := sk.find_bone(c[0])
		var b := sk.find_bone(c[1])
		if a >= 0 and b >= 0:
			# 438a Runde 4: die Beinkapsel so dick wie Haut und Rüstung dieses Körpers (figur.gd _haut_radien; Lauf 164: Rüstung bis
			# 9,5 cm über der festen Kapsel)
			var r: float = maxf(float(c[2]), float(figur._haut_r.get(j, 0.0)))
			beine.append([xs * sk.get_bone_global_pose(a).origin, xs * sk.get_bone_global_pose(b).origin, r + FAUST])
	for i in _arm.size():
		var hand0: Vector3 = xs * sk.get_bone_global_pose(_arm[i][0]).origin
		var seite := "L" if i == 0 else "R"
		var faust: Vector3 = xs * (sk.get_bone_global_pose(_arm[i][0]) * figur.griff_ort[seite]) if figur.griff_ort.has(seite) \
			else hand0.lerp(xs * sk.get_bone_global_pose(_mitte[i]).origin, 0.6)
		var weg := Vector3.ZERO
		for k in (beine if i == 1 else []):     # nur die Schwertfaust; der Schild hält sich in figur.gd _boden_schutz frei
			var q: Vector3 = Geometry3D.get_closest_point_to_segment(faust + weg, k[0], k[1])
			var d: float = float(k[2]) - (faust + weg).distance_to(q)
			if d > 0.0 and (faust + weg).distance_to(q) > 0.001:
				weg += ((faust + weg) - q).normalized() * d
		if weg != Vector3.ZERO:
			PH._ik(sk, xs, _arm[i], hand0 + weg)
		var tief: float = (xs * sk.get_bone_global_pose(_arm[i][0]).origin).y
		for f in _spitzen[i]:
			var a: Vector3 = xs * sk.get_bone_global_pose(f[0]).origin
			var b: Vector3 = xs * sk.get_bone_global_pose(f[1]).origin
			tief = minf(tief, minf(b.y, (b + (b - a)).y))     # Fingerkuppe: letztes Glied noch einmal so lang
		var d := y0 - tief
		for t in figur._boden_teile:
			# nur der Schild (die gehobene Schwertfaust ging ins Bein) und nur beim Hinfallen und Aufstehen (schild_406: in der Abwehr
			# hob sich der Arm des Klerikers, der lange Schild ging in den Körper)
			if i == 0 and t[5] == "L" and t[4] == _arm[i][0] and figur.sturz_jetzt():
				var gw: Transform3D = xs * sk.get_bone_global_pose(_arm[i][0]) * (t[1] as Transform3D)
				var w_tief := INF
				for c in t[2]:
					w_tief = minf(w_tief, (gw * c).y)
				d = maxf(d, minf(figur.global_position.y + figur.BODEN_FREI - w_tief, WAFFE_HEBEN))
		gehoben[i] = maxf(d, 0.0)
		if d <= 0.0:
			continue
		var hand: Vector3 = xs * sk.get_bone_global_pose(_arm[i][0]).origin
		PH._ik(sk, xs, _arm[i], hand + Vector3.UP * d)


func _knochen(sk: Skeleton3D) -> bool:
	for s in ["l", "r"]:
		var e := [sk.find_bone("hand_" + s), sk.find_bone("lowerarm_" + s), sk.find_bone("upperarm_" + s)]
		if -1 in e:
			_arm.clear()
			return false
		_arm.append(e)
		_mitte.append(maxi(sk.find_bone("middle_01_" + s), e[0]))
		var alle := []
		for f in FINGER:
			for n in ["01", "02", "03"]:
				var fb := sk.find_bone("%s_%s_%s" % [f, n, s])
				if fb >= 0:
					alle.append(fb)
		_finger.append(alle)
		var sp := []
		for f in FINGER:
			var a := sk.find_bone("%s_02_%s" % [f, s])
			var b := sk.find_bone("%s_03_%s" % [f, s])
			if a >= 0 and b >= 0:
				sp.append([a, b])
		_spitzen.append(sp)
	return true
