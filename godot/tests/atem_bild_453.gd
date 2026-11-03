# 453 r3 (Prüfer Film r2, 15:48: Rücken und Flanke schlagen im Film nur ≤ 0,4 px aus): wie weit verschiebt die Atemschicht das Netz
# des Wolfs auf dem Schirm (Pixel), am Kampfort wie in film_453 (Kampfkamera, dann Nahkamera NAHE m), ohne Bild: je Bild die Haut des
# Rumpfs auf dem Rechner nachgerechnet, einmal mit der Pose vor der Atemschicht (Merker-Schicht direkt davor), einmal danach, beide
# mit der Kamera auf 1080 × 2340 abgebildet. Bericht je Wolf und Kamera: größter Ausschlag und Mittel der Höchstwerte je Atemzug.
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/atem_bild_453.gd   (Exit 0 = Rumpf nah ≥ NAH_PX, 1 sonst)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const RUMPF := ["Wolf_ROOTSHJnt", "Wolf_Spine_01SHJnt", "Wolf_Spine_02SHJnt", "Wolf_Spine_03SHJnt", "Wolf_Spine_04SHJnt",
	"Wolf_Spine_TopSHJnt"]
## Grenze: nah soll das Atmen am Rumpf je Atemzug mindestens so viele Pixel ausschlagen (Prüfer: ~4 px erwartet)
const NAH_PX := 2.5


class Merker extends SkeletonModifier3D:
	var posen := []
	func _process_modification_with_delta(_d: float) -> void:
		var sk := get_skeleton()
		posen.resize(sk.get_bone_count())
		for b in sk.get_bone_count():
			posen[b] = sk.get_bone_global_pose(b)


var wolf := {}     # id -> {sk, mi, merker, nach, punkte, bind}
var werte := {}    # "Kamera/id" -> [Höchstwerte je Bild]
var vor := {}      # id -> Bewegung im letzten Bild
var beginne := []  # [Bild, id, Bewegung]
var naechst := INF # Nahkamera: kleinster Abstand zu einem Wolf (m)
var draussen := 0  # Nahkamera: Wolfsbilder außerhalb des Bilds


func _initialize() -> void:
	_run.call_deferred()


func _env(n: String, d: int) -> int:
	return int(OS.get_environment(n)) if OS.get_environment(n) != "" else d


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	if not FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json"):
		print("Atem 453: ohne Kaufwolf, nichts zu messen")
		quit(0)
		return
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(_env("SEED", 7))
	for i in 4:
		await process_frame
	var kf = p.fight
	for f in kf.figures.values():
		if f.fighter.monster != null and f.atem != null:
			_merke(f)
	print("Wölfe mit Atemschicht: %d" % wolf.size())
	for i in _env("RUHE_MS", 8000) * 30 / 1000:
		await process_frame
		_bild(kf, kf.cam, "Kampfkamera")
		_gesten(i)
	var nah := Camera3D.new()
	kf.add_child(nah)
	nah.fov = kf.cam.fov
	_nah(kf, nah)
	nah.make_current()
	for i in _env("NAH_MS", 10000) * 30 / 1000:
		await process_frame
		_nah(kf, nah)
		_bild(kf, nah, "nah")
		_gesten(i + _env("RUHE_MS", 8000) * 30 / 1000)
		for id in wolf:
			var d: float = nah.global_position.distance_to(wolf[id]["f"].global_position)
			naechst = minf(naechst, d)
			if not nah.is_position_in_frustum(wolf[id]["f"].global_position + Vector3(0, 0.5, 0)) and not wolf[id]["f"].down:
				draussen += 1
	_bericht()


func _merke(f) -> void:
	var sk: Skeleton3D = f._find(f.model, "Skeleton3D")
	var mi: MeshInstance3D = null
	for c in f.model.find_children("*", "MeshInstance3D", true, false):
		if (c as MeshInstance3D).skin != null and (mi == null or c.mesh.get_faces().size() > mi.mesh.get_faces().size()):
			mi = c
	var m := Merker.new()
	sk.add_child(m)
	sk.move_child(m, f.atem.get_index())     # direkt vor der Atemschicht
	var e := {"sk": sk, "mi": mi, "merker": m, "nach": [], "f": f}
	f.atem.modification_processed.connect(func():
		var l := []
		for b in sk.get_bone_count():
			l.append(sk.get_bone_global_pose(b))
		e["nach"] = l)
	# Punkte des Rumpfs: überwiegend an Becken, Rücken (Flanke, Brust, Bauch)
	var arr := mi.mesh.surface_get_arrays(0)
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var bo = arr[Mesh.ARRAY_BONES]
	var we = arr[Mesh.ARRAY_WEIGHTS]
	var n_je: int = bo.size() / vs.size()
	var skin := mi.skin
	var bind := []
	for i in skin.get_bind_count():
		var bn := skin.get_bind_bone(i)
		if bn < 0:
			bn = sk.find_bone(skin.get_bind_name(i))
		bind.append([bn, skin.get_bind_pose(i)])
	var punkte := []
	for v in vs.size():
		var dom := 0
		for j in n_je:
			if we[v * n_je + j] > we[v * n_je + dom]:
				dom = j
		if sk.get_bone_name(bind[bo[v * n_je + dom]][0]) in RUMPF:
			var l := []
			for j in n_je:
				if we[v * n_je + j] > 0.0:
					l.append([bo[v * n_je + j], we[v * n_je + j]])
			punkte.append([vs[v], l])
	e["punkte"] = punkte
	e["bind"] = bind
	wolf[String(f.fighter.id)] = e


func _haut(e: Dictionary, posen: Array, cam: Camera3D) -> PackedVector2Array:
	var gt: Transform3D = e["sk"].global_transform
	var out := PackedVector2Array()
	for pk in e["punkte"]:
		var p := Vector3()
		for bw in pk[1]:
			var bi: Array = e["bind"][bw[0]]
			p += bw[1] * (gt * (posen[bi[0]] * (bi[1] * pk[0])))
		out.append(Vector2(INF, INF) if cam.is_position_behind(p) else cam.unproject_position(p))
	return out


func _bild(kf, cam: Camera3D, name: String) -> void:
	for id in wolf:
		var e: Dictionary = wolf[id]
		if e["nach"].is_empty() or e["merker"].posen.is_empty() or e["f"].down:
			continue
		var a := _haut(e, e["merker"].posen, cam)
		var b := _haut(e, e["nach"], cam)
		var m := 0.0
		for i in a.size():
			if a[i].x != INF and b[i].x != INF:
				m = maxf(m, a[i].distance_to(b[i]))
		var k := "%s/%s" % [name, id]
		if not werte.has(k):
			werte[k] = []
		werte[k].append(m)


## Beginn jeder Bewegung vor dem Kampf (Ruhe), mit Stand der Grundschleife (Gleichtakt der Grundschleifen)
func _gesten(n: int) -> void:
	var stand := []
	for id in wolf:
		var an: AnimationPlayer = wolf[id]["f"].anim
		var a := String(an.current_animation)
		if a != vor.get(id, ""):
			beginne.append([n, id, a])
		vor[id] = a
		stand.append("%s %s %.2f" % [id, a, an.current_animation_position])
	if n in [30, 120]:
		print("Bild %d: %s" % [n, ", ".join(stand)])


## wie film_453 _nah
var _mitte := Vector3.INF

## Tangens des halben Blickwinkels quer (fov gilt in der Höhe, der Schirm steht hochkant)
func _halb_quer(kf, cam: Camera3D) -> float:
	var g: Vector2 = Vector2(kf.get_viewport().get_visible_rect().size)
	return tan(deg_to_rad(cam.fov) * 0.5) * g.x / maxf(g.y, 1.0)


func _nah(kf, cam: Camera3D) -> void:
	var s := Vector3.ZERO
	var z := 0
	for f in kf.figures.values():
		if f != null and is_instance_valid(f) and f.fighter != null and f.fighter.monster != null and not f.down:
			s += f.home
			z += 1
	if z == 0:
		return
	# 453 r3 (Prüfer Film r2: Kopf des schwarzen Wolfs füllt das halbe Bild, meist nur ein Wolf; gemessen: wer angreift, läuft auf die
	# Kamera zu): von der Seite, quer zur Richtung Wölfe → Helden, so weit, dass das ganze Rudel ins Bild passt; fest, ohne Nachführen
	if _mitte != Vector3.INF:
		return
	_mitte = s / z + Vector3(0, 0.6, 0)
	var zu: Vector3 = kf.cam.global_position - _mitte
	zu.y = 0.0
	var seite: Vector3 = zu.normalized().cross(Vector3.UP)
	# aus der Richtung, in der das Rudel schmaler im Bild steht (seitlich oder schräg von vorn, über den Helden hinweg)
	var beste := Vector3.ZERO
	var beste_weit := INF
	for r in [seite, (seite + zu.normalized()).normalized(), (zu.normalized() - seite).normalized(), -seite]:
		var quer: Vector3 = r.cross(Vector3.UP)
		var breit := 0.0
		for f in kf.figures.values():
			if f != null and is_instance_valid(f) and f.fighter != null and f.fighter.monster != null and not f.down:
				breit = maxf(breit, absf((f.home - _mitte).dot(quer)))
		var w: float = (breit + 0.8) / _halb_quer(kf, cam)
		if w < beste_weit:
			beste_weit = w
			beste = r
	var weit: float = float(OS.get_environment("NAHE")) if OS.get_environment("NAHE") != "" else maxf(3.2, beste_weit)
	cam.position = _mitte + beste * weit + Vector3(0, 0.5, 0)
	cam.look_at(_mitte)


func _bericht() -> void:
	var fehler := 0
	for k in werte:
		var l: Array = werte[k]
		# Höchstwert je Atemzug: Fenster von 2,4 s
		var zuege := []
		var i := 0
		while i < l.size():
			var m := 0.0
			for j in range(i, mini(i + 72, l.size())):
				m = maxf(m, l[j])
			zuege.append(m)
			i += 72
		var s := 0.0
		for z in zuege:
			s += z
		var mittel: float = s / maxf(zuege.size(), 1)
		print("— %s: größter Ausschlag Rumpf %.2f px, je Atemzug im Mittel %.2f px (%d Bilder)" % [k, l.max(), mittel, l.size()])
		if k.begins_with("nah/") and mittel < NAH_PX:
			fehler += 1
	var gb := []
	for b in beginne:
		gb.append("%.1f s %s %s" % [b[0] / 30.0, b[1], b[2]])
	print("Bewegungen in Ruhe: %s" % ", ".join(gb))
	print("Nahkamera: nächster Wolf %.2f m, Wölfe außerhalb des Bilds in %d Wolfsbildern" % [naechst, draussen])
	print("Atem 453 auf dem Schirm: %d Wölfe nah unter %.1f px" % [fehler, NAH_PX])
	quit(1 if fehler else 0)
