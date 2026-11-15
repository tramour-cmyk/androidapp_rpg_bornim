extends SceneTree
# 416.2 (Chef 02.11., 10:52, Build 146, 146.5: „Ziege wird geschoben, kein Platztausch“): ohne Bild. Die Ziege im Dorf suedlich
# des Flusses, der Held haelt von jeder Seite gegen sie; gemessen: kommt er binnen 6 s an ihr vorbei, wie oft tritt sie, tauscht sie.
# Aufruf: im Ordner godot mit -s res://tests/ziege_4162.gd -> „ZIEGE n Fehler“

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.betrete("village", Vector2i(30, 25), "DOWN")
	for i in 5: await process_frame
	var k: Karte = spiel.karte
	var z: Leute = null
	for l in spiel.leute_liste():
		if String(l.daten.get("tier", "")) == "ziege" or String(l.daten.get("id", "")).begins_with("ziege"): z = l
	if z == null:
		# am Rechner ohne gekaufte Tiermodelle (daten/dorftiere): eine Ziege wie Leute.dorftiere, Leib wie Laenge 1 m
		var p: Array = Leute.DORFTIERE["village"][0]
		z = Leute.new(k, {"id": "ziege1", "x": p[1], "y": p[2], "blick": "DOWN", "streifen": 2, "tier": "ziege"}, spiel.held)
		spiel.leute.add_child(z)
		z.leib = 0.65
		spiel.held.leute = spiel.leute.get_children()
		print("Ziege selbst gestellt (ohne Modell)")
	Leute.still = false
	var start := z.kachel
	print("Ziege auf ", start, " Daten ", z.daten)
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var h: Vector2i = start - d
		if not (k.begehbar(h) and k.begehbar(start + d)): print("Seite ", d, ": Held- oder Zielkachel zu"); continue
		z.ziel = Vector2i(-1, -1); z.warte = 30.0; z.durch_bis = 0
		z.kachel = start; z.position = k.kachel_pos(start)
		spiel.held.setze(h, "DOWN")
		spiel.held.richtung = Vector3(d.x, 0, d.y)
		var tritte := []; var vorbei := -1.0
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 6000:
			await process_frame
			if z.ziel.x >= 0 and (tritte.is_empty() or tritte[-1][1] != z.ziel):
				tritte.append([z.kachel, z.ziel, z.durch_bis > Time.get_ticks_msec()])
			var hk := k.pos_kachel(spiel.held.position)
			if vorbei < 0 and (hk - start) == d: vorbei = (Time.get_ticks_msec() - t0) / 1000.0
		spiel.held.richtung = Vector3.ZERO
		print("Seite ", d, ": Held ", h, " -> ", k.pos_kachel(spiel.held.position), ", vorbei nach ", vorbei, " s; Schritte der Ziege [von, nach, Tausch]: ", tritte)
		pruefe(vorbei >= 0, "von %s kommt der Held an der Ziege vorbei" % [d])
		pruefe(not tritte.is_empty() and tritte[0][1] == h and tritte[0][2], "von %s tauscht die Ziege mit dem Helden den Platz" % [d])
		await create_timer(0.5).timeout
	print("ZIEGE %d Fehler" % fehler)
	quit(1 if fehler else 0)
