extends SceneTree
# 1145 Messung (nicht im Pruefsatz): Nebel neu rechnen je Stelle (jede zweite begehbare Kachel, zwei Blickrichtungen) in Hoehle,
# Wald, Dorf, Tiefwald; Zeit je Rechnung und Pruefsumme der Nebelteile (gleiche Summe = gleiches Bild wie vorher).
# Lauf 16.11. am Rechner, alt gegen neu gleiche Summen, Median Hoehle 62 -> 4,5 ms, Wald 10,5 -> 5,1, Dorf 13 -> 6,5, Tiefwald 17 -> 7
func _initialize() -> void: _lauf.call_deferred()
func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	for ort in [["cave", Vector2i(10, 18)], ["forest", Vector2i(10, 1)], ["village", Vector2i(9, 26)], ["deep_forest", Vector2i(5, 5)]]:
		spiel.betrete(ort[0], ort[1], "UP")
		for i in 20: await process_frame
		if spiel.herde: spiel.herde.aus = true
		var nb = spiel.nebel
		var h = spiel.held
		h.set_process(false)
		var summe := 0
		var n := 0
		var t := []
		for y in range(0, nb.hoehe, 2):
			for x in range(0, nb.breite, 2):
				if not spiel.karte.begehbar(Vector2i(x, y)): continue
				for a in [0.0, 2.3]:
					h.kachel = Vector2i(x, y)
					h.rotation.y = a
					nb.schluessel = ""
					var t0 := Time.get_ticks_usec()
					nb.schritt(0.016)
					t.append(Time.get_ticks_usec() - t0)
					summe = hash([summe, nb.soll, nb.erkundet])
					n += 1
		t.sort()
		print("NEBEL1145 ", ort[0], " Stellen ", n, " soll ", summe, " us median ", t[t.size() / 2], " max ", t[-1])
	quit(0)
