extends SceneTree
# 557 (Chef 04.11., 11:15: „am Beispiel der Spielstände einen Entwurf … Spieldauer … in dem neuen Stil. Einmal bitte ein Bild basteln“):
# Bilder des Entwurfs B „ohne Kasten“ (Spielstaende.entwurf = "B") am Rechner, mit Fenster (xvfb-run), 1080 × 2340:
#   557_b_eins       ein voller Platz, drei leere
#   557_b_zwei       zwei volle Plaetze (1 und 3), zwei leere
#   557_b_vorschlag  wie zwei, mit den Vorschlaegen zum Zuschalten (11:17): zuletzt gespielt oben mit „Weiter“, Kapitel und Auftrag, Gold und TP
#   557_b_loeschen   die Rueckfrage zum Loeschen (der einzige Rahmen)
#   557_jetzt_zwei   der Stand von heute (Karten wie alt, 529) mit denselben zwei Plaetzen, zum Vergleich
# PNG nach BILD557_AUS (Vorgabe user://). Die Spielstaende des Rechners werden gesichert und danach wiederhergestellt.

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 30: await process_frame   # die Drehteller zeichnen ihre Figur in eigene Viewports
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD557_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _speichere(n: int, name_: String, volk: String, klasse: String, stufe: int, karte: String, tag: int, minuten: int, gespielt_ms: int, flaggen: Array, gold: int) -> void:
	var z := Zustand.new()
	z.name = name_; z.gold = gold; z.tag = tag; z.minuten = minuten; z.gespielt_ms = gespielt_ms
	for f in flaggen: z.setze(f)
	var hw := Heldwerte.erschaffe(name_, volk, klasse, {}, z.neue_uid)
	if stufe > 1: hw.ep_dazu(int(Heldwerte.regel("ep_fuer_stufe")[stufe]))
	hw.tp = maxi(1, hw.max_tp() - 5)
	Spielstand.platz = n
	Spielstand.speichere(z, hw, {"karte": karte, "x": 4, "y": 6, "blick": "UP"})

func _zeige(entwurf: String, n: String, loeschen := false) -> void:
	Spielstaende.entwurf = entwurf
	var s := Spielstaende.new()
	root.add_child(s)
	if loeschen:
		await process_frame
		s.frage_loeschen(Spielstand.liste()[0])
	await _bild(n)
	s.queue_free()
	await process_frame

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var gesichert := Spielstand.liste()
	var alt_platz := Spielstand.platz
	for n in range(1, gesichert.size() + 1): Spielstand.loesche(n)
	_speichere(1, "Mira", "ELF", "WIZARD", 4, "deep_forest", 3, 21 * 60 + 5, (2 * 60 + 14) * 60000, [Geschichte.QUEST_STARTED, Geschichte.BARRIER_OPEN], 37)
	await _zeige("B", "557_b_eins")
	await _zeige("B", "557_b_loeschen", true)
	_speichere(3, "Borin", "DWARF", "FIGHTER", 2, "inn", 1, 9 * 60 + 40, 38 * 60000, [Geschichte.QUEST_STARTED], 12)
	await _zeige("B", "557_b_zwei")
	await _zeige("", "557_jetzt_zwei")
	Spielstaende.mit = {"weiter": true, "ziel": true, "werte": true}
	await _zeige("B", "557_b_vorschlag")
	Spielstaende.mit = {"weiter": false, "ziel": false, "werte": false}
	Spielstaende.entwurf = ""
	for n in range(1, gesichert.size() + 1):
		Spielstand.loesche(n)
		if not gesichert[n - 1].is_empty():
			var f := FileAccess.open(Spielstand.datei(n), FileAccess.WRITE); f.store_string(JSON.stringify(gesichert[n - 1])); f.close()
	Spielstand.platz = alt_platz
	quit(0)
