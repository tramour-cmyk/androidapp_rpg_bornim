extends SceneTree
# 636 (Abgleich 620.2a): öffnet Jorin den Schlagbaum (Flagge barrier_open), hört man das Türgeräusch wie alt (Game.kt SetFlag,
# Sound.DOOR); andere Flaggen klingen nicht. Braucht godot/daten wie im Bau (Klang). Ohne Bild.
# 636 A: der Testmodus „Klang“ zeigt über der Welt, ob das Türgeräusch spielt, abgebrochen oder gar nicht gestartet wurde.
# Aufruf: im Ordner godot mit -s res://tests/schlagbaum_636.gd -> „SCHLAGBAUM636 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut    " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func laute(kl, vorher: int) -> Array:
	var r: Array = []
	for i in range(vorher, kl._naechster):
		var p = kl._effekte[i % kl._effekte.size()]
		if p.stream: r.append(String(p.stream.resource_path).get_file())
	return r

func _lauf() -> void:
	Sprache.lade()
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	while spiel.ui.spricht(): spiel.ui.naechste(); await process_frame
	spiel.betrete("village", Vector2i(17, 4), "UP")
	for i in 30: await process_frame
	while spiel.ui.spricht(): spiel.ui.naechste(); await process_frame
	var kl = root.get_node_or_null("Klang")
	pruefe(kl != null, "Klang geladen")
	if kl == null: quit(1); return
	var vorher: int = kl._naechster
	spiel.spiele([{"art": "flagge", "flagge": Geschichte.QUEST_STARTED}])
	await process_frame
	var l1 := laute(kl, vorher)
	pruefe(not l1.any(func(n): return String(n).begins_with("door")), "andere Flagge ohne Türgeräusch: %s" % str(l1))
	vorher = kl._naechster
	spiel.spiele([{"art": "flagge", "flagge": Geschichte.BARRIER_OPEN}])
	await process_frame
	var l2 := laute(kl, vorher)
	pruefe(l2.any(func(n): return String(n).begins_with("door")), "Schlagbaum auf mit Türgeräusch: %s" % str(l2))
	pruefe(spiel.zustand.has(Geschichte.BARRIER_OPEN), "Flagge gesetzt")
	# 636 A: Anzeige „Klang“ im Testmodus
	Testmodus.klang = true
	spiel.ui.richte_ein()
	for i in 16: await process_frame
	var txt := String(spiel.ui.mess.text)
	pruefe(spiel.ui.mess.visible, "Anzeige Klang sichtbar")
	pruefe(txt.contains("Klang: alle") and txt.contains("door_") and txt.contains("spielt"), "Anzeige: Türgeräusch spielt: " + txt.replace("\n", " | "))
	for i in kl.STROEME: kl.effekt("click", 0.35)
	for i in 16: await process_frame
	txt = String(spiel.ui.mess.text)
	pruefe(txt.contains("door_") and txt.contains("abgebrochen"), "Anzeige: verdrängter Klang abgebrochen: " + txt.replace("\n", " | "))
	kl.effekte_an = false
	kl.effekt("door")
	kl.effekte_an = true
	kl.effekt("gibtsnicht")
	for i in 16: await process_frame
	txt = String(spiel.ui.mess.text)
	pruefe(txt.contains("door  0.80  Effekte aus") and txt.contains("gibtsnicht  0.80  keine Aufnahme"), "Anzeige: nicht gestartet mit Grund: " + txt.replace("\n", " | "))
	Testmodus.klang = false
	print("SCHLAGBAUM636 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
