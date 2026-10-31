# 403: Film des Kaufhelden im Kampfort (Kämpfer, dann Kleriker, gegen das Wolfsrudel, Autopilot, Echtzeit). Nur mit
# --write-movie und Fenster (xvfb-run), Probelauf nach 389: PROBE=403 xvfb-run godot --path godot --write-movie <datei>.avi
# --fixed-fps 30 -s res://tests/film_403.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const KLASSEN := ["FIGHTER", "CLERIC"]
const DAUER_MS := 22000


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for k in (OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(KLASSEN)):
		var p = Probe.new()
		p.hero_cls = k
		p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
		p.foe = "WOLVES"
		root.add_child(p)
		await process_frame
		p._start()
		for i in 4:
			await process_frame
		var kf = p.fight
		kf.mars.find("merc").auto = true
		kf.mars.set_autopilot(true)
		if not kf.busy:
			kf.go_on()
		var t0 := Time.get_ticks_msec()
		var n := 0
		while n < DAUER_MS * 30 / 1000:     # Bilder bei --fixed-fps 30
			await process_frame
			n += 1
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
					kf.go_on()
				else:
					var c = kf.mars.current()
					var ts: Array = kf.mars.targets(c)
					kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		print("Film 403 %s: %s nach %d Bildern" % [k, kf.mars.outcome, n])
		kf.queue_free()     # der Kampfort hängt an der Wurzel (Prüfer Film 1: Figuren des ersten Kampfs blieben stehen)
		p.queue_free()
		await process_frame
	quit(0)
