extends SceneTree
# 591 (Chef 07.11., 268.6: „Gackern und Geräusch Kaninchen gibt es nicht“): im echten Spiel (spiel.tscn, Dorf, Klang wie im Bau) geht
# der Held Kachel fuer Kachel auf ein Huhn zu; gezaehlt wird, was der Klang dabei spielt. Braucht daten/dorftiere und daten/klang.
# Ohne Bild. Aufruf: im Ordner godot mit -s res://tests/tierflucht_591.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if not DirAccess.dir_exists_absolute("res://daten/dorftiere"):
		print("TIERFLUCHT591 ohne Dorftiere")
		quit(0)
		return
	Sprache.lade()
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	while spiel.ui.spricht(): spiel.ui.naechste(); await process_frame
	spiel.betrete("village", Vector2i(16, 16), "DOWN")
	for i in 30: await process_frame
	while spiel.ui.spricht(): spiel.ui.naechste(); await process_frame
	var kl = root.get_node_or_null("Klang")
	pruefe(kl != null, "Klang geladen")
	if kl == null: quit(1); return
	var huhn = null
	var huehner: Array = []   # Lauf 280: zwei Hühner je Heuballen; floh das Nachbarhuhn (Laute da), blieb das gemessene stehen
	for n in spiel.find_children("*", "Node3D", true, false):
		var d = n.get("daten")
		if d is Dictionary and String(d.get("tier", "")) == "huhn":
			huehner.append(n)
			if huhn == null: huhn = n
	pruefe(huhn != null, "ein Huhn im Dorf")
	if huhn == null: quit(1); return
	print("Huhn bei %s, Eltern %s, Held-Eltern %s, ortsart %s, ruhig %s" % [huhn.kachel, huhn.get_parent().name, spiel.held.get_parent().name, kl.ortsart, kl._ruhig()])
	var ziel: Vector2i = huhn.kachel
	var start := ziel + Vector2i(-6, 0)
	for dx in [-6, -7, -5, 6, 7, 5]:
		if spiel.karte.begehbar(ziel + Vector2i(dx, 0)): start = ziel + Vector2i(dx, 0); break
	spiel.held.setze(start, "RIGHT")
	for i in 90: await process_frame   # 3 s: Klang findet die Tiere (alle 2 s)
	var vorher: int = kl._naechster
	var schritt := Vector2i(signi(ziel.x - start.x), 0)
	var t := start
	var floh := false
	for k in 8:
		if t + schritt == huhn.kachel or not spiel.karte.begehbar(t + schritt): break
		t += schritt
		spiel.held.setze(t, "RIGHT")
		for i in 12: await process_frame
		for h in huehner: floh = floh or (bool(h.flucht) and h.kachel.distance_to(t) <= 4.0)   # ein Huhn nahe beim Helden flieht
	for i in 30: await process_frame
	var laute: Array = []
	for i in range(vorher, kl._naechster):
		var p = kl._effekte[i % kl._effekte.size()]
		if p.stream: laute.append(String(p.stream.resource_path).get_file())
	print("Held bis %s, Huhn floh %s, jetzt %s; Laute: %s" % [t, floh, huhn.kachel, laute])
	pruefe(floh, "ein Huhn nahe beim Helden flieht")
	pruefe(laute.any(func(n): return String(n).begins_with("hen_alarm") or String(n).begins_with("hen_flap")), "Gackern oder Flügel zu hören")
	print("TIERFLUCHT591 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
