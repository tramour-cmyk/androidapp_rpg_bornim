# 399.2 (Chef 28.10., 16:10: „wenn nur noch zwei Wölfe da sind und die dann in einer Linie stehen, dann läuft der hintere Wolf
# durch den vorderen“): Wolfsrudel und Wolf mit Jungwölfen auf Autopilot durch den echten Kampfort; in jedem Bild, in dem ein
# Gegner unterwegs ist (Anlauf, Biss, Heimweg), darf seine Mitte nicht im Umriss eines anderen stehenden Gegners liegen
# (Umriss wie figur.gd clearance, um die eigene halbe Breite erweitert). Mit dem gekauften Wolf erst nach „Modelle bauen“ aussagekräftig.
# Run: godot --headless --path godot -s res://tests/umweg_399.gd   (exit code 0 = keiner läuft durch einen anderen)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const CLASSES := ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]
const LIMIT_MS := 60000
const TIEF := -0.05     # m: so weit darf die Mitte den erweiterten Umriss streifen (Messrauschen der Bilder)


func _initialize() -> void:
	Engine.time_scale = 10.0
	_all.call_deferred()


func _all() -> void:
	var failed := 0
	var n := 0
	for foe in ["WOLVES", "RUDEL"]:
		for i in CLASSES.size():
			var hero: String = CLASSES[i]
			n += 1
			var r: Array = await _one(foe, hero, CLASSES[(i + 1) % CLASSES.size()])
			var gut: bool = r[0] == 0
			print(("gut " if gut else "FEHLER ") + "%s %s: %d Bilder durch einen anderen, engste Stelle %.2f m%s (%s)" % [foe, hero, r[0], r[1], r[2], r[3]])
			if not gut:
				failed += 1
	print("Umweg 399.2: %d Kämpfe, %d mit Durchlaufen" % [n, failed])
	quit(1 if failed > 0 else 0)


func _half_w(f) -> float:
	var b: AABB = f.footprint()
	return maxf(0.5 * minf(b.size.x, b.size.z), 0.1)


func _one(foe: String, hero: String, merc: String) -> Array:
	var p = Probe.new()
	p.hero_cls = hero
	p.merc_cls = merc
	p.foe = foe
	root.add_child(p)
	await process_frame
	p._start()
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
	var tight := INF
	var wer := ""
	while Time.get_ticks_msec() - t0 < LIMIT_MS:
		await process_frame
		for f in k.figures.values():
			if f.fighter.side != "FOES" or not f.visible or f.down or f.dead_at >= 0 or not f.lunging():
				continue
			var r := _half_w(f)
			for o in k.figures.values():
				if o == f or o.fighter.side != "FOES" or not o.visible or o.down or o.dead_at >= 0:
					continue
				var c: float = o.clearance(f.position) - r
				if c < tight:
					tight = c
					wer = ", %s in %s%s" % [f.fighter.id, o.fighter.id, " (beide unterwegs)" if o.lunging() else ""]
					# 399.2 Ursache (Tom 17:42: auch ohne Kaufwolf bis −0,92 m): in welcher Bewegung, wo, wessen Platz
					wer += "; %s %s bei %s, Heim %s; %s %s bei %s, Heim %s" % [f.fighter.id, _bew(f), _xz(f.position), _xz(f.home),
						o.fighter.id, _bew(o), _xz(o.position), _xz(o.home)]
				if c < TIEF:
					bad += 1
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
	var kauf: String = "Kaufwolf" if FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json") else "ohne Kaufwolf"
	k.finish()
	p.queue_free()
	await process_frame
	return [bad, tight if tight < INF else 99.0, wer, "%s, %s" % [out, kauf]]


func _bew(f) -> String:
	return String(f.anim.current_animation) if f.anim != null else "-"


func _xz(p: Vector3) -> String:
	return "(%.2f, %.2f)" % [p.x, p.z]
