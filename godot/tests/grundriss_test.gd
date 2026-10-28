extends SceneTree
# 399.1 ohne Bild: aus dem Dorf durch jede Tuer eines Grundrisses (Schenke, Laden, Aeltester, Tempel) hinein und durch dessen Ausgang
# zurueck; geprueft: Karte gewechselt, Held auf begehbarem Feld, Licht innen, zurueck im Dorf vor der Tuer. Braucht godot/daten wie im Bau.
# Godot bricht headless beim Beenden ab, sobald das Dorf geladen war (399.1); massgeblich ist die Zeile GRUNDRISS.
# Aufruf: im Ordner godot mit -s res://tests/grundriss_test.gd

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	for id in ["inn", "shop", "elder", "temple"]:
		var tuer: Dictionary = {}
		for a in spiel.karte.daten.get("ausgaenge", []):
			if String(a["ziel"]["karte"]) == id: tuer = a; break
		if tuer.is_empty(): print("FEHLER keine Tuer nach %s" % id); fehler += 1; continue
		await spiel.geh_hinaus(tuer)
		for i in 5: await process_frame
		var drin: bool = spiel.karte.id == id
		var frei: bool = spiel.karte.begehbar(spiel.held.kachel)
		print("%s: drin %s, Held %s begehbar %s, Licht innen %s, Leute %d" % [id, drin, spiel.held.kachel, frei, spiel.licht.innen, spiel.leute.get_child_count()])
		if not drin or not frei or not spiel.licht.innen: fehler += 1; print("FEHLER hinein %s" % id)
		var raus: Dictionary = spiel.karte.daten.get("ausgaenge", [{}])[0]
		await spiel.geh_hinaus(raus)
		for i in 5: await process_frame
		print("  zurueck: %s auf %s, Licht innen %s" % [spiel.karte.id, spiel.held.kachel, spiel.licht.innen])
		if spiel.karte.id != "village" or spiel.licht.innen: fehler += 1; print("FEHLER hinaus %s" % id)
	print("GRUNDRISS %d Fehler" % fehler)
	quit(1 if fehler else 0)
