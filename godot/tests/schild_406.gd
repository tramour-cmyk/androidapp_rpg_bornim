# 406 (Chef 31.10., 23:22): Kaufschild 2 (Drachenschild, „shield“) beim Kleriker, 15 (rund, „round_shield“) beim Kämpfer.
# Ohne Bild: je Klasse trägt der Held den gewählten Schild unterwegs auf dem Rücken (HeldFigur.bewaffne) und im Kampfort am linken
# Unterarm (figur.gd _arm_kauf); gemessen wird, wie tief der Schild in den eigenen Körper ragt (Kapseln um die Knochen wie
# figur.gd kapseln, ohne den linken Arm, der ihn hält): unterwegs in Stehen, Gehen, Rennen, im Kampf jedes Bild auf Autopilot.
# Run: godot --headless --path godot -s res://tests/schild_406.gd   (Ende 0 = alles richtig; ohne Kaufdateien „ohne Kauf“, 0)
# Film (nur Probelauf nach 389): PROBE=406 FILM=1 xvfb-run godot --path godot --resolution 1080x2340 --write-movie <datei>.avi
# --fixed-fps 30 -s res://tests/schild_406.gd   ->  je Klasse 8 s Drehung mit Schild auf dem Rücken, dann der Kampf (DAUER_MS)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Figur = preload("res://kampf/figur.gd")
const SOLL := {"FIGHTER": "round_shield", "CLERIC": "shield"}
const DREIECKE := {"round_shield": 428, "shield": 864}     # kaufschild.py: PolyMech 15, Omie 2
# Grenzen knapp über dem Stand 01.11., damit nichts schlechter wird. Vorher mit den Schilden aus waffen.py: Rücken 4,1 bis 7,2 cm
# (Schulter, Oberarm an der Oberkante; Lage aus 376.1), Kampf bis 5,8 cm (Kleriker, Ausweichen)
const NETZ_M := 0.005        # Kampf: Messbilder über 5 mm werden gezählt
const RUECKEN_M := 0.10      # neu 01.11.: Kämpfer 2,5 bis 7,4, Kleriker 2,7 bis 9,1 cm
const KAMPF_M := 0.06        # neu 01.11.: Kämpfer nie, Kleriker bis 5,0 cm in 4 von 1600 Messbildern (alt 5,8 cm in 9)
const TIEF_M := 0.02     # erlaubt: Schild höchstens 2 cm in einer Kapsel (Kapseln sind grob, Kleidung liegt darüber)
const OHNE := [8, 10]    # MENSCH_KAPSELN: linker Ober- und Unterarm halten den Schild
const DAUER_MS := 16000

var fails := 0
var film := OS.get_environment("FILM") != ""


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok     " if ok else "FEHLER ") + what)
	if not ok:
		fails += 1


func _kapseln(sk: Skeleton3D) -> Array:
	var out := []
	var g := sk.global_transform
	for i in Figur.MENSCH_KAPSELN.size():
		var c: Array = Figur.MENSCH_KAPSELN[i]
		var i0 := sk.find_bone(c[0])
		var i1 := sk.find_bone(c[1])
		if i0 < 0 or i1 < 0 or i in OHNE:
			continue
		var a: Vector3 = g * sk.get_bone_global_pose(i0).origin
		var b: Vector3 = g * sk.get_bone_global_pose(i1).origin
		if c[0] == "Head":
			a += g.basis.y.normalized() * 0.1
			b = a
		out.append([a, b, float(c[2]), i])
	return out


## Ecken des Schilds in der Welt (alle Netze unter [n])
func _ecken(n: Node) -> PackedVector3Array:
	var out := PackedVector3Array()
	for mi in n.find_children("*", "MeshInstance3D", true, false) + ([n] if n is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		var t := (mi as MeshInstance3D).global_transform
		for s in me.get_surface_count():
			for v in me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				out.append(t * v)
	return out


func _dreiecke(n: Node) -> int:
	var d := 0
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh
		for s in me.get_surface_count():
			var idx = me.surface_get_arrays(s)[Mesh.ARRAY_INDEX]
			d += (idx.size() if idx != null else me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX].size()) / 3
	return d


## [tiefste m, Kapsel]: wie tief eine Ecke des Schilds in einer Kapsel liegt
func _tiefe(ecken: PackedVector3Array, kap: Array) -> Array:
	var best := [-INF, -1, Vector3.ZERO]
	for p in ecken:
		for c in kap:
			var q: Vector3 = Geometry3D.get_closest_point_to_segment(p, c[0], c[1])
			var t: float = float(c[2]) - p.distance_to(q)
			if t > best[0]:
				best = [t, c[3], p]
	return best


## 406 Netzmessung (die Kapseln sind am Rücken zu grob: der alte Schild lag mit der Fessel 9 cm „in“ Kapsel 0): Ecken der
## Kleidung und Haut, auf dem Rechner gehäutet wie im Zeichner (Knochen × Bindung × Ecke); ohne die Ecken, die am linken Arm hängen
var _haut := []     # [MeshInstance3D, Skin, Ecken, Knochen, Gewichte, je Ecke frei (nicht linker Arm)]

func _haut_lesen(sk: Skeleton3D) -> void:
	_haut.clear()
	var arm := []
	for i in sk.get_bone_count():
		var nm := sk.get_bone_name(i)
		var p := i
		while p >= 0:
			if sk.get_bone_name(p) in ["upperarm_l", "lowerarm_l", "hand_l"]:
				arm.append(i)
				break
			p = sk.get_bone_parent(p)
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.skin == null or m.get_parent() is BoneAttachment3D:
			continue
		for s in m.mesh.get_surface_count():
			var ar := m.mesh.surface_get_arrays(s)
			if ar[Mesh.ARRAY_BONES] == null:
				continue
			var nb: int = ar[Mesh.ARRAY_BONES].size() / ar[Mesh.ARRAY_VERTEX].size()
			var frei := PackedByteArray()
			frei.resize(ar[Mesh.ARRAY_VERTEX].size())
			for v in ar[Mesh.ARRAY_VERTEX].size():
				var w_arm := 0.0
				for j in nb:
					var bb: int = m.skin.get_bind_bone(ar[Mesh.ARRAY_BONES][v * nb + j])
					if bb < 0:
						bb = sk.find_bone(m.skin.get_bind_name(ar[Mesh.ARRAY_BONES][v * nb + j]))
					if bb in arm:
						w_arm += ar[Mesh.ARRAY_WEIGHTS][v * nb + j]
				frei[v] = 1 if w_arm < 0.3 else 0
			_haut.append([m, m.skin, ar[Mesh.ARRAY_VERTEX], ar[Mesh.ARRAY_BONES], ar[Mesh.ARRAY_WEIGHTS], nb, frei])


func _haut_ecken(sk: Skeleton3D) -> PackedVector3Array:
	var out := PackedVector3Array()
	var g := sk.global_transform
	for h in _haut:
		var skin: Skin = h[1]
		var tr := []
		for i in skin.get_bind_count():
			var bb := skin.get_bind_bone(i)
			if bb < 0:
				bb = sk.find_bone(skin.get_bind_name(i))
			tr.append(g * sk.get_bone_global_pose(bb) * skin.get_bind_pose(i))
		var vs: PackedVector3Array = h[2]
		var nb: int = h[5]
		for v in vs.size():
			if h[6][v] == 0:
				continue
			var p := Vector3.ZERO
			for j in nb:
				var w: float = h[4][v * nb + j]
				if w > 0.0:
					p += (tr[h[3][v * nb + j]] as Transform3D) * vs[v] * w
			out.append(p)
	return out


## [tiefste m, Stelle im Schild cm]: wie weit Körper oder Kleidung durch die Schildfläche ragen; im Raum des Schilds (glTF:
## Fläche x/y, vorn +z) je Feld von 2 cm die hinterste Ecke des Schilds; eine Körperecke im selben Feld, die vor ihr liegt (größeres
## z), aber nicht mehr als 5 cm vor der vordersten (davor kreuzt etwas vor dem Schild vorbei), steckt im Schild
func _netz_tiefe(schild: Node3D, koerper: PackedVector3Array) -> Array:
	var inv := schild.global_transform.affine_inverse()
	var feld := {}
	for p in _ecken(schild):
		var q := inv * p
		var k := Vector2i(floori(q.x / 0.02), floori(q.y / 0.02))
		var e: Vector2 = feld.get(k, Vector2(INF, -INF))
		feld[k] = Vector2(minf(e.x, q.z), maxf(e.y, q.z))
	var best := [-INF, Vector3.ZERO]
	for p in koerper:
		var q := inv * p
		var k := Vector2i(floori(q.x / 0.02), floori(q.y / 0.02))
		if not feld.has(k):
			continue
		var e: Vector2 = feld[k]
		if q.z > e.y + 0.05:
			continue
		var t: float = q.z - e.x
		if t > best[0]:
			best = [t, q * 100.0]
	return best


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin") or not HeldFigur.da("FIGHTER"):
		print("Schild 406: ohne Kauf, nichts zu prüfen")
		quit(0)
		return
	var klassen := OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(["FIGHTER", "CLERIC"])
	# --- unterwegs: Schild auf dem Rücken
	var buehne := Node3D.new()
	root.add_child(buehne)
	if film:
		_licht(buehne)
	var figuren := []
	for i in klassen.size():
		var k := klassen[i]
		var hw := Heldwerte.erschaffe("Test", "HUMAN", k)
		var off = hw.ausruestung.get("OFF_HAND")
		_check(off is Dictionary and String(off["base"]) == SOLL[k], "%s: Startausrüstung %s (%s)" % [k, SOLL[k], off["base"] if off is Dictionary else "kein Schild"])
		var m := HeldFigur.baue({"klasse": k, "volk": "HUMAN", "aussehen": {}, "ausruestung": hw.ausruestung}, [])
		buehne.add_child(m)
		m.position = Vector3((i - (klassen.size() - 1) / 2.0) * 1.1, 0, 0)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var rs := sk.find_child("RueckenSchild", false, false)
		_check(rs != null, "%s: Schild auf dem Rücken" % k)
		if rs == null:
			continue
		var d := _dreiecke(rs)
		_check(d == DREIECKE[SOLL[k]], "%s: Kaufschild %s (%d Dreiecke, soll %d)" % [k, SOLL[k], d, DREIECKE[SOLL[k]]])
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		_haut_lesen(sk)
		var rsm := rs.get_child(0) as Node3D
		for b in ["Stehen", "Gehen", "Rennen"]:
			if not ap.has_animation(b):
				continue
			ap.play(b)
			var nt := [-INF, Vector3.ZERO]
			var nbei := 0.0
			for j in 24:
				var zt: float = ap.get_animation(b).length * j / 24.0
				ap.seek(zt, true)
				sk.force_update_all_bone_transforms()
				var t := _netz_tiefe(rsm, _haut_ecken(sk))
				if t[0] > nt[0]:
					nt = t
					nbei = zt
			_check(nt[0] <= RUECKEN_M, "%s Rücken %s: Körper höchstens %.3f m im Schild (Netz, bei %.2f s, Stelle %s cm)" % [k, b, nt[0], nbei, nt[1]])
		for b in ([] if OS.get_environment("KAPSELN") == "" else ["Stehen", "Gehen", "Rennen"]):
			if not ap.has_animation(b):
				continue
			ap.play(b)
			var tief := [-INF, -1, Vector3.ZERO]
			var bei := 0.0
			var lang := ap.get_animation(b).length
			for j in 24:
				ap.seek(lang * j / 24.0, true)
				sk.force_update_all_bone_transforms()
				var t := _tiefe(_ecken(rs), _kapseln(sk))
				if t[0] > tief[0]:
					tief = t
					bei = lang * j / 24.0
			var lok: Vector3 = (rs.get_child(0) as Node3D).global_transform.affine_inverse() * (tief[2] as Vector3) if rs.get_child_count() > 0 else Vector3.ZERO
			_check(tief[0] <= TIEF_M, "%s Rücken %s: Schild höchstens %.3f m im Körper (Kapsel %d bei %.2f s; Stelle im Schild %s cm)" % [k, b, tief[0], tief[1], bei, lok * 100.0])
		ap.play("Stehen")
		figuren.append(m)
	if film:
		var cam := Camera3D.new()
		buehne.add_child(cam)
		cam.fov = 30.0
		cam.position = Vector3(0, 1.3, 6.2)
		cam.look_at(Vector3(0, 1.0, 0))
		cam.current = true
		for n in 8 * 30:     # 8 s, jeder dreht sich einmal ganz
			for m in figuren:
				m.rotation.y = TAU * n / 240.0
			await process_frame
	buehne.queue_free()
	await process_frame
	# --- Kampfort: Schild am linken Unterarm, jedes Bild gemessen
	for k in klassen:
		var p = Probe.new()
		p.hero_cls = k
		p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
		p.foe = "WOLVES"
		root.add_child(p)
		await process_frame
		p._start(int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7)
		for i in 6:
			await process_frame
		var kf = p.fight
		var fig = kf.figures.get("hero")
		var schild: Node = fig.model.find_child("Schild", true, false) if fig else null
		_check(schild != null, "%s: Schild in der Hand im Kampf" % k)
		if schild == null:
			continue
		var d := _dreiecke(schild)
		_check(d == DREIECKE[SOLL[k]], "%s Kampf: Kaufschild %s (%d Dreiecke)" % [k, SOLL[k], d])
		var sk := fig._find(fig.model, "Skeleton3D") as Skeleton3D
		_haut_lesen(sk)
		var sm: Node3D = schild.find_children("*", "MeshInstance3D", true, false)[0] if not schild is MeshInstance3D else schild
		kf.mars.find("merc").auto = true
		kf.mars.set_autopilot(true)
		if not kf.busy:
			kf.go_on()
		var tief := {}     # Bewegung -> [tiefste m, Kapsel, Bilder über TIEF_M]
		var n := 0
		var dauer := int(OS.get_environment("DAUER_MS")) if OS.get_environment("DAUER_MS") != "" else DAUER_MS
		while n < (dauer * 30 / 1000 if film else 6000):
			await process_frame
			n += 1
			if fig.visible and not fig.down:
				var b := String(fig.anim.current_animation)
				var e: Array = tief.get(b, [-INF, Vector3.ZERO, 0])
				if n % 3 == 0:
					var t := _netz_tiefe(sm, _haut_ecken(sk))
					if t[0] > e[0]:
						e[0] = t[0]
						e[1] = t[1]
					if t[0] > NETZ_M:
						e[2] += 1
				tief[b] = e
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
					kf.go_on()
				else:
					var c = kf.mars.current()
					var ts: Array = kf.mars.targets(c)
					kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		for b in tief:
			_check(tief[b][0] <= KAMPF_M, "%s Kampf %s: Körper höchstens %.3f m im Schild (Netz, Stelle %s cm, %d Messbilder über %.3f)" % [k, b if b != "" else "–", tief[b][0], tief[b][1], tief[b][2], NETZ_M])
		print("Kampf %s: %s nach %d Bildern" % [k, kf.mars.outcome, n])
		kf.queue_free()
		p.queue_free()
		await process_frame
	print("SCHILD 406 %s" % ("gut" if fails == 0 else "FALSCH %d" % fails))
	quit(1 if fails > 0 else 0)


func _licht(n: Node3D) -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.05, 0.05, 0.05)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.55, 0.52, 0.48)
	env.environment.ambient_light_energy = 0.6
	n.add_child(env)
	var sonne := DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-50, 35, 0)
	sonne.light_energy = 1.2
	n.add_child(sonne)
