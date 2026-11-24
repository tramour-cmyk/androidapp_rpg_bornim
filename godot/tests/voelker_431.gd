extends SceneTree
# 431 Schritt 2 (Auftrag 24.11., 08:31): der Held auf dem Koerper seines Volkes ueber alle Faelle, 5 Voelker x 2 Geschlechter x
# 8 Herkuenfte = 80, je mit der Startausruestung der Herkunft (BrsHeld). Je Fall: Modell des Volkes (nicht der Menschenkoerper),
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
				print("%s %s %s %s: Modell %s, Groesse %.3f m (Soll %.3f, %+.1f %%), Sohle %+.3f m, Schrankteile %d, Haare %d" % [
					wort, v, g, h, mo, gr, soll, abw * 100.0, mass["sohle"], mass["schrank"], mass["haar"]])
				m.free()
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
	# Umhang an Huefte und Ruecken (Probebild 24.11., 10:51: Zwerg mit Wulst): Abstand des Umhangs vom Leib im Band 35-60 % der Groesse,
	# seitlich und hinten; Grenze: hoechstens 10 cm mehr als beim Menschen gleichen Geschlechts (Zwerg vorher 13 cm, nach LOSE 6 cm)
	var mensch := {}
	for v in VOELKER:
		for g in ["m", "w"]:
			var b := BrsHeld.neu(v, "Wachsoldat")
			b.ausstatten()
			var vm := HeldFigur.volk_modell(v)
			var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": vm, "aussehen": HeldFigur.vorgabe("Wachsoldat", g, vm), "ausruestung": b.ausruestung}, [])
			root.add_child(m)
			var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			if ap and ap.has_animation("Stehen"): ap.play("Stehen"); ap.seek(0.0, true)
			for i in 3: await process_frame
			var ms := messe(m)
			var gr: float = ms["scheitel"] - ms["sohle"]
			var leib := band(m, "Leib_", ms["sohle"] + 0.35 * gr, ms["sohle"] + 0.6 * gr)
			var um := band(m, "Kleid_CLOAK", ms["sohle"] + 0.35 * gr, ms["sohle"] + 0.6 * gr)
			var seit: float = um.x - leib.x
			var hint: float = um.y - leib.y
			if v == "Mensch": mensch[g] = Vector2(seit, hint)
			var ok: bool = seit <= mensch[g].x + 0.10 and hint <= mensch[g].y + 0.10
			if not ok: fehler += 1
			n += 1
			print("%s Umhang %s %s: seitlich %.1f cm, hinten %.1f cm ueber dem Leib (Mensch %.1f / %.1f)" % ["FALL" if ok else "FALSCH", v, g,
				seit * 100, hint * 100, mensch[g].x * 100, mensch[g].y * 100])
			m.free()
	print("VOELKER431 %d Faelle (80 Erschaffung, 10 Platte, 10 Umhang), %d am Volkskoerper (von 64 ausser Mensch), %d falsch" % [n, volk_ok, fehler])
	quit(1 if fehler > 0 else 0)


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
