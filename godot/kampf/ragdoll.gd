# 1215 (Chef 13.11., 16:25: „eine Richtung mitgeben auf ein Modell und dann den letzten Tick die Physik übernehmen lassen … es kommt
# ein Schlag von rechts … den schieben wir noch ein bisschen nach rechts und dann lassen wir ihn physisch richtig zusammenbrechen“;
# 15.11., 10:56 zum ersten Film: „völliger Fleischklumpen“; 11:21, 1215a A: ein Sterben für alle Körper und Todesarten).
#
# Physikalisches Sterben. Die gebackene Sterbebewegung (die zur Richtung des Treffers passt) gibt die Richtung; nach VORLAUF ihrer
# Länge übernehmen starre Körper je Glied, mit der Geschwindigkeit, die das Glied in der Bewegung gerade hat (kein Ruck), dazu der
# Stoß des Treffers. Die Gelenke halten am Anfang noch etwas (Spannung), dann erschlafft der Körper; liegt er, bleibt die Lage.
#
# Anders als die erste Probe (PhysicalBone3D): Körper und Gelenke sind eigene Knoten und Gelenke des Physikservers, verbunden nach
# der Tafel GLIEDER (nicht nach den Eltern im Gerüst: im eigenen Gerüst hängen Becken und Hüftknochen nebeneinander an der Wurzel,
# die Beine hingen in der ersten Probe an nichts, gemessen tod_ragdoll_1215). Jeder Knochen gehört einem Glied (dem nächsten über
# ihm, sonst dem Becken) und geht starr mit ihm mit; kein Knochen bleibt stehen, die Haut reißt nicht aus. Größe der Körper aus dem
# Netz (Ecken je Glied), darum liegt die Haut auf dem Boden und nicht darin.
extends Node

## Anteil der Sterbebewegung, nach dem die Physik übernimmt (mindestens VORLAUF_MIN_S: die Überblendung in die Sterbebewegung)
const VORLAUF := 0.22
const VORLAUF_MIN_S := 0.16
## spätestens dann liegt er (s nach der Übernahme); still: alle Glieder langsamer als das (m/s je m Größe und rad/s), so lange (s)
const LIEGEN_S := 6.0
const STILL_MPS := 0.06
const STILL_RAD := 0.25
const STILL_S := 0.4
## Spannung der Gelenke (Reibmoment, Anteil von Körpergewicht mal Hebel, mal r des Gelenks): am Anfang, am Ende, Zeit dazwischen (s)
const SPANNUNG_AN := 1.0
const SPANNUNG_AUS := 0.006
const SPANNUNG_S := 0.35
## Dämpfung der Körper; ab RUHE_AB s wächst sie, damit er zur Ruhe kommt statt zu zittern
const DAEMPF_LIN := 0.05
const DAEMPF_ROT := 0.9
const RUHE_AB := 2.5
## Grenzen der übernommenen Geschwindigkeit (eine Überblendung kann in einem Bild springen)
const MAX_MPS := 5.0
const MAX_RAD := 10.0
const SCHICHT := 1 << 19      # eigene Kollisionsschicht: Glieder, Boden, Hindernisse, sonst nichts
const DICHTE_KG := 32.0       # Masse eines 1 m großen Körpers (mal Größe hoch 3); nur das Verhältnis der Glieder zählt
## höchstens so viele zugleich in der Physik; darüber und unter MIN_BILDRATE stirbt er gebacken (Rückfall, Frage 8). Gemessen am
## Rechner (tod_ragdoll_1215 „Kosten“): drei zugleich 3 bis 7 ms je Physikbild (stark schwankend), gebacken 0,15 ms; am Handy
## misst das Laufprotokoll („1215 Ragdoll: liegt … Physik … ms“)
const MAX_ZUGLEICH := 3
const MIN_BILDRATE := 20.0

## Glieder je Gerüst. k: Knochen am Anfang des Glieds; ende: Knochen, dessen Ursprung das Ende ist ("" = längs des Knochens, lang
## mal Größe), mal: Ende so viel weiter; an: Glied, an dem es hängt; form: kasten, kapsel, kugel; m: Anteil der Masse;
## null: wo der Winkel 0 ist: "ruhe" (Ruhelage des Gerüsts), "gerade" (in Verlängerung des Glieds darüber), "gegen" (ihm entgegen:
## die Beine hängen am Becken nach unten); x: Beugen nach vorn (+) und hinten (−) in Grad, y: Drehen um die eigene Achse (±), z: zur
## Seite (±; Knie 12°, Ellbogen 15° vor der Streckung: die Grenze gibt bei schneller Bewegung um etwa 5° je rad/s nach, gemessen
## gelenk_1215); r: Spannung (Faktor); mit: weitere Kapseln am selben Glied [von, bis, mal] (Fuß)
## eigenes Gerüst (tools/blender348/v3_kampf/rig.py: je Strecke zwischen zwei Gelenkpunkten ein Knochen „a-b“; Goblin, Späher,
## Schamane, Kobold)
const GLIEDER_STRECKE := [
	{"n": "becken", "k": "pelvis-waist", "ende": "belly-chest", "form": "kasten", "m": 0.27},
	{"n": "brust", "k": "belly-chest", "ende": "chestTop-neck", "an": "becken", "form": "kasten", "m": 0.24, "null": "gerade", "x": [-15, 40], "y": 18, "z": 18, "r": 0.8},
	{"n": "kopf", "k": "neck-neckTop", "an": "brust", "form": "kasten", "m": 0.09, "lang": 0.16, "null": "ruhe", "x": [-60, 45], "y": 45, "z": 30, "r": 0.12},
	{"n": "oberarm_l", "k": "upL-elL", "ende": "elL-foL", "an": "brust", "form": "kapsel", "m": 0.03, "null": "ruhe", "x": [-100, 150], "y": 90, "z": 90, "r": 0.07},
	{"n": "unterarm_l", "k": "elL-foL", "ende": "foL-wrL", "mal": 2.7, "an": "oberarm_l", "form": "kapsel", "m": 0.022, "null": "gerade", "x": [15, 140], "y": 0, "z": 0, "r": 0.04},
	{"n": "oberarm_r", "k": "upR-elR", "ende": "elR-foR", "an": "brust", "form": "kapsel", "m": 0.03, "null": "ruhe", "x": [-100, 150], "y": 90, "z": 90, "r": 0.07},
	{"n": "unterarm_r", "k": "elR-foR", "ende": "foR-wrR", "mal": 2.7, "an": "oberarm_r", "form": "kapsel", "m": 0.022, "null": "gerade", "x": [15, 140], "y": 0, "z": 0, "r": 0.04},
	{"n": "schenkel_l", "k": "hipL-thighL", "ende": "kneeL-calfL", "an": "becken", "form": "kapsel", "m": 0.1, "null": "gegen", "x": [-20, 95], "y": 35, "z": 45, "r": 0.5},
	{"n": "wade_l", "k": "kneeL-calfL", "ende": "ankleL-heelL", "an": "schenkel_l", "form": "kapsel", "m": 0.06, "null": "gerade", "x": [-125, -12], "y": 0, "z": 0, "mit": [["ankleL-heelL", "ballL-toeL", 1.5]], "r": 0.5},
	{"n": "schenkel_r", "k": "hipR-thighR", "ende": "kneeR-calfR", "an": "becken", "form": "kapsel", "m": 0.1, "null": "gegen", "x": [-20, 95], "y": 35, "z": 45, "r": 0.5},
	{"n": "wade_r", "k": "kneeR-calfR", "ende": "ankleR-heelR", "an": "schenkel_r", "form": "kapsel", "m": 0.06, "null": "gerade", "x": [-125, -12], "y": 0, "z": 0, "mit": [["ankleR-heelR", "ballR-toeR", 1.5]], "r": 0.5},
]
## UAL (Quaternius Universal Animation Library: Grak, Krogg, Menschen auf dem Kaufkörper)
const GLIEDER_UAL := [
	{"n": "becken", "k": "pelvis", "ende": "spine_02", "form": "kasten", "m": 0.27},
	{"n": "brust", "k": "spine_02", "ende": "neck_01", "an": "becken", "form": "kasten", "m": 0.24, "null": "gerade", "x": [-15, 40], "y": 18, "z": 18, "r": 0.8},
	{"n": "kopf", "k": "Head", "an": "brust", "form": "kasten", "m": 0.08, "lang": 0.13, "null": "ruhe", "x": [-60, 45], "y": 45, "z": 30, "r": 0.12},
	{"n": "oberarm_l", "k": "upperarm_l", "ende": "lowerarm_l", "an": "brust", "form": "kapsel", "m": 0.03, "null": "ruhe", "x": [-100, 150], "y": 90, "z": 90, "r": 0.07},
	{"n": "unterarm_l", "k": "lowerarm_l", "ende": "hand_l", "mal": 1.45, "an": "oberarm_l", "form": "kapsel", "m": 0.022, "null": "gerade", "x": [15, 140], "y": 0, "z": 0, "r": 0.04},
	{"n": "oberarm_r", "k": "upperarm_r", "ende": "lowerarm_r", "an": "brust", "form": "kapsel", "m": 0.03, "null": "ruhe", "x": [-100, 150], "y": 90, "z": 90, "r": 0.07},
	{"n": "unterarm_r", "k": "lowerarm_r", "ende": "hand_r", "mal": 1.45, "an": "oberarm_r", "form": "kapsel", "m": 0.022, "null": "gerade", "x": [15, 140], "y": 0, "z": 0, "r": 0.04},
	{"n": "schenkel_l", "k": "thigh_l", "ende": "calf_l", "an": "becken", "form": "kapsel", "m": 0.1, "null": "gegen", "x": [-20, 95], "y": 35, "z": 45, "r": 0.5},
	{"n": "wade_l", "k": "calf_l", "ende": "foot_l", "an": "schenkel_l", "form": "kapsel", "m": 0.06, "null": "gerade", "x": [-125, -12], "y": 0, "z": 0, "mit": [["foot_l", "ball_l", 1.6]], "r": 0.5},
	{"n": "schenkel_r", "k": "thigh_r", "ende": "calf_r", "an": "becken", "form": "kapsel", "m": 0.1, "null": "gegen", "x": [-20, 95], "y": 35, "z": 45, "r": 0.5},
	{"n": "wade_r", "k": "calf_r", "ende": "foot_r", "an": "schenkel_r", "form": "kapsel", "m": 0.06, "null": "gerade", "x": [-125, -12], "y": 0, "z": 0, "mit": [["foot_r", "ball_r", 1.6]], "r": 0.5},
]
const TAFELN := {"strecke": GLIEDER_STRECKE, "ual": GLIEDER_UAL}
## Ferse und Ballen je Gerüst (für vorn)
const VORN_MARKEN := {"strecke": ["ankleL-heelL", "ballL-toeL"], "ual": ["foot_l", "ball_l"]}

## Stoß je Art des Treffers: Geschwindigkeit (m/s je m Größe) auf das getroffene Glied, Anteil davon für den ganzen Körper, Drall.
## nah: Hieb, Stich, Biss; schwer: Zweihänder, Axt, Keule; pfeil: klein und punktuell; zauber: Druck auf den ganzen Körper;
## schild: Schildstoß; sprung: Anspringen; still: Gift, Blutung, Feuer über Zeit (kein Stoß, er sackt zusammen)
const STOSS := {
	"nah": [1.2, 0.35, 1.0], "schwer": [2.4, 0.45, 1.2], "pfeil": [1.3, 0.1, 1.6], "zauber": [2.0, 0.6, 0.5],
	"schild": [2.0, 0.75, 0.4], "sprung": [1.8, 0.65, 0.6], "still": [0.0, 0.0, 0.0],
}
const KRITISCH := 1.6

static var zugleich := 0
static var bleibt := false                # Tests messen den Liegenden auch, wenn die Figur schon ausgeblendet ist
static var bildrate_pruefen := true      # Tests ohne Bild schalten die Prüfung der Bildrate ab
static var _masse := {}      # Schlüssel des Modells -> Maße der Glieder aus dem Netz (einmal je Körper gemessen)

var sk: Skeleton3D
var anim: AnimationPlayer
var geruest := ""
var gross := 1.0             # Größe der Figur (m)
var skala := 1.0             # Maßstab des Gerüsts in der Welt
var phase := ""              # "", "vorlauf", "physik", "liegt"
var glieder := []            # je Glied: Tafelzeile dazu {b Knochen, ruhe Transform3D (Rahmen des Glieds in der Ruhe, Gerüstmaß), lang, k RigidBody3D …}
var nach_name := {}
var koerper := {}            # Name -> RigidBody3D
var _gelenke := []           # [RID, Glied]
var _besitzer := PackedInt32Array()      # je Knochen: Index des Glieds
var _rel := []               # je Knochen: Haltung im Rahmen seines Glieds (bei der Übernahme)
var _folge := PackedInt32Array()         # Knochen, Eltern vor Kindern
var _lose := PackedInt32Array()          # Knochen ohne Glied über sich im Gerüst
var _vor := []               # je Glied: Lage im Vorlauf im Bild davor und jetzt (Welt), für die Geschwindigkeit
var _vor_dt := 0.0
var _zeit := 0.0
var _still := 0.0
var _masse_ges := 1.0
var _schubse := 0
var _physik_s := 0.0     # Summe der Physikzeit der Engine über die Bilder mit Physik (Messung)
var _schubs_ab := 1.1     # frühestens so lange nach der Übernahme (s)
var _schwanz := Vector3.ZERO     # Spitze des starren Schwanzes im Rahmen des Beckens (Gerüstmaß); kurz = keiner
var _boden_y := 0.0
var _statisch := []
var _waffen := []            # RigidBody3D der fallenden Waffen
var treffer := {}            # art, richtung (Welt, waagerecht), staerke (Faktor), kritisch, glied
var bilder_physik := 0
var usec := 0                # Rechenzeit dieses Skripts in der Physik (Skelett nachführen), für die Messung
var schluessel := ""
var schatten: Node3D           # Bodenschatten der Figur: bleibt unter dem Becken


## Gerüst erkennen und Glieder vermessen (noch ohne Körper); false: kein bekanntes Zweibeiner-Gerüst oder gespiegelt
func einrichten(s: Skeleton3D, a: AnimationPlayer, groesse_m: float, modell_schluessel := "") -> bool:
	sk = s
	anim = a
	gross = maxf(groesse_m, 0.3)
	schluessel = modell_schluessel
	var welt := sk.global_transform
	if welt.basis.determinant() <= 0.0:
		return false
	skala = welt.basis.get_scale().x
	for g in TAFELN:
		var da := true
		for z in TAFELN[g]:
			if sk.find_bone(z.k) < 0 or (z.has("ende") and sk.find_bone(z.ende) < 0):
				da = false
				break
		if da:
			geruest = g
			break
	if geruest == "":
		return false
	var vorn := _vorn()
	for z in TAFELN[geruest]:
		var g: Dictionary = z.duplicate()
		g.b = sk.find_bone(z.k)
		var rest := sk.get_bone_global_rest(g.b)
		var ziel: Vector3 = rest.origin + rest.basis.y.normalized() * float(z.get("lang", 0.12)) * gross / skala
		if z.has("ende"):
			ziel = rest.origin + (sk.get_bone_global_rest(sk.find_bone(z.ende)).origin - rest.origin) * float(z.get("mal", 1.0))
		g.lang = maxf((ziel - rest.origin).length(), 0.001)
		g.ruhe = Transform3D(_rahmen((ziel - rest.origin).normalized(), vorn), rest.origin)
		nach_name[z.n] = glieder.size()
		glieder.append(g)
	_besitz()
	# Dinge: ein Knochen ohne Glied über sich, der in der Ruhe weit vom Becken liegt (Graks Axt hängt im Modell an einem Knochen an
	# der Wurzel), wird ein eigener freier Körper und fällt für sich. Die Hüftknochen des eigenen Gerüsts liegen im Becken: kein Ding
	var becken: Transform3D = glieder[0].ruhe
	var dinge := 0
	for b in _lose.duplicate():
		if _lose.has(sk.get_bone_parent(b)):
			continue     # hängt unter einem anderen losen Knochen
		var rest := sk.get_bone_global_rest(b)
		var ab := Geometry3D.get_closest_point_to_segment(rest.origin, becken.origin, becken * Vector3(0, glieder[0].lang, 0)).distance_to(rest.origin)
		if ab * skala < 0.2 * gross:
			continue
		var g := {"n": "ding_%s" % sk.get_bone_name(b), "k": sk.get_bone_name(b), "form": "kasten", "m": 0.04, "ding": true, "b": b,
			"lang": 0.3 * gross / skala, "ruhe": Transform3D(rest.basis.orthonormalized(), rest.origin)}
		nach_name[g.n] = glieder.size()
		glieder.append(g)
		dinge += 1
	if dinge > 0:
		_lose.clear()
		_besitz()
	_vermessen()
	return true


## vorn der Figur im Raum des Gerüsts: von der Ferse zu den Zehen (Ruhelage), sonst +z (glTF schaut nach +z)
func _vorn() -> Vector3:
	var f := sk.find_bone(String(VORN_MARKEN[geruest][0]))
	var z := sk.find_bone(String(VORN_MARKEN[geruest][1]))
	if f >= 0 and z >= 0:
		var d := sk.get_bone_global_rest(z).origin - sk.get_bone_global_rest(f).origin
		d.y = 0.0
		if d.length() > 0.001:
			return d.normalized()
	return Vector3.BACK


## Rahmen eines Glieds: y längs, z nach vorn (quer zu y), x = y × z. Drehung um +x bringt y nach vorn: beugen
static func _rahmen(y: Vector3, vorn: Vector3) -> Basis:
	var z := vorn - y * vorn.dot(y)
	if z.length() < 0.2:     # das Glied zeigt selbst nach vorn oder hinten (Fuß, gestreckter Arm): dann oben als zweite Richtung
		z = Vector3.UP - y * y.y
		if y.dot(vorn) > 0.0:
			z = -z
	z = z.normalized()
	return Basis(y.cross(z).normalized(), y, z)


## je Knochen das Glied, mit dem er geht: das nächste über ihm im Gerüst, sonst das Becken (Wurzel, Hüftknochen des eigenen
## Gerüsts, Hilfsknochen); Reihenfolge Eltern vor Kindern
func _besitz() -> void:
	var n := sk.get_bone_count()
	var eigen := {}
	for i in glieder.size():
		eigen[glieder[i].b] = i
	_besitzer.resize(n)
	var tiefe := []
	for b in n:
		var p := b
		var t := 0
		var wer := -1
		while p >= 0:
			if wer < 0 and eigen.has(p):
				wer = eigen[p]
			p = sk.get_bone_parent(p)
			t += 1
		_besitzer[b] = maxi(wer, 0)
		if wer < 0 and sk.get_bone_parent(b) >= 0:
			_lose.append(b)
		tiefe.append([t, b])
	tiefe.sort()
	_folge.resize(n)
	for i in n:
		_folge[i] = tiefe[i][1]


## Maße der Glieder aus dem Netz: je Ecke der Knochen mit dem größten Gewicht, sein Glied; im Rahmen des Glieds Dicke (Kapsel),
## Breite und Tiefe (Kasten), Mitte und Halbmesser (Kugel). Einmal je Modell (Schlüssel), sonst aus der Tafel geschätzt
func _vermessen() -> void:
	var m: Array = _masse.get(schluessel, []) if schluessel != "" else []
	if m.is_empty():
		var punkte := []
		var fern := Vector3.ZERO
		for i in glieder.size():
			punkte.append(PackedVector3Array())
		for mi in sk.get_parent().find_children("*", "MeshInstance3D", true, false):
			var netz := (mi as MeshInstance3D).mesh
			var haut := (mi as MeshInstance3D).skin
			if netz == null or haut == null or (mi as MeshInstance3D).get_parent() is BoneAttachment3D:
				continue
			var bind_knochen := PackedInt32Array()
			var bind := []
			for j in haut.get_bind_count():
				var bn := haut.get_bind_bone(j)
				if bn < 0:
					bn = sk.find_bone(haut.get_bind_name(j))
				bind_knochen.append(bn)
				bind.append((sk.get_bone_global_rest(bn) if bn >= 0 else Transform3D.IDENTITY) * haut.get_bind_pose(j))
			for f in netz.get_surface_count():
				var arr := netz.surface_get_arrays(f)
				var ecken: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				var kn = arr[Mesh.ARRAY_BONES]
				var gw = arr[Mesh.ARRAY_WEIGHTS]
				if kn == null or gw == null or ecken.is_empty():
					continue
				var je: int = kn.size() / ecken.size()
				var schritt := maxi(1, ecken.size() / 1500)
				for e in range(0, ecken.size(), schritt):
					var best := 0
					for q in range(1, je):
						if gw[e * je + q] > gw[e * je + best]:
							best = q
					var j: int = kn[e * je + best]
					if j >= bind.size() or bind_knochen[j] < 0:
						continue
					var gl: int = _besitzer[bind_knochen[j]]
					# nur Knochen, die im Gerüst unter dem Glied hängen (nicht die dem Becken zugeschlagenen: Schwanz des Kobolds)
					if _lose.has(bind_knochen[j]) or sk.get_bone_parent(bind_knochen[j]) < 0:
						# Ecken an Knochen ohne Glied (Hüftknochen): gehören zum Becken, zählen nicht für seine Maße; die fernste ist
						# die Spitze des Schwanzes (Kobold: der Schwanz hängt starr am Hüftknochen)
						var ps: Vector3 = (glieder[0].ruhe as Transform3D).affine_inverse() * ((bind[j] as Transform3D) * ecken[e])
						if ps.length() > fern.length():
							fern = ps
						continue
					punkte[gl].append((glieder[gl].ruhe as Transform3D).affine_inverse() * ((bind[j] as Transform3D) * ecken[e]))
		for i in glieder.size():
			m.append(_mass(glieder[i], punkte[i]))
		m.append(fern)
		if schluessel != "":
			_masse[schluessel] = m
	for i in glieder.size():
		glieder[i].mass = m[i]
	_schwanz = m[glieder.size()]


func _unter(b: int, ahn: int) -> bool:
	while b >= 0:
		if b == ahn:
			return true
		b = sk.get_bone_parent(b)
	return false


## [halb x, halb z, y von, y bis, Mitte der Kugel, Halbmesser] im Maß des Gerüsts
func _mass(g: Dictionary, p: PackedVector3Array) -> Array:
	var l: float = g.lang
	var dick: float = l * (0.5 if g.form == "kasten" else 0.2)
	if p.size() < 8:
		return [dick, dick * 0.7, 0.0, l, Vector3(0, l * 0.5, 0), maxf(dick, l * 0.5)]
	var xs := []
	var zs := []
	var rs := []
	var ys := []
	var mitte := Vector3.ZERO
	for v in p:
		mitte += v
	mitte /= p.size()
	for v in p:
		ys.append(v.y)
		if v.y > 0.1 * l and v.y < 0.9 * l:     # Dicke aus der Mitte des Glieds (am Ende der Wade sitzt der Fuß, am Unterarm die Hand)
			rs.append(Vector2(v.x, v.z).length())
		xs.append(absf(v.x - mitte.x))
		zs.append(absf(v.z - mitte.z))
	for a in [xs, zs, rs, ys]:
		a.sort()
	var q := func(a: Array, t: float) -> float: return a[clampi(int(a.size() * t), 0, a.size() - 1)]
	if g.form == "kapsel":
		# nie dicker als ein Drittel der Länge und ein Zwölftel der Größe: Robe und Lendentuch hängen an den Schenkeln, mit ihnen
		# gemessen wurden die Beine des Schamanen so dick, dass er nicht einknicken konnte (Brust blieb 0,7 m hoch, Spalt 0,27 m)
		var r: float = minf(q.call(rs, 0.75) if rs.size() >= 4 else dick, minf(l * 0.33, gross / skala * 0.085))
		return [r, r, 0.0, l, Vector3(0, l * 0.5, 0), r]
	# Kasten (Rumpf, Kopf): um die Mitte der Ecken, 92 von 100 Ecken liegen darin (Ohrspitzen und Nase des Goblins ragen heraus)
	var y0: float = q.call(ys, 0.04)
	var y1: float = q.call(ys, 0.96)
	if g.get("ding", false):     # ein Ding (Axt): sein ganzer Kasten
		y0 = q.call(ys, 0.01)
		y1 = q.call(ys, 0.99)
		return [maxf(q.call(xs, 0.98), 0.01), maxf(q.call(zs, 0.98), 0.01), y0, y1, Vector3(mitte.x, (y0 + y1) * 0.5, mitte.z), 0.0]
	var gr: float = gross / skala
	y0 = maxf(y0, -0.8 * l)
	y1 = minf(y1, maxf(1.8 * l, 0.28 * gr))
	var weit := 0.97 if not g.has("ende") else 0.92     # Kopf: die Ohren zählen mit (lagen bis 0,1 m im Boden)
	return [minf(q.call(xs, weit), 0.24 * gr), minf(q.call(zs, weit), 0.17 * gr), y0, y1, Vector3(clampf(mitte.x, -0.05 * gr, 0.05 * gr), (y0 + y1) * 0.5, clampf(mitte.z, -0.08 * gr, 0.08 * gr)), 0.0]


## im Tod nach dem Vorlauf die Physik übernehmen lassen; [fuss] Welt-Höhe des Bodens, [hindernisse] Stellen (Welt) und Halbmesser
## dessen, was steht (lebende Figuren, Bäume, Felsen): [[Vector3, r, hoch] …]
func sterben(nach_s: float, fuss: float, hindernisse := []) -> void:
	phase = "vorlauf"
	_zeit = -maxf(nach_s, 0.0)
	_boden_y = fuss
	_hindernisse = hindernisse
	_vor.clear()
	process_priority = 100      # nach dem AnimationPlayer: die Haltung dieses Bilds
	zugleich += 1

var _hindernisse := []


## darf noch einer physikalisch sterben? (Frage 8: Rückfall auf die gebackene Bewegung, wenn es zu teuer wird)
static func frei() -> bool:
	if zugleich >= MAX_ZUGLEICH:
		return false
	var fps := Engine.get_frames_per_second()
	return not bildrate_pruefen or Time.get_ticks_msec() < 3000 or fps >= MIN_BILDRATE or OS.has_feature("movie")


## Lage eines Glieds in der Welt aus der Haltung seines Knochens: Rahmen des Glieds (ohne Maßstab), Ursprung am Gelenk
func _lage(g: Dictionary) -> Transform3D:
	var pose := sk.get_bone_global_pose(g.b)
	var rest := sk.get_bone_global_rest(g.b)
	var t: Transform3D = sk.global_transform * (pose * (rest.affine_inverse() * (g.ruhe as Transform3D)))
	return Transform3D(t.basis.orthonormalized(), t.origin)


func _process(delta: float) -> void:
	if phase == "vorlauf":
		_zeit += delta
		var jetzt := []
		for g in glieder:
			jetzt.append(_lage(g))
		if _zeit >= 0.0 and not _vor.is_empty():
			_los(_vor, jetzt, maxf(delta, 0.001))
		_vor = jetzt
	elif phase == "physik":
		_nachfuehren()


func _physics_process(delta: float) -> void:
	if phase != "physik":
		return
	_zeit += delta
	bilder_physik += 1
	_physik_s += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	var sp := lerpf(SPANNUNG_AN, SPANNUNG_AUS, clampf(_zeit / SPANNUNG_S, 0.0, 1.0))
	if _zeit <= SPANNUNG_S + delta:
		_spannung(sp)
	var mehr := maxf(0.0, _zeit - RUHE_AB)
	var schnell := 0.0
	var dreht := 0.0
	for n in koerper:
		var k := koerper[n] as RigidBody3D
		schnell = maxf(schnell, k.linear_velocity.length())
		dreht = maxf(dreht, k.angular_velocity.length())
		if mehr > 0.0:
			k.linear_damp = DAEMPF_LIN + mehr * 1.5
			k.angular_damp = DAEMPF_ROT + mehr * 4.0
	_still = _still + delta if schnell < STILL_MPS * gross and dreht < STILL_RAD else 0.0
	# hockt er (Becken oder Brust hoch über dem Boden: auf Knien und Stirn, gesehen beim Kobold nach einem Stoß von hinten), kippt
	# ein Schubs quer zur Körperachse ihn auf die Seite; höchstens dreimal
	if _zeit >= _schubs_ab and _schubse < 3 and _zeit < LIEGEN_S - 1.0 and (koerper["becken"] as RigidBody3D).linear_velocity.length() < 0.35 * gross:
		var hoch := 0.0
		for n in ["becken", "brust"]:
			hoch = maxf(hoch, ((koerper[n] as RigidBody3D).global_transform * (koerper[n] as RigidBody3D).center_of_mass).y - _boden_y)
		if hoch > 0.3 * gross:
			_schubse += 1
			_schubs_ab = _zeit + 0.6
			var achse: Vector3 = ((koerper["brust"] as RigidBody3D).global_position - (koerper["becken"] as RigidBody3D).global_position) * Vector3(1, 0, 1)
			var quer: Vector3 = (achse.normalized().cross(Vector3.UP) if achse.length() > 0.02 else Vector3.RIGHT) * (1.0 if _schubse % 2 == 1 else -1.0)
			for n in ["becken", "brust", "kopf"]:
				(koerper[n] as RigidBody3D).linear_velocity += quer * 1.3 * gross
				(koerper[n] as RigidBody3D).angular_velocity += achse.normalized() * 2.5 * (1.0 if _schubse % 2 == 1 else -1.0)
			_still = 0.0
	if _still >= STILL_S or _zeit >= LIEGEN_S:
		_einfrieren()


## Übernahme: Körper und Gelenke anlegen, Geschwindigkeit aus den letzten zwei Bildern der Bewegung, Stoß des Treffers
func _los(vorher: Array, jetzt: Array, dt: float) -> void:
	phase = "physik"
	_zeit = 0.0
	if anim != null:
		anim.pause()
	var masse_ges := DICHTE_KG * pow(gross, 3.0)
	_masse_ges = masse_ges
	for i in glieder.size():
		var g: Dictionary = glieder[i]
		var k := RigidBody3D.new()
		k.name = "R_" + String(g.n)
		k.collision_layer = SCHICHT
		k.collision_mask = SCHICHT
		k.mass = maxf(float(g.m) * masse_ges, 0.05)
		k.linear_damp = DAEMPF_LIN
		k.angular_damp = DAEMPF_ROT
		k.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
		k.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
		k.continuous_cd = true
		k.can_sleep = false
		var pm := PhysicsMaterial.new()
		pm.friction = 0.85
		pm.bounce = 0.0
		k.physics_material_override = pm
		var ms: Array = g.mass
		var cs := CollisionShape3D.new()
		var l: float = g.lang * skala
		match String(g.form):
			"kasten":
				var kasten := BoxShape3D.new()
				kasten.size = Vector3(maxf(ms[0] * 2.0, 0.02), maxf(ms[3] - ms[2], 0.02), maxf(ms[1] * 2.0, 0.02)) * skala
				cs.shape = kasten
				cs.position = (ms[4] as Vector3) * skala
			_:
				var kap := CapsuleShape3D.new()
				# nicht dicker, als beide Enden des Glieds jetzt über dem Boden sind (sonst steckt es im ersten Bild im Boden)
				var frei: float = minf((jetzt[i] as Transform3D).origin.y, ((jetzt[i] as Transform3D) * Vector3(0, l, 0)).y) - _boden_y - 0.004
				kap.radius = clampf(minf(float(ms[0]) * skala, frei), 0.012, l * 0.45)
				kap.height = maxf(l, kap.radius * 2.0 + 0.002)
				cs.shape = kap
				cs.position = Vector3(0, l * 0.5, 0)
		k.add_child(cs)
		for zus in g.get("mit", []):     # Fuß: Kapsel von der Ferse über den Ballen hinaus, starr an der Wade, wie er jetzt steht
			var a := sk.find_bone(zus[0])
			var b := sk.find_bone(zus[1])
			if a < 0 or b < 0:
				continue
			var inv: Transform3D = (jetzt[i] as Transform3D).affine_inverse() * sk.global_transform
			var pa: Vector3 = inv * sk.get_bone_global_pose(a).origin
			var pb: Vector3 = inv * sk.get_bone_global_pose(b).origin
			pb = pa + (pb - pa) * float(zus[2])
			# nicht dicker, als der Fuß jetzt über dem Boden steht (sonst hebt der Boden die Wade im ersten Bild aus dem Knie:
			# Spalt 0,03 bis 0,05 m nach 3 Bildern, gemessen)
			var hoch: float = minf(((jetzt[i] as Transform3D) * pa).y, ((jetzt[i] as Transform3D) * pb).y) - _boden_y
			var fk := CapsuleShape3D.new()
			fk.radius = clampf(minf((cs.shape as CapsuleShape3D).radius * 0.6, hoch - 0.004), 0.008, 0.05)
			fk.height = maxf((pb - pa).length(), fk.radius * 2.0 + 0.002)
			var fs := CollisionShape3D.new()
			fs.shape = fk
			fs.transform = Transform3D(_rahmen((pb - pa).normalized(), Vector3.UP), (pa + pb) * 0.5)
			k.add_child(fs)
		if i == 0 and _schwanz.length() * skala > 0.3 * gross:
			# Kobold: der Schwanz ist starr am Becken; als Kapsel bis zur Spitze liegt er auf dem Boden statt darin (gemessen bis
			# 0,39 m im Boden)
			var sp: Vector3 = _schwanz * skala
			var sk_form := CapsuleShape3D.new()
			sk_form.radius = 0.035 * gross
			sk_form.height = maxf(sp.length(), sk_form.radius * 2.0 + 0.002)
			var ss := CollisionShape3D.new()
			ss.shape = sk_form
			ss.transform = Transform3D(_rahmen(sp.normalized(), Vector3.UP), sp * 0.5)
			k.add_child(ss)
		k.top_level = true
		add_child(k)
		k.global_transform = jetzt[i]
		g.koerper = k
		koerper[g.n] = k
		# Geschwindigkeit des Glieds in der Bewegung: Weg und Drehung seit dem Bild davor
		var v: Vector3 = ((jetzt[i] as Transform3D).origin - (vorher[i] as Transform3D).origin) / dt
		var dq: Quaternion = ((jetzt[i] as Transform3D).basis * (vorher[i] as Transform3D).basis.inverse()).get_rotation_quaternion()
		var w: Vector3 = dq.get_axis() * dq.get_angle() / dt if dq.get_angle() > 0.0001 else Vector3.ZERO
		k.linear_velocity = v.limit_length((MAX_MPS if not g.get("ding", false) else 1.5) * gross)
		k.angular_velocity = w.limit_length(MAX_RAD)
	# der Ursprung des Körpers liegt am Gelenk; der Schwerpunkt in der Mitte des Glieds
	for g in glieder:
		var k: RigidBody3D = g.koerper
		k.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
		k.center_of_mass = (g.mass[4] as Vector3) * skala
	_gelenke_bauen()
	# was sich in der Ausgangslage schon durchdringt (Oberarm an der Brust, Schenkel aneinander), stößt sich nie ab
	for i in glieder.size():
		for j in range(i + 1, glieder.size()):
			if glieder[i].get("ding", false) or glieder[j].get("ding", false) or _nah(glieder[i], glieder[j]):     # Dinge fallen neben den Körper
				(glieder[i].koerper as RigidBody3D).add_collision_exception_with(glieder[j].koerper)
	# je Knochen die Haltung im Rahmen seines Glieds, wie sie jetzt ist: so geht er starr mit
	# Knochen ohne Glied über sich (Hüftknochen des eigenen Gerüsts, Graks Axt an der Wurzel): zum Glied, dem sie jetzt am nächsten sind
	for b in _lose:
		var ort: Vector3 = sk.global_transform * sk.get_bone_global_pose(b).origin
		var best := 0
		var weit := INF
		for i in glieder.size():
			var t: Transform3D = jetzt[i]
			var d := Geometry3D.get_closest_point_to_segment(ort, t.origin, t * Vector3(0, glieder[i].lang * skala, 0)).distance_to(ort)
			if d < weit - 0.001:
				weit = d
				best = i
		_besitzer[b] = best
	_rel.clear()
	for b in sk.get_bone_count():
		_rel.append((jetzt[_besitzer[b]] as Transform3D).affine_inverse() * (sk.global_transform * sk.get_bone_global_pose(b)))
	_boden()
	_waffen_los()
	_stoss()
	_spannung(SPANNUNG_AN)
	if OS.get_environment("RAGDOLL_MASS") != "":     # Messung: Maße der Körper und Winkel bei der Übernahme
		for g in glieder:
			var w: Vector3 = winkel(g.n) if g.has("an") else Vector3.ZERO
			print("1215 Glied %s: lang %.2f, halb %.2f × %.2f, y %.2f bis %.2f; Winkel %.0f %.0f %.0f" % [g.n, g.lang * skala, g.mass[0] * skala, g.mass[1] * skala, g.mass[2] * skala, g.mass[3] * skala, w.x, w.y, w.z])


## Gelenke des Physikservers (6 Freiheitsgrade, Lage fest, Winkel begrenzt), Rahmen je Körper aus der Ruhelage: der Winkel 0 liegt,
## wo die Tafel ihn will, gleich in welcher Haltung die Physik übernimmt
func _gelenke_bauen() -> void:
	for g in glieder:
		if not g.has("an"):
			continue
		var e: Dictionary = glieder[nach_name[g.an]]
		var rk: Transform3D = g.ruhe            # Kind in der Ruhe
		var re: Transform3D = e.ruhe            # Eltern in der Ruhe
		var bk := rk.basis
		var ba := rk.basis                      # Rahmen am Elternglied (Winkel 0)
		match String(g.get("null", "ruhe")):
			"gerade":
				ba = _an_achse(re.basis.y, rk.basis)
			"gegen":
				ba = _an_achse(-re.basis.y, rk.basis)
		# der Ort des Gelenks am Elternglied ist der von jetzt (die Knochen dazwischen, Schulter und Brustkorb, stehen in der Bewegung
		# anders als in der Ruhe: mit dem Ort der Ruhe sprang der Arm bei der Übernahme bis 0,1 m, gemessen tod_ragdoll_1215)
		var lokal_e := Transform3D(re.basis.inverse() * ba, (e.koerper as RigidBody3D).global_transform.affine_inverse() * (g.koerper as RigidBody3D).global_transform.origin)
		var lokal_k := Transform3D(bk.inverse() * bk, Vector3.ZERO)
		var j := PhysicsServer3D.joint_create()
		PhysicsServer3D.joint_make_generic_6dof(j, (e.koerper as RigidBody3D).get_rid(), lokal_e, (g.koerper as RigidBody3D).get_rid(), lokal_k)
		var x: Array = g.get("x", [0, 0])
		# gemessen (tests/gelenk_1215.gd): das Kind dreht um +x des Rahmens zwischen −obere und −untere Grenze
		var grenzen := [[-deg_to_rad(float(x[1])), -deg_to_rad(float(x[0]))], [-deg_to_rad(float(g.get("y", 0))), deg_to_rad(float(g.get("y", 0)))],
			[-deg_to_rad(float(g.get("z", 0))), deg_to_rad(float(g.get("z", 0)))]]
		for ax in 3:
			PhysicsServer3D.generic_6dof_joint_set_flag(j, ax, PhysicsServer3D.G6DOF_JOINT_FLAG_ENABLE_LINEAR_LIMIT, true)
			PhysicsServer3D.generic_6dof_joint_set_param(j, ax, PhysicsServer3D.G6DOF_JOINT_LINEAR_LOWER_LIMIT, 0.0)
			PhysicsServer3D.generic_6dof_joint_set_param(j, ax, PhysicsServer3D.G6DOF_JOINT_LINEAR_UPPER_LIMIT, 0.0)
			PhysicsServer3D.generic_6dof_joint_set_flag(j, ax, PhysicsServer3D.G6DOF_JOINT_FLAG_ENABLE_ANGULAR_LIMIT, true)
			PhysicsServer3D.generic_6dof_joint_set_param(j, ax, PhysicsServer3D.G6DOF_JOINT_ANGULAR_LOWER_LIMIT, grenzen[ax][0])
			PhysicsServer3D.generic_6dof_joint_set_param(j, ax, PhysicsServer3D.G6DOF_JOINT_ANGULAR_UPPER_LIMIT, grenzen[ax][1])
			PhysicsServer3D.generic_6dof_joint_set_flag(j, ax, PhysicsServer3D.G6DOF_JOINT_FLAG_ENABLE_MOTOR, true)
			PhysicsServer3D.generic_6dof_joint_set_param(j, ax, PhysicsServer3D.G6DOF_JOINT_ANGULAR_MOTOR_TARGET_VELOCITY, 0.0)
		PhysicsServer3D.joint_disable_collisions_between_bodies(j, true)
		g.rahmen_e = lokal_e
		_gelenke.append([j, g])


## Winkel eines Glieds gegen das, an dem es hängt (Grad): x beugen (+ nach vorn), y drehen, z zur Seite; zum Messen (Tests)
func winkel(n: String) -> Vector3:
	var g: Dictionary = glieder[nach_name[n]]
	if not g.has("rahmen_e"):
		return Vector3.ZERO
	var e: Dictionary = glieder[nach_name[g.an]]
	var rel: Basis = ((e.koerper as RigidBody3D).global_transform.basis * (g.rahmen_e as Transform3D).basis).inverse() * (g.koerper as RigidBody3D).global_transform.basis
	var y := rel.y
	var x := rel.x
	return Vector3(rad_to_deg(atan2(y.z, y.y)), rad_to_deg(atan2(-x.z, x.x)), rad_to_deg(asin(clampf(-y.x, -1.0, 1.0))))


## Abstand der beiden Seiten eines Gelenks (m): 0, solange es hält
func spalt(n: String) -> float:
	var g: Dictionary = glieder[nach_name[n]]
	if not g.has("rahmen_e"):
		return 0.0
	var e: Dictionary = glieder[nach_name[g.an]]
	return ((e.koerper as RigidBody3D).global_transform * (g.rahmen_e as Transform3D).origin).distance_to((g.koerper as RigidBody3D).global_transform.origin)


## Rahmen mit y auf [achse], x so nah wie möglich am x von [wie] (die Beugeachse bleibt die des Kinds)
static func _an_achse(achse: Vector3, wie: Basis) -> Basis:
	var y := achse.normalized()
	var x := wie.x - y * wie.x.dot(y)
	if x.length() < 0.05:
		x = wie.z.cross(y)
	x = x.normalized()
	return Basis(x, y, x.cross(y).normalized())


## Spannung: Reibmoment je Gelenk (Motor mit Zielgeschwindigkeit 0)
func _spannung(anteil: float) -> void:
	for jg in _gelenke:
		var g: Dictionary = jg[1]
		# gemessen am Bild (Blatt Fall 2): mit dem Gewicht des Glieds allein hielten die Knie nichts, er fiel in 0,25 s wie ein Sack;
		# Knie und Hüfte tragen den ganzen Körper: Anteil von Körpergewicht mal einem Zehntel der Größe (Hebel im Stand)
		var moment: float = anteil * float(g.get("r", 1.0)) * _masse_ges * 9.8 * gross * 0.1
		for ax in 3:
			PhysicsServer3D.generic_6dof_joint_set_param(jg[0], ax, PhysicsServer3D.G6DOF_JOINT_ANGULAR_MOTOR_FORCE_LIMIT, moment)


## liegen die Achsen zweier Glieder näher beieinander als ihre Dicken?
func _nah(a: Dictionary, b: Dictionary) -> bool:
	var ta: Transform3D = (a.koerper as RigidBody3D).global_transform
	var tb: Transform3D = (b.koerper as RigidBody3D).global_transform
	var ra: float = maxf(maxf(a.mass[0], a.mass[1]), a.mass[5]) * skala
	var rb: float = maxf(maxf(b.mass[0], b.mass[1]), b.mass[5]) * skala
	var pts := Geometry3D.get_closest_points_between_segments(ta.origin, ta * Vector3(0, a.lang * skala, 0), tb.origin, tb * Vector3(0, b.lang * skala, 0))
	return (pts[0] as Vector3).distance_to(pts[1]) < (ra + rb) * 1.05


func _boden() -> void:
	var boden := StaticBody3D.new()
	boden.name = "RagdollBoden"
	boden.collision_layer = SCHICHT
	boden.collision_mask = SCHICHT
	var cs := CollisionShape3D.new()
	cs.shape = WorldBoundaryShape3D.new()
	boden.add_child(cs)
	boden.top_level = true
	add_child(boden)
	boden.global_transform = Transform3D(Basis.IDENTITY, Vector3(0, _boden_y, 0))
	_statisch.append(boden)
	# was steht (lebende Figuren, Bäume, Felsen): Säulen, an denen er abgleitet statt hindurchzufallen
	for h in _hindernisse:
		var s := StaticBody3D.new()
		s.collision_layer = SCHICHT
		s.collision_mask = SCHICHT
		var hs := CollisionShape3D.new()
		var zyl := CylinderShape3D.new()
		zyl.radius = float(h[1])
		zyl.height = float(h[2])
		hs.shape = zyl
		s.add_child(hs)
		var pm := PhysicsMaterial.new()
		pm.friction = 0.1
		s.physics_material_override = pm
		s.top_level = true
		add_child(s)
		s.global_transform = Transform3D(Basis.IDENTITY, Vector3(h[0].x, _boden_y + float(h[2]) * 0.5, h[0].z))
		_statisch.append(s)


## die Waffe in der Hand wird ein eigener Körper und fällt (Schild am Arm und im Modell gebackene Waffen bleiben am Glied)
func _waffen_los() -> void:
	for at in sk.get_children():
		if not at is BoneAttachment3D:
			continue
		var was := String(at.get_meta("was", ""))
		if was == "" or was == "waffe-im-modell" or was.contains("shield"):
			continue
		var hand: int = (at as BoneAttachment3D).bone_idx if (at as BoneAttachment3D).bone_idx >= 0 else sk.find_bone((at as BoneAttachment3D).bone_name)
		for w in at.get_children():
			if not w is Node3D:
				continue
			var box := AABB()
			var erst := true
			for mi in w.find_children("*", "MeshInstance3D", true, false) + ([w] if w is MeshInstance3D else []):
				var bb: AABB = ((w as Node3D).global_transform.affine_inverse() * (mi as MeshInstance3D).global_transform) * (mi as MeshInstance3D).get_aabb()
				box = bb if erst else box.merge(bb)
				erst = false
			if erst:
				continue
			var g: Transform3D = (w as Node3D).global_transform
			var k := RigidBody3D.new()
			k.name = "R_waffe"
			k.collision_layer = SCHICHT
			k.collision_mask = SCHICHT
			k.mass = 1.2
			k.angular_damp = 0.6
			k.continuous_cd = true
			var pm := PhysicsMaterial.new()
			pm.friction = 0.8
			k.physics_material_override = pm
			var ms := g.basis.get_scale()
			var cs := CollisionShape3D.new()
			var kasten := BoxShape3D.new()
			kasten.size = (box.size * ms).max(Vector3.ONE * 0.02)
			cs.shape = kasten
			cs.position = box.get_center() * ms
			k.add_child(cs)
			k.top_level = true
			add_child(k)
			k.global_transform = Transform3D(g.basis.orthonormalized(), g.origin)
			# steckt sie im Boden (der Speer des Kobolds steht mit dem Schaft auf der Erde und blieb aufrecht stecken, gesehen im
			# Blatt), so weit heben, dass ihre tiefste Ecke aufliegt
			var tief := INF
			for e in 8:
				tief = minf(tief, (k.global_transform * (cs.position + kasten.size * (Vector3(e & 1, (e >> 1) & 1, (e >> 2) & 1) - Vector3.ONE * 0.5))).y)
			if tief < _boden_y + 0.01:
				k.global_position.y += _boden_y + 0.01 - tief
			at.remove_child(w)
			k.add_child(w)
			(w as Node3D).transform = Transform3D(Basis.from_scale(ms), Vector3.ZERO)
			if hand >= 0:
				var hk: RigidBody3D = glieder[_besitzer[hand]].koerper
				k.linear_velocity = hk.linear_velocity
				k.angular_velocity = hk.angular_velocity
			# sie kippt (ein Stab oder Speer blieb sonst auf dem Ende stehen, gemessen 0,7 m hoch und gesehen im Blatt)
			k.angular_velocity += Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized() * 2.5
			k.can_sleep = false
			for n in koerper:     # die Waffe fällt neben den Körper, nicht auf ihm tanzend: nur der Boden hält sie
				k.add_collision_exception_with(koerper[n])
			_waffen.append(k)


## Stoß des Treffers: Geschwindigkeit auf das getroffene Glied, ein Anteil auf den ganzen Körper, Drall um die Hochachse
func _stoss() -> void:
	var art := String(treffer.get("art", "still"))
	var s: Array = STOSS.get(art, STOSS["nah"])
	var richtung: Vector3 = treffer.get("richtung", Vector3.ZERO)
	richtung.y = 0.0
	var v: float = float(s[0]) * gross * float(treffer.get("staerke", 1.0)) * (KRITISCH if treffer.get("kritisch", false) else 1.0)
	v = minf(v, 2.4 * gross)     # nie weiter als etwa eine Körperlänge geschleudert (gemessen ohne Grenze bis 2,5 m)
	if richtung.length() < 0.01 or v <= 0.0:
		# ohne Stoß (Gift, Blutung): die Beine geben sofort nach, er sackt zusammen und kippt, wohin er sich gerade neigt
		for n in ["schenkel_l", "schenkel_r", "wade_l", "wade_r"]:
			if nach_name.has(n):
				glieder[nach_name[n]].r = 0.0
		# und er kippt aus dem Gleichgewicht (sonst bleibt der geduckte Goblin auf den Fersen hocken: Brust 0,54 m hoch, gemessen)
		# zur Seite oder nach hinten, nie nach vorn (vornüber faltet er sich auf den Knien zu einem Ballen, gesehen im Blatt „Gift“)
		var vorn_welt: Vector3 = (sk.global_transform.basis * _vorn() * Vector3(1, 0, 1)).normalized()
		var wohin: Vector3 = vorn_welt.rotated(Vector3.UP, (1.0 if randf() < 0.5 else -1.0) * deg_to_rad(randf_range(70.0, 150.0))) * 0.9 * gross
		for n in ["brust", "kopf", "becken"]:
			if koerper.has(n):
				(koerper[n] as RigidBody3D).linear_velocity += wohin * (0.55 if n == "becken" else 1.0)
		return
	richtung = richtung.normalized()
	var ziel := String(treffer.get("glied", "brust"))
	if not koerper.has(ziel):
		ziel = "brust"
	var zk := koerper[ziel] as RigidBody3D
	var breit := float(s[1])
	# der Körper kippt als Ganzes um die Füße: je höher ein Glied, desto schneller (bis zur Höhe des Treffers voll), dazu der Anteil
	# für alle. So zieht der Stoß kein Gelenk auseinander (erste Fassung: nur die Brust bekam ihn, Spalt bis 0,05 m). Der Pfeil
	# trifft klein und punktuell: fast nur das getroffene Glied
	var h_ziel: float = maxf(zk.global_transform.origin.y + (zk.global_transform.basis * zk.center_of_mass).y - _boden_y, 0.2 * gross)
	var kipp := Vector3.UP.cross(richtung) * (1.0 - breit) * v / h_ziel
	for n in koerper:
		var k := koerper[n] as RigidBody3D
		if String(n).begins_with("ding_"):
			continue
		var h: float = (k.global_transform * k.center_of_mass).y - _boden_y
		if art == "pfeil":
			k.linear_velocity += richtung * v * (breit if k != zk else 1.0)
			continue
		k.linear_velocity += richtung * v * (breit + (1.0 - breit) * clampf(h / h_ziel, 0.0, 1.25))
		k.angular_velocity += kipp
	# Drall: der Treffer sitzt selten in der Mitte; die getroffene Seite geht zuerst mit
	# dazu rollt er etwas um die Fallrichtung: so landet er auf Schulter und Seite statt genau auf Gesicht oder Knien (ein Stoß
	# genau von hinten faltete den geduckten Kobold sonst zu einem Ballen auf den Knien, gesehen im Blatt)
	var seite := float(treffer.get("seite", 0.0))
	if absf(seite) > 0.01:
		for n in ["brust", "becken", "kopf"]:
			if koerper.has(n):
				(koerper[n] as RigidBody3D).angular_velocity += Vector3.UP * seite * float(s[2]) * v / maxf(gross, 0.3) * 0.6 \
					+ richtung * signf(seite) * (0.8 + absf(seite)) * 1.2


## die Haltung jedes Knochens aus der Lage seines Glieds (starr mit ihm), als lokale Haltung ins Gerüst
func _nachfuehren() -> void:
	var t0 := Time.get_ticks_usec()
	var inv := sk.global_transform.affine_inverse()
	var lage := []
	for g in glieder:
		lage.append(inv * (g.koerper as RigidBody3D).global_transform)
	var glob := []
	glob.resize(sk.get_bone_count())
	for b in _folge:
		var t: Transform3D = (lage[_besitzer[b]] as Transform3D) * (_rel[b] as Transform3D)
		glob[b] = t
		var p := sk.get_bone_parent(b)
		var l: Transform3D = (glob[p] as Transform3D).affine_inverse() * t if p >= 0 else t
		sk.set_bone_pose_position(b, l.origin)
		sk.set_bone_pose_rotation(b, l.basis.get_rotation_quaternion())
		sk.set_bone_pose_scale(b, l.basis.get_scale())
	if schatten != null and is_instance_valid(schatten):
		var bp: Vector3 = (glieder[0].koerper as RigidBody3D).global_transform * Vector3(0, glieder[0].lang * skala * 0.5, 0)
		schatten.global_position = Vector3(bp.x, schatten.global_position.y, bp.z)
	usec += Time.get_ticks_usec() - t0


## die Lage, wie die Physik sie hinterlassen hat, bleibt; die Körper stehen still (als Hindernis für den nächsten, bis der Tote
## vergeht), die Gelenke sind weg, gerechnet wird nichts mehr
func _einfrieren() -> void:
	_nachfuehren()
	phase = "liegt"
	zugleich = maxi(0, zugleich - 1)
	for jg in _gelenke:
		PhysicsServer3D.free_rid(jg[0])
	_gelenke.clear()
	for n in koerper:
		(koerper[n] as RigidBody3D).freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		(koerper[n] as RigidBody3D).freeze = true
	for w in _waffen:
		(w as RigidBody3D).freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		(w as RigidBody3D).freeze = true
	for s in _statisch:
		(s as Node).queue_free()
	_statisch.clear()
	print("1215 Ragdoll: liegt nach %d Bildern Physik (%.2f s), Physik %.1f ms je Bild (alle zugleich), Skelett %.0f µs je Bild, %.0f Bilder/s" % [bilder_physik, _zeit,
		_physik_s / maxi(bilder_physik, 1) * 1000.0, float(usec) / maxi(bilder_physik, 1), Engine.get_frames_per_second()])


## der Tote vergeht (ausgeblendet): Körper weg
func raeumen() -> void:
	if bleibt:
		return
	if phase == "physik" or phase == "vorlauf":
		zugleich = maxi(0, zugleich - 1)
	phase = "weg"
	for jg in _gelenke:
		PhysicsServer3D.free_rid(jg[0])
	_gelenke.clear()
	for n in koerper:
		(koerper[n] as Node).queue_free()
	koerper.clear()
	for w in _waffen:
		if is_instance_valid(w):
			(w as Node).queue_free()
	_waffen.clear()
	for s in _statisch:
		(s as Node).queue_free()
	_statisch.clear()


func _exit_tree() -> void:
	if phase == "physik" or phase == "vorlauf":
		zugleich = maxi(0, zugleich - 1)
	for jg in _gelenke:
		PhysicsServer3D.free_rid(jg[0])
	_gelenke.clear()
