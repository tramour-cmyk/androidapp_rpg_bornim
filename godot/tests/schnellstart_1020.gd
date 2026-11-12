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
	# 1020.1 E: Schalter bleiben über einen Neustart (neu geladen aus user://test.cfg), solange der Testmodus an ist
	var war := Testmodus.an
	Testmodus.an = true
	Herde.beachten_nicht = true
	Held.schnell = 3.0
	Testmodus.schalter_speichern(true)
	Herde.beachten_nicht = false
	Held.schnell = 1.0
	var c := ConfigFile.new()
	c.load(Testmodus.DATEI)
	var an_vorher = c.get_value("test", "an", false)
	c.set_value("test", "an", true)
	c.save(Testmodus.DATEI)
	Testmodus._schalter_laden(c)   # wie lade() am Gerät (ohne Fenster lädt lade() die Schalter nicht)
	pruefe(Herde.beachten_nicht and Held.schnell > 1.0, "Schalter nach Neustart nicht wieder da")
	c.load(Testmodus.DATEI)
	c.set_value("test", "an", an_vorher)
	if c.has_section("schalter"): c.erase_section("schalter")
	c.save(Testmodus.DATEI)
	Testmodus.an = war
	Herde.beachten_nicht = false
	Held.schnell = 1.0
	# 1020.1 E: Uhrzeit springt auf die nächste Zeit der Liste
	pruefe(Testmodus.UHRZEITEN.has(20 * 60 + 30) and Testmodus.UHRZEITEN.has(10 * 60), "Uhrzeiten ohne 10 oder 20:30")
	for n in [Testmodus.TESTPLATZ, Testmodus.LAGEPLATZ]: Spielstand.loesche(n)
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)   # nichts für die folgenden Tests liegen lassen
	print("SCHNELLSTART1020 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
