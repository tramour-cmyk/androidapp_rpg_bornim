class_name Tragen
extends SkeletonModifier3D
# 417 (Chef 31.10., 21:12: „Wenn wir unsere Waffen einfach tragen können. Beim Rennen. Und beim Gehen.“; 21:17 „wenn der Stab schwebt
# oder die Kriegsaxt schwebt, dann ist das nicht stimmig“; 21:27 „so machen, Tom soll mit Stab, Axt und Bogen anfangen“): die Waffe
# unterwegs in der Hand statt auf dem Ruecken, Tragart je Waffenklasse (Vorschlag Sokrates, ROLLE-BERATUNG „Tragart“):
#   stab:     langer Stab als Wanderstab in der rechten Faust, im Gehen steht sein Fuss am Boden und wird je Schritt umgesetzt
#             (wie Aldric, leute.gd richte_ding), im Rennen schraeg vorn in der Faust
#   schulter: Kriegsaxt, Speer geschultert: rechte Faust vor der Brust, der Schaft liegt auf der rechten Schulter, Kopf hinten oben
#   bogen:    Bogen in der linken Faust neben dem Bein, oben etwas nach aussen, der Ruecken des Bogens nach vorn
# Die UAL hat keine Tragebewegung: nach jeder Bewegung stellt dieser Knoten den tragenden Arm (zwei Knochen, Ellbogen nach hinten
# aussen) an ein Ziel vor der Brust, das mit der Brust geht; vom Armschwung der Bewegung bleibt SCHWUNG je Tragart. Die Waffe
# haengt nicht am Knochen, sondern wird danach an die Faust gestellt (Griff = Ursprung, Schaft +Y, waffen.py).

const ARTEN := {"quarterstaff": "stab", "staff": "stab", "greataxe": "schulter", "spear": "schulter", "shortbow": "bogen", "longbow": "bogen"}
# je Tragart: Seite; Faust gegen das Schultergelenk in Metern (aussen, vorn, oben; Brustrahmen); Anteil des Armschwungs (vorn-hinten)
const LAGE := {
	"stab": {"seite": "r", "faust": Vector3(0.10, 0.24, -0.34), "schwung": 0.25},
	"schulter": {"seite": "r", "faust": Vector3(0.03, 0.22, -0.26), "schwung": 0.12},
	"bogen": {"seite": "l", "faust": Vector3(0.10, 0.06, -0.47), "schwung": 0.45},
}
const STAB_VOR := 0.16        # m: so weit geht die Faust im Gehen ueber den stehenden Stabfuss hinaus, dann wird er umgesetzt
const STAB_SETZ := 0.24       # s: Umsetzen
const STAB_SETZ_VOR := 0.16   # m: so weit vor der Faust setzt er auf
const STAB_AUSSEN := 0.04     # m: Fuss des Stabs aussen von der Faust

var art := ""
var seite := "r"
var waffe: Node3D             # top_level, wird je Bild gestellt
var modell: Node3D            # Wurzel der Figur (+Z vorn, +X links, wie heldfigur.gd)
var anim: AnimationPlayer
var griff := Vector3.ZERO     # Faust im Raum des Handknochens (heldfigur.gd faust)
var achse := Vector3.UP       # Kleinfinger- zu Zeigefingerknoechel im Raum des Handknochens
var unten := 0.0              # Stab: Laenge unter dem Ursprung
var mittel := 0.0             # gleitendes Mittel des Armschwungs (vorn-hinten), m
var stab_fuss := Vector3.INF  # Welt
var stab_von := Vector3.ZERO
var stab_nach := Vector3.ZERO
var stab_t := 1.0
var zuletzt := ""             # Bewegung und Stelle im letzten Bild: die Uhr ist die Bewegung (Spiel, Film mit seek)
var stelle := 0.0
var faust_welt := Vector3.ZERO   # fuer die Messung
var schaft_welt := Vector3.UP
var fehl := 0.0                  # m: so weit liegt die Faust nach dem Stellen neben dem Ziel (Arm zu kurz)

static func art_von(base: String) -> String: return String(ARTEN.get(base, ""))

func _init(a := "", w: Node3D = null, m: Node3D = null, f := {}) -> void:
	art = a; waffe = w; modell = m
	seite = String(LAGE.get(a, {}).get("seite", "r"))
	griff = f.get("griff", Vector3.ZERO); achse = f.get("achse", Vector3.UP)
	name = "Tragen"
	if waffe:
		for mi in waffe.find_children("*", "MeshInstance3D", true, false):
			unten = maxf(unten, -(mi as MeshInstance3D).get_aabb().position.y)

func _process_modification() -> void:
	var sk := get_skeleton()
	if sk == null or modell == null or art == "": return
	var iu := sk.find_bone("upperarm_" + seite)
	var il := sk.find_bone("lowerarm_" + seite)
	var ih := sk.find_bone("hand_" + seite)
	var ic := sk.find_bone("spine_03")
	if iu < 0 or il < 0 or ih < 0 or ic < 0: return
	var bew: String = anim.assigned_animation if anim else ""
	var pos: float = anim.current_animation_position if anim and bew != "" else 0.0
	var dt := 0.0
	if bew == zuletzt and anim and bew != "":
		dt = pos - stelle
		if dt < 0.0: dt += anim.get_animation(bew).length
		dt = clampf(dt, 0.0, 0.1)
	zuletzt = bew; stelle = pos
	var G := sk.global_transform
	var mi := G.affine_inverse() * modell.global_transform
	var vorn := (mi.basis * Vector3.BACK).normalized()
	var oben := (mi.basis * Vector3.UP).normalized()
	var links := (mi.basis * Vector3.RIGHT).normalized()
	# Brustrahmen: die halbe Drehung der Brust gegen die Ruhe (Neigung im Rennen, kaum das Mitdrehen im Schritt)
	var cr := sk.get_bone_global_rest(ic).basis.orthonormalized()
	var cp := sk.get_bone_global_pose(ic).basis.orthonormalized()
	var R := Basis(Quaternion.IDENTITY.slerp((cp * cr.inverse()).get_rotation_quaternion(), 0.5))
	var vc := (R * vorn).normalized()
	var oc := (R * oben).normalized()
	var ac := (R * (-links if seite == "r" else links)).normalized()
	var S := sk.get_bone_global_pose(iu).origin
	var lage: Dictionary = LAGE[art]
	var f: Vector3 = lage["faust"]
	# Armschwung der Bewegung: Faust vor/hinter der Schulter, ohne Mittel
	var hand_a := sk.get_bone_global_pose(ih) * griff
	var sw := (hand_a - S).dot(vorn)
	mittel = sw if dt == 0.0 else lerpf(mittel, sw, clampf(dt * 1.5, 0.0, 1.0))
	var P := S + ac * f.x + vc * f.y + oc * f.z + vorn * (sw - mittel) * float(lage["schwung"])
	# Schaft (Richtung der Waffe +Y) und Faust
	var d := oc
	var geht := bew.begins_with("Gehen")
	var rennt := bew.begins_with("Rennen")
	match art:
		"stab":
			if rennt:
				d = (oc + vc * 0.45 + ac * 0.06).normalized()
				stab_fuss = Vector3.INF
			else:
				d = _stab(G, P, vorn, ac, geht, dt)
		"schulter":
			var T := S + oc * 0.115 + ac * 0.03 - vc * 0.02   # oben auf der Schulter (0,10: Stiel 1,2 cm in der Schulter, Messung 417)
			d = (T - P).normalized()
		"bogen":
			# der Unterarm haengt senkrecht ueber der Faust: ein senkrechter Bogen liefe mit dem oberen Wurfarm durch ihn (Messung 417:
			# 4,8 cm im Unterarm); wie man ihn traegt: vorn oben, hinten unten, quer zum Unterarm
			d = (oc * 0.6 + vc * 0.8 + ac * 0.08).normalized()
	_arm(sk, iu, il, ih, P, d, vc, oc, ac)
	# Waffe an die Faust
	var hg := sk.get_bone_global_pose(ih)
	var pf := hg * griff
	faust_welt = G * pf
	fehl = pf.distance_to(P)
	var dw := (G.basis * d).normalized()
	schaft_welt = dw
	if waffe == null: return
	var x: Vector3
	match art:
		"bogen": x = G.basis * -vc              # Ruecken des Bogens nach hinten, die Sehne vorn (hinten schnitt sie den Unterarm, Messung 417)
		_: x = G.basis * ac                      # Schneide, Blatt nach aussen
	x = (x - dw * x.dot(dw)).normalized()
	waffe.global_basis = Basis(x, dw, x.cross(dw))
	var o := faust_welt
	if art == "stab":
		if stab_fuss != Vector3.INF: o = stab_fuss + dw * unten   # der Schaft laeuft durch die Faust, der Fuss steht
		else: o = faust_welt + dw * 0.18                          # im Rennen unter der Mitte gefasst
	waffe.global_position = o

# Wanderstab: Fuss am Boden (Welt), im Gehen umgesetzt, wenn die Faust STAB_VOR darueber hinaus ist; Ergebnis Richtung im Skelettraum
func _stab(G: Transform3D, P: Vector3, vorn: Vector3, ac: Vector3, geht: bool, dt: float) -> Vector3:
	var pw := G * P
	var vw := (G.basis * vorn).normalized(); vw.y = 0; vw = vw.normalized()
	var aw := (G.basis * ac); aw.y = 0; aw = aw.normalized()
	var boden := modell.global_position.y
	var ruhe := Vector3(pw.x, boden, pw.z) + aw * STAB_AUSSEN + vw * 0.03
	if stab_fuss == Vector3.INF:
		stab_fuss = ruhe; stab_nach = ruhe; stab_t = 1.0
	if stab_t >= 1.0:
		var neu := Vector3.INF
		if geht and (pw - stab_fuss).dot(vw) > STAB_VOR: neu = ruhe + vw * STAB_SETZ_VOR
		elif not geht and stab_fuss.distance_to(ruhe) > 0.05: neu = ruhe
		if neu != Vector3.INF:
			stab_von = stab_fuss; stab_nach = neu; stab_t = 0.0
	if stab_t < 1.0:
		if geht: stab_nach = ruhe + vw * STAB_SETZ_VOR
		stab_t = minf(1.0, stab_t + dt / STAB_SETZ)
		stab_fuss = stab_von.lerp(stab_nach, smoothstep(0.0, 1.0, stab_t)) + Vector3.UP * 0.07 * sin(PI * stab_t)
	var y := pw - stab_fuss
	y.y = maxf(y.y, 0.5)
	return (G.basis.inverse() * y.normalized()).normalized()

# Zwei Knochen: Oberarm und Unterarm so, dass die Faust (griff) auf P liegt und Kleinfinger-Zeigefinger laengs d; Ellbogen nach
# hinten aussen unten. Zweimal, weil die Handlage den Handgelenkpunkt verschiebt.
func _arm(sk: Skeleton3D, iu: int, il: int, ih: int, P: Vector3, d: Vector3, vc: Vector3, oc: Vector3, ac: Vector3) -> void:
	var l1 := sk.get_bone_rest(il).origin.length()
	var l2 := sk.get_bone_rest(ih).origin.length()
	var pol := (-vc * 0.6 + ac * 0.5 - oc * 0.4).normalized()
	for _i in 2:
		var hb := sk.get_bone_global_pose(ih).basis.orthonormalized()
		var hz := _richte(hb, (hb * achse).normalized(), d)   # Hand gedreht, bis die Faust laengs des Schafts liegt
		var W := P - hz * griff
		var A := sk.get_bone_global_pose(iu).origin
		var dv := W - A
		var dist := clampf(dv.length(), absf(l1 - l2) + 0.01, (l1 + l2) * 0.995)
		var dir := dv.normalized()
		var ca := clampf((l1 * l1 + dist * dist - l2 * l2) / (2.0 * l1 * dist), -1.0, 1.0)
		var q := (pol - dir * pol.dot(dir))
		q = q.normalized() if q.length() > 1e-4 else oc.cross(dir).normalized()
		var E := A + dir * (l1 * ca) + q * (l1 * sqrt(maxf(0.0, 1.0 - ca * ca)))
		_zeige(sk, iu, il, E)
		_zeige(sk, il, ih, A + dir * dist)
		var hp := sk.get_bone_global_pose(sk.get_bone_parent(ih)).basis.orthonormalized()
		hb = sk.get_bone_global_pose(ih).basis.orthonormalized()
		hz = _richte(hb, (hb * achse).normalized(), d)
		sk.set_bone_pose_rotation(ih, (hp.inverse() * hz).get_rotation_quaternion())

# kleinste Drehung von b, die den Vektor von (Bild von b) auf nach dreht
static func _richte(b: Basis, von: Vector3, nach: Vector3) -> Basis:
	var ax := von.cross(nach)
	var w := atan2(ax.length(), von.dot(nach))
	if ax.length() < 1e-6: return b
	return Basis(ax.normalized(), w) * b

# Knochen i so drehen, dass sein Kind k (Ursprung) auf Z zeigt
static func _zeige(sk: Skeleton3D, i: int, k: int, Z: Vector3) -> void:
	var g := sk.get_bone_global_pose(i)
	var von := (sk.get_bone_global_pose(k).origin - g.origin).normalized()
	var nach := (Z - g.origin).normalized()
	var nb := _richte(g.basis.orthonormalized(), von, nach)
	var p := sk.get_bone_parent(i)
	var pb := sk.get_bone_global_pose(p).basis.orthonormalized() if p >= 0 else Basis.IDENTITY
	sk.set_bone_pose_rotation(i, (pb.inverse() * nb).get_rotation_quaternion())
