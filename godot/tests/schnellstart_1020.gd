extends SceneTree
# 1020.1 A (Chef 12.11., 08:09): Schnellstart im Testmodus und Lage merken/zurück. Prüft ohne Bild: Schnellstart beginnt ohne Intro
# erwacht in der Schenke (Rast.START) auf dem Testplatz 9, die vier Plätze des Spielers bleiben unberührt und zeigen ihn nicht;
# „Lage merken“, dann Uhr und Ort geändert, „Lage zurück“ stellt beides wieder her und speichert weiter in den Testplatz;
# „Einmaliges“ löscht Eingebungen und Kampfhinweise. Braucht godot/daten wie im Bau.
# Aufruf: im Ordner godot mit -s res://tests/schnellstart_1020.gd -> „SCHNELLSTART1020 0 Fehler“ (Exit 0)

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	for n in [Testmodus.TESTPLATZ, Testmodus.LAGEPLATZ]: Spielstand.loesche(n)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)   # das Probespiel ohne Hauptmenü speichert vorher in Platz 1
	var w := Testmodus.schnellstart()
	pruefe(bool(w.get("schnell", false)) and int(w["platz"]) > Spielstand.PLAETZE and not (w["brs"] as Dictionary).is_empty(), "Schnellstart-Wahl %s" % [w.keys()])
	spiel.starte(w)
	for i in 10: await process_frame
	pruefe(root.find_children("*", "Zwischenbild", true, false).is_empty(), "Schnellstart zeigt das Intro")
	pruefe(spiel.karte.id == String(Rast.START["karte"]), "Schnellstart nicht in der Schenke: %s" % spiel.karte.id)
	pruefe(spiel.zustand.has(Geschichte.INTRO_DONE), "Schnellstart nicht erwacht")
	pruefe(Spielstand.platz == Testmodus.TESTPLATZ, "Platz %d statt Testplatz" % Spielstand.platz)
	spiel.speichere()
	pruefe(Spielstand.liste().all(func(d): return (d as Dictionary).is_empty()) and Spielstand.letzter() == 0, "Testplatz unter den Plätzen des Spielers: %s" % [Spielstand.liste().map(func(d): return [d.get("platz", 0), d.get("zustand", {}).get("name", "")])])
	# Lage merken, ändern, zurück
	spiel.zustand.minuten = 10 * 60
	spiel.test_tat("lage_merken", [])
	spiel.zustand.minuten = 21 * 60
	await spiel.test_tat("teleport", ["village", 19, 13, "DOWN"])
	pruefe(spiel.karte.id == "village", "Teleport ins Dorf")
	await spiel.test_tat("lage_zurueck", [])
	for i in 3: await process_frame
	pruefe(spiel.zustand.minuten == 10 * 60, "Uhr nach „Lage zurück“ %d statt 600" % spiel.zustand.minuten)
	pruefe(spiel.karte.id == String(Rast.START["karte"]), "Ort nach „Lage zurück“ %s" % spiel.karte.id)
	pruefe(Spielstand.platz == Testmodus.TESTPLATZ, "nach „Lage zurück“ Platz %d" % Spielstand.platz)
	# Einmaliges
	spiel.zustand.setze("eingebung_POUNCE")
	spiel.zustand.setze("kampf_hinweis_reihe")
	spiel.test_tat("einmaliges", [])
	pruefe(not spiel.zustand.has("eingebung_POUNCE") and not spiel.zustand.has("kampf_hinweis_reihe"), "Einmaliges nicht zurückgesetzt")
	for n in [Testmodus.TESTPLATZ, Testmodus.LAGEPLATZ]: Spielstand.loesche(n)
	print("SCHNELLSTART1020 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
