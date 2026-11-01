# 453 r2 (Chef 01.11., 13:0x, Archiv 453: „wichtig ist nur, dass die Wölfe nicht im Gleichtakt Dinge tun und atmen kann man nicht
# aussetzen, d.h. Stillstand für mehrere Sekunden geht eigentlich nicht, entweder Animation mit Bewegung oder Atmen“): der Wolf atmet
# als eigene Schicht unter jeder Bewegung (Stehen, Hocke, Gesten, Gehen, Sprung, Biss), wie die Helden (atem.gd, 453.1): je Wolf eigener
# Takt (± TAKT_STREU) und Versatz, nach Biss, Treffer, Ausweichen schneller und tiefer, dann abklingend.
# Der Brustkorb weitet sich: die Rückenknochen über Brust und Flanke (Spine_02, Spine_03 der Quelle) werden quer zum Rumpf breiter und
# heben sich; Spine_04 behält seine Lage, damit Schultern, Vorderläufe, Hals und Kopf (und damit die Pfoten) nicht mitgehen.
extends "res://kampf/atem.gd"

## Ruhe: ein Atemzug in Sekunden (wachsam im Kampf, 25 je Minute)
const TIER_RUHE_S := 2.4
## bei voller Einatmung in Ruhe: Flanke breiter (Anteil), Bauch tiefer (Anteil), Rücken höher (Meter)
const BREITER := 0.09
const TIEFER_BAUCH := 0.05
const HEBEN_M := 0.014
## [Knochen, Anteil]: Spine_02 über der Flanke voll, Spine_03 über der Brust etwas weniger
const RIPPEN := [["Wolf_Spine_02SHJnt", 1.0], ["Wolf_Spine_03SHJnt", 0.8]]
const HALTEN := "Wolf_Spine_04SHJnt"
const VON := "Wolf_Spine_01SHJnt"

var _rippen := []
var _halten := -1
var _von := -1


static func passt(sk: Skeleton3D) -> bool:
	return sk.find_bone(RIPPEN[0][0]) >= 0 and sk.find_bone(HALTEN) >= 0 and sk.find_bone(VON) >= 0


func eigen(seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	takt = TIER_RUHE_S * (1.0 + rng.randf_range(-TAKT_STREU, TAKT_STREU))
	phase = rng.randf()


func _process_modification_with_delta(delta: float) -> void:
	var sk := get_skeleton()
	if sk == null:
		return
	schritt(maxf(delta, 0.0))
	if _rippen.is_empty():
		for r in RIPPEN:
			_rippen.append(sk.find_bone(r[0]))
		_halten = sk.find_bone(HALTEN)
		_von = sk.find_bone(VON)
	if _halten < 0 or _von < 0:
		return
	tiefe = welle(phase) * (1.0 + TIEFER * anstrengung)
	if tiefe < 0.0005:
		return
	# Achsen im Raum des Skeletts: oben aus der Welt, längs den Rücken entlang (folgt Ducken und Biss), quer daraus
	var oben: Vector3 = (sk.global_basis.inverse() * Vector3.UP).normalized()
	var laengs: Vector3 = sk.get_bone_global_pose(_halten).origin - sk.get_bone_global_pose(_von).origin
	if laengs.length() < 1e-6:
		return
	laengs = laengs.normalized()
	var quer := laengs.cross(oben).normalized()
	oben = quer.cross(laengs).normalized()
	var m_je_einheit: float = sk.global_basis.get_scale().y
	var heben: Vector3 = oben * (HEBEN_M * tiefe / maxf(m_je_einheit, 1e-6))
	var halten := sk.get_bone_global_pose(_halten)
	var achsen := Basis(quer, oben, laengs)
	var vorher := []     # erst alle lesen: nach dem Setzen enthielte der Kindknochen die Weitung des Elternknochens schon
	for b in _rippen:
		vorher.append(sk.get_bone_global_pose(b) if b >= 0 else Transform3D())
	for i in RIPPEN.size():
		var b: int = _rippen[i]
		if b < 0:
			continue
		var a: float = RIPPEN[i][1] * tiefe
		var weit := achsen * Basis.from_scale(Vector3(1.0 + BREITER * a, 1.0 + TIEFER_BAUCH * a, 1.0)) * achsen.inverse()
		var g: Transform3D = vorher[i]
		g.basis = weit * g.basis
		g.origin += heben * RIPPEN[i][1]
		sk.set_bone_global_pose(b, g)
	sk.set_bone_global_pose(_halten, halten)
