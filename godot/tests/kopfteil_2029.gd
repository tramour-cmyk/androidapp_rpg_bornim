extends SceneTree
# 2029 (Chef 25.11., 12:37, Votum A zu 2026): starre Kopfteile aus den MakeHuman-Paketen (HeldFigur.KOPFTEILE, kopfteil_mh.py) auf
# unseren Figuren, ueber alle Faelle: Haar_MH01 und Helm_Templer auf 5 Voelkern x Mann/Frau, Bart_Wikinger (mit Hair_Moustache) auf
# 5 Voelkern Mann = 25 Faelle, Herkunft Wachsoldat mit Startausruestung. Je Fall gemessen am gezeichneten Netz (Ecken auf der CPU
# gehaeutet, im Raum des Kopfknochens) in der Ruhepose („Stehen“, Bild 0) und im Endbild des Hiebs (Kampfbewegung „Hieb“ wie im
# Kampfort, kampf/figur.gd _kaufheld):
#   Kopf: Stueck haengt am Kopfknochen und folgt ihm (Lage zum Kopf in beiden Posen gleich, 2 mm)
#   Helm: Ecken der Kopfhaut (Haut, ueberwiegend am Kopf) ueber der Stirnlinie (Oberkante der Brauen) ausserhalb des Helms = 0
#         (Strahl aus der Kopfmitte, aeusserste Helmflaeche); Haar unter dem Helm weg (keine Frisur am Kopf)
#   Bart: keine Ecke im Gesicht ueber der Oberlippe (Oberkante Hair_Moustache, |x| < 3 cm)
#   Stueck: Dreiecke <= 800, Bild <= 1024 px, Bildmittel >= 0,15, Flecken (wie zopf_431) < 5 %
# Ohne Kaufmodelle: nur die Stuecke (Bild, Dreiecke), Ende ohne Fehler. Aufruf im Ordner godot: godot --headless -s res://tests/kopfteil_2029.gd
const VOELKER := ["Mensch", "Elf", "Zwerg", "Hügelvolk", "Orkblütiger"]
const DREIECKE := 800
const BILD := 1024
const MITTEL := 0.15
const FLECKEN := 0.05
const LIPPE_X := 0.03
var fehler := 0
var stueck_ok := {}   # Kennung_G -> Text, leer = gut

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	for n in ["Haar_MH01", "Bart_Wikinger", "Helm_Templer"]:
		for g in ["M", "W"]:
			stueck_ok[n + "_" + g] = stueck(n, g)
	if not HeldFigur.da():
		var f := stueck_ok.values().filter(func(x): return x != "").size()
		print("KOPFTEIL2029 ohne Kaufmodelle: %d Stuecke, %d falsch" % [stueck_ok.size(), f])
		quit(1 if f > 0 else 0); return
	var hieb := hieb_laden()
	var n := 0
	for art in ["haar", "helm", "bart"]:
		for v in VOELKER:
			for g in (["m"] if art == "bart" else ["m", "w"]):
				n += 1
				var r := await fall(art, v, g, hieb)
				if r != "": fehler += 1
				print("%s %s %s %s%s" % ["FALL" if r == "" else "FALSCH", art, v, g, r])
	print("KOPFTEIL2029 %d Faelle, %d falsch" % [n, fehler])
	quit(1 if fehler > 0 else 0)

# Bild und Netz eines Stuecks: Text mit den Zahlen; „ FALSCH: …“ am Ende, wenn eine Grenze reisst
func stueck(n: String, g: String) -> String:
	var q := HeldFigur.kopfteil(n, g)
	if q == null: return " FALSCH: %s_%s fehlt" % [n, g]
	var a := q.mesh.surface_get_arrays(0)
	var ix: PackedInt32Array = a[Mesh.ARRAY_INDEX]
	var uv: PackedVector2Array = a[Mesh.ARRAY_TEX_UV]
	var tri := ix.size() / 3
	var mat := q.mesh.surface_get_material(0) as BaseMaterial3D
	var img := mat.albedo_texture.get_image() if mat and mat.albedo_texture else null
	if img == null: return " FALSCH: %s_%s ohne Bild" % [n, g]
	if img.is_compressed(): img.decompress()
	var w := img.get_width(); var h := img.get_height()
	var l := PackedFloat32Array()
	for i in range(0, ix.size(), 3):
		var c := (uv[ix[i]] + uv[ix[i + 1]] + uv[ix[i + 2]]) / 3.0
		l.append(img.get_pixel(clampi(int(fposmod(c.x, 1.0) * w), 0, w - 1), clampi(int(fposmod(c.y, 1.0) * h), 0, h - 1)).get_luminance())
	var mittel := 0.0
	for x in l: mittel += x
	mittel /= maxf(1.0, l.size())
	var fl := 0
	for x in l: if x < 0.4 * mittel or x > 1.6 * mittel: fl += 1
	var anteil := float(fl) / maxf(1.0, l.size())
	var r := []
	if tri > DREIECKE: r.append("Dreiecke %d" % tri)
	if maxi(w, h) > BILD: r.append("Bild %d px" % maxi(w, h))
	if mittel < MITTEL: r.append("Bildmittel %.3f" % mittel)
	if anteil >= FLECKEN: r.append("Flecken %.1f %%" % (anteil * 100.0))
	var t := "%s_%s: %d Dreiecke, Bild %dx%d, Mittel %.3f, Flecken %.1f %%" % [n, g, tri, w, h, mittel, anteil * 100.0]
	print("STUECK %s%s" % [t, "" if r.is_empty() else " FALSCH: " + ", ".join(r)])
	return "" if r.is_empty() else " FALSCH: " + ", ".join(r)

func fall(art: String, v: String, g: String, hieb: Animation) -> String:
	var b := BrsHeld.neu(v, "Wachsoldat")
	b.ausstatten()
	var vm := HeldFigur.volk_modell(v)
	var a := HeldFigur.vorgabe("Wachsoldat", g, vm)
	var kenn := {"haar": "Haar_MH01", "bart": "Bart_Wikinger", "helm": "Helm_Templer"}[art] as String
	match art:
		"haar": a["frisur"] = kenn
		"bart": a["bart"] = "Bart_Wikinger,Hair_Moustache"
		"helm": a["helm"] = kenn
	var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": vm, "aussehen": a, "ausruestung": b.ausruestung}, [])
	if m == null: return " FALSCH: keine Figur"
	root.add_child(m)
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	var r := []
	var s := String(stueck_ok.get(kenn + "_" + g.to_upper(), ""))
	if s != "": r.append(s.trim_prefix(" FALSCH: "))
	var ba := m.find_child("Haar_" + kenn, true, false) as BoneAttachment3D
	if ba == null or ba.bone_name != "Head" or ba.get_child_count() == 0:
		m.free(); return " FALSCH: %s nicht am Kopfknochen" % kenn
	var mi := ba.get_child(0) as MeshInstance3D
	if art == "helm":
		for x in m.find_children("Haar_*", "BoneAttachment3D", true, false):
			var hn := String(x.name).substr(5)
			if hn != kenn and not (hn.begins_with("Bart") or hn in ["Hair_Beard", "Hair_Moustache", "Hair_MuttonChops"]): r.append("Haar %s unter dem Helm" % hn)
	if hieb and not ap.has_animation("Hieb_2029"):
		ap.get_animation_library("").add_animation("Hieb_2029", hieb_fuer(hieb, m, sk))
	var lage := []
	var zahlen := []
	for pose in ["Stehen", "Hieb_2029"]:
		if not ap.has_animation(pose):
			r.append("keine Pose " + pose); continue
		ap.play(pose)
		ap.seek(0.0 if pose == "Stehen" else ap.get_animation(pose).length, true)
		ap.pause()
		for i in 3: await process_frame
		var kopf := m.global_transform.affine_inverse() * sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head"))
		var ki := kopf.affine_inverse()
		if OS.get_environment("K29_DEBUG") != "": print("DBG %s ba %s\n    kopf %s\n    override %s" % [pose, m.global_transform.affine_inverse() * ba.global_transform, kopf, ba.override_pose])
		# folgt dem Kopf: Mitte der Kopfhaut (Ecken nur am Kopf und seinen Kindern, gehaeutet) im Raum des Stuecks, in beiden Posen gleich
		var mil := (m.global_transform.affine_inverse() * mi.global_transform).affine_inverse()
		var mitte := Vector3.ZERO
		var nk := 0
		for hm in haut_netze(m):
			for p in netz(m, hm, mil, true, sk, 0.999): mitte += p; nk += 1
		lage.append(mitte / maxf(1.0, nk))
		var stueck_v := netz(m, mi, ki)
		if art == "helm":
			var raus := helm_raus(m, sk, ki, stueck_v, mi)
			zahlen.append("%s: Kopfhaut ueber der Stirn %d Ecken, ausserhalb %d" % [pose, raus.x, raus.y])
			if raus.x == 0: r.append("%s keine Kopfhaut ueber der Stirn gefunden" % pose)
			if raus.y > 0: r.append("%s Kopfhaut sticht durch den Helm (%d Ecken)" % [pose, raus.y])
		elif art == "bart":
			var ms := m.find_child("Haar_Hair_Moustache", true, false)
			if ms == null: r.append("ohne Schnauzbart"); continue
			var lippe := -9.0
			for p in netz(m, ms.get_child(0) as MeshInstance3D, ki): lippe = maxf(lippe, p.y)
			var im_gesicht := 0
			for p in stueck_v: if p.y > lippe + 0.002 and absf(p.x) < LIPPE_X and p.z > 0.0: im_gesicht += 1
			zahlen.append("%s: Bartecken ueber der Oberlippe im Gesicht %d" % [pose, im_gesicht])
			if im_gesicht > 0: r.append("%s Bart im Gesicht (%d Ecken)" % [pose, im_gesicht])
		else:
			zahlen.append("%s: %d Ecken am Kopf" % [pose, stueck_v.size()])
	if lage.size() == 2:
		var d: float = (lage[0] as Vector3).distance_to(lage[1])
		zahlen.append("Kopf gegen Stueck Ruhe/Hieb %.4f m" % d)
		if d > 0.002: r.append("folgt dem Kopf nicht (%.4f m)" % d)
	var mo := String(m.get_meta("tracht", ""))
	m.free()
	return ", Modell %s, %s%s" % [mo, "; ".join(zahlen), "" if r.is_empty() else ", FALSCH: " + "; ".join(r)]

# Ecken eines Netzes im Raum des Kopfknochens: gehaeutet (Skelett mal Bindung, nach Gewicht) oder starr (am Kopf)
func netz(m: Node3D, x: MeshInstance3D, ki: Transform3D, nur_kopf := false, sk: Skeleton3D = null, anteil := 0.5) -> PackedVector3Array:
	var out := PackedVector3Array()
	var tm := ki * m.global_transform.affine_inverse() * x.global_transform
	var tr := []
	var kopf := {}
	if x.skin and sk:
		var raum := m.global_transform.affine_inverse() * sk.global_transform
		for i in x.skin.get_bind_count():
			var bn := String(x.skin.get_bind_name(i))
			var bi := sk.find_bone(bn) if bn != "" else x.skin.get_bind_bone(i)
			tr.append(ki * raum * sk.get_bone_global_pose(maxi(bi, 0)) * x.skin.get_bind_pose(i))
			var j := bi
			while j >= 0:
				if sk.get_bone_name(j) == "Head": kopf[i] = true; break
				j = sk.get_bone_parent(j)
	for s in x.mesh.get_surface_count():
		var a := x.mesh.surface_get_arrays(s)
		var V: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		if tr.is_empty():
			for p in V: out.append(tm * p)
			continue
		var B = a[Mesh.ARRAY_BONES]
		var W = a[Mesh.ARRAY_WEIGHTS]
		if B == null or W == null or V.is_empty(): continue
		var k := int(B.size() / V.size())
		for j in V.size():
			var p := Vector3.ZERO
			var ws := 0.0
			var wk := 0.0
			for e in k:
				var wt: float = W[j * k + e]
				if wt <= 0.0: continue
				p += (tr[B[j * k + e]] as Transform3D) * V[j] * wt
				ws += wt
				if kopf.has(B[j * k + e]): wk += wt
			if ws <= 0.0 or (nur_kopf and wk < anteil * ws): continue
			out.append(p / ws)
	return out

# sichtbare Hautnetze (Material wie HeldFigur.toene: Regular, Superhero)
func haut_netze(m: Node3D) -> Array:
	var l := []
	for x in m.find_children("*", "MeshInstance3D", true, false):
		var mi := x as MeshInstance3D
		if not mi.is_visible_in_tree() or mi.skin == null: continue
		var src := mi.mesh.surface_get_material(0)
		var rn := String(src.resource_name) if src else ""
		if rn.contains("Regular") or rn.contains("Superhero"): l.append(mi)
	return l

# Helm: Ecken der Kopfhaut ueber der Stirnlinie (x) und davon ausserhalb der aeussersten Helmflaeche (y), Strahl aus der Kopfmitte
func helm_raus(m: Node3D, sk: Skeleton3D, ki: Transform3D, hv: PackedVector3Array, hm: MeshInstance3D) -> Vector2i:
	var stirn := -9.0
	for x in m.find_children("Eyebrows*", "MeshInstance3D", true, false):
		if (x as MeshInstance3D).is_visible_in_tree():
			for p in netz(m, x as MeshInstance3D, ki, false, sk): stirn = maxf(stirn, p.y)
	var haut := PackedVector3Array()
	for mi in haut_netze(m):
		for p in netz(m, mi, ki, true, sk): if p.y > stirn: haut.append(p)
	if haut.is_empty() or stirn < -8.0: return Vector2i(0, 0)
	var c := Vector3.ZERO
	for p in haut: c += p
	c /= haut.size()
	c.y = stirn
	var ix: PackedInt32Array = hm.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX]
	var raus := 0
	for p in haut:
		var d := (p - c).normalized()
		var weit := -1.0
		for i in range(0, ix.size(), 3):
			var t = Geometry3D.ray_intersects_triangle(c, d, hv[ix[i]], hv[ix[i + 1]], hv[ix[i + 2]])
			if t != null: weit = maxf(weit, ((t as Vector3) - c).length())
		if weit < (p - c).length():
			raus += 1
			if OS.get_environment("K29_DEBUG") != "": print("RAUS %s stirn %.3f c %s weit %.3f" % [p, stirn, c, weit])
	return Vector2i(haut.size(), raus)

# Kampfbewegung „Hieb“ aus kampf-bewegungen.bin, wie kampf/figur.gd _kaufheld auf das Geruest des Helden umgesetzt
func hieb_laden() -> Animation:
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin"): return null
	var sc := Gebiet.lade_glb("res://daten/kampf-bewegungen.bin")
	var ap := Gebiet.finde(sc, "AnimationPlayer") as AnimationPlayer
	var an: Animation = ap.get_animation("Hieb").duplicate(true) if ap and ap.has_animation("Hieb") else null
	sc.free()
	if an == null: print("KOPFTEIL2029 ohne Hieb in kampf-bewegungen.bin")
	return an

func hieb_fuer(src: Animation, m: Node3D, sk: Skeleton3D) -> Animation:
	var an := src.duplicate(true) as Animation
	var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / HeldFigur.bew_becken
	var pfad := str(HeldFigur._pfad(m, sk))
	for t in range(an.get_track_count() - 1, -1, -1):
		var bn := String(an.track_get_path(t)).get_slice(":", 1)
		an.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
		var ty := an.track_get_type(t)
		if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]) or sk.find_bone(bn) < 0:
			an.remove_track(t)
		elif ty == Animation.TYPE_POSITION_3D:
			for i in an.track_get_key_count(t): an.track_set_key_value(t, i, an.track_get_key_value(t, i) * f)
	an.loop_mode = Animation.LOOP_NONE
	return an
