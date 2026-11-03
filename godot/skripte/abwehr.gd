class_name Abwehr
extends SkeletonModifier3D
# 531 (Chef 03.11., 23:42, Build 249: „vertreibt keine Mobs“): wie alt (WorldScreen lastWardOff, MapFolk.wardAt, 09.10.) nimmt
# Garrick die Fackel aus dem Feuer, wenn ein Tier am Schutzort aufgibt (herde.gd abgewehrt), dreht sich zu ihm, haelt sie hoch und
# schwenkt sie links und rechts, dann zurueck ins Feuer. Zeiten wie alt: 0,45 s greifen, bis 0,7 s hoch, bis 2,9 s Schwuenge alle
# 0,28 s, bis 3,25 s halten, bis 3,7 s zurueck. Als Schicht ueber seiner Ruhebewegung, nur rechter Ober- und Unterarm; die Fackel
# (Held.fackelkopf) folgt der Hand. Die Bewegung ist neu: Aussehen urteilt der Chef (373).

const DAUER := 3.7
const GREIFEN := 0.45
const HOCH := 0.7
const SCHWUNG_BIS := 2.9
const HALTEN_BIS := 3.25
const SCHWUNG_S := 0.28           # je Seite
const OBERARM_HEBEN := 30.0       # Grad ueber der Waagerechten, zum Tier hin
const UNTERARM_HEBEN := 62.0      # Grad: die Fackel steigt vor ihm auf
const QUER := 0.42                # Anteil seitlich beim Schwung (etwa 23 Grad)
const AUSSEN := 0.45              # Pruefer Lauf 1 (Bild 2, 3: Fackel 2-5 cm an der Kapuze): Arm nach rechts aussen, Fackel vom Kopf weg

var t := -1.0                     # s seit Beginn; < 0: aus
var ziel := Vector3.ZERO          # Welt: wo das Tier stand
var fackel: Node3D                # Stiel, Flamme, Licht (Held.fackelkopf), Kind der Person
var licht: OmniLight3D
var nacht_k := 0.0
var _ob := -1
var _ub := -1
var _hb := -1

func los(wo: Vector3) -> void:
	ziel = wo
	t = 0.0

func laeuft() -> bool: return t >= 0.0 and t < DAUER

## schaut er gerade zum Tier (alt faceBeast)?
func zum_tier() -> bool: return t >= GREIFEN and t < HALTEN_BIS

## wie weit der Arm oben ist, 0..1, weich
func gewicht() -> float:
	if t < 0.0 or t >= DAUER: return 0.0
	var w: float
	if t < GREIFEN: w = 0.45 * t / GREIFEN
	elif t < HOCH: w = 0.45 + 0.55 * (t - GREIFEN) / (HOCH - GREIFEN)
	elif t < HALTEN_BIS: w = 1.0
	else: w = 1.0 - (t - HALTEN_BIS) / (DAUER - HALTEN_BIS)
	return smoothstep(0.0, 1.0, w)

## seitlich: -1 links, +1 rechts, weich zwischen den Schwuengen
func schwung() -> float:
	if t < HOCH or t >= SCHWUNG_BIS: return 0.0
	var u := (t - HOCH) / SCHWUNG_S
	var k := clampf((SCHWUNG_BIS - t) / 0.2, 0.0, 1.0) * clampf((t - HOCH) / 0.15, 0.0, 1.0)
	return sin(u * PI) * k

func _process_modification_with_delta(delta: float) -> void:
	if t < 0.0: return
	t += maxf(delta, 0.0)
	var sk := get_skeleton()
	if fackel: fackel.visible = laeuft()
	if not laeuft() or sk == null:
		if t >= DAUER: t = -1.0
		return
	if _ob < 0:
		_ob = sk.find_bone("upperarm_r"); _ub = sk.find_bone("lowerarm_r"); _hb = sk.find_bone("hand_r")
	if _ob < 0 or _ub < 0 or _hb < 0: return
	var w := gewicht()
	var oben: Vector3 = (sk.global_basis.inverse() * Vector3.UP).normalized()
	var schulter := sk.get_bone_global_pose(_ob).origin
	var zu: Vector3 = sk.global_transform.affine_inverse() * ziel - schulter
	zu = zu - oben * zu.dot(oben)
	if zu.length() < 0.01: zu = sk.global_basis.inverse() * (sk.global_basis.z)
	var vorn := zu.normalized()
	var quer := vorn.cross(oben).normalized()
	var seit := vorn + quer * QUER * schwung()
	seit = seit.normalized()
	var aussen := (seit + quer * AUSSEN).normalized()   # quer = rechte Seite der Figur (sie blickt nach vorn, links ist oben x vorn)
	_richte(sk, _ob, _ub, aussen * cos(deg_to_rad(OBERARM_HEBEN)) + oben * sin(deg_to_rad(OBERARM_HEBEN)), w)
	var unter := (aussen * cos(deg_to_rad(UNTERARM_HEBEN)) + oben * sin(deg_to_rad(UNTERARM_HEBEN))).normalized()
	_richte(sk, _ub, _hb, unter, w)
	if fackel:
		var hand := sk.global_transform * sk.get_bone_global_pose(_hb)
		var y: Vector3 = (sk.global_basis * unter.lerp(oben, 0.35)).normalized()
		var x: Vector3 = (sk.global_basis * quer).normalized()
		x = (x - y * x.dot(y)).normalized()
		fackel.global_transform = Transform3D(Basis(x, y, x.cross(y)), hand.origin + y * 0.03)
	if licht: licht.light_energy = (0.5 + 1.9 * nacht_k) * (0.88 + 0.08 * sin(t * 19.0) + 0.04 * randf())

## Knochen b so drehen, dass er (zum Kind k hin) in Richtung d zeigt, mit Anteil w
func _richte(sk: Skeleton3D, b: int, k: int, d: Vector3, w: float) -> void:
	var g := sk.get_bone_global_pose(b)
	var jetzt := sk.get_bone_global_pose(k).origin - g.origin
	if jetzt.length() < 1e-4 or d.length() < 1e-4: return
	var q := Quaternion(jetzt.normalized(), d.normalized())
	q = Quaternion.IDENTITY.slerp(q, w)
	g.basis = Basis(q) * g.basis
	sk.set_bone_global_pose(b, g)

## die Fackel an die Person p haengen (unsichtbar bis zur Abwehr)
static func baue(sk: Skeleton3D, p: Node3D) -> Abwehr:
	var a := Abwehr.new()
	a.name = "Abwehr"
	sk.add_child(a)
	var f := Node3D.new()
	f.name = "AbwehrFackel"
	f.top_level = true
	p.add_child(f)
	var teile := Held.fackelkopf(f)
	a.fackel = f
	a.licht = teile[1]
	a.licht.set_meta("reich", 4.0)   # 348.13b: Tusche nach der Fackel wie beim Helden
	a.licht.set_meta("kraft", 1.0)
	a.licht.add_to_group("tuschelicht")
	f.visible = false
	return a
