# 992 (Chef 11.11., 20:29, Test 277, wiederholt zu 709: „der Bildschirm springt am Anfang zwei, dreimal … jedes Mal so ungefähr, wenn
# eine Textzeile in den Bericht kam … dieses Umspringen, wenn ich dran bin“; 20:32: „das Bild zuckt einfach ab und zu“): Messung ohne
# Bild am echten Kampfort, der Held zieht von Hand wie in beam_864, Gegner und Söldner nach Autopilot. Je Bild der Schirmort eines
# festen Punkts am Boden: rückt er außerhalb eines Schlags (dessen Zoom und Ruck gewollt sind, 249) weiter als SCHIRM_PX in einem Bild,
# ist das ein Sprung; ebenso, wenn der Boden selbst rückt (die Kamera passt neu, kampfort._fit_camera).
# Gefunden (vorher): beim Aufbau ein Bild lang Grundstellung der Linse (_fit_camera gegen _rand_kamera, 29 px); bei jedem Zug des
# Söldners war der Kasten ein Bild lang 1207 statt 849 px hoch, _rand_kamera nahm die Linse 4 % zurück (14 px) und kam langsam wieder.
# Run: GEGNER=WOLVES,KOBOLDS godot --headless --path godot --fixed-fps 30 -s res://tests/kamera_992.gd   (Exit 0 = kein Sprung)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const DAUER_BILDER := 30 * 120
const SCHIRM_PX := 10.0    # in einem Bild (1/30 s), bei 1080 px Breite; der weiche Rückzug der Linse (438, _rand_kamera) bleibt darunter
const WARTE_BILDER := 20   # so lange steht der Held am Zug, bevor er befiehlt (der Spieler schaut erst)

var spruenge := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	var gegner := (OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES,KOBOLDS").split(",")
	for g in gegner:
		var sd := int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7
		seed(sd)
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = g
		root.add_child(p)
		await process_frame
		p._start(sd)
		for i in 4:
			await process_frame
		var kf = p.fight
		if kf == null:
			print("KAMERA992 kein Kampf %s" % g)
			spruenge += 1
			p.queue_free()
			continue
		if kf.mars.find("merc") != null:
			kf.mars.find("merc").auto = true
		if not kf.busy:
			kf.go_on()
		var boden: Vector3 = kf._ground(0, 0)
		var punkt: Vector3 = boden     # fester Punkt der Welt
		var sp_vor := Vector2.INF
		var n := 0
		var warte := 0
		var am_zug := 0
		var hier := 0
		var schlag := 0
		while n < DAUER_BILDER:
			await process_frame
			n += 1
			var b: Vector3 = kf._ground(0, 0)
			var rueck := b - boden
			boden = b
			var held_dran: bool = not kf.busy and kf.zuege > 0
			if held_dran:
				am_zug += 1
			var sp: Vector2 = kf.cam.unproject_position(punkt)
			if n > 15 and sp_vor != Vector2.INF and sp.distance_to(sp_vor) > SCHIRM_PX:
				if kf.hit.is_empty():
					hier += 1
					print("  Sprung %s Bild %d (%.1f s): %.0f px, Zug %d%s, rand_z %.3f, Kasten %.0f px" % [g, n, n / 30.0,
						sp.distance_to(sp_vor), kf.zuege, ", Held am Zug" if held_dran else "", kf.rand_z, kf.ui.panel.size.y if kf.ui else -1.0])
				else:
					schlag += 1
			if n > 15 and rueck.length() > 0.01:
				hier += 1
				print("  Boden %s Bild %d (%.1f s): %.2f m, Zug %d" % [g, n, n / 30.0, rueck.length(), kf.zuege])
			sp_vor = sp
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				if kf.mars.pilot_next():
					kf.go_on()
					continue
				warte += 1
				if warte < WARTE_BILDER:
					continue
				warte = 0
				var c = kf.mars.current()
				var ts: Array = kf.mars.targets(c)
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		print("KAMERA992 %s: %s nach %.1f s, Held %d Bilder am Zug, %d Sprünge, %d Bilder mit Schlagzoom (gewollt)" % [g, kf.mars.outcome,
			n / 30.0, am_zug, hier, schlag])
		if am_zug == 0:
			print("KAMERA992 %s: der Held kam nie an den Zug" % g)
			spruenge += 1
		spruenge += hier
		kf.queue_free()
		p.queue_free()
		await process_frame
	print("KAMERA992 %s" % ("0 Sprünge" if spruenge == 0 else "%d Sprünge" % spruenge))
	quit(1 if spruenge > 0 else 0)
