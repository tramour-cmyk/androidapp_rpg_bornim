extends SceneTree
# 416.7 (Chef 31.10., Build 143: „am Tresen in Schenke und Laden geht der Aktionsknopf nicht“): ohne Bild; der Held steht vor dem
# Tresen gegenueber Rowena (Schenke) und Thessa (Laden), Blick zum Tresen: der Knopf bietet TALK an und meint die Person dahinter
# (wie Navigation.actionTarget: gerade ueber den Tresen); schraeg ueber den Tresen nicht. Angetippt geht der Held vor den Tresen,
# nicht dahinter. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/tresen_4167.gd -> „TRESEN n Fehler“

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	for f in [["inn", "rowena"], ["shop", "thessa"]]:
		spiel.betrete(f[0], Vector2i(1, 1), "DOWN")
		for i in 5: await process_frame
		var wer: Leute = null
		for l in spiel.leute_liste():
			if String(l.daten.get("id", "")) == f[1]: wer = l
		if wer == null: print("FEHLER %s: %s fehlt" % f); fehler += 1; continue
		var k: Karte = spiel.karte
		var vor := wer.kachel + Vector2i(0, 2)
		if k.zeichen(wer.kachel + Vector2i(0, 1)) != "K": print("FEHLER %s: kein Tresen vor %s" % [f[0], wer.kachel]); fehler += 1; continue
		spiel.held.setze(vor, "UP")
		spiel.held.rotation.y = PI
		var pv: Array = spiel.person_vorn()
		var an: Array = spiel.angebot(vor)
		var gut: bool = pv[0] == wer and an[0] == "TALK"
		print("%s %s vor %s: %s %s %s" % [f[0], f[1], vor, pv[0].daten["id"] if pv[0] else "niemand", an, "" if gut else "FEHLER"])
		if not gut: fehler += 1
		# schraeg ueber den Tresen nicht (actionTarget: Ecke nie)
		var schraeg := vor + Vector2i(1, 0)
		if k.begehbar(schraeg) and k.zeichen(schraeg + Vector2i(0, -1)) == "K":
			spiel.held.setze(schraeg, "UP")
			var ps: Array = spiel.person_vorn()
			print("%s schraeg %s: %s %s" % [f[0], schraeg, ps[0].daten["id"] if ps[0] else "niemand", "FEHLER" if ps[0] == wer else ""])
			if ps[0] == wer: fehler += 1
		# angetippt: vor den Tresen, nicht dahinter
		var weit := vor
		for y in k.hoehe:
			for x in k.breite:
				var t := Vector2i(x, y)
				if k.begehbar(t) and absi(t.x - vor.x) + absi(t.y - vor.y) >= 3 and not k.weg(t, vor).is_empty(): weit = t
		spiel.held.setze(weit, "UP")
		var n: Vector2i = spiel.naechster_nachbar(wer.kachel)
		print("%s angetippt -> %s %s" % [f[0], n, "" if n == vor else "FEHLER (soll %s)" % vor])
		if n != vor: fehler += 1
	print("TRESEN %d Fehler" % fehler)
	quit(1 if fehler else 0)
