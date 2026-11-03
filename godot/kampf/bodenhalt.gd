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

const FAUST_HAUT := 0.03     # 438a Faust: Punkte der Schwertfaust so weit vor Haut und Kleidung der Beine (Faust um 3 cm dick)
const SUCHE := 0.12          # nächste Ecke höchstens so weit (wie sturz_438a)
const FAUST_SCHRITTE := 4    # Schübe je Bild (die nächste Ecke ändert sich mit dem Schub)

var figur: Node3D
var faust_tief := 0.0        # Prüflauf: wie tief die Schwertfaust vor dem Schub in Haut oder Kleidung lag (m)
var faust_weg := 0.0         # Prüflauf: wie weit die Schwerthand in diesem Bild geschoben wurde (m)
var faust_us := 0            # Prüflauf: Zeit für die Faust in diesem Bild (µs)
var faust_kurz := 0.0        # Prüflauf: so weit blieb die Schwerthand vor dem Ziel des Schubs (Arm zu kurz)
var faust_nach := 0.0        # Prüflauf: so tief liegt die Schwertfaust nach allen Schüben und dem Boden noch in Haut oder Kleidung (m)
const FAUST_ZUG := 0.015     # 438a G: Schub je Bild höchstens so viel anders (m; 45 cm/s)
var _faust_letzt := Vector3.ZERO
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
	faust_tief = 0.0
	faust_us = 0
	faust_nach = 0.0
	faust_kurz = 0.0
	for i in _arm.size():
		if not figur.griff_ort.has("L" if i == 0 else "R"):
			continue
		for bi in _finger[i]:
			if not sturz:
				_griff[i][bi] = sk.get_bone_pose_rotation(bi)
			elif _griff[i].has(bi):
				sk.set_bone_pose_rotation(bi, _griff[i][bi])
	# 438a Vergleich (Lauf 197: beim Aufstehen steckt schon der Griff 3,7 cm im Kleid am rechten Oberschenkel, Drehen um ihn hilft
	# nicht): Schwertarm abspreizen, nur in sturz_438a (figur.spreizen_grad), weich hinein und heraus
	if float(figur.spreizen_grad) > 0.0 and figur.griff_ort.has("R") and figur.anim != null \
			and String(figur.anim.current_animation).begins_with(figur.STURZ_BEWEGUNG[1]):
		var pos: float = figur.anim.current_animation_position
		var lang: float = figur.anim.current_animation_length
		var gew := clampf(pos / 0.25, 0.0, 1.0) * clampf((lang - pos) / 0.3, 0.0, 1.0)
		if gew > 0.0:
			_spreizen(sk, deg_to_rad(float(figur.spreizen_grad)) * gew)
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
		# 438a Faust (Lauf 206: beim Aufstehen steckt der Griff 7–13 cm im Kleid am rechten Oberschenkel, Kapseln sehen das Kleid nicht,
		# Drehen um den Griff hilft nicht): die Schwertfaust selbst geht aus Haut und Kleidung der Beine, je Punkt der Faust (Handgelenk,
		# Griff, Knöchel) die nächste Ecke und ihre Normale, wie sturz_438a misst; nur beim Hinfallen, Liegen und Aufstehen
		var faust_pos := PackedVector3Array()     # Prüflauf: Ecken um die Faust, für die Tiefe nach allen Schüben
		var faust_nor := PackedVector3Array()
		if i == 1 and int(figur.faust_frei) in [1, 2] and sturz:
			var fs: Array = _faust_schub(sk, xs, i, faust, hand0, weg)
			weg = fs[0]
			faust_pos = fs[1]
			faust_nor = fs[2]
		# 438a G (Lauf 207: der Schub sprang beim Hinfallen 10,4 cm in einem Bild): höchstens FAUST_ZUG je Bild anders als im letzten, auch
		# hinein und heraus
		if i == 1 and int(figur.faust_frei) == 2:
			weg = _faust_letzt.move_toward(weg, FAUST_ZUG)
		if i == 1 and int(figur.faust_frei) != 3:
			_faust_letzt = weg
		if weg != Vector3.ZERO:
			PH._ik(sk, xs, _arm[i], hand0 + weg)
			if i == 1:
				faust_weg = weg.length()
				# Lauf 207: nach den Schüben steckte der Griff noch 3 cm im Kleid: reicht der Arm nicht (IK bis 99,9 % gestreckt)?
				faust_kurz = (hand0 + weg).distance_to(xs * sk.get_bone_global_pose(_arm[i][0]).origin)
		elif i == 1:
			faust_weg = 0.0
			faust_kurz = 0.0
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
		if d > 0.0:
			var hand: Vector3 = xs * sk.get_bone_global_pose(_arm[i][0]).origin
			PH._ik(sk, xs, _arm[i], hand + Vector3.UP * d)
		# 438a H (Lauf 209: nach allen Schüben lag die Faust beim Aufstehen noch 10,3 cm im Kleid, ohne Schub in diesem Bild: der Boden hob
		# die Hand danach ins Bein): erst der Boden, dann die Faust aus dem Kleid, dabei nicht wieder hinunter, solange sie am Boden liegt;
		# Schub je Bild höchstens FAUST_ZUG anders
		if i == 1 and int(figur.faust_frei) == 3:
			var h1: Vector3 = xs * sk.get_bone_global_pose(_arm[i][0]).origin
			var f1: Vector3 = xs * (sk.get_bone_global_pose(_arm[i][0]) * figur.griff_ort["R"]) if figur.griff_ort.has("R") else h1
			var w3 := Vector3.ZERO
			if sturz:
				var fs: Array = _faust_schub(sk, xs, i, f1, h1, Vector3.ZERO)
				w3 = fs[0]
				faust_pos = fs[1]
				faust_nor = fs[2]
				if gehoben[i] > 0.0:
					w3.y = maxf(w3.y, 0.0)
			w3 = _faust_letzt.move_toward(w3, FAUST_ZUG)
			_faust_letzt = w3
			if w3 != Vector3.ZERO:
				PH._ik(sk, xs, _arm[i], h1 + w3)
				faust_kurz = (h1 + w3).distance_to(xs * sk.get_bone_global_pose(_arm[i][0]).origin)
			faust_weg = (weg + w3).length()
		if i == 1 and not faust_pos.is_empty():
			faust_nach = _faust_tiefe(sk, xs, i, faust_pos, faust_nor)


## 438a Faust: schiebt die Schwertfaust (Griff [faust], Handgelenk [hand0], Knöchel) aus Haut und Kleidung der Beine, ausgehend von [weg];
## gibt [weg, Ecken, Normalen] zurück und setzt faust_tief, faust_us
func _faust_schub(sk: Skeleton3D, xs: Transform3D, i: int, faust: Vector3, hand0: Vector3, weg: Vector3) -> Array:
	var t_us := Time.get_ticks_usec()
	var bw: Array = figur.bein_welt(sk)
	var punkte := [faust, hand0, xs * sk.get_bone_global_pose(_mitte[i]).origin]
	var box := AABB(faust, Vector3.ZERO)
	for q in punkte:
		box = box.expand(q)
	box = box.grow(SUCHE + FAUST_HAUT + 0.15)
	var pos := PackedVector3Array()
	var nor := PackedVector3Array()
	for j in (bw[0] as PackedVector3Array).size():
		if box.has_point(bw[0][j]):
			pos.append(bw[0][j])
			nor.append(bw[1][j])
	var tiefste := 0.0
	for wdh in FAUST_SCHRITTE:
		var schub := Vector3.ZERO
		var tief_max := 0.0
		for q in punkte:
			var f: Vector3 = q + weg
			var best := -1
			var bd := SUCHE
			for j in pos.size():
				var dd := f.distance_to(pos[j])
				if dd < bd:
					bd = dd
					best = j
			if best < 0:
				continue
			var tief: float = FAUST_HAUT - (f - pos[best]).dot(nor[best])
			if tief > tief_max:
				tief_max = tief
				schub = nor[best] * tief
		if wdh == 0:
			tiefste = tief_max
		if tief_max <= 0.002:
			break
		weg += schub
	faust_tief = tiefste
	faust_us = Time.get_ticks_usec() - t_us
	return [weg, pos, nor]


## 438a Prüflauf: wie tief Griff, Handgelenk und Knöchel der Faust [i] jetzt in den Ecken [pos] liegen (wie der Schub, mit FAUST_HAUT)
func _faust_tiefe(sk: Skeleton3D, xs: Transform3D, i: int, pos: PackedVector3Array, nor: PackedVector3Array) -> float:
	var hb := sk.get_bone_global_pose(_arm[i][0])
	var punkte := [xs * (hb * figur.griff_ort["R"]), xs * hb.origin, xs * sk.get_bone_global_pose(_mitte[i]).origin]
	var out := 0.0
	for f in punkte:
		var best := -1
		var bd := SUCHE
		for j in pos.size():
			var dd: float = (f as Vector3).distance_to(pos[j])
			if dd < bd:
				bd = dd
				best = j
		if best >= 0:
			out = maxf(out, FAUST_HAUT - ((f as Vector3) - pos[best]).dot(nor[best]))
	return out


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


## 438a Vergleich: dreht den rechten Oberarm um [ang], so dass die Hand vom rechten Oberschenkel weggeht (Unterarm, Hand, Waffe gehen mit)
func _spreizen(sk: Skeleton3D, ang: float) -> void:
	var e: Array = _arm[1]
	var th := sk.find_bone("thigh_r")
	var ca := sk.find_bone("calf_r")
	if th < 0 or ca < 0:
		return
	var go := sk.get_bone_global_pose(e[2])
	var hand := sk.get_bone_global_pose(e[0]).origin
	var q := Geometry3D.get_closest_point_to_segment(hand, sk.get_bone_global_pose(th).origin, sk.get_bone_global_pose(ca).origin)
	var ax := (hand - go.origin).cross(hand - q)
	if ax.length() < 1e-6:
		return
	sk.set_bone_global_pose(e[2], Transform3D(Basis(ax.normalized(), ang) * go.basis, go.origin))
