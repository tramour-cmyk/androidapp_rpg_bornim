extends SceneTree
# 1043 (Chef 12.11., 15:52, t278.33, MARS-Probekampf Wölfe, Klosterschüler, „Ausweichen“ erzwungen: „davon hab ich nix gesehen. Da weicht
# nichts“): wie aus dem Reiter Test (Wölfe, Klosterschüler, Ausweichen erzwingen). Messung: wann die Regel das Ausweichen verbraucht,
# wann der Held es zeigt, mit welcher Bewegung, wie weit Fuß und Kopf dabei wandern (m, Bildpunkte). Am Rechner ohne Kaufheld nur die
# Zeiten; Bewegung und Weg erst auf dem Bauserver (Kaufheld). Aufruf im Ordner godot:
# --headless -s res://tests/ausweichen_1043.gd   (HERKUNFT=…; FILM=1: Zeit 1:1 für --write-movie)

func _initialize() -> void: _lauf.call_deferred()


func _lauf() -> void:
	var Mars = load("res://regeln/mars.gd")
	Engine.time_scale = 1.0 if OS.get_environment("FILM") != "" else 4.0
	var herkunft := OS.get_environment("HERKUNFT") if OS.get_environment("HERKUNFT") != "" else "Klosterschüler"
	Testmodus.probe_zug = ""; Testmodus.probe_ausweichen = true
	Mars.test_erzwungen.clear()
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.test_tat("probe", ["WOLVES", herkunft, 3])
	var t0 := Time.get_ticks_msec()
	while (spiel.kampf == null or spiel.kampf.mars == null) and Time.get_ticks_msec() - t0 < 15000: await process_frame
	var k = spiel.kampf
	if k == null:
		print("AUSWEICHEN1043 kein Kampf"); quit(1); return
	var held = k.figures.get("hero")
	print("Held %s, Schild %s, Bewegungen mit „Ausweichen“: %s" % [herkunft, held.blockt(), str(Array(held.anim.get_animation_list()).filter(func(n): return String(n).contains("Ausweich"))) if held.anim else "keine"])
	k.mars.set_autopilot(true)
	if not k.busy: k.go_on()
	var letzte := ""
	var zaehler := "0/0"
	var erzwungen_ms := -1.0
	var mess = null     # [Beginn ms, Fuß, Kopf am Schirm, weitester Fuß m, weitester Kopf px, Bewegungen]
	var befunde := []
	var ausweich_film := 0
	t0 = Time.get_ticks_msec()
	# Lauf 404: im Film nach Bildern statt Uhrzeit; --write-movie lief mit 9 % der Echtzeit, 300 s Uhr waren 32 s Film, der Held
	# wurde (Seed 7, erste Runde alle auf den Söldner) erst bei 18,8 s Kampfzeit angegriffen
	var f0 := Engine.get_process_frames()
	while (Engine.get_process_frames() - f0 < 30 * 120) if OS.get_environment("FILM") != "" else (Time.get_ticks_msec() - t0 < 90000):
		await process_frame
		if k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty():
			break
		if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
			# 1029: der Söldner „selbst“ bekommt einen Befehl; go_on allein hielt sofort wieder bei ihm, kein Wolf kam zum Zug (Lauf 396)
			k.mars.set_autopilot(true)
			if k.mars.pilot_next(): k.go_on()
			else:
				var ts: Array = k.mars.targets(k.mars.current())
				k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		if erzwungen_ms < 0.0 and Mars.test_erzwungen.has("ausweichen"):
			erzwungen_ms = k.clock_ms
			print("%.2f s Regel: Ausweichen verbraucht" % (k.clock_ms / 1000.0))
		# 1076 (Chef 12.11., 20:42: Film nur der Prüfgegenstand, etwa dreimal, bis 15 s): im Film dreimal erzwungen, die Regel setzt
		# test_ausweichen nach jedem Mal zurück (mars.gd 1847)
		if OS.get_environment("FILM") != "" and not k.mars.test_ausweichen and Mars.test_erzwungen.count("ausweichen") < 3:
			k.mars.test_ausweichen = true
		var kopf: Vector2 = k.screen_of(held.head())
		var zz := "%d/%d" % [held.ausweich_nr, held.abwehr_nr]
		if zz != zaehler:
			print("%.2f s Held Ausweichen/Abwehr %s; Bericht: %s" % [k.clock_ms / 1000.0, zz, str(k.ui.lines.back()) if not k.ui.lines.is_empty() else ""])
			if zz.get_slice("/", 0) != zaehler.get_slice("/", 0):
				# Filmzeit für den Schnitt in godot.yml (--fixed-fps 30: ein Bild je Durchlauf)
				print("SCHNITT1043 %.2f" % (Engine.get_process_frames() / 30.0))
				ausweich_film += 1
			zaehler = zz
			mess = [k.clock_ms, held.position, kopf, 0.0, 0.0, []]
		var a := String(held.anim.current_animation) if held.anim else ""
		if a != letzte:
			print("%.2f s Held: %s" % [k.clock_ms / 1000.0, a])
			letzte = a
			if mess != null and not mess[5].has(a): mess[5].append(a)
		if mess != null:
			mess[3] = maxf(mess[3], (held.position - mess[1]).length())
			mess[4] = maxf(mess[4], (kopf - mess[2]).length())
			if k.clock_ms - mess[0] > 1500.0:
				var b := "ab %.2f s: Fuß bis %.2f m, Kopf bis %.0f px, Bewegungen %s" % [mess[0] / 1000.0, mess[3], mess[4], str(mess[5])]
				print("Ausweichen " + b)
				befunde.append(b)
				mess = null
		if erzwungen_ms >= 0.0 and mess == null and not befunde.is_empty() and OS.get_environment("FILM") == "":
			break
		if ausweich_film >= 3 and mess == null:     # 1076: nach dem dritten Ausweichen ist der Film zu Ende
			break
	print("AUSWEICHEN1043 erzwungen %s; %s" % ["ja" if erzwungen_ms >= 0.0 else "nein", "; ".join(befunde) if not befunde.is_empty() else "kein Ausweichen gezeigt"])
	quit(0)
