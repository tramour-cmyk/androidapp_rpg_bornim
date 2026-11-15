extends SceneTree
# 1295 (Chef 15.11., 13:41, Build 286, Menü → Karte in der Blutzahnhöhle: „nicht mehr so richtig formatfüllend … unten an der Karte
# sind sie abgeschnitten“): das Kartenblatt füllt den freien Platz des Menüs bis über „Zurück“, gleich beim Öffnen des Menüs auf dem
# Reiter Karte und nach dem Wechsel von einem anderen Reiter; in Höhle, Wald und Dorf. Schirm wie am Handy 1080 × 2340.
# Ausgabe „KARTENHOEHE1295 <n> Fehler“.   ~/godot/godot --headless --path . -s res://tests/kartenhoehe_1295.gd

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	print(("gut    " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	for o in [["cave", Vector2i(10, 18)], ["forest", Vector2i(9, 29)], ["village", Vector2i(19, 13)]]:
		spiel.betrete(o[0], o[1], "UP")
		if spiel.herde: spiel.herde.aus = true
		await create_timer(0.3).timeout
		var lage := []
		for weg in ["direkt", "vom Reiter Held"]:
			spiel.ui.sage([])
			spiel.oeffne_menue("karte" if weg == "direkt" else "held")
			await create_timer(0.3).timeout
			var mm: Array = root.find_children("*", "Menue", true, false)
			if mm.is_empty():
				pruefe(false, "%s, %s: Menü geht nicht auf" % [o[0], weg]); continue
			var m: Menue = mm[0]
			if weg != "direkt":
				m.reiter = "karte"; m.baue()
				await create_timer(0.3).timeout
			var kr: Kartenreiter = m.find_children("*", "Kartenreiter", true, false)[0]
			var rahmen: Control = kr.flaeche.get_parent()
			var frei: float = m.rolle.size.y
			pruefe(kr.size.y >= frei - 2.0, "%s, %s: Karte %.0f hoch, Platz %.0f, Blatt sichtbar %.0f" % [o[0], weg, kr.size.y, frei, rahmen.size.y])
			var fl = kr.flaeche
			lage.append([fl.mass, fl.versatz])
			if lage.size() == 2:   # beide Wege öffnen gleich: gleiche Größe und Lage des Blatts (Held in der Mitte, soweit der Rand es lässt)
				pruefe(absf(lage[0][0] - lage[1][0]) < 0.001 and (lage[0][1] as Vector2).distance_to(lage[1][1]) < 1.0, "%s: Blatt öffnet gleich (Maß %.3f/%.3f, Versatz %s/%s)" % [o[0], lage[0][0], lage[1][0], lage[0][1], lage[1][1]])
			m.queue_free()
			for e in root.find_children("*", "CanvasLayer", true, false): if e.get_child_count() == 0: e.queue_free()
			get_root().get_tree().paused = false
			await create_timer(0.3).timeout
	print("KARTENHOEHE1295 %d Fehler" % fehler)
	quit(1 if fehler else 0)
