extends SceneTree
# 764 (Chef 09.11., 14:49): der Heldenreiter zeigt die Zustände der Leiste mit Erklärung ([870.14.zustand.*]); ohne Zustand kein
# Abschnitt; die Zeilen passen auf den Schirm (1080 × 2340). Ausgabe „ZUSTAENDE764 n Fehler“.
#   ~/godot/godot --headless --path . -s res://tests/zustaende_764.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func texte(n: Node) -> String:
	return " | ".join(n.find_children("*", "Label", true, false).map(func(l): return String(l.text))).replace(char(0xA0), " ").replace(char(0x202F), " ")   # ohne_waise: geschuetzte Leerzeichen

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Probe", "Mensch", "Wachsoldat", z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	m.reiter = "held"
	m.baue()
	await process_frame
	pruefe(not texte(m.inhalt).contains("ZUSTÄNDE"), "ohne Zustand kein Abschnitt")
	z.leiden["POISON"] = 3
	z.leiden["BLEED"] = 2
	m.baue()
	await process_frame
	await process_frame
	var t := texte(m.inhalt)
	pruefe(t.contains("ZUSTÄNDE") and t.contains("Gift") and t.contains("Schaden zu Beginn jeder Runde. Abwehr mit Zähigkeit."), "Gift mit Erklärung")
	pruefe(t.contains("Blut") and t.contains("Schaden jede Runde, Heilung nur halb so stark."), "Blutung mit Erklärung")
	var frei := m.get_viewport_rect().size.x - 48 * Menue.DP
	pruefe(m.inhalt.get_combined_minimum_size().x <= frei + 0.5, "passt auf den Schirm (%.0f von %.0f)" % [m.inhalt.get_combined_minimum_size().x, frei])
	# t282.12 (Chef 13.11., 10:25): „Betrunken“ stand senkrecht, ein Buchstabe je Zeile; jedes Schild in einer Zeile, so breit wie sein Wort
	z.met = Rast.BETRUNKEN
	m.baue()
	await process_frame
	await process_frame
	for st in ["POISON", "BLEED", "DRUNK"]:
		var kw := m.inhalt.find_child("Schild_" + st, true, false) as Label
		pruefe(kw != null and kw.get_line_count() == 1 and kw.size.x >= kw.get_minimum_size().x - 0.5 and kw.size.x > kw.size.y, "Schild %s waagerecht in einer Zeile (%s)" % [st, str(kw.size) if kw else "fehlt"])
	pruefe(texte(m.inhalt).contains("Betrunken"), "Betrunken steht im Heldenreiter")
	var l := Leiste.new()
	root.add_child(l)
	await process_frame
	if l.has_method("zeige"):
		l.zeige(hw, z, false)
		pruefe(l.zustaende_da, "Leiste weiß vom Zustand (Antippen öffnet den Heldenreiter)")
	print("ZUSTAENDE764 %d Fehler" % fehler)
	quit(1 if fehler else 0)
