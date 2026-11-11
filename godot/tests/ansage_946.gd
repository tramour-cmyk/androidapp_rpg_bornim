# 946 (Chef 11.11., 13:29, Bild aus t276): „! Anspringen“ des dritten Wolfs lag oben unter der Zugleiste (nur „!ger“ sichtbar).
# Messung ohne Bild: Wolfsrudel mit Rand oben wie am Handy (Kamera, Rand.test_oben) und mit großer Schrift des Handys; in jedem Bild
# liegt jede Ansage ganz unter der Zugleiste und ganz in der Szene.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/ansage_946.gd   (GEGNER=WOLVES, SEEDS=1-4)
# Exit 0 = kein Befund.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var gegner := OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES"
	var bis := int(OS.get_environment("SEEDS")) if OS.get_environment("SEEDS") != "" else 4
	var befunde := 0
	var gesehen := 0
	# Rand oben (Kamera) und Schriftgröße des Handys: ohne, mit Rand, mit Rand und großer Schrift
	for fall in [[0.0, 1.0], [110.0, 1.0], [110.0, 1.3]]:
		Rand.test_oben = fall[0]
		Stil.schriftfaktor = fall[1]
		for s in range(1, bis + 1):
			seed(s)
			var p = Probe.new()
			p.hero_cls = "FIGHTER"
			p.merc_cls = "CLERIC"
			p.foe = gegner
			root.add_child(p)
			await process_frame
			p._start(s)
			for i in 4:
				await process_frame
			var kf = p.fight
			var ui = kf.ui
			var m = kf.mars
			m.find("merc").auto = true
			if m.set_autopilot(true) and not kf.busy:
				kf.go_on()
			var falsch := 0
			var erst := ""
			for i in 30 * 90:
				await process_frame
				if m.outcome != "ONGOING" and not kf.busy:
					break
				var sr: Rect2 = kf.scene_rect()
				var unten: float = ui.get("turns_unten") if ui.get("turns_unten") != null else ui.turns_top + ui.sp(13) * 1.35 + 4 * ui.dp
				for r in ui.sign_rects:
					gesehen += 1
					if r.position.y < unten - 0.5 or r.end.y > sr.size.y + 0.5:
						falsch += 1
						if erst == "":
							erst = "bei %.1f s: Ansage oben %.0f, Zugleiste unten %.0f, Szene %.0f" % [i / 30.0, r.position.y, unten, sr.size.y]
			if falsch > 0:
				befunde += 1
			print("  Rand %.0f, Schrift %.1f, Seed %d: %d Bilder mit Ansage unter der Zugleiste oder außerhalb %s" % [fall[0], fall[1], s, falsch, erst])
			p.queue_free()
			for i in 5:
				await process_frame
	Rand.test_oben = -1.0
	Stil.schriftfaktor = 1.0
	if gesehen == 0:
		print("  keine Ansage gemessen")
		befunde += 1
	print("ANSAGE946 %d" % befunde)
	quit(1 if befunde > 0 else 0)
