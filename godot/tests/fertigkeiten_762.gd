extends SceneTree
# 762 (Chef 09.11., 14:49): der Heldenreiter zeigt die Fertigkeiten nach BRS mit Wert und Rang. Ohne Bild: ein Wachsoldat (Schild,
# Mittlere Rüstung, Einhänder je 10) zeigt den Abschnitt mit drei Zeilen „<Name> … Anfänger  10“, alles im Kasten; ein Held ohne
# BRS (alter Spielstand) zeigt ihn nicht; die Ränge nach dem Handbuch [423.rang]. Braucht godot/daten wie im Bau.
# Aufruf: im Ordner godot, --headless -s res://tests/fertigkeiten_762.gd

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FEHLER %s %s" % [was, wie])

func texte(n: Node, out: Array) -> Array:
	if n is Label: out.append((n as Label).text)
	for k in n.get_children(): texte(k, out)
	return out

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	for r in [[0, "Anfänger"], [24, "Anfänger"], [25, "Geselle"], [49, "Geselle"], [50, "Meister"], [75, "Großmeister"], [100, "Großmeister"]]:
		pruefe("Rang", String(Menue.rang_von(r[0])[1]) == r[1], "%d: %s statt %s" % [r[0], Menue.rang_von(r[0])[1], r[1]])
	for brs in [true, false]:
		var z := Zustand.new()
		var hw := Heldwerte.erschaffe("Thora", "HUMAN", "FIGHTER", {}, z.neue_uid)
		if brs: z.brs = BrsHeld.neu("Mensch", "Wachsoldat").als_daten()
		var m := Menue.new(hw, z)
		root.add_child(m)
		m.reiter = "held"; m.baue()
		for i in 6: await process_frame
		var t := texte(m.inhalt, [])
		pruefe("Kopf", t.has("FERTIGKEITEN") == brs, "brs=%s: %s" % [brs, t.has("FERTIGKEITEN")])
		if brs:
			for f in z.brs["fertigkeiten"]:
				var i := t.find(String(f))
				pruefe("Zeile " + String(f), i >= 0 and i + 1 < t.size() and t[i + 1] == "Anfänger  10", str(t.slice(maxi(i, 0), i + 2)))
			var rr: Rect2 = m.rolle.get_global_rect()
			for l in m.inhalt.find_children("*", "Label", true, false):
				var g: Rect2 = (l as Label).get_global_rect()
				pruefe("im Kasten", g.end.x <= rr.end.x + 0.5, "%s endet %.0f, Kasten %.0f" % [(l as Label).text.left(30), g.end.x, rr.end.x])
		m.queue_free()
		await process_frame
	print("FERTIGKEITEN762 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
