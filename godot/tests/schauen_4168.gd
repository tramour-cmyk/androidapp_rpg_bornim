extends SceneTree
# 416.8 (Chef 08.11., 15:43, t269.11: „beim Annähern richtet sich keiner zum Helden aus“; DESIGN-STIL: bis 3 Felder anschauen, nach
# etwa 10 s Stillstand das Interesse verlieren, 5la.3): ohne Bild. Eine Person blickt vom Helden weg; der Held kommt auf 2 Kacheln:
# sie wendet sich ihm zu; er geht 2 Kacheln zur Seite: der Blick folgt; er bleibt 10 s stehen: sie blickt wieder wie vorher; 5 Kacheln
# entfernt schaut sie nicht. Braucht godot/daten wie im Bau (karten.json). Aufruf im Ordner godot: headless,
# -s res://tests/schauen_4168.gd -> „SCHAUEN n Fehler“

func _initialize() -> void:
	_lauf.call_deferred()

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func warte(s: float) -> void:
	await create_timer(s).timeout

func zum(l: Leute, p: Vector3) -> float:
	return rad_to_deg(absf(angle_difference(l.rotation.y, atan2(p.x - l.global_position.x, p.z - l.global_position.z))))

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.betrete("village", Vector2i(11, 7), "DOWN")
	for i in 5: await process_frame
	var k: Karte = spiel.karte
	# Pim ohne Modell an seinem Platz (wie zuwenden_4168 ohne Kaufmodelle); andere Leute weg, damit keiner im Weg steht
	for l in spiel.leute_liste(): l.visible = false
	var alle = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	var wer: Leute = null
	for p in alle["karten"]["village"]["leute"]:
		if String(p["id"]) != "pim": continue
		wer = Leute.new(k, {"id": "pim", "x": int(p["x"]), "y": int(p["y"]), "streifen": 0}, spiel.held)
		spiel.add_child(wer)
		wer.position = k.kachel_pos(wer.kachel)
	if wer == null: print("SCHAUEN Pim fehlt in karten.json"); quit(1); return
	# zwei begehbare Kacheln im Abstand 2 (nah) und eine im Abstand 5 (fern), dazu eine zweite nahe auf anderer Seite
	var nah := Vector2i(-99, -99); var nah2 := Vector2i(-99, -99); var fern := Vector2i(-99, -99)
	for dx in range(-5, 6):
		for dy in range(-5, 6):
			var t: Vector2i = wer.kachel + Vector2i(dx, dy)
			if not k.begehbar(t): continue
			var m := maxi(absi(dx), absi(dy))
			if m == 2 and nah.x == -99: nah = t
			elif m == 2 and nah2.x == -99 and (t - nah).length() >= 2.0: nah2 = t
			elif m == 5 and fern.x == -99: fern = t
	if nah.x == -99 or nah2.x == -99 or fern.x == -99: print("SCHAUEN keine freien Kacheln um Pim"); quit(1); return
	wer.warte = 99.0          # streift im Test nicht los
	# 1. fern: schaut nicht
	spiel.held.setze(fern, "UP")
	await process_frame
	var hp := k.kachel_pos(fern)
	var weg_vom := atan2(wer.global_position.x - hp.x, wer.global_position.z - hp.z)
	wer.blick = weg_vom; wer.rotation.y = weg_vom
	await warte(2.0)
	pruefe(zum(wer, spiel.held.global_position) > 150.0, "5 Kacheln entfernt schaut sie nicht her (%.0f Grad daneben)" % zum(wer, spiel.held.global_position))
	# 2. nah: wendet sich zu
	spiel.held.setze(nah, "UP")
	await warte(2.5)
	pruefe(wer.schaut, "2 Kacheln entfernt: sie schaut")
	pruefe(zum(wer, spiel.held.global_position) < 25.0, "2 Kacheln entfernt: zum Helden gewandt (%.0f Grad daneben)" % zum(wer, spiel.held.global_position))
	# 3. zur Seite: der Blick folgt
	spiel.held.setze(nah2, "UP")
	await warte(2.0)
	pruefe(zum(wer, spiel.held.global_position) < 25.0, "der Blick folgt zur Seite (%.0f Grad daneben)" % zum(wer, spiel.held.global_position))
	# 4. 10 s still: verliert das Interesse, blickt wie vorher
	await warte(10.0)
	pruefe(not wer.schaut, "nach 10 s Stillstand schaut sie nicht mehr")
	pruefe(absf(rad_to_deg(angle_difference(wer.rotation.y, weg_vom))) < 25.0, "blickt wieder wie vorher (%.0f Grad daneben)" % absf(rad_to_deg(angle_difference(wer.rotation.y, weg_vom))))
	print("SCHAUEN %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
