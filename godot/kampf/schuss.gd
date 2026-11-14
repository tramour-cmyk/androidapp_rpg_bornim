# 601 (Chef 05.11., Build 266, t266.5: „Goblinspäher Schussanimation nicht vorhanden“): der Späher schießt sichtbar. Die Bewegungen
# des Goblin-Gerüsts (UAL, goblin.py) haben keinen Bogenschuss, darum eine Schicht über „Stehen“ (wie atem.gd, ausholen.gd):
# 1 heben: der Rumpf dreht die linke Schulter zum Ziel, der Bogenarm streckt sich mit dem Bogen auf das Ziel;
# 2 ziehen: die rechte Hand greift an der Bogenhand die Sehne und zieht bis vor die Wange, der Ellbogen hoch und hinten;
# 3 halten (zielen), 4 lösen bei LOS: die Zughand schnellt ein Stück zurück, der Bogen nickt; 5 senken in die Ruhe.
# Der Pfeil liegt vom Ziehen bis zum Lösen auf der Sehne (kampf_ui.gd pfeil_auf), beim Lösen fliegt er (kampf_ui.gd _pfeil_flug).
# Nur Richtungen der Knochen (Zielen mit Quaternion zwischen Ist- und Sollrichtung), Längen bleiben, wie das Gerüst sie hat.
# Zwei Gerüste: UAL-Namen (upperarm_l …) und das Kampfgerüst aus goblin.py mit Strecken „von-bis“ (upL-elL …); die Hand liegt dort am
# Ende der letzten Strecke (foL-wrL), ohne eigenen Knochen.
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
var _r := {}                  # Rolle -> Knochen (int) oder Liste
var _hand_ende := false       # die Hand am Ende der letzten Armstrecke (Kampfgerüst)
var _ende := {}               # letzte Armstrecke -> Weg zum Ende im eigenen Raum (Ruhelage)

## Rollen je Gerüst: Wirbel, Hals, Kopf, Arme (Oberarm, Unterarm, letzte Strecke oder Hand)
const GERUESTE := {
	"ual": {"wirbel": ["spine_01", "spine_02", "spine_03"], "hals": "neck_01", "kopf": "Head",
		"arm_l": ["upperarm_l", "lowerarm_l", "hand_l"], "arm_r": ["upperarm_r", "lowerarm_r", "hand_r"], "ende": false},
	"strecken": {"wirbel": ["pelvis-waist", "waist-belly", "belly-chest"], "hals": "chestTop-neck", "kopf": "neck-neckTop",
		"arm_l": ["upL-elL", "elL-foL", "foL-wrL"], "arm_r": ["upR-elR", "elR-foR", "foR-wrR"], "ende": true},
}


func einrichten(sk: Skeleton3D) -> bool:
	for art in GERUESTE:
		var g: Dictionary = GERUESTE[art]
		var ok := true
		for n in g.arm_l + g.arm_r:
			ok = ok and sk.find_bone(n) >= 0
		if not ok:
			continue
		_r = {"wirbel": [], "hals": sk.find_bone(g.hals), "kopf": sk.find_bone(g.kopf), "arm_l": [], "arm_r": []}
		for n in g.wirbel:
			if sk.find_bone(n) >= 0:
				_r.wirbel.append(sk.find_bone(n))
		for sd in ["arm_l", "arm_r"]:
			for n in g[sd]:
				_r[sd].append(sk.find_bone(n))
		_hand_ende = g.ende
		if _hand_ende:     # Ende der letzten Strecke: so weit wie von der vorigen Strecke bis zu ihr, in ihrem Raum
			for sd in ["arm_l", "arm_r"]:
				var c: int = _r[sd][2]
				var b: int = _r[sd][1]
				var rc := sk.get_bone_global_rest(c)
				var v := rc.origin - sk.get_bone_global_rest(b).origin
				_ende[c] = rc.basis.inverse() * v
		return not _r.wirbel.is_empty()
	return false


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


## Hand ([sd] "arm_l"/"arm_r") im Raum des Skeletts
func hand(sk: Skeleton3D, sd: String) -> Vector3:
	var c: int = _r[sd][2]
	var g := sk.get_bone_global_pose(c)
	return g.origin + g.basis * (_ende[c] as Vector3) if _hand_ende else g.origin


## Hand in der Welt (der Pfeil auf der Sehne liegt an der Zughand)
func hand_welt(sk: Skeleton3D, sd: String) -> Vector3:
	return sk.global_transform * hand(sk, sd)


func _process_modification_with_delta(delta: float) -> void:
	var sk := get_skeleton()
	if _wartet:
		vor -= maxf(delta, 0.0)
		if vor > 0.0:
			return
		_wartet = false
		t = 0.0
	if sk == null or t < 0.0 or _r.is_empty():
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
	var sl := _o(sk, _r.arm_l[0])
	var sr := _o(sk, _r.arm_r[0])
	var mitte := (sl + sr) * 0.5
	var quer := Vector3(sl.x - sr.x, 0.0, sl.z - sr.z)
	var zu := Vector3(z.x - mitte.x, 0.0, z.z - mitte.z)
	var breite := maxf((sl - sr).length(), 0.01)
	if quer.length() > 0.001 and zu.length() > 0.001:
		var dreh := Quaternion(quer.normalized(), zu.normalized())
		var winkel := dreh.get_angle() * RUMPF * w_bogen
		var achse := Vector3.UP * signf(dreh.get_axis().y if dreh.get_angle() > 0.001 else 1.0)
		for b in _r.wirbel:
			_drehe(sk, b, Quaternion(achse, winkel / _r.wirbel.size()))
		var kopf: int = _r.hals if _r.hals >= 0 else _r.kopf
		if kopf >= 0:
			_drehe(sk, kopf, Quaternion(achse, -winkel * 0.85))
	# 2 Bogenarm gestreckt auf das Ziel (etwas über die Schulterhöhe, der Pfeil steigt im Bogen)
	sl = _o(sk, _r.arm_l[0])
	var auf := (z - sl)
	if auf.length() < 0.01:
		return
	auf = (auf.normalized() + Vector3.UP * 0.08).normalized()
	var al: Array = _r.arm_l
	_ziele(sk, al[0], _o(sk, al[1]) - _o(sk, al[0]), auf, w_bogen)
	var unter := (auf + Vector3.DOWN * BEUGE).normalized()
	_ziele(sk, al[1], _o(sk, al[2]) - _o(sk, al[1]), unter, w_bogen)
	if _hand_ende:
		_ziele(sk, al[2], hand(sk, "arm_l") - _o(sk, al[2]), unter, w_bogen)
	else:
		_ziele(sk, al[2], sk.get_bone_global_pose(al[2]).basis.y, auf, w_bogen * 0.6)
	# 3 Zughand: von der Bogenhand (Sehne greifen) bis vor die Wange, nach dem Lösen ein Stück zurück
	var bogen := hand(sk, "arm_l")
	var hals: Vector3 = _o(sk, _r.hals) if _r.hals >= 0 else (_o(sk, _r.wirbel[-1]) + Vector3.UP * breite * 0.6)
	var seite := (sl - _o(sk, _r.arm_r[0])).normalized()
	var wange := hals + seite * (breite * ANKER_SEITE) + auf * (breite * ANKER_VORN) + Vector3.UP * (breite * ANKER_HOCH)
	var f := w_zug if t < LOS else 1.0     # nach dem Lösen bleibt die Hand an der Wange, der Arm sinkt mit dem Bogen
	var hz := bogen.lerp(wange, f) - auf * (breite * NACH * w_nach)
	var w_arm := maxf(w_bogen * smoothstep(0.0, 0.5, t / ZIEHEN_VON) if t < ZIEHEN_VON else w_bogen, 0.0)
	_zwei_glieder(sk, hz, -auf + Vector3.UP * 0.5, w_arm)


func _o(sk: Skeleton3D, b: int) -> Vector3:
	return sk.get_bone_global_pose(b).origin


## Knochen [b] in Skelettraum um [q] drehen (um seinen Ursprung)
func _drehe(sk: Skeleton3D, b: int, q: Quaternion) -> void:
	var g := sk.get_bone_global_pose(b)
	_setze(sk, b, Basis(q) * g.basis)


func _setze(sk: Skeleton3D, b: int, global_basis: Basis) -> void:
	var p := sk.get_bone_parent(b)
	var pb: Basis = sk.get_bone_global_pose(p).basis if p >= 0 else Basis.IDENTITY
	sk.set_bone_pose_rotation(b, (pb.orthonormalized().inverse() * global_basis.orthonormalized()).get_rotation_quaternion())


## Knochen [b] so drehen, dass seine Richtung [ist] (Skelettraum) nach [r] zeigt, Anteil [w]
func _ziele(sk: Skeleton3D, b: int, ist: Vector3, r: Vector3, w: float) -> void:
	if ist.length() < 0.0001 or r.length() < 0.0001:
		return
	var g := sk.get_bone_global_pose(b)
	var q := Quaternion(ist.normalized(), r.normalized())
	_setze(sk, b, Basis(Quaternion.IDENTITY.slerp(q, w)) * g.basis)


## rechter Arm so, dass die Hand bei [ziel_h] liegt (Skelettraum), Ellbogen zur Seite [pol]; Anteil [w]
func _zwei_glieder(sk: Skeleton3D, ziel_h: Vector3, pol: Vector3, w: float) -> void:
	if w <= 0.0005:
		return
	var ar: Array = _r.arm_r
	var s := _o(sk, ar[0])
	var l1 := (_o(sk, ar[1]) - s).length()
	var l2 := (hand(sk, "arm_r") - _o(sk, ar[1])).length()
	var d := ziel_h - s
	var n := clampf(d.length(), 0.01, (l1 + l2) * 0.999)
	var dn := d.normalized()
	# Ellbogen: auf dem Kreis um die Linie Schulter -> Hand, zur Polseite
	var a := (l1 * l1 - l2 * l2 + n * n) / (2.0 * n)
	var h := sqrt(maxf(l1 * l1 - a * a, 0.0))
	var p := (pol - dn * pol.dot(dn))
	p = p.normalized() if p.length() > 0.001 else dn.cross(Vector3.RIGHT).normalized()
	var ell := s + dn * a + p * h
	_ziele(sk, ar[0], _o(sk, ar[1]) - s, ell - s, w)
	var hin := s + dn * n
	_ziele(sk, ar[1], hand(sk, "arm_r") - _o(sk, ar[1]), hin - _o(sk, ar[1]), w)
	if _hand_ende:     # die letzte Strecke in dieselbe Richtung (der Unterarm ist dort zweiteilig)
		_ziele(sk, ar[2], hand(sk, "arm_r") - _o(sk, ar[2]), hin - _o(sk, ar[1]), w)
