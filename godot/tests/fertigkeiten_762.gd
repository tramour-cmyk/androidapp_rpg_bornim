extends SceneTree
# 762 (Chef 09.11., 14:49; eigener Reiter 20:59): Fertigkeiten nach BRS mit Wert und Rang. Ohne Bild: ein Wachsoldat (Schild,
# Mittlere Rüstung, Einhänder je 10) zeigt im Heldenreiter höchstens drei Zeilen „<Name> … Anfänger  10“ und den Sprung, im Reiter
# „Fertigkeiten“ die acht Gruppen (Bergbau nicht, 461c), seine drei mit Rang, die übrigen matt; alles im Kasten. Ein Held ohne BRS
# (alter Spielstand) hat weder Reiter noch Abschnitt; die Ränge nach dem Handbuch [423.rang]. Braucht godot/daten wie im Bau.
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
	Bedienung.lade()
	var gemerkt: Dictionary = Bedienung.fert_gruppen.duplicate()
	Bedienung.fert_gruppen = {}
	for r in [[0, "Anfänger"], [24, "Anfänger"], [25, "Geselle"], [49, "Geselle"], [50, "Meister"], [75, "Großmeister"], [100, "Großmeister"]]:
		pruefe("Rang", String(Menue.rang_von(r[0])[1]) == r[1], "%d: %s statt %s" % [r[0], Menue.rang_von(r[0])[1], r[1]])
	for brs in [true, false]:
		var z := Zustand.new()
		var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
		if brs: z.brs = BrsHeld.neu("Mensch", "Wachsoldat").als_daten()
		var m := Menue.new(hw, z)
		root.add_child(m)
		m.reiter = "held"; m.baue()
		for i in 6: await process_frame
		var t := texte(m.inhalt, [])
		pruefe("Kopf", t.has("FERTIGKEITEN") == brs, "brs=%s: %s" % [brs, t.has("FERTIGKEITEN")])
		pruefe("Reiter", m.leiste.get_children().any(func(k): return (k as Control).tooltip_text == "Fertigkeiten") == brs, "brs=%s" % brs)
		if brs:
			pruefe("Sprung", t.has("FERTIGKEITEN ›"), str(t))
			for f in z.brs["fertigkeiten"]:
				var i := t.find(String(f))
				pruefe("Zeile " + String(f), i >= 0 and i + 1 < t.size() and t[i + 1] == "Anfänger  10", str(t.slice(maxi(i, 0), i + 2)))
			var rr: Rect2 = m.rolle.get_global_rect()
			for l in m.inhalt.find_children("*", "Label", true, false):
				var g: Rect2 = (l as Label).get_global_rect()
				pruefe("im Kasten", g.end.x <= rr.end.x + 0.5, "%s endet %.0f, Kasten %.0f" % [(l as Label).text.left(30), g.end.x, rr.end.x])
			m.tippe_reiter("fertigkeiten")
			for i in 6: await process_frame
			var r2 := texte(m.inhalt, [])
			for gr in ["WAFFEN", "RÜSTUNG", "SCHATTEN", "MAGIE", "WILDNIS", "GESELLSCHAFT", "SAMMELN", "HANDWERK"]:
				pruefe("Gruppe " + gr, r2.has(gr), str(r2))
			for f in z.brs["fertigkeiten"]:
				var i := r2.find(String(f))
				pruefe("Reiterzeile " + String(f), i >= 0 and i + 1 < r2.size() and r2[i + 1] == "Anfänger  10", str(r2.slice(maxi(i, 0), i + 2)))
			var matt := "\n".join(r2)
			# Klappen (Chef 21:33): Gruppen ohne Geuebtes zu, Kopf mit Anzahl; Antippen oeffnet und wird gemerkt
			pruefe("Schatten zu", not matt.contains("Schleichen"), matt.left(200))
			pruefe("Anzahl Schatten", r2.has("0/%d" % (BrsHeld.e()["fertigkeiten"]["Schatten"] as Array).size()), str(r2))
			var kopf: Control = m.inhalt.find_child("Gruppe_Schatten", true, false)
			pruefe("Kopf Schatten antippbar", kopf != null and kopf.size.y >= 47.0 * Menue.DP, str(kopf.size if kopf else null))
			var wz: Control = kopf.find_child("Winkel", true, false) if kopf else null
			pruefe("Winkel zu nach rechts", wz != null and is_zero_approx(wz.rotation), str(wz.rotation if wz else null))
			var ww: Control = m.inhalt.find_child("Gruppe_Waffen", true, false).find_child("Winkel", true, false)
			pruefe("Winkel offen nach unten", is_equal_approx(ww.rotation, PI / 2), str(ww.rotation))
			m.klappe_gruppe("Schatten", false)
			for i in 6: await process_frame
			r2 = texte(m.inhalt, [])
			matt = "\n".join(r2)
			pruefe("matt Schleichen", matt.contains("Schleichen, Spähen"), matt.left(200))
			pruefe("gemerkt", Bedienung.fert_gruppen.get("Schatten", false) == true, str(Bedienung.fert_gruppen))
			m.klappe_gruppe("Waffen", true)
			for i in 6: await process_frame
			var r3 := texte(m.inhalt, [])
			pruefe("Waffen zu", not r3.has("Einhänder") and r3.has("WAFFEN"), str(r3))
			m.klappe_gruppe("Waffen", false)
			for i in 6: await process_frame
			pruefe("kein Bergbau", not matt.contains("Bergbau"), "")
			pruefe("keine Illusion, keine Beschwörung (984.1)", not matt.contains("Illusion") and not matt.contains("Beschwörung"), matt.left(200))
			for zl in r2:
				if String(zl).begins_with("Zweihänder"): pruefe("Einhänder nicht matt", not String(zl).contains("Einhänder"), zl)
			for l in m.inhalt.find_children("*", "Label", true, false):
				var g: Rect2 = (l as Label).get_global_rect()
				pruefe("Reiter im Kasten", g.end.x <= rr.end.x + 0.5, "%s endet %.0f, Kasten %.0f" % [(l as Label).text.left(30), g.end.x, rr.end.x])
		m.queue_free()
		await process_frame
	Bedienung.fert_gruppen = gemerkt
	Bedienung.speichere()
	print("FERTIGKEITEN762 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
