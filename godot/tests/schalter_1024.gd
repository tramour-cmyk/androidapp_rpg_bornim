# 1024 (Chef 12.11., 09:04, Bild Wolfskampf Build 278: „Das scheint mir meine Anzeige etwas zu überdecken. Da stimmt was nicht.“;
# Schalterreihe rechts halb vom unteren Kasten verdeckt): Wölfe auf Autopilot durch den echten Kampfort; in jedem Bild darf kein
# Schalter (Raster, Würfel, Tempo, Kreuz, Haken) unter die Oberkante des Kastens reichen, wie er gerade steht; der Kasten wächst
# im ersten Zug um WACHSEN_PX (vorher: 445 von 2097 Bildern 150 px darunter). Der Held wartet je Zug 1,5 s auf ein Tippen (AUTO=1: Autopilot).
# Run: godot --headless --path godot -s res://tests/schalter_1024.gd   (GEGNER=…, SEEDS=…; Exit 0 = nie verdeckt)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const LIMIT_MS := 60000
const WACHSEN_PX := 150.0


func _initialize() -> void:
	root.content_scale_size = Vector2i(1080, 2340)     # wie das Handy des Chefs
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP     # headless ist das Fenster 64 × 64; so bleibt die Fläche 1080 × 2340
	Engine.time_scale = 10.0
	_all.call_deferred()


func _all() -> void:
	var failed := 0
	var n := 0
	var gegner := (OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES,RATS").split(",")
	var seeds := (OS.get_environment("SEEDS") if OS.get_environment("SEEDS") != "" else "1,2,3").split(",")
	for foe in gegner:
		for s in seeds:
			n += 1
			var r: Array = await _one(foe, int(s))
			print(("gut " if r[0] == 0 else "FALSCH ") + "%s Seed %s: %d von %d Bildern ein Schalter unter dem Kasten oder eine Ansage auf der Bildrate-Zeile, tiefster Schalter %.0f px%s" % [foe, s, r[0], r[1], r[2], r[3]])
			if r[0] > 0:
				failed += 1
	print("SCHALTER1024 %d Kämpfe, %d mit verdeckten Schaltern" % [n, failed])
	quit(1 if failed > 0 else 0)


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
	# wie der Chef: der Held wartet auf ein Tippen (Kasten mit den Knöpfen des Zugs), nach 1,5 s Spielzeit greift er an
	var hand := OS.get_environment("AUTO") == ""
	if not hand:
		k.mars.set_autopilot(true)
	if not k.busy:
		k.go_on()
	var dran_seit := -1.0
	var gewachsen := false
	var ui = k.ui
	# Bildrate-Zeile des Testmodus wie spiel.gd _kampf_messe (24 px vom Rand, 30 % der Höhe, zwei Zeilen): keine Ansage darauf
	var zeile := Rect2(24, 2340 * 0.30, 1080 - 48, 2 * 14 * 2.62 * 1.4)
	ui.set("frei_halten", [zeile])     # vor 1024 gab es das Feld nicht (dann ohne Wirkung)
	var auf_zeile := 0
	var t0 := Time.get_ticks_msec()
	var bad := 0
	var bilder := 0
	var tief := -INF
	var wo := ""
	while Time.get_ticks_msec() - t0 < LIMIT_MS:
		await process_frame
		if k.mars.outcome != "ONGOING":
			break
		if not k.busy and not k.playing and k.beats.is_empty():
			var c = k.mars.current()
			if hand and c != null and c.id == "hero":
				if dran_seit < 0.0:
					dran_seit = k.clock_ms
				elif k.clock_ms - dran_seit > 1500.0:
					var ts: Array = k.mars.targets(c)
					k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
					dran_seit = -1.0
			elif k.mars.pilot_next():
				k.go_on()
		# der Kasten wächst mitten in einem Zug (mehr Zeilen im Bericht, größere Schrift am Handy); panel_passt passt die Kamera dann
		# erst nach dem Zug neu (709), fitted_h bleibt so lange alt
		if not gewachsen and k.busy and k.zuege > 0:
			ui.panel.custom_minimum_size.y = ui.panel.size.y + WACHSEN_PX
			gewachsen = true
		var vs: Vector2 = ui.get_viewport().get_visible_rect().size
		var oben: float = ui.panel.get_global_rect().position.y
		bilder += 1
		var schlecht := false
		for nm in ["grid_rect", "dice_rect", "tempo_rect", "win_rect", "lose_rect"]:
			var r: Rect2 = ui.get(nm)
			if r.size == Vector2.ZERO:
				continue
			var ueber: float = r.end.y - oben
			if ueber > tief:
				tief = ueber
				wo = "; %s %s, Kasten oben %.0f px (gepasst %.0f, jetzt %.0f hoch), %.1f s" % [nm, r, oben, ui.fitted_h, ui.panel.size.y, k.clock_ms / 1000.0]
			if ueber > 1.0:
				schlecht = true
		for r in ui.sign_rects:
			if (r as Rect2).intersects(zeile):
				schlecht = true
				auf_zeile += 1
				break
		if schlecht:
			bad += 1
	p.queue_free()
	await process_frame
	return [bad, bilder, tief, wo + ("; Ansage auf der Bildrate-Zeile in %d Bildern" % auf_zeile)]
