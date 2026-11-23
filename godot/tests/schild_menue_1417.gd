# 1417 (Chef 16.11., 12:37/12:38, Bild Hauptmenü v0.348.506): der Schild der Wachsoldatin links im Hauptmenü wirkt „an mehreren Stellen
# eingekerbt oder kaputt … als ob der Stoff, der dahinter liegt, einen Teil des Schildes überdeckt oder das Schild im Körper steckt“.
# Ohne Bild: die vier Helden wie im Hauptmenü (HauptmenueHelden), nach den Schichten (skeleton_updated) gehäutet wie im Zeichner;
# gemessen wird, wie weit Körper und Kleidung (ohne linke Hand und Unterarm, die den Schild halten) durch die Schildfläche ragen
# (tests/schild_406.gd _netz_tiefe), je Netz die tiefste Ecke und die Zahl der Ecken über 1 cm. MESS=1417: dazu Fassungen
# (Abspreizen des Arms, Drehung der Schildhand) nebeneinander.
# 1675 (Chef 18.11., 15:57): Arm wieder am Bein (Abspreizen 0), der Stoff in der Schildflaeche hinter den Schild (HauptmenueHelden
# StoffHinterSchild, im Ecken-Shader): gemessen wie gezeichnet, also nach dessen Verschiebung (schiebe); Abspreizen ueber 0 ist ein Fehler.
# 1675-Ü4 (Pruefer 23.11., 12:11): dazu _sicht, was die Menuekamera zeigt: Zellen, in denen die Figur vor der Schildflaeche liegt
# (rot an 738306c3d und bab336c9a: 1652 Zellen Kleid_LEGS bis 7,5 cm davor, die graue Spitze; das Feld aus den Ecken des Schilds liess
# Zellen grosser Flaechen leer). SICHTKARTE=1 druckt die Karte.
# Run: godot --headless --path godot -s res://tests/schild_menue_1417.gd   (ohne Kaufdateien „ohne Kauf“, 0)
extends SceneTree

const BARY := [Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1), Vector3(0.5, 0.5, 0), Vector3(0, 0.5, 0.5), Vector3(0.5, 0, 0.5),
		Vector3(1, 1, 1) / 3.0, Vector3(4, 1, 1) / 6.0, Vector3(1, 4, 1) / 6.0, Vector3(1, 1, 4) / 6.0]
const GRENZE := 0.01          # erlaubt: 1 cm (Kleidung liegt locker, die Häutung ist linear)
const VOR := 0.05             # Stoff bis so weit vor dem Schild zaehlt (1675-Ü4: 0,3 aus bab336c9a aenderte nichts Messbares, zurueck)
var fehler := 0
var _haut := []               # [MeshInstance3D, Skin, Ecken, Knochen, Gewichte, nb, frei]
var _posen := []
var _sk: Skeleton3D
const SICHT_PX := 0.002       # 1675-Ü4: Raster der Sichtmessung, Meter in der Schildebene (Handy: etwa 3,5 mm je Bildpunkt)
const SICHT_ERLAUBT := 0      # Bildpunkte, in denen die Figur vor der Schildflaeche gezeichnet wird
var _vor_alle := {}
var _stoff = null             # 1675 HauptmenueHelden.StoffHinterSchild der Figur
var _gepruefte := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	if not HauptmenueHelden.da():
		print("SCHILD1417 ohne Kauf, 0 Fehler")
		quit(0)
		return
	var hm := HauptmenueHelden.new()
	root.add_child(hm)
	for i in 10: await process_frame
	for trg in hm.figuren:
		var m := trg.get_child(0) as Node3D
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var tr: Tragen = null
		for c in sk.get_children():
			if c is Tragen and (c as Tragen).gang == "schildarm": tr = c
		_gepruefte += 1
		if tr == null:
			print("SCHILD1417 %s ohne Schild" % trg.get_meta("haltung", ""))
			continue
		_sk = sk
		_stoff = m.get_node_or_null("StoffHinterSchild")
		if absf(tr.schild_abspreiz) > 0.01:
			print("FEHLER Schildarm %.0f Grad abgespreizt (1675: Grundhaltung vor dem Koerper, Abspreizen 0)" % tr.schild_abspreiz)
			fehler += 1
		_haut_lesen(sk)
		var fassungen := [[tr.schild_abspreiz, _dreh(sk)]]
		if OS.get_environment("MESS") == "1417":
			for a in [0.0, 8.0, 12.0, 18.0, 25.0]:
				for d in [0.0, 30.0, 60.0, 90.0]:
					fassungen.append([a, d])
		var erste := true
		for f in fassungen:
			tr.schild_abspreiz = float(f[0])
			var hd := sk.get_node_or_null("SchildDrehen")
			if hd: hd.set("grad", float(f[1]))
			# ueber die ganze Bewegung (das Bild steht nach wenigen Bildern, wo, haengt vom Start ab): fuenf Stellen, die schlechteste
			var r := [-INF, "", 0, {}]
			var sicht := [0, 0.0, "", {}]
			var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			var bew := String(trg.get_meta("haltung", ""))
			for st in 5:
				if ap and ap.has_animation(bew):
					ap.play(bew); ap.seek(ap.get_animation(bew).length * st / 5.0, true); ap.pause()
				_posen = []
				sk.skeleton_updated.connect(_merke, CONNECT_ONE_SHOT)
				for i in 3: await process_frame
				if _posen.is_empty(): continue
				var r1 := _messen(tr.waffe)
				if float(r1[0]) > float(r[0]): r = r1
				if erste:
					var s1 := _sicht(m, tr.waffe, hm._v.get_camera_3d())
					if int(s1[0]) > int(sicht[0]): sicht = s1
			print("SCHILD1417 %s abspreiz %.0f dreh %.0f: tiefste %.1f cm (%s), Felder (2 cm) ueber 1 cm %d %s" % [trg.get_meta("haltung", ""), f[0], f[1], r[0] * 100.0, r[1], r[2], r[3]])
			if erste and float(r[0]) > GRENZE:
				print("FEHLER %s: Koerper oder Kleidung %.1f cm durch den Schild (%s)" % [trg.get_meta("haltung", ""), r[0] * 100.0, r[1]])
				fehler += 1
			if erste:
				print("SCHILD1675 Sicht der Menuekamera: %d Bildpunkte (je %.1f mm) Figur vor der Schildflaeche, bis %.1f cm davor (%s) %s" % [sicht[0], SICHT_PX * 1000.0, sicht[1] * 100.0, sicht[2], sicht[3]])
				if int(sicht[0]) > SICHT_ERLAUBT:
					print("FEHLER %s: Figur vor dem Schild sichtbar, %d Bildpunkte (%s)" % [trg.get_meta("haltung", ""), sicht[0], sicht[2]])
					fehler += 1
			erste = false
	print("SCHILD1417 %d Figuren geprueft, Stoff hinter dem Schild: %s" % [_gepruefte, "ja" if _stoff else "nein"])
	if OS.get_environment("MESS") == "1675": await _andere(hm)
	print("SCHILD1417 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func _dreh(sk: Skeleton3D) -> float:
	var hd := sk.get_node_or_null("SchildDrehen")
	return float(hd.get("grad")) if hd else 0.0

func _merke() -> void:
	_posen.resize(_sk.get_bone_count())
	for b in _sk.get_bone_count(): _posen[b] = _sk.get_bone_global_pose(b)

func _haut_lesen(sk: Skeleton3D) -> void:
	_haut.clear()
	var hand := []
	for i in sk.get_bone_count():
		var p := i
		while p >= 0:
			if sk.get_bone_name(p) in ["lowerarm_l", "hand_l"]:
				hand.append(i); break
			p = sk.get_bone_parent(p)
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.skin == null or m.get_parent() is BoneAttachment3D or not m.visible: continue
		for s in m.mesh.get_surface_count():
			var ar := m.mesh.surface_get_arrays(s)
			if ar[Mesh.ARRAY_BONES] == null: continue
			var nb: int = ar[Mesh.ARRAY_BONES].size() / ar[Mesh.ARRAY_VERTEX].size()
			var frei := PackedByteArray()
			frei.resize(ar[Mesh.ARRAY_VERTEX].size())
			for v in ar[Mesh.ARRAY_VERTEX].size():
				var w := 0.0
				for j in nb:
					var bb: int = m.skin.get_bind_bone(ar[Mesh.ARRAY_BONES][v * nb + j])
					if bb < 0: bb = sk.find_bone(m.skin.get_bind_name(ar[Mesh.ARRAY_BONES][v * nb + j]))
					if bb in hand: w += ar[Mesh.ARRAY_WEIGHTS][v * nb + j]
				frei[v] = 1 if w < 0.3 else 0
			var mt := m.get_active_material(s)
			var geschoben := mt is ShaderMaterial and float((mt as ShaderMaterial).get_shader_parameter("schild_an") if (mt as ShaderMaterial).get_shader_parameter("schild_an") != null else 0.0) > 0.0
			_haut.append([m, m.skin, ar[Mesh.ARRAY_VERTEX], ar[Mesh.ARRAY_BONES], ar[Mesh.ARRAY_WEIGHTS], nb, frei, ar[Mesh.ARRAY_INDEX], geschoben])

## [tiefste m, Netz und Knochen, Ecken ueber 1 cm, je Netz]
func _messen(schild: Node3D) -> Array:
	var inv := schild.global_transform.affine_inverse()
	var feld := {}
	for mi in schild.find_children("*", "MeshInstance3D", true, false) + ([schild] if schild is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		var t := inv * (mi as MeshInstance3D).global_transform
		for s in me.get_surface_count():
			for v in me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				var q: Vector3 = t * v
				var k := Vector2i(floori(q.x / 0.02), floori(q.y / 0.02))
				var e: Vector2 = feld.get(k, Vector2(INF, -INF))
				feld[k] = Vector2(minf(e.x, q.z), maxf(e.y, q.z))
	var g := _sk.global_transform
	var best := [-INF, "", 0, {}]
	for h in _haut:
		var skin: Skin = h[1]
		var trs := []
		for i in skin.get_bind_count():
			var bb := skin.get_bind_bone(i)
			if bb < 0: bb = _sk.find_bone(skin.get_bind_name(i))
			trs.append(g * (_posen[bb] as Transform3D) * skin.get_bind_pose(i))
		var vs: PackedVector3Array = h[2]
		var nb: int = h[5]
		var nm := String((h[0] as MeshInstance3D).name)
		var welt := PackedVector3Array()
		welt.resize(vs.size())
		for v in vs.size():
			var p := Vector3.ZERO
			for j in nb:
				var w: float = h[4][v * nb + j]
				if w > 0.0: p += (trs[h[3][v * nb + j]] as Transform3D) * vs[v] * w
			welt[v] = _stoff.schiebe(p) if h[8] and _stoff else p
		# Ecken und Flaechen: je Dreieck ohne Handecke 10 Punkte (Ecken, Kantenmitten, Mitte, Drittel), sonst kreuzt eine grosse
		# Flaeche des Umhangs den Schild, ohne dass eine Ecke darin liegt
		var idx = h[7]
		var n_dr: int = (idx.size() if idx != null else vs.size()) / 3
		var gezaehlt := {}
		for d in n_dr:
			var a: int = idx[d * 3] if idx != null else d * 3
			var b: int = idx[d * 3 + 1] if idx != null else d * 3 + 1
			var c: int = idx[d * 3 + 2] if idx != null else d * 3 + 2
			if h[6][a] == 0 or h[6][b] == 0 or h[6][c] == 0: continue
			for bw in BARY:
				var p: Vector3 = welt[a] * bw.x + welt[b] * bw.y + welt[c] * bw.z
				var q := inv * p
				var k := Vector2i(floori(q.x / 0.02), floori(q.y / 0.02))
				if not feld.has(k): continue
				var e: Vector2 = feld[k]
				if q.z > e.y + VOR: continue
				var tief: float = q.z - e.x
				if tief > GRENZE and not gezaehlt.has(k):
					gezaehlt[k] = true
					best[2] += 1
					best[3][nm] = int(best[3].get(nm, 0)) + 1
				if tief > best[0]:
					best[0] = tief
					best[1] = "%s %s, Schild x %.0f y %.0f cm" % [nm, _knochen(h, a), q.x * 100.0, q.y * 100.0]
	return best

func _knochen(h: Array, v: int) -> String:
	var nb: int = h[5]
	var bm := -1; var wm := 0.0
	for j in nb:
		if float(h[4][v * nb + j]) > wm: wm = h[4][v * nb + j]; bm = h[3][v * nb + j]
	if bm < 0: return "?"
	var skin: Skin = h[1]
	var bb := skin.get_bind_bone(bm)
	return _sk.get_bone_name(bb) if bb >= 0 else String(skin.get_bind_name(bm))

## 1675 Systemfrage (MESS=1675, nur Messung, kein Fehler): andere Figuren mit dem Schild am Arm in „Stehen“ wie die Wachsoldatin des
## Menues (Arm am Bein, Abspreizen 0, Schildhand 60 Grad), alle Voelker und beide Geschlechter mit der Startausruestung der
## Wachsoldatin; je Figur ohne und mit StoffHinterSchild
func _andere(hm: HauptmenueHelden) -> void:
	var v := hm.figuren[0].get_parent()
	for volk in HeldFigur.VOLK_MODELL:
		for g in ["w", "m"]:
			var h := {"herkunft": "Wachsoldat", "volk": volk, "geschlecht": g}
			var w := HauptmenueHelden.wahl(h)
			var mats := []
			var m: Node3D = HeldFigur.baue(w, mats)
			if m == null: continue
			var trg := Node3D.new()
			trg.position = Vector3(5, 0, 0)
			v.add_child(trg); trg.add_child(m)
			var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
			Gebiet.bewegungen(ap, ["Stehen"])
			ap.play("Stehen")
			var hs := HauptmenueHelden.HandSenken.new(); sk.add_child(hs)
			var hd := HauptmenueHelden.HandSenken.new(); hd.name = "SchildDrehen"; hd.seite = "l"; hd.um_unterarm = true; hd.grad = 60.0
			sk.add_child(hd)
			HauptmenueHelden.waffen_in_die_hand(m, sk, ap, w.get("ausruestung", {}), "Stehen", "r", 0.0)
			var tr: Tragen = null
			for c in sk.get_children():
				if c is Tragen and (c as Tragen).gang == "schildarm": tr = c
			if tr == null:
				print("SCHILD1675 %s %s ohne Schild" % [volk, g]); trg.queue_free(); continue
			var st := HauptmenueHelden.StoffHinterSchild.new(sk, tr.waffe, mats)
			m.add_child(st)
			_sk = sk
			_haut_lesen(sk)
			var erg := []
			for mit in [false, true]:
				for mt in mats: (mt as ShaderMaterial).set_shader_parameter("schild_an", 1.0 if mit else 0.0)
				_stoff = st if mit else null
				var r := [-INF, "", 0, {}]
				for k in 5:
					ap.seek(ap.get_animation("Stehen").length * k / 5.0, true); ap.pause()
					_posen = []
					sk.skeleton_updated.connect(_merke, CONNECT_ONE_SHOT)
					for i in 3: await process_frame
					if _posen.is_empty(): continue
					var r1 := _messen(tr.waffe)
					if float(r1[0]) > float(r[0]): r = r1
				erg.append(r)
			print("SCHILD1675 %s %s: ohne %.1f cm (%s), mit Stoff hinter dem Schild %.1f cm" % [volk, g, erg[0][0] * 100.0, erg[0][1], erg[1][0] * 100.0])
			trg.queue_free()
			await process_frame

## 1675-Ü4 (Pruefer 23.11., 12:11: graue Spitze im Bild links unten im Schild, die _messen nicht sieht; Feld nur aus den Ecken des
## Schilds, Zellen ohne Ecke zaehlen nicht, Hand und Unterarm ausgenommen): gemessen, was die Menuekamera zeigt. Schild und Figur
## (alle sichtbaren Netze ausser dem Schild, auch Hand und Unterarm, gehaeutet und wie im Ecken-Shader verschoben) als Dreiecke in ein
## Tiefenraster der Kamera (Zelle SICHT_PX in der Schildebene); gezaehlt die Zellen, in denen die Figur naeher als die Schildflaeche
## liegt. [Zellen, tiefste m davor, Netz und Knochen der tiefsten, je Netz Zellen]
func _sicht(m: Node3D, schild: Node3D, kam: Camera3D) -> Array:
	var ci := kam.global_transform.affine_inverse()
	var mitte: Vector3 = ci * schild.global_position
	var px := SICHT_PX / -mitte.z           # Zelle im Bild (tan)
	var zb := {}                            # Vector2i -> naechste Schildtiefe
	for mi in schild.find_children("*", "MeshInstance3D", true, false) + ([schild] if schild is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		var t := ci * (mi as MeshInstance3D).global_transform
		for s in me.get_surface_count():
			var ar := me.surface_get_arrays(s)
			var vs: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
			var cs := PackedVector3Array(); cs.resize(vs.size())
			for v in vs.size(): cs[v] = t * vs[v]
			_raster(cs, ar[Mesh.ARRAY_INDEX], px, zb, null, -1)
	var best := [0, -INF, "", {}]
	if zb.is_empty(): return [0, 0.0, "kein Schild", {}]
	var g := _sk.global_transform
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var mm := mi as MeshInstance3D
		if not mm.is_visible_in_tree() or mm == schild or schild.is_ancestor_of(mm) or mm.mesh == null: continue
		var nm := String(mm.name)
		for s in mm.mesh.get_surface_count():
			var ar := mm.mesh.surface_get_arrays(s)
			var vs: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
			var cs := PackedVector3Array(); cs.resize(vs.size())
			var mt := mm.get_active_material(s)
			var geschoben := _stoff != null and mt is ShaderMaterial and (mt as ShaderMaterial).get_shader_parameter("schild_an") != null and float((mt as ShaderMaterial).get_shader_parameter("schild_an")) > 0.0
			var gehaeutet := mm.skin != null and ar[Mesh.ARRAY_BONES] != null and not (mm.get_parent() is BoneAttachment3D)
			var trs := []
			var nb := 0
			if gehaeutet:
				nb = ar[Mesh.ARRAY_BONES].size() / vs.size()
				for i in mm.skin.get_bind_count():
					var bb := mm.skin.get_bind_bone(i)
					if bb < 0: bb = _sk.find_bone(mm.skin.get_bind_name(i))
					trs.append(g * (_posen[bb] as Transform3D) * mm.skin.get_bind_pose(i))
			for v in vs.size():
				var p := Vector3.ZERO
				if gehaeutet:
					for j in nb:
						var w: float = ar[Mesh.ARRAY_WEIGHTS][v * nb + j]
						if w > 0.0: p += (trs[ar[Mesh.ARRAY_BONES][v * nb + j]] as Transform3D) * vs[v] * w
				else:
					p = mm.global_transform * vs[v]
				if geschoben: p = _stoff.schiebe(p)
				cs[v] = ci * p
			var vor := {}
			_raster(cs, ar[Mesh.ARRAY_INDEX], px, zb, vor, 0)
			if vor.is_empty(): continue
			for k in vor: _vor_alle[k] = nm.substr(5, 1)
			best[3][nm] = int(best[3].get(nm, 0)) + vor.size()
			best[0] += vor.size()
			for k in vor:
				var e: Array = vor[k]
				if float(e[0]) > float(best[1]):
					best[1] = e[0]
					var q := schild.global_transform.affine_inverse() * (kam.global_transform * (Vector3((k.x + 0.5) * px, (k.y + 0.5) * px, -1.0) * float(e[2])))
					var kn := _knochen([mm, mm.skin, null, ar[Mesh.ARRAY_BONES], ar[Mesh.ARRAY_WEIGHTS], nb], int(e[1])) if gehaeutet else String(mm.get_parent().name)
					best[2] = "%s %s, Ecke %d, Schild x %.0f y %.0f cm" % [nm, kn, e[1], q.x * 100.0, q.y * 100.0]
	if best[0] == 0: best[1] = 0.0
	if OS.get_environment("SICHTKARTE") != "":   # zur eigenen Pruefung: Karte je 4 mm, . Schild, _ Figur davor
		var alle := {}
		for k in zb: alle[k] = "."
		for k in _vor_alle: alle[k] = _vor_alle[k]
		var lo := Vector2i(1 << 30, 1 << 30); var hi := -lo
		for k in alle: lo = Vector2i(mini(lo.x, k.x), mini(lo.y, k.y)); hi = Vector2i(maxi(hi.x, k.x), maxi(hi.y, k.y))
		for y in range(hi.y, lo.y - 1, -4):
			var z := ""
			for x in range(lo.x, hi.x + 1, 2): z += String(alle.get(Vector2i(x, y), " "))
			print("KARTE ", z)
	_vor_alle = {}
	return best

## Dreiecke (Kameraraum) ins Raster: ohne vor die naechste Tiefe in zb, mit vor je Zelle, in der das Dreieck mehr als 1 mm vor zb
## liegt, [m davor, Ecke, Tiefe]
func _raster(cs: PackedVector3Array, idx, px: float, zb: Dictionary, vor, _x: int) -> void:
	var n: int = (idx.size() if idx != null else cs.size()) / 3
	for d in n:
		var ia: int = idx[d * 3] if idx != null else d * 3
		var ib: int = idx[d * 3 + 1] if idx != null else d * 3 + 1
		var ic: int = idx[d * 3 + 2] if idx != null else d * 3 + 2
		var a := cs[ia]; var b := cs[ib]; var c := cs[ic]
		if a.z > -0.1 or b.z > -0.1 or c.z > -0.1: continue
		var sa := Vector2(a.x, a.y) / -a.z / px
		var sb := Vector2(b.x, b.y) / -b.z / px
		var sc := Vector2(c.x, c.y) / -c.z / px
		var lo := sa.min(sb).min(sc); var hi := sa.max(sb).max(sc)
		var fl := (sb.x - sa.x) * (sc.y - sa.y) - (sb.y - sa.y) * (sc.x - sa.x)
		if absf(fl) < 1e-9: continue
		for y in range(ceili(lo.y - 0.5), floori(hi.y - 0.5) + 1):
			for x in range(ceili(lo.x - 0.5), floori(hi.x - 0.5) + 1):
				var k := Vector2i(x, y)
				if vor != null and not zb.has(k): continue
				var pp := Vector2(x + 0.5, y + 0.5)
				var w1 := ((sc.x - sb.x) * (pp.y - sb.y) - (sc.y - sb.y) * (pp.x - sb.x)) / fl
				var w2 := ((sa.x - sc.x) * (pp.y - sc.y) - (sa.y - sc.y) * (pp.x - sc.x)) / fl
				var w3 := 1.0 - w1 - w2
				if w1 < 0.0 or w2 < 0.0 or w3 < 0.0: continue
				var iz := w1 / -a.z + w2 / -b.z + w3 / -c.z   # 1/Tiefe linear im Bild
				var z := 1.0 / iz
				if vor == null:
					zb[k] = minf(float(zb.get(k, INF)), z)
				elif z < float(zb[k]) - 0.001:
					var dz: float = float(zb[k]) - z
					var e = vor.get(k)
					if e == null or dz > float(e[0]):
						vor[k] = [dz, ia if w1 >= w2 and w1 >= w3 else (ib if w2 >= w3 else ic), z]
