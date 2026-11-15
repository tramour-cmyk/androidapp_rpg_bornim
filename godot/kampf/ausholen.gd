# 1000 (Tuffy 620.2c, wie 310 der alten Fassung: „wound up from the announcement; held through its own turn until the blow, lowered
# when foiled“, SkirmishScreen.kt 557): nach der Ansage „Schwerer Hieb“ hält Grak die Axt oben, hinter dem Kopf, bis zu seinem Hieb,
# auch während der Züge der anderen, beim Ring und auf dem Weg zum Ziel; kommt er aus dem Tritt (Ansage weg ohne Hieb), senkt er sie.
# Eine Schicht über der Grundbewegung (wie atem.gd): Rumpf, Hals, Kopf und Arme nehmen die Lage aus seiner eigenen Bewegung „Hieb“
# im obersten Punkt (GRAK_HIEB in grak_gestalt.py: 0,30–0,38 s ruht die Axt oben); Becken und Beine bleiben bei Stehen oder Gehen.
# Damit nichts starr steht (C2), wiegt sich die Lage langsam zwischen OBEN_VON und OBEN_BIS (Spannung vor dem Schlag). Beim Hieb
# beginnt „Hieb“ an genau der Stelle, die die Schicht gerade zeigt (figur.gd _hieb), und die Schicht geht im selben Bild aus.
extends SkeletonModifier3D

## Stelle in „Hieb“ (s), zwischen denen die gehaltene Lage pendelt: Axt oben hinter dem Kopf
const OBEN_VON := 0.30
const OBEN_BIS := 0.38
## ein Hin und Her in Sekunden
const PENDEL_S := 1.9
## hinein (Ausholen aus Stehen) und hinaus (Senken nach dem Aus-dem-Tritt-Kommen), Zeitkonstante in s
const HOCH_S := 0.16
const SENK_S := 0.22
## so lange nach dem Treffer, Ausweichen … zurück in die Lage (Zeitkonstante, s)
const STOER_S := 0.08
## Grundbewegungen, über denen die Lage gilt; bei allen anderen (Treffer, Ausweichen, Tod) gibt sie der Bewegung nach
const UNTER := ["Stehen", "Gehen", "Rennen", "Zurück", "Lauern", "Umsehen"]
## im Treffer zuckt er, die Axt bleibt aber oben (so viel der Lage bleibt)
const STOER := {"Treffer": 0.7}

var hieb: Animation = null
var anim: AnimationPlayer = null
var an := false            # gehalten (Ansage bis Hieb)
var gewicht := 0.0         # 0 = nur die Grundbewegung, 1 = ganz in der Lage
var phase := 0.0
var fest := false         # unterwegs zum Hieb: die Stelle bleibt, damit der Aufschlag zur Zeit kommt, die _hieb gerechnet hat
var _spuren := []          # [Knochen, Drehspur, Ortsspur]
# 1000 (Chef 15.11., 12:55, Fund t286.5a: „die Axt bewegt sich nicht mit, die schwebt jetzt vor ihm. Wie Telekinese.“): Graks Axt
# hängt nicht an der Hand, sondern an einem eigenen Knochen „axt“ unter root (grak_gestalt.py: je Bild dorthin gestellt, wo die
# rechte Faust sie hält). Die Schicht nahm nur Knochen ab spine_01, die Axt blieb also in der Grundbewegung (Stehen) stehen, während
# die Arme hochgingen. Jetzt folgt der Knochen „axt“ der rechten Faust, wie sie nach der Schicht steht: Lage der Axt im Raum der
# Faust aus der Grundbewegung, mit dem Gewicht hin zu der aus „Hieb“ an der gezeigten Stelle.
var _axt := -1
var _hand := -1
var _kette_hand := []      # je Knochen von der Wurzel bis hand_r: [Knochen, Drehspur, Ortsspur, Maßspur] in „Hieb“
var _kette_axt := []


## [h] die Bewegung „Hieb“ der Figur, [sk] ihr Skelett: Rumpf ab spine_01 aufwärts samt Armen, ohne Becken und Beine
func einrichten(h: Animation, ap: AnimationPlayer, sk: Skeleton3D) -> bool:
	hieb = h
	anim = ap
	_spuren.clear()
	var wurzel := sk.find_bone("spine_01")
	if wurzel < 0 or h == null:
		return false
	var dreh := {}
	var ort := {}
	for t in h.get_track_count():
		var p := h.track_get_path(t)
		if p.get_subname_count() < 1:
			continue
		var b := sk.find_bone(String(p.get_subname(0)))
		if b < 0:
			continue
		if h.track_get_type(t) == Animation.TYPE_ROTATION_3D:
			dreh[b] = t
		elif h.track_get_type(t) == Animation.TYPE_POSITION_3D:
			ort[b] = t
	for b in sk.get_bone_count():
		var k := b
		while k >= 0 and k != wurzel:
			k = sk.get_bone_parent(k)
		if k == wurzel and dreh.has(b):
			_spuren.append([b, dreh[b], ort.get(b, -1)])
	_axt = sk.find_bone("axt")
	_hand = sk.find_bone("hand_r")
	_kette_hand.clear()
	_kette_axt.clear()
	if _axt >= 0 and _hand >= 0:
		var mass := {}
		for t in h.get_track_count():
			var p := h.track_get_path(t)
			if p.get_subname_count() >= 1 and h.track_get_type(t) == Animation.TYPE_SCALE_3D:
				mass[sk.find_bone(String(p.get_subname(0)))] = t
		for paar in [[_hand, _kette_hand], [_axt, _kette_axt]]:
			var k: int = paar[0]
			while k >= 0:
				(paar[1] as Array).push_front([k, dreh.get(k, -1), ort.get(k, -1), mass.get(k, -1)])
				k = sk.get_bone_parent(k)
	return not _spuren.is_empty()


## Lage des letzten Knochens der [kette] im Skelett, wie „Hieb“ ihn an der Stelle [t] stellt (ohne Spur: Ruhelage)
func _in_hieb(sk: Skeleton3D, kette: Array, t: float) -> Transform3D:
	var g := Transform3D()
	for e in kette:
		var b: int = e[0]
		var q: Quaternion = hieb.rotation_track_interpolate(e[1], t) if e[1] >= 0 else sk.get_bone_rest(b).basis.get_rotation_quaternion()
		var o: Vector3 = hieb.position_track_interpolate(e[2], t) if e[2] >= 0 else sk.get_bone_rest(b).origin
		var m: Vector3 = hieb.scale_track_interpolate(e[3], t) if e[3] >= 0 else sk.get_bone_rest(b).basis.get_scale()
		g = g * Transform3D(Basis(q).scaled(m), o)
	return g


## Stelle in „Hieb“, die die Schicht gerade zeigt (s)
func stelle() -> float:
	return OBEN_VON + (OBEN_BIS - OBEN_VON) * (0.5 - 0.5 * cos(TAU * phase))


## im Hieb: die Bewegung übernimmt an derselben Stelle, die Schicht ist sofort aus
func aus_sofort() -> void:
	an = false
	fest = false
	gewicht = 0.0


func _process_modification_with_delta(delta: float) -> void:
	var sk := get_skeleton()
	if sk == null or hieb == null:
		return
	var dt := maxf(delta, 0.0)
	var cur: String = anim.current_animation if anim != null else ""
	var ziel: float = (1.0 if cur in UNTER else float(STOER.get(cur, 0.0))) if an else 0.0
	if an and cur == "":
		ziel = gewicht     # zwischen zwei Bewegungen (Treffer zu Ende, Stehen noch nicht): bleiben, wie es ist
	var tau := HOCH_S if ziel > gewicht else (SENK_S if not an else STOER_S)
	gewicht = lerpf(gewicht, ziel, 1.0 - exp(-dt / tau))
	if an and not fest:
		phase = fposmod(phase + dt / PENDEL_S, 1.0)
	if gewicht < 0.002:
		gewicht = 0.0 if ziel == 0.0 else gewicht
		return
	var t := stelle()
	# 1000: Axt im Raum der rechten Faust, wie die Grundbewegung sie gerade hält (vor der Schicht)
	var mit_axt := _axt >= 0 and _hand >= 0
	var halt_grund := sk.get_bone_global_pose(_hand).affine_inverse() * sk.get_bone_global_pose(_axt) if mit_axt else Transform3D()
	for s in _spuren:
		var b: int = s[0]
		var q := hieb.rotation_track_interpolate(s[1], t)
		sk.set_bone_pose_rotation(b, sk.get_bone_pose_rotation(b).slerp(q, gewicht))
		if s[2] >= 0:
			sk.set_bone_pose_position(b, sk.get_bone_pose_position(b).lerp(hieb.position_track_interpolate(s[2], t), gewicht))
	if mit_axt:
		var halt_hieb := _in_hieb(sk, _kette_hand, t).affine_inverse() * _in_hieb(sk, _kette_axt, t)
		# 1314 (Lauf 497 rot, ausholen_1000: 0,096 m bei Haltung 0,57 im Gehen; die Grundbewegung hält die Axt beim Überblenden bis
		# 0,11 m neben der Faust): der Griff aus „Hieb“ gilt schon ab halber Haltung ganz, die Faust führt die Axt
		var soll := sk.get_bone_global_pose(_hand) * halt_grund.interpolate_with(halt_hieb, smoothstep(0.0, 0.5, gewicht))
		var pa := sk.get_bone_parent(_axt)
		var lokal := (sk.get_bone_global_pose(pa).affine_inverse() if pa >= 0 else Transform3D()) * soll
		sk.set_bone_pose_position(_axt, lokal.origin)
		sk.set_bone_pose_rotation(_axt, lokal.basis.get_rotation_quaternion())
