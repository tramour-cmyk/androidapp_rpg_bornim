extends SceneTree
# 509 Film (unter 30 s): Frösche und Libellen am Teich im Flüsterwald, aus der Spielkamera bei Tag. Der Held steht gut 3 m vom
# ersten Frosch: Frösche sitzen und atmen, Libellen stehen und schießen über dem Wasser; dann geht er ans Ufer, der Frosch springt
# ins Wasser (Ringe); er geht zurück, der Frosch taucht auf, schwimmt und klettert hinaus. Mit --write-movie aufnehmen (godot.yml
# „Teichfilm 509“); MESS=1 ohne Bild: druckt je Abschnitt Lage des Froschs und ob Frosch und Libellen im Bild sind (G1).

var spiel
var frames := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _process(_dt: float) -> bool:
	frames += 1
	return false

func _warte(s: float) -> void:
	await create_timer(s).timeout

func _blick(v: Vector2) -> String:
	if absf(v.x) > absf(v.y): return "RIGHT" if v.x > 0 else "LEFT"
	return "DOWN" if v.y > 0 else "UP"

func _im_bild(p: Vector3) -> bool:
	var cam: Camera3D = root.get_viewport().get_camera_3d()
	if cam == null or cam.is_position_behind(p): return false
	var s := cam.unproject_position(p)
	var r := root.get_viewport().get_visible_rect().size
	return s.x > 8 and s.y > 8 and s.x < r.x - 8 and s.y < r.y - 8

func _mess(was: String, t: Teichleben, f: Dictionary) -> void:
	var lagen := ["sitzt", "springt", "unter", "taucht auf", "schwimmt", "klettert"]
	var fn: Node3D = f["n"]
	var lib := t.libellen.map(func(l): return _im_bild((l["n"] as Node3D).global_position))
	print("Teich 509 %s: Frosch %s, im Bild %s, Libellen im Bild %s, Held %s" % [was, lagen[int(f["lage"])], _im_bild(fn.global_position), lib, spiel.held.kachel])

func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.ui.mess.visible = false
	spiel.ui.oben.visible = false
	spiel.zustand.minuten = 10 * 60
	spiel.betrete("forest", Vector2i(9, 30), "UP")
	if spiel.herde: spiel.herde.aus = true
	await _warte(1.0)
	var t: Teichleben = spiel.gebiet.teich
	if t == null or t.froesche.is_empty():
		print("Teich 509 FEHLER: kein Teichleben im Wald (%s)" % ("kein Knoten" if t == null else "keine Frösche"))
		quit(1); return
	print("Teich 509: %d Frösche, %d Libellen" % [t.froesche.size(), t.libellen.size()])
	var f: Dictionary = t.froesche[0]
	var u: Vector2 = f["ufer"]; var wv: Vector2 = f["wasser"]
	var weg := (u - wv).normalized()
	var k: Karte = spiel.karte
	# Stand: gut 3 m vom Frosch landeinwärts, auf begehbarem Feld
	var start := Vector2i(-1, -1)
	for d in [3.2, 3.6, 2.8, 4.0, 2.4]:
		for dreh in [0.0, 0.4, -0.4, 0.8, -0.8]:
			var p := u + weg.rotated(dreh) * d
			var kt := k.pos_kachel(Vector3(p.x, 0, p.y))
			if k.begehbar(kt): start = kt; break
		if start.x >= 0: break
	if start.x < 0:
		print("Teich 509 FEHLER: kein Standplatz beim Frosch"); quit(1); return
	spiel.held.setze(start, _blick(-weg))
	spiel.kamera.springe()
	spiel.ui.textfeld.visible = false
	await _warte(6.0)
	_mess("Stand", t, f)
	# ans Ufer: der Frosch springt
	spiel.held.geh_zu(k.kachel_pos(k.pos_kachel(Vector3(u.x, 0, u.y))))   # aufs Feld des Froschs (Ufer, begehbar)
	await _warte(4.0)
	_mess("am Ufer", t, f)
	spiel.held.geh_zu(k.kachel_pos(start))
	await _warte(14.0)
	_mess("zurück", t, f)
	await _warte(4.0)
	_mess("Ende", t, f)
	print("Teich 509 Film fertig, %d Bilder" % frames)
	quit(0)
