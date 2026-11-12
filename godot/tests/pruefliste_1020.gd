extends SceneTree
# 1020.1 (Chef 12.11., 08:09): Prüfliste im Spiel. Prüft: die Prüfliste des Baus liegt im Spiel (daten/pruefliste.json, im Bau aus
# tools/pruefliste.py; am Rechner ohne die Datei übersprungen), Ergebnis setzen und wieder lesen, Wort nach ✗, nächste offene
# Zeile, Text für die Zwischenablage wie der Abschnitt „## Ergebnis“; der Reiter „Test“ baut mit Liste ohne Skriptfehler.
# Aufruf: im Ordner godot mit -s res://tests/pruefliste_1020.gd -> „PRUEFLISTE1020 0 Fehler“ (Exit 0)

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if FileAccess.file_exists(Pruefliste.DATEI):
		var echt := Pruefliste.liste()
		print("PRUEFLISTE1020 im Bau: Build %d, %d Zeilen" % [int(echt.get("build", 0)), Pruefliste.zeilen().size()])
		pruefe(int(echt.get("build", 0)) > 0 and Pruefliste.zeilen().size() >= 1, "Prüfliste im Bau ohne Build oder Zeilen")
		for z in Pruefliste.zeilen():
			pruefe(String(z.get("wo", "")) != "" and String(z.get("richtig", "")) != "", "Zeile %s ohne Wo oder Richtig" % z.get("nr", "?"))
	else:
		print("PRUEFLISTE1020 keine daten/pruefliste.json (am Rechner ohne Bau)")
	# eigene Probeliste, Build 9999 (eigener Abschnitt in user://pruefliste.cfg)
	Pruefliste._liste = {"build": 9999, "titel": "Probe", "kopf": ["Ein Weg: …"], "abschnitte": [
		{"titel": "A · Dorf", "zeilen": [{"nr": "9999.1", "team": "Tom", "vorgang": "1", "wo": "a", "richtig": "r", "falsch": "f"},
			{"nr": "9999.2", "team": "Tom", "vorgang": "2", "wo": "b", "richtig": "r", "falsch": "f"}]},
		{"titel": "B · Wald", "zeilen": [{"nr": "9999.3", "team": "Jerry", "vorgang": "3", "wo": "c", "richtig": "r", "falsch": "f"}]}]}
	for n in ["9999.1", "9999.2", "9999.3"]: Pruefliste.setze(n, "")
	pruefe(Pruefliste.naechste_offene() == "9999.1", "erste offene nicht 9999.1: %s" % Pruefliste.naechste_offene())
	Pruefliste.setze("9999.1", "✓")
	Pruefliste.setze("9999.2", "✗ kein Staub")
	pruefe(Pruefliste.ergebnis("9999.1") == "✓", "✓ nicht gespeichert")
	pruefe(Pruefliste.wort("9999.2") == "kein Staub", "Wort nach ✗: '%s'" % Pruefliste.wort("9999.2"))
	pruefe(Pruefliste.naechste_offene("9999.1") == "9999.3", "nächste offene nach 9999.1 nicht 9999.3")
	pruefe(Pruefliste.zaehle() == [2, 1, 3], "Zähler %s statt [2, 1, 3]" % [Pruefliste.zaehle()])
	var soll := "Build 9999 · Ergebnis\n- 9999.1 ✓\n- 9999.2 ✗ kein Staub\n- offen: 9999.3"
	pruefe(Pruefliste.ergebnis_text() == soll, "Ergebnistext:\n%s" % Pruefliste.ergebnis_text())
	# bleibt über einen Neustart (neu aus der Datei gelesen)
	var c := ConfigFile.new()
	pruefe(c.load(Pruefliste.ERGEBNIS) == OK and String(c.get_value("t9999", "9999.2", "")) == "✗ kein Staub", "nicht in user://pruefliste.cfg")
	# der Reiter baut mit Liste, Zeile aufgeklappt
	Testmodus.an = true
	Testmodus.geladen = true
	Pruefliste.offen = "9999.2"
	var szene: PackedScene = load("res://spiel.tscn")
	var spiel = szene.instantiate() if szene else null
	if spiel != null:
		root.add_child(spiel)
		for i in 10: await process_frame
		if spiel.has_method("oeffne_menue"):
			spiel.oeffne_menue("test")
			for i in 5: await process_frame
			var ms := root.find_children("*", "Menue", true, false)
			pruefe(not ms.is_empty(), "kein Menü offen")
			if not ms.is_empty():
				var felder := (ms[0] as Node).find_children("*", "LineEdit", true, false)
				pruefe(felder.size() == 1 and (felder[0] as LineEdit).text == "kein Staub", "Wortfeld der aufgeklappten Zeile fehlt")
	for n in ["9999.1", "9999.2", "9999.3"]: Pruefliste.setze(n, "")
	print("PRUEFLISTE1020 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
