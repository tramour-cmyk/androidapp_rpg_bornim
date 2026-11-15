extends SceneTree
# 1268.1 (1268 A, Chef 15.11., 10:51; Systemfrage Tür 1169): Wächter für die Fehlerart Tür. Bisher kam jeder Türfehler einzeln
# zurück (611 Klopfen ohne Klang, 629.1 ohne Namen der Stimme, 636 Schlagbaum ohne Türgeräusch, 495 Held außerhalb des Grundrisses,
# 1063 Held blieb an der Tür stehen). Die eine Stelle im Code ist spiel.gd: _aktion (Klopfen) und geh_hinaus (Weg hinaus) für jede
# Tür aus daten/karten.json; dieser Test geht jede Tür der Daten durch, damit eine neue Tür oder eine Änderung an der Stelle nicht
# still einen alten Fehler zurückbringt. Nie abschalten (1268 A).
#  1. Daten: jedes Ziel ist eine bekannte Karte; ein offener Ausgang zu einer anderen Karte hat dort den Rückweg, und beide Wege
#     enden auf einer Kachel neben der Tür (vor der Tür, nicht darin, nicht weit weg).
#  2. Klopfen: an jeder Tür mit „klopfen“, tags und nachts, klingt es (knock, 611) und es steht eine Zeile da; eine gesprochene
#     Zeile (in Anführungszeichen) hat den Namen der Stimme (629.1), ohne Anführungszeichen.
#  3. Türgeräusch: der Weg hinaus durch jede offene Tür des Dorfs spielt „door“ (399.3).
# Daneben bleiben die Einzeltests klopfen_611 (Klang an 12/5), klopfen_629 (Namen der Stimme), schlagbaum_636, tuer_495 (Doppeltipp).
# Mit Klangliste (im Bau) zählt „keine Aufnahme“ als Fehler; am Rechner ohne Klänge nur, dass der Klang verlangt wird.
# Aufruf im Ordner godot: --headless -s res://tests/tuer_1268.gd -> „TUER1268 n Fehler, k Türen“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func neben(a: Vector2i, b: Vector2i) -> bool:
	return absi(a.x - b.x) + absi(a.y - b.y) == 1

## der Klang [id] wurde verlangt, seit das Protokoll leer war; mit Klangliste auch gespielt
func klang_da(kl: Node, id: String) -> bool:
	if kl == null: return false
	var mit_liste: bool = not kl.liste.get("sfx", []).is_empty()
	for e in kl.protokoll:
		var w := String(e.was)
		if w == id or (w.begins_with(id + "_") and w.substr(id.length() + 1).is_valid_int()):
			if not mit_liste or String(e.grund) in ["", "Effekte aus", "Blende"]: return true
			if not String(e.grund) in ["keine Aufnahme", "nicht geladen"]: return true
	return false

func _lauf() -> void:
	var alle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	var karten: Dictionary = alle["karten"]
	var tueren := 0

	# 1. Daten
	for id in karten:
		for a in karten[id].get("ausgaenge", []):
			var z: Dictionary = a["ziel"]
			var ziel := String(z["karte"])
			var t := Vector2i(int(a["x"]), int(a["y"]))
			pruefe(karten.has(ziel), "%s %s: Ziel %s unbekannt" % [id, t, ziel])
			if bool(a["verschlossen"]) or ziel == id or not karten.has(ziel): continue
			tueren += 1
			var an := Vector2i(int(z["x"]), int(z["y"]))
			var rueck := {}
			for r in karten[ziel].get("ausgaenge", []):
				if String(r["ziel"]["karte"]) == id and not bool(r["verschlossen"]) and neben(Vector2i(int(r["x"]), int(r["y"])), an): rueck = r
			pruefe(not rueck.is_empty(), "%s %s -> %s %s: kein Rückweg neben der Ankunft" % [id, t, ziel, an])
			if rueck.is_empty(): continue
			var zurueck := Vector2i(int(rueck["ziel"]["x"]), int(rueck["ziel"]["y"]))
			# Ausgänge am Kartenrand (Wald) sind eine Reihe: zurück neben irgendeinem Ausgang dieser Reihe zum selben Ziel
			var ok := false
			for b in karten[id].get("ausgaenge", []):
				if String(b["ziel"]["karte"]) == ziel and neben(Vector2i(int(b["x"]), int(b["y"])), zurueck): ok = true
			pruefe(ok, "%s %s -> %s: Rückweg endet auf %s, nicht vor der Tür" % [id, t, ziel, zurueck])

	# 2. und 3. im Spiel
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var kl := root.get_node_or_null("/root/Klang")
	pruefe(kl != null, "kein Klang")
	for id in karten:
		var klopf: Array = karten[id].get("ausgaenge", []).filter(func(a): return bool(a["verschlossen"]) and a.has("klopfen"))
		if klopf.is_empty(): continue
		spiel.betrete(id, Vector2i(1, 1), "DOWN")
		for i in 5: await process_frame
		for a in klopf:
			var t := Vector2i(int(a["x"]), int(a["y"]))
			var vor := Vector2i(int(a["ziel"]["x"]), int(a["ziel"]["y"]))
			tueren += 1
			for zeit in ["tag", "nacht"]:
				spiel.licht.nacht = 1.0 if zeit == "nacht" else 0.0
				spiel.licht.ziel = spiel.licht.nacht
				spiel.ui.zeilen.clear()
				spiel.ui.naechste()   # offene Zeile zu
				if kl: kl.protokoll.clear()
				spiel.held.setze(vor, "UP" if vor.y > t.y else ("DOWN" if vor.y < t.y else ("LEFT" if vor.x > t.x else "RIGHT")))
				pruefe(spiel.vor_ihm(vor) == t, "%s %s: von %s aus nicht die Tür vor dem Helden" % [id, t, vor])
				spiel._aktion()
				var text := String(spiel.ui.text.text)
				var wer := String(spiel.ui.sprecher.text)
				print("KLOPFEN %s %s %s: %s%s" % [id, t, zeit, (wer + ": ") if wer != "" else "", text.left(60)])
				pruefe(klang_da(kl, "knock"), "%s %s %s: Klopfen ohne Klang (611)" % [id, t, zeit])
				pruefe(spiel.ui.textfeld.visible and text != "", "%s %s %s: keine Zeile hinter der Tür" % [id, t, zeit])
				var gesprochen := text.begins_with("„") or text.begins_with("“")
				pruefe(not gesprochen, "%s %s %s: gesprochene Zeile ohne Namen der Stimme (629.1): %s" % [id, t, zeit, text.left(40)])
	spiel.licht.nacht = 0.0
	spiel.ui.zeilen.clear()
	spiel.ui.naechste()

	# 3. Türgeräusch
	spiel.betrete("village", Vector2i(1, 1), "DOWN")
	for i in 5: await process_frame
	for a in karten["village"].get("ausgaenge", []):
		var ziel := String(a["ziel"]["karte"])
		if bool(a["verschlossen"]) or ziel == "village" or ziel in spiel.WALD: continue
		if kl: kl.protokoll.clear()
		spiel.geh_hinaus(a)
		pruefe(klang_da(kl, "door"), "village -> %s: Weg hinaus ohne Türgeräusch (399.3)" % ziel)
		for i in 200:
			if not spiel.geht_hinaus: break
			await create_timer(0.1).timeout
		spiel.ui.zeilen.clear()
		spiel.ui.naechste()
		spiel.betrete("village", Vector2i(1, 1), "DOWN")
		for i in 5: await process_frame
	print("TUER1268 %d Fehler, %d Türen" % [fehler, tueren])
	quit(1 if fehler else 0)
