class_name Halt
extends RefCounted
# 653 (Chef 08.11., 14:35/14:40, „653 ja“; „jetzt“ 10.11., 12:33): Halt für Waffen und Schilde einmal je Modell statt je Figur:
#  1. Griff je Gegenstand: wo die Hand greift, wohin der Schaft läuft (achse), wohin Schneide oder Vorderseite zeigt (vorn), Spitze,
#     Ober- und Unterkante; aus dem Modell abgelesen (Modellregel 4 wie waffen.py und kaufschild.py: Ursprung = Griff bzw. Fessel,
#     Schaft nach +Y, Vorderseite nach +Z) und im Gegenstandskatalog als Feld „halt“ abgelegt (tests/halt_653.gd schreibt es).
#  2. Halterung je Körper: rechte und linke Faust, Unterarm (Schild), aus dem Skelett des Körpers; Korrektur je Körpertyp, nie je Paar.
#  3. Eine Anlegefunktion (anlegen): Lage = Halterung des Körpers · Griff des Gegenstands, keine Zahlen je Paar.
# Jerry (709, 845) liest Spitze und Länge aus gegenstand() statt je Gegner zu messen.

const WAFFEN := "res://daten/waffen/%s.bin"
const KAMPF := "res://kampf/daten/%s.bin"

static var _mass := {}            # Kennung -> Maße (Zwischenspeicher)

## Datei des Modells: daten/waffen (Karte, Held, Leute), sonst kampf/daten (Kampf); leer, wenn keins da ist
static func datei(id: String) -> String:
	for f in [WAFFEN % id, KAMPF % id]:
		if FileAccess.file_exists(f): return f
	return ""

## Maße des Gegenstands im Raum seines Modells (m): griff, achse, vorn (Vector3), spitze (Vector3, weitestes Ende längs der Achse),
## laenge (Griff bis Spitze), unten (Länge unter dem Griff), hoehe (Vector2 unten/oben in y), rand_hinten (Schild: wie weit der Rand
## außerhalb der Mitte hinter die Fessel reicht). Zuerst der Katalog („halt“), sonst aus dem Modell gemessen; leer ohne Modell
static func gegenstand(id: String) -> Dictionary:
	if _mass.has(id): return _mass[id]
	var h = Katalog.eintrag(id).get("halt") if Katalog.hat(id) else null
	var m: Dictionary = aus_feld(h) if h is Dictionary else messen(id)
	if not m.is_empty(): _mass[id] = m
	return m

static func _v(a) -> Vector3: return Vector3(float(a[0]), float(a[1]), float(a[2])) if a is Array and a.size() == 3 else Vector3.ZERO

static func aus_feld(h: Dictionary) -> Dictionary:
	var hh: Array = h.get("hoehe", [-0.24, 0.24])
	return {"griff": _v(h.get("griff", [0, 0, 0])), "achse": _v(h.get("achse", [0, 1, 0])).normalized(),
		"vorn": _v(h.get("vorn", [0, 0, 1])).normalized(), "spitze": _v(h.get("spitze", [0, 0, 0])), "laenge": float(h.get("laenge", 0.0)),
		"unten": float(h.get("unten", 0.0)), "hoehe": Vector2(float(hh[0]), float(hh[1])), "rand_hinten": float(h.get("rand_hinten", 0.0))}

## als Feld für den Katalog (Zahlen auf mm gerundet)
static func als_feld(m: Dictionary) -> Dictionary:
	var r := func(x: float) -> float: return snappedf(x, 0.001)
	var v := func(p: Vector3) -> Array: return [r.call(p.x), r.call(p.y), r.call(p.z)]
	return {"griff": v.call(m["griff"]), "achse": v.call(m["achse"]), "vorn": v.call(m["vorn"]), "spitze": v.call(m["spitze"]),
		"laenge": r.call(m["laenge"]), "unten": r.call(m["unten"]), "hoehe": [r.call(m["hoehe"].x), r.call(m["hoehe"].y)],
		"rand_hinten": r.call(m["rand_hinten"])}

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
	return mass_aus(pts)

## Maße aus Ecken (Modellregel 4): Griff im Ursprung, Achse +Y, vorn +Z; Spitze = Mitte der Ecken im obersten Zentimeter
static func mass_aus(pts: PackedVector3Array) -> Dictionary:
	if pts.is_empty(): return {}
	var lo := INF; var hi := -INF; var hinten := 0.0
	for p in pts:
		lo = minf(lo, p.y); hi = maxf(hi, p.y)
		if absf(p.x) > 0.15: hinten = maxf(hinten, -p.z)
	var sp := Vector3.ZERO; var n := 0
	for p in pts:
		if p.y > hi - 0.01: sp += p; n += 1
	sp /= maxf(1.0, n)
	return {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.BACK, "spitze": sp, "laenge": sp.length(), "unten": maxf(0.0, -lo),
		"hoehe": Vector2(lo, hi), "rand_hinten": hinten}

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
		var aussen := (knoechel.cross(achse) * (1.0 if s == "l" else -1.0)).normalized()
		b = Basis(achse.cross(aussen), achse, aussen)
	else:
		return {}
	var t := Transform3D(b, griff)
	var kor: Array = KORREKTUR.get(koerper, {}).get(platz, [])
	if kor.size() == 4:   # [x, y, z m im Rahmen der Halterung, Drehung um die Achse Grad]
		t = t * Transform3D(Basis(Vector3.UP, deg_to_rad(float(kor[3]))), Vector3(float(kor[0]), float(kor[1]), float(kor[2])))
	return {"knochen": sk.get_bone_name(h), "lage": t}

## Korrektur je Körpertyp und Platz, nie je Paar (Chefsache 653, Gegenargument): {Körpertyp: {Platz: [x, y, z, Grad]}}; das
## Prüfbild (tests/halt_653.gd) zeigt, wo eine nötig ist. Später im Figurenkatalog (649)
const KORREKTUR := {}

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
