extends SceneTree
# 539 (Abgleich 512): das Licht folgt der Uhr wie alt (Game.daylight: Tag 7–19, Daemmerung 19–21 und 5–7, Nacht 21–5), nicht nur nach
# Rast und Testknopf; nachts gespeichert laedt als Nacht; Fackel, Nachtmonster und Klopfen fragen dieselbe Nacht (Game.isNight).
# Ohne Aufnahme; braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/licht_539.gd -> „LICHT539 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	for p in [[12 * 60, 1.0], [7 * 60, 1.0], [19 * 60, 1.0], [20 * 60, 0.5], [21 * 60, 0.0], [23 * 60, 0.0], [3 * 60, 0.0], [6 * 60, 0.5], [6 * 60 + 59, 1.0 - 1.0 / 120.0]]:
		pruefe(is_equal_approx(Licht.tageslicht(int(p[0])), float(p[1])), "Tageslicht um %02d:%02d: %.3f statt %.3f" % [int(p[0]) / 60, int(p[0]) % 60, Licht.tageslicht(int(p[0])), float(p[1])])
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	# nachts gespeichert, geladen: sofort Nacht, ohne Ueberblendung
	var z := Zustand.new()
	z.name = "Thora"; z.minuten = 23 * 60
	Spielstand.platz = 1
	Spielstand.speichere(z, Heldwerte.erschaffe("Thora", "HUMAN", "FIGHTER", {}, z.neue_uid), {"karte": "village", "x": 19, "y": 13, "blick": "DOWN"})
	spiel.starte({"laden": true, "platz": 1})
	await process_frame
	pruefe(spiel.licht.nacht > 0.99 and spiel.licht.ziel > 0.99, "nachts gespeichert laedt als Tag: nacht %.2f, ziel %.2f" % [spiel.licht.nacht, spiel.licht.ziel])
	pruefe(spiel.nachts() and spiel.im_dunkeln(), "um 23 Uhr draussen nicht dunkel (Fackel)")
	pruefe(spiel.herde == null or spiel.herde.nacht(), "Herde haelt 23 Uhr fuer Tag")
	# die Uhr laeuft in den Morgen: das Licht folgt ohne Rast
	spiel.zustand.minuten = 4 * 60 + 58
	for i in 3: await process_frame
	pruefe(spiel.licht.ziel > 0.99, "vor 5 Uhr schon Daemmerung")
	spiel.zustand.minuten = 6 * 60
	for i in 3: await process_frame
	pruefe(is_equal_approx(spiel.licht.ziel, 0.5), "um 6 Uhr nicht halbe Daemmerung: %.2f" % spiel.licht.ziel)
	spiel.zustand.minuten = 8 * 60
	var t0 := Time.get_ticks_msec()
	while spiel.licht.nacht > 0.01 and Time.get_ticks_msec() - t0 < 4000: await process_frame
	pruefe(spiel.licht.nacht < 0.01 and not spiel.nachts(), "um 8 Uhr nicht Tag: nacht %.2f" % spiel.licht.nacht)
	pruefe(not spiel.im_dunkeln(), "am Tag draussen dunkel")
	# Abend: um 20 Uhr Daemmerung, noch keine Nacht (isNight erst unter 0,35 Tageslicht)
	spiel.zustand.minuten = 20 * 60
	t0 = Time.get_ticks_msec()
	while absf(spiel.licht.nacht - 0.5) > 0.01 and Time.get_ticks_msec() - t0 < 4000: await process_frame
	pruefe(not spiel.nachts(), "um 20 Uhr schon Nacht")
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	print("LICHT539 %d Fehler" % fehler)
	quit(1 if fehler else 0)
