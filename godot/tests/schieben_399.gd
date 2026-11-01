extends SceneTree
# 348.6 (Test 139.7, Chef 28.10., 21:3x: „139.7 funktioniert nicht“, zum zweiten Mal nach 133.7): ohne Bild; der Held drueckt mit dem
# Joystick gegen einen Dorfbewohner, der weicht (keine Wache auf Runde): nach einer halben Sekunde tritt er zur Seite und der Weg ist frei.
# Neun Versuche, der Joystick bis 30 Grad neben der Linie zu ihm (die Kamera blickt schraeg). Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/schieben_399.gd

# bis 15 Grad neben ihm bleibt der Held vor ihm stehen und er tritt zur Seite; ab 30 Grad geht der Held an ihm vorbei (frei)
const WINKEL := [0.0, 15.0, -15.0, 10.0, -10.0, 5.0, 30.0, -30.0, -5.0]

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var versuche := 0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	var k: Karte = spiel.karte
	Leute.uhr = func(): return 10 * 60   # vormittags: alle draussen
	for l in spiel.leute.get_children() + spiel.leute.get_children() + spiel.leute.get_children():   # dreimal, je mit anderem Winkel
		if not (l is Leute) or not l.weicht() or versuche >= 9: continue
		await process_frame
		var je := 0
		for i in 120: await process_frame   # er steht wieder
		for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			var von := Vector2i.ZERO
			var p: Vector2i = l.kachel
			von = p + d
			if je >= 1 or not k.begehbar(von) or not k.begehbar(von + d): continue
			if spiel.leute.get_children().any(func(x): return x is Leute and x != l and (x.kachel == von or x.ziel == von)): continue
			l.ziel = Vector2i(-1, -1); l.warte = 3.0   # er steht, mitten auf seiner Kachel
			var kp: Vector3 = k.kachel_pos(p)
			l.position = Vector3(kp.x, l.position.y, kp.z)
			spiel.held.setze(von, "DOWN")
			for i in 3: await process_frame
			# wie am Handy: die Kamera blickt schraeg (Kamera.NORD 45 Grad), der Joystick zeigt selten genau entlang der Kacheln
			var r := Vector3(-d.x, 0, -d.y).rotated(Vector3.UP, deg_to_rad(WINKEL[versuche % WINKEL.size()]))
			spiel.held.richtung = r
			var t0 := Time.get_ticks_msec()
			var weg := false
			while Time.get_ticks_msec() - t0 < 2500:
				await process_frame
				spiel.held.richtung = r
				if l.kachel != p or (l.ziel != Vector2i(-1, -1) and l.ziel != p): weg = true; break
			spiel.held.richtung = Vector3.ZERO
			var vorbei: bool = absf(WINKEL[versuche % WINKEL.size()]) > 20.0 and (spiel.held.kachel - von).length() >= 2.0
			if vorbei: weg = true
			versuche += 1
			print("%s auf %s, Held von %s: %s nach %d ms (Held auf %s)" % [l.daten.get("id", "?"), p, von, ("vorbei" if vorbei else "weicht") if weg else "BLEIBT", Time.get_ticks_msec() - t0, spiel.held.kachel])
			if not weg:
				fehler += 1
				var hp: Vector3 = spiel.held.position + r * 0.38
				print("  vor dem Helden begehbar ", k.begehbar(k.pos_kachel(hp)), "; sperren: ", spiel.held.leute.filter(func(x): return is_instance_valid(x) and x.sperrt(hp)).map(func(x): return [x.daten.get("id"), x.position, x.leib]))
				print("  frei um ihn: ", [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)].map(func(s): return [p + s, l.frei_fuer_mich(p + s)]))
			break
	if versuche == 0: fehler += 1; print("FEHLER niemand zum Schieben")
	print("SCHIEBEN %d Fehler bei %d Versuchen" % [fehler, versuche])
	quit(1 if fehler else 0)
