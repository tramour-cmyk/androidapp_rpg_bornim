extends SceneTree
# 531.2 (Chef 16.11., 17:34 zum Bild Garrick im Profil: „Da schwebt ein Gürtel über Schulter und durch die Kapuze … Köcher … und Bogen
# schwebt auch“): ohne Bild. Garrick wie im Spiel (HeldFigur.person), in „Stehen“ an fünf Stellen angehalten, nach den Schichten
# (skeleton_updated) gehäutet wie im Zeichner. Gemessen je Teil der Abstand zur nächsten Fläche von Körper und Kleidung (Dreiecke
# dicht abgetastet): Gurt je Ecke (höchstens GURT_LUFT_MAX), Köcher an seiner nächsten Stelle (höchstens KOECHER_LUFT_MAX), Bogen zur
# nächsten Fläche von Köcher, Gurt, Körper (höchstens BOGEN_LUFT_MAX). Massgeblich ist die Zeile SCHWEBEN531.
#   im Ordner godot: MESS=531 godot --headless --path . -s res://tests/schweben_531.gd   (ohne Kaufdaten „ohne Kauf“, 0)

const GURT_LUFT_MAX := 0.012
const KOECHER_LUFT_MAX := 0.012
const BOGEN_LUFT_MAX := 0.015
const BARY := [Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1), Vector3(0.5, 0.5, 0), Vector3(0, 0.5, 0.5), Vector3(0.5, 0, 0.5),
		Vector3(1, 1, 1) / 3.0, Vector3(4, 1, 1) / 6.0, Vector3(1, 4, 1) / 6.0, Vector3(1, 1, 4) / 6.0]
const ZELLE := 0.03
var fehler := 0
var _sk: Skeleton3D
var _posen := []

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if not FileAccess.file_exists("res://daten/held_L_garrick_M.bin"):
		print("SCHWEBEN531 ohne Kauf, 0 Fehler"); quit(0); return
	var g := HeldFigur.person("garrick", [])
	root.add_child(g)
	_sk = Gebiet.finde(g, "Skeleton3D") as Skeleton3D
	var ap := Gebiet.finde(g, "AnimationPlayer") as AnimationPlayer
	for i in 5: await process_frame
	var schlecht := {"Gurt": [-INF, ""], "Koecher": [-INF, ""], "Bogen": [-INF, ""], "tief": [INF, ""]}
	for st in 5:
		if ap and ap.has_animation("Stehen"):
			ap.play("Stehen"); ap.seek(ap.get_animation("Stehen").length * st / 5.0, true); ap.pause()
		for i in 3: await process_frame
		_posen = []
		_sk.skeleton_updated.connect(_merke, CONNECT_ONE_SHOT)
		for i in 3: await process_frame
		if _posen.is_empty(): print("SCHWEBEN531 keine Pose"); continue
		var koerper := PackedVector3Array(); var gurt := PackedVector3Array()
		var ohne_k := PackedVector3Array(); var ohne_n := PackedVector3Array()
		for mi in g.find_children("*", "MeshInstance3D", true, false):
			var m := mi as MeshInstance3D
			if m.skin == null or m.get_parent() is BoneAttachment3D: continue
			if m.name == "Gurt": gurt.append_array(_gehaeutet(m, false)); continue
			normalen = PackedVector3Array()
			var d := _gehaeutet(m, true)
			if not String(m.name).containsn("hood"): ohne_k.append_array(_gehaeutet(m, true, true))
			koerper.append_array(d)

		# Gurt im Körper (ohne Kapuze, er liegt unter ihr): von jeder Ecke der Außenseite des Riemens (Normale weg von der Rumpfachse) ein
		# Strahl nach außen; liegt bis 4 cm davor eine Fläche von Körper oder Kleidung (Röhre 1 cm), steckt der Riemen darunter, so tief
		var tief := INF; var two := Vector3.ZERO
		var achse := _sk.global_transform * (_posen[_sk.find_bone("spine_02")] as Transform3D).origin
		var gi := _gitter(ohne_k)
		var gm := g.find_child("Gurt", true, false) as MeshInstance3D
		var gn: PackedVector3Array = gm.mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
		var gb := _gurt_basen(gm)
		for i in gurt.size():
			var nor: Vector3 = (gb[i] as Basis) * gn[i]
			nor = nor.normalized()
			var p: Vector3 = gurt[i]
			if nor.dot(Vector3(p.x - achse.x, 0.0, p.z - achse.z)) <= 0.0: continue
			var k := Vector3i(floori(p.x / ZELLE), floori(p.y / ZELLE), floori(p.z / ZELLE))
			for dx in range(-2, 3):
				for dy in range(-2, 3):
					for dz in range(-2, 3):
						var z = gi.get(k + Vector3i(dx, dy, dz))
						if z == null: continue
						for q in z:
							var v: Vector3 = q - p
							var t := v.dot(nor)
							if t > 0.003 and t < 0.04 and (v - nor * t).length() < 0.01 and -t < tief:
								tief = -t; two = p
								if OS.get_environment("MESS") == "531": print("DECKT Gurt %s nor %s davor %s" % [_wo(g, p), nor, _wo(g, q)])
		if tief < float(schlecht.get("tief", [INF])[0]): schlecht["tief"] = [tief, _wo(g, two)]
		var koecher := _starr(g, "RueckenKoecher"); var bogen := _starr(g, "RueckenBogen")
		var gitter := _gitter(koerper)
		# Gurt: jede Ecke; die weiteste zählt
		var gw := -INF; var gwo := Vector3.ZERO
		for p in gurt:
			var d := _naechste(gitter, p)
			if d > gw: gw = d; gwo = p
		var kw := INF; var kwo := Vector3.ZERO
		for p in koecher:
			var d := _naechste(gitter, p)
			if d < kw: kw = d; kwo = p
		var mit := koerper.duplicate(); mit.append_array(_dicht(g, "RueckenKoecher")); mit.append_array(gurt)
		var gitter2 := _gitter(mit)
		var bw := INF; var bwo := Vector3.ZERO
		for p in bogen:
			var d := _naechste(gitter2, p)
			if d < bw: bw = d; bwo = p
		print("SCHWEBEN531 Stehen %d/5: Gurt weiteste Ecke %.1f cm (%s), Köcher nächste Stelle %.1f cm (%s), Bogen nächste Stelle %.1f cm (%s)" % [st, gw * 100, _wo(g, gwo), kw * 100, _wo(g, kwo), bw * 100, _wo(g, bwo)])
		for n in [["Gurt", gw, gwo], ["Koecher", kw, kwo], ["Bogen", bw, bwo]]:
			if float(n[1]) > float(schlecht[n[0]][0]): schlecht[n[0]] = [n[1], _wo(g, n[2])]
	for n in [["Gurt", GURT_LUFT_MAX], ["Koecher", KOECHER_LUFT_MAX], ["Bogen", BOGEN_LUFT_MAX]]:
		var w: float = schlecht[n[0]][0]
		var gut := w <= float(n[1])
		if not gut: fehler += 1
		print("%s %s: höchstens %.1f cm Luft (erlaubt %.1f), schlechteste Stelle %s" % ["gut" if gut else "FEHLER", n[0], w * 100, float(n[1]) * 100, schlecht[n[0]][1]])
	var tf: float = schlecht["tief"][0]
	if tf == INF: tf = 0.0
	if tf < -0.004: fehler += 1
	print("%s Gurt im Körper: tiefste Ecke %.1f cm (erlaubt 0,4 cm), bei %s" % ["gut" if tf >= -0.004 else "FEHLER", -tf * 100, schlecht["tief"][1]])
	print("SCHWEBEN531 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func _merke() -> void:
	_posen.resize(_sk.get_bone_count())
	for b in _sk.get_bone_count(): _posen[b] = _sk.get_bone_global_pose(b)

## Ort im Raum der Figur in cm (x links, y hoch, z vorn)
func _wo(g: Node3D, p: Vector3) -> String:
	var q := g.global_transform.affine_inverse() * p
	return "x %.0f y %.0f z %.0f cm" % [q.x * 100, q.y * 100, q.z * 100]

## ohne_arme: Dreiecke mit einer Ecke an Arm oder Hand (Gewicht über 0,3) fallen weg (der hängende Arm vor dem Gurt ist kein Durchstoßen)
func _gehaeutet(m: MeshInstance3D, dicht: bool, ohne_arme := false) -> PackedVector3Array:
	var aus := PackedVector3Array()
	var g := _sk.global_transform
	var trs := []
	for i in m.skin.get_bind_count():
		var bb := m.skin.get_bind_bone(i)
		if bb < 0: bb = _sk.find_bone(m.skin.get_bind_name(i))
		trs.append(g * (_posen[maxi(bb, 0)] as Transform3D) * m.skin.get_bind_pose(i))
	for s in m.mesh.get_surface_count():
		var ar := m.mesh.surface_get_arrays(s)
		if ar[Mesh.ARRAY_BONES] == null: continue
		var vs: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
		var nb: int = ar[Mesh.ARRAY_BONES].size() / vs.size()
		var welt := PackedVector3Array(); welt.resize(vs.size())
		for v in vs.size():
			var p := Vector3.ZERO
			for j in nb:
				var w: float = ar[Mesh.ARRAY_WEIGHTS][v * nb + j]
				if w > 0.0: p += (trs[ar[Mesh.ARRAY_BONES][v * nb + j]] as Transform3D) * vs[v] * w
			welt[v] = p
		if not dicht: aus.append_array(welt); continue
		var idx = ar[Mesh.ARRAY_INDEX]
		if ohne_arme:
			var arm := PackedByteArray(); arm.resize(vs.size())
			for v in vs.size():
				var w := 0.0
				for j in nb:
					var bb := m.skin.get_bind_bone(ar[Mesh.ARRAY_BONES][v * nb + j])
					if bb < 0: bb = _sk.find_bone(m.skin.get_bind_name(ar[Mesh.ARRAY_BONES][v * nb + j]))
					var bn := _sk.get_bone_name(maxi(bb, 0))
					if bn.begins_with("upperarm") or bn.begins_with("lowerarm") or bn.begins_with("hand") or bn.contains("thumb") or bn.contains("index") or bn.contains("middle") or bn.contains("ring") or bn.contains("pinky"):
						w += ar[Mesh.ARRAY_WEIGHTS][v * nb + j]
				arm[v] = 1 if w > 0.3 else 0
			var neu_idx := PackedInt32Array()
			var n: int = (idx.size() if idx != null else vs.size()) / 3
			for d in n:
				var e := [idx[d * 3] if idx != null else d * 3, idx[d * 3 + 1] if idx != null else d * 3 + 1, idx[d * 3 + 2] if idx != null else d * 3 + 2]
				if arm[e[0]] == 0 and arm[e[1]] == 0 and arm[e[2]] == 0: neu_idx.append_array(PackedInt32Array(e))
			idx = neu_idx
		aus.append_array(_abtasten(welt, idx))
	return aus

var normalen := PackedVector3Array()   # je Punkt aus _abtasten die Flaechennormale (Reihenfolge wie die Punkte)

func _abtasten(welt: PackedVector3Array, idx) -> PackedVector3Array:
	var aus := PackedVector3Array()
	var n: int = (idx.size() if idx != null else welt.size()) / 3
	for d in n:
		var a: Vector3 = welt[idx[d * 3] if idx != null else d * 3]
		var b: Vector3 = welt[idx[d * 3 + 1] if idx != null else d * 3 + 1]
		var c: Vector3 = welt[idx[d * 3 + 2] if idx != null else d * 3 + 2]
		var l := maxf(a.distance_to(b), maxf(b.distance_to(c), a.distance_to(c)))
		var k := clampi(ceili(l / 0.01), 1, 12)   # etwa alle 1 cm ein Punkt
		var nor := (b - a).cross(c - a).normalized()
		for i in k + 1:
			for j in k + 1 - i:
				var u := float(i) / k; var v := float(j) / k
				aus.append(a * (1.0 - u - v) + b * u + c * v); normalen.append(nor)
	return aus

## Ecken eines starren Teils (Knoten unter dem Skelett, Name beginnt mit was)
func _starr(g: Node3D, was: String) -> PackedVector3Array:
	var aus := PackedVector3Array()
	for ba in _sk.find_children(was + "*", "", false, false):
		for mi in ba.find_children("*", "MeshInstance3D", true, false) + ([ba] if ba is MeshInstance3D else []):
			var t := (mi as MeshInstance3D).global_transform
			for s in (mi as MeshInstance3D).mesh.get_surface_count():
				for v in (mi as MeshInstance3D).mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]: aus.append(t * v)
	return aus

func _dicht(g: Node3D, was: String) -> PackedVector3Array:
	var aus := PackedVector3Array()
	for ba in _sk.find_children(was + "*", "", false, false):
		for mi in ba.find_children("*", "MeshInstance3D", true, false) + ([ba] if ba is MeshInstance3D else []):
			var t := (mi as MeshInstance3D).global_transform
			for s in (mi as MeshInstance3D).mesh.get_surface_count():
				var ar := (mi as MeshInstance3D).mesh.surface_get_arrays(s)
				var welt := PackedVector3Array()
				for v in ar[Mesh.ARRAY_VERTEX]: welt.append(t * v)
				aus.append_array(_abtasten(welt, ar[Mesh.ARRAY_INDEX]))
	return aus

func _gitter(pts: PackedVector3Array) -> Dictionary:
	var g := {}
	for p in pts:
		var k := Vector3i(floori(p.x / ZELLE), floori(p.y / ZELLE), floori(p.z / ZELLE))
		if not g.has(k): g[k] = PackedVector3Array()
		g[k].append(p)
	return g

## Abstand zum nächsten Punkt (bis 15 cm; weiter: 15 cm)
func _naechste(g: Dictionary, p: Vector3) -> float:
	var k := Vector3i(floori(p.x / ZELLE), floori(p.y / ZELLE), floori(p.z / ZELLE))
	var best := 0.15
	for dx in range(-5, 6):
		for dy in range(-5, 6):
			for dz in range(-5, 6):
				var z = g.get(k + Vector3i(dx, dy, dz))
				if z == null: continue
				for q in z: best = minf(best, p.distance_to(q))
	return best

## je Ecke des Gurts die Drehung seiner Häutung (für die Normale)
func _gurt_basen(m: MeshInstance3D) -> Array:
	var aus := []
	var g := _sk.global_transform
	var trs := []
	for i in m.skin.get_bind_count():
		var bb := m.skin.get_bind_bone(i)
		if bb < 0: bb = _sk.find_bone(m.skin.get_bind_name(i))
		trs.append(g * (_posen[maxi(bb, 0)] as Transform3D) * m.skin.get_bind_pose(i))
	var ar := m.mesh.surface_get_arrays(0)
	var vs: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
	var nb: int = ar[Mesh.ARRAY_BONES].size() / vs.size()
	for v in vs.size():
		var b := Basis(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)
		for j in nb:
			var w: float = ar[Mesh.ARRAY_WEIGHTS][v * nb + j]
			if w > 0.0:
				var tb: Basis = (trs[ar[Mesh.ARRAY_BONES][v * nb + j]] as Transform3D).basis
				b = Basis(b.x + tb.x * w, b.y + tb.y * w, b.z + tb.z * w)
		aus.append(b)
	return aus
