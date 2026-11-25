# 2024 (Chef 25.11., 09:54 „2024 A“; Systemfrage): eine Waffe, die im Modell an einem eigenen Knochen hängt (Krogg „waffe“,
# krogg_gestalt.py; Grak „axt“, grak_gestalt.py), verlässt in keiner Bewegung die rechte Faust, außer im Tod.
# Ursache (tests/stiel_2024.gd, rot 4d4bfac47): der Knochen hat seinen Ursprung im Modellursprung, über 1 m von der Faust, mit
# Schlüsseln zu 24 Bildern/s; zwischen zwei Schlüsseln laufen Ort und Drehung getrennt, im schnellen Hieb flog die Waffe bis
# 0,75 m aus der Faust; beim Überblenden zweier Bewegungen ebenso (bis 8 cm).
# Der Bau (krogg_gestalt.py waffe_hand, grak_gestalt.py axt_hand) stellt die Waffe in jedem Bild außer im Tod mit derselben Lage in die
# rechte Faust; Godot liest die Bewegungen zu 30 Bildern/s neu ein (Schlüssel dazwischen gerechnet), dabei fliegt sie heraus.
# Hier: eine Schicht über allen anderen (läuft als letzte, auch nach ausholen.gd): die Waffe liegt in der Faust, wie sie gerade
# gezeichnet wird, mit der Lage aus Stehen, Bild 0 (dort ein echter Schlüssel des Baus); im Tod lässt die Faust los (Bewegung des Baus).
extends SkeletonModifier3D

const KNOCHEN := ["waffe", "axt"]

var anim: AnimationPlayer = null
var _waffe := -1
var _hand := -1
var _halt := Transform3D()     # Waffe im Raum der rechten Faust


## [ap] Bewegungen der Figur, [sk] ihr Skelett; false ohne Waffenknochen oder ohne Stehen
func einrichten(ap: AnimationPlayer, sk: Skeleton3D) -> bool:
	anim = ap
	for k in KNOCHEN:
		if sk.find_bone(k) >= 0:
			_waffe = sk.find_bone(k)
			break
	_hand = sk.find_bone("hand_r")
	if _waffe < 0 or _hand < 0 or ap == null or not ap.has_animation("Stehen"):
		return false
	var a := ap.get_animation("Stehen")
	var spuren := {}
	for t in a.get_track_count():
		var p := a.track_get_path(t)
		if p.get_subname_count() >= 1:
			spuren["%s|%d" % [String(p.get_subname(0)), a.track_get_type(t)]] = t
	_halt = _lage(sk, a, spuren, _kette(sk, _hand), 0.0).affine_inverse() * _lage(sk, a, spuren, _kette(sk, _waffe), 0.0)
	return true


func _kette(sk: Skeleton3D, b: int) -> Array:
	var out := []
	var k := b
	while k >= 0:
		out.push_front(k)
		k = sk.get_bone_parent(k)
	return out


## Lage des letzten Knochens der [kette] im Skelett, wie die Bewegung [a] ihn an der Stelle [t] stellt (ohne Spur: Ruhelage)
func _lage(sk: Skeleton3D, a: Animation, spuren: Dictionary, kette: Array, t: float) -> Transform3D:
	var g := Transform3D()
	for b in kette:
		var nm := sk.get_bone_name(b)
		var r: Transform3D = sk.get_bone_rest(b)
		var td: int = spuren.get("%s|%d" % [nm, Animation.TYPE_ROTATION_3D], -1)
		var to: int = spuren.get("%s|%d" % [nm, Animation.TYPE_POSITION_3D], -1)
		var ts: int = spuren.get("%s|%d" % [nm, Animation.TYPE_SCALE_3D], -1)
		var q: Quaternion = a.rotation_track_interpolate(td, t) if td >= 0 else r.basis.get_rotation_quaternion()
		var o: Vector3 = a.position_track_interpolate(to, t) if to >= 0 else r.origin
		var m: Vector3 = a.scale_track_interpolate(ts, t) if ts >= 0 else r.basis.get_scale()
		g = g * Transform3D(Basis(q).scaled(m), o)
	return g


func _process_modification_with_delta(_delta: float) -> void:
	var sk := get_skeleton()
	if sk == null or anim == null:
		return
	var cur := String(anim.current_animation)
	if cur == "" or cur.begins_with("Tod"):
		return
	var soll: Transform3D = sk.get_bone_global_pose(_hand) * _halt
	var pa := sk.get_bone_parent(_waffe)
	var lokal := (sk.get_bone_global_pose(pa).affine_inverse() if pa >= 0 else Transform3D()) * soll
	sk.set_bone_pose_position(_waffe, lokal.origin)
	sk.set_bone_pose_rotation(_waffe, lokal.basis.get_rotation_quaternion())
