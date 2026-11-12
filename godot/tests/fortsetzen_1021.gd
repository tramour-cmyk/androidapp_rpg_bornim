extends SceneTree
# 1021 ohne Bild (der letzte Teil mit godot/daten wie im Bau): die Marke beim Verlassen im Spiel (Spielstand.merke_hintergrund) fuehrt beim naechsten Start gleich
# in den Stand, ausser die App kam zurueck (vergiss_hintergrund), der Spieler hat sie selbst beendet (Ende laut System 10, 11 nach der
# Marke) oder der Platz ist leer. Die Marke gilt nur einmal (kein Kreis bei Absturz beim Laden). Dazu die Zeile „Letztes Ende der App“.
# Aufruf: im Ordner godot mit -s res://tests/fortsetzen_1021.gd

func _initialize() -> void: _lauf.call_deferred()

func _stand(n: int) -> void:
	var f := FileAccess.open(Spielstand.datei(n), FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": Spielstand.VERSION, "zustand": {}, "held": {}, "ort": {"karte": "village", "x": 19, "y": 13, "blick": "DOWN"}}))
	f.close()

func _lauf() -> void:
	var fehler := 0
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	Spielstand.vergiss_hintergrund()
	_stand(3)
	var jetzt := int(Time.get_unix_time_from_system() * 1000.0)
	var faelle := [
		# [Name, Marke setzen, zurueckgekommen, Ende laut System, erwarteter Platz]
		["ohne Marke", false, false, {}, 0],
		["Ende im Hintergrund, kein Bericht (Rechner, vor Android 11)", true, false, {}, 3],
		["Speicher knapp", true, false, {"grund": 3, "zeit": jetzt + 60000}, 3],
		["Signal (Akkusparen)", true, false, {"grund": 2, "zeit": jetzt + 60000}, 3],
		["App kam zurueck", true, true, {"grund": 3, "zeit": jetzt + 60000}, 0],
		["aus den letzten Apps gewischt", true, false, {"grund": 10, "zeit": jetzt + 60000}, 0],
		["in den Einstellungen gestoppt", true, false, {"grund": 11, "zeit": jetzt + 60000}, 0],
		["alter Nutzerbericht vor der Marke", true, false, {"grund": 10, "zeit": jetzt - 3600000}, 3],
	]
	for fa in faelle:
		Spielstand.platz = 3
		if fa[1]: Spielstand.merke_hintergrund()
		if fa[2]: Spielstand.vergiss_hintergrund()
		var p := Spielstand.fortsetzen(fa[3])
		var zweit := Spielstand.fortsetzen({})
		print("%s: Platz %d, beim zweiten Start %d" % [fa[0], p, zweit])
		if p != fa[4] or zweit != 0: fehler += 1; print("FEHLER 1021 %s: erwartet %d" % [fa[0], fa[4]])
	# leerer Platz: wie bisher Hauptmenue
	Spielstand.platz = 2
	Spielstand.merke_hintergrund()
	if Spielstand.fortsetzen({}) != 0: fehler += 1; print("FEHLER 1021 leerer Platz")
	# „Letztes Ende der App“
	var t := Messung.ende_text({"grund": 3, "zeit": jetzt, "pss_mb": 812, "rss_mb": 900, "wichtigkeit": 400, "beschreibung": ""})
	print("Zeile: ", t.replace("\n", " | "))
	if not t.contains("Speicher knapp") or not t.contains("PSS 812 MB") or Messung.ende_text({}) != "–": fehler += 1; print("FEHLER 1021 Zeile")
	if not Messung.letztes_ende().is_empty(): fehler += 1; print("FEHLER 1021 am Rechner ein Ende laut System")
	# im Spiel (braucht godot/daten wie im Bau): Marke, neuer Start, der Held steht dort, wo gespeichert wurde, ohne Hauptmenue
	if FileAccess.file_exists("res://daten/karten.json"):
		var spiel = load("res://spiel.tscn").instantiate()
		root.add_child(spiel)
		for i in 5: await process_frame
		var z := Zustand.new()
		z.name = "Weg"; z.gold = 321
		Spielstand.platz = 4
		Spielstand.speichere(z, BrsHeld.fuer_spiel("Weg", "Mensch", "Wachsoldat", z.neue_uid), {"karte": "village", "x": 19, "y": 13, "blick": "DOWN"})
		Spielstand.merke_hintergrund()
		Spielstand.platz = 1
		var weiter: bool = spiel.weiter_nach_hintergrund()
		for i in 5: await process_frame
		print("im Spiel: weiter %s, %s %s, %s, Gold %d, Platz %d, Hauptmenue %d" % [weiter, spiel.karte.id, spiel.held.kachel, spiel.zustand.name, spiel.zustand.gold,
			Spielstand.platz, root.find_children("*", "Hauptmenue", true, false).size()])
		if not weiter or spiel.karte.id != "village" or spiel.held.kachel != Vector2i(19, 13) or spiel.zustand.gold != 321 or Spielstand.platz != 4:
			fehler += 1; print("FEHLER 1021 im Spiel nicht weiter, wo gespeichert")
		if spiel.weiter_nach_hintergrund(): fehler += 1; print("FEHLER 1021 im Spiel zweimal weiter")
		# Verlassen im Spiel setzt die Marke, Zurueckkommen loescht sie
		spiel.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
		var gesetzt := FileAccess.file_exists(Spielstand.HINTERGRUND)
		spiel.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
		print("Pause: Marke %s, zurueck: Marke %s" % [gesetzt, FileAccess.file_exists(Spielstand.HINTERGRUND)])
		if not gesetzt or FileAccess.file_exists(Spielstand.HINTERGRUND): fehler += 1; print("FEHLER 1021 Marke beim Pausieren")
		spiel.queue_free()
		await process_frame
	else: print("im Spiel: ohne godot/daten nicht geprueft")
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	print("FORTSETZEN1021 %d Fehler" % fehler)
	quit(1 if fehler else 0)
