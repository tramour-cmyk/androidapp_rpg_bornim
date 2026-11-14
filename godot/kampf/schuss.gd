# 601 (Chef 05.11., Build 266, t266.5: „Goblinspäher Schussanimation nicht vorhanden“): der Späher schießt sichtbar. Die Bewegungen
# des Goblin-Gerüsts (UAL, goblin.py) haben keinen Bogenschuss, darum eine Schicht über „Stehen“ (wie atem.gd, ausholen.gd):
# 1 heben: der Rumpf dreht die linke Schulter zum Ziel, der Bogenarm streckt sich mit dem Bogen auf das Ziel;
# 2 ziehen: die rechte Hand greift an der Bogenhand die Sehne und zieht bis vor die Wange, der Ellbogen hoch und hinten;
# 3 halten (zielen), 4 lösen bei LOS: die Zughand schnellt ein Stück zurück, der Bogen nickt; 5 senken in die Ruhe.
# Der Pfeil liegt vom Ziehen bis zum Lösen auf der Sehne (kampf_ui.gd pfeil_auf), beim Lösen fliegt er (kampf_ui.gd _pfeil_flug).
# Nur Richtungen der Knochen (Zielen mit Quaternion zwischen Ist- und Sollrichtung), Längen bleiben, wie das Gerüst sie hat.
extends SkeletonModifier3D

## Zeiten in s ab dem Beginn
const HEBEN_BIS := 0.24
const ZIEHEN_VON := 0.20
const ZIEHEN_BIS := 0.52
## Lösen: der Pfeil fliegt (Figur.strike gibt das als ms zurück)
const LOS := 0.70
const NACH_BIS := 0.80
const SENKEN_VON := 0.92
const DAUER := 1.20
## so weit dreht der Rumpf die linke Schulter zum Ziel (Anteil der vollen Drehung), der Kopf dreht zurück zum Ziel
const RUMPF := 0.75
## Ellbogen des Bogenarms nicht ganz durchgestreckt (Anteil zur Hand hin, Rest Richtung Ziel)
const BEUGE := 0.06
## Zughand vor der Wange: so weit vom Hals zur linken Schulter und nach vorn (Anteil der Schulterbreite)
const ANKER_SEITE := 0.25
const ANKER_VORN := 0.35
const ANKER_HOCH := 0.12
## nach dem Lösen fährt die Zughand so weit zurück (Anteil der Schulterbreite)
const NACH := 0.45

signal fertig

var ziel := Vector3.ZERO      # Welt: wohin der Pfeil zeigt
var t := -1.0                 # Zeit im Schuss, < 0: aus
var vor := 0.0                # so lange (s) wartet der Schuss noch (Seitenschritt für freie Linie, kampf_ui.gd _step_aside)
var _wartet := false
var _b := {}                  # Name -> Knochen


func einrichten(sk: Skeleton3D) -> bool:
	_b.clear()
	for n in ["spine_01", "spine_02", "spine_03", "neck_01", "Head", "clavicle_l", "upperarm_l", "lowerarm_l", "hand_l",
			"clavicle_r", "upperarm_r", "lowerarm_r", "hand_r"]:
		_b[n] = sk.find_bone(n)
	for n in ["spine_03", "upperarm_l", "lowerarm_l", "hand_l", "upperarm_r", "lowerarm_r", "hand_r"]:
		if int(_b[n]) < 0:
			return false
	return true


func schiessen(auf: Vector3) -> void:
	ziel = auf
	vor = 0.0
	t = 0.0
	_wartet = false


## erst nach [s] Sekunden anfangen (die Figur tritt vorher zur Seite)
func verschieben(s: float) -> void:
	if t >= 0.0 and t < 0.05:
		vor = maxf(s, 0.0)
		t = -1.0
		_wartet = vor > 0.0
		if not _wartet:
			t = 0.0


func an() -> bool:
	return _wartet or (t >= 0.0 and t < DAUER)


## Anteile der Phasen bei Zeit [x]: [Bogen oben 0..1, Sehne gezogen 0..1, nach dem Lösen 0..1]
static func phasen(x: float) -> Array:
	if x < 0.0 or x >= DAUER:
		return [0.0, 0.0, 0.0]
	var heben := smoothstep(0.0, HEBEN_BIS, x) * (1.0 - smoothstep(SENKEN_VON, DAUER, x))
	var ziehen := smoothstep(ZIEHEN_VON, ZIEHEN_BIS, x) if x < LOS else 1.0 - smoothstep(LOS, LOS + 0.3, x)
	var nach := smoothstep(LOS, NACH_BIS, x) * (1.0 - smoothstep(SENKEN_VON, DAUER, x)) if x >= LOS else 0.0
	return [heben, ziehen, nach]


func _process_modification_with_delta(delta: float) -> void:
	var sk := get_skeleton()
	if _wartet:
		vor -= maxf(delta, 0.0)
		if vor > 0.0:
			return
		_wartet = false
		t = 0.0
	if sk == null or t < 0.0 or _b.is_empty():
		return
	t += maxf(delta, 0.0)
	if t >= DAUER:
		t = -1.0
		fertig.emit()
		return
	var ph := phasen(t)
	var w_bogen: float = ph[0]
	var w_zug: float = ph[1]
	var w_nach: float = ph[2]
	if w_bogen <= 0.0005:
		return
	var inv := sk.global_transform.affine_inverse()
	var z: Vector3 = inv * ziel
	# 1 Rumpf: die Linie rechte -> linke Schulter (waagerecht) auf das Ziel, verteilt auf die Wirbel
	var sl := _pos(sk, "upperarm_l")
	var sr := _pos(sk, "upperarm_r")
	var mitte := (sl + sr) * 0.5
	var quer := Vector3(sl.x - sr.x, 0.0, sl.z - sr.z)
	var zu := Vector3(z.x - mitte.x, 0.0, z.z - mitte.z)
	var breite := maxf((sl - sr).length(), 0.01)
	if quer.length() > 0.001 and zu.length() > 0.001:
		var dreh := Quaternion(quer.normalized(), zu.normalized())
		var winkel := dreh.get_angle() * RUMPF * w_bogen
		var achse := Vector3.UP * signf(dreh.get_axis().y if dreh.get_angle() > 0.001 else 1.0)
		var wirbel := ["spine_01", "spine_02", "spine_03"].filter(func(n): return int(_b[n]) >= 0)
		for n in wirbel:
			_drehe(sk, int(_b[n]), Quaternion(achse, winkel / wirbel.size()))
		var kopf := "neck_01" if int(_b["neck_01"]) >= 0 else "Head"
		if int(_b[kopf]) >= 0:
			_drehe(sk, int(_b[kopf]), Quaternion(achse, -winkel * 0.85))
	# 2 Bogenarm gestreckt auf das Ziel (etwas über die Schulterhöhe, der Pfeil steigt im Bogen)
	sl = _pos(sk, "upperarm_l")
	var auf := (z - sl)
	if auf.length() < 0.01:
		return
	auf = (auf.normalized() + Vector3.UP * 0.08).normalized()
	_ziele(sk, "upperarm_l", "lowerarm_l", auf, w_bogen)
	_ziele(sk, "lowerarm_l", "hand_l", (auf + Vector3.DOWN * BEUGE).normalized(), w_bogen)
	_ziele(sk, "hand_l", "", auf, w_bogen * 0.6)
	# 3 Zughand: von der Bogenhand (Sehne greifen) bis vor die Wange, nach dem Lösen ein Stück zurück
	var bogen := _pos(sk, "hand_l")
	var hals := _pos(sk, "neck_01") if int(_b["neck_01"]) >= 0 else (_pos(sk, "spine_03") + Vector3.UP * breite * 0.6)
	var seite := (sl - _pos(sk, "upperarm_r")).normalized()
	var wange := hals + seite * (breite * ANKER_SEITE) + auf * (breite * ANKER_VORN) + Vector3.UP * (breite * ANKER_HOCH)
	var f := w_zug if t < LOS else 1.0     # nach dem Lösen bleibt die Hand an der Wange, der Arm sinkt mit dem Bogen
	var hand := bogen.lerp(wange, f) - auf * (breite * NACH * w_nach)
	var w_arm := maxf(w_bogen * smoothstep(0.0, 0.5, t / ZIEHEN_VON) if t < ZIEHEN_VON else w_bogen, 0.0)
	_zwei_glieder(sk, hand, -auf + Vector3.UP * 0.5, w_arm)


func _pos(sk: Skeleton3D, n: String) -> Vector3:
	return sk.get_bone_global_pose(int(_b[n])).origin


## Knochen [b] in Skelettraum um [q] drehen (um seinen Ursprung)
func _drehe(sk: Skeleton3D, b: int, q: Quaternion) -> void:
	var g := sk.get_bone_global_pose(b)
	var nb := Basis(q) * g.basis
	_setze(sk, b, nb)


func _setze(sk: Skeleton3D, b: int, global_basis: Basis) -> void:
	var p := sk.get_bone_parent(b)
	var pb: Basis = sk.get_bone_global_pose(p).basis if p >= 0 else Basis.IDENTITY
	sk.set_bone_pose_rotation(b, (pb.orthonormalized().inverse() * global_basis.orthonormalized()).get_rotation_quaternion())


## Knochen [von] so drehen, dass er (zum Kind [nach], ohne Kind seine eigene y-Achse) in Richtung [r] zeigt, Anteil [w]
func _ziele(sk: Skeleton3D, von: String, nach: String, r: Vector3, w: float) -> void:
	var b := int(_b[von])
	var g := sk.get_bone_global_pose(b)
	var ist: Vector3 = (_pos(sk, nach) - g.origin) if nach != "" and int(_b.get(nach, -1)) >= 0 else g.basis.y
	if ist.length() < 0.0001:
		return
	var q := Quaternion(ist.normalized(), r.normalized())
	_setze(sk, b, Basis(Quaternion.IDENTITY.slerp(q, w)) * g.basis)


## Oberarm und Unterarm rechts so, dass die Hand bei [hand] liegt (Skelettraum), Ellbogen zur Seite [pol]; Anteil [w]
func _zwei_glieder(sk: Skeleton3D, hand: Vector3, pol: Vector3, w: float) -> void:
	if w <= 0.0005:
		return
	var s := _pos(sk, "upperarm_r")
	var l1 := (_pos(sk, "lowerarm_r") - s).length()
	var l2 := (_pos(sk, "hand_r") - _pos(sk, "lowerarm_r")).length()
	var d := hand - s
	var n := clampf(d.length(), 0.01, (l1 + l2) * 0.999)
	var dn := d.normalized()
	# Ellbogen: auf dem Kreis um die Linie Schulter -> Hand, zur Polseite
	var a := (l1 * l1 - l2 * l2 + n * n) / (2.0 * n)
	var h := sqrt(maxf(l1 * l1 - a * a, 0.0))
	var p := (pol - dn * pol.dot(dn))
	p = p.normalized() if p.length() > 0.001 else dn.cross(Vector3.RIGHT).normalized()
	var ell := s + dn * a + p * h
	_ziele(sk, "upperarm_r", "lowerarm_r", (ell - s).normalized(), w)
	_ziele(sk, "lowerarm_r", "hand_r", (s + dn * n - _pos(sk, "lowerarm_r")).normalized(), w)
