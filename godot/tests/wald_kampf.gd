extends SceneTree
# 399.1 ohne Bild: Dorf laden, durch den Ausgang in den Wald (17,0), der Kampfort von Jerry spielt auf Autopilot zu Ende, dann
# finish() wie der Knopf am Ende; geprueft: Kampf kam, Held steht wieder im Dorf vor dem Ausgang, Welt sichtbar, Trefferpunkte nach
# dem Kampf (Sieg: wie im Kampf, Niederlage: voll am Wiederkehrort). Braucht godot/daten und kampf/daten wie im Bau.
# Godot bricht headless beim Beenden ab, sobald das Dorf geladen war (auch ohne Kampf, 399.1 nachgestellt); massgeblich ist die Zeile WALD_KAMPF.
# Aufruf: im Ordner godot mit -s res://tests/wald_kampf.gd

func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var hw = spiel.held_werte()
	var tp0: int = hw.tp
	var aus: Dictionary = {}
	for a in spiel.karte.daten.get("ausgaenge", []):
		if String(a["ziel"]["karte"]) == "forest": aus = a; break
	if aus.is_empty(): print("FEHLER kein Ausgang in den Wald"); quit(1); return
	spiel.geh_hinaus(aus)
	var t0 := Time.get_ticks_msec()
	while spiel.kampf == null and Time.get_ticks_msec() - t0 < 10000: await process_frame
	var k = spiel.kampf
	if k == null: print("FEHLER kein Kampf"); quit(1); return
	print("Kampf: %d Gegner, Held %d/%d TP, Welt sichtbar %s" % [k.mars.fighters().filter(func(f): return f.side == "FOES").size(), tp0, hw.max_tp(), spiel.visible])
	if spiel.visible: fehler += 1; print("FEHLER Welt im Kampf sichtbar")
	await process_frame
	k.mars.set_autopilot(true)
	if not k.busy: k.go_on()
	t0 = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 60000:
		await process_frame
		if k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty(): break
		if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
			if k.mars.pilot_next() or k.mars.set_autopilot(true): k.go_on()
			else:
				var ts: Array = k.mars.targets(k.mars.current())
				k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	var aus_k: String = k.mars.outcome
	var hp_k: int = k.mars.find("hero").hp
	print("Ende: %s, Held %d TP im Kampf, Lohn %s" % [aus_k, hp_k, k.reward.get("lines", [])])
	if aus_k == "ONGOING": fehler += 1; print("FEHLER Kampf haengt")
	k.finish()
	t0 = Time.get_ticks_msec()
	while (spiel.kampf != null or not spiel.visible) and Time.get_ticks_msec() - t0 < 10000: await process_frame
	for i in 30: await process_frame
	print("zurueck: Welt sichtbar %s, Held auf %s, TP %d/%d, Kamera aktiv %s" % [spiel.visible, spiel.held.kachel, hw.tp, hw.max_tp(), spiel.kamera.current])
	if not spiel.visible: fehler += 1; print("FEHLER Welt nicht zurueck")
	if not spiel.kamera.current: fehler += 1; print("FEHLER Kamera")
	if aus_k == "WON" and hw.tp != maxi(1, hp_k): fehler += 1; print("FEHLER TP nach Sieg")
	if aus_k == "LOST" and hw.tp != hw.max_tp(): fehler += 1; print("FEHLER TP nach Niederlage")
	if aus_k != "LOST" and spiel.held.kachel.y > 3: fehler += 1; print("FEHLER Held nicht am Waldausgang")
	print("WALD_KAMPF %d Fehler" % fehler)
	quit(1 if fehler else 0)
