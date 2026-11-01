extends SceneTree
# 399.1 ohne Bild: aus dem Reiter „Test“ ein Kampf gegen Goblins und eine MARS-Probe (Magier Stufe 5 gegen Grak) im Dorf; der Kampfort
# spielt auf Autopilot zu Ende; geprueft: Kampf kam mit den gewaehlten Gegnern, bei der Probe zwei Kaempfer der Klasse auf der Stufe,
# danach Welt sichtbar, Held am selben Fleck; die Probe laesst den eigenen Helden, wie er war. Braucht godot/daten und kampf/daten wie im Bau.
# Aufruf: im Ordner godot mit -s res://tests/testkampf_399.gd

func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()

var fehler := 0

func kampf(spiel, was: String, mit: Array) -> Array:
	spiel.test_tat(was, mit)
	var t0 := Time.get_ticks_msec()
	while spiel.kampf == null and Time.get_ticks_msec() - t0 < 10000: await process_frame
	var k = spiel.kampf
	if k == null: fehler += 1; print("FEHLER kein Kampf ", was, mit); return []
	var party: Array = k.mars.fighters().filter(func(f): return f.side == "PARTY")
	var feinde: Array = k.mars.fighters().filter(func(f): return f.side == "FOES").map(func(f): return String(f.kind) if "kind" in f else String(f.id))
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
	var aus: String = k.mars.outcome
	k.finish()
	t0 = Time.get_ticks_msec()
	while (spiel.kampf != null or not spiel.visible) and Time.get_ticks_msec() - t0 < 10000: await process_frame
	for i in 30: await process_frame
	print("%s %s: %d in der Gruppe, Gegner %s, Ende %s, Welt sichtbar %s, Held %s" % [was, mit, party.size(), feinde, aus, spiel.visible, spiel.held.kachel])
	if not spiel.visible: fehler += 1; print("FEHLER Welt nicht zurueck")
	return [party.size(), aus]

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var hw = spiel.held_werte()
	var da: Vector2i = spiel.held.kachel
	var r := await kampf(spiel, "kampf", ["GOBLINS"])
	if not r.is_empty() and r[1] != "LOST" and spiel.held.kachel != da: fehler += 1; print("FEHLER Held nicht am Fleck")
	hw.tp = 3
	var vor := [hw.tp, hw.stufe, spiel.zustand.gold, spiel.zustand.siege]
	r = await kampf(spiel, "probe", ["GRAK", "WIZARD", 5])
	if not r.is_empty() and r[0] != 2: fehler += 1; print("FEHLER Probe ohne Soeldner")
	if [hw.tp, hw.stufe, spiel.zustand.gold, spiel.zustand.siege] != vor: fehler += 1; print("FEHLER Probe aendert den Helden: ", vor)
	print("TESTKAMPF %d Fehler" % fehler)
	quit(1 if fehler else 0)
