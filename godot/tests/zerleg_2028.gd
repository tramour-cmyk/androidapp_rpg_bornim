# 2028 (Nora): Handgelenk einer Figur mit Kaufkleid zerlegen, ohne Bild. Netze des Spiels wie durchstich_1631 (HeldFigur.person, Haltung,
# Bewegung Stehen, Bild 0); Strahlen in Blickrichtung der Spielkamera (30 Grad von oben, von vorn) in einem Feld um jedes Handgelenk.
# Je erstem Treffer: Lage, Vorder- oder Rückseite (Dreieck und Eckennormale), Eckfarbe, Textur am UV, Eckennormale zur Kamera.
# Run: godot --headless --path godot -s res://tests/zerleg_2028.gd [-- --nur=L_rowena]
extends "res://tests/durchstich_1631.gd"

const HALB := 30        # halbe Seitenlänge des Felds um das Handgelenk (Bildpunkte der Spielkamera)
const NEIGUNG := 30.0

var farben := PackedColorArray()
var uvs := PackedVector2Array()
var bilder := []        # je Ecke Index in texte
var texte := []         # Image je Fläche

func _initialize() -> void:
	_zerlege.call_deferred()

func _zerlege() -> void:
	if not HauptmenueHelden.da():
		print("ZERLEG2028 ohne Kauf"); quit(0); return
	var nur := "L_rowena"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nur="): nur = a.substr(6)
	var id := nur.trim_prefix("L_")
	var m := HeldFigur.person(id, [])
	root.add_child(m)
	await process_frame
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var ap := m.get_node_or_null("AnimationPlayer") as AnimationPlayer
	var netz := _sammle(sk)
	_sammle_farben(sk)
	var haltung: Node = null
	for c in sk.get_children():
		if c is HeldFigur.Haltung: haltung = c
	ap.speed_scale = 0.0
	ap.play("Stehen", 0.0)
	ap.seek(0.0, true)
	if haltung: haltung.grund_w = -1.0; haltung.arm_w = -1.0; haltung.dame_w = -1.0
	sk.skeleton_updated.connect(_nach_update.bind(sk))
	_posen = []; _warte = true
	await process_frame
	await process_frame
	var lage := _haut(netz, _posen)
	var V: PackedVector3Array = lage[0]; var N: PackedVector3Array = lage[1]
	var g := _gitter(V, netz["tri"])
	# Blick: von vorn (+z des Skeletts, Figur schaut zur Kamera) und 30 Grad von oben; Spielkamera orthogonal, 3,4 m auf 1080 Punkte
	var dir := Vector3(0, -sin(deg_to_rad(NEIGUNG)), -cos(deg_to_rad(NEIGUNG)))
	var quer := Vector3.RIGHT; var hoch := quer.cross(dir).normalized()
	var px := 3.4 / 1080.0 / m.scale.x
	# wie toon.gdshader vertex(): Ecken, deren Normale von der Kamera weg zeigt, rueck (heldfigur RUECK) längs des Blicks zurück
	var rueck := float(HeldFigur.RUECK)
	var V2 := V.duplicate()
	for i in V.size(): V2[i] = V[i] + dir * rueck * smoothstep(0.0, 0.2, N[i].dot(dir))
	var g2 := _gitter(V2, netz["tri"])
	# je Stück: Knochen mit dem größten Gewicht (häufigster), Ecken, offene Randecken
	var dom := {}; var rand_n := {}
	var randset := {}
	for i in netz["rand"]: randset[i] = true
	for tl in netz["teile"]:
		var b0: int = tl[0]; var anz: int = tl[1]; var bs = tl[2]; var ws = tl[3]; var nn: int = tl[4]; var bb: PackedInt32Array = tl[5]
		for i in anz:
			var best := 0
			for q in nn:
				if ws[i * nn + q] > ws[i * nn + best]: best = q
			var kn := sk.get_bone_name(bb[bs[i * nn + best]]) if bb[bs[i * nn + best]] >= 0 else "?"
			var ln: String = netz["lname"][netz["lage"][b0 + i]]
			if not dom.has(ln): dom[ln] = {}
			dom[ln][kn] = dom[ln].get(kn, 0) + 1
			if randset.has(b0 + i): rand_n[ln] = rand_n.get(ln, 0) + 1
	for ln in dom:
		var ks: Array = dom[ln].keys(); ks.sort_custom(func(x, y): return dom[ln][x] > dom[ln][y])
		print("ZERLEG2028 Stueck %s: %s; Randecken %d" % [ln, ", ".join(ks.slice(0, 3).map(func(x): return "%s %d" % [x, dom[ln][x]])), rand_n.get(ln, 0)])
	for bn in ["hand_l", "hand_r"]:
		var b := sk.find_bone(bn)
		if b < 0: continue
		var mitte: Vector3 = (_posen[b] as Transform3D).origin
		for fall in [["ohne rueck", V, g], ["mit rueck", V2, g2]]:
			var VV: PackedVector3Array = fall[1]
			var tief := {}; var lage_px := {}; var vorn_px := {}
			for iy in range(-HALB, HALB + 1):
				for ix in range(-HALB, HALB + 1):
					var von := mitte + quer * (ix * px) + hoch * (iy * px) - dir * 1.0
					var h := _erster(VV, netz, fall[2], von, dir, 2.0)
					if h.is_empty(): continue
					var tri: int = h[0]; var bc: Vector3 = h[1]
					var i0: int = netz["tri"][tri]; var i1: int = netz["tri"][tri + 1]; var i2: int = netz["tri"][tri + 2]
					var p := VV[i0] * bc.x + VV[i1] * bc.y + VV[i2] * bc.z
					tief[Vector2i(ix, iy)] = (p - von).dot(dir)
					lage_px[Vector2i(ix, iy)] = String(netz["lname"][netz["lage"][i0]])
					var fn := (VV[i1] - VV[i0]).cross(VV[i2] - VV[i0])
					vorn_px[Vector2i(ix, iy)] = fn.dot(dir) > 0.0   # Wicklung der Kaufnetze: vorn, wenn das Dreieck längs des Blicks zeigt (gemessen: 288 zu 8)
			# Tusche wie tusche.gdshader: Laplace der Tiefe mit Abstand e Bildpunkte, Linie ab knick 0,06 m (voll ab 0,15)
			for e in [2, 3, 5]:
				var tinte := 0; var je := {}
				for k in tief:
					var nb := [k + Vector2i(e, 0), k - Vector2i(e, 0), k + Vector2i(0, e), k - Vector2i(0, e)]
					var lap := -4.0 * float(tief[k])
					var ok := true
					for q in nb:
						if not tief.has(q): ok = false; break
						lap += float(tief[q])
					if not ok: continue
					if smoothstep(0.06, 0.15, absf(lap)) < 0.5: continue
					tinte += 1
					var tiefst: Vector2i = k
					for q in nb:
						if float(tief[q]) > float(tief[tiefst]): tiefst = q
					var lk := "%s %s > %s %s" % [lage_px[k], "vorn" if vorn_px[k] else "RUECK", lage_px[tiefst], "vorn" if vorn_px[tiefst] else "RUECK"]
					je[lk] = je.get(lk, 0) + 1
				var ks := je.keys(); ks.sort_custom(func(x, y): return je[x] > je[y])
				print("ZERLEG2028 %s %s %s e=%d: %d Bildpunkte, Tusche %d  %s" % [nur, bn, fall[0], e, tief.size(), tinte, ", ".join(ks.slice(0, 6).map(func(x): return "%s: %d" % [x, je[x]]))])
			if "--karte" in OS.get_cmdline_user_args() and fall[0] == "mit rueck":
				for iy in range(HALB, -HALB - 1, -2):
					var z := ""
					for ix in range(-HALB, HALB + 1):
						var k := Vector2i(ix, iy)
						if not tief.has(k): z += " "; continue
						var lap := -4.0 * float(tief[k]); var ok := true
						for q in [k + Vector2i(3, 0), k - Vector2i(3, 0), k + Vector2i(0, 3), k - Vector2i(0, 3)]:
							if not tief.has(q): ok = false; break
							lap += float(tief[q])
						var l: String = lage_px[k]
						var c := "H" if l.begins_with("Female") else ("K" if l.begins_with("Kleid") else "?")
						if not vorn_px[k]: c = c.to_lower()
						if ok and smoothstep(0.06, 0.15, absf(lap)) >= 0.5: c = "#" if vorn_px[k] else "*"
						z += c
					print("KARTE %s |%s|" % [bn, z])
			var rs := {}
			for k in tief:
				var lk := "%s %s" % [lage_px[k], "vorn" if vorn_px[k] else "RUECKSEITE"]
				rs[lk] = rs.get(lk, 0) + 1
			var ks2 := rs.keys(); ks2.sort_custom(func(x, y): return rs[x] > rs[y])
			print("ZERLEG2028 %s %s %s sichtbar: %s" % [nur, bn, fall[0], ", ".join(ks2.map(func(x): return "%s: %d" % [x, rs[x]]))])
	quit(0)

func _hx(c: Color) -> String:
	return "%d,%d,%d" % [int(c.r * 255), int(c.g * 255), int(c.b * 255)]

# nächster Treffer (alle Lagen, beide Seiten) -> [Dreieck, Baryzentrik]
func _erster(V: PackedVector3Array, netz: Dictionary, g: Dictionary, von: Vector3, dir: Vector3, weit: float) -> Array:
	var tri: PackedInt32Array = netz["tri"]
	var best := []; var bd := INF
	var bis := von + dir * weit
	var gesehen := {}
	var schritte := int(weit / ZELLE) + 1
	for q in schritte + 1:
		var p := von + dir * (float(q) * ZELLE)
		var c := _zelle(p)
		for x in range(c.x - 1, c.x + 2):
			for y in range(c.y - 1, c.y + 2):
				for z in range(c.z - 1, c.z + 2):
					var k := Vector3i(x, y, z)
					if not g.has(k): continue
					for t in g[k]:
						if gesehen.has(t): continue
						gesehen[t] = true
						var a := V[tri[t]]; var b := V[tri[t + 1]]; var cc := V[tri[t + 2]]
						var hit = Geometry3D.segment_intersects_triangle(von, bis, a, b, cc)
						if hit == null: continue
						var d := von.distance_to(hit)
						if d < bd:
							bd = d
							best = [t, _bary(hit, a, b, cc)]
		if not best.is_empty() and float(q) * ZELLE > bd + ZELLE * 2.0: break
	return best

func _bary(p: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	var v0 := b - a; var v1 := c - a; var v2 := p - a
	var d00 := v0.dot(v0); var d01 := v0.dot(v1); var d11 := v1.dot(v1); var d20 := v2.dot(v0); var d21 := v2.dot(v1)
	var den := d00 * d11 - d01 * d01
	if absf(den) < 1e-12: return Vector3(1, 0, 0)
	var v := (d11 * d20 - d01 * d21) / den; var w := (d00 * d21 - d01 * d20) / den
	return Vector3(1.0 - v - w, v, w)

# Eckfarbe, UV und Bild je Ecke, in derselben Reihenfolge wie _sammle
func _sammle_farben(sk: Skeleton3D) -> void:
	for me_ in sk.find_children("*", "MeshInstance3D", true, false):
		var me := me_ as MeshInstance3D
		if me.skin == null or me.mesh == null or not me.is_visible_in_tree(): continue
		var nm := String(me.name)
		if AUSSER.any(func(x): return x in nm): continue
		for s in me.mesh.get_surface_count():
			var a := me.mesh.surface_get_arrays(s)
			var vs: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			if vs.is_empty() or a[Mesh.ARRAY_BONES] == null or a[Mesh.ARRAY_WEIGHTS] == null or a[Mesh.ARRAY_NORMAL] == null: continue
			var cs = a[Mesh.ARRAY_COLOR]; var us = a[Mesh.ARRAY_TEX_UV]
			var mat := me.get_active_material(s)
			var tx: Texture2D = null
			if mat is ShaderMaterial: tx = mat.get_shader_parameter("tex")
			elif mat is BaseMaterial3D: tx = mat.albedo_texture
			var bi := -1
			if tx:
				var im := tx.get_image()
				if im:
					if im.is_compressed(): im.decompress()
					texte.append(im); bi = texte.size() - 1
			print("ZERLEG2028 Flaeche %s/%d %s Eckfarbe %s Bild %s" % [nm, s, mat.resource_name if mat else "-", "ja" if cs != null and not (cs as PackedColorArray).is_empty() else "nein", "ja" if bi >= 0 else "nein"])
			for i in vs.size():
				farben.append(cs[i] if cs != null and not (cs as PackedColorArray).is_empty() else Color(1, 1, 1))
				uvs.append(us[i] if us != null and not (us as PackedVector2Array).is_empty() else Vector2.ZERO)
				bilder.append(bi)
