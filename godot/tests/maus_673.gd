extends SceneTree
# 673 A (Chef 08.11., 15:39 „673 ja“): am Rechner zoomt das Mausrad, rechte Maustaste ziehen dreht die Kamera; über dasselbe Signal
# wie zwei Finger (steuerung.gd kneifen), Grenzen der Kamera bleiben (NAH bis WEIT). Linke Taste und Bewegung ohne rechte Taste tun
# nichts (auf dem Handy erzeugt Touch höchstens die linke Taste). Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/maus_673.gd

var fehler := 0
var signale: Array = []

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func taste(knopf: MouseButton, unten: bool) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = knopf
	e.pressed = unten
	return e

func zug(dx: float, maske: int) -> InputEventMouseMotion:
	var e := InputEventMouseMotion.new()
	e.relative = Vector2(dx, 0)
	e.button_mask = maske
	return e

func _lauf() -> void:
	var s = load("res://skripte/steuerung.gd").new()
	s.kneifen.connect(func(f, w): signale.append([f, w]))
	var k := Kamera.new()
	root.add_child(k)
	var z0: float = k.zoom
	# Rad hinein: Faktor unter 1, Kamera naeher (wie Finger auseinander)
	pruefe(s._maus(taste(MOUSE_BUTTON_WHEEL_UP, true)), "Rad hoch wird verbraucht")
	pruefe(signale.size() == 1 and signale[0][0] < 1.0 and signale[0][1] == 0.0, "Rad hoch zoomt hinein, dreht nicht (%s)" % [signale])
	k.kneifen(signale[0][0])
	pruefe(k.zoom <= z0, "Kamera näher oder an der Grenze NAH (%.2f -> %.2f)" % [z0, k.zoom])
	signale.clear()
	s._maus(taste(MOUSE_BUTTON_WHEEL_DOWN, true))
	pruefe(signale.size() == 1 and signale[0][0] > 1.0, "Rad runter zoomt hinaus (%s)" % [signale])
	for i in 60: k.kneifen(signale[0][0])
	pruefe(is_equal_approx(k.zoom, Kamera.WEIT), "hinaus höchstens bis WEIT (%.2f)" % k.zoom)
	signale.clear()
	# rechte Taste ziehen dreht
	s._maus(taste(MOUSE_BUTTON_RIGHT, true))
	pruefe(s._maus(zug(50.0, MOUSE_BUTTON_MASK_RIGHT)), "Ziehen mit rechter Taste wird verbraucht")
	pruefe(signale.size() == 1 and signale[0][0] == 1.0 and absf(signale[0][1] - 20.0) < 0.01, "50 px nach rechts drehen 20 Grad, kein Zoom (%s)" % [signale])
	s._maus(taste(MOUSE_BUTTON_RIGHT, false))
	signale.clear()
	pruefe(not s._maus(zug(50.0, 0)), "nach dem Loslassen: Bewegung wird nicht verbraucht")
	pruefe(not s._maus(taste(MOUSE_BUTTON_LEFT, true)) and not s._maus(taste(MOUSE_BUTTON_LEFT, false)), "linke Taste bleibt beim Joystick und Tippen")
	pruefe(signale.is_empty(), "ohne rechte Taste kein Zoom, keine Drehung (%s)" % [signale])
	s.free()
	print("MAUS673 %s" % ("alles gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler else 0)
