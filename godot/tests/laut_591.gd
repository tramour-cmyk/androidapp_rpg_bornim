extends SceneTree
# 591 (Chef 08.11., 15:41, t269.10: „Kaninchen nicht hörbar; Huhn gackert kaum, Flattern kaum hörbar … tschack, tschack, tschack“):
# ohne Bild. Im Dorf ein Huhn und ein Kaninchen (ohne Modell) zwei Kacheln vom Helden; beim Losrennen zaehlt der Test, was der Klang spielt
# und wie laut: Huhn zweimal Gackern und dreimal Fluegel, das erste Gackern fast voll; Kaninchen vier Schritte im Gras, deutlich.
# Braucht daten/klang (sfx, liste.json wie im Bau). Aufruf im Ordner godot: headless, -s res://tests/laut_591.gd -> „LAUT591 …“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func warte(n: int) -> void:
	for i in n: await process_frame

func _lauf() -> void:
	Sprache.lade()
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await warte(5)
	while spiel.ui.spricht(): spiel.ui.naechste(); await process_frame
	spiel.betrete("village", Vector2i(16, 16), "DOWN")
	await warte(30)
	while spiel.ui.spricht(): spiel.ui.naechste(); await process_frame
	var kl = root.get_node_or_null("Klang")
	pruefe(kl != null, "Klang geladen")
	if kl == null: quit(1); return
	print("ortsart %s, ruhig %s, effekte %s, sfx %d" % [kl.ortsart, kl._ruhig(), kl.effekte_an, kl.liste.get("sfx", []).size()])
	var k: Karte = spiel.karte
	var held_k: Vector2i = spiel.held.kachel if spiel.held.get("kachel") is Vector2i else k.pos_kachel(spiel.held.position)
	for tier in ["huhn", "kaninchen"]:
		var t := Leute.new(k, {"id": "probe_" + tier, "tier": tier, "x": held_k.x + 2, "y": held_k.y, "streifen": 0}, spiel.held)
		spiel.held.get_parent().add_child(t)   # dort sucht der Klang die Tiere
		t.position = k.kachel_pos(t.kachel)
		kl._tiere_suche = 0.0
		await create_timer(0.5).timeout   # der Klang rechnet alle 100 ms (Spielzeit, nicht Bilder)
		print("%s: Klang kennt %d Tiere, sichtbar %s, Abstand %.1f" % [tier, kl._tiere.size(), t.is_visible_in_tree(), t.held_abstand()])
		var gespielt: Array = []   # [Datei, Pegel in dB]
		var i0: int = kl._naechster
		t.flucht = true
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 1500:
			await process_frame
			while i0 != kl._naechster:
				var p = kl._effekte[i0]
				if p.stream: gespielt.append([String(p.stream.resource_path).get_file().get_basename(), p.volume_db])
				i0 = (i0 + 1) % kl._effekte.size()
		print("%s: %s (flucht %s, schleier %.2f, Tier %s)" % [tier, gespielt, t.flucht, kl.schleier_pegel(), kl._tiere.values()])
		var zahl := func(v: String) -> int: return gespielt.filter(func(g): return String(g[0]).begins_with(v)).size()
		if tier == "huhn":
			pruefe(zahl.call("hen_alarm") == 2, "Huhn gackert zweimal (%d)" % zahl.call("hen_alarm"))
			pruefe(zahl.call("hen_flap") == 3, "Huhn schlaegt dreimal mit den Fluegeln (%d)" % zahl.call("hen_flap"))
			var erst: Array = gespielt.filter(func(g): return String(g[0]).begins_with("hen_alarm"))
			pruefe(not erst.is_empty() and float(erst[0][1]) > -3.0, "erstes Gackern fast voll (%s dB)" % (erst[0][1] if not erst.is_empty() else "–"))
		else:
			pruefe(zahl.call("step_grass") == 4, "Kaninchen huscht in vier Schritten (%d)" % zahl.call("step_grass"))
			var s: Array = gespielt.filter(func(g): return String(g[0]).begins_with("step_grass"))
			pruefe(not s.is_empty() and float(s[0][1]) > -4.0, "deutlich zu hoeren (%s dB)" % (s[0][1] if not s.is_empty() else "–"))
		t.queue_free()
		await warte(5)
	print("LAUT591 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
