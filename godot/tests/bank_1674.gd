extends SceneTree
# 1674 (Chef 18.11., 15:59, t299: „Erst hängt der Typ hier ewig an der Bank und kann nicht vorbeigehen … 2 Minuten zugucken, bevor
# ich ihn weggeschubst habe“; Bewohner im Kittel, Bank am Brunnen auf dem Dorfplatz): ohne Bild. Dorfplatz: Bank (14, 16), Brunnen
# (16, 16), Bank (21, 16). Eine Probeperson geht quer über den Platz, der Held steht still in der Enge zwischen Bank und Brunnen oder
# daneben, oder dort steht eine andere Person (diese Fälle gingen schon vorher schräg vorbei, sie sichern nur ab); geprüft: sie kommt in 25 s an (vorher: Umweg zur Nachbarkachel, von dort wieder durch
# den Helden, hin und her; vor einer stehenden Person wartete sie für immer). Die Leute des Dorfs sind je Fall vom Platz genommen.
# Aufruf im Ordner godot: --headless --fixed-fps 30 -s res://tests/bank_1674.gd -> „BANK1674 n Fehler“

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 12 * 60
	spiel.betrete("village", Vector2i(11, 7), "DOWN")
	for i in 10: await process_frame
	var k: Karte = spiel.karte
	var fehler := 0
	# [Start, Ziel, Held]
	for fall in [[Vector2i(15, 14), Vector2i(15, 19), Vector2i(15, 16)], [Vector2i(15, 19), Vector2i(15, 13), Vector2i(15, 16)],
			[Vector2i(12, 16), Vector2i(19, 16), Vector2i(15, 16)], [Vector2i(13, 15), Vector2i(13, 18), Vector2i(13, 16)],
			[Vector2i(14, 13), Vector2i(14, 19), Vector2i(14, 15)], [Vector2i(14, 19), Vector2i(14, 13), Vector2i(14, 17)],
			[Vector2i(15, 14), Vector2i(15, 19), Vector2i(10, 10), Vector2i(15, 16)], [Vector2i(12, 16), Vector2i(19, 16), Vector2i(10, 10), Vector2i(15, 15)]]:
		for l in spiel.leute.get_children(): l.free()   # tagesplan zeigt Versteckte wieder, Bram kam auf den Platz
		if fall.size() > 3:   # eine andere Person steht still in der Enge
			var b := Leute.new(k, {"id": "steht_1674", "x": fall[3].x, "y": fall[3].y, "streifen": 0}, spiel.held)
			spiel.leute.add_child(b)
			b.warte = 999.0
		var p := Leute.new(k, {"id": "probe_1674", "x": fall[0].x, "y": fall[0].y, "streifen": 0}, spiel.held)
		spiel.leute.add_child(p)
		spiel.held.position = k.kachel_pos(fall[2])
		spiel.held.richtung = Vector3.ZERO
		for i in 10: await process_frame
		p.warte = 0.0
		p.fort_nach = fall[1]
		var kacheln := {}
		var an := -1.0
		for f in 30 * 25:
			await process_frame
			kacheln[p.kachel] = int(kacheln.get(p.kachel, 0)) + 1
			if p.kachel == fall[1]:
				an = f / 30.0
				break
		var ok := an >= 0.0
		print(("gut " if ok else "FEHLER ") + "%s nach %s, Held auf %s: %s; Kacheln %d, zuletzt auf %s, Ziel %s, Weg %s" % [str(fall[0]), str(fall[1]),
			str(fall[2]), ("an nach %.1f s" % an) if ok else "nicht an in 25 s", kacheln.size(), str(p.kachel), str(p.ziel), str(p.weg.slice(0, 3))])
		if not ok: fehler += 1
	print("BANK1674 %d Fehler" % fehler)
	quit(1 if fehler else 0)
