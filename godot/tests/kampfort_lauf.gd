# 348.7: lets every Probekampf (each foe, hero and Söldner of all classes) play itself through the real Kampfort on
# autopilot, sped up, and checks it ends without a script error and with every message played.
# Run: godot --headless --path godot -s res://tests/kampfort_lauf.gd   (exit code 0 = every fight ended)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const CLASSES := ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]
const LIMIT_MS := 60000


func _initialize() -> void:
	Engine.time_scale = 30.0
	_all.call_deferred()


func _all() -> void:
	var failed := 0
	var n := 0
	for foe in ["WOLVES", "GRAK", "SPIDER", "SCOUT", "RATS"]:
		for i in CLASSES.size():
			var hero: String = CLASSES[i]
			var merc: String = CLASSES[(i + 1) % CLASSES.size()]
			n += 1
			var r: String = await _one(foe, hero, merc)
			print(("endet " if (r.begins_with("WON") and not r.begins_with("WON ohne")) or r.begins_with("LOST") else "FEHLER ") + "%s %s+%s: %s" % [foe, hero, merc, r])
			if not ((r.begins_with("WON") and not r.begins_with("WON ohne")) or r.begins_with("LOST")):
				failed += 1
	print("Kampfort: %d Kämpfe, %d hängen" % [n, failed])
	quit(1 if failed > 0 else 0)


func _one(foe: String, hero: String, merc: String) -> String:
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
	k.mars.find("merc").auto = true
	k.mars.set_autopilot(true)
	if not k.busy:
		k.go_on()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < LIMIT_MS:
		await process_frame
		if k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty():
			break
		if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
			if k.mars.pilot_next() or k.mars.set_autopilot(true):
				k.go_on()
			else:     # no autopilot against a leader (Grak, Spinne): the hero strikes the first he can reach
				var c = k.mars.current()
				var ts: Array = k.mars.targets(c)
				k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	var out: String = k.mars.outcome
	# 296.2: a won fight brings its reward, said at the end
	var lines: Array = k.reward.get("lines", [])
	if out == "WON" and lines.is_empty():
		out = "WON ohne Lohn"
	elif out == "WON":
		out += " " + str(lines)
	k.finish()
	p.queue_free()
	await process_frame
	if out == "ONGOING":
		return "hängt nach %d s" % ((Time.get_ticks_msec() - t0) / 1000)
	return "%s (%d s)" % [out, (Time.get_ticks_msec() - t0) / 1000]
