extends SceneTree
# 495 (Lauf 259, Zufallsspieler Saat 4): zweimal der Knopf an einer Tuer waehrend der Blende; der zweite Weg hinaus fand die Karte schon
# gewechselt und setzte den Helden im Haus des Aeltesten auf (5, 21), ausserhalb des Grundrisses. Ohne Bild: an jeder Tuer des Dorfs
# zu einem Grundriss und zurueck zweimal geh_hinaus ohne zu warten; danach steht der Held auf einer begehbaren Kachel der Zielkarte.
# Braucht godot/daten wie im Bau (ohne Grundrisse bleibt der Held im Dorf, der Test prueft dann nur das Dorf).
# Aufruf: im Ordner godot mit -s res://tests/tuer_495.gd -> „TUER495 n Fehler“

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	for ziel in ["elder", "inn", "shop", "temple"]:
		spiel.betrete("village", Vector2i(1, 1), "DOWN")
		for i in 5: await process_frame
		var hin: Dictionary = {}
		for t in spiel.karte.ausgaenge:
			var a: Dictionary = spiel.karte.ausgang(t)
			if String(a["ziel"]["karte"]) == ziel: hin = a
		if hin.is_empty(): print("FEHLER village: keine Tuer nach %s" % ziel); fehler += 1; continue
		for richtung in ["hin", "zurueck"]:
			var a: Dictionary = hin
			if richtung == "zurueck":
				if spiel.karte.id == "village": break   # ohne Grundriss (am Rechner) blieb der Held im Dorf
				a = {}
				for t in spiel.karte.ausgaenge:
					var r: Dictionary = spiel.karte.ausgang(t)
					if String(r["ziel"]["karte"]) == "village": a = r
				if a.is_empty(): break   # ohne Grundriss (am Rechner) blieb der Held im Dorf
			var von: String = spiel.karte.id
			spiel.geh_hinaus(a)   # ein Spieler tippt zweimal
			for i in 3: await process_frame
			await spiel.geh_hinaus(a)
			for i in 240:
				if not spiel.geht_hinaus: break
				await process_frame
			for i in 30: await process_frame   # Ortsworte, Blende
			var k: Karte = spiel.karte
			var h: Vector2i = spiel.held.kachel
			var drin: bool = h.x >= 0 and h.y >= 0 and h.x < k.breite and h.y < k.hoehe and k.begehbar(h)
			print("%s -> %s (%s): Karte %s, Held %s %s" % [von, String(a["ziel"]["karte"]), richtung, k.id, h, "" if drin else "FEHLER ausserhalb"])
			if not drin: fehler += 1
	print("TUER495 %d Fehler" % fehler)
	quit(1 if fehler else 0)
