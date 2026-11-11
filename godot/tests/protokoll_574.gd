extends SceneTree
# 574 (Chef 04.11., 20:40, Laufprotokoll Build 257: dreimal „Lambda capture at index 0 was freed“ nach Testmenue, Stationen, Probekaempfen):
# eine Zeile im Spielmenue (Menue.meldung) und ein Hinweis im Hauptmenue (Hauptmenue.hinweis) verschwinden nach 3 s; wird der Schirm vorher
# geschlossen, darf der Zeitgeber keinen freigegebenen Knoten mehr anfassen. Ohne Bild; die Fehlerzeile prueft der Bau (grep
# „Lambda capture“). Dazu einmal „Condition "buffer_size == 0"“: ein Grundriss lud seine Bodenmaske, die es nicht gibt (gebiet.gd baue_leben).
# Aufruf im Ordner godot: headless, -s res://tests/protokoll_574.gd -> „PROTOKOLL574 gut“; der Bau sucht dazu „Lambda capture“ und „buffer_size“

func _initialize() -> void:
	Engine.time_scale = 10.0
	_lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", "Wachsoldat", z.neue_uid)
	# Spielmenue: Meldung, dann gleich schliessen (Menue zu, Probekampf, Ortswechsel)
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.meldung("Station gesetzt")
	await process_frame
	m.queue_free()
	# Hauptmenue: Hinweis (Testmodus an), dann gleich ein anderer Schirm
	Hauptmenue.vorspann_gezeigt = true
	var hm := Hauptmenue.new(null)
	root.add_child(hm)
	await process_frame
	hm.hinweis("Testmodus aktiviert")
	await process_frame
	hm.queue_free()
	await create_timer(4.0).timeout
	var fehler := 0
	for id in ["inn", "shop", "elder", "temple"]:
		if Gebiet.maske_bild(id) != null: fehler += 1; print("FALSCH %s hat eine Bodenmaske" % id)
	if Gebiet.bild("gibt_es_nicht_574") == null: fehler += 1; print("FALSCH Gebiet.bild ohne Datei gibt nichts")
	print("PROTOKOLL574 ", "gut" if fehler == 0 else "FALSCH %d" % fehler)
	quit(1 if fehler else 0)
