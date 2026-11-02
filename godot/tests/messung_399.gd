extends SceneTree
# 399.1 (Test 139, Chef 28.10., 21:5x: „über das Gerät … keine Testdaten wie in der alten Fassung“): ohne Bild; Dorf, ein Teleport mit
# Blende; unter „Gerät“ stehen danach Ort, Bilder je Sekunde, laengste Bildpause, Blende und die 10 s danach, Ladezeit je Ort,
# Grafikspeicher, Rand oben und die Fehlermeldungen. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/messung_399.gd

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 30: await process_frame
	var fertig := [false]
	var lauf := func(): await spiel.test_tat("teleport", ["village", 11, 7, "DOWN"]); fertig[0] = true
	lauf.call()
	var t0 := Time.get_ticks_msec()
	while not fertig[0] and Time.get_ticks_msec() - t0 < 20000: await process_frame
	for i in 20: await process_frame
	var g := Menue.geraeteangaben()
	print(g)
	for soll in ["Ort: village 11/7", "Bilder je Sekunde: ", "Längste Bildpause seit dem Start: ", "Blende: längste Bildpause ", "über 50 ms: ",
			"Ladezeit je Ort: village ", "Kampfort bereit nach: ", "Grafikspeicher: ", "Rand oben (Kamera): ", "Letzte Fehlermeldungen: "]:
		if not g.contains(soll): fehler += 1; print("FEHLER Gerät ohne ", soll)
	if g.contains("Blende: längste Bildpause –"): fehler += 1; print("FEHLER Blende nicht gemessen")
	if not fertig[0]: fehler += 1; print("FEHLER Teleport kam nicht an")
	print("MESSUNG %d Fehler" % fehler)
	quit(1 if fehler else 0)
