# 1631 (Chef 18.11., 09:00, Rollenspiegel Tom; Auslöser 1515, 1535, 1569, 1569.1: Kleidung sticht durch oder hängt an der Hand):
# Durchstechprüfung für alle Figuren mit Kaufkleid, je Ruhebewegung, ohne Bild. Weg wie tools/blender348/v3/pruef_tracht.py (376.1),
# aber auf den Netzen des Spiels (daten/held_*.bin) mit dem Aufbau des Spiels (HeldFigur.baue/person: Haltung, Kopfheben, Kleiderschrank):
# Lagen = zusammenhängende Stücke jedes sichtbaren gebundenen Netzes (Leib_*, Kleid_*, Kopf/Hände, Stiefel; Kleid der Leute nach Stücken).
# In der Ruhelage des Skeletts gilt eine Ecke als bedeckt, wenn der Strahl entlang ihrer Normale binnen WEIT eine andere Lage trifft.
# DURCH: in der Bewegung trifft der Strahl gegen die Normale binnen DURCH_WEIT (mindestens DURCH_MIN) eine nach außen zeigende Wand
# dieser Lage, nicht nah an deren offenem Rand (Kragen, Ärmel, Saum) -> die Ecke liegt vor der Lage, die sie decken sollte.
# ZUG: Dreiecke, deren längste Kante gegen die Ruhelage über ZUG_FAKTOR wächst und über ZUG_LANG lang ist (Stoff hängt an der Hand,
# 1515, 1535). Je Figur und Bewegung zählt das Bild mit den meisten Ecken bzw. Dreiecken.
# Schwelle: durchstich_1631.json (Sperrklinke wie typen_1268.json): je Figur und Bewegung höchstens der gespeicherte Wert; fehlt er, 0.
# Rot (Ende 1), wenn ein Wert über Grenze plus Spielraum liegt (spielraum(), 1700); ohne Eintrag nur gemessen (NEU1631). Ohne die Datei nur Messung (Ende 0); die Werte des Laufs stehen in der Zeile SCHWELLE1631
# (erste Schwelle aus dem Lauf des Bauservers am Stand von main, nicht am Rechner: der Kaufbau dort ist der des Spiels). Neu messen und Schwelle schreiben: -- --schreiben (nur nach Befund, nie um rot zu umgehen).
# Run: godot --headless --path godot -s res://tests/durchstich_1631.gd [-- --nur=<Figur>]   (ohne Kaufdateien „ohne Kauf“, 0)
extends SceneTree

const WEIT := 0.08
const DURCH_WEIT := 0.03
const DURCH_MIN := 0.005
const RAND_WEIT := 0.03
const ZUG_FAKTOR := 1.6
const ZUG_LANG := 0.06
const BILDER := 6
const ZELLE := 0.04
const SCHWELLE := "res://tests/durchstich_1631.json"
const AUSSER := ["Eye", "Brow", "Hair", "Haar", "Bart", "Beard", "Lash", "Teeth", "Tongue"]

var fehler := 0
var neu := {}
var alt := {}
var _posen: Array = []
var _warte := false

func _initialize() -> void:
	_lauf.call_deferred()

# 1700: Spielraum über der Grenze, 2 oder 2 % (gerundet auf), was größer ist
static func spielraum(grenze: int) -> int:
	return maxi(2, ceili(grenze * 0.02))


func _lauf() -> void:
	if not HauptmenueHelden.da():
		print("DURCH1631 ohne Kauf, 0 Fehler")
		quit(0)
		return
	if FileAccess.file_exists(SCHWELLE):
		var j = JSON.parse_string(FileAccess.get_file_as_string(SCHWELLE))
		if j is Dictionary: alt = j
	var nur := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nur="): nur = a.substr(6)
	var t0 := Time.get_ticks_msec()
	# Helden je Tracht und Geschlecht, mit Startausrüstung und einmal mit Umhang (1569)
	for h in ["Wachsoldat", "Zauberlehrling", "Jägerkind", "Klosterschüler", "Wanderer"]:
		for g in ["m", "w"]:
			if not HeldFigur.da(h, g): continue
			var hw := BrsHeld.fuer_spiel("Test", "Mensch", h)
			var modell := String(HeldFigur.tracht({"herkunft": h, "aussehen": {"geschlecht": g}})["modell"])
			var start_netze := ""
			for um in [false, true]:
				var aus := hw.ausruestung.duplicate()
				if um: aus["CLOAK"] = {"base": "cloak"}
				var name := modell + ("+Umhang" if um else "")
				if nur != "" and not name.begins_with(nur): continue
				var m := HeldFigur.baue({"herkunft": h, "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": aus}, [])
				if m == null: continue
				# ohne Umhangteil im Bau (Stück ohne Schrankteil) sieht der Held mit Umhang aus wie ohne: nicht doppelt messen
				var sicht := ",".join(m.find_children("*", "MeshInstance3D", true, false).filter(func(x): return (x as MeshInstance3D).visible).map(func(x): return String(x.name)))
				if um and sicht == start_netze:
					m.free()
					continue
				start_netze = sicht
				await _figur(name, m, Gebiet.RUHE)
	# Leute und Gefährten auf dem Kaufkörper (475)
	var d := DirAccess.open("res://daten")
	if d:
		for f in d.get_files():
			if not (f.begins_with("held_L_") and f.ends_with(".bin")): continue
			var id := f.trim_prefix("held_L_").get_slice("_", 0)
			var name := "L_" + id
			if nur != "" and not name.begins_with(nur): continue
			var m := HeldFigur.person(id, [])
			if m == null: continue
			var ruhe := []
			for r in HeldFigur.ruhe_von(id):
				if r not in ruhe: ruhe.append(r)
			await _figur(name, m, ruhe)
	print("SCHWELLE1631 " + JSON.stringify(neu))
	if not FileAccess.file_exists(SCHWELLE) and "--schreiben" not in OS.get_cmdline_user_args():
		print("DURCH1631 ohne Schwelle (%s fehlt): nur gemessen, Werte in der Zeile SCHWELLE1631" % SCHWELLE)
		quit(0)
		return
	if "--schreiben" in OS.get_cmdline_user_args():
		var f := FileAccess.open(SCHWELLE, FileAccess.WRITE)
		f.store_string(JSON.stringify(neu, "\t", true) + "\n")
		print("DURCH1631 Schwelle geschrieben")
	print("DURCH1631 %d s" % ((Time.get_ticks_msec() - t0) / 1000))
	print("DURCH1631 %d Fehler" % fehler)
	quit(1 if fehler else 0)

# ---- eine Figur ------------------------------------------------------------------------------------------------------------------

func _figur(name: String, m: Node3D, ruhe: Array) -> void:
	root.add_child(m)
	await process_frame
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var ap := m.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if sk == null or ap == null:
		m.queue_free()
		return
	var netz := _sammle(sk)
	if netz.is_empty():
		m.queue_free()
		return
	netz_lage = netz["lage"]
	# Ruhelage des Skeletts (ohne Bewegung, ohne Haltung)
	var rest := []
	for i in sk.get_bone_count(): rest.append(sk.get_bone_global_rest(i))
	var lage0 := _haut(netz, rest)
	var V0: PackedVector3Array = lage0[0]
	var N0: PackedVector3Array = lage0[1]
	var gitter0 := _gitter(V0, netz["tri"])
	var deckt := {}   # Ecke -> Lage darüber
	for i in V0.size():
		var h := _strahl(V0, netz, gitter0, V0[i] + N0[i] * 0.001, N0[i], WEIT, netz["lage"][i], false)
		if h[0] >= 0: deckt[i] = h[1]
	var laengen := _kanten(V0, netz["tri"])
	sk.skeleton_updated.connect(_nach_update.bind(sk))
	# gleiche Pose in jedem Lauf (561: L_aldric 48/49, L_garrick 187/189): die Bewegung steht (speed_scale 0, sonst läuft sie um die
	# Bildzeit des Rechners weiter) und die Haltung blendet nicht nach der Uhr aus der vorigen Bewegung über (grund_w, arm_w, dame_w
	# auf -1 = sofort Sollwert), so hängt kein Bild an Reihenfolge oder Rechenzeit
	var haltung: Node = null
	for c in sk.get_children():
		if c is HeldFigur.Haltung: haltung = c
	ap.speed_scale = 0.0
	neu[name] = {}
	for bew in ruhe:
		if not ap.has_animation(bew): continue
		var an := ap.get_animation(bew)
		var durch := 0; var zug := 0; var wo := {}
		for b in BILDER:
			var t := an.length * float(b) / float(BILDER)
			ap.play(bew, 0.0)
			ap.seek(t, true)
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
			var rand := _rand_gitter(V, netz["rand"])
			var n := 0
			for i in deckt:
				var l: int = deckt[i]
				var h := _strahl(V, netz, gitter, V[i] - N[i] * 0.001, -N[i], DURCH_WEIT, l, true)
				if h[0] < 0 or h[2] < DURCH_MIN: continue
				if _nah_rand(rand, V, h[3], l): continue
				n += 1
				var k := "%s>%s %.1f m" % [netz["lname"][netz["lage"][i]], netz["lname"][l], V[i].y]
				wo[k] = wo.get(k, 0) + 1
			durch = maxi(durch, n)
			zug = maxi(zug, _zug(V, netz["tri"], laengen))
		neu[name][bew] = {"durch": durch, "zug": zug}
		# 1700: Grenze plus Spielraum (Rechenrauschen zwischen Rechner und Bauserver, je 1–2 Ecken, Läufe 564–570);
		# Figur oder Bewegung ohne Eintrag: nur gemessen (Zeile NEU1631), Eintrag mit dem nächsten -- --schreiben am Bauserver.
		var bekannt: bool = alt.has(name) and (alt[name] as Dictionary).has(bew)
		var grenze: Dictionary = alt.get(name, {}).get(bew, {})
		var gd := int(grenze.get("durch", 0)); var gz := int(grenze.get("zug", 0))
		var oben := wo.keys()
		oben.sort_custom(func(x, y): return wo[x] > wo[y])
		print("DURCH1631 %s %s: durch %d (Grenze %d), Zug %d (Grenze %d)  %s" % [name, bew, durch, gd, zug, gz, ", ".join(oben.slice(0, 4).map(func(x): return "%s: %d" % [x, wo[x]]))])
		if not bekannt:
			print("NEU1631 %s %s: ohne Grenze, nur gemessen (durch %d, Zug %d)" % [name, bew, durch, zug])
			continue
		if durch > gd + spielraum(gd):
			print("FEHLER %s %s: %d Ecken stechen durch die Lage darüber (Grenze %d + %d)" % [name, bew, durch, gd, spielraum(gd)])
			fehler += 1
		if zug > gz + spielraum(gz):
			print("FEHLER %s %s: %d Dreiecke gezogen (Grenze %d + %d)" % [name, bew, zug, gz, spielraum(gz)])
			fehler += 1
	sk.skeleton_updated.disconnect(_nach_update)
	m.queue_free()
	await process_frame

func _nach_update(sk: Skeleton3D) -> void:
	if not _warte: return
	_warte = false
	_posen = []
	for i in sk.get_bone_count(): _posen.append(sk.get_bone_global_pose(i))

# Netze einer Figur: Ecken (Ort, Normale, Knochen, Gewichte je Netz), Dreiecke, Lagen (Stücke), offene Ränder
func _sammle(sk: Skeleton3D) -> Dictionary:
	var V := PackedVector3Array(); var N := PackedVector3Array()
	var tri := PackedInt32Array(); var lage := PackedInt32Array()
	var teile := []   # je Netz: [erste Ecke, Anzahl, Knochen, Gewichte, je Ecke, Bindung (Knochen), Bindung (Lage)]
	var lname := []
	var rand := PackedInt32Array()
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
			# Formschlüssel, wie sie an der Figur stehen (unter_CLOAK, Gesicht, Statur; Godot hält die Formen absolut): fest für die Ruhe
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
			# Stücke: Ecken mit gleichem Ort verschweißt (Nähte der Textur), dann zusammenhängend
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
			var l0 := lname.size()
			for i in vs.size():
				var r := _wurzel(eltern, wid[i])
				if not stueck.has(r):
					stueck[r] = lname.size()
					lname.append("%s%s#%d" % [nm, (".%d" % s) if me.mesh.get_surface_count() > 1 else "", stueck.size() - 1])
				lage.append(stueck[r])
			if stueck.size() == 1: lname[l0] = nm + ((".%d" % s) if me.mesh.get_surface_count() > 1 else "")
			for t in ix.size(): tri.append(b0 + ix[t])
			# offene Ränder: Kanten (verschweißt) an nur einem Dreieck
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
			teile.append([b0, vs.size(), bs, ws, int(bs.size() / vs.size()), bb, bp])
	if V.is_empty(): return {}
	return {"V": V, "N": N, "tri": tri, "lage": lage, "teile": teile, "lname": lname, "rand": rand}

func _wurzel(e: PackedInt32Array, i: int) -> int:
	while e[i] != i:
		e[i] = e[e[i]]
		i = e[i]
	return i

# Haut: Ecken und Normalen im Raum des Skeletts zu den Knochenlagen posen (global)
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
		if (hi - lo).length_squared() > 75: continue   # gerissenes Riesendreieck (ZUG zählt es), nicht ins Gitter
		for x in range(lo.x, hi.x + 1):
			for y in range(lo.y, hi.y + 1):
				for z in range(lo.z, hi.z + 1):
					var k := Vector3i(x, y, z)
					if g.has(k): g[k].append(t)
					else: g[k] = [t]
	return g

# erster Treffer des Strahls auf eine Lage != eigene (nur_lage >= 0 mit nur=true: nur diese Lage, Wand nach außen wie die Normale)
# -> [Dreieck, Lage, Abstand, Treffpunkt]
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
						if fn.dot(-dir) <= 0.0: continue   # Wand zeigt wie die Ecke nach außen (dir ist gegen die Normale)
					best = [t, lt, d, hit, fn]
	# 1652: decken heißt, die nächste Wand einer anderen Lage wird von innen getroffen (zeigt wie der Strahl nach außen); ist es ihre
	# Außenseite, liegt die Lage darunter (Rückseite eines aufgesetzten Stücks, Osrics Sonne auf der Robe)
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
	var lage: PackedInt32Array = netz_lage
	for x in range(c.x - r, c.x + r + 1):
		for y in range(c.y - r, c.y + r + 1):
			for z in range(c.z - r, c.z + r + 1):
				var k := Vector3i(x, y, z)
				if not g.has(k): continue
				for i in g[k]:
					if lage[i] == l and V[i].distance_to(p) < RAND_WEIT: return true
	return false

var netz_lage := PackedInt32Array()

func _kanten(V: PackedVector3Array, tri: PackedInt32Array) -> PackedFloat32Array:
	var L := PackedFloat32Array(); L.resize(tri.size() / 3)
	for t in range(0, tri.size(), 3):
		var a := V[tri[t]]; var b := V[tri[t + 1]]; var c := V[tri[t + 2]]
		L[t / 3] = maxf(a.distance_to(b), maxf(b.distance_to(c), c.distance_to(a)))
	return L

func _zug(V: PackedVector3Array, tri: PackedInt32Array, L0: PackedFloat32Array) -> int:
	var n := 0
	for t in range(0, tri.size(), 3):
		var a := V[tri[t]]; var b := V[tri[t + 1]]; var c := V[tri[t + 2]]
		var l := maxf(a.distance_to(b), maxf(b.distance_to(c), c.distance_to(a)))
		if l > ZUG_LANG and l > L0[t / 3] * ZUG_FAKTOR: n += 1
	return n
