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
const SOLL := {"Wachsoldat": "round_shield", "FIGHTER": "round_shield", "CLERIC": "shield"}
# 870.4: unterwegs nur Herkünfte mit Schild (werte.json „herkuenfte“ schild: nur der Wachsoldat); im Kampfort die Probeblätter
# (tabellen.json „probe“ nennen noch die Klasse), damit Drachenschild mit Sonne weiter geprüft wird
const PROBE := {"Wachsoldat": "FIGHTER", "Klosterschüler": "CLERIC"}
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


## sonne = false: Dreiecke des Schilds ohne die aufgelegte Sonne (kaufschild.py, Material „sonne“), true: nur die Sonne
func _dreiecke(n: Node, sonne := false) -> int:
	var d := 0
	for mi in n.find_children("*", "MeshInstance3D", true, false) + ([n] if n is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		for s in me.get_surface_count():
			var mat := me.surface_get_material(s)
			if (mat != null and mat.resource_name.begins_with("sonne")) != sonne:
				continue
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
	return _ecken_aus(sk, _haut)


## 406 b (Chef 01.11., 20:2x: „bei beiden Schultern … Draufsicht, links am Schild … eine leichte Irritation“): die Netzmessung lässt den
## ganzen linken Arm aus, auch Schulter und Oberarm, die den Schild nicht halten; hier nur sie (Gewicht auf clavicle_l, upperarm_l)
var _schulter := []

func _schulter_lesen(sk: Skeleton3D, knochen := []) -> void:
	_schulter = []
	var nur: Array = knochen if not knochen.is_empty() else [sk.find_bone("clavicle_l"), sk.find_bone("upperarm_l")]
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
				var w := 0.0
				for j in nb:
					var bb: int = m.skin.get_bind_bone(ar[Mesh.ARRAY_BONES][v * nb + j])
					if bb < 0:
						bb = sk.find_bone(m.skin.get_bind_name(ar[Mesh.ARRAY_BONES][v * nb + j]))
					if bb in nur:
						w += ar[Mesh.ARRAY_WEIGHTS][v * nb + j]
				frei[v] = 1 if w >= 0.5 else 0
			_schulter.append([m, m.skin, ar[Mesh.ARRAY_VERTEX], ar[Mesh.ARRAY_BONES], ar[Mesh.ARRAY_WEIGHTS], nb, frei])


## 406a E3 (Tor 461a, Lauf 170: die Faust der Schildhand liegt außen auf dem Schild, 2, 5, 22, 35 s, Kämpfer 82–87 s; gemessen nur
## vor der Neigung): Haut der Finger der linken Hand (mindestens halbes Gewicht auf einem Fingerglied), wie _schulter
var _finger := []
const FINGERNAMEN := ["thumb", "index", "middle", "ring", "pinky"]
var _finger_je := {}
func _finger_lesen(sk: Skeleton3D) -> void:
	var nur := []
	for i in sk.get_bone_count():
		var nm := sk.get_bone_name(i)
		if nm.ends_with("_l") and (nm.begins_with("thumb") or nm.begins_with("index") or nm.begins_with("middle") or nm.begins_with("ring") or nm.begins_with("pinky")):
			nur.append(i)
	var alt := _schulter.duplicate()
	_schulter_lesen(sk, nur)
	_finger = _schulter
	# Lauf 182: Beugen −50° lässt 1,8–4 cm; welcher Finger bleibt davor, je Finger einzeln
	_finger_je = {}
	for f in FINGERNAMEN:
		var je := []
		for i in nur:
			if (sk.get_bone_name(i) as String).begins_with(f):
				je.append(i)
		if je.is_empty():
			_finger_je[f] = []
			continue
		_schulter_lesen(sk, je)
		_finger_je[f] = _schulter
	_schulter = alt


## 406a E3 Weg (Lauf 179: Schild weiter vor schiebt den Schwertarm hinein): Finger der Schildhand zur Faust beugen. Je Beugung aus
## BEUGEN (Grad je Glied um die Achse quer über die Knöchel, Handrahmen wie figur.gd _handrahmen; Vorzeichen unbekannt, darum beide)
## die Finger vor der Vorderseite bei der jetzigen Fassung; die Pose wird danach zurückgesetzt
## Lauf 182: positiv streckt (bis 11 cm), negativ schließt die Faust (−50°: 1,8–4 cm); jetzt weiter schließen
const BEUGEN := [0.0, -50.0, -75.0, -90.0]
## 406a E3 Lauf 190: Faust allein lässt 2–4 cm; figur.gd knickt die Hand um KNICK_GRAD, hier je Winkel mehr (Grad) gemessen
const KNICK_PROBE := [-10.0, 10.0, 20.0]
func _beugen_finger(sk: Skeleton3D, schild: Node3D) -> Array:
	var glieder := []
	for f in ["index", "middle", "ring", "pinky"]:
		for n in ["01", "02", "03"]:
			var b := sk.find_bone("%s_%s_l" % [f, n])
			if b >= 0:
				glieder.append(b)
	var hand := sk.find_bone("hand_l")
	var mf := sk.find_bone("middle_01_l")
	var zf := sk.find_bone("index_01_l")
	var kf := sk.find_bone("pinky_01_l")
	if hand < 0 or mf < 0 or zf < 0 or kf < 0 or glieder.is_empty():
		return []
	var alt := {}
	for b in glieder:
		alt[b] = sk.get_bone_pose_rotation(b)
	var out := []
	for grad in BEUGEN:
		for b in glieder:
			# Achse quer über die Knöchel im Raum des Elternknochens (aus der jetzigen Pose)
			var pg := sk.get_bone_global_pose(sk.get_bone_parent(b))
			var quer := (sk.get_bone_global_pose(zf).origin - sk.get_bone_global_pose(kf).origin).normalized()
			var achse := (pg.basis.inverse() * quer).normalized()
			sk.set_bone_pose_rotation(b, Quaternion(achse, deg_to_rad(grad)) * (alt[b] as Quaternion))
		var r: Array = _varianten_finger(schild, _ecken_aus(sk, _finger))[0]
		var je := {}
		for f in FINGERNAMEN:
			je[f] = _varianten_finger(schild, _ecken_aus(sk, _finger_je[f]))[0][0]
		out.append([r[0], r[1], je])
		for b in glieder:
			sk.set_bone_pose_rotation(b, alt[b])
	return out


## je Fassung aus VARIANTEN_F: wie weit eine Fingerecke vor der Vorderseite des Schilds liegt (m, positiv = sichtbar davor), nur mitten
## im Schild (alle 8 Nachbarfelder da), wie sturz_438a _runde3
const VARIANTEN_F := [[0.0, 0.0, 0.0, 0.0], [0.0, 0.02, 0.0, 0.0], [0.0, 0.04, 0.0, 0.0], [0.0, 0.06, 0.0, 0.0], [0.0, 0.08, 0.0, 0.0]]
func _varianten_finger(schild: Node3D, finger: PackedVector3Array) -> Array:
	var feld := _karte(schild)
	var inv := schild.global_transform.affine_inverse()
	var sc := schild.global_transform.basis.get_scale()
	var out := []
	for v in VARIANTEN_F:
		var dreh := _neigung(v)
		var t := Vector3(0.0, -v[0] / sc.y, v[1] / sc.z)
		var best := [-INF, Vector3.ZERO]
		for p in finger:
			var q: Vector3 = dreh.inverse() * (inv * p - t)
			var k := Vector2i(floori(q.x / RASTER), floori(q.y / RASTER))
			if not feld.has(k):
				continue
			var innen := true
			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if not feld.has(k + Vector2i(dx, dy)):
						innen = false
			if not innen:
				continue
			var e: Vector2 = feld[k]
			if q.z - e.y > best[0]:
				best = [q.z - e.y, q * 100.0]
		out.append(best)
	return out


## 406 Lauf 198: wie weit eine Ecke vor der Vorderseite liegt, in jedem Feld des Schilds, auch am Rand; nur bis RAND_WEIT davor (weiter
## vorn kreuzt etwas vor dem Schild vorbei): [m, Stelle im Schild cm]
const RAND_WEIT := 0.08
const RAND_BEWEGUNGEN := ["SS_IdleCombat", "SS_WalkForward", "SS_RunForward", "SS_WalkBackwards", "SS_BlockLight", "SS_GetHitLightFront"]
func _rand_vorn(schild: Node3D, pts: PackedVector3Array) -> Array:
	var feld := _karte(schild)
	var inv := schild.global_transform.affine_inverse()
	var best := [-INF, Vector3.ZERO]
	for p in pts:
		var q: Vector3 = inv * p
		var k := Vector2i(floori(q.x / RASTER), floori(q.y / RASTER))
		if not feld.has(k):
			continue
		var vorn: float = q.z - (feld[k] as Vector2).y
		if vorn < RAND_WEIT and vorn > best[0]:
			best = [vorn, q * 100.0]
	return best


## 406 Lauf 205 (Prüfer: Finger des Kämpfers beim Gehen und Rennen 5–10 cm über dem oberen Schildrand, RAND sagt −0,2 cm): _rand_vorn
## zählt nur Ecken vor einem Feld des Schilds; was über den Umriss hinausragt, sah es nie. Hier je Ecke außerhalb des Umrisses, wie weit
## sie über den Rand hinausragt (Umriss je 10° um die Mitte der Felder) und wie weit vor (+) oder hinter (−) der Vorderseite des Rands;
## nur bis UEBER_WEIT hinaus: [m über den Rand, m vor dem Rand, Stelle im Schild cm]
const UEBER_WEIT := 0.15
var _umrisse := {}
func _rand_ueber(schild: Node3D, pts: PackedVector3Array) -> Array:
	var feld := _karte(schild)
	var id := schild.get_instance_id()
	if not _umrisse.has(id):
		var m := Vector2.ZERO
		for k in feld:
			m += Vector2(k) * RASTER
		m /= maxf(feld.size(), 1)
		var r := PackedFloat32Array()
		var vorn := PackedFloat32Array()
		r.resize(36)
		vorn.resize(36)
		vorn.fill(-INF)
		for k in feld:
			var d: Vector2 = Vector2(k) * RASTER - m
			var si := posmod(int(floor(rad_to_deg(d.angle()) / 10.0)), 36)
			if d.length() > r[si]:
				r[si] = d.length()
			vorn[si] = maxf(vorn[si], (feld[k] as Vector2).y)
		_umrisse[id] = [m, r, vorn]
	var u: Array = _umrisse[id]
	var inv := schild.global_transform.affine_inverse()
	var best := [-INF, 0.0, Vector3.ZERO]
	for p in pts:
		var q: Vector3 = inv * p
		var k := Vector2i(floori(q.x / RASTER), floori(q.y / RASTER))
		if feld.has(k):
			continue
		var d: Vector2 = Vector2(q.x, q.y) - (u[0] as Vector2)
		var si := posmod(int(floor(rad_to_deg(d.angle()) / 10.0)), 36)
		var ueber: float = d.length() - float(u[1][si])
		if ueber > 0.0 and ueber < UEBER_WEIT and ueber > best[0]:
			best = [ueber, q.z - float(u[2][si]), q * 100.0]
	return best


## Haut des linken Unterarms und der Hand (ohne Finger), wie _schulter
func _arm_lesen(sk: Skeleton3D) -> Array:
	var alt := _schulter.duplicate()
	_schulter_lesen(sk, [sk.find_bone("lowerarm_l"), sk.find_bone("hand_l")])
	var out := _schulter
	_schulter = alt
	return out


func _ecken_aus(sk: Skeleton3D, liste: Array) -> PackedVector3Array:
	var out := PackedVector3Array()
	var g := sk.global_transform
	for h in liste:
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


## 406 b (Lauf 162: Kleriker Schulter und Oberarm bis 7,3 cm im Drachenschild bei Abwehr, Kämpfer bis 2,4 cm): wie tief Körper,
## Schulter und Oberarm stünden, säße der Schild um [tiefer, weiter vorn] m anders an der Fessel (VARIANTEN). Der Schild bewegt sich
## starr, also gleich, als rückten die Körperecken entgegen; ohne neuen Lauf je Fassung.
## Lauf 165: mit den Feldern von 2 cm aus den Ecken sprangen die Werte (Kämpfer 6 cm vor: Körper 7,3 statt -5,8): am gewölbten Rand
## (4,6 cm hinter der Fessel) liegt im Feld die hinterste Randecke, eine Körperecke daneben, außerhalb des Umrisses, zählte als „im
## Schild“. Jetzt die Fläche selbst: jedes Dreieck (ohne die Sonne) auf ein Raster von RASTER m gelegt, je Rasterpunkt hinterste und
## vorderste Fläche genau an dieser Stelle; außerhalb des Umrisses gibt es keinen Rasterpunkt.
## Lauf 167: Kämpfer vorn 3 cm frei (Schulter -0,7 cm); Kleriker bei Abwehr mit der Schulter am oberen Innenrand des Drachenschilds
## bis 7,7 cm durch, Verschieben allein hilft wenig (vorn 6: 4,1). Darum auch geneigt: [tiefer m, vorn m, Oberkante vor Grad (um die
## Querachse), Seite vor Grad (um die Hochachse, + bringt +x nach vorn)], gedreht um die Fessel. Werte gegen SCHILD_LAGE in figur.gd.
const VARIANTEN := [[0.0, 0.0, 0.0, 0.0], [0.0, 0.03, 0.0, 0.0], [0.0, 0.0, 10.0, 0.0], [0.0, 0.0, 20.0, 0.0], [0.0, 0.02, 20.0, 0.0],
		[0.0, 0.0, 0.0, 10.0], [0.0, 0.0, 0.0, 20.0], [0.0, 0.0, 0.0, -10.0], [0.0, 0.0, 0.0, -20.0], [0.0, 0.02, 0.0, 20.0],
		[0.0, 0.02, 0.0, -20.0], [0.0, 0.0, 15.0, 15.0], [0.0, 0.0, 15.0, -15.0], [0.0, 0.02, 15.0, 15.0], [0.0, 0.02, 15.0, -15.0],
		[0.12, 0.02, 0.0, 0.0], [0.16, 0.02, 0.0, 0.0], [0.0, 0.03, 25.0, 0.0]]
const RASTER := 0.01
var _karten := {}

## Rasterpunkt -> Vector2(hinterste z, vorderste z) im Raum von schild (einmal je Schild, die Lage der Netze darin ist starr)
func _karte(schild: Node3D) -> Dictionary:
	var id := schild.get_instance_id()
	if _karten.has(id):
		return _karten[id]
	var feld := {}
	var inv := schild.global_transform.affine_inverse()
	for mi in schild.find_children("*", "MeshInstance3D", true, false) + ([schild] if schild is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		var tr := inv * (mi as MeshInstance3D).global_transform
		for s in me.get_surface_count():
			var mat := me.surface_get_material(s)
			if mat != null and mat.resource_name.begins_with("sonne"):
				continue
			var ar := me.surface_get_arrays(s)
			var vs: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
			var idx = ar[Mesh.ARRAY_INDEX]
			var n: int = idx.size() if idx != null else vs.size()
			for t in range(0, n - 2, 3):
				var pa: Vector3 = tr * vs[idx[t] if idx != null else t]
				var pb: Vector3 = tr * vs[idx[t + 1] if idx != null else t + 1]
				var pc: Vector3 = tr * vs[idx[t + 2] if idx != null else t + 2]
				var den := (pb.y - pc.y) * (pa.x - pc.x) + (pc.x - pb.x) * (pa.y - pc.y)
				if absf(den) < 1e-12:
					continue
				for i in range(floori(minf(pa.x, minf(pb.x, pc.x)) / RASTER), floori(maxf(pa.x, maxf(pb.x, pc.x)) / RASTER) + 1):
					for j in range(floori(minf(pa.y, minf(pb.y, pc.y)) / RASTER), floori(maxf(pa.y, maxf(pb.y, pc.y)) / RASTER) + 1):
						var px := (i + 0.5) * RASTER
						var py := (j + 0.5) * RASTER
						var l1 := ((pb.y - pc.y) * (px - pc.x) + (pc.x - pb.x) * (py - pc.y)) / den
						var l2 := ((pc.y - pa.y) * (px - pc.x) + (pa.x - pc.x) * (py - pc.y)) / den
						var l3 := 1.0 - l1 - l2
						if l1 < -1e-4 or l2 < -1e-4 or l3 < -1e-4:
							continue
						var z := l1 * pa.z + l2 * pb.z + l3 * pc.z
						var k := Vector2i(i, j)
						var e: Vector2 = feld.get(k, Vector2(INF, -INF))
						feld[k] = Vector2(minf(e.x, z), maxf(e.y, z))
	_karten[id] = feld
	return feld


## Drehung einer Fassung im Raum des Schilds: erst Oberkante vor (+y nach +z), dann Seite vor (+x nach +z); wie figur.gd _schild_neigung
static func _neigung(v: Array) -> Basis:
	var kipp := Basis(Vector3.RIGHT, deg_to_rad(v[2]))       # (0,1,0) -> (0, cos, sin): Oberkante vor
	var seite := Basis(Vector3.UP, deg_to_rad(-v[3]))       # (1,0,0) -> (cos, 0, sin): Seite +x vor
	return seite * kipp


## je Fassung [tiefste m, Stelle cm]: Körperecke an einem Rasterpunkt vor der hintersten Fläche, höchstens 5 cm vor der vordersten
func _varianten_tiefe(schild: Node3D, koerper: PackedVector3Array) -> Array:
	var feld := _karte(schild)
	var inv := schild.global_transform.affine_inverse()
	var sc := schild.global_transform.basis.get_scale()
	var nah := PackedVector3Array()
	for p in koerper:
		var q := inv * p
		if absf(q.x) < 0.6 and absf(q.y) < 0.7 and absf(q.z) < 0.3:
			nah.append(q)
	var out := []
	for v in VARIANTEN:
		# neuer Schild = alter um (0, -tiefer, vorn) verschoben und um die Fessel gedreht; die Körperecke im Raum des neuen Schilds
		var dreh := _neigung(v)
		var t := Vector3(0.0, -v[0] / sc.y, v[1] / sc.z)
		var best := [-INF, Vector3.ZERO]
		for q0 in nah:
			var q: Vector3 = dreh.inverse() * (q0 - t)
			var k := Vector2i(floori(q.x / RASTER), floori(q.y / RASTER))
			if not feld.has(k):
				continue
			var e: Vector2 = feld[k]
			if q.z > e.y + 0.05 or q.z - e.x <= best[0]:
				continue
			best = [q.z - e.x, q * 100.0]
		out.append(best)
	return out


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin") or not HeldFigur.da("Wachsoldat"):
		print("Schild 406: ohne Kauf, nichts zu prüfen")
		quit(0)
		return
	var klassen := OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(["Wachsoldat"])
	var kampf_klassen := PackedStringArray(["FIGHTER", "CLERIC"]) if OS.get_environment("KLASSEN") == "" else PackedStringArray(Array(klassen).map(func(x): return PROBE.get(x, x)))
	# --- unterwegs: Schild auf dem Rücken
	var buehne := Node3D.new()
	root.add_child(buehne)
	if film:
		_licht(buehne)
	var figuren := []
	for i in klassen.size():
		var k := klassen[i]
		var hw := BrsHeld.fuer_spiel("Test", "Mensch", k)
		var off = hw.ausruestung.get("OFF_HAND")
		_check(off is Dictionary and String(off["base"]) == SOLL[k], "%s: Startausrüstung %s (%s)" % [k, SOLL[k], off["base"] if off is Dictionary else "kein Schild"])
		var m := HeldFigur.baue({"herkunft": k, "volk": "HUMAN", "aussehen": {}, "ausruestung": hw.ausruestung}, [])
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
	for k in kampf_klassen:
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
		# 1013 (wie 988 in held_kampf_403): die Probehelden sind seit 870.6 Helden nach BRS der Herkunft; Schild nur, wenn die
		# Herkunft einen trägt (werte.json „herkuenfte“: Wachsoldat ja, Klosterschüler nein)
		var hk: String = String(load("res://regeln/brs_kampf.gd").KLASSE_HERKUNFT.get(k, "Wanderer"))
		var soll_schild := bool(Brs.lade()["herkuenfte"].get(hk, {}).get("schild", false))
		_check((schild != null) == soll_schild, "%s: Schild in der Hand im Kampf nur, wenn die Herkunft einen trägt (%s: %s, %s)" % [k, hk, "ja" if soll_schild else "nein", "da" if schild else "keiner"])
		if schild == null:
			continue
		var d := _dreiecke(schild)
		_check(d == DREIECKE[SOLL[k]], "%s Kampf: Kaufschild %s (%d Dreiecke)" % [k, SOLL[k], d])
		# 406, B5 (Chef 01.11., 22:35, Archiv 461c): auf dem Drachenschild des Klerikers die goldene Sonne, auf dem Rundschild keine
		var ds := _dreiecke(schild, true)
		_check((ds > 0) == (SOLL[k] == "shield"), "%s Kampf: Sonne auf dem Schild %s (%d Dreiecke)" % [k, "ja" if SOLL[k] == "shield" else "nein", ds])
		var sk := fig._find(fig.model, "Skeleton3D") as Skeleton3D
		_finger_lesen(sk)
		_schulter_lesen(sk)
		_haut_lesen(sk)
		var var_f := {}     # 406a E3: Bewegung -> je Fassung aus VARIANTEN_F [Finger vor dem Schild m, Stelle]
		var var_b := {}     # 406a E3: Bewegung -> je Beugung aus BEUGEN [Finger vor dem Schild m, Stelle]
		var sm: Node3D = schild.find_children("*", "MeshInstance3D", true, false)[0] if not schild is MeshInstance3D else schild
		# 406a E3 Lauf 188: die Faust (figur.gd SchildFaust) ist ein SkeletonModifier3D; außerhalb von skeleton_updated liest man die
		# Pose ohne sie (wie sturz_438a): die Finger, wie man sie sieht, nur dort messen
		var faust := {"an": false}     # Bewegung -> [Finger vor der Vorderseite m, Stelle, je Finger]
		var knick_f := {}     # 406a E3: Bewegung -> je Winkel aus KNICK_PROBE [Finger vor der Vorderseite m, Stelle]
		var faust_mess := func() -> void:
			if not faust.an:
				return
			faust.an = false
			var bw := String(fig.anim.current_animation)
			var r: Array = _varianten_finger(sm, _ecken_aus(sk, _finger))[0]
			# 406a E3 Knick: wie weit die Finger vor der Vorderseite lägen, knickte die Hand um KNICK_PROBE Grad mehr (Schild bleibt)
			var sf = fig.schild_faust
			if sf != null and sf.hand >= 0 and sf.achse != Vector3.ZERO:
				var hg: Transform3D = sk.global_transform * sk.get_bone_global_pose(sf.hand)
				var ax: Vector3 = (hg.basis * sf.achse).normalized()
				var pts := _ecken_aus(sk, _finger)
				var kn: Array = knick_f.get(bw, [])
				for i in KNICK_PROBE.size():
					var dreh := Basis(ax, deg_to_rad(KNICK_PROBE[i]))
					var neu := PackedVector3Array()
					for q in pts:
						neu.append(hg.origin + dreh * (q - hg.origin))
					var v: Array = _varianten_finger(sm, neu)[0]
					if kn.size() <= i:
						kn.append([-INF, Vector3.ZERO])
					if v[0] > kn[i][0]:
						kn[i] = v
				knick_f[bw] = kn
			var alt: Array = faust.get(bw, [-INF, Vector3.ZERO, {}])
			if r[0] > alt[0]:
				var je := {}
				for f in FINGERNAMEN:
					je[f] = _varianten_finger(sm, _ecken_aus(sk, _finger_je[f]))[0][0]
				faust[bw] = [r[0], r[1], je, fig.anim.current_animation_position]
		# 406 Lauf 198 (Prüfer am Film: Gehen und Rennen, Finger und Unterarm der Schildhand vor dem oberen Schildrand, 2–3 cm): je
		# Bewegung des Satzes Finger und Unterarm vor der Vorderseite, auch am Rand (ohne „mitten im Schild“), wie man sie sieht
		var unterarm := _arm_lesen(sk)
		var rand := {}     # Bewegung -> [[Finger m, Stelle], [Unterarm m, Stelle], Zeit]
		var ueber := {}    # 406 Lauf 205: Bewegung -> [[Finger über den Rand], [Unterarm über den Rand], Zeit]
		var rand_an := {"an": false}
		var rand_mess := func() -> void:
			if not rand_an.an:
				return
			rand_an.an = false
			var bw := String(fig.anim.current_animation)
			var fv: Array = _rand_vorn(sm, _ecken_aus(sk, _finger))
			var uv: Array = _rand_vorn(sm, _ecken_aus(sk, unterarm))
			var alt: Array = rand.get(bw, [[-INF, Vector3.ZERO], [-INF, Vector3.ZERO], 0.0])
			if fv[0] > alt[0][0]:
				alt[0] = fv
				alt[2] = fig.anim.current_animation_position
			if uv[0] > alt[1][0]:
				alt[1] = uv
			rand[bw] = alt
			var fu: Array = _rand_ueber(sm, _ecken_aus(sk, _finger))
			var uu: Array = _rand_ueber(sm, _ecken_aus(sk, unterarm))
			var au: Array = ueber.get(bw, [[-INF, 0.0, Vector3.ZERO], [-INF, 0.0, Vector3.ZERO], 0.0])
			if fu[0] > au[0][0]:
				au[0] = fu
				au[2] = fig.anim.current_animation_position
			if uu[0] > au[1][0]:
				au[1] = uu
			ueber[bw] = au
		sk.skeleton_updated.connect(rand_mess)
		fig.set_process(false)
		for bw in RAND_BEWEGUNGEN:
			if not fig.anim.has_animation(bw):
				continue
			fig.anim.play(bw, 0.15)
			for j in 45:
				await process_frame
				if j % 2 == 0:
					rand_an.an = true
		sk.skeleton_updated.disconnect(rand_mess)
		fig.anim.play("SS_IdleCombat", 0.2)
		fig.set_process(true)
		for bw in rand:
			var r: Array = rand[bw]
			print("  %s RAND %s: Finger %.1f cm (Stelle %s, bei %.2f s), Unterarm und Hand %.1f cm (Stelle %s) vor der Vorderseite, auch am Rand" % [
				k, bw, r[0][0] * 100.0, (r[0][1] as Vector3).round(), r[2], r[1][0] * 100.0, (r[1][1] as Vector3).round()])
		for bw in ueber:
			var r: Array = ueber[bw]
			print("  %s UEBER %s: Finger %.1f cm über den Rand hinaus, %.1f cm vor der Vorderseite des Rands (Stelle %s, bei %.2f s); Unterarm und Hand %.1f cm hinaus, %.1f cm davor (Stelle %s)" % [
				k, bw, r[0][0] * 100.0, r[0][1] * 100.0, (r[0][2] as Vector3).round(), r[2], r[1][0] * 100.0, r[1][1] * 100.0, (r[1][2] as Vector3).round()])
		sk.skeleton_updated.connect(faust_mess)
		kf.mars.find("merc").auto = true
		kf.mars.set_autopilot(true)
		if not kf.busy:
			kf.go_on()
		var tief := {}     # Bewegung -> [tiefste m, Kapsel, Bilder über TIEF_M]
		var schulter := {}     # 406 b: Bewegung -> [tiefste m, Stelle cm]
		var var_k := []     # 406 b: je Fassung tiefste m Körper (ohne linken Arm)
		var var_s := []     # ... Schulter und Oberarm
		for v in VARIANTEN:
			var_k.append([-INF, Vector3.ZERO]); var_s.append([-INF, Vector3.ZERO])
		var n := 0
		var diag_vorher := ""
		var diag_jetzt := ""
		var dauer := int(OS.get_environment("DAUER_MS")) if OS.get_environment("DAUER_MS") != "" else DAUER_MS
		while n < (dauer * 30 / 1000 if film else 6000):
			await process_frame
			n += 1
			if fig.visible and not fig.down:
				var b := String(fig.anim.current_animation)
				if b != diag_jetzt:
					diag_vorher = "%s (Bild %d)" % [diag_jetzt, n]
					diag_jetzt = b
				var e: Array = tief.get(b, [-INF, Vector3.ZERO, 0])
				if n % 3 == 0 or OS.get_environment("DIAG1014") != "":
					var t := _netz_tiefe(sm, _haut_ecken(sk))
					if t[0] > e[0]:
						e[0] = t[0]
						e[1] = t[1]
					if t[0] > NETZ_M:
						e[2] += 1
						if OS.get_environment("DIAG1014") != "":
							var wp: Vector3 = sm.global_transform * (t[1] / 100.0)
							var nb := ""
							var nd := INF
							for bi in sk.get_bone_count():
								var bp: Vector3 = sk.global_transform * sk.get_bone_global_pose(bi).origin
								if bp.distance_to(wp) < nd:
									nd = bp.distance_to(wp)
									nb = sk.get_bone_name(bi)
							print("DIAG1014 Bild %d %s bei %.3f/%.3f s, vorher %s, %.3f m, Stelle %s, nächster Knochen %s (%.2f m), Welt %s" % [n, b, fig.anim.current_animation_position, fig.anim.current_animation_length, diag_vorher, t[0], t[1], nb, nd, sk.global_transform.affine_inverse() * wp])
				if n % 6 == 3:
					faust.an = true
				if n % 6 == 0:
					var vk := _varianten_tiefe(sm, _haut_ecken(sk))
					var vs := _varianten_tiefe(sm, _ecken_aus(sk, _schulter))
					if vs[0][0] > schulter.get(b, [-INF])[0]:
						schulter[b] = vs[0]
					var vf := _varianten_finger(sm, _ecken_aus(sk, _finger))
					var fb: Array = var_f.get(b, [])
					for i in VARIANTEN_F.size():
						if fb.size() <= i:
							fb.append([-INF, Vector3.ZERO])
						if vf[i][0] > fb[i][0]:
							fb[i] = vf[i]
					var_f[b] = fb
					var bg := _beugen_finger(sk, sm)
					var bf: Array = var_b.get(b, [])
					for i in bg.size():
						if bf.size() <= i:
							bf.append([-INF, Vector3.ZERO])
						if bg[i][0] > bf[i][0]:
							bf[i] = bg[i]
					var_b[b] = bf
					for i in VARIANTEN.size():
						if vk[i][0] > var_k[i][0]:
							var_k[i] = vk[i]
						if vs[i][0] > var_s[i][0]:
							var_s[i] = vs[i]
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
		for b in schulter:
			print("  %s Kampf %s: linke Schulter und Oberarm %.3f m im Schild (Stelle %s cm)" % [k, b if b != "" else "–", schulter[b][0], schulter[b][1]])
		for i in VARIANTEN.size():
			print("  %s FASSUNG tiefer %.0f cm, vorn %.0f cm, Oberkante vor %.0f°, Seite +x vor %.0f°: Körper %.1f cm (Stelle %s), Schulter und Oberarm %.1f cm (Stelle %s) im Schild" % [k, VARIANTEN[i][0] * 100.0, VARIANTEN[i][1] * 100.0, VARIANTEN[i][2], VARIANTEN[i][3], var_k[i][0] * 100.0, (var_k[i][1] as Vector3).round(), var_s[i][0] * 100.0, (var_s[i][1] as Vector3).round()])
		for b in var_f:
			for i in VARIANTEN_F.size():
				print("  %s FINGER %s, Schild vorn +%.0f cm: Finger %.1f cm vor der Vorderseite (Stelle %s)" % [k, b if b != "" else "–", VARIANTEN_F[i][1] * 100.0, var_f[b][i][0] * 100.0, (var_f[b][i][1] as Vector3).round()])
		for b in var_b:
			var z := PackedStringArray()
			for i in (var_b[b] as Array).size():
				var jf := PackedStringArray()
				var je: Dictionary = var_b[b][i][2] if (var_b[b][i] as Array).size() > 2 else {}
				for f in je:
					jf.append("%s %.1f" % [f, float(je[f]) * 100.0])
				z.append("%+.0f° %.1f cm (Stelle %s; %s)" % [BEUGEN[i], var_b[b][i][0] * 100.0, (var_b[b][i][1] as Vector3).round(), ", ".join(jf)])
			print("  %s BEUGEN %s: Finger vor der Vorderseite je Beugung: %s" % [k, b if b != "" else "–", " | ".join(z)])
		sk.skeleton_updated.disconnect(faust_mess)
		for b in faust:
			if b == "an":
				continue
			var jf := PackedStringArray()
			for f in faust[b][2]:
				jf.append("%s %.1f" % [f, float(faust[b][2][f]) * 100.0])
			print("  %s FAUST %s: Finger %.1f cm vor der Vorderseite, wie man sie sieht (bei %.2f s, Stelle %s; %s)" % [k, b if b != "" else "–", faust[b][0] * 100.0, faust[b][3], (faust[b][1] as Vector3).round(), ", ".join(jf)])
		for b in knick_f:
			var z := PackedStringArray()
			for i in (knick_f[b] as Array).size():
				z.append("%+.0f° %.1f cm (Stelle %s)" % [KNICK_PROBE[i], knick_f[b][i][0] * 100.0, (knick_f[b][i][1] as Vector3).round()])
			print("  %s KNICK %s (gebaut %.0f°): Finger vor der Vorderseite je Grad mehr: %s" % [k, b if b != "" else "–", Figur.KNICK_GRAD.get(k, 0.0), " | ".join(z)])
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
