extends SceneTree
# 416.8 (Chef 31.10., 20:5x: „NPC dreht sich bei Interaktion zum Helden, nach etwa 10 s ignoriert er ihn wieder und spielt Leerlauf“):
# ohne Bild; im Dorf eine Person, die vom Helden weg blickt, wird angesprochen (spiel.sprich): nach 1,5 s blickt sie zum Helden
# (hoechstens 20 Grad daneben), geht der Held zur Seite, folgt ihr Blick; solange das Gespraech offen ist, bleibt sie zugewandt;
# 10 s nach dem Ende blickt sie wieder wie vorher. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit
# -s res://tests/zuwenden_4168.gd -> „ZUWENDEN n Fehler“

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
	var wer: Leute = null
	var stand := Vector2i.ZERO
	var seite := Vector2i.ZERO
	var namen := []
	for l in spiel.leute_liste():
		namen.append("%s%s" % [l.daten.get("id", "?"), "" if l.visible else "(weg)"])
		if wer != null or l.daten.has("tier") or not l.visible: continue
		for d in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
			var q: Vector2i = Vector2i(d.y, d.x)
			if k.begehbar(l.kachel + d) and (k.begehbar(l.kachel + d + q) or k.begehbar(l.kachel + d - q)):
				wer = l; stand = l.kachel + d; seite = q if k.begehbar(l.kachel + d + q) else -q
				break
	if wer == null:   # ohne gebaute Leute (Bau ohne Kaufmodelle): Pim ohne Modell an seinem Platz
		var alle = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
		for p in alle["karten"]["village"]["leute"]:
			if String(p["id"]) != "pim": continue
			wer = Leute.new(k, {"id": "pim", "x": int(p["x"]), "y": int(p["y"]), "streifen": 0}, spiel.held)
			spiel.add_child(wer)
			wer.position = k.kachel_pos(wer.kachel)
		for d in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
			var q: Vector2i = Vector2i(d.y, d.x)
			if wer and k.begehbar(wer.kachel + d) and (k.begehbar(wer.kachel + d + q) or k.begehbar(wer.kachel + d - q)):
				stand = wer.kachel + d; seite = q if k.begehbar(wer.kachel + d + q) else -q
				break
		print("ohne gebaute Leute (", namen, "): Pim ohne Modell")
	if wer == null or stand == Vector2i.ZERO:
		print("ZUWENDEN keine Person mit freiem Platz daneben"); quit(1); return
	var weg_vom := atan2(float(-(stand - wer.kachel).x), float(-(stand - wer.kachel).y))   # vom Helden weg
	wer.blick = weg_vom
	wer.rotation.y = weg_vom
	wer.warte = 99.0          # streift im Test nicht los
	var vorher := wer.blick
	spiel.held.setze(stand, "UP")
	await process_frame
	pruefe(zum(wer, spiel.held.global_position) > 150.0, "%s blickt vorher weg (%.0f Grad)" % [wer.daten["id"], zum(wer, spiel.held.global_position)])
	spiel.sprich(wer)
	await warte(2.5)   # gewendet wird mit fester Rate (DREH_STEH 1,4 rad/s, Chef Lauf 75: nicht zu flott), 180 Grad in 2,2 s
	pruefe(zum(wer, spiel.held.global_position) < 20.0, "nach 2,5 s zum Helden (%.0f Grad daneben)" % zum(wer, spiel.held.global_position))
	pruefe(Leute.still, "Gespraech offen")
	# der Held tritt zur Seite: der Blick folgt
	spiel.held.setze(stand + seite, "UP")
	await warte(1.5)
	pruefe(zum(wer, spiel.held.global_position) < 20.0, "folgt dem Helden zur Seite (%.0f Grad daneben)" % zum(wer, spiel.held.global_position))
	# Gespraech zu Ende (alle Zeilen weg)
	spiel.szene.clear()
	spiel.ui.textfeld.visible = false   # steuerung.gd spricht()
	await warte(5.0)
	pruefe(zum(wer, spiel.held.global_position) < 20.0, "5 s nach dem Gespraech noch zugewandt (%.0f Grad)" % zum(wer, spiel.held.global_position))
	await warte(8.0)
	pruefe(absf(rad_to_deg(angle_difference(wer.rotation.y, vorher))) < 20.0, "13 s nach dem Gespraech wieder wie vorher (%.0f Grad daneben)" % rad_to_deg(absf(angle_difference(wer.rotation.y, vorher))))
	pruefe(wer.zugewandt_bis == 0, "niemandem mehr zugewandt")
	print("ZUWENDEN %d Fehler" % fehler)
	quit(1 if fehler else 0)
