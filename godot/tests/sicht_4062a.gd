extends SceneTree
# 406.2a Lauf 223/230 nachgestellt ohne Bild: DIAG (Lauf 230) zeigte den Wolf und die Waffen in der Szene, im Kegel der Filmkamera, mit
# eigenem Stoff unsichtbar, rot ohne Tiefentest aber da (343 Punkte), an ihrer Stelle grüne Schirmfarbe: etwas verdeckt sie. Hier: der
# Kampfort wie im Film (Probe, Wölfe, Kamera aus film_4062a), dann je Ziel die Dreiecke des Walds zwischen Kamera und Ziel. Kein
# Bildbefehl (390a). Braucht kampf/daten/kampfort-wald.bin (kampfort_wald.py). Aufruf mit --resolution 540x1170 wie der Lauf.
# Massgeblich die Zeilen SICHT.

const Probe = preload("res://kampf/probe.gd")
const FORMAT := Vector2(1080, 2340)
const RAND_M := 1.9
const ABSTAND := 4.4
const WINKEL := [55.0, 40.0, 70.0]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(540, 1170)     # headless: Format wie der Lauf (sonst quadratisch, andere Kampfmitte)
	await process_frame
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 12:
		await process_frame
	var kf = p.fight
	var held = kf.figures["hero"]
	var wolf = null
	for id in kf.figures:
		var f = kf.figures[id]
		if f != held and f.fighter.monster != null and wolf == null:
			wolf = f
	held.position = held.home
	var zu: Vector3 = wolf.home - held.home
	zu.y = 0.0
	zu = zu.normalized()
	var q: Vector3 = held.home + zu.rotated(Vector3.UP, deg_to_rad(WINKEL[0])) * ABSTAND
	q.y = wolf.home.y
	wolf.position = q
	var von: Vector3 = kf.cam.global_position - held.home
	von.y = 0.0
	von = von.normalized().rotated(Vector3.UP, deg_to_rad(-20.0))
	var hfov := 2.0 * atan(tan(deg_to_rad(40.0) / 2.0) * FORMAT.x / FORMAT.y)
	var rechts := von.cross(Vector3.UP).normalized()
	var d: float = clampf(absf((wolf.position - held.position).dot(rechts)) + RAND_M, 2.6, 5.2) / 2.0 / tan(hfov / 2.0)
	var mitte: Vector3 = held.position.lerp(wolf.position, 0.5) + Vector3(0, 0.95, 0)
	var cam_pos: Vector3 = mitte + von * d + Vector3(0, d * 0.22, 0)
	print("SICHT Bild %s, Spielkamera %s, Kampfmitte d0 %.2f" % [root.get_visible_rect().size, kf.cam.global_position, kf.d0])
	print("SICHT Kamera %s (Lauf 230: (-6.87, 4.36, 0.20)), Abstand %.1f m, Held %s, Wolf %s" % [cam_pos, d, held.position, wolf.position])
	var wald := _wald(kf)
	for z in [["Wolf Rumpf", wolf.position + Vector3(0, 0.45, 0)], ["Wolf Kopf", wolf.position + Vector3(0, 0.75, 0)],
			["Held Hüfte (Waffe)", held.position + Vector3(0, 1.0, 0)], ["Held Kopf", held.position + Vector3(0, 1.7, 0)]]:
		var treffer := _treffer(cam_pos, z[1], wald)
		print("SICHT %s: %d Dreiecke des Walds dazwischen, zuerst %s" % [z[0], treffer[0], treffer[1]])
	# zum Vergleich die Spielkamera
	for z in [["Wolf Rumpf", wolf.position + Vector3(0, 0.45, 0)], ["Held Hüfte (Waffe)", held.position + Vector3(0, 1.0, 0)]]:
		var treffer := _treffer(kf.cam.global_position, z[1], wald)
		print("SICHT Spielkamera %s: %d Dreiecke dazwischen" % [z[0], treffer[0]])
	quit(0)


func _wald(kf) -> Array:
	var out := []     # [a, b, c, name]
	var w = kf.get("forest")
	if w == null:
		return out
	for mi in (w as Node).find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null or m.mesh is PlaneMesh or not m.is_visible_in_tree():
			continue
		var tr := m.global_transform
		for s in m.mesh.get_surface_count():
			var ar := m.mesh.surface_get_arrays(s)
			var vs: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
			var idx = ar[Mesh.ARRAY_INDEX]
			var n: int = idx.size() if idx != null else vs.size()
			for t in range(0, n - 2, 3):
				out.append([tr * vs[idx[t] if idx != null else t], tr * vs[idx[t + 1] if idx != null else t + 1], tr * vs[idx[t + 2] if idx != null else t + 2], String(m.name)])
	return out


func _treffer(a: Vector3, b: Vector3, wald: Array) -> Array:
	var n := 0
	var erst := ""
	var best := INF
	var d := b - a
	for t in wald:
		var hit = Geometry3D.segment_intersects_triangle(a, b, t[0], t[1], t[2])
		if hit != null:
			n += 1
			var s: float = (hit as Vector3).distance_to(a)
			if s < best:
				best = s
				erst = "%s bei %.1f m von %.1f m" % [t[3], s, d.length()]
	return [n, erst]
