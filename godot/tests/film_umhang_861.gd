# 861 (Chef 10.11., 13:12, Bild t274.14: „Hat der Umhang wieder eine Beule …?“; 11.11., 12:09 Bertram, Umhang links; 11.11., 20:11,
# Film 595: „wieder so einen Umhangbuckel“; Sokrates: nachstellen im Filmlauf, alle Klassen mit Umhang): ein Held je Lauf (KLASSE=
# FIGHTER, CLERIC, ROGUE, WIZARD) mit der Ausrüstung der Probe im Kampfort, Spiellicht (Toon, Tusche nach Licht, Schatten), Spielkamera
# herangezogen. Erst gemessen, ohne Bild: der Abstand jeder Umhangecke zur nächsten Ecke darunter (Körper, Kleidung) in „Stehen“ und in
# jeder Kampfbewegung, mit dem Becken an derselben Stelle; wo er wächst, hebt sich der Umhang vom Rücken (Beule). Zur größten Stelle je
# Bewegung: Höhe, Seite, Gewichte und welcher Knochen wie viel dazu beiträgt (Zeilen „Umhang 861“). Dann der Film: Kampfhaltung von
# hinten, langsam herum zu beiden Seiten, dann die Kampfbewegungen schräg von hinten. Die Regeln laufen nicht. Wie film_umhang_656.gd.
# Aufruf: KLASSE=CLERIC PROBE=861 xvfb-run godot --path godot --rendering-driver opengl3 --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_umhang_861.gd   (MESSEN=nur: nur die Messung, kein Film)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const HeldFigur = preload("res://skripte/heldfigur.gd")

const NAMEN := {"FIGHTER": "Kämpfer", "CLERIC": "Kleriker", "ROGUE": "Schurke", "WIZARD": "Magier"}
const ZELLE := 0.04       # Raster für die Suche der Ecke darunter (m)
const NAH := 0.12         # weiter weg zählt keine Ecke als „darunter“ (Saum frei)

var fg: Node3D
var anim: AnimationPlayer
var sk: Skeleton3D
var lb: Label
var lz: Label
var hinten := 0.0
var klasse := "FIGHTER"

# Messung: je Ecke [Netz, Lage im Netz, Binds, Gewichte]
var netze: Array = []      # je Netz {"binds": [[Knochen, Bindlage]], "skel": bool}
var ecken: Array = []      # [netz, pos, binds(PackedInt32Array), gewichte(PackedFloat32Array)]
var umhang: PackedInt32Array = []
var partner: PackedInt32Array = []
var ref_pos: PackedVector3Array = []
var ref_g: Array = []      # Knochenlagen in Stehen (Becken angeglichen = wie gemessen)
var K := Transform3D.IDENTITY
var links := 1.0           # Vorzeichen von x für die linke Seite der Figur
var hinten_z := -1.0       # Vorzeichen von z für hinten


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	klasse = OS.get_environment("KLASSE") if OS.get_environment("KLASSE") != "" else "FIGHTER"
	var p = Probe.new()
	p.hero_cls = klasse
	p.merc_cls = "FIGHTER" if klasse != "FIGHTER" else "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	if kf == null:
		print("FEHLER Film 861: kein Kampfort")
		quit(1)
		return
	if kf.ui != null:
		kf.ui.visible = false
	var bis := Time.get_ticks_msec() + 15000
	while kf.playing and Time.get_ticks_msec() < bis:
		await process_frame
	kf.playing = true     # keine Meldungen der Regeln mehr; _process des Kampforts läuft weiter (Tusche nach Licht)
	for id in kf.figures:
		var f = kf.figures[id]
		f.set_process(false)
		if f.fighter.monster == null and fg == null and f.fighter.id == "hero":
			fg = f
		else:
			f.visible = false
	if fg == null:
		print("FEHLER Film 861: kein Held")
		quit(1)
		return
	anim = fg.anim
	sk = _find(fg, "Skeleton3D") as Skeleton3D
	if not fg.kauf:
		print("Film 861: ohne Kaufheld (daten/kampf-bewegungen.bin), nichts zu filmen")
		quit(0)
		return
	print("Film 861: %s, Waffe %s, Schild %s, Satz Schwert und Schild %s" % [NAMEN.get(klasse, klasse),
		fg.fighter.hero.main.id if fg.fighter.hero.has("main") else "-", fg._schild(), fg._ss()])
	var alle: Array = Array(anim.get_animation_list())
	print("Film 861: Bewegungen %s" % ", ".join(alle))
	fg._idle()
	var ruhe: String = anim.current_animation if anim.current_animation != "" else "Stehen"
	var hiebe: Array = ["SS_SwordAttack1", "SS_SwordAttack2", "SS_SwordAttack3"].filter(func(n): return fg._ss() and anim.has_animation(n))
	if hiebe.is_empty():
		hiebe = alle.filter(func(n): return (String(n).contains("Attack") or String(n).begins_with("Hieb") or String(n).begins_with("Stich")) and not String(n).begins_with("SS_")).slice(0, 3)
	var abwehr: Array = ["SS_BlockMedium1", "SS_BlockHeavy1"].filter(func(n): return fg._ss() and anim.has_animation(n))
	print("Film 861: Ruhe %s, Hiebe %s, Abwehr %s" % [ruhe, ", ".join(hiebe), ", ".join(abwehr)])

	_messen(ruhe, hiebe, abwehr)
	if OS.get_environment("MESSEN") == "nur":
		print("Film 861: fertig (nur Messung)")
		quit(0)
		return

	var mitte: Vector3 = kf._ground(0, 0)
	var cam: Camera3D = kf.cam
	var vorn: Vector3 = cam.global_position - mitte
	vorn.y = 0.0
	vorn = vorn.normalized()
	fg.position = mitte
	hinten = atan2(vorn.x, vorn.z) + PI     # Rücken zur Kamera
	fg.rotation = Vector3(0, hinten, 0)
	var vs: Vector2 = root.get_visible_rect().size
	_spiel(ruhe, 0.0)
	await process_frame
	var fuss := cam.unproject_position(mitte)
	var kopf := cam.unproject_position(mitte + Vector3(0, 1.85 * fg.scale.y, 0))
	var z := clampf(vs.y * 0.40 / maxf(fuss.y - kopf.y, 1.0), 1.0, 6.0)
	var c := Vector2(fuss.x, (fuss.y + kopf.y) * 0.5 + (fuss.y - kopf.y) * 0.05)
	var per: float = kf.base_size / vs.y
	cam.size = kf.base_size / z
	cam.frustum_offset = Vector2(kf.base_off.x + (c.x - vs.x / 2.0) * per, kf.base_off.y - (c.y - vs.y / 2.0) * per)
	kf.base_size = cam.size
	kf.base_off = cam.frustum_offset
	if not Signatur.wache(kf, self, "Film 861"):
		return
	var cl := CanvasLayer.new()
	root.add_child(cl)
	lb = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.03), int(vs.x / 17.0), Color(0.95, 0.82, 0.45))
	lz = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.085), int(vs.x / 30.0), Color(0.92, 0.88, 0.80))
	lb.text = "Umhang · " + String(NAMEN.get(klasse, klasse))
	print("Film Start Bild %d" % Engine.get_frames_drawn())
	# Teil 1: Kampfhaltung, von hinten, langsam zur einen Seite, zurück und zur anderen
	_spiel(ruhe, 0.2)
	await _warte(1.5, 0.0, "Kampfhaltung")
	await _warte(3.0, PI * 0.5, "Kampfhaltung")
	await _warte(1.5, 0.0, "Kampfhaltung")
	await _warte(6.0, -PI, "Kampfhaltung")
	await _warte(1.5, 0.0, "Kampfhaltung")
	await _warte(3.0, PI * 0.25, "Kampfhaltung")
	# Teil 2: schräg von hinten (diese Seite jetzt), die Kampfbewegungen
	for n in hiebe + abwehr:
		anim.play(n, 0.15, 1.0, false)
		anim.seek(0.0, true)
		print("Stück %s %.2f s" % [n, anim.get_animation(n).length])
		await _warte(anim.get_animation(n).length, 0.0, n)
		_spiel(ruhe, 0.25)
		await _warte(0.5, 0.0, "Kampfhaltung")
	lb.text = ""
	lz.text = ""
	await _warte(0.3, 0.0, "")
	print("Film 861: fertig")
	quit(0)


# ---------------------------------------------------------------- Messung

func _messen(ruhe: String, hiebe: Array, abwehr: Array) -> void:
	var model: Node3D = fg.model
	K = HeldFigur.im_raum(model, sk)
	for mi in model.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null or m.skin == null:
			continue
		var binds := []
		for i in m.skin.get_bind_count():
			var b := m.skin.get_bind_bone(i)
			if b < 0:
				b = sk.find_bone(m.skin.get_bind_name(i))
			binds.append([b, m.skin.get_bind_pose(i)])
		var ni := netze.size()
		netze.append({"binds": binds, "name": String(m.name)})
		for s in m.mesh.get_surface_count():
			var a: Array = m.mesh.surface_get_arrays(s)
			var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var bo = a[Mesh.ARRAY_BONES]
			var we = a[Mesh.ARRAY_WEIGHTS]
			var uv2 = a[Mesh.ARRAY_TEX_UV2]
			if bo == null or we == null or v.is_empty():
				continue
			var je: int = int(bo.size() / v.size())
			for i in v.size():
				var bb := PackedInt32Array()
				var ww := PackedFloat32Array()
				for k in je:
					if we[i * je + k] > 1e-4:
						bb.append(bo[i * je + k])
						ww.append(we[i * je + k])
				if uv2 != null and (uv2 as PackedVector2Array).size() == v.size() and uv2[i].x > 0.5:
					umhang.append(ecken.size())
				ecken.append([ni, v[i], bb, ww])
	print("Umhang 861: %d Netze mit Haut, %d Ecken, davon Umhang %d" % [netze.size(), ecken.size(), umhang.size()])
	if umhang.is_empty() or not anim.has_animation("Stehen"):
		print("FEHLER Umhang 861: kein Umhang (UV2.x) oder keine Bewegung Stehen")
		return
	# Bezug: Stehen (Bild 0), wie der Held unterwegs aussieht
	_pose("Stehen", 0.0)
	var pel := sk.find_bone("pelvis")
	var Rpel := sk.get_bone_global_pose(pel)
	ref_g = _lagen(Rpel, pel)
	ref_pos = PackedVector3Array()
	ref_pos.resize(ecken.size())
	var ist_umhang := {}
	for i in umhang:
		ist_umhang[i] = true
	var raster := {}
	var tief := INF
	for i in ecken.size():
		ref_pos[i] = _haut(i, ref_g)
		tief = minf(tief, ref_pos[i].y)
		if not ist_umhang.has(i):
			var key := Vector3i(floori(ref_pos[i].x / ZELLE), floori(ref_pos[i].y / ZELLE), floori(ref_pos[i].z / ZELLE))
			if not raster.has(key):
				raster[key] = PackedInt32Array()
			raster[key].append(i)
	# Seiten: Mitte des Umhangs gegen das Becken (hinten), linker Oberarm (links)
	var bp: Vector3 = K * Rpel.origin
	var mz := 0.0
	for i in umhang:
		mz += ref_pos[i].z - bp.z
	hinten_z = signf(mz) if mz != 0.0 else -1.0
	var ul := sk.find_bone("upperarm_l")
	if ul >= 0:
		links = signf((K * sk.get_bone_global_pose(ul).origin).x - bp.x)
	print("Umhang 861: hinten ist z %+d, links ist x %+d (Becken %.2f m über den Füßen)" % [int(hinten_z), int(links), bp.y - tief])
	# zu jeder Umhangecke die nächste Ecke darunter (nicht Umhang) binnen NAH
	partner.resize(umhang.size())
	var r := int(ceil(NAH / ZELLE))
	var mit := 0
	for j in umhang.size():
		var q: Vector3 = ref_pos[umhang[j]]
		var c := Vector3i(floori(q.x / ZELLE), floori(q.y / ZELLE), floori(q.z / ZELLE))
		var best := -1
		var bd := NAH * NAH
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				for dz in range(-r, r + 1):
					var key := c + Vector3i(dx, dy, dz)
					if not raster.has(key):
						continue
					for k in raster[key]:
						var d := q.distance_squared_to(ref_pos[k])
						if d < bd:
							bd = d
							best = k
		partner[j] = best
		if best >= 0:
			mit += 1
	print("Umhang 861: %d von %d Umhangecken mit einer Ecke darunter (binnen %d cm)" % [mit, umhang.size(), int(NAH * 100)])
	_gewichte_gesamt()
	var liste: Array = [ruhe] + hiebe + abwehr
	for n in ["Kampfstehen", "SS_IdleCombat", "Gehen", "SS_WalkForward", "Rennen"]:
		if anim.has_animation(n) and n not in liste:
			liste.append(n)
	for n in liste:
		_bewegung(String(n), pel, Rpel, tief)
	anim.stop()


func _pose(n: String, t: float) -> void:
	anim.play(n, 0.0, 1.0, false)
	anim.seek(t, true)
	sk.force_update_all_bone_transforms()


## Knochenlagen mit dem Becken an seiner Stelle in Stehen
func _lagen(Rpel: Transform3D, pel: int) -> Array:
	var aus := Rpel * sk.get_bone_global_pose(pel).affine_inverse()
	var g := []
	for b in sk.get_bone_count():
		g.append(aus * sk.get_bone_global_pose(b))
	return g


func _haut(i: int, g: Array) -> Vector3:
	var e: Array = ecken[i]
	var binds: Array = netze[e[0]]["binds"]
	var p := Vector3.ZERO
	var bb: PackedInt32Array = e[2]
	var ww: PackedFloat32Array = e[3]
	var s := 0.0
	for k in bb.size():
		var bi: Array = binds[bb[k]]
		if bi[0] < 0:
			continue
		p += ww[k] * ((g[bi[0]] as Transform3D) * (bi[1] as Transform3D) * (e[1] as Vector3))
		s += ww[k]
	return K * (p / maxf(s, 1e-6))


## je Knochen der Beitrag einer Ecke zwischen Bezug und Bewegung
func _beitrag(i: int, g: Array, vz: float, aus: Dictionary, u: Vector3) -> void:
	var e: Array = ecken[i]
	var binds: Array = netze[e[0]]["binds"]
	var bb: PackedInt32Array = e[2]
	var ww: PackedFloat32Array = e[3]
	for k in bb.size():
		var bi: Array = binds[bb[k]]
		if bi[0] < 0:
			continue
		var v: Vector3 = e[1]
		var d: Vector3 = K.basis * (ww[k] * ((g[bi[0]] as Transform3D) * (bi[1] as Transform3D) * v - (ref_g[bi[0]] as Transform3D) * (bi[1] as Transform3D) * v))
		var nm := sk.get_bone_name(bi[0])
		aus[nm] = float(aus.get(nm, 0.0)) + vz * d.dot(u)


func _gewichte(i: int) -> String:
	var e: Array = ecken[i]
	var binds: Array = netze[e[0]]["binds"]
	var t := []
	var bb: PackedInt32Array = e[2]
	var ww: PackedFloat32Array = e[3]
	for k in bb.size():
		var bi: Array = binds[bb[k]]
		t.append([ww[k], sk.get_bone_name(bi[0]) if bi[0] >= 0 else "?"])
	t.sort_custom(func(a, b): return a[0] > b[0])
	return ", ".join(t.map(func(x): return "%s %d %%" % [x[1], roundi(x[0] * 100)]))


func _gewichte_gesamt() -> void:
	var s := {}
	for i in umhang:
		var e: Array = ecken[i]
		var binds: Array = netze[e[0]]["binds"]
		var bb: PackedInt32Array = e[2]
		var ww: PackedFloat32Array = e[3]
		for k in bb.size():
			var bi: Array = binds[bb[k]]
			var nm := sk.get_bone_name(bi[0]) if bi[0] >= 0 else "?"
			s[nm] = float(s.get(nm, 0.0)) + ww[k]
	var t := []
	for nm in s:
		t.append([s[nm] / umhang.size(), nm])
	t.sort_custom(func(a, b): return a[0] > b[0])
	print("Umhang 861: Gewichte des Umhangs im Mittel: %s" % ", ".join(t.slice(0, 12).map(func(x): return "%s %.1f %%" % [x[1], x[0] * 100])))


func _seite(q: Vector3, bp: Vector3) -> String:
	var x := (q.x - bp.x) * links         # + links
	var z := (q.z - bp.z) * hinten_z      # + hinten
	var w := rad_to_deg(atan2(x, z))      # 0 hinten, +90 links, -90 rechts
	var s := "hinten"
	if w > 30.0:
		s = "hinten links" if w < 60.0 else "links"
	elif w < -30.0:
		s = "hinten rechts" if w > -60.0 else "rechts"
	return "%s (%+d°)" % [s, roundi(w)]


func _bewegung(n: String, pel: int, Rpel: Transform3D, tief: float) -> void:
	var lang := anim.get_animation(n).length
	var schritte := 6 if anim.get_animation(n).loop_mode != Animation.LOOP_NONE else 10
	var bp: Vector3 = K * Rpel.origin
	var best := {"d": -INF}
	var ueber3 := 0
	var ueber6 := 0
	var baender := {}     # Höhe (10 cm) und Seite -> größter Zuwachs
	for st in schritte + 1:
		var t := lang * st / float(schritte)
		_pose(n, minf(t, lang - 0.001))
		var g := _lagen(Rpel, pel)
		var n3 := 0
		var n6 := 0
		for j in umhang.size():
			var pj := partner[j]
			if pj < 0:
				continue
			var ic := umhang[j]
			var pc := _haut(ic, g)
			var pp := _haut(pj, g)
			var d := pc.distance_to(pp) - (ref_pos[ic] as Vector3).distance_to(ref_pos[pj])
			if d > 0.03: n3 += 1
			if d > 0.06: n6 += 1
			var hb := "%.1f m %s" % [snappedf(ref_pos[ic].y - tief, 0.1), _seite(ref_pos[ic], bp).get_slice(" (", 0)]
			baender[hb] = maxf(float(baender.get(hb, -INF)), d)
			if d > best["d"]:
				best = {"d": d, "t": t, "ic": ic, "pj": pj, "g": g, "u": (pc - pp).normalized()}
		ueber3 = maxi(ueber3, n3)
		ueber6 = maxi(ueber6, n6)
	if best["d"] == -INF:
		print("Umhang 861 %s: nichts messbar" % n)
		return
	var ic: int = best["ic"]
	var pj: int = best["pj"]
	print("Umhang 861 %s: größter Abstand vom Körper %+.1f cm bei %.2f s, Höhe %.2f m, %s; Ecken über 3 cm %d, über 6 cm %d" % [n,
		best["d"] * 100.0, best["t"], ref_pos[ic].y - tief, _seite(ref_pos[ic], bp), ueber3, ueber6])
	print("    Umhangecke: %s" % _gewichte(ic))
	print("    darunter (%s, %.1f cm in Stehen): %s" % [netze[ecken[pj][0]]["name"], (ref_pos[ic] as Vector3).distance_to(ref_pos[pj]) * 100.0, _gewichte(pj)])
	var aus := {}
	_beitrag(ic, best["g"], 1.0, aus, best["u"])
	_beitrag(pj, best["g"], -1.0, aus, best["u"])
	var t := []
	for nm in aus:
		t.append([aus[nm], nm])
	t.sort_custom(func(a, b): return absf(a[0]) > absf(b[0]))
	print("    Beitrag je Knochen (cm, + hebt ab): %s" % ", ".join(t.slice(0, 6).map(func(x): return "%s %+.1f" % [x[1], x[0] * 100.0])))
	var hb := []
	for k in baender:
		if baender[k] > 0.02:
			hb.append([baender[k], k])
	hb.sort_custom(func(a, b): return a[0] > b[0])
	print("    Stellen über 2 cm: %s" % ("keine" if hb.is_empty() else ", ".join(hb.slice(0, 8).map(func(x): return "%s %+.1f" % [x[1], x[0] * 100.0]))))


# ---------------------------------------------------------------- Film

func _spiel(n: String, blend: float) -> void:
	if anim.has_animation(n):
		anim.play(n, blend)


func _warte(s: float, dreh: float, was: String) -> void:
	var t := 0.0
	var schritt := dreh / maxf(s * 30.0, 1.0)
	while t < s:
		await process_frame
		fg.rotation.y += schritt
		if was != "":
			lz.text = "%s · %s" % [_blick(), was]
		_schatten()
		t += 1.0 / 30.0     # Bilder bei --fixed-fps 30


## woher die Kamera auf den Helden sieht, aus seiner Drehung (nicht geschätzt)
func _blick() -> String:
	var cam: Camera3D = root.get_camera_3d()
	if cam == null:
		return ""
	var zu := cam.global_position - fg.global_position
	zu.y = 0.0
	zu = zu.normalized()
	var b := fg.global_transform.basis * HeldFigur.im_raum(fg, fg.model).basis     # Raum des Modells (dort sind hinten_z, links gemessen)
	var vor := b * Vector3(0, 0, -hinten_z)
	vor.y = 0.0
	vor = vor.normalized()
	var li := b * Vector3(links, 0, 0)
	li.y = 0.0
	li = li.normalized()
	var w := rad_to_deg(atan2(zu.dot(li), -zu.dot(vor)))     # 0 von hinten, +90 von links
	if absf(w) < 20.0:
		return "von hinten"
	if absf(w) > 160.0:
		return "von vorn"
	var s := "links" if w > 0.0 else "rechts"
	return ("von hinten " + s) if absf(w) < 70.0 else ("von " + s if absf(w) < 110.0 else "von vorn " + s)


var _sh0 = null

func _schatten() -> void:
	var sh := fg.get_node_or_null("Bodenschatten") as Node3D
	if sh == null:
		return
	if _sh0 == null:
		_sh0 = sh.position
	var b := sk.find_bone("pelvis")
	var p: Vector3 = fg.global_transform.affine_inverse() * (sk.global_transform * sk.get_bone_global_pose(b).origin)
	sh.position = Vector3(_sh0.x + p.x / fg.scale.x, _sh0.y, _sh0.z + p.z / fg.scale.z)


func _label(cl: CanvasLayer, pos: Vector2, fs: int, farbe: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", maxi(4, fs / 6))
	l.add_theme_font_size_override("font_size", fs)
	cl.add_child(l)
	return l


func _find(n: Node, cls: String) -> Node:
	if n.is_class(cls):
		return n
	for c in n.get_children():
		var r := _find(c, cls)
		if r:
			return r
	return null
