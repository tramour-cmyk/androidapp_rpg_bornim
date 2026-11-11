extends SceneTree
# 470a B ohne Bild: die Seite „Neues Spiel“ nach BRS 1.1 kommt bis 2.3 nur aus dem Reiter „Test“ (Erschaffung BRS); sie liegt ueber der
# Welt, das Spiel steht so lange; „Zurück“ fuehrt zurueck in die Welt, Held und Spielstand bleiben, wie sie waren. 834: „Abenteuer
# beginnen“ speichert, merkt den neuen Helden fuer das neue Spiel (spiel.gd neu_brs) und laedt die Szene neu (das prueft brs_held_834.gd).
# Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/testmenue_470.gd -> „TESTMENUE470 n Fehler“

func _initialize() -> void:
	_lauf.call_deferred()

func seite(spiel) -> ErschaffungBrs:
	var s: Array = spiel.find_children("*", "ErschaffungBrs", true, false).filter(func(c): return not c.is_queued_for_deletion())
	return s[0] if not s.is_empty() else null

func _lauf() -> void:
	var fehler := 0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var vor: Dictionary = spiel.zustand.als_daten()
	vor.erase("gespielt_ms")   # 834: „Abenteuer beginnen“ speichert, dabei zaehlt die Spielzeit weiter
	for wie in ["zurueck", "beginnen"]:
		spiel.test_tat("erschaffung_brs", [])
		for i in 3: await process_frame
		var e := seite(spiel)
		if e == null: print("FEHLER %s: Seite fehlt" % wie); fehler += 1; continue
		if not paused: print("FEHLER %s: Spiel laeuft weiter" % wie); fehler += 1
		if wie == "zurueck": e.zurueck.emit()
		else:
			e.b.waehle("Handeln")   # Mensch als Wachsoldat: eine Fertigkeit selbst
			e.baue()
			if not e.los_an(): print("FEHLER Beginnen gesperrt"); fehler += 1
			e.beginne()
		for i in 3: await process_frame
		if seite(spiel) != null: print("FEHLER %s: Seite bleibt" % wie); fehler += 1
		if paused: print("FEHLER %s: Spiel steht noch" % wie); fehler += 1
	var nach: Dictionary = spiel.zustand.als_daten()
	nach.erase("gespielt_ms")
	if nach != vor: print("FEHLER Spielstand geaendert"); fehler += 1
	var neu: Dictionary = load("res://skripte/spiel.gd").neu_brs
	if (neu.get("brs", {}) as Dictionary).is_empty(): print("FEHLER 834: kein Held nach BRS fuer das neue Spiel"); fehler += 1
	print("TESTMENUE470 %d Fehler" % fehler)
	quit(1 if fehler else 0)
