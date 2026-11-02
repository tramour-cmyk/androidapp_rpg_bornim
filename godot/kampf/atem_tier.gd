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
## 453 r3 (Prüfer Film r3, 01.11., 23:2x: Rücken im Film 0,3–0,5 px): kein Bildfehler, die Schicht kommt im Bild an (atem_render_453:
## Rücken bis 3,7 px, wie gerechnet), aber zu klein: Rücken 15 mm auf 37 cm Länge, 1,7–2,4 px aus der Kampfkamera (11–15 m), der Bauch
## ging nicht mit (−0,5 mm: Heben und Weiten hoben sich auf). Jetzt Rücken 22 mm, Bauch −18 mm (atem_ruecken_453), Pfoten und Kopf
## wie bisher still (atem_netz_453); vorher BAUCH 0,05, HEBEN 0,014
const BREITER := 0.09
const TIEFER_BAUCH := 0.12
const HEBEN_M := 0.010
## [Knochen, Anteil]: Spine_02 über der Flanke voll, Spine_03 über der Brust etwas weniger
const RIPPEN := [["Wolf_Spine_02SHJnt", 1.0], ["Wolf_Spine_03SHJnt", 0.8]]
const HALTEN := "Wolf_Spine_04SHJnt"
const VON := "Wolf_Spine_01SHJnt"

var _rippen := []
var _halten := -1
## 453 r3 (gemessen tests/atem_netz_453.gd): Spine_04 und alles darunter (Schultern, Vorderläufe, Hals, Kopf) der Reihe nach von oben
## zurück auf die Pose vor dem Atem. Nur Spine_04 genügte nicht: die Weitung quer zum Rumpf liegt nicht genau in den Achsen der
## Knochen, set_bone_pose zerlegt sie in Drehung und Maßstab und verliert die Scherung; der Rest ging bis in die Vorderpfoten (5 mm je
## Atemzug) und den Kopf (1 mm).
var _kinder := PackedInt32Array()
var _von := -1

## 453a B (Chef 02.11., 11:15, „453a B“, Archiv 453a; Votum Tuffy): aus der Kampfkamera (11–15 m) hob sich in r3b nur die Rückenmitte
## (ein Fünftel der Länge, 3–4 px). Jetzt hebt sich der ganze Rücken vom Hinterteil (Spine_01) bis zur Schulterhöhe (Spine_04), dazu
## Schultern und Hals um 1 cm; Kopf, Läufe, Pfoten und Rute bleiben, wo die Bewegung sie hinstellt. [Knochen, Weitung (Anteil wie
## RIPPEN), Hebung m]; Weitung hebt die Rückenhaut zusätzlich (r3: Spine_02 mit 0,010 m Hebung gab 22 mm Rückenlinie).
## Prüfschalter ATEM_R3B=1: wie r3b (Vergleichsfilm).
## Lauf 174 (Prüfer: Kruppe 2,0–2,5 px, Hüfte höchstens 0,3 px; atem_ruecken: Hinterteil auf ROOT gewichtet, 7 mm): ROOT hebt sich mit
const RUECKEN_B := [["Wolf_ROOTSHJnt", 0.0, 0.012], ["Wolf_Spine_01SHJnt", 0.7, 0.012], ["Wolf_Spine_02SHJnt", 1.0, 0.010], ["Wolf_Spine_03SHJnt", 0.8, 0.010],
	["Wolf_Spine_04SHJnt", 0.0, 0.010], ["Wolf_Spine_TopSHJnt", 0.0, 0.010], ["hals", 0.0, 0.010]]
var R3B := OS.get_environment("ATEM_R3B") != ""
var _b_folge := PackedInt32Array()     # alle Knochen unter dem ersten gehobenen, Eltern vor Kindern
var _b_art := {}                       # Knochen -> Index in RUECKEN_B; fehlt er, bleibt er in der Lage vor dem Atem


## Reihenfolge einmal: von den Wurzeln abwärts; nur Knochen unter einem gehobenen werden gesetzt
func _b_bereit(sk: Skeleton3D) -> void:
	for i in RUECKEN_B.size():
		var b := sk.find_bone(RUECKEN_B[i][0])
		if b >= 0:
			_b_art[b] = i
	var offen := []
	for b in sk.get_bone_count():
		if sk.get_bone_parent(b) < 0:
			offen.append([b, false])
	while not offen.is_empty():
		var e: Array = offen.pop_front()
		var unter: bool = e[1] or _b_art.has(e[0])
		if unter:
			_b_folge.append(e[0])
		for k in sk.get_bone_children(e[0]):
			offen.append([k, unter])
	if OS.get_environment("ATEM_BAUM") != "":     # Prüflauf: welche Knochen heben sich, welche bleiben
		var z := []
		for b in _b_folge:
			z.append("%s%s<%s" % ["+" if _b_art.has(b) else "", sk.get_bone_name(b), sk.get_bone_name(sk.get_bone_parent(b))])
		print("ATEMBAUM %s" % " ".join(z))


func _ruecken_b(sk: Skeleton3D) -> void:
	if _b_folge.is_empty():
		_b_bereit(sk)
		_von = sk.find_bone(VON)
		_halten = sk.find_bone(HALTEN)
	if _b_folge.is_empty() or _von < 0 or _halten < 0:
		return
	tiefe = welle(phase) * (1.0 + TIEFER * anstrengung)
	if tiefe < 0.0005:
		return
	var oben: Vector3 = (sk.global_basis.inverse() * Vector3.UP).normalized()
	var laengs: Vector3 = sk.get_bone_global_pose(_halten).origin - sk.get_bone_global_pose(_von).origin
	if laengs.length() < 1e-6:
		return
	laengs = laengs.normalized()
	var quer := laengs.cross(oben).normalized()
	oben = quer.cross(laengs).normalized()
	var je_m: float = 1.0 / maxf(sk.global_basis.get_scale().y, 1e-6)
	var achsen := Basis(quer, oben, laengs)
	var vorher := []     # erst alle lesen: nach dem Setzen enthielte ein Kindknochen die Lage des Elternknochens schon
	for b in _b_folge:
		vorher.append(sk.get_bone_global_pose(b))
	for i in _b_folge.size():
		var b: int = _b_folge[i]
		var g: Transform3D = vorher[i]
		if _b_art.has(b):
			var r: Array = RUECKEN_B[_b_art[b]]
			var a: float = float(r[1]) * tiefe
			if a > 0.0:
				g.basis = achsen * Basis.from_scale(Vector3(1.0 + BREITER * a, 1.0 + TIEFER_BAUCH * a, 1.0)) * achsen.inverse() * g.basis
			g.origin += oben * (float(r[2]) * tiefe * je_m)
		sk.set_bone_global_pose(b, g)


static func passt(sk: Skeleton3D) -> bool:
	return sk.find_bone(RIPPEN[0][0]) >= 0 and sk.find_bone(HALTEN) >= 0 and sk.find_bone(VON) >= 0


## 453a (Prüfer Film Lauf 174, C3: schwarzer und grauer Wolf atmeten den ersten Zug gleichzeitig, Höchststand beide bei 1,2 s): der
## Versatz aus dem Zufall allein lag zweimal dicht beieinander; jetzt je neuem Wolf um den goldenen Schnitt weiter, dazu wenig Zufall
static var _zaehler := 0
func eigen(seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	takt = TIER_RUHE_S * (1.0 + rng.randf_range(-TAKT_STREU, TAKT_STREU))
	phase = fposmod(_zaehler * 0.618034 + rng.randf_range(0.0, 0.1), 1.0)
	_zaehler += 1


func _process_modification_with_delta(delta: float) -> void:
	var sk := get_skeleton()
	if sk == null:
		return
	schritt(maxf(delta, 0.0))
	if not R3B:
		_ruecken_b(sk)
		return
	if _rippen.is_empty():
		for r in RIPPEN:
			_rippen.append(sk.find_bone(r[0]))
		_halten = sk.find_bone(HALTEN)
		_von = sk.find_bone(VON)
		if _halten >= 0:
			var offen := [_halten]
			while not offen.is_empty():
				var k: int = offen.pop_front()
				_kinder.append(k)
				offen.append_array(Array(sk.get_bone_children(k)))
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
	var kinder := []
	for k in _kinder:
		kinder.append(sk.get_bone_global_pose(k))
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
	for i in _kinder.size():
		sk.set_bone_global_pose(_kinder[i], kinder[i])
