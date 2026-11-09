extends SceneTree
# 542 (Abgleich Build 249: Jorins „Feuer am Steinkreis“ nicht abschliessbar, Gwennas Ring nicht findbar, Aldrics Ring als Ding):
# ohne Bild; wie alt (Jobs.findAt, Jobs.ringIn, Uniques.make): am Steinkreis des Fluesterwalds liegt bei angenommenem Auftrag der
# Fetzen (Knopf „LOOK“), in der Truhe cave_3 Gwennas Ring (auch wenn sie schon leer war), und Aldrics Ring kommt als Ausruestung
# (Einzelstueck) in die Tasche. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/auftraege_542.gd
# -> „AUFTRAEGE n Fehler“

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])
	else: print("gut %s" % was)

func lies(spiel) -> Array:
	var gelesen := []
	for i in 30:
		if not spiel.ui.spricht(): break
		gelesen.append(String(spiel.ui.text.text))
		spiel.ui.naechste()
		await process_frame
	return gelesen

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	pruefe("Fetzen: ohne Auftrag nichts", Auftraege.fund_bei(z, "forest", "I").size(), 0)
	Auftraege.nimm(z, Auftraege.von("stones"))
	pruefe("Fetzen: mit Auftrag am Stein", Auftraege.fund_bei(z, "forest", "I").size(), 2)
	pruefe("Fetzen: nicht anderswo", [Auftraege.fund_bei(z, "deep_forest", "I").size(), Auftraege.fund_bei(z, "forest", "T").size()], [0, 0])
	z.dazu(Auftraege.RAG)
	pruefe("Fetzen: schon in der Tasche", Auftraege.fund_bei(z, "forest", "I").size(), 0)
	pruefe("Ring: ohne Auftrag nicht", Auftraege.ring_in(z, "cave_3"), false)
	Auftraege.nimm(z, Auftraege.von("ring"))
	pruefe("Ring: mit Auftrag in cave_3", [Auftraege.ring_in(z, "cave_3"), Auftraege.ring_in(z, "cave_1")], [true, false])
	# im Spiel
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	await lies(spiel)
	var sz: Zustand = spiel.zustand
	spiel.spiele([{"art": "geben", "ding": "ring_protection", "anzahl": 1}])
	await process_frame
	var t: Array = await lies(spiel)
	var ring = null
	for g in sz.beutel:
		if g.get("unique") == "ring_protection": ring = g
	pruefe("Aldrics Ring als Ausrüstung", ring != null and String(ring["base"]) == "ring" and String(ring["rarity"]) == "RARE", true)
	pruefe("nicht als Ding", sz.anzahl("ring_protection"), 0)
	pruefe("Fundzeile nennt den Ring", t.size() > 0 and t[0].contains("Ring des Ältesten"), true)
	Auftraege.nimm(sz, Auftraege.von("ring"))
	sz.setze("kiste:cave_3")   # schon leer
	spiel.oeffne_kiste({"id": "cave_3"})
	await process_frame
	t = await lies(spiel)
	pruefe("Gwennas Ring aus der leeren Truhe", [sz.anzahl(Auftraege.RING), t.size() > 0 and t[0].begins_with("Unter Lumpen und Knochen")], [1, true])
	spiel.oeffne_kiste({"id": "cave_3"})
	await process_frame
	t = await lies(spiel)
	pruefe("danach wieder leer", sz.anzahl(Auftraege.RING), 1)
	# Steinkreis im Fluesterwald
	Auftraege.nimm(sz, Auftraege.von("stones"))
	spiel.betrete("forest", Vector2i(1, 1), "DOWN")
	for i in 3: await process_frame
	await lies(spiel)
	var k: Karte = spiel.karte
	var vor := Vector2i(-1, -1)
	for y in k.hoehe:
		for x in k.breite:
			if vor.x < 0 and k.zeichen(Vector2i(x, y)) == "I" and k.begehbar(Vector2i(x, y + 1)): vor = Vector2i(x, y + 1)
	pruefe("Stein mit freiem Feld davor", vor.x >= 0, true)
	if vor.x >= 0:
		# Lauf 310: ein Wolf der Herde stand zufällig neben dem Stein, der Knopf hieß „FIGHT“; die Herde hier räumen
		if spiel.herde != null:
			spiel.herde.aus = true
			for s in spiel.herde.liste: s.queue_free()
			spiel.herde.liste.clear()
		spiel.held.setze(vor, "UP")
		spiel.held.rotation.y = PI
		pruefe("Knopf am Stein", spiel.angebot(vor)[0], "LOOK")
		spiel._aktion()
		await process_frame
		t = await lies(spiel)
		pruefe("Fetzen gefunden", [sz.anzahl(Auftraege.RAG), t.size() > 0 and t[0].begins_with("Zwischen den Steinen")], [1, true])
	print("AUFTRAEGE %d Fehler" % fehler)
	quit(1 if fehler else 0)
