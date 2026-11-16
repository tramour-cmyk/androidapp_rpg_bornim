extends SceneTree
# 611 (Chef 07.11., 268.8: „Klopfen sollte deutlicher sein“): wie alt (Game.kt 1024, Sound.KNOCK, 215.1) hoert man es klopfen, wenn
# der Held an eine verschlossene Tuer im Dorf klopft (Aktionsknopf vor 12/5); dazu der Satz von drinnen. Braucht godot/daten wie im
# Bau (Klang). Ohne Bild. Aufruf: im Ordner godot mit -s res://tests/klopfen_611.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	while spiel.ui.spricht(): spiel.ui.naechste(); await process_frame
	spiel.betrete("village", Vector2i(12, 6), "UP")
	for i in 30: await process_frame
	while spiel.ui.spricht(): spiel.ui.naechste(); await process_frame
	spiel.held.setze(Vector2i(12, 6), "UP")
	spiel.held.rotation.y = atan2(0.0, -1.0)
	var kl = root.get_node_or_null("Klang")
	pruefe(kl != null, "Klang geladen")
	if kl == null: quit(1); return
	var vorher: int = kl._naechster
	spiel._aktion()
	await process_frame
	var laute: Array = []
	for i in range(vorher, kl._naechster):
		var p = kl._effekte[i % kl._effekte.size()]
		if p.stream: laute.append(String(p.stream.resource_path).get_file())
	pruefe(laute.any(func(n): return String(n).begins_with("knock_")), "Klopfen an 12/5 ist zu hoeren: %s" % str(laute))
	pruefe(spiel.ui.spricht(), "der Satz von drinnen steht da")
	print("KLOPFEN611 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
