class_name Tragen
extends SkeletonModifier3D
# 417 (Chef 31.10., 21:12: „Wenn wir unsere Waffen einfach tragen können. Beim Rennen. Und beim Gehen.“; 21:17 „wenn der Stab schwebt
# oder die Kriegsaxt schwebt, dann ist das nicht stimmig“; 21:27 „so machen, Tom soll mit Stab, Axt und Bogen anfangen“): die Waffe
# unterwegs in der Hand statt auf dem Ruecken, Tragart je Waffenklasse (Vorschlag Sokrates, ROLLE-BERATUNG „Tragart“):
#   stab:     langer Stab als Wanderstab in der rechten Faust, im Gehen steht sein Fuss am Boden und wird je Schritt umgesetzt
#             (wie Aldric, leute.gd richte_ding), im Rennen schraeg vorn in der Faust
#   schulter: Kriegsaxt, Speer geschultert: rechte Faust vor der Brust, der Schaft liegt auf der rechten Schulter, Kopf hinten, Blatt haengt
#   bogen:    Bogen in der linken Faust neben dem Bein, oben etwas nach aussen, der Ruecken des Bogens nach vorn
# Die UAL hat keine Tragebewegung: nach jeder Bewegung stellt dieser Knoten den tragenden Arm (zwei Knochen, Ellbogen nach hinten
# aussen) an ein Ziel vor der Brust, das mit der Brust geht; vom Armschwung der Bewegung bleibt SCHWUNG je Tragart. Die Waffe
# haengt nicht am Knochen, sondern wird danach an die Faust gestellt (Griff = Ursprung, Schaft +Y, waffen.py).

const ARTEN := {"quarterstaff": "stab", "staff": "stab", "greataxe": "schulter", "spear": "schulter", "shortbow": "bogen", "longbow": "bogen"}
# je Tragart: Seite; Faust gegen das Schultergelenk in Metern (aussen, vorn, oben; Brustrahmen); Anteil des Armschwungs (vorn-hinten)
const LAGE := {
	"stab": {"seite": "r", "faust": Vector3(0.10, 0.24, -0.34), "schwung": 0.25},
	"schulter": {"seite": "r", "faust": Vector3(0.06, 0.35, -0.12), "schwung": 0.12},
	"bogen": {"seite": "l", "faust": Vector3(0.10, 0.06, -0.43), "schwung": 0.45},
}
const STAB_VOR := 0.16        # m: so weit geht die Faust im Gehen ueber den stehenden Stabfuss hinaus, dann wird er umgesetzt
const STAB_SETZ := 0.24       # s: Umsetzen
const STAB_SETZ_VOR := 0.16   # m: so weit vor der Faust setzt er auf
const STAB_AUSSEN := 0.04     # m: Fuss des Stabs aussen von der Faust
# Axt: Griff in m unter dem Ursprung von waffen.py (Kopf 0,80 darueber). Runde 2 0,40 am Stielende (in der Mitte stiess das untere Ende
# in den Oberschenkel, Messung 417: 5 cm in 26 von 40 Bildern). Runde 3 (Chef 01.11., 11:32: „die Schwerkraft sorgt dafür, dass ... der
# Axtkopf nach unten geht ... ein bisschen weiter nach vorne ziehen, damit es gemütlicher zum Tragen ist"): die Axt weiter vorn gefasst,
# der Kopf naeher hinter der Schulter und tiefer; das Blatt haengt nach unten statt nach oben (axt_haengt)
const AXT_GRIFF := 0.15

var art := ""
var gang := ""                # 417 Runde 4: Paketbewegung (gang_von); leer: Tragart von Hand wie Runde 3
var seite := "r"
var waffe: Node3D             # top_level, wird je Bild gestellt
var modell: Node3D            # Wurzel der Figur (+Z vorn, +X links, wie heldfigur.gd)
var anim: AnimationPlayer
var griff := Vector3.ZERO     # Faust im Raum des Handknochens (heldfigur.gd faust)
var halt := {}                # 653: Maße des Gegenstands (Halt.gegenstand): Griff, Schaft, Schneide aus dem Modell statt Modellregel 4
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
var merken := false             # Messung (tests/tragen_417.gd): Posen aller Knochen am Ende jeder Aenderung, Skelettraum;
var posen: Array[Transform3D] = []   # ausserhalb der Aenderung liefert get_bone_global_pose die Pose ohne diesen Knoten
var faust_weite := 0.0          # m: Knoechel bis Mittelglieder quer zum Schaft (geschlossene Faust: etwa Schaftdicke plus Finger)
var fehl := 0.0                  # m: so weit liegt die Faust nach dem Stellen neben dem Ziel (Arm zu kurz)
var axt_griff := AXT_GRIFF        # Probe 417 Runde 3 (tragprobe.gd): Fassungen nebeneinander
var axt_haengt := true            # Blatt nach unten (Runde 3); false: Schneide oben wie Runde 2
var zwei_winkel := 0.0            # Messung: Grad zwischen Schaft durch beide Faeuste und der Achse der rechten Hand

static func art_von(base: String) -> String: return String(ARTEN.get(base, ""))

# 417 Runde 4 (Chef 01.11., 12:21, Axt Runde 3 „schwebt“; 348.12c): Gehen und Rennen je Waffe aus den Protofactor-Paketen
# (waffengang.py, bewegungen.bin „Gehen_<gang>“, „Rennen_<gang>“). Die Bewegung fuehrt Arm und Hand; dieser Knoten stellt nur die Waffe
# in die Faust (Schaft laengs Kleinfinger-Zeigefinger der Hand, wie die Bewegung sie haelt). Stab bleibt beim Wanderstab (Runde 2 passt).
const GANG_ZWEI :=["greatsword", "greataxe", "maul", "halberd"]
const GANG_BOGEN := ["shortbow", "longbow", "light_crossbow"]
static func gang_von(base: String, schild: bool) -> String:
	if base == "" or ARTEN.get(base, "") == "stab": return ""
	if base in GANG_BOGEN: return "bogen"
	if base in GANG_ZWEI or (base == "spear" and not schild): return "axt"
	return "schild" if schild else "einhand"

# 499 (Chef 03.11., 07:14, Drehteller: „da schwebt das Schild … und über dem Schild schwebt dann das Schwert“): die Waffe ist top_level
# und erbte den Massstab der Figur nicht; der Drehteller verkleinert sie (0,68: Stab 1,48-fach, 22 cm neben der Faust). Waffe und alle
# Abstaende in der Welt gehen mit dem Massstab der Figur (im Spiel 1)
func mass() -> float:
	return modell.global_basis.get_scale().y if modell and modell.is_inside_tree() else 1.0

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
	if sk == null or modell == null or (art == "" and gang == ""): return
	if gang == "schildarm":
		_schildarm(sk)
		return
	var iu := sk.find_bone("upperarm_" + seite)
	var il := sk.find_bone("lowerarm_" + seite)
	var ih := sk.find_bone("hand_" + seite)
	var ic := sk.find_bone("spine_03")
	if iu < 0 or il < 0 or ih < 0 or ic < 0: return
	var bew: String = anim.assigned_animation if anim else ""
	if gang != "":
		_paket(sk, ih)
		return
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
				d = (oc + vc * 0.30 - ac * 0.08).normalized()   # unten etwas nach aussen (+0,06: 0,6 cm am Oberschenkel, +0,14: 5 cm im Becken); Pruefer 417: bei 0,45 „wie eine Lanze, eher Angriff als Tragen“
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
			if rennt: d = (oc * 0.35 + vc * 0.94 + ac * 0.08).normalized()   # Messung 417: im Rennen schwingt der Unterarm vor, 5 cm im Bogen
	_arm(sk, iu, il, ih, P, d, vc, oc, ac)
	var mitte := _faust_zu(sk, ih, d)
	# Waffe an die Faust
	var hg := sk.get_bone_global_pose(ih)
	var pf := hg * griff
	faust_welt = G * pf
	fehl = pf.distance_to(P)
	if merken:
		posen.resize(sk.get_bone_count())
		for i in sk.get_bone_count(): posen[i] = sk.get_bone_global_pose(i)
	var dw := (G.basis * d).normalized()
	schaft_welt = dw
	if waffe == null: return
	var x: Vector3
	match art:
		"bogen": x = G.basis * -vc              # Ruecken des Bogens nach hinten, die Sehne vorn (hinten schnitt sie den Unterarm, Messung 417)
		"schulter": x = G.basis * (-oc if axt_haengt else oc)   # Blatt laengs des Koerpers: von der Seite als Blatt zu sehen (Pruefer 417:
		                                          # nach aussen sah man von der Seite nur die Kante, „wie ein Speer“); Runde 3 haengt es nach unten
		_: x = G.basis * ac                      # Schneide, Blatt nach aussen
	x = (x - dw * x.dot(dw)).normalized()
	var ms := mass()
	var o := G * mitte   # Mitte der geschlossenen Faust (Pruefer 417: an den Knoecheln lag die Hand nur auf)
	if art == "stab":
		if stab_fuss != Vector3.INF: o = stab_fuss + dw * unten * ms   # der Schaft laeuft durch die Faust, der Fuss steht
		else: o = G * mitte + dw * 0.18 * ms                           # im Rennen unter der Mitte gefasst
	elif art == "schulter": o = G * mitte + dw * axt_griff * ms
	_stelle(x, dw, o)

# 653 (Chef 10.11., 14:22 „653 passt“): die Waffe an ihren Platz, Lage = Ziel · Griffrahmen⁻¹ (Halt.lage): Ziel y = Schaft [dw],
# z = wohin Modell +X zeigt (Schneide, beim Bogen der Ruecken) [z], Ursprung am Griff [o] (Welt). Ohne Maße wie Modellregel 4
# (Griff = Ursprung, Schaft +Y)
func _stelle(z: Vector3, dw: Vector3, o: Vector3) -> void:
	var ms := mass()
	if halt.is_empty():
		waffe.global_basis = Basis(z, dw, z.cross(dw)).scaled(Vector3.ONE * ms)
		waffe.global_position = o
		return
	# z ist hier die Richtung von Modell +X (Schneide, beim Bogen der Ruecken, waffen.py); Halt nennt beim Bogen die Seite der Sehne
	# „vorn“: Griff und Schaft aus Halt, die Drehung um den Schaft wie Modellregel 4
	var m := halt.duplicate()
	m["vorn"] = Vector3.RIGHT
	var ziel := Transform3D(Basis(dw.cross(z), dw, z).scaled(Vector3.ONE * ms), o)
	waffe.global_transform = ziel * Halt.griff_rahmen(m).affine_inverse()

# 417 Runde 5 (Pruefer 13:3x: Schwert durch Schild, Schild vor Brust und Gesicht, Bogen im Becken): die Waffe so in der Hand, wie die
# Hersteller der Pakete sie in ihren Unity-Prefabs an die Hand haengen (Messung 3f, griff417b.py, Lauf 41310719427), umgerechnet in den
# Rahmen der Hand: x Handgelenk -> Mittelfinger, y quer ueber die Knoechel (Kleinfinger -> Zeigefinger), z = x kreuz y; Laengen in
# Handlaengen (Handgelenk bis Mittelfinger). Den Rahmen gleicht zauber385.py zwischen Paket und Kaufkoerper ab, darum gilt die Lage hier.
# Befund: Zweihaender, Keule und Schwert liegen alle drei gleich, Achse (0,26, 0,96, 0,02), also laengs der Knoechel, etwas zu den Fingern
# geneigt; der Schaft laeuft 0,33 Handlaengen innen (Handflaeche) durch die Faust. Bogen links ebenso laengs der Knoechel; der Schild
# links liegt mit der Flaeche am Handruecken (Normale -z), Mitte am Handgelenk.
const GRIFF_ACHSE := Vector3(0.26, 0.96, 0.02)          # Waffe rechts, zur Spitze (Modell +Y)
const GRIFF_PUNKT := Vector3(0.99, -0.09, -0.33)        # Griff (Modell-Ursprung) rechts
const BOGEN_ACHSE := Vector3(-0.44, -0.90, 0.05)        # Bogen links, Wurfarme (Modell +Y)
const BOGEN_PUNKT := Vector3(0.99, -0.09, 0.33)         # links ist der Rahmen gespiegelt: innen ist +z
const SCHILD_NORMALE := Vector3(0.22, -0.07, -0.97)     # Schild links, Vorderseite (Modell +Z)
const SCHILD_PUNKT := Vector3(-0.18, -0.06, -0.35)      # Fessel (Modell-Ursprung) am Handgelenk, am Handruecken
# 417 Runde 6 (Lauf 41322461393): Zweihaender im Rennen mit dem Stielende 4,9 cm in der linken Wade, die linke Faust 6,5 cm neben dem
# Schaft: die Bewegung fuehrt den Schaft mit beiden Haenden, die Achse der rechten Hand allein trifft die linke nicht. Der Schaft laeuft
# darum durch beide Faeuste (links wie der Bogen: innen +z), hoechstens ZWEI_HOECHST Grad von der Achse der rechten Hand.
const ZWEI_LINKS := Vector3(0.99, -0.09, 0.33)
const ZWEI_HOECHST := 30.0
# Lauf 41324326151: ganz durch beide Faeuste (Anteil 1) steht der Stiel steiler, das Ende in 11 von 15 Bildern zwischen den Beinen
# (vorher 3). Anteil der Drehung zur linken Faust und Verschieben der Axt laengs des Schafts zur Spitze (m: die Faeuste fassen naeher am
# Stielende), Fassungen in tests/tragen_pakete_417.gd. Lauf 41326853378: nur Anteil 1 mit 0,25 m ist frei (Rennen 0 von 15, Oberschenkel
# 0,1 cm) und haelt die linke Faust am Schaft (0,6 cm); Anteil 0,5 liess sie 5,4 cm daneben, 0,15 m stiess 4,9 cm in den Oberschenkel.
# Lauf 41328184986: 0,30 m mit mehr Luft (Rennen 3,0 cm, Gehen 8,5 cm), darum 0,30
var zwei_anteil := 1.0
var zwei_schieben := 0.30
# Schwert mit Schild: im Rennen fuehrt die Bewegung die rechte Faust 5 cm durch den rechten Oberschenkel; der Oberarm geht dafuer
# immer (auch im Gehen, damit beim Wechsel nichts springt) schwert_abspreiz Grad nach aussen. Lauf 41356789633 (Becken nach Beinlaenge):
# 9 Grad liess den Knauf im Rennen in 1 von 15 Bildern 4,9 cm in den rechten Oberschenkel; Lauf 41359533716: 12 Grad frei 6,0 cm,
# 15 Grad 7,0, 18 Grad 8,0 (Gehen ueberall frei, Schluesselbein 2,0-4,0). 15 fuer Luft bei kraeftiger Statur
var schwert_abspreiz := 15.0
# 417 Runde 5 (Lauf 41350556171): das entspannte Paketgehen WalkNormal2S&S fuehrt den linken Arm dicht am Koerper, der untere Schildrand
# lag in 5 von 15 Bildern bis 5 cm in Ruecken (spine_03) und linkem Oberschenkel. Der Schildarm geht darum immer (kein Sprung beim
# Wechsel) schild_abspreiz Grad nach aussen; Fassungen in tests/tragen_pakete_417.gd (SCHILD_FASSUNGEN). Lauf 41355090887 (Gehen):
# 0 Grad 5 von 15 Bildern bis -5,0 cm, 5 Grad 2 Bilder -4,9, 8 Grad frei 3,9 cm, 12 Grad frei 6,3 (Oberschenkel 9,1), 16 Grad 6,3;
# Rennen bei allen frei. 12 statt 8: Luft fuer kraeftige Statur (gemessen nur normal)
var schild_abspreiz := 12.0

# Rahmen der Hand im Skelettraum: Basis aus x, y, z je mal Handlaenge, Ursprung am Handgelenk (wie zauber385.py rahmen)
static func hand_rahmen(sk: Skeleton3D, s: String) -> Transform3D:
	var ih := sk.find_bone("hand_" + s); var im := sk.find_bone("middle_01_" + s)
	var ii := sk.find_bone("index_01_" + s); var ip := sk.find_bone("pinky_01_" + s)
	if ih < 0 or im < 0 or ii < 0 or ip < 0: return Transform3D()
	var h := sk.get_bone_global_pose(ih).origin
	var d := sk.get_bone_global_pose(im).origin - h
	var x := d.normalized()
	var z := x.cross(sk.get_bone_global_pose(ii).origin - sk.get_bone_global_pose(ip).origin).normalized()
	var y := z.cross(x)
	var l := d.length()
	return Transform3D(Basis(x * l, y * l, z * l), h)

# Waffe in die Faust: Y laengs der gemessenen Achse, X (Schneide, beim Bogen der Ruecken zum Ziel) zu den Fingern hin, quer zur Achse
func _paket(sk: Skeleton3D, ih: int) -> void:
	var G := sk.global_transform
	var R := hand_rahmen(sk, seite)
	var bogen := gang == "bogen"
	if gang == "schild": _abspreizen(sk, ih, schwert_abspreiz)
	R = hand_rahmen(sk, seite)
	var d := (R.basis * (BOGEN_ACHSE if bogen else GRIFF_ACHSE)).normalized()
	zwei_winkel = 0.0
	if gang == "axt" and seite == "r":
		var RL := hand_rahmen(sk, "l")
		var v := RL * ZWEI_LINKS - R * GRIFF_PUNKT
		if v.length() > 0.08:
			var dn := v.normalized() * signf(v.dot(d))
			var w := rad_to_deg(d.angle_to(dn))
			var wz := minf(w, ZWEI_HOECHST) * zwei_anteil
			if w > 1e-3: dn = d.slerp(dn, wz / w).normalized()
			zwei_winkel = wz
			d = dn
	var _mitte := _faust_zu(sk, ih, d)
	R = hand_rahmen(sk, seite)
	var p := R * (BOGEN_PUNKT if bogen else GRIFF_PUNKT)
	var dw := (G.basis * d).normalized()
	schaft_welt = dw
	faust_welt = G * p
	if merken:
		posen.resize(sk.get_bone_count())
		for i in sk.get_bone_count(): posen[i] = sk.get_bone_global_pose(i)
	if waffe == null: return
	var x := (G.basis * R.basis.x).normalized()
	x = (x - dw * x.dot(dw)).normalized()
	_stelle(x, dw, G * p + (dw * zwei_schieben * mass() if gang == "axt" else Vector3.ZERO))

# Oberarm um die Vorwaertsachse der Figur nach aussen, die Faust weg vom Bein (rechts schwert_abspreiz, links schild_abspreiz)
func _abspreizen(sk: Skeleton3D, ih: int, grad: float) -> void:
	var iu := sk.find_bone("upperarm_" + seite)
	if iu < 0 or modell == null: return
	var mi := sk.global_transform.affine_inverse() * modell.global_transform
	var vorn := (mi.basis * Vector3.BACK).normalized()
	var aussen := (mi.basis * (Vector3.LEFT if seite == "r" else Vector3.RIGHT)).normalized()
	var g := sk.get_bone_global_pose(iu)
	var r := sk.get_bone_global_pose(ih).origin - g.origin
	var w := deg_to_rad(grad) * signf(vorn.cross(r).dot(aussen))
	var nb := Basis(vorn, w) * g.basis.orthonormalized()
	var p := sk.get_bone_parent(iu)
	var pb := sk.get_bone_global_pose(p).basis.orthonormalized() if p >= 0 else Basis.IDENTITY
	sk.set_bone_pose_rotation(iu, (pb.inverse() * nb).get_rotation_quaternion())

# Schild links am Handruecken (Messung 3f): Vorderseite SCHILD_NORMALE, oben quer ueber die Knoechel (Rahmen y), Fessel am Handgelenk
func _schildarm(sk: Skeleton3D) -> void:
	if schild_abspreiz != 0.0 and waffe != null: _abspreizen(sk, sk.find_bone("hand_l"), schild_abspreiz)
	if merken:
		posen.resize(sk.get_bone_count())
		for i in sk.get_bone_count(): posen[i] = sk.get_bone_global_pose(i)
	if waffe == null: return
	var G := sk.global_transform
	var R := hand_rahmen(sk, "l")
	var z := (G.basis * (R.basis * SCHILD_NORMALE)).normalized()
	var y := (G.basis * R.basis.y).normalized()
	y = (y - z * y.dot(z)).normalized()
	if halt.is_empty():
		waffe.global_basis = Basis(y.cross(z), y, z).scaled(Vector3.ONE * mass())
		waffe.global_position = G * (R * SCHILD_PUNKT)
	else:   # 653: Schild mit Oberkante [y] und Vorderseite [z] aus Halt (Fessel, oben, vorn je Modell)
		var ziel := Transform3D(Basis(y.cross(z), y, z).scaled(Vector3.ONE * mass()), G * (R * SCHILD_PUNKT))
		waffe.global_transform = ziel * Halt.griff_rahmen(halt).affine_inverse()
	faust_welt = G * R.origin; schaft_welt = y

# Wanderstab: Fuss am Boden (Welt), im Gehen umgesetzt, wenn die Faust STAB_VOR darueber hinaus ist; Ergebnis Richtung im Skelettraum
func _stab(G: Transform3D, P: Vector3, vorn: Vector3, ac: Vector3, geht: bool, dt: float) -> Vector3:
	var pw := G * P
	var vw := (G.basis * vorn).normalized(); vw.y = 0; vw = vw.normalized()
	var aw := (G.basis * ac); aw.y = 0; aw = aw.normalized()
	var boden := modell.global_position.y
	var ms := mass()   # 499: Masse in Metern der Figur (Drehteller verkleinert sie)
	var ruhe := Vector3(pw.x, boden, pw.z) + (aw * STAB_AUSSEN + vw * 0.03) * ms
	# Pruefer 417 Runde 2 (im Film fehlte der Stab im Gehen): nach einem Sprung der Figur (Ortswechsel, Probe) stand der Fuss am alten
	# Ort, die Faust kam nie mehr ueber ihn hinaus; weiter als einen Meter weg setzt er neu an
	if stab_fuss == Vector3.INF or Vector2(stab_fuss.x - ruhe.x, stab_fuss.z - ruhe.z).length() > 1.0 * ms:
		stab_fuss = ruhe; stab_nach = ruhe; stab_t = 1.0
	if stab_t >= 1.0:
		var neu := Vector3.INF
		if geht and (pw - stab_fuss).dot(vw) > STAB_VOR * ms: neu = ruhe + vw * STAB_SETZ_VOR * ms
		elif not geht and stab_fuss.distance_to(ruhe) > 0.05 * ms: neu = ruhe
		if neu != Vector3.INF:
			stab_von = stab_fuss; stab_nach = neu; stab_t = 0.0
	if stab_t < 1.0:
		if geht: stab_nach = ruhe + vw * STAB_SETZ_VOR * ms
		stab_t = minf(1.0, stab_t + dt / STAB_SETZ)
		stab_fuss = stab_von.lerp(stab_nach, smoothstep(0.0, 1.0, stab_t)) + Vector3.UP * 0.07 * ms * sin(PI * stab_t)
	var y := pw - stab_fuss
	y.y = maxf(y.y, 0.5 * ms)
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

# Finger um den Schaft schliessen (die UAL laesst die Hand im Gehen offen): je Finger die drei Glieder um die Achse des Schafts
# gebeugt, zusammen FAUST_BEUGE, die Richtung, die die Fingerspitze naeher an den Schaft bringt; Ergebnis die Mitte der Faust
# (zwischen Knoecheln und Mittelgliedern, quer zum Schaft), Skelettraum
const FINGER := ["index", "middle", "ring", "pinky"]
const FAUST_BEUGE := 120.0   # Grad ueber drei Glieder (200: Mittelglieder 1,4 cm vor den Knoecheln, zu eng fuer den Schaft)
# 610 (Chef 07.11., t268: „Finger am Stab zucken ohne Unterlass“): die Richtung der Beugung wurde in jedem Bild neu geprobt; liegen
# beide Proben fast gleich weit vom Schaft, sprang sie von Bild zu Bild hin und her. Einmal je Finger gewaehlt, gilt sie, solange die
# Waffe in dieser Hand bleibt (Wechsel der Ausruestung baut einen neuen Knoten); wahl_wechsel zaehlt fuer den Test
var beuge_wahl := {}
var wahl_wechsel := 0
func _faust_zu(sk: Skeleton3D, ih: int, d: Vector3) -> Vector3:
	var hg := sk.get_bone_global_pose(ih)
	var k := hg * griff   # zwischen den Knoecheln
	var summe := Vector3.ZERO
	var n := 0
	for f in FINGER:
		var kette: Array[int] = []
		for g in ["_01_", "_02_", "_03_"]:
			var i := sk.find_bone(f + g + seite)
			if i >= 0: kette.append(i)
		if kette.size() < 2: continue
		for i in kette: sk.set_bone_pose_rotation(i, sk.get_bone_rest(i).basis.get_rotation_quaternion())   # von der Ruhe aus, nicht vom Schwung der Bewegung
		var spitze := func() -> Vector3:
			var l := kette[-1]
			var ch := sk.get_bone_children(l)
			var gl := sk.get_bone_global_pose(l)
			return sk.get_bone_global_pose(ch[0]).origin if ch.size() > 0 else gl * (sk.get_bone_rest(l).origin * 0.8 + Vector3(0, 0.02, 0))
		# Richtung der Beugung: die, bei der die Spitze nach einem kleinen Probeschritt naeher an der Schaftlinie liegt
		var vorher: Vector3 = spitze.call()
		_beuge(sk, kette[0], d, 10.0)
		var plus: Vector3 = spitze.call()
		_beuge(sk, kette[0], d, -20.0)
		var minus: Vector3 = spitze.call()
		_beuge(sk, kette[0], d, 10.0)
		var ab := func(q: Vector3) -> float:
			var r := q - k
			return (r - d * r.dot(d)).length()
		var vz := 1.0 if ab.call(plus) < ab.call(minus) else -1.0
		# 610: beide Proben lagen fast gleich weit vom Schaft (gemessen finger_610: die Wahl wechselte im Stehen 120-mal in 150 Bildern,
		# die Spitzen sprangen 11 cm). Richtig ist die Beugung zur Handflaeche, auf der Seite des Daumens (gemessen: +3,2 cm zur
		# Handflaeche, die andere -2,9 cm, also nach hinten)
		var flaeche := _handflaeche(sk, ih, kette[0])
		if flaeche != Vector3.ZERO: vz = 1.0 if (plus - minus).dot(flaeche) > 0.0 else -1.0
		if beuge_wahl.has(f) and beuge_wahl[f] != vz: wahl_wechsel += 1
		vz = beuge_wahl.get(f, vz)
		beuge_wahl[f] = vz
		for i in kette: _beuge(sk, i, d, vz * FAUST_BEUGE / kette.size())
		if kette.size() >= 2:
			summe += sk.get_bone_global_pose(kette[1]).origin
			n += 1
	if n == 0: return k
	var q := summe / n - k
	faust_weite = (q - d * q.dot(d)).length()
	var m := (k + summe / n) * 0.5
	return k + (m - k) - d * (m - k).dot(d)   # nur quer zum Schaft verschoben, laengs bleibt der Griff

# 610: Richtung zur Handflaeche (Skelettraum): vom Handknochen zum Daumenansatz, quer zum Finger; ZERO ohne Daumen
func _handflaeche(sk: Skeleton3D, ih: int, finger: int) -> Vector3:
	var di := sk.find_bone("thumb_01_" + seite)
	if di < 0: return Vector3.ZERO
	var h := sk.get_bone_global_pose(ih).origin
	var lang := (sk.get_bone_global_pose(finger).origin - h).normalized()
	var q := sk.get_bone_global_pose(di).origin - h
	q -= lang * q.dot(lang)
	return q.normalized() if q.length() > 0.001 else Vector3.ZERO

# Knochen i um die Achse a (Skelettraum) um w Grad drehen, Kinder folgen
static func _beuge(sk: Skeleton3D, i: int, a: Vector3, w: float) -> void:
	var g := sk.get_bone_global_pose(i)
	var nb := Basis(a.normalized(), deg_to_rad(w)) * g.basis.orthonormalized()
	var p := sk.get_bone_parent(i)
	var pb := sk.get_bone_global_pose(p).basis.orthonormalized() if p >= 0 else Basis.IDENTITY
	sk.set_bone_pose_rotation(i, (pb.inverse() * nb).get_rotation_quaternion())

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
