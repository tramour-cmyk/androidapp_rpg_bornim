extends SceneTree
# 1285 (Chef 15.11., 12:09, Build 286, Hoehle: „immer im Sprint … große Schritte … ganz kleine Joystick-Bewegungen“) ohne Bild: echte
# Kette Finger -> Steuerung (Ring) -> Kamera.richtung -> Held (Tempo, Gehen/Rennen) wie spiel.gd, je Ausschlag in dp. Aufruf: im
# Ordner godot mit -s res://tests/joystick_1285.gd

var fehler := 0

func _initialize() -> void: _lauf.call_deferred()

func ereignis(ui: Steuerung, p: Vector2, an: bool, zug: bool) -> void:
	var e: InputEvent
	if zug:
		var d := InputEventScreenDrag.new(); d.position = p; d.index = 0; e = d
	else:
		var t := InputEventScreenTouch.new(); t.position = p; t.pressed = an; t.index = 0; e = t
	ui._unhandled_input(e)

func spieler() -> AnimationPlayer:
	var lib := AnimationLibrary.new()
	for n in ["Stehen", "Gehen", "Rennen"]:
		var a := Animation.new(); a.length = 1.0; a.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation(n, a)
	var ap := AnimationPlayer.new()
	ap.add_animation_library("", lib)
	return ap

# ein Zug: Finger auf, in 0,2 s auf dp Ausschlag, 2 s halten; Rueckgabe Tempo m/s, Bewegung, Ring an
func zug(karte_id: String, dp: float, schnell: float) -> Array:
	var k := Karte.lade(karte_id)
	var h := Held.new(k)
	var start := Vector2i(-1, -1)
	for y in k.hoehe:
		for x in k.breite:
			if start.x >= 0: break
			var ok := true
			for i in 12:
				if not h.frei(Vector3((x + i + 0.5) * Karte.TS, 0, (y + 0.5) * Karte.TS)): ok = false; break
			if ok: start = Vector2i(x, y)
	h.setze(start, "RIGHT")
	h.anim = spieler(); root.add_child(h.anim); h.anim.play("Stehen")
	h.renn = 2.0; h.gang = 1.0
	Held.schnell = schnell
	var ui := Steuerung.new()
	root.add_child(ui)
	await process_frame
	ui.richte_ein()
	var will := [false]
	ui.laufen.connect(func(an): will[0] = an)
	ui.joystick.connect(func(v): h.richtung = Vector3(v.x, 0, v.y).normalized() * minf(1.0, v.length()) if v.length() > 0.0 else Vector3.ZERO)
	var z := Zustand.new()
	var hw := Testmodus.probeheld("Wachsoldat", 1)
	var ring := false
	var o := Vector2(540, 1600)
	ereignis(ui, o, true, false)
	var dt := 1.0 / 30.0
	var max_t := 0.0; var bew := ""
	for i in 66:
		var f := minf(1.0, float(i + 1) / 6.0)
		ereignis(ui, o + Vector2(dp * AktionsKnopf.DP * f, 0), true, true)
		h.laeuft = Ausdauer.schritt(z, hw, dt * 1000.0, h.geht(), will[0])
		h._process(dt)
		ring = ring or will[0]
		# 1421: bei „Schnell“ und Rennen (12 m/s) erreicht er vor dem Ende die Wand; die Bewegung zählt, solange er läuft
		if i > 30 and h.tempo_jetzt > 0.0: max_t = maxf(max_t, h.tempo_jetzt); bew = String(h.anim.current_animation)
	ereignis(ui, o, false, false)
	ui.free(); h.anim.free(); h.free()
	Held.schnell = 1.0
	return [max_t, bew, ring]

func _lauf() -> void:
	Bedienung.lade()
	var vorher := [Bedienung.ring, Bedienung.lauf_taste]
	Bedienung.ring = 1; Bedienung.lauf_taste = false
	# im Ring (94 dp) gehen, darueber rennen; mit „Schnell“ (555) dasselbe Gangbild, nur dreifach so schnell
	for karte_id in ["cave", "village"]:
		for s in [1.0, 3.0]:
			for dp in [20.0, 55.0, 90.0, 100.0, 130.0]:
				var r: Array = await zug(karte_id, dp, s)
				print("1285 %s schnell %.0f: Ausschlag %3.0f dp (%.2f cm) -> %.2f m/s, %s, Ring %s" % [karte_id, s, dp, dp / 160.0 * 2.54, r[0], r[1], r[2]])
				var soll := "Rennen" if dp > 94.0 else "Gehen"
				if r[1] != soll or r[2] != (dp > 94.0):
					fehler += 1; print("FEHLER %s schnell %.0f, %.0f dp: %s statt %s" % [karte_id, s, dp, r[1], soll])
	# 1421 (Chef 16.11., 12:48, „Rennen B“): mit eingeschalteter Renntaste (aus) rennt er auch weit ausgeschlagen nicht; zwei feste
	# Tempi: jeder Ausschlag im Ring gibt dasselbe Gehtempo
	Bedienung.lauf_taste = true
	for dp in [55.0, 130.0]:
		var r: Array = await zug("village", dp, 1.0)
		print("1421 Renntaste aus: Ausschlag %3.0f dp -> %.2f m/s, %s, Ring %s" % [dp, r[0], r[1], r[2]])
		if r[1] != "Gehen" or r[2]:
			fehler += 1; print("FEHLER 1421 Renntaste aus, %.0f dp: %s, Ring %s statt Gehen ohne Ring" % [dp, r[1], r[2]])
	Bedienung.lauf_taste = false
	var t20: Array = await zug("village", 20.0, 1.0)
	var t90: Array = await zug("village", 90.0, 1.0)
	if absf(float(t20[0]) - float(t90[0])) > 0.05:
		fehler += 1; print("FEHLER 1421 Gehtempo hängt am Ausschlag: 20 dp %.2f m/s, 90 dp %.2f m/s" % [t20[0], t90[0]])
	Bedienung.ring = vorher[0]; Bedienung.lauf_taste = vorher[1]
	print("ok Joystick 1285" if fehler == 0 else "FEHLER Joystick 1285: %d" % fehler)
	quit(1 if fehler else 0)
