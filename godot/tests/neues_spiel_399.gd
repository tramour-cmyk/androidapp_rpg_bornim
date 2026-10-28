extends SceneTree
# 399.1 (Test 139, Chef 28.10., 21:3x: „alten Spielstand geladen … neues Spiel gestartet … Position des Charakters war die gleiche“): ohne Bild;
# ein Spielstand am Brunnen mit Gold und Flaggen wird geladen (Held dort), dann im selben Spiel ein neues begonnen: nach der Ankunft steht
# der neue Held im Bett der Schenke (Story.START), ohne Gold, Flaggen und Namen des vorigen, gespeichert in seinem eigenen Platz.
# Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/neues_spiel_399.gd

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var z := Zustand.new()
	z.name = "Alt"; z.gold = 777; z.setze("met_rowena")
	Spielstand.platz = 1
	Spielstand.speichere(z, Heldwerte.erschaffe("Alt", "HUMAN", "FIGHTER", {}, z.neue_uid), {"karte": "village", "x": 19, "y": 13, "blick": "DOWN"})
	spiel.starte({"laden": true, "platz": 1})
	for i in 5: await process_frame
	print("geladen: %s %s, %s, Gold %d" % [spiel.karte.id, spiel.held.kachel, spiel.zustand.name, spiel.zustand.gold])
	if spiel.karte.id != "village" or spiel.held.kachel != Vector2i(19, 13) or spiel.zustand.gold != 777: fehler += 1; print("FEHLER Laden")
	spiel.starte({"name": "Neu", "volk": "ELF", "klasse": "WIZARD", "werte": {}, "platz": 2})
	for i in 30:   # die Ankunft bei Nacht: fertig, sobald sie da ist (Tippen „Überspringen?“ gibt es ohne Finger nicht)
		await process_frame
		var zb := root.find_children("*", "Zwischenbild", true, false)
		if not zb.is_empty(): zb[0].fertig.emit(); break
	for i in 5: await process_frame
	var soll := Vector2i(int(Rast.START["x"]), int(Rast.START["y"]))
	print("neu: %s %s, %s, Gold %d, met_rowena %s, %s, Platz %d" % [spiel.karte.id, spiel.held.kachel, spiel.zustand.name, spiel.zustand.gold,
		spiel.zustand.flaggen.has("met_rowena"), spiel.held_werte().klasse, Spielstand.platz])
	if spiel.karte.id != String(Rast.START["karte"]) or spiel.held.kachel != soll: fehler += 1; print("FEHLER neues Spiel nicht im Bett der Schenke")
	if spiel.zustand.name != "Neu" or spiel.zustand.gold == 777 or spiel.zustand.flaggen.has("met_rowena"): fehler += 1; print("FEHLER neues Spiel erbt den Zustand")
	if spiel.held_werte().klasse != "WIZARD" or Spielstand.platz != 2: fehler += 1; print("FEHLER neuer Held oder Platz")
	var alt := Spielstand.lade(1)
	if alt.is_empty() or int(alt["zustand"].get("gold", 0)) != 777: fehler += 1; print("FEHLER alter Spielstand ueberschrieben")
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	print("NEUES_SPIEL %d Fehler" % fehler)
	quit(1 if fehler else 0)
