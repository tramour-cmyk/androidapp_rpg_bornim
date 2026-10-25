# 348.7: dreht Hals und Kopf eines Tiers nach dem Abspielen der Bewegung um die Hochachse zu seinem Ziel (Prüfer Runde 11:
# „alle gleich ausgerichtet; zeigt jeder Kopf auf sein Ziel?“). Der Rumpf bleibt halb seitlich, der Rest kommt vom Hals.
extends SkeletonModifier3D

const BONES := {"hals": 0.45, "kopf": 0.55}
const MAX_DEG := 35.0

## Gewünschte Drehung in Grad (positiv = links herum von oben gesehen), weich nachgeführt.
var want := 0.0
var now := 0.0
var turned := 0.0       # für den Prüflauf: zuletzt angewandte Drehung


func _process_modification_with_delta(delta: float) -> void:
	var sk := get_skeleton()
	if sk == null:
		return
	now = move_toward(now, clampf(want, -MAX_DEG, MAX_DEG), 120.0 * maxf(delta, 1.0 / 60.0))
	turned = now
	if absf(now) < 0.1:
		return
	# Hochachse der Welt im Raum des Skeletts (das Modell kann gedreht und skaliert sein)
	var up: Vector3 = (sk.global_basis.inverse() * Vector3.UP).normalized()
	for name in BONES:
		var b := sk.find_bone(name)
		if b < 0:
			continue
		var g := sk.get_bone_global_pose(b)
		var r := Basis(up, deg_to_rad(now * BONES[name]))
		g.basis = r * g.basis
		sk.set_bone_global_pose(b, g)
