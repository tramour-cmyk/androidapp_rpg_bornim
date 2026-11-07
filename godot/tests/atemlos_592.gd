extends SceneTree
# 592 ohne Bild („592 so“, Chef 05.11., 22:0x): wird der Held atemlos, steht er etwa 1 s (Haende auf den Knien, Stehen_3) und geht
# danach steuerbar weiter; nur beim Uebergang, nicht jedes Bild neu. Aufruf: im Ordner godot mit -s res://tests/atemlos_592.gd

func _initialize() -> void: _lauf.call_deferred()

func spieler(lib: AnimationLibrary) -> AnimationPlayer:
	var ap := AnimationPlayer.new()
	ap.add_animation_library("", lib)
	return ap

func _lauf() -> void:
	var fehler := 0
	var k := Karte.lade("village")
	var h := Held.new(k)
	h.setze(Vector2i(19, 13), "RIGHT")
	var lib := AnimationLibrary.new()
	for n in ["Stehen", "Stehen_2", "Stehen_3"]:
		var a := Animation.new()
		a.length = 2.5
		lib.add_animation(n, a)
	h.anim = spieler(lib)
	h.atemlos_neu(true)
	if absf(h.atem_halt_bis - (h.zeit + Held.ATEM_HALT)) > 0.001: fehler += 1; print("FEHLER kein Halt: ", h.atem_halt_bis)
	var bis := h.atem_halt_bis
	h.zeit += 0.5
	h.atemlos_neu(true)
	if h.atem_halt_bis != bis: fehler += 1; print("FEHLER Halt neu begonnen")
	h.zeit -= 0.5
	# ohne Bewegungen weiter (das Modell fehlt am Rechner): im Halt bewegt er sich nicht, danach schon
	h.anim.free()
	h.anim = null
	var p0 := h.position
	h.richtung = Vector3(1, 0, 0)
	for i in 25: h._process(1.0 / 30.0)   # bis 0,83 s
	if h.position.distance_to(p0) > 0.001: fehler += 1; print("FEHLER bewegt sich im Halt: ", h.position.distance_to(p0))
	for i in 20: h._process(1.0 / 30.0)
	if h.position.distance_to(p0) < 0.1: fehler += 1; print("FEHLER geht nach dem Halt nicht weiter")
	print("Atemlos 592: Halt %.1f s, danach %.2f m gegangen" % [Held.ATEM_HALT, h.position.distance_to(p0)])
	# wieder bei Atem und erneut leer: neuer Halt
	h.atemlos_neu(false)
	h.anim = spieler(lib)
	h.atemlos_neu(true)
	if h.atem_halt_bis <= h.zeit: fehler += 1; print("FEHLER zweites Mal kein Halt")
	h.anim.free()
	h.free()
	print("ok Atemlos 592" if fehler == 0 else "FEHLER Atemlos 592: %d" % fehler)
	quit(1 if fehler else 0)
