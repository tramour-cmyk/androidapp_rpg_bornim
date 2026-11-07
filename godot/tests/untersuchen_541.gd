extends SceneTree
# 541 (Abgleich Build 249: „Untersuchen fehlt ganz, Angriff mit dem Aktionsknopf fehlt“): ohne Bild; wie alt (Game.interact,
# Navigation.actionAt): Brunnen, Regal, Altar … zeigen „Ansehen“ und ihren Satz, der Schlagbaum seinen; ein Monster vor dem Helden
# zeigt „Kampf“ und greift an (von hinten: Held zuerst).
# Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/untersuchen_541.gd -> „UNTERSUCHEN n Fehler“

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

# eine Kachel mit Zeichen z und ein begehbares Feld darunter; der Held dort, Blick nach oben
func vor_zeichen(spiel, z: String) -> bool:
	var k: Karte = spiel.karte
	for y in k.hoehe - 1:
		for x in k.breite:
			if k.zeichen(Vector2i(x, y)) == z and k.begehbar(Vector2i(x, y + 1)) and k.ausgang(Vector2i(x, y + 1)).is_empty():
				spiel.held.setze(Vector2i(x, y + 1), "UP")
				spiel.held.rotation.y = PI
				return true
	return false

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	pruefe("Altar vorher", String(Geschichte.ansehen("A", Vector2i.ZERO, z, false, true)["de"]).begins_with("Auf dem Altar ist eine leere Halterung"), true)
	z.setze(Geschichte.CHAPTER1_DONE)
	pruefe("Altar nachher", String(Geschichte.ansehen("A", Vector2i.ZERO, z, false, true)["de"]), "Das Sonnenamulett strahlt auf dem Altar.")
	pruefe("Laterne bei Nacht", String(Geschichte.ansehen("l", Vector2i.ZERO, z, true, false)["de"]), "Die Laterne brennt warm und hell.")
	pruefe("Gras ist nichts", Geschichte.ansehen(".", Vector2i.ZERO, z, false, false), {})
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	await lies(spiel)
	spiel.betrete("village", Vector2i(1, 1), "DOWN")
	for i in 3: await process_frame
	await lies(spiel)
	for f in [["w", "Ein alter Brunnen."], ["z", "Der Schlagbaum ist unten."]]:
		var da := vor_zeichen(spiel, f[0])
		pruefe("Dorf hat %s mit Feld davor" % f[0], da, true)
		if not da: continue
		pruefe("%s: Knopf Ansehen" % f[0], spiel.angebot(spiel.held.kachel)[0], "LOOK")
		spiel._aktion()
		await process_frame
		var t: Array = await lies(spiel)
		pruefe("%s: Satz" % f[0], t.size() > 0 and t[0].begins_with(f[1]), true)
	# Monster vor dem Helden
	spiel.betrete("forest", Vector2i(1, 1), "DOWN")
	for i in 5: await process_frame
	await lies(spiel)
	var h: Herde = spiel.herde
	if h != null and h.liste.is_empty():   # am Rechner ohne die Modelle des Baus zieht die Herde keine: eines von Hand
		var k: Karte = spiel.karte
		for y in range(2, k.hoehe - 2):
			for x in range(2, k.breite - 2):
				var t := Vector2i(x, y)
				if h.liste.is_empty() and k.begehbar(t) and k.begehbar(t + Vector2i(0, 1)) and k.ausgang(t).is_empty() and k.ausgang(t + Vector2i(0, 1)).is_empty():
					h._zeige({"art": "wolf", "kachel": t, "heim": t, "blick": Vector2i(0, 1), "nr": 0})
	if h == null or h.liste.is_empty():
		print("FEHLER kein Monster im Flüsterwald"); fehler += 1
	else:
		h.liste[0].ruhig_bis = h.jetzt + 600000
		h.liste[0].naechst_ms = h.jetzt + 600000
		var los := []
		for c in h.kampf.get_connections(): h.kampf.disconnect(c["callable"])
		h.kampf.connect(func(m, er, wer): los.append([m, er]))
		h.aus = false
		var s: Streuner = h.liste[0]
		var feld := Vector2i(-1, -1)
		for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			if feld.x < 0 and spiel.karte.begehbar(s.kachel + d): feld = s.kachel + d
		spiel.held.setze(feld, "UP")
		var b: Vector2i = s.kachel - feld
		spiel.held.rotation.y = atan2(float(b.x), float(b.y))
		s.blick = -b   # sieht den Helden an
		pruefe("Monster: Knopf Kampf", spiel.angebot(spiel.held.kachel)[0], "FIGHT")
		spiel._aktion()
		pruefe("Monster: Angriff von vorn", los, [[s.art, "NORMAL"]])
		los.clear()
		s.blick = b   # wendet dem Helden den Ruecken zu
		spiel._aktion()
		pruefe("Monster: von hinten Held zuerst", los, [[s.art, "HERO_FIRST"]])
	print("UNTERSUCHEN %d Fehler" % fehler)
	quit(1 if fehler else 0)
