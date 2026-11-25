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
# 2029 Teil 2 (Auftrag 25.11., 17:16): Helm je Fall in beiden Nackenvarianten (HeldFigur.nacken „A“ kurze Frisur darunter, „B“
# Nackenschirm Helm_Templer_B), also 10 Haar + 5 Bart + 2 x 10 Helm = 35 Faelle, dazu je Helmfall:
#   Nacken: Ecken der Kopfhaut hinten (Tiefe unter NACKEN_Z, ueberwiegend am Kopf; Kopfhaut = was die kuerzeste Frisur Hair_Buzzed an
#           derselben Figur deckt), die weder Helm noch Frisur deckt (Strahl waagrecht aus der Kopfachse) = 0, Ruhe und Hieb
#   A: Ecken der Frisur unter dem Helm ausserhalb der aeussersten Helmflaeche (Durchstechen) = 0
# Gegenstand (4 Faelle): helmet zeigt Helm_Templer, hood, leather_cap, great_helm nicht
# Erschaffung (10 Faelle, 5 Voelker x Mann/Frau): Haar_MH01 nur bei Elf Mann, Bart_Wikinger nur bei Zwerg Mann, alte Wahlen vollzaehlig,
#   jede Wahl mit Wort in HeldFigur.WORTE (2029-Ü17; Zahl der Wahlen und ohne Wort)
# Ohne Kaufmodelle: nur die Stuecke (Bild, Dreiecke), Ende ohne Fehler. Aufruf im Ordner godot: godot --headless -s res://tests/kopfteil_2029.gd
const VOELKER := ["Mensch", "Elf", "Zwerg", "Hügelvolk", "Orkblütiger"]
const DREIECKE := 800
const BILD := 1024
const MITTEL := 0.15
const FLECKEN := 0.05
const LIPPE_X := 0.03
# Helm sitzt (Pruefer 25.11., 14:06): Luft zwischen Kopfhaut ueber der Stirnlinie und Helminnenseite, Nasenschutz am Gesicht. Am Stand
# 711ab74f2 (Helm schwebte im Bild) Luft im Mittel 1,8 bis 2,9 cm in allen 10 Faellen; nach der Behebung 0,6 bis 1,4 cm
const LUFT_MAX := 0.045
const LUFT_MITTEL := 0.015
const NASE := 0.010
const NACKEN_Z := -0.03
# Wahl der Erschaffung vor 2029 Teil 2 (main 8f07379a6, HeldFigur.VOLK_KOPF); die uebrigen Voelker ohne Liste: alle Frisuren und Baerte
const ALT_WAHL := {"ELF_m_frisur": ["Hair_Long", "Hair_LongDreads"], "DWARF_m_bart": ["Bart_Breit,Hair_Moustache"]}
const NEU_WAHL := {"ELF_m_frisur": "Haar_MH01", "DWARF_m_bart": "Bart_Wikinger,Hair_Moustache"}
var haaransatz := {}
var fehler := 0
var stueck_ok := {}   # Kennung_G -> Text, leer = gut
# Pose, wie sie gezeichnet wird: nach den Modifikatoren (KopfHeben), festgehalten in skeleton_updated; danach setzt das Skelett die Pose
# der Bewegung zurueck (get_bone_global_pose ausserhalb gab den Kopf bis 12 Grad gesenkt, die BoneAttachment und das Bild gehoben)
var posen := []

func posen_merken(sk: Skeleton3D) -> void:
	posen = []
	for i in sk.get_bone_count(): posen.append(sk.get_bone_global_pose(i))

func pose(sk: Skeleton3D, i: int) -> Transform3D:
	return posen[i] if i < posen.size() else sk.get_bone_global_pose(i)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	for n in ["Haar_MH01", "Bart_Wikinger", "Helm_Templer", "Helm_Templer_B"]:
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
				# NACKEN=alt,A,B: Varianten (alt = ohne Frisur unter dem Helm wie 685a45298, zum Gegenbeweis); Vorgabe A und B
				for nv in (Array(OS.get_environment("NACKEN").split(",", false)) if OS.get_environment("NACKEN") != "" else ["A", "B"]) if art == "helm" else ["A"]:
					if OS.get_environment("NUR") != "" and OS.get_environment("NUR") != "%s %s %s" % [art, v, g]: continue   # ein Fall (Suche)
					n += 1
					HeldFigur.nacken = nv
					var r := await fall(art, v, g, hieb)
					HeldFigur.nacken = "A"
					var falsch := r.begins_with("!")
					if falsch: fehler += 1
					print("%s %s%s %s %s%s" % ["FALSCH" if falsch else "FALL", art, " " + nv if art == "helm" else "", v, g, r.trim_prefix("!")])
	var ne := erschaffung()
	var ng := gegenstand()
	print("KOPFTEIL2029 %d Faelle, %d Erschaffung, %d Gegenstand, %d falsch" % [n, ne, ng, fehler])
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
		"helm":
			a["helm"] = kenn
			if HeldFigur.nacken == "B": kenn += "_B"
	var ansatz: Dictionary = await haaransatz_von(v, g, b) if art == "helm" else {}
	var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": vm, "aussehen": a, "ausruestung": b.ausruestung}, [])
	if m == null: return "!, FALSCH: keine Figur"
	root.add_child(m)
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	var r := []
	var s := String(stueck_ok.get(kenn + "_" + g.to_upper(), ""))
	if s != "": r.append(s.trim_prefix(" FALSCH: "))
	var ba := m.find_child("Haar_" + kenn, true, false) as BoneAttachment3D
	if ba == null or ba.bone_name != "Head" or ba.get_child_count() == 0:
		m.free(); return "!, FALSCH: %s nicht am Kopfknochen" % kenn
	var mi := ba.get_child(0) as MeshInstance3D
	sk.skeleton_updated.connect(posen_merken.bind(sk))
	if art == "helm":
		for x in m.find_children("Haar_*", "BoneAttachment3D", true, false):
			var hn := String(x.name).substr(5)
			if hn != kenn and not (hn.begins_with("Bart") or hn in ["Hair_Beard", "Hair_Moustache", "Hair_MuttonChops"]):
				if not (HeldFigur.nacken == "A" and hn == HeldFigur.UNTER_HELM): r.append("Haar %s unter dem Helm" % hn)
		if HeldFigur.nacken == "A" and m.find_child("Haar_" + HeldFigur.UNTER_HELM, true, false) == null: r.append("A ohne %s unter dem Helm" % HeldFigur.UNTER_HELM)
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
		var kopf := m.global_transform.affine_inverse() * sk.global_transform * pose(sk, sk.find_bone("Head"))
		var ki := kopf.affine_inverse()
		# folgt dem Kopf: Mitte der Kopfhaut (Ecken nur am Kopf und seinen Kindern, gehaeutet) im Raum des Stuecks, in beiden Posen gleich
		var mil := (m.global_transform.affine_inverse() * mi.global_transform).affine_inverse()
		var mitte := Vector3.ZERO
		var nk := 0
		for hm in haut_netze(m):
			for p in netz(m, hm, mil, true, sk, 0.999): mitte += p; nk += 1
		lage.append(mitte / maxf(1.0, nk))
		var stueck_v := netz(m, mi, ki)
		if art == "helm":
			var hm := helm_mass(m, sk, ki, stueck_v, mi)
			zahlen.append("%s: Kopfhaut ueber der Stirn %d Ecken, ausserhalb %d, Luft groesste %.1f cm, mittlere %.1f cm, Nasenschutz zur Haut %.1f cm" % [
				pose, hm["n"], hm["raus"], hm["luft_max"] * 100.0, hm["luft_mittel"] * 100.0, hm["nase"] * 100.0])
			if hm["n"] == 0: r.append("%s keine Kopfhaut ueber der Stirn gefunden" % pose)
			if hm["raus"] > 0: r.append("%s Kopfhaut sticht durch den Helm (%d Ecken)" % [pose, hm["raus"]])
			if hm["luft_max"] > LUFT_MAX: r.append("%s Helm schwebt (Luft bis %.1f cm)" % [pose, hm["luft_max"] * 100.0])
			if hm["luft_mittel"] > LUFT_MITTEL: r.append("%s Helm sitzt locker (Luft im Mittel %.1f cm)" % [pose, hm["luft_mittel"] * 100.0])
			if hm["nase"] > NASE: r.append("%s Nasenschutz steht vom Gesicht ab (%.1f cm)" % [pose, hm["nase"] * 100.0])
			var deck := [mi]
			var fr := m.find_child("Haar_" + HeldFigur.UNTER_HELM, true, false)
			if fr: deck.append(fr.get_child(0))
			var nk2 := nacken_mass(m, sk, ki, deck, ansatz)
			var sticht := 0
			if fr: sticht = durchstechen(netz(m, fr.get_child(0) as MeshInstance3D, ki), stueck_v, mi, hm["mitte"])
			zahlen.append("Nacken %s: Kopfhaut hinten unter der Frisur %s (Haaransatz %.1f cm ueber dem Kopfknochen) %d Ecken, kahl %d; Frisur durch den Helm %d" % [
				HeldFigur.nacken, HeldFigur.UNTER_HELM, float(ansatz["y"]) * 100.0, nk2["n"], nk2["kahl"], sticht])
			if nk2["n"] == 0: r.append("%s keine Kopfhaut im Nacken gefunden" % pose)
			if nk2["kahl"] > 0: r.append("%s Nacken kahl (%d Ecken)" % [pose, nk2["kahl"]])
			if sticht > 0: r.append("%s Frisur sticht durch den Helm (%d Ecken)" % [pose, sticht])
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
	return ("" if r.is_empty() else "!") + ", Modell %s, %s%s" % [mo, "; ".join(zahlen), "" if r.is_empty() else ", FALSCH: " + "; ".join(r)]

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
			tr.append(ki * raum * pose(sk, maxi(bi, 0)) * x.skin.get_bind_pose(i))
			var j := bi
			while j >= 0:
				if sk.get_bone_name(j) == "Head": kopf[i] = true; break
				j = sk.get_bone_parent(j)
	for s in x.mesh.get_surface_count():
		var a := x.mesh.surface_get_arrays(s)
		var V: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		# Formschluessel wie gezeichnet (Gesicht, Statur, unter_*): Ecke + Gewicht * (Form - Grund) bzw. * Form (relativ)
		var am := x.mesh as ArrayMesh
		if am and am.get_blend_shape_count() > 0:
			var bs := x.mesh.surface_get_blend_shape_arrays(s)
			V = V.duplicate()
			var basis0: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			for bi in mini(bs.size(), am.get_blend_shape_count()):
				var wt := x.get_blend_shape_value(bi)
				if absf(wt) < 0.0001: continue
				var BV: PackedVector3Array = bs[bi][Mesh.ARRAY_VERTEX]
				var rel := am.blend_shape_mode == Mesh.BLEND_SHAPE_MODE_RELATIVE
				for j in mini(V.size(), BV.size()): V[j] += (BV[j] if rel else BV[j] - basis0[j]) * wt
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

# Helm, gemessen ueber der Stirnlinie (Oberkante der Brauen) an den Ecken der Kopfhaut, Strahl aus der Kopfmitte:
#   raus: Ecken ausserhalb der aeussersten Helmflaeche (Durchstechen)
#   luft_max, luft_mittel: Abstand Kopfhaut bis zur naechsten Helmflaeche dahinter (Innenseite), groesster und mittlerer (Pruefer
#     25.11., 14:06: im Bild 711ab74f2 schwebte der Helm, Durchstechen allein belegt den Sitz nicht)
#   nase: groesster Abstand einer Ecke des Nasenschutzes (|x| < 1,2 cm, unter der Stirnlinie, vorn) zur naechsten Ecke der Kopfhaut
func helm_mass(m: Node3D, sk: Skeleton3D, ki: Transform3D, hv: PackedVector3Array, hm: MeshInstance3D) -> Dictionary:
	var stirn := -9.0
	for x in m.find_children("Eyebrows*", "MeshInstance3D", true, false):
		if (x as MeshInstance3D).is_visible_in_tree():
			for p in netz(m, x as MeshInstance3D, ki, false, sk): stirn = maxf(stirn, p.y)
	var alle := PackedVector3Array()
	var haut := PackedVector3Array()
	for mi in haut_netze(m):
		for p in netz(m, mi, ki, true, sk):
			alle.append(p)
			if p.y > stirn: haut.append(p)
	var r := {"n": haut.size(), "raus": 0, "luft_max": 0.0, "luft_mittel": 0.0, "nase": 0.0, "mitte": Vector3.ZERO}
	if haut.is_empty() or stirn < -8.0: return r
	var c := Vector3.ZERO
	for p in haut: c += p
	c /= haut.size()
	c.y = stirn
	r["mitte"] = c
	var ix: PackedInt32Array = hm.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX]
	var summe := 0.0
	var innen := 0
	for p in haut:
		var d := (p - c).normalized()
		var l := (p - c).length()
		var weit := -1.0
		var nah := 9.0
		for i in range(0, ix.size(), 3):
			var t = Geometry3D.ray_intersects_triangle(c, d, hv[ix[i]], hv[ix[i + 1]], hv[ix[i + 2]])
			if t == null: continue
			var e := ((t as Vector3) - c).length()
			weit = maxf(weit, e)
			if e >= l - 0.001: nah = minf(nah, e)
		if weit < l: r["raus"] += 1
		elif nah < 8.0:
			r["luft_max"] = maxf(r["luft_max"], nah - l)
			summe += nah - l
			innen += 1
	r["luft_mittel"] = summe / maxf(1.0, innen)
	for q in hv:
		if absf(q.x) > 0.012 or q.y > stirn - 0.01 or q.z < 0.0: continue
		var best := 9.0
		for p in alle: best = minf(best, p.distance_to(q))
		r["nase"] = maxf(r["nase"], best)
	return r

# Kopfhaut im Nacken (Raum des Kopfknochens) = was die kuerzeste Frisur HeldFigur.UNTER_HELM deckt: ihre Dreiecke an derselben Figur
# (Helm, Variante A), Ruhepose wie gezeichnet (starr am Kopf, in jeder Pose gleich), und ihre Unterkante hinten (|x| < 3 cm) als Haaransatz
func haaransatz_von(v: String, g: String, b: BrsHeld) -> Dictionary:
	var k := v + g
	if haaransatz.has(k): return haaransatz[k]
	var vm := HeldFigur.volk_modell(v)
	var a := HeldFigur.vorgabe("Wachsoldat", g, vm)
	a["helm"] = "Helm_Templer"   # ohne Helm setzte die Volksregel (Elf, Zwergin) eine andere Frisur; Lage der Frisur haengt nicht am Helm
	var nv := HeldFigur.nacken
	HeldFigur.nacken = "A"
	var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": vm, "aussehen": a, "ausruestung": b.ausruestung}, [])
	HeldFigur.nacken = nv
	var r := {"y": 9.0, "tri": []}
	if m:
		root.add_child(m)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		sk.skeleton_updated.connect(posen_merken.bind(sk))   # Raum des Kopfknochens wie gezeichnet, wie in fall()
		ap.play("Stehen")
		ap.seek(0.0, true)
		ap.pause()
		for i in 3: await process_frame
		var ki := (m.global_transform.affine_inverse() * sk.global_transform * pose(sk, sk.find_bone("Head"))).affine_inverse()
		var fr := m.find_child("Haar_" + HeldFigur.UNTER_HELM, true, false)
		if fr:
			r["tri"] = dreiecke(m, [fr.get_child(0)], ki)
			for p in netz(m, fr.get_child(0) as MeshInstance3D, ki):
				if p.z < NACKEN_Z and absf(p.x) < 0.03: r["y"] = minf(r["y"], p.y)
		m.free()
	haaransatz[k] = r
	return r

# Dreiecke von Netzen im Raum ki (netz() reiht die Flaechen aneinander)
func dreiecke(m: Node3D, netze: Array, ki: Transform3D) -> Array:
	var tri := []
	for d in netze:
		var v := netz(m, d as MeshInstance3D, ki)
		var am := (d as MeshInstance3D).mesh
		var o := 0
		for s in am.get_surface_count():
			var ix: PackedInt32Array = am.surface_get_arrays(s)[Mesh.ARRAY_INDEX]
			if ix.is_empty(): ix = PackedInt32Array(range(am.surface_get_array_len(s)))
			for i in range(0, ix.size(), 3): tri.append([v[o + ix[i]], v[o + ix[i + 1]], v[o + ix[i + 2]]])
			o += am.surface_get_array_len(s)
	return tri

# Strahl aus o in Richtung d trifft ein Dreieck an oder hinter dem Abstand l
func trifft(tri: Array, o: Vector3, d: Vector3, l: float) -> bool:
	for t in tri:
		var h = Geometry3D.ray_intersects_triangle(o, d, t[0], t[1], t[2])
		if h != null and ((h as Vector3) - o).length() >= l - 0.001: return true
	return false

# Nacken: Ecken der Kopfhaut hinten (Tiefe unter NACKEN_Z), die die kuerzeste Frisur decken wuerde (ref); kahl = kein Dreieck der
# deckenden Netze dieser Figur (Helm, Frisur) auf dem waagrechten Strahl aus der Kopfachse durch die Ecke an oder hinter ihr
func nacken_mass(m: Node3D, sk: Skeleton3D, ki: Transform3D, deck: Array, ref: Dictionary) -> Dictionary:
	var tri := dreiecke(m, deck, ki)
	var alle := PackedVector3Array()
	var c := Vector3.ZERO
	for hm in haut_netze(m):
		for p in netz(m, hm, ki, true, sk):
			if p.y > float(ref["y"]):
				c += p
				alle.append(p)
	c /= maxf(1.0, alle.size())
	var n := 0
	var kahl := 0
	for p in alle:
		if p.z >= NACKEN_Z: continue
		var o := Vector3(c.x, p.y, c.z)
		var d := (p - o).normalized()
		var l := (p - o).length()
		if not trifft(ref["tri"], o, d, l): continue   # keine Kopfhaut (Hals unter dem Haaransatz, Inneres)
		n += 1
		if not trifft(tri, o, d, l):
			kahl += 1
			if OS.has_environment("NACKEN_ZEIGEN"): print("KAHL %.3f %.3f %.3f l %.3f" % [p.x, p.y, p.z, l])
	return {"n": n, "kahl": kahl}

# Ecken der Frisur ausserhalb der aeussersten Helmflaeche (Strahl aus der Kopfmitte auf Hoehe der Stirnlinie wie helm_mass); Ecken, deren
# Strahl den Helm nicht trifft (unter dem Rand), zaehlen nicht
func durchstechen(fv: PackedVector3Array, hv: PackedVector3Array, hm: MeshInstance3D, c: Vector3) -> int:
	var ix: PackedInt32Array = hm.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX]
	var raus := 0
	for p in fv:
		var d := (p - c).normalized()
		var l := (p - c).length()
		var weit := -1.0
		for i in range(0, ix.size(), 3):
			var t = Geometry3D.ray_intersects_triangle(c, d, hv[ix[i]], hv[ix[i + 1]], hv[ix[i + 2]])
			if t != null: weit = maxf(weit, ((t as Vector3) - c).length())
		if weit >= 0.0 and weit < l:
			raus += 1
			if OS.has_environment("NACKEN_ZEIGEN"): print("STICHT %.3f %.3f %.3f um %.1f mm" % [p.x, p.y, p.z, (l - weit) * 1000.0])
	return raus

# Erschaffung: Wahl je Volk und Geschlecht (HeldFigur.frisuren, baerte wie erschaffung_brs.gd); neue Stuecke nur bei Elf Mann (Haar) und
# Zwerg Mann (Bart), alte Wahlen vollzaehlig
func erschaffung() -> int:
	var n := 0
	var wahlen := 0
	var ohne_wort := 0
	for v in VOELKER:
		var vm := HeldFigur.volk_modell(v)
		for g in ["m", "w"]:
			n += 1
			var r := []
			var zahl := []
			for teil in ["frisur", "bart"]:
				var l: Array = HeldFigur.frisuren(g, vm) if teil == "frisur" else HeldFigur.baerte(g, vm)
				var key := "%s_%s_%s" % [vm, g, teil]
				var neu := String(NEU_WAHL.get(key, ""))
				var alt: Array = ALT_WAHL.get(key, [])
				if alt.is_empty():   # ohne Liste: Wahl wie vor Teil 2 aus held-klassen.json (geschlechter haare, baerte)
					alt = (Array(HeldFigur.geschlecht_info(g).get("haare", [])) + [""]) if teil == "frisur" else ([""] + Array(HeldFigur.geschlecht_info(g).get("baerte", [])))
					alt = HeldFigur._volk_filter(alt, vm, g, teil) if not ALT_WAHL.has(key) and HeldFigur.VOLK_KOPF.get(vm, {}).get(g, {}).has(teil) else alt
				for x in alt: if x not in l: r.append("%s %s fehlt" % [teil, x])
				for x in l:
					if x in alt: continue
					if x != neu: r.append("%s %s neu, nicht erwartet" % [teil, x])
				if neu != "" and neu not in l: r.append("%s %s fehlt (neu)" % [teil, neu])
				for x in (l if l.size() >= 2 else []):   # 2029-Ü17: jede Wahl zeigt ein Wort aus WORTE, nie die Kennung (Knoepfe nur ab 2 Wahlen, erschaffung_brs.gd)
					wahlen += 1
					if not HeldFigur.WORTE.has(teil + ":" + x):
						ohne_wort += 1
						r.append("%s %s ohne Wort" % [teil, x])
				zahl.append("%s alt %d neu %d" % [teil, alt.size(), l.size()])
			if not r.is_empty(): fehler += 1
			print("%s erschaffung %s %s %s%s" % ["FALSCH" if not r.is_empty() else "FALL", v, g, ", ".join(zahl), "" if r.is_empty() else ", FALSCH: " + "; ".join(r)])
	print("KOPFTEIL2029 Erschaffung: %d Wahlen, %d ohne Wort" % [wahlen, ohne_wort])
	return n

# Gegenstand auf dem Kopf (Mensch Mann Wachsoldat, ohne aussehen „helm“): helmet zeigt Helm_Templer mit der Frisur der Nackenregel,
# die anderen Kopfgegenstaende keinen starren Helm
func gegenstand() -> int:
	var n := 0
	for kopf in ["helmet", "hood", "leather_cap", "great_helm"]:
		n += 1
		var b := BrsHeld.neu("Mensch", "Wachsoldat")
		b.ausstatten()
		var aus := b.ausruestung.duplicate()
		aus["HEAD"] = {"base": kopf}
		var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": "HUMAN", "aussehen": HeldFigur.vorgabe("Wachsoldat", "m"), "ausruestung": aus}, [])
		if m == null: fehler += 1; print("FALSCH gegenstand %s keine Figur" % kopf); continue
		var helm := m.find_child("Haar_Helm_Templer", true, false) != null
		var fr := m.find_child("Haar_" + HeldFigur.UNTER_HELM, true, false) != null
		var gut: bool = helm == (kopf == "helmet") and (fr or kopf != "helmet")
		if not gut: fehler += 1
		print("%s gegenstand %s: Helm_Templer %s, %s %s" % ["FALL" if gut else "FALSCH", kopf, "ja" if helm else "nein", HeldFigur.UNTER_HELM, "ja" if fr else "nein"])
		m.free()
	return n

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
