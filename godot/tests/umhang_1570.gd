# 1570 (Chef 12.11.: „Jeder, dem ich eine Ausrüstung Umhang gebe, kann Umhang tragen“; 18.11.: „ich bin auch für die Systemlösung“;
# Neins 861 „links … riesen Beule“, 1676 „rechte Armseite … überdeckt … bekleckst“): jeder Held je Herkunft M/W mit angelegtem
# Umhang, auf den Netzen des Spiels (HeldFigur.baue wie Welt und Kampf), drei Prüfungen je Bild:
#  BEULE: Umhangecken zwischen Hüfte und Achsel, die seitlich weiter als BEULE_MARGE über Rumpf und Oberarm in derselben Höhe hinausragen
#    (Körperbreite im selben Bild; gehobener Arm zählt dort nicht mehr mit, eine Flanke, die ihm folgt, ist eine Beule).
#  UNTERARM: sichtbare Ecken von Unterarm und Hand (Gewicht lowerarm/hand/Finger), deren Strahl zur Spielkamera zuerst den Umhang trifft
#    (Welt: Blick 30 Grad von oben, von vorn, schräg vorn und von der Seite des Arms; Kampf: Spielkamera 25 Grad von hinten, nur die Beule und das
#    Durchstechen zählen dort, hinten deckt der Umhang den Arm zu Recht).
#  DURCH: wie durchstich_1631 (Grundlage), nur Paare mit dem Umhang (Körper und Kleidung durch den Umhang oder Umhang durch sie).
# Welt: Gehen mit Zweihänder (Gehen_axt) und ohne (Gehen); Kampf: Kampfbewegungen wie kampf/figur.gd _kaufheld (SS_IdleCombat, Hieb, Abwehr: Handaxt und
# Schild). Rot (Ende 1), wenn eine Zahl über ihrer Grenze liegt: BEULE 0, UNTERARM GRENZE_ARM; DURCH nicht über dem Wert an main
# (umhang_1570.json, gemessen am Stand vor 1570 mit den Kaufmodellen des Bauservers, Spielraum wie durchstich_1631 spielraum).
# Run: godot --headless --path godot -s res://tests/umhang_1570.gd [-- --nur=<Herkunft>]   (ohne Kaufdateien „ohne Kauf“, 0)
extends SceneTree

const BILDER := 6
const ZELLE := 0.04
const WEIT := 0.08
const DURCH_WEIT := 0.03
const DURCH_MIN := 0.005
const RAND_WEIT := 0.03
const BEULE_MARGE := 0.05     # m über die Körperbreite (Stofflage, Falte)
const GRENZE_ARM := 0         # Ecken von Unterarm/Hand unter dem Umhang (Welt, Blick von vorn bis seitlich)
const MAIN_DURCH := "res://tests/umhang_1570.json"   # je „Herkunft G Ort Bewegung“: durch am Stand vor 1570
const AUSSER := ["Eye", "Brow", "Hair", "Haar", "Bart", "Beard", "Lash", "Teeth", "Tongue"]
const HERKUENFTE := ["Wachsoldat", "Zauberlehrling", "Jägerkind", "Klosterschüler", "Wanderer"]
const WELT := ["Gehen_axt", "Gehen"]   # mit Zweihänder (tragen.gd GANG_ZWEI) und ohne Waffe (1676: Schankraum, Waffe abgelegt)
const KAMPF := ["SS_IdleCombat", "Hieb", "Abwehr"]
const RUMPF := ["pelvis", "spine_01", "spine_02", "spine_03", "neck_01", "neck_02", "clavicle_l", "clavicle_r", "upperarm_l", "upperarm_r", "thigh_l", "thigh_r"]
const FINGER := ["thumb", "index", "middle", "ring", "pinky"]

var fehler := 0
var _posen: Array = []
var _warte := false
var netz_lage := PackedInt32Array()
var zeilen := []
var main_durch := {}

func _initialize() -> void:
	_lauf.call_deferred()

static func ist_umhang(n: String) -> bool:
	return n.begins_with("Kleid_CLOAK") or n.begins_with("Teil_UMHANG")

func _lauf() -> void:
	if not HauptmenueHelden.da():
		print("UMHANG1570 ohne Kauf, 0 Fehler")
		quit(0)
		return
	if FileAccess.file_exists(MAIN_DURCH):
		var j = JSON.parse_string(FileAccess.get_file_as_string(MAIN_DURCH))
		if j is Dictionary: main_durch = j
	var nur := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nur="): nur = a.substr(6)
	var t0 := Time.get_ticks_msec()
	for h in HERKUENFTE:
		if nur != "" and not h.begins_with(nur): continue
		for g in ["m", "w"]:
			if not HeldFigur.da(h, g): continue
			var hw := BrsHeld.fuer_spiel("Test", "Mensch", h)
			# Welt: Zweihänder, keine Nebenhand
			var aus := hw.ausruestung.duplicate()
			aus["CLOAK"] = {"base": "cloak"}; aus["MAIN_HAND"] = {"base": "greatsword"}; aus.erase("OFF_HAND")
			var m := HeldFigur.baue({"herkunft": h, "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": aus}, [])
			if m != null: await _figur("%s %s Welt" % [h, g.to_upper()], m, WELT, false)
			# Kampf: wie _kaufheld (ohne Ausrüstung unterwegs), Handaxt und Schild halten die Kampfbewegungen
			var ak := hw.ausruestung.duplicate(); ak["CLOAK"] = {"base": "cloak"}
			var mk := HeldFigur.baue({"herkunft": h, "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": {}, "kleid": ak}, [])
			if mk != null:
				_kampf_bewegungen(mk)
				await _figur("%s %s Kampf" % [h, g.to_upper()], mk, KAMPF, true)
	for z in zeilen: print(z)
	print("UMHANG1570 %d s" % ((Time.get_ticks_msec() - t0) / 1000))
	print("UMHANG1570 %d Fehler" % fehler)
	quit(1 if fehler else 0)

# Kampfbewegungen auf die Figur wie kampf/figur.gd _kaufheld
func _kampf_bewegungen(m: Node3D) -> void:
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var sc := Gebiet.lade_glb("res://daten/kampf-bewegungen.bin")
	if sc == null or ap == null or sk == null: return
	var ap0 := Gebiet.finde(sc, "AnimationPlayer") as AnimationPlayer
	var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / HeldFigur.bew_becken
	var pfad := str(HeldFigur._pfad(m, sk))
	var lib := ap.get_animation_library("")
	for n in KAMPF:
		if not ap0.has_animation(n): continue
		var an := ap0.get_animation(n).duplicate(true) as Animation
		for t in range(an.get_track_count() - 1, -1, -1):
			var bn := String(an.track_get_path(t)).get_slice(":", 1)
			an.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
			var ty := an.track_get_type(t)
			if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]) or sk.find_bone(bn) < 0:
				an.remove_track(t)
			elif ty == Animation.TYPE_POSITION_3D:
				for i in an.track_get_key_count(t): an.track_set_key_value(t, i, an.track_get_key_value(t, i) * f)
		if lib.has_animation(n): lib.remove_animation(n)
		lib.add_animation(n, an)
	sc.free()

# ---- eine Figur ------------------------------------------------------------------------------------------------------------------

func _figur(name: String, m: Node3D, bewegungen: Array, kampf: bool) -> void:
	root.add_child(m)
	await process_frame
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var ap := m.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if sk == null or ap == null:
		m.queue_free()
		return
	var netz := _sammle(sk)
	if netz.is_empty() or not (netz["umhang"] as Dictionary).values().has(true):
		print("FEHLER %s: kein Umhang sichtbar" % name)
		fehler += 1
		m.queue_free()
		return
	netz_lage = netz["lage"]
	var um: Dictionary = netz["umhang"]   # Lage -> ist Umhang
	var rest := []
	for i in sk.get_bone_count(): rest.append(sk.get_bone_global_rest(i))
	var lage0 := _haut(netz, rest)
	var V0: PackedVector3Array = lage0[0]
	var N0: PackedVector3Array = lage0[1]
	var gitter0 := _gitter(V0, netz["tri"])
	var deckt := {}
	for i in V0.size():
		var h := _strahl(V0, netz, gitter0, V0[i] + N0[i] * 0.001, N0[i], WEIT, netz["lage"][i], false)
		if h[0] >= 0 and (um.get(h[1], false) or um.get(netz["lage"][i], false)): deckt[i] = h[1]
	sk.skeleton_updated.connect(_nach_update.bind(sk))
	var haltung: Node = null
	for c in sk.get_children():
		if c is HeldFigur.Haltung: haltung = c
	ap.speed_scale = 0.0
	for bew in bewegungen:
		if not ap.has_animation(bew):
			print("FEHLER %s: Bewegung %s fehlt" % [name, bew])
			fehler += 1
			continue
		var an := ap.get_animation(bew)
		var beule := 0; var beule_cm := 0.0; var beule_wo := ""
		var arm := {"l": 0, "r": 0}; var durch := 0; var wo_d := {}
		for b in BILDER:
			ap.play(bew, 0.0)
			ap.seek(an.length * float(b) / float(BILDER), true)
			if haltung:
				haltung.grund_w = -1.0; haltung.arm_w = -1.0; haltung.dame_w = -1.0
			_posen = []
			_warte = true
			await process_frame
			await process_frame
			if _posen.is_empty(): continue
			var lage := _haut(netz, _posen)
			var V: PackedVector3Array = lage[0]
			var N: PackedVector3Array = lage[1]
			var gitter := _gitter(V, netz["tri"])
			# BEULE
			var bl := _beule(netz, V, _posen, sk)
			if int(bl[0]) > beule: beule = int(bl[0]); beule_cm = float(bl[1]) * 100.0; beule_wo = String(bl[2]) + " Bild %d" % b
			# UNTERARM (nur Welt)
			if not kampf:
				for s in ["l", "r"]:
					arm[s] = maxi(arm[s], _arm_bedeckt(netz, V, N, gitter, s))
			# DURCH
			var rand := _rand_gitter(V, netz["rand"])
			var n := 0
			for i in deckt:
				var l: int = deckt[i]
				var h := _strahl(V, netz, gitter, V[i] - N[i] * 0.001, -N[i], DURCH_WEIT, l, true)
				if h[0] < 0 or h[2] < DURCH_MIN: continue
				if _nah_rand(rand, V, h[3], l): continue
				n += 1
				var wk := "%s>%s %.1f" % [netz["lname"][netz["lage"][i]], netz["lname"][l], V[i].y]
				wo_d[wk] = wo_d.get(wk, 0) + 1
			durch = maxi(durch, n)
		var z := "UMHANG1570 %s %s: Beule %d Ecken (bis %.1f cm, %s), Unterarm unter Umhang links %d rechts %d, durch %d" % [name, bew, beule, beule_cm, beule_wo, arm["l"], arm["r"], durch]
		var oben := wo_d.keys()
		oben.sort_custom(func(x, y): return wo_d[x] > wo_d[y])
		z += "  " + ", ".join(oben.slice(0, 4).map(func(x): return "%s: %d" % [x, wo_d[x]]))
		zeilen.append(z)
		print(z)
		if beule > 0:
			print("FEHLER %s %s: Flanke %.1f cm über Körperbreite (%d Ecken)" % [name, bew, beule_cm, beule])
			fehler += 1
		if arm["l"] > GRENZE_ARM or arm["r"] > GRENZE_ARM:
			print("FEHLER %s %s: Umhang über dem Unterarm (links %d, rechts %d Ecken)" % [name, bew, arm["l"], arm["r"]])
			fehler += 1
		var gd := int(main_durch.get("%s %s" % [name, bew], 0))
		if durch > gd + maxi(2, ceili(gd * 0.02)):
			print("FEHLER %s %s: %d Ecken stechen durch (Umhang), an main %d" % [name, bew, durch, gd])
			fehler += 1
	sk.skeleton_updated.disconnect(_nach_update)
	m.queue_free()
	await process_frame

func _nach_update(sk: Skeleton3D) -> void:
	if not _warte: return
	_warte = false
	_posen = []
	for i in sk.get_bone_count(): _posen.append(sk.get_bone_global_pose(i))

# Beule: Umhangecken zwischen Hüfte und Achsel, seitlich über Rumpf und Oberarm hinaus (Rahmen des Beckens: x quer, y hoch)
# -> [Ecken über BEULE_MARGE, größter Überstand über die Körperbreite, Ort]
func _beule(netz: Dictionary, V: PackedVector3Array, posen: Array, sk: Skeleton3D) -> Array:
	var bp := sk.find_bone("pelvis"); var bl := sk.find_bone("upperarm_l"); var br := sk.find_bone("upperarm_r")
	if bp < 0 or bl < 0 or br < 0: return [0, 0.0, ""]
	var pv: Transform3D = posen[bp]
	var quer := ((posen[bl] as Transform3D).origin - (posen[br] as Transform3D).origin)
	quer.y = 0.0
	quer = quer.normalized()
	var mitte := ((posen[bl] as Transform3D).origin + (posen[br] as Transform3D).origin) * 0.5
	var y0 := pv.origin.y
	var y1 := minf((posen[bl] as Transform3D).origin.y, (posen[br] as Transform3D).origin.y) - 0.08   # unter der Achsel
	if y1 <= y0: return [0, 0.0, ""]
	var bahnen := 8
	var breit := []   # je Bahn [links, rechts] Körper
	for k in bahnen: breit.append([0.0, 0.0])
	var art: PackedByteArray = netz["art"]   # 1 Rumpf/Oberarm, 2 Umhang, 3 Unterarm/Hand l, 4 r
	for i in V.size():
		if art[i] != 1: continue
		var p := V[i]
		if p.y < y0 or p.y > y1: continue
		var k := clampi(int((p.y - y0) / (y1 - y0) * bahnen), 0, bahnen - 1)
		var x := (p - mitte).dot(quer)
		if x > 0: breit[k][0] = maxf(breit[k][0], x)
		else: breit[k][1] = maxf(breit[k][1], -x)
	var n := 0; var best := 0.0; var wo := ""
	for i in V.size():
		if art[i] != 2: continue
		var p := V[i]
		if p.y < y0 or p.y > y1: continue
		var k := clampi(int((p.y - y0) / (y1 - y0) * bahnen), 0, bahnen - 1)
		var x := (p - mitte).dot(quer)
		var ueber: float = (x - float(breit[k][0])) if x > 0 else (-x - float(breit[k][1]))
		if ueber > best: best = ueber; wo = "%s %.2f m" % ["links" if x > 0 else "rechts", p.y]
		if ueber > BEULE_MARGE: n += 1
	return [n, best, wo]

# Unterarm: sichtbare Ecken (Normale zur Kamera) von Unterarm/Hand der Seite s, deren Strahl zur Kamera zuerst den Umhang trifft;
# Blick der Spielkamera der Welt (30 Grad von oben) von vorn, schräg vorn und von der Seite dieses Arms (von der anderen Seite und von
# hinten deckt der Umhang den Arm zu Recht); größte Zahl
func _arm_bedeckt(netz: Dictionary, V: PackedVector3Array, N: PackedVector3Array, g: Dictionary, s: String) -> int:
	var art: PackedByteArray = netz["art"]
	var soll := 3 if s == "l" else 4
	var best := 0
	var vz := 1.0 if s == "l" else -1.0   # linke Seite +X
	for gier in [0.0, 45.0 * vz, 90.0 * vz]:
		# zur Kamera: Figur blickt nach +Z; Kamera vorn oben, um gier um die Hochachse gedreht
		var zur := Vector3(0, sin(deg_to_rad(30.0)), cos(deg_to_rad(30.0))).rotated(Vector3.UP, deg_to_rad(gier))
		var n := 0
		for i in V.size():
			if art[i] != soll or N[i].dot(zur) < 0.2: continue
			var h := _strahl_jede(V, netz, g, V[i] + N[i] * 0.002, zur, 0.6, netz["lage"][i])
			if h >= 0 and (netz["umhang"] as Dictionary).get(h, false): n += 1
		best = maxi(best, n)
	return best

# erster Treffer einer anderen Lage (gleich welche Seite) -> Lage oder -1
func _strahl_jede(V: PackedVector3Array, netz: Dictionary, g: Dictionary, von: Vector3, dir: Vector3, weit: float, l: int) -> int:
	var tri: PackedInt32Array = netz["tri"]; var lage: PackedInt32Array = netz["lage"]
	var bis := von + dir * weit
	var best := INF; var bl := -1
	var schritte := int(ceil(weit / (ZELLE * 0.5)))
	var gesehen := {}
	var zellen := {}
	for k in schritte + 1:
		zellen[_zelle(von + dir * (weit * float(k) / float(schritte)))] = true
	for z in zellen:
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				for dz in [-1, 0, 1]:
					var c := (z as Vector3i) + Vector3i(dx, dy, dz)
					if not g.has(c): continue
					for t in g[c]:
						if gesehen.has(t): continue
						gesehen[t] = true
						var lt := lage[tri[t]]
						if lt == l: continue
						var hit = Geometry3D.segment_intersects_triangle(von, bis, V[tri[t]], V[tri[t + 1]], V[tri[t + 2]])
						if hit == null: continue
						var d := von.distance_to(hit)
						if d < best: best = d; bl = lt
	return bl

# ---- wie durchstich_1631 ---------------------------------------------------------------------------------------------------------

func _sammle(sk: Skeleton3D) -> Dictionary:
	var V := PackedVector3Array(); var N := PackedVector3Array()
	var tri := PackedInt32Array(); var lage := PackedInt32Array()
	var art := PackedByteArray()
	var teile := []
	var lname := []
	var umhang := {}
	var rand := PackedInt32Array()
	var knochen := {}
	for i in sk.get_bone_count(): knochen[i] = sk.get_bone_name(i)
	for me_ in sk.find_children("*", "MeshInstance3D", true, false):
		var me := me_ as MeshInstance3D
		if me.skin == null or me.mesh == null or not me.is_visible_in_tree(): continue
		var nm := String(me.name)
		if AUSSER.any(func(x): return x in nm): continue
		var bb := PackedInt32Array(); var bp := []
		for k in me.skin.get_bind_count():
			var bn := me.skin.get_bind_name(k)
			bb.append(sk.find_bone(bn) if bn != "" else me.skin.get_bind_bone(k))
			bp.append(me.skin.get_bind_pose(k))
		for s in me.mesh.get_surface_count():
			var a := me.mesh.surface_get_arrays(s)
			var vs: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var ns = a[Mesh.ARRAY_NORMAL]
			var bs = a[Mesh.ARRAY_BONES]; var ws = a[Mesh.ARRAY_WEIGHTS]; var ix = a[Mesh.ARRAY_INDEX]
			if vs.is_empty() or bs == null or ws == null or ns == null: continue
			if ix == null:
				ix = PackedInt32Array(range(vs.size()))
			var formen := me.mesh.surface_get_blend_shape_arrays(s)
			if not formen.is_empty():
				vs = vs.duplicate(); ns = (ns as PackedVector3Array).duplicate()
				var basis_v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]; var basis_n: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
				for fi in formen.size():
					var w := me.get_blend_shape_value(fi)
					if absf(w) < 0.001: continue
					var fv: PackedVector3Array = formen[fi][Mesh.ARRAY_VERTEX]
					var fn = formen[fi][Mesh.ARRAY_NORMAL]
					for i in vs.size():
						vs[i] += (fv[i] - basis_v[i]) * w
						if fn is PackedVector3Array and not (fn as PackedVector3Array).is_empty(): ns[i] += (fn[i] - basis_n[i]) * w
			var b0 := V.size()
			V.append_array(vs); N.append_array(ns)
			var nb := int(bs.size() / vs.size())
			var cloak := ist_umhang(nm)
			# Art je Ecke: Umhang; sonst Unterarm/Hand je Seite, Rumpf/Oberarm (größtes Gewicht)
			for i in vs.size():
				if cloak: art.append(2); continue
				var w_arm := {"l": 0.0, "r": 0.0}; var w_rumpf := 0.0; var w_sum := 0.0
				for k in nb:
					var w: float = ws[i * nb + k]
					if w <= 0.0: continue
					var bi: int = bb[bs[i * nb + k]]
					var bn := String(knochen.get(bi, ""))
					w_sum += w
					for sd in ["l", "r"]:
						if bn.ends_with("_" + sd) and (bn.begins_with("lowerarm") or bn.begins_with("hand") or FINGER.any(func(f): return bn.begins_with(f))):
							w_arm[sd] += w
					if bn in RUMPF: w_rumpf += w
				if w_arm["l"] > 0.5 * w_sum: art.append(3)
				elif w_arm["r"] > 0.5 * w_sum: art.append(4)
				elif w_rumpf > 0.5 * w_sum: art.append(1)
				else: art.append(0)
			var schweiss := {}
			var wid := PackedInt32Array(); wid.resize(vs.size())
			for i in vs.size():
				var key := Vector3i((vs[i] * 10000.0).round())
				if not schweiss.has(key): schweiss[key] = schweiss.size()
				wid[i] = schweiss[key]
			var eltern := PackedInt32Array(range(schweiss.size()))
			for t in range(0, ix.size(), 3):
				var r0 := _wurzel(eltern, wid[ix[t]])
				for q in [1, 2]:
					var r1 := _wurzel(eltern, wid[ix[t + q]])
					if r1 != r0: eltern[r1] = r0
			var stueck := {}
			for i in vs.size():
				var r := _wurzel(eltern, wid[i])
				if not stueck.has(r):
					stueck[r] = lname.size()
					umhang[lname.size()] = cloak
					lname.append("%s#%d" % [nm, stueck.size() - 1])
				lage.append(stueck[r])
			for t in ix.size(): tri.append(b0 + ix[t])
			var kanten := {}
			for t in range(0, ix.size(), 3):
				for q in 3:
					var x := wid[ix[t + q]]; var y := wid[ix[t + (q + 1) % 3]]
					var k := Vector2i(mini(x, y), maxi(x, y))
					kanten[k] = kanten.get(k, 0) + 1
			var am_rand := {}
			for k in kanten:
				if kanten[k] == 1: am_rand[k.x] = true; am_rand[k.y] = true
			for i in vs.size():
				if am_rand.has(wid[i]): rand.append(b0 + i)
			teile.append([b0, vs.size(), bs, ws, nb, bb, bp])
	if V.is_empty(): return {}
	return {"V": V, "N": N, "tri": tri, "lage": lage, "teile": teile, "lname": lname, "rand": rand, "art": art, "umhang": umhang}

func _wurzel(e: PackedInt32Array, i: int) -> int:
	while e[i] != i:
		e[i] = e[e[i]]
		i = e[i]
	return i

func _haut(netz: Dictionary, posen: Array) -> Array:
	var V0: PackedVector3Array = netz["V"]; var N0: PackedVector3Array = netz["N"]
	var V := PackedVector3Array(); V.resize(V0.size())
	var N := PackedVector3Array(); N.resize(V0.size())
	for tl in netz["teile"]:
		var b0: int = tl[0]; var anz: int = tl[1]; var bs = tl[2]; var ws = tl[3]; var n: int = tl[4]
		var bb: PackedInt32Array = tl[5]; var bp: Array = tl[6]
		var M := []
		for k in bb.size(): M.append((posen[bb[k]] as Transform3D) * (bp[k] as Transform3D) if bb[k] >= 0 else Transform3D.IDENTITY)
		for i in anz:
			var p := Vector3.ZERO; var q := Vector3.ZERO
			var v := V0[b0 + i]; var nn := N0[b0 + i]
			for k in n:
				var w: float = ws[i * n + k]
				if w <= 0.0: continue
				var t: Transform3D = M[bs[i * n + k]]
				p += (t * v) * w
				q += (t.basis * nn) * w
			V[b0 + i] = p
			N[b0 + i] = q.normalized()
	return [V, N]

func _zelle(p: Vector3) -> Vector3i:
	return Vector3i(floori(p.x / ZELLE), floori(p.y / ZELLE), floori(p.z / ZELLE))

func _gitter(V: PackedVector3Array, tri: PackedInt32Array) -> Dictionary:
	var g := {}
	for t in range(0, tri.size(), 3):
		var a := V[tri[t]]; var b := V[tri[t + 1]]; var c := V[tri[t + 2]]
		var lo := _zelle(Vector3(minf(a.x, minf(b.x, c.x)), minf(a.y, minf(b.y, c.y)), minf(a.z, minf(b.z, c.z))))
		var hi := _zelle(Vector3(maxf(a.x, maxf(b.x, c.x)), maxf(a.y, maxf(b.y, c.y)), maxf(a.z, maxf(b.z, c.z))))
		if (hi - lo).length_squared() > 75: continue
		for x in range(lo.x, hi.x + 1):
			for y in range(lo.y, hi.y + 1):
				for z in range(lo.z, hi.z + 1):
					var k := Vector3i(x, y, z)
					if g.has(k): g[k].append(t)
					else: g[k] = [t]
	return g

func _strahl(V: PackedVector3Array, netz: Dictionary, g: Dictionary, von: Vector3, dir: Vector3, weit: float, l: int, nur: bool) -> Array:
	var tri: PackedInt32Array = netz["tri"]; var lage: PackedInt32Array = netz["lage"]
	var bis := von + dir * weit
	var lo := _zelle(Vector3(minf(von.x, bis.x), minf(von.y, bis.y), minf(von.z, bis.z)))
	var hi := _zelle(Vector3(maxf(von.x, bis.x), maxf(von.y, bis.y), maxf(von.z, bis.z)))
	var best := [-1, -1, INF, Vector3.ZERO]
	var gesehen := {}
	for x in range(lo.x, hi.x + 1):
		for y in range(lo.y, hi.y + 1):
			for z in range(lo.z, hi.z + 1):
				var k := Vector3i(x, y, z)
				if not g.has(k): continue
				for t in g[k]:
					if gesehen.has(t): continue
					gesehen[t] = true
					var lt := lage[tri[t]]
					if nur:
						if lt != l: continue
					elif lt == l: continue
					var a := V[tri[t]]; var b := V[tri[t + 1]]; var c := V[tri[t + 2]]
					var hit = Geometry3D.segment_intersects_triangle(von, bis, a, b, c)
					if hit == null: continue
					var d := von.distance_to(hit)
					if d >= best[2]: continue
					var fn := (b - a).cross(c - a)
					if nur:
						if fn.dot(-dir) <= 0.0: continue
					best = [t, lt, d, hit, fn]
	if not nur and best[0] >= 0 and (best[4] as Vector3).dot(dir) <= 0.0: return [-1, -1, INF, Vector3.ZERO]
	return best

func _rand_gitter(V: PackedVector3Array, rand: PackedInt32Array) -> Dictionary:
	var g := {}
	for i in rand:
		var k := _zelle(V[i])
		if g.has(k): g[k].append(i)
		else: g[k] = [i]
	return g

func _nah_rand(g: Dictionary, V: PackedVector3Array, p: Vector3, l: int) -> bool:
	var c := _zelle(p)
	var r := int(ceil(RAND_WEIT / ZELLE))
	for x in range(c.x - r, c.x + r + 1):
		for y in range(c.y - r, c.y + r + 1):
			for z in range(c.z - r, c.z + r + 1):
				var k := Vector3i(x, y, z)
				if not g.has(k): continue
				for i in g[k]:
					if netz_lage[i] == l and V[i].distance_to(p) < RAND_WEIT: return true
	return false

