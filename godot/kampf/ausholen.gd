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
	return not _spuren.is_empty()


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
	for s in _spuren:
		var b: int = s[0]
		var q := hieb.rotation_track_interpolate(s[1], t)
		sk.set_bone_pose_rotation(b, sk.get_bone_pose_rotation(b).slerp(q, gewicht))
		if s[2] >= 0:
			sk.set_bone_pose_position(b, sk.get_bone_pose_position(b).lerp(hieb.position_track_interpolate(s[2], t), gewicht))
