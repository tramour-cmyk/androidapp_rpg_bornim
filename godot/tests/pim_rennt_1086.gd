extends SceneTree
# 1086 (Chef 13.11., 15:47, t283.5, schon t282.9: „ich habe jetzt Pim 5 Goldstücke gegeben. Text sagt, er rennt heim, steht aber
# neben mir, passiert nichts … an der Tür geklopft … gab eh keinen Dank“): der echte Ablauf im Spiel, wie der Chef ihn geht. Der Held
# steht neben Pim am Schlagbaum (10 Uhr), spricht ihn an (spiel.gd sprich), wählt „Gib Pim 5 Gold“, liest das Gespräch zu Ende und
# bleibt stehen. Danach muss Pim losrennen (leute.gd eilt), bei seiner Hütte ankommen, und dann dankt die Mutter beim Klopfen
# (kein „unterwegs“ mehr). pim_verband_842 setzte die Flagge und rief plan_jetzt selbst auf, darum fand er es nicht.
# Aufruf: im Ordner godot mit -s res://tests/pim_rennt_1086.gd -> „PIMRENNT1086 0 Fehler“ (Exit 0)

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func pim_von(spiel) -> Leute:
	for l in spiel.leute.get_children():
		if l is Leute and String(l.daten.get("id", "")) == "pim": return l
	return null

func _lauf() -> void:
	var platz1_vorher := FileAccess.file_exists(Spielstand.datei(1))
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	var sz: Zustand = spiel.zustand
	sz.minuten = 10 * 60
	sz.gold = 12
	for f in ["intro_done", "quest_started"]: sz.setze(f)
	await spiel.test_tat("teleport", ["village", 15, 15, "UP"])
	for i in 10: await process_frame
	var pim := pim_von(spiel)
	if pim == null:   # am Rechner ohne gebaute Leute: Pim ohne Modell, der Ablauf ist derselbe
		print("PIMRENNT1086 Pim ohne Modell (am Rechner ohne Bau)")
		for d in spiel.karte.daten.get("leute", []):
			if String(d["id"]) == "pim": spiel.leute.add_child(Leute.new(spiel.karte, d, spiel.held))
		for i in 3: await process_frame
		pim = pim_von(spiel)
	pruefe(pim != null, "Pim fehlt im Dorf")
	if pim == null:
		print("PIMRENNT1086 %d Fehler" % fehler)
		quit(1)
		return
	pim.kachel = Vector2i(15, 14)
	pim.position = spiel.karte.kachel_pos(pim.kachel)
	pim.weg.clear()
	spiel.held.setze(Vector2i(15, 15), "UP")
	for i in 5: await process_frame
	# ansprechen wie im Spiel, Gold wählen, zu Ende lesen
	spiel.sprich(pim)
	var n := 0
	while not spiel.ui.knopf_bereit() and spiel.ui.spricht() and n < 8:
		spiel.ui.weiter(); await process_frame
		if not spiel.ui.knopf_bereit(): spiel.ui.weiter(); await process_frame
		n += 1
	pruefe(spiel.knopf_offen.size() == 2, "Knöpfe Überreden und Gold: %d" % spiel.knopf_offen.size())
	spiel.ui.knopf_im_text.emit(1)
	await process_frame
	pruefe(sz.has(Geschichte.PIM_GOLD_HEIM) and sz.gold == 7, "Gold gegeben: Flagge %s, Gold %d" % [sz.has(Geschichte.PIM_GOLD_HEIM), sz.gold])
	n = 0
	while spiel.ui.spricht() and n < 20:
		spiel.ui.weiter(); await process_frame
		n += 1
	pruefe(not spiel.ui.spricht(), "Gespräch endet nicht")
	var start := pim.kachel
	var ziel := Vector2i(17, 24)
	var d0 := absi(start.x - ziel.x) + absi(start.y - ziel.y)
	# der Held bleibt stehen; nach 3 s muss Pim unterwegs sein
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 3000: await process_frame
	var d1 := absi(pim.kachel.x - ziel.x) + absi(pim.kachel.y - ziel.y)
	pruefe(pim.eilt or d1 <= 2, "nach 3 s rennt Pim nicht heim (eilt %s, schaut %s, zugewandt %d)" % [pim.eilt, pim.schaut, pim.zugewandt_bis])
	pruefe(d1 < d0, "nach 3 s steht Pim noch da: %s (vorher %s)" % [pim.kachel, start])
	# ankommen (höchstens 20 s), dann kein „unterwegs“ mehr: die Mutter dankt
	t0 = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 20000 and (pim.eilt or absi(pim.kachel.x - ziel.x) + absi(pim.kachel.y - ziel.y) > 2): await process_frame
	pruefe(not pim.eilt and absi(pim.kachel.x - ziel.x) + absi(pim.kachel.y - ziel.y) <= 2, "Pim kommt nicht an: %s, eilt %s" % [pim.kachel, pim.eilt])
	pruefe(not spiel.pim_rennt_heim() and Geschichte.pim_gold_dankt(sz), "danach dankt die Mutter nicht (unterwegs %s)" % spiel.pim_rennt_heim())
	spiel.queue_free()
	await process_frame
	if not platz1_vorher: Spielstand.loesche(1)
	print("PIMRENNT1086 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
