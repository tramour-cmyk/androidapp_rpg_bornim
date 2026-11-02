extends SceneTree
# 399.1 (Test 139, Chef 28.10., 21:3x: „konnte nicht mehr in die Häuser rein, weil der Aktionsbutton gefehlt hat“): ohne Bild; neues Spiel
# (frischer Zustand), vor jede Tuer des Dorfs gestellt, Blick zur Tuer: der Knopf bietet ENTER an und ist zu sehen, in Wischen und Klassisch.
# Dazu liegen Aktions- und Renntaste nach jedem Aufbau der Bedienung ganz im Schirm (Ursache t139: Lage absolut statt vom Anker).
# Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/aktion_399.gd

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var k: Karte = spiel.karte
	for a in k.daten.get("ausgaenge", []):
		var t := Vector2i(int(a["x"]), int(a["y"]))
		if not k.tuer(t): continue
		var vor := Vector2i(-1, -1)
		for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			if k.begehbar(t + d): vor = t + d; break
		if vor.x < 0: print("FEHLER kein Feld vor %s" % t); fehler += 1; continue
		spiel.held.setze(vor, "DOWN")
		spiel.held.rotation.y = atan2(float(t.x - vor.x), float(t.y - vor.y))
		for klassisch in [false, true]:
			Bedienung.klassisch = klassisch
			spiel.ui.richte_ein()
			spiel._steht_auf(vor)
			var an: Array = spiel.angebot(vor)
			var zu_sehen: bool = spiel.ui.aktion_knopf.visible
			var zeichen: String = spiel.ui.aktion_knopf.zeichen
			var gut: bool = zu_sehen and zeichen == "ENTER" if not bool(a.get("verschlossen", false)) or a.has("klopfen") else true
			print("%s %s -> %s %s, Knopf %s %s %s" % ["Klassisch" if klassisch else "Wischen", t, String(a["ziel"]["karte"]), an, zu_sehen, zeichen, "" if gut else "FEHLER"])
			if not gut: fehler += 1
	var schirm: Rect2 = root.get_visible_rect()
	for art in [[false, false], [false, true], [true, false], [true, true]]:
		Bedienung.klassisch = art[0]; Bedienung.links = art[1]
		for i in 2:   # zweimal: der zweite Aufbau ist der nach dem Menue
			spiel.ui.richte_ein()
			await process_frame
		for c in [spiel.ui.aktion_knopf, spiel.ui.lauf_knopf]:
			var r: Rect2 = c.get_global_rect()
			var drin := schirm.encloses(r) and r.size.x > 50
			print("%s %s %s %s" % ["Klassisch" if art[0] else "Wischen", "links" if art[1] else "rechts", r, "" if drin else "FEHLER ausserhalb"])
			if not drin: fehler += 1
	Bedienung.klassisch = false; Bedienung.links = false
	print("AKTION %d Fehler" % fehler)
	quit(1 if fehler else 0)
