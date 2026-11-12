# 863 (Chef 11.11., 20:43/20:45, t277.14, Probekampf Ratten, Wachsoldat: „die graue kam von hinten, hat angegriffen und ging dann
# … links ein bisschen zurück und steht jetzt neben der anderen, die schon da war, oder halb auf ihr rauf“): Ratten (und Wölfe,
# Grabhunde) auf Autopilot durch den echten Kampfort; in jedem Bild, in dem zwei stehende Gegner beide ruhen (kein Schlag, kein
# Gehen), darf keiner im Umriss des anderen stehen (Körper ohne Schatten wie umweg_399, um die eigene halbe Breite erweitert), und
# keine zwei stehenden Gegner haben denselben Platz (home), wenn der Kampf auf den Helden wartet.
# Run: godot --headless --path godot -s res://tests/ruhe_863.gd   (GEGNER=…, SEEDS=…; Exit 0 = keiner steht auf einem anderen)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const LIMIT_MS := 60000
const TIEF := -0.05     # m: Messrauschen wie umweg_399


func _initialize() -> void:
	Engine.time_scale = 10.0
	_all.call_deferred()


func _all() -> void:
	var failed := 0
	var n := 0
	var gegner := (OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "RATS,GRABHUNDE,WOLVES").split(",")
	var seeds := (OS.get_environment("SEEDS") if OS.get_environment("SEEDS") != "" else "1,2,3,4").split(",")
	for foe in gegner:
		for s in seeds:
			n += 1
			var r: Array = await _one(foe, int(s))
			var gut: bool = r[0] == 0 and r[1] == 0
			print(("gut " if gut else "FALSCH ") + "%s Seed %s: %d Bilder aufeinander, %d gleiche Plätze, engste Stelle %.2f m%s (%s)" % [foe, s, r[0], r[1], r[2], r[3], r[4]])
			if not gut:
				failed += 1
	print("RUHE863 %d Kämpfe, %d mit Gegnern aufeinander" % [n, failed])
	quit(1 if failed > 0 else 0)


func _half_w(f) -> float:
	var b: AABB = _koerper(f)
	return maxf(0.5 * minf(b.size.x, b.size.z), 0.1)


var _koerper_von := {}
func _koerper(f) -> AABB:
	if _koerper_von.has(f):
		return _koerper_von[f]
	var r: float = f.body_r()
	var box := AABB(Vector3(-r, 0, -r), Vector3(2 * r, 1, 2 * r))
	if f.model != null:
		var inv: Transform3D = f.global_transform.affine_inverse()
		var first := true
		for m in f.model.find_children("*", "MeshInstance3D", true, false):
			if String(m.name).ends_with("schatten"):
				continue
			var b: AABB = (inv * m.global_transform) * m.get_aabb()
			box = b if first else box.merge(b)
			first = false
	_koerper_von[f] = box
	return box


func _frei(o, p: Vector3) -> float:
	var box := _koerper(o)
	var loc: Vector3 = o.global_transform.affine_inverse() * p
	var dx := maxf(box.position.x - loc.x, loc.x - box.end.x)
	var dz := maxf(box.position.z - loc.z, loc.z - box.end.z)
	if dx <= 0.0 and dz <= 0.0:
		return maxf(dx, dz)
	return Vector2(maxf(dx, 0.0), maxf(dz, 0.0)).length()


func _ruht(f) -> bool:
	return not f.lunging() and not (f.tween and f.tween.is_running())


func _steht(f) -> bool:
	return f.fighter.side == "FOES" and f.visible and not f.down and f.dead_at < 0 and f.fighter.hp > 0


func _one(foe: String, s: int) -> Array:
	seed(s)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = foe
	root.add_child(p)
	await process_frame
	p._start(s)
	await process_frame
	await process_frame
	var k = p.fight
	if k.mars.find("merc") != null:
		k.mars.find("merc").auto = true
	k.mars.set_autopilot(true)
	if not k.busy:
		k.go_on()
	var t0 := Time.get_ticks_msec()
	var bad := 0
	var gleich := 0
	var tight := INF
	var wer := ""
	var schon := {}
	while Time.get_ticks_msec() - t0 < LIMIT_MS:
		await process_frame
		var fs: Array = k.figures.values().filter(func(f): return _steht(f))
		for f in fs:
			for o in fs:
				if o == f or not _ruht(f) or not _ruht(o):
					continue
				var c: float = _frei(o, f.position) - _half_w(f)
				if c < tight:
					tight = c
					wer = "; %s bei %s (Heim %s, Platz %s) in %s bei %s (Heim %s, Platz %s), %.1f s" % [f.fighter.id, _xz(f.position), _xz(f.home),
						str(f.fighter.place), o.fighter.id, _xz(o.position), _xz(o.home), str(o.fighter.place), k.clock_ms / 1000.0]
				if c < TIEF:
					bad += 1
		# gleiche Plätze, wenn der Kampf auf den Helden wartet
		if not k.busy and not k.playing and k.beats.is_empty():
			for f in fs:
				for o in fs:
					if f.fighter.id < o.fighter.id and Vector2(f.home.x - o.home.x, f.home.z - o.home.z).length() < 0.05:
						var key := "%s|%s" % [f.fighter.id, o.fighter.id]
						if not schon.has(key):
							schon[key] = true
							gleich += 1
							print("     %s Seed %d: %s und %s gleicher Platz %s (%s, %s), %.1f s" % [foe, s, f.fighter.id, o.fighter.id, _xz(f.home),
								str(f.fighter.place), str(o.fighter.place), k.clock_ms / 1000.0])
		if k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty():
			break
		if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
			if k.mars.pilot_next() or k.mars.set_autopilot(true):
				k.go_on()
			else:
				var c = k.mars.current()
				var ts: Array = k.mars.targets(c)
				k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	var out: String = k.mars.outcome
	k.finish()
	p.queue_free()
	await process_frame
	return [bad, gleich, tight if tight < INF else 99.0, wer, out]


func _xz(p: Vector3) -> String:
	return "(%.2f, %.2f)" % [p.x, p.z]
