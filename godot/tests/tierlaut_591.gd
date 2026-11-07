extends SceneTree
# 591 (Chef 07.11., 268.6: „Gackern und Geräusch Kaninchen gibt es nicht, Hühner laufen nur weg, kein Flattern wie in der alten
# Fassung“): ein echtes Dorftier (leute.gd) flieht vor dem Helden; klang.gd spielt dabei, was alt HenSound spielte (Huhn: Alarm und
# Fluegel, Kaninchen: Huschen). Gezaehlt an den Effektspielern des Klangs. Braucht godot/daten/klang wie im Bau. Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/tierlaut_591.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	await process_frame
	var kl = root.get_node_or_null("Klang")
	pruefe(kl != null, "Klang geladen")
	if kl == null: quit(1); return
	var n0: int = kl._naechster
	kl.effekt("hen_alarm", 0.4)
	pruefe(kl._naechster - n0 == 1, "ein Effekt spielt (Gegenprobe)")
	var k := Karte.lade("village")
	for tier in ["huhn", "kaninchen"]:
		var hof := Node3D.new()
		root.add_child(hof)
		var held := Node3D.new()
		hof.add_child(held)
		var start := Vector2i(27, 24)
		var l := Leute.new(k, {"id": tier + "1", "x": start.x, "y": start.y, "streifen": 2, "tier": tier, "fell": "grau"}, held)
		hof.add_child(l)
		l.position = k.kachel_pos(l.kachel)
		held.position = k.kachel_pos(start + Vector2i(-5, 0))
		kl._held = held
		kl._tiere_suche = 0.0
		kl._tierlaute(100.0)   # Tier gefunden, Held weit
		kl._tierlaute(100.0)
		var vorher: int = kl._naechster
		held.position = k.kachel_pos(start + Vector2i(-1, 0))
		var floh: bool = l.fliehe()
		kl._tierlaute(100.0)
		var laute: Array = []
		for i in range(vorher, kl._naechster):
			var p = kl._effekte[i % kl._effekte.size()]
			if p.stream: laute.append(String(p.stream.resource_path).get_file())
		pruefe(floh and not laute.is_empty(), "%s flieht (%s) mit Laut: %s" % [tier, floh, str(laute)])
		kl._held = null
		hof.queue_free()
		await process_frame
	print("TIERLAUT591 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
