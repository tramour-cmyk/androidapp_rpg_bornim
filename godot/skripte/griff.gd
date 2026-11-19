class_name Griff
extends RefCounted
# 1694 (Chef 18.11., 17:01 „Als Systemlösung, genau“; Auftrag 19.11.: „Jede Figur des Spiels hält jeden Gegenstand sichtbar richtig“):
# der eine Griff für alle Figuren mit Fingerknochen (Held, Leute, Kaufmonster mit Menschengerüst). Wie Spiele es üblich lösen:
#  1. Haltepunkt am Gegenstand: Griff, Schaftachse, Radius (Halt, regeln/halt.json; Radius aus dem Netz), zweiter Griff bei Zweihändern
#  2. Halterung an der Hand: Stelle in der Faust aus dem Netz der Figur (Haut der Handfläche, Dicke der Grundglieder), je Körper einmal
#  3. Handhaltung je Griffart: die Finger schließen sich von der Ruhe aus Glied für Glied, bis sie anliegen (wie VR-Hände, die sich um
#     den Griff legen statt einer festen Pose je Waffe); Ergebnis je Lage des Schafts in der Hand zwischengespeichert (kein Rechnen je Bild)
# Einzelbild 19.11., 08:26 (Stiel quer über den Fingern bei Messung „passt“): der Schaft lag unter dem Grundgelenk, wo in der Faust die
# Grundglieder hinunterlaufen (Finger 1,4 cm im Stiel). Richtig: an der Handfläche UND an der Beugeseite der Grundglieder, davor zur
# Handwurzel hin. Alle Zahlen im Skelettraum; Längen der Hand in HAND_LANG (Handgelenk bis Mittelfingergrundgelenk) gerechnet.

const HAND_LANG := 0.09            # m: Handgelenk bis Mittelfingergrundgelenk am Kaufkörper; die Längen unten gelten dafür
const FINGER := ["index", "middle", "ring", "pinky"]
const SCHRITT := 4.0               # Grad je Schritt
const HOECHST := 28                # Schritte je Glied (112°)
const HAUT := 0.009                # m: Endgliedspitze (Knochen) so weit über der Oberfläche: die Fingerkuppe liegt an
const HAUT_MIN := 0.004            # m: näher: Glied im Schaft, öffnen
const DAUMEN_HAUT := 0.014         # m: Daumen (dicker als die Finger)
const FAUST_TIEFE := 0.011         # m: Grundgelenk bis Haut der Handinnenseite, wenn das Netz nichts liefert
const GRUND_DICKE := 0.009         # m: Grundglied, Knochen bis Beugeseite, wenn das Netz nichts liefert
const EINDRUCK := 0.002            # m: der Schaft drückt so weit in Haut und Finger (anliegend, kein Spalt)
const HALT_WEIT := 0.07            # m: weiter weg hält die Hand den Schaft nicht (getragen, auf dem Rücken)
const NEU_AB := 0.002              # m bzw. rad*m: so weit darf der Schaft in der Hand wandern, bevor die Finger neu schließen

## hat die Seite [s] („r“, „l“) eine Hand mit Fingern (Menschengerüst: hand_r, index_01_r …)?
static func hat_hand(sk: Skeleton3D, s: String) -> bool:
	for b in ["hand_", "middle_01_", "index_01_", "pinky_01_", "thumb_01_"]:
		if sk.find_bone(b + s) < 0: return false
	return true

## Maßstab: Skeletteinheiten je Meter Kaufhand (aus der Ruhelage der Hand)
static func einheit(sk: Skeleton3D, s: String) -> float:
	var l := sk.get_bone_global_rest(sk.find_bone("middle_01_" + s)).origin.distance_to(sk.get_bone_global_rest(sk.find_bone("hand_" + s)).origin)
	return l / HAND_LANG if l > 1e-5 else 1.0

## [Grundgelenk Mittelfinger, Fingerrichtung (Handgelenk → Knöchel), Handinnenseite] in der aktuellen Pose (rest: Ruhelage)
static func flaeche(sk: Skeleton3D, s: String, rest := false) -> Array:
	var P := func(n: String) -> Vector3:
		var i := sk.find_bone(n + s)
		return sk.get_bone_global_rest(i).origin if rest else sk.get_bone_global_pose(i).origin
	var mp: Vector3 = P.call("middle_01_"); var hp: Vector3 = P.call("hand_")
	var lang := (mp - hp).normalized()
	var fl := lang.cross((P.call("index_01_") - P.call("pinky_01_")).normalized()).normalized()
	if fl.dot(P.call("thumb_01_") - hp) < 0.0: fl = -fl
	return [mp, lang, fl]

## Haut der Handfläche (unter der Stelle des Schafts) und Dicke des Grundglieds zur Beugeseite, aus dem gezeichneten Netz in Ruhelage
## (Ecken mit Hauptgewicht an Hand bzw. Grundglied des Mittelfingers); je Skelett, Seite und Radius einmal (Meta am Skelett)
static func hand_mass(sk: Skeleton3D, s: String, r: float) -> Vector2:
	var key := "griff_%s_%d" % [s, int(round(r * 10000.0))]
	if sk.has_meta(key): return sk.get_meta(key)
	var u := einheit(sk, s)
	var haut := FAUST_TIEFE * u; var grund := GRUND_DICKE * u
	var ih := sk.find_bone("hand_" + s); var mf := sk.find_bone("middle_01_" + s)
	var f := flaeche(sk, s, true)
	var mp: Vector3 = f[0]; var lang: Vector3 = f[1]; var fl: Vector3 = f[2]
	var kinder := sk.get_bone_children(mf)
	var mlang := (sk.get_bone_global_rest(kinder[0]).origin - mp) if kinder.size() > 0 else lang * 0.04 * u
	var mlen := mlang.length(); mlang = mlang.normalized()
	var ecken := []   # [Ecke in Ruhelage, an der Hand]
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var m3 := mi as MeshInstance3D
		if m3.mesh == null or m3.skin == null or not m3.visible: continue
		var bh := -1; var bm := -1
		for k in m3.skin.get_bind_count():
			var nm := m3.skin.get_bind_name(k)
			var b := sk.find_bone(nm) if nm != "" else m3.skin.get_bind_bone(k)
			if b == ih: bh = k
			if b == mf: bm = k
		if bh < 0 and bm < 0: continue
		for su in m3.mesh.get_surface_count():
			var a := m3.mesh.surface_get_arrays(su)
			var pos = a[Mesh.ARRAY_VERTEX]; var kn = a[Mesh.ARRAY_BONES]; var gw = a[Mesh.ARRAY_WEIGHTS]
			if pos == null or kn == null or gw == null or pos.size() == 0: continue
			var je: int = kn.size() / pos.size()
			for vi in pos.size():
				var best := -1; var bw := 0.0
				for k in je:
					if gw[vi * je + k] > bw: bw = gw[vi * je + k]; best = int(kn[vi * je + k])
				if best != bh and best != bm: continue
				var knochen := ih if best == bh else mf
				ecken.append([sk.get_bone_global_rest(knochen) * (m3.skin.get_bind_pose(best) * pos[vi]), best == bh])
	var dick := -INF
	for e in ecken:
		if e[1]: continue
		var rel: Vector3 = e[0] - mp
		var t := rel.dot(mlang)
		if t > 0.2 * mlen and t < 0.8 * mlen: dick = maxf(dick, rel.dot(fl))
	if dick > 0.0: grund = dick
	var basis := mp - lang * (r + grund)
	var tief := -INF
	for e in ecken:
		if not e[1]: continue
		var rel: Vector3 = e[0] - basis
		var t := rel.dot(fl)
		if t > 0.0 and (rel - fl * t).length() < 0.012 * u: tief = maxf(tief, t)
	if tief > 0.0: haut = tief
	var w := Vector2(haut, grund)
	sk.set_meta(key, w)
	return w

## Verschiebung (quer zum Schaft, Skelettraum), die die Schaftachse durch [o] mit Richtung [d] an die Stelle in der Faust bringt;
## ZERO, wenn die Hand den Schaft nicht hält (weiter als HALT_WEIT)
static func schub(sk: Skeleton3D, s: String, o: Vector3, d: Vector3, r: float) -> Vector3:
	var f := flaeche(sk, s)
	var mp: Vector3 = f[0]; var lang: Vector3 = f[1]; var fl: Vector3 = f[2]
	var u := einheit(sk, s)
	var nah := o + d * (mp - o).dot(d)
	if mp.distance_to(nah) > HALT_WEIT * u: return Vector3.ZERO
	var hm := hand_mass(sk, s, r)
	var ein := EINDRUCK * u
	var fq := (fl - d * fl.dot(d)).normalized()
	var ziel := mp + fq * (r + hm.x - ein) - lang * (r + hm.y - ein)
	var w := ziel - nah
	return w - d * w.dot(d)

## Stelle in der Faust im Raum des Handknochens (Leute: der Gegenstand folgt der Hand ohne Drehung um den Griff)
static func stelle_lokal(sk: Skeleton3D, s: String, r: float) -> Vector3:
	var f := flaeche(sk, s, true)
	var hm := hand_mass(sk, s, r)
	var ein := EINDRUCK * einheit(sk, s)
	var ziel: Vector3 = f[0] + f[2] * (r + hm.x - ein) - f[1] * (r + hm.y - ein)
	return sk.get_bone_global_rest(sk.find_bone("hand_" + s)).affine_inverse() * ziel

## Radius des Schafts am Griff (m, Raum des Modells): Median der Abstände zur Achse der Ecken von 10 cm unter bis 2 cm über dem Griff,
## nur unter 3 cm; ohne Ecken 1,5 cm
static func radius(ding: Node3D, halt: Dictionary) -> float:
	var m := halt if not halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
	var g := Halt.griff_rahmen(m)
	var rs := []
	for mi in ding.find_children("*", "MeshInstance3D", true, false) + ([ding] if ding is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		if me == null: continue
		var tr := g.affine_inverse() * HeldFigur.im_raum(ding, mi)
		for su in me.get_surface_count():
			for q in me.surface_get_arrays(su)[Mesh.ARRAY_VERTEX]:
				var v: Vector3 = tr * q
				if v.y < -0.10 or v.y > 0.02: continue
				var rq := Vector2(v.x, v.z).length()
				if rq > 0.003 and rq < 0.03: rs.append(rq)
	if rs.is_empty(): return 0.015
	rs.sort()
	return rs[rs.size() / 2]

## Finger und Daumen um den Schaft (Achse [o] + t·[d], Radius [r]) schließen, von der Ruhe aus. [merk]: Zwischenspeicher des Aufrufers
## (Dictionary); solange der Schaft in der Hand an derselben Stelle liegt, werden nur die gemerkten Drehungen gesetzt
static func schliessen(sk: Skeleton3D, s: String, o: Vector3, d: Vector3, r: float, merk: Dictionary) -> void:
	var ih := sk.find_bone("hand_" + s)
	var H := sk.get_bone_global_pose(ih).affine_inverse()
	var ol := H * o; var dl := (H.basis * d).normalized()
	var u := einheit(sk, s)
	if merk.has("o") and (merk["o"] as Vector3).distance_to(ol) < NEU_AB * u and (merk["d"] as Vector3).dot(dl) > 0.9995 and is_equal_approx(float(merk["r"]), r):
		for k in merk["dreh"]: sk.set_bone_pose_rotation(k, merk["dreh"][k])
		return
	var quer := func(p: Vector3) -> float:
		var v := p - o
		return (v - d * v.dot(d)).length()
	var dreh := {}
	var f := flaeche(sk, s)
	var fl: Vector3 = f[2]
	var gehalten := float(quer.call(f[0])) <= HALT_WEIT * u
	for fi in FINGER:
		var kette: Array[int] = []
		for g in ["_01_", "_02_", "_03_"]:
			var i := sk.find_bone(fi + g + s)
			if i >= 0: kette.append(i)
		if kette.size() < 2: continue
		for i in kette: sk.set_bone_pose_rotation(i, sk.get_bone_rest(i).basis.get_rotation_quaternion())
		# Beugerichtung: die, in der die Spitze zur Handinnenseite geht (fest aus der Hand, kein Springen von Bild zu Bild, 610)
		var vor := _spitze(sk, kette[-1])
		_beuge(sk, kette[0], d, 10.0)
		var plus := _spitze(sk, kette[-1])
		_beuge(sk, kette[0], d, -10.0)
		var vz := 1.0 if (plus - vor).dot(fl) > 0.0 else -1.0
		if not gehalten:   # nichts in der Hand: lockere Faust
			for i in kette: _beuge(sk, i, d, vz * 120.0 / kette.size())
		else:
			var ab := func(von: int) -> float:
				var pts: Array[Vector3] = []
				for k in range(von, kette.size()): pts.append(sk.get_bone_global_pose(kette[k]).origin)
				pts.append(_spitze(sk, kette[-1]))
				var m := INF
				for k in range(1, pts.size()):
					m = minf(m, minf(float(quer.call(pts[k])), float(quer.call((pts[k] + pts[k - 1]) * 0.5))))
				return m - r
			for j in kette.size():
				for st in HOECHST:
					if float(ab.call(j)) <= HAUT * u: break
					_beuge(sk, kette[j], d, vz * SCHRITT)
				var n := 0
				while float(ab.call(j)) < HAUT_MIN * u and n < HOECHST:   # im Schaft: zurück
					_beuge(sk, kette[j], d, -vz * SCHRITT); n += 1
		for i in kette: dreh[i] = sk.get_bone_pose_rotation(i)
	if gehalten: _daumen(sk, s, quer, d, r, u)
	for g in ["_01_", "_02_", "_03_"]:
		var i := sk.find_bone("thumb" + g + s)
		if i >= 0: dreh[i] = sk.get_bone_pose_rotation(i)
	merk["o"] = ol; merk["d"] = dl; merk["r"] = r; merk["dreh"] = dreh

# Daumen: Mittel- und Endglied um die Schaftachse, in der Richtung, in der der Abstand kleiner wird, bis er anliegt
static func _daumen(sk: Skeleton3D, s: String, quer: Callable, d: Vector3, r: float, u: float) -> void:
	var kette: Array[int] = []
	for g in ["_02_", "_03_"]:
		var i := sk.find_bone("thumb" + g + s)
		if i >= 0: kette.append(i)
	if kette.is_empty(): return
	for i in kette: sk.set_bone_pose_rotation(i, sk.get_bone_rest(i).basis.get_rotation_quaternion())
	var ab := func() -> float:
		var sp := _spitze(sk, kette[-1])
		var gl := sk.get_bone_global_pose(kette[-1]).origin
		return minf(float(quer.call(sp)), float(quer.call((sp + gl) * 0.5))) - r
	for j in kette.size():
		var a: float = ab.call()
		if a <= DAUMEN_HAUT * u: return
		_beuge(sk, kette[j], d, SCHRITT)
		var vz := 1.0 if float(ab.call()) < a else -1.0
		if vz < 0.0: _beuge(sk, kette[j], d, -SCHRITT)
		for st in HOECHST:
			var vorher: float = ab.call()
			if vorher <= DAUMEN_HAUT * u: return
			_beuge(sk, kette[j], d, vz * SCHRITT)
			var nach: float = ab.call()
			if nach < HAUT_MIN * u or nach >= vorher:
				_beuge(sk, kette[j], d, -vz * SCHRITT); break

## Spitze des Endglieds (Skelettraum): Kind des Knochens, sonst Ende in Richtung des Glieds
static func _spitze(sk: Skeleton3D, l: int) -> Vector3:
	var ch := sk.get_bone_children(l)
	if ch.size() > 0: return sk.get_bone_global_pose(ch[0]).origin
	var gb := sk.get_bone_global_pose(l).origin
	return gb + (gb - sk.get_bone_global_pose(sk.get_bone_parent(l)).origin) * 0.85

## Knochen i um die Achse a (Skelettraum) um w Grad drehen, Kinder folgen
static func _beuge(sk: Skeleton3D, i: int, a: Vector3, w: float) -> void:
	var g := sk.get_bone_global_pose(i)
	var nb := Basis(a.normalized(), deg_to_rad(w)) * g.basis.orthonormalized()
	var p := sk.get_bone_parent(i)
	var pb := sk.get_bone_global_pose(p).basis.orthonormalized() if p >= 0 else Basis.IDENTITY
	sk.set_bone_pose_rotation(i, (pb.inverse() * nb).get_rotation_quaternion())
