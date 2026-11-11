extends SceneTree
# 581 (Abgleich 512b, Pruefer 05.11., 08:17): Reiter Ausruestung war breiter als der Schirm (Rand 11 statt 27 px), die Reiter
# sprangen beim Wechsel. Ohne Bild gemessen: in jedem Reiter liegt der Inhalt ganz im Kasten, der Rand bleibt 10 dp und die
# Reiterzeichen stehen in jedem Reiter an derselben Stelle. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot,
# --headless -s res://tests/menue_breite_581.gd

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FEHLER %s %s" % [was, wie])

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	for held in [["Thora", "Zwerg", "Wachsoldat"], ["Mira", "Elf", "Zauberlehrling"]]:
		var hw := BrsHeld.fuer_spiel(held[0], held[1], held[2], z.neue_uid)
		var m := Menue.new(hw, z)
		root.add_child(m)
		var lage := []
		for r in ["held", "tasche", "ausruestung", "chronik", "system"]:
			m.reiter = r; m.baue()
			for i in 6: await process_frame
			var rand := 24 * Menue.DP   # 630 (549a „Schirm“): Seitenrand 24 dp, ohne Kasten
			var kasten: Rect2 = m.rolle.get_global_rect()
			pruefe("Rand links", absf(kasten.position.x - rand) <= 1.0, "%s %s: %.0f statt %.0f px" % [held[0], r, kasten.position.x, rand])
			pruefe("Rand rechts", absf(1080.0 - kasten.end.x - rand) <= 1.0, "%s %s: %.0f statt %.0f px" % [held[0], r, 1080.0 - kasten.end.x, rand])
			var ri: Rect2 = m.inhalt.get_global_rect()
			var rr: Rect2 = m.rolle.get_global_rect()
			pruefe("Inhalt im Kasten", ri.position.x >= rr.position.x - 0.5 and ri.end.x <= rr.end.x + 0.5, "%s %s: Inhalt %.0f–%.0f, Kasten %.0f–%.0f" % [held[0], r, ri.position.x, ri.end.x, rr.position.x, rr.end.x])
			lage.append(m.leiste.get_children().map(func(k): return int(round(k.get_global_rect().position.x))))
		for i in range(1, lage.size()):
			pruefe("Reiter springen", lage[i] == lage[0], "%s: %s gegen %s" % [held[0], str(lage[i]), str(lage[0])])
		m.queue_free()
		await process_frame
	print("MENUEBREITE581 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
