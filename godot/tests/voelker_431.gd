extends SceneTree
# 431 Schritt 2 (Auftrag 24.11., 08:31): der Held auf dem Koerper seines Volkes ueber alle Faelle, 5 Voelker x 2 Geschlechter x
# 8 Herkuenfte = 80 (Nachbesserung 24.11., 19:47: dazu Bart, Haar, Hautton, Vorschau in wahrer Groesse, Kniewinkel), je mit der Startausruestung der Herkunft (BrsHeld). Je Fall: Modell des Volkes (nicht der Menschenkoerper),
# Groesse gegen LISTE-FIGUREN.md „Voelker“ (Frau 7 % kleiner), Fuesse am Boden. Gemessen am gezeichneten Netz in „Stehen“ (Bild 0,
# mit Haltung und Kopfheben, wie die Erschaffung zeigt): Scheitel = hoechste Ecke der Haut (ohne Haar, Helm, Kapuze), Sohle = tiefste
# Ecke aller sichtbaren Netze; Ecken auf der CPU gehaeutet (Skelett mal Bindung), ohne Formschluessel.
# Ohne Kaufmodelle: eine Zeile, Ende ohne Fehler. Aufruf im Ordner godot: godot --headless -s res://tests/voelker_431.gd
const VOELKER := ["Mensch", "Elf", "Zwerg", "Hügelvolk", "Orkblütiger"]
const ZIEL := {"Mensch": 1.75, "Elf": 1.72, "Zwerg": 1.35, "Hügelvolk": 1.05, "Orkblütiger": 1.85}   # LISTE-FIGUREN.md „Völker“
const FRAU := 0.93
const GROESSE_TOL := 0.03   # Anteil
const BODEN_TOL := 0.03     # m

var fehler := 0

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if not HeldFigur.da():
		print("VOELKER431 ohne Kaufmodelle, nichts zu pruefen"); quit(0); return
	var n := 0
	var volk_ok := 0
	for v in VOELKER:
		for g in ["m", "w"]:
			for h in BrsHeld.herkuenfte():
				var b := BrsHeld.neu(v, h)
				b.ausstatten()   # wie die Erschaffung (held())
				var vm := HeldFigur.volk_modell(v)
				var w := {"herkunft": h, "volk": vm, "aussehen": HeldFigur.vorgabe(h, g, vm), "ausruestung": b.ausruestung}
				var m := HeldFigur.baue(w, [])
				n += 1
				if m == null:
					fehler += 1; print("FALSCH %s %s %s: keine Figur" % [v, g, h]); continue
				root.add_child(m)
				var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
				if ap and ap.has_animation("Stehen"):
					ap.play("Stehen"); ap.seek(0.0, true)
				for i in 3: await process_frame
				var mo := String(m.get_meta("tracht", ""))
				if h == "Wachsoldat" and v in ["Mensch", "Zwerg"]:   # 431 Nachbesserung: Kniewinkel am Netz, Mensch zum Vergleich
					var kw := knie(m)
					print("KNIE %s %s: links %.0f Grad, rechts %.0f Grad (180 = gestreckt)" % [v, g, kw["l"], kw["r"]])
				var eigen := vm == "HUMAN" or mo.begins_with(vm + "_")
				if eigen and vm != "HUMAN": volk_ok += 1
				var mass := messe(m)
				var soll: float = ZIEL[v] * (FRAU if g == "w" else 1.0)
				var gr: float = mass["scheitel"] - mass["sohle"]
				var abw := gr / soll - 1.0
				var ok := eigen and absf(abw) <= GROESSE_TOL and absf(mass["sohle"]) <= BODEN_TOL
				var wort := "FALL" if ok else "FALSCH"
				if not ok and v == "Mensch": wort = "BEZUG"   # Mensch wie vor 431 (nicht geaendert), Abweichung nur genannt
				elif not ok: fehler += 1
				# 431 Nachbesserung: Bart, Haar, Hautton nach LISTE-FIGUREN „Völker“, Vorschau in wahrer Groesse
				var kopf := kopf_pruefen(m, v, g, int(w["aussehen"].get("haut", 0)))
				if kopf != "": fehler += 1
				print("%s %s %s %s: Modell %s, Groesse %.3f m (Soll %.3f, %+.1f %%), Sohle %+.3f m, Schrankteile %d, Haare %s%s" % [
					wort if kopf == "" else "FALSCH", v, g, h, mo, gr, soll, abw * 100.0, mass["sohle"], mass["schrank"], haare(m), kopf])
				m.free()
	# Vorschau der Erschaffung (Drehteller wie ErschaffungBrs): wahre Groesse, keine Normierung (Massstab 1 = Figur 1:1)
	for v in VOELKER:
		for g in ["m", "w"]:
			var b := BrsHeld.neu(v, "Wachsoldat"); b.ausstatten()
			var vm := HeldFigur.volk_modell(v)
			var t := Drehteller.new({"herkunft": "Wachsoldat", "volk": vm, "aussehen": HeldFigur.vorgabe("Wachsoldat", g, vm), "ausruestung": b.ausruestung}, 0.9, false, true, 1)
			root.add_child(t)
			await process_frame
			var held := t.teller.get_child(0) as Node3D
			var hoch := t.huelle(held, held.transform).size.y
			var ok2 := absf(held.scale.x - 1.0) < 0.001 and t.find_child("Massstab", true, false) != null
			if not ok2: fehler += 1
			print("%s Vorschau %s %s: Massstab der Figur %.3f, Hoehe im Teller %.2f m, Groessenlinie %s" % ["VORSCHAU" if ok2 else "FALSCH", v, g,
				held.scale.x, hoch, "ja" if t.find_child("Massstab", true, false) else "nein"])
			t.free()
	# Wachsoldat in Platte (297.18): Schrankteile am Volkskoerper (G); Brustplatte zwischen Huefte und Hals der Figur
	for v in VOELKER:
		for g in ["m", "w"]:
			var b := BrsHeld.neu(v, "Wachsoldat")
			b.ausstatten()
			var aus := platte(b.ausruestung)
			var vm := HeldFigur.volk_modell(v)
			var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": vm, "aussehen": HeldFigur.vorgabe("Wachsoldat", g, vm), "ausruestung": aus}, [])
			root.add_child(m)
			var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			if ap and ap.has_animation("Stehen"): ap.play("Stehen"); ap.seek(0.0, true)
			for i in 3: await process_frame
			var mass := messe(m, "Teil_KNIGHT_BODY")
			var gr: float = mass["scheitel"] - mass["sohle"]
			var lo: float = (mass["teil_unten"] - mass["sohle"]) / gr
			var hi: float = (mass["teil_oben"] - mass["sohle"]) / gr
			var ok: bool = mass["schrank"] >= 3 and lo > 0.3 and lo < 0.62 and hi > 0.7 and hi < 0.95
			if not ok: fehler += 1
			print("%s Platte %s %s: Modell %s, Schrankteile %d, Brustplatte %.2f-%.2f der Groesse" % ["FALL" if ok else "FALSCH", v, g,
				m.get_meta("tracht", ""), mass["schrank"], lo, hi])
			n += 1
			m.free()
	print("VOELKER431 %d Faelle (80 Erschaffung, 10 Platte), %d am Volkskoerper (von 64 ausser Mensch), %d falsch" % [n, volk_ok, fehler])
	quit(1 if fehler > 0 else 0)


# Namen der Haarnetze am Kopf (BoneAttachment „Haar_*“)
static func haare(m: Node3D) -> String:
	var l := []
	for ba in m.find_children("Haar_*", "BoneAttachment3D", true, false): l.append(String(ba.name).substr(5))
	return ",".join(l) if not l.is_empty() else "-"

# LISTE-FIGUREN.md „Völker“ Punkt 3 und 4: Elf langes Haar, nie Bart; Zwerg Vollbart (Bart_Breit) mit Schnauzbart; Zwergin kein Bart,
# zwei Schlaefenzoepfe (Netz fehlt: nur genannt); Huegelvolk Mann hoechstens kurzer Bart; Orkbluetiger Hautton im Farbton der Wahl
# (Toenung der Haut G/R >= 0,9 * G/R des Tons, wie tests/orkhaut_431.gd im Bild). Leer = richtig, sonst der Grund
static func kopf_pruefen(m: Node3D, v: String, g: String, haut := 0) -> String:
	var h := haare(m).split(",")
	var lang := ["Hair_Long", "Hair_LongDreads"]
	var voll := ["Hair_Beard", "Bart_Breit", "Bart_Lang", "Bart_Kinn"]
	var r := []
	if v == "Elf":
		var kapuze := m.find_children("*Head_Hood*", "MeshInstance3D", true, false).any(func(x): return (x as Node3D).is_visible_in_tree())
		if not (h[0] in lang) and not kapuze: r.append("Elf ohne langes Haar")   # unter der Kapuze (Jaegerkind) kein Haar
		for x in h: if x.begins_with("Bart") or x in ["Hair_Beard", "Hair_Moustache", "Hair_MuttonChops"]: r.append("Elf mit Bart " + x)
	if v == "Zwerg" and g == "m" and not ("Bart_Breit" in h and "Hair_Moustache" in h): r.append("Zwerg ohne Vollbart mit Schnauzbart")
	if v == "Zwerg" and g == "w":
		for x in h: if x.begins_with("Bart") or x in ["Hair_Beard", "Hair_Moustache", "Hair_MuttonChops"]: r.append("Zwergin mit Bart")
	if v == "Hügelvolk" and g == "m":
		for x in h: if x in voll: r.append("Huegelvolk mit langem Bart " + x)
	if v == "Orkblütiger":
		for mi in m.find_children("*", "MeshInstance3D", true, false):
			var me := (mi as MeshInstance3D).mesh
			if me == null: continue
			for i in me.get_surface_count():
				var src := me.surface_get_material(i)
				var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
				if src == null or sm == null or not String(src.resource_name).contains("Superhero"): continue
				var t: Vector3 = sm.get_shader_parameter("toenung")
				var z := HeldFigur.ton("HALF_ORC", "haut", haut).srgb_to_linear()
				if t.y / maxf(t.x, 0.0001) < 0.9 * z.g / maxf(z.r, 0.0001): r.append("Orkhaut Toenung G/R %.2f statt %.2f" % [t.y / t.x, z.g / z.r])
				break
	return "" if r.is_empty() else ", FALSCH: " + "; ".join(r)

# gehaeutete Ecken je sichtbarem Netz (Skelett im Raum der Figur mal Pose mal Bindung, nach Gewicht), ohne Formschluessel
# groesstes |x| und groesste Tiefe nach hinten (-z, die Figur blickt +z) der Netze mit Namen prefix zwischen y0 und y1
func band(m: Node3D, prefix: String, y0: float, y1: float) -> Vector2:
	var r := Vector2(-9, -9)
	for mi in m.find_children(prefix + "*", "MeshInstance3D", true, false):
		var x := mi as MeshInstance3D
		if not x.is_visible_in_tree() or x.skin == null: continue
		var sk := x.get_node_or_null(x.skeleton) as Skeleton3D
		if sk == null: continue
		var raum := m.global_transform.affine_inverse() * sk.global_transform
		var tr := []
		for i in x.skin.get_bind_count():
			var bn := String(x.skin.get_bind_name(i))
			var bi := sk.find_bone(bn) if bn != "" else x.skin.get_bind_bone(i)
			tr.append(raum * sk.get_bone_global_pose(maxi(bi, 0)) * x.skin.get_bind_pose(i))
		for s in x.mesh.get_surface_count():
			var a := x.mesh.surface_get_arrays(s)
			var V: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var B = a[Mesh.ARRAY_BONES]
			var W = a[Mesh.ARRAY_WEIGHTS]
			if B == null or W == null or V.is_empty(): continue
			var k := int(B.size() / V.size())
			for j in V.size():
				var p := Vector3.ZERO
				var ws := 0.0
				for e in k:
					var wt: float = W[j * k + e]
					if wt <= 0.0: continue
					p += (tr[B[j * k + e]] as Transform3D) * V[j] * wt
					ws += wt
				if ws <= 0.0: continue
				p /= ws
				if p.y < y0 or p.y > y1: continue
				r.x = maxf(r.x, absf(p.x)); r.y = maxf(r.y, -p.z)
	return r


static func platte(start: Dictionary) -> Dictionary:
	var aus := start.duplicate(true)
	for p in [["CHEST", "plate"], ["ARMS", "gauntlets"], ["LEGS", "greaves"]]:
		var st: Dictionary = (aus.get("CHEST", {}) as Dictionary).duplicate()
		st["base"] = p[1]
		aus[p[0]] = st
	aus.erase("OFF_HAND")   # Rueckansicht 297.18: der Schild auf dem Ruecken verdeckte die Platte
	aus.erase("CLOAK")   # Umhang ruht bis nach dem Meilenstein (Sokrates 16.11., 00:08; Beleglauf ohne Umhang, 09:39)
	return aus


func messe(m: Node3D, teil := "") -> Dictionary:
	var teil_unten := 9.0
	var teil_oben := -9.0
	var scheitel := -9.0
	var sohle := 9.0
	var schrank := 0
	var haar := 0
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var x := mi as MeshInstance3D
		if not x.is_visible_in_tree() or x.mesh == null: continue
		if String(x.name).begins_with("Teil_"): schrank += 1
		var sk := x.get_node_or_null(x.skeleton) as Skeleton3D if x.skin else null
		if sk == null:
			if x.get_parent() is BoneAttachment3D: haar += 1
			continue
		var raum := m.global_transform.affine_inverse() * sk.global_transform
		var tr := []
		for i in x.skin.get_bind_count():
			var bn := String(x.skin.get_bind_name(i))
			var bi := sk.find_bone(bn) if bn != "" else x.skin.get_bind_bone(i)
			tr.append(raum * sk.get_bone_global_pose(maxi(bi, 0)) * x.skin.get_bind_pose(i))
		for s in x.mesh.get_surface_count():
			var mat := x.mesh.surface_get_material(s)
			var rn := String(mat.resource_name) if mat else ""
			var haut := rn.contains("Regular") or rn.contains("Superhero")
			var a := x.mesh.surface_get_arrays(s)
			var V: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var B = a[Mesh.ARRAY_BONES]
			var W = a[Mesh.ARRAY_WEIGHTS]
			if B == null or W == null or V.is_empty(): continue
			var k := int(B.size() / V.size())
			for j in V.size():
				var p := Vector3.ZERO
				var ws := 0.0
				for e in k:
					var wt: float = W[j * k + e]
					if wt <= 0.0: continue
					p += (tr[B[j * k + e]] as Transform3D) * V[j] * wt
					ws += wt
				if ws <= 0.0: continue
				p /= ws
				sohle = minf(sohle, p.y)
				if haut: scheitel = maxf(scheitel, p.y)
				if teil != "" and String(x.name).begins_with(teil):
					teil_unten = minf(teil_unten, p.y); teil_oben = maxf(teil_oben, p.y)
	return {"scheitel": scheitel, "sohle": sohle, "schrank": schrank, "haar": haar, "teil_unten": teil_unten, "teil_oben": teil_oben}


# 431 Nachbesserung (Auftrag 24.11., 19:47: Kniewinkel Zwerg messen, Mensch zum Vergleich): am gezeichneten Netz der Beine (Haut,
# Hose, Stiefel; ohne Umhang, der an den Oberschenkeln haengt). Ober- und Unterschenkel = Ecken, die zu mindestens 80 % dem
# Knochen gehoeren (thigh, calf), Knie = Ecken, die beiden je mindestens 25 % gehoeren; Kniewinkel am Knie zwischen der Mitte des
# Ober- und des Unterschenkels (180 = gestreckt). Je Seite
static func knie(m: Node3D) -> Dictionary:
	var r := {}
	for s in ["l", "r"]:
		var teile := {"thigh_" + s: [], "calf_" + s: [], "knie": []}
		for mi in m.find_children("*", "MeshInstance3D", true, false):
			var x := mi as MeshInstance3D
			if not x.is_visible_in_tree() or x.skin == null or x.mesh == null: continue
			var nm0 := String(x.name)
			if not (nm0.begins_with("Leib_") or nm0.contains("LEGS") or nm0.contains("Feet") or nm0.contains("Boot")): continue   # Bein, ohne Umhang
			var sk := x.get_node_or_null(x.skeleton) as Skeleton3D
			if sk == null: continue
			var raum := m.global_transform.affine_inverse() * sk.global_transform
			var tr := []
			var namen := []
			for i in x.skin.get_bind_count():
				var bn := String(x.skin.get_bind_name(i))
				var bi := sk.find_bone(bn) if bn != "" else x.skin.get_bind_bone(i)
				tr.append(raum * sk.get_bone_global_pose(maxi(bi, 0)) * x.skin.get_bind_pose(i))
				namen.append(sk.get_bone_name(maxi(bi, 0)))
			var ziel := []   # je Bindung: 0 Oberschenkel, 1 Unterschenkel, -1 sonst
			for nm in namen: ziel.append(0 if nm == "thigh_" + s else (1 if nm == "calf_" + s else -1))
			if not (0 in ziel or 1 in ziel): continue
			for su in x.mesh.get_surface_count():
				var a := x.mesh.surface_get_arrays(su)
				var V: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
				var B = a[Mesh.ARRAY_BONES]
				var W = a[Mesh.ARRAY_WEIGHTS]
				if B == null or W == null or V.is_empty(): continue
				var kk := int(B.size() / V.size())
				for j in V.size():
					var w2 := [0.0, 0.0]
					var ws := 0.0
					for e in kk:
						var wt: float = W[j * kk + e]
						ws += wt
						var zi: int = ziel[B[j * kk + e]]
						if zi >= 0: w2[zi] += wt
					if ws <= 0.0: continue
					var wo := ""
					if maxf(w2[0], w2[1]) >= 0.8 * ws: wo = "thigh_" + s if w2[0] >= w2[1] else "calf_" + s
					elif minf(w2[0], w2[1]) >= 0.25 * ws: wo = "knie"
					if wo == "": continue
					var p := Vector3.ZERO
					for e in kk:
						var wt: float = W[j * kk + e]
						if wt > 0.0: p += (tr[B[j * kk + e]] as Transform3D) * V[j] * wt
					(teile[wo] as Array).append(p / ws)
		if (teile["knie"] as Array).size() < 5 or (teile["thigh_" + s] as Array).size() < 5 or (teile["calf_" + s] as Array).size() < 5:
			r[s] = -1.0; continue
		var kn := _mitte(teile["knie"])
		r[s] = rad_to_deg((_mitte(teile["thigh_" + s]) - kn).angle_to(_mitte(teile["calf_" + s]) - kn))
	return r

static func _mitte(pts: Array) -> Vector3:
	var c := Vector3.ZERO
	for p in pts: c += p
	return c / pts.size()
