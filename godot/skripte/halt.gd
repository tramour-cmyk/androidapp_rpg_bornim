class_name Halt
extends RefCounted
# 653 (Chef 08.11., 14:35/14:40, „653 ja“; „jetzt“ 10.11., 12:33): Halt für Waffen und Schilde einmal je Modell statt je Figur:
#  1. Griff je Gegenstand: wo die Hand greift, wohin der Schaft läuft (achse), wohin Schneide oder Vorderseite zeigt (vorn), Spitze,
#     Ober- und Unterkante; aus dem Modell abgelesen (Modellregel 4 wie waffen.py und kaufschild.py: Ursprung = Griff bzw. Fessel,
#     Schaft nach +Y, Vorderseite nach +Z) und in regeln/halt.json abgelegt ({Kennung: Maße}; tests/halt_653.gd --aus= schreibt es,
#     eigene Datei statt Katalogspalte: gemessen, nicht von Hand gepflegt).
#  2. Halterung je Körper: rechte und linke Faust, Unterarm (Schild), aus dem Skelett des Körpers; Korrektur je Körpertyp, nie je Paar.
#  3. Eine Anlegefunktion (anlegen): Lage = Halterung des Körpers · Griff des Gegenstands, keine Zahlen je Paar.
# Jerry (709, 845) liest Spitze und Länge aus gegenstand() statt je Gegner zu messen.
# Alt: core/art/Dress.kt held (Griff je Grundform GRIP_BACK, eine Funktion für alle Körper), weaponThroughShield/Body (nichts im Körper).

const WAFFEN := "res://daten/waffen/%s.bin"
const BOGEN := ["shortbow", "longbow", "light_crossbow"]   # Korrektur je Gegenstand (nie je Paar): Fläche in x statt z
## Chef 10.11., 13:39 (Prüfbild 653: „im Seitprofil der Unterarm durch das Schild“): die Fessel (Ursprung des Schilds) liegt auf der
## Rückseite des Bretts; die Faust um sie herum, der Unterarm dahinter. Das Brett steht darum so weit außen vor der Faustmitte
const SCHILD_AUSSEN := 0.055
const KAMPF := "res://kampf/daten/%s.bin"
const FELD := "res://regeln/halt.json"

static var _mass := {}            # Kennung -> Maße (Zwischenspeicher)
static var _feld = null           # Inhalt von FELD

## abgelegte Maße je Kennung (regeln/halt.json); leer, wenn die Datei fehlt
static func feld() -> Dictionary:
	if _feld == null:
		_feld = {}
		if FileAccess.file_exists(FELD):
			var j = JSON.parse_string(FileAccess.get_file_as_string(FELD))
			if j is Dictionary: _feld = j
	return _feld

## Datei des Modells: daten/waffen (Karte, Held, Leute), sonst kampf/daten (Kampf); leer, wenn keins da ist
static func datei(id: String) -> String:
	for f in [WAFFEN % id, KAMPF % id]:
		if FileAccess.file_exists(f): return f
	return ""

## Maße des Gegenstands im Raum seines Modells (m): griff, achse, vorn (Vector3), spitze (Vector3, weitestes Ende längs der Achse),
## laenge (Griff bis Spitze), unten (Länge unter dem Griff), hoehe (Vector2 unten/oben in y), rand_hinten (Schild: wie weit der Rand
## außerhalb der Mitte hinter die Fessel reicht). Zuerst abgelegt (regeln/halt.json), sonst aus dem Modell gemessen; leer ohne Modell
static func gegenstand(id: String) -> Dictionary:
	if _mass.has(id): return _mass[id]
	var h = feld().get(id)
	var m: Dictionary = aus_feld(h) if h is Dictionary else messen(id)
	if not m.is_empty(): _mass[id] = m
	return m

static func _v(a) -> Vector3: return Vector3(float(a[0]), float(a[1]), float(a[2])) if a is Array and a.size() == 3 else Vector3.ZERO

static func aus_feld(h: Dictionary) -> Dictionary:
	var hh: Array = h.get("hoehe", [-0.24, 0.24])
	return {"griff": _v(h.get("griff", [0, 0, 0])), "achse": _v(h.get("achse", [0, 1, 0])).normalized(),
		"vorn": _v(h.get("vorn", [0, 0, 1])).normalized(), "spitze": _v(h.get("spitze", [0, 0, 0])), "laenge": float(h.get("laenge", 0.0)),
		"unten": float(h.get("unten", 0.0)), "hoehe": Vector2(float(hh[0]), float(hh[1])), "rand_hinten": float(h.get("rand_hinten", 0.0)),
		"kasten": AABB(_v(h.get("kasten", [0, 0, 0, 0, 0, 0]).slice(0, 3)), _v(h.get("kasten", [0, 0, 0, 0, 0, 0]).slice(3, 6)))}

## als Eintrag für regeln/halt.json (Zahlen auf mm gerundet)
static func als_feld(m: Dictionary) -> Dictionary:
	var r := func(x: float) -> float: return snappedf(x, 0.001)
	var v := func(p: Vector3) -> Array: return [r.call(p.x), r.call(p.y), r.call(p.z)]
	return {"griff": v.call(m["griff"]), "achse": v.call(m["achse"]), "vorn": v.call(m["vorn"]), "spitze": v.call(m["spitze"]),
		"laenge": r.call(m["laenge"]), "unten": r.call(m["unten"]), "hoehe": [r.call(m["hoehe"].x), r.call(m["hoehe"].y)],
		"rand_hinten": r.call(m["rand_hinten"]), "kasten": v.call((m["kasten"] as AABB).position) + v.call((m["kasten"] as AABB).size)}

## aus dem Modell: Ecken aller Netze im Raum des Modells
static func messen(id: String) -> Dictionary:
	var f := datei(id)
	if f == "": return {}
	var d := Gebiet.lade_glb(f)
	if d == null: return {}
	var pts := PackedVector3Array()
	for mi in d.find_children("*", "MeshInstance3D", true, false) + ([d] if d is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		if me == null: continue
		var tr := HeldFigur.im_raum(d, mi)
		for s in me.get_surface_count():
			for p in me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]: pts.append(tr * p)
	d.free()
	var m := mass_aus(pts)
	if not m.is_empty() and not id in BOGEN and String(Katalog.eintrag(id).get("art", "")) == "waffe":
		# waffen.py (Kopf der Datei): „Schneide quer nach ±X, Fläche nach ±Z“; vorn ist die Schneide (Faust: Schneide zu den Knöcheln,
		# wie tragen.gd die Waffe seit 417 stellt), nicht die Fläche. Nur die Schilde (kaufschild.py) zeigen mit +Z nach vorn
		m["vorn"] = Vector3.RIGHT
	if id in BOGEN and not m.is_empty():
		# Chef 10.11., 13:39 (Prüfbild 653: „in der Seitansicht fehlt die Sehne … sieht aus wie ein Stab“): beim Bogen liegen Wurfarme
		# und Sehne in x (waffen.py), nicht in z; vorn ist darum die Seite der Sehne, die Fläche des Bogens steht dann senkrecht
		var sx := signf((m["spitze"] as Vector3).x)
		m["vorn"] = Vector3(sx if sx != 0.0 else -1.0, 0, 0)
	return m

## Maße aus Ecken (Modellregel 4): Griff im Ursprung, Achse +Y, vorn +Z; Spitze = Mitte der Ecken im obersten Zentimeter
static func mass_aus(pts: PackedVector3Array) -> Dictionary:
	if pts.is_empty(): return {}
	var lo := INF; var hi := -INF; var hinten := 0.0
	var kasten := AABB(pts[0], Vector3.ZERO)
	for p in pts:
		lo = minf(lo, p.y); hi = maxf(hi, p.y)
		kasten = kasten.expand(p)
		if absf(p.x) > 0.15: hinten = maxf(hinten, -p.z)
	var sp := Vector3.ZERO; var n := 0
	for p in pts:
		if p.y > hi - 0.01: sp += p; n += 1
	sp /= maxf(1.0, n)
	return {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.BACK, "spitze": sp, "laenge": sp.length(), "unten": maxf(0.0, -lo),
		"hoehe": Vector2(lo, hi), "rand_hinten": hinten, "kasten": kasten}

## Rahmen des Griffs im Raum des Modells: Ursprung am Griff, y = Achse, z = vorn
static func griff_rahmen(m: Dictionary) -> Transform3D:
	var y: Vector3 = m["achse"]
	var z: Vector3 = (m["vorn"] - y * y.dot(m["vorn"])).normalized()
	return Transform3D(Basis(y.cross(z), y, z), m["griff"])

# ---------------------------------------------------------------- Halterungen je Körper
## Plätze: „faust_r“, „faust_l“ (Griff zwischen den Knöcheln von Zeige- und Kleinfinger, Klinge zum Daumen, Schneide zu den Knöcheln),
## „unterarm_l“ (Schild: Fessel in der Faust, Vorderseite nach außen, oben zum Daumen). Ergebnis {knochen, lage}: lage im Raum des
## Knochens in Ruhelage (wie BoneAttachment3D den Knochen führt); leer, wenn der Körper den Platz nicht hat.
## Kaufkörper (hand_r, index_01_r, pinky_01_r, middle_01_r); andere Gerüste folgen mit ihrem Körpertyp (KORREKTUR)
static func halterung(sk: Skeleton3D, platz: String, koerper := "") -> Dictionary:
	var s := platz.right(1)
	var h := sk.find_bone("hand_" + s)
	var z := sk.find_bone("index_01_" + s)
	var k := sk.find_bone("pinky_01_" + s)
	var mf := sk.find_bone("middle_01_" + s)
	if h < 0 or z < 0 or k < 0 or mf < 0: return {}
	var hr := sk.get_bone_global_rest(h).affine_inverse()
	var zf := hr * sk.get_bone_global_rest(z).origin
	var kf := hr * sk.get_bone_global_rest(k).origin
	var mp := hr * sk.get_bone_global_rest(mf).origin
	var griff := (zf + kf) * 0.5
	var achse := (zf - kf).normalized()                      # vom kleinen Finger zum Zeigefinger: der Schaft verlässt die Faust am Daumen
	var knoechel := mp - achse * mp.dot(achse)               # vom Handgelenk zu den Knöcheln, quer zur Achse
	knoechel = knoechel.normalized()
	var b: Basis
	if platz.begins_with("faust"):
		b = Basis(achse.cross(knoechel), achse, knoechel)     # y = Achse, z = Schneide zu den Knöcheln
	elif platz.begins_with("unterarm"):
		# Schild: oben zum Daumen (Achse), Vorderseite vom Handrücken weg (aus dem Handrücken: Knöchel × Achse, je Seite gespiegelt)
		var aussen := (knoechel.cross(achse) * (-1.0 if s == "l" else 1.0)).normalized()
		b = Basis(achse.cross(aussen), achse, aussen)
		griff += aussen * SCHILD_AUSSEN
	else:
		return {}
	var t := Transform3D(b, griff)
	var kor: Array = KORREKTUR.get(koerper, {}).get(platz, [])
	if kor.size() == 4:   # [x, y, z m im Rahmen der Halterung, Drehung um die Achse Grad]
		t = t * Transform3D(Basis(Vector3.UP, deg_to_rad(float(kor[3]))), Vector3(float(kor[0]), float(kor[1]), float(kor[2])))
	return {"knochen": sk.get_bone_name(h), "lage": t}

## Korrektur je Körpertyp und Platz, nie je Paar (Chefsache 653, Gegenargument): {Körpertyp: {Platz: [x, y, z, Grad]}}; das
## Prüfbild (tests/halt_653.gd) zeigt, wo eine nötig ist. Später im Figurenkatalog (649)
## 967 (halt_653 am Rechner, Kaufstand 11.11.: Finger der linken Faust in der Haltung „Stehen“ bis 1,4 cm im Brett, je Körper
## verschieden): der Schild um so viel nach außen, wie die Finger hineinreichen, und 2 mm Luft
const KORREKTUR := {
	"KLOSTER_M": {"unterarm_l": [0.0, 0.0, 0.016, 0.0]}, "KLOSTER_W": {"unterarm_l": [0.0, 0.0, 0.003, 0.0]},
	"WALD_M": {"unterarm_l": [0.0, 0.0, 0.003, 0.0]}, "WALD_W": {"unterarm_l": [0.0, 0.0, 0.005, 0.0]},
}

# ---------------------------------------------------------------- die eine Anlegefunktion
## hängt Gegenstand [id] an [platz] des Körpers (Skelett sk); Lage = Halterung · Griff⁻¹. Gibt das Modell zurück (Kind eines
## BoneAttachment3D namens [name]), null ohne Modell oder Platz. [faktor]: Größe des Gegenstands (Volk, Goblin)
static func anlegen(sk: Skeleton3D, platz: String, id: String, name := "Gehalten", koerper := "", faktor := 1.0) -> Node3D:
	var hl := halterung(sk, platz, koerper)
	var m := gegenstand(id)
	var f := datei(id)
	if hl.is_empty() or m.is_empty() or f == "": return null
	var d := Gebiet.lade_glb(f)
	if d == null: return null
	for alt in sk.get_children():
		if alt is BoneAttachment3D and String(alt.name) == name: alt.free()
	var ba := BoneAttachment3D.new()
	ba.name = name
	ba.bone_name = hl["knochen"]
	ba.set_meta("was", id)
	sk.add_child(ba)
	ba.add_child(d)
	d.transform = lage(hl, m, faktor)
	return d

## Lage des Modells im Raum des Knochens
static func lage(hl: Dictionary, m: Dictionary, faktor := 1.0) -> Transform3D:
	var g := griff_rahmen(m)
	return (hl["lage"] as Transform3D) * Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * faktor), Vector3.ZERO) * g.affine_inverse()
