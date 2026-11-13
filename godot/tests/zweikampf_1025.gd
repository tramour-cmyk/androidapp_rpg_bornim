extends SceneTree
# 1025 (von Sokrates; Chef 12.11., 10:25–10:28, Bilder Probekampf Wölfe, Build 278: zwei Kämpfe zugleich — Probekampf, dann das Rudel
# der Karte ohne Kampfort über der Karte; danach Kampfort schwarz, 7–8 Bilder/s, Kampfoberfläche über der Karte). Nachgestellt im
# ganzen Spiel ohne Bild: einen Probekampf starten und, während er läuft, die Karte angreifen lassen, wie Herde es tut (Signal
# kampf, _kampf_auf_karte, greife_an). Richtig: es entsteht kein zweiter Kampfort, die Karte ruht im Kampf (Herde zieht nicht),
# nach dem Kampf hängt kein Kampfort und keine Kampfoberfläche mehr im Baum, und das Rudel hat Schonzeit (Herde.frieden_bis,
# schonzeit) wie nach einem Kampf auf der Karte. Läuft ohne die gebauten Modelle (Platzhalterfiguren, nur die Abläufe zählen).
# Aufruf: im Ordner godot mit -s res://tests/zweikampf_1025.gd; maßgeblich ist die Zeile ZWEIKAMPF1025.

var fehler := 0


func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FALSCH ") + was)
	if not ok: fehler += 1


func _initialize() -> void:
	_lauf.call_deferred()


## alle Kampforte im Baum (kampf/kampfort.gd hängt unter /root, nicht unter spiel)
func _kampforte() -> Array:
	return root.find_children("*", "Node3D", true, false).filter(func(n):
		return n.get_script() != null and String(n.get_script().resource_path) == "res://kampf/kampfort.gd")


func _warte(bis: Callable, ms: int) -> void:
	var t0 := Time.get_ticks_msec()
	while not bis.call() and Time.get_ticks_msec() - t0 < ms:
		await process_frame


## wie spiel.gd welt_ruht (1025); vor dem Bau gab es die Abfrage nicht, dann zählt nur im_kampf (so stellt der Test den Fehler nach)
func _ruht(spiel) -> bool:
	return bool(spiel.welt_ruht()) if spiel.has_method("welt_ruht") else bool(spiel.im_kampf)


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	Testmodus.lade()
	Testmodus.an = true
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	print("Karte %s, Held %s" % [spiel.karte.id, spiel.held.kachel])
	# eine Herde wie auf den Karten mit Monstern (im Dorf gibt es keine); ohne „begegnungen“ bleibt ihre Liste leer,
	# frieden_bis und schonzeit prüfen trotzdem, was nach dem Kampf geschieht
	if spiel.herde == null:
		var h0 := Herde.new(spiel.karte, spiel)
		spiel.add_child(h0)
		h0.kampf.connect(spiel._kampf_auf_karte)
		spiel.herde = h0
		for i in 5: await process_frame
	var h: Herde = spiel.herde
	pruefe(h != null, "Herde da (%d Monster)" % (h.liste.size() if h != null else -1))

	# 1) Probekampf aus dem Reiter Test
	spiel.test_tat("probe", ["WOLVES", "FIGHTER", 3])
	await _warte(func(): return spiel.kampf != null, 30000)
	var k = spiel.kampf
	if k == null:
		print("FALSCH kein Probekampf"); _ende(); return
	for i in 10: await process_frame
	pruefe(_kampforte().size() == 1, "ein Kampfort (%d)" % _kampforte().size())
	pruefe(_ruht(spiel), "die Welt ruht im Probekampf")

	# 2) die Karte greift an, während der Probekampf läuft (drei Wege, wie Herde es tut)
	spiel._kampf_auf_karte("wolf", "NORMAL", null)
	for i in 5: await process_frame
	h.kampf.emit("wolf", "AMBUSHED", null)
	for i in 5: await process_frame
	if not h.liste.is_empty(): h.greife_an(h.liste[0])
	for i in 5: await process_frame
	pruefe(_kampforte().size() == 1, "kein zweiter Kampfort (%d)" % _kampforte().size())
	pruefe(spiel.kampf == k and is_instance_valid(k), "derselbe Kampf läuft weiter")

	# 3) die Karte ruht im Kampf: Herde zieht nicht (spiel.gd _process ruft schritt nur außerhalb des Kampfs)
	var jetzt_vorher: int = h.jetzt
	var orte_vorher: Array = h.liste.map(func(s): return s.kachel)
	for i in 40: await process_frame
	pruefe(h.jetzt == jetzt_vorher, "Herde zieht nicht im Kampf (jetzt %d → %d)" % [jetzt_vorher, h.jetzt])
	pruefe(h.liste.map(func(s): return s.kachel) == orte_vorher, "Monster stehen, wo sie standen")

	# 4) ganzer Bericht offen, dann Kampf beenden: nichts bleibt über der Karte liegen
	if k.ui != null: k.ui._show_full_log(true)
	for i in 10: await process_frame
	if k.mars.outcome == "ONGOING": k.test_end(true)
	await _warte(func(): return k.mars.outcome != "ONGOING", 40000)
	await _warte(func(): return not k.busy, 20000)
	for i in 30: await process_frame
	if is_instance_valid(k): k.finish()
	await _warte(func(): return spiel.kampf == null and spiel.visible, 30000)
	for i in 30: await process_frame
	# die Sperre fällt erst, wenn kampf_im_wald ganz durch ist (nach der Blende zurück in die Welt, 1025)
	await _warte(func(): return not _ruht(spiel), 10000)
	pruefe(_kampforte().is_empty(), "nach dem Kampf kein Kampfort mehr im Baum (%d)" % _kampforte().size())
	pruefe(spiel.visible and spiel.ui.visible, "Welt und Oberfläche wieder da")
	var ebenen: Array = root.find_children("*", "CanvasLayer", true, false).filter(func(c):
		return c.get_script() != null and String(c.get_script().resource_path) == "res://kampf/kampf_ui.gd")
	pruefe(ebenen.is_empty(), "keine Kampfoberfläche über der Karte (%d)" % ebenen.size())
	pruefe(not _ruht(spiel), "die Welt läuft wieder")
	pruefe(h.schonzeit > 0 and h.frieden_bis > h.jetzt, "Schonzeit nach dem Probekampf (schonzeit %d, Frieden noch %d ms)" % [h.schonzeit, h.frieden_bis - h.jetzt])

	# 5) danach läuft ein Kampf auf der Karte wieder an
	spiel._kampf_auf_karte("wolf", "NORMAL", null)
	await _warte(func(): return spiel.kampf != null, 30000)
	pruefe(spiel.kampf != null, "nach dem Probekampf ist ein Kampf auf der Karte wieder möglich")
	var k2 = spiel.kampf
	if k2 != null:
		if k2.mars.outcome == "ONGOING": k2.test_end(true)
		await _warte(func(): return k2.mars.outcome != "ONGOING", 40000)
		for i in 30: await process_frame
		if is_instance_valid(k2): k2.finish()
		await _warte(func(): return spiel.kampf == null and spiel.visible, 30000)
	_ende()


func _ende() -> void:
	print("ZWEIKAMPF1025 %d Fehler" % fehler)
	quit(1 if fehler else 0)
