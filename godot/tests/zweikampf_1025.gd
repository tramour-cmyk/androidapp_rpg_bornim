extends SceneTree
# 1025 (Chef 12.11., 10:25–10:28, Bilder Probekampf Wölfe, Build 278): zwei Kämpfe zugleich. Ohne Bild: während ein Kampf läuft, zieht
# die Herde nicht und kein zweiter Kampf beginnt (auch nicht aus dem Testmenü oder beim Weg in den Wald, die `im_kampf` nie setzten);
# am Ende ist der Kampfort abgebaut und die Welt wieder da, bei Sieg, Flucht und noch offenem Bericht.
# Aufruf im Ordner godot: --headless -s res://tests/zweikampf_1025.gd   (Ende 0 = alles richtig)

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FALSCH %s %s" % [was, wie])
	else: print("ok %s" % was)

func _kampf_da(spiel, alt) -> Object:
	var t0 := Time.get_ticks_msec()
	while (spiel.kampf == null or spiel.kampf == alt or spiel.kampf.mars == null) and Time.get_ticks_msec() - t0 < 20000: await process_frame
	return spiel.kampf if spiel.kampf != alt else null

func _zu_ende(k) -> void:
	k.mars.set_autopilot(true)
	if not k.busy: k.go_on()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 60000:
		await process_frame
		if k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty(): break
		if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
			k.mars.set_autopilot(true)
			if k.mars.pilot_next(): k.go_on()
			else:
				var ts: Array = k.mars.targets(k.mars.current())
				k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])

## Orte (Kampforte) in der Welt: der Kampfort hängt als Knoten im Baum, nach dem Kampf darf keiner übrig sein
func _orte(spiel) -> int:
	var n := 0
	for k in spiel.get_tree().get_root().find_children("*", "Node3D", true, false):
		var s = k.get_script()
		if s != null and String(s.resource_path).ends_with("kampf/kampfort.gd"): n += 1
	return n

func _lauf() -> void:
	Engine.time_scale = 30.0
	Testmodus.probe_volk = "Mensch"; Testmodus.probe_waffe = "*"; Testmodus.probe_neben = "*"; Testmodus.probe_soeldner = ""
	Testmodus.probe_tasche = "zwei"; Testmodus.probe_leben = "voll"; Testmodus.probe_zeit = ""; Testmodus.probe_zug = ""
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var vorige = null
	# 1: Probekampf aus dem Testmenü; während er läuft, ruht die Welt und kein zweiter Kampf beginnt
	spiel.test_tat("probe", ["WOLVES", "Herumtreiber", 3, false])
	var k = await _kampf_da(spiel, vorige)
	if k == null: pruefe("Probekampf kommt", false); return
	pruefe("im Kampf gesperrt (im_kampf)", spiel.im_kampf, "im_kampf %s" % spiel.im_kampf)
	var vor_orten := _orte(spiel)
	pruefe("genau ein Kampfort", vor_orten == 1, str(vor_orten))
	# ein Monster der Karte greift mitten im Probekampf an (Herde.schritt → spiel._kampf_auf_karte)
	spiel._kampf_auf_karte("wolf", "NORMAL", null)
	for i in 10: await process_frame
	pruefe("kein zweiter Kampf aus der Herde", spiel.kampf == k and _orte(spiel) == 1, "%s, %d Kampforte" % ["derselbe" if spiel.kampf == k else "anderer", _orte(spiel)])
	# und der Weg in den Wald (spiel.gd kampf_im_wald, ohne im_kampf) ebenso nicht
	var zweiter: String = await spiel.kampf_im_wald(spiel.held.kachel, "WOLVES")
	pruefe("kein zweiter Kampf aus dem Wald", zweiter == "NONE" and spiel.kampf == k and _orte(spiel) == 1, "%s, %d Kampforte" % [zweiter, _orte(spiel)])
	# 2: Sieg; danach ist der Kampfort abgebaut und die Welt wieder sichtbar
	await _zu_ende(k)
	pruefe("Bericht offen: Welt ruht weiter", spiel.im_kampf, "im_kampf %s" % spiel.im_kampf)
	k.finish()
	var t0 := Time.get_ticks_msec()
	while spiel.kampf != null and Time.get_ticks_msec() - t0 < 20000: await process_frame
	for i in 10: await process_frame
	pruefe("nach dem Kampf kein Kampfort mehr", _orte(spiel) == 0, "%d Kampforte" % _orte(spiel))
	pruefe("nach dem Kampf Welt und Oberfläche da", spiel.visible and spiel.ui.visible, "Welt %s, Oberfläche %s" % [spiel.visible, spiel.ui.visible])
	pruefe("nach dem Kampf wieder frei", not spiel.im_kampf, "im_kampf %s" % spiel.im_kampf)
	# 3: Flucht (Kampf verlassen) baut ebenso ab
	vorige = spiel.kampf
	spiel.test_tat("probe", ["WOLVES", "Herumtreiber", 3, false])
	var k2 = await _kampf_da(spiel, vorige)
	if k2 == null: pruefe("zweiter Probekampf kommt", false)
	else:
		k2.mars.outcome = "FLED"
		k2.finish()
		var t1 := Time.get_ticks_msec()
		while spiel.kampf != null and Time.get_ticks_msec() - t1 < 20000: await process_frame
		for i in 10: await process_frame
		pruefe("nach der Flucht kein Kampfort mehr", _orte(spiel) == 0, "%d Kampforte" % _orte(spiel))
		pruefe("nach der Flucht wieder frei", not spiel.im_kampf and spiel.visible and spiel.ui.visible,
			"im_kampf %s, Welt %s, Oberfläche %s" % [spiel.im_kampf, spiel.visible, spiel.ui.visible])
	Engine.time_scale = 1.0
	print("ZWEIKAMPF1025 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler > 0 else 0)
