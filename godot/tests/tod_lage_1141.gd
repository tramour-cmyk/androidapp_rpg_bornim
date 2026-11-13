# 1141.1 (Chef 13.11., 16:17: „die fallen alle mit Schwerpunkt dahin, wo sie halt standen vorher … als würden ihm die Beine nach
# hinten weggezogen“; Sokrates Punkt 3): gilt das auch für die Körper mit Bibliothekstod und für „Niedergeworfen“? Messung ohne Bild
# am echten Kampfort: je Gegner Becken und Füße (Knochen mit hips/pelvis, foot/toe/ball im Namen) vor dem Fall und nach dem Liegen,
# waagerecht in Metern. Fällt der Körper um die Füße, bleiben die Füße (≤ FUSS_M) und das Becken wandert; zieht er die Beine weg,
# bleibt das Becken über dem Standplatz und die Füße wandern. Nur Messung, kein Urteil (Exit 0, außer ohne Kampf).
# Run: GEGNER=GRAK,KROGG,SKELETONS,BOARS godot --headless --path godot --fixed-fps 30 -s res://tests/tod_lage_1141.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const LIEGEN_BILDER := 30 * 4
const FUSS_M := 0.15

var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _knochen(sk: Skeleton3D, worte: Array) -> Array:
	var r := []
	for b in sk.get_bone_count():
		var n := sk.get_bone_name(b).to_lower()
		for w in worte:
			if n.contains(w):
				r.append(b)
				break
	return r


func _lage(sk: Skeleton3D, knochen: Array) -> Vector2:
	if knochen.is_empty():
		return Vector2.INF
	var s := Vector3.ZERO
	for b in knochen:
		s += sk.global_transform * sk.get_bone_global_pose(b).origin
	s /= knochen.size()
	return Vector2(s.x, s.z)


func _messe(fig, wie: String) -> void:
	var sk: Skeleton3D = fig._find(fig.model, "Skeleton3D") as Skeleton3D if fig.model else null
	if sk == null:
		print("TODLAGE1141 %s %s: kein Skelett (Ersatzzweig, kippt als Ganzes)" % [fig.fighter.id, wie])
		return
	var becken := _knochen(sk, ["hips", "pelvis", "becken"])
	if becken.size() > 1:
		becken = [becken[0]]
	var fuesse := _knochen(sk, ["foot", "toe", "ball", "fuss"])
	var b0 := _lage(sk, becken)
	var f0 := _lage(sk, fuesse)
	var tod: bool = fig.anim != null and fig.anim.has_animation("Tod")
	if wie == "stirbt":
		fig.die()
	else:
		fig.knocked_down()
	for i in LIEGEN_BILDER:
		await process_frame
	var b1 := _lage(sk, becken)
	var f1 := _lage(sk, fuesse)
	if b0 == Vector2.INF or f0 == Vector2.INF:
		print("TODLAGE1141 %s %s: Becken %d, Füße %d Knochen erkannt (%s)" % [fig.fighter.id, wie, becken.size(), fuesse.size(), sk.get_bone_name(0)])
		return
	var fw := f0.distance_to(f1)
	var bw := b0.distance_to(b1)
	print("TODLAGE1141 %s %s (%s): Becken %.2f m gewandert, Füße %.2f m, Becken am Ende %.2f m vom alten Fußpunkt → %s" % [
		fig.fighter.id, wie, "Tod" if tod else "ohne Tod", bw, fw, b1.distance_to(f0),
		"um die Füße" if fw <= FUSS_M and bw > fw else "Beine weggezogen" if fw > bw else "unklar"])


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	var gegner := (OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "GRAK,KROGG,SKELETONS").split(",")
	for g in gegner:
		seed(7)
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = g
		root.add_child(p)
		await process_frame
		p._start(7)
		for i in 30:
			await process_frame
		var kf = p.fight
		if kf == null:
			print("TODLAGE1141 kein Kampf %s" % g)
			fehler += 1
			p.queue_free()
			continue
		var erster := true
		for id in kf.figures.keys():
			var fig = kf.figures[id]
			if fig.fighter.monster == null or not fig.visible:
				continue
			# der erste Gegner jeder Art stirbt, der zweite wird niedergeworfen (wenn da)
			await _messe(fig, "stirbt" if erster else "niedergeworfen")
			erster = false
		p.queue_free()
		await process_frame
	print("TODLAGE1141 fertig, %d ohne Kampf" % fehler)
	quit(1 if fehler > 0 else 0)
