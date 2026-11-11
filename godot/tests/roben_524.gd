extends SceneTree
# 521, 523, 524 (Chef 04.11., 12:01, t257 255.4/255.5: „Bestimmt hier hinten und vorne nicht, Leute.“): genau die zwei Roben vom Chef.
# Angelegt „Schattenwache“, epische Robe +2 GES, +2 RK, +2 Schadensreduktion, +2 STR; in der Tasche die Robe des Ankers, nur +18 %
# Standhaftigkeit. Gemessen: der Vergleich nennt jede Aenderung (RK, Geschicklichkeit, Staerke, Schadensreduktion,
# Standhaftigkeit), Urteil „gemischt“; in der Tasche und im Wechselschirm hat die Robe des Ankers ein Zeichen (◆) und eine Zahl in der
# Zeile, nicht nur „Oberkörper“.
# Aufruf: im Ordner godot mit -s res://tests/roben_524.gd -> „ROBEN524 n Fehler“

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func texte(n: Node) -> Array:
	return n.find_children("*", "Label", true, false).filter(func(l): return not l.is_queued_for_deletion() and l.is_visible_in_tree()).map(func(l): return String(l.text).replace(" ", " "))

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Probe", "Mensch", "Zauberlehrling", z.neue_uid)
	var schatten := z.ausruestung_dazu({"uid": 0, "base": "robe", "rarity": "EPIC", "ilvl": 1, "plus": 2, "rolls": [["DEX", 2], ["AC", 2], ["RESIST", 2], ["STR", 2]], "unique": null, "name_seed": 3})
	hw.anlegen(schatten)
	z.beutel.erase(schatten)
	var anker := z.ausruestung_dazu({"uid": 0, "base": "robe", "rarity": "RARE", "ilvl": 1, "plus": 0, "rolls": [["TENACITY", 18]], "unique": null, "name_seed": 7})
	var v := Vergleich.von(hw, anker)
	var worte := v.zeilen.map(func(r): return String(r["wort"]))
	print("Vergleich: ", v.zeilen)
	for w in ["Gewandtheit", "Kraft", "Schadensreduktion", "Standhaftigkeit"]:   # 683: Wörter nach BRS; 870.4: Schutzwert nach BRS ohne Zusatzeigenschaft (870.6)
		pruefe(w in worte, "Vergleich nennt %s (%s)" % [w, worte])
	pruefe(v.urteil() == 0, "Urteil gemischt (%s): %s" % [v.urteil(), v.satz()])
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.reiter = "tasche"
	m.baue()
	await process_frame
	var zeile: Node = null
	for h in m.find_children("*", "HBoxContainer", true, false):
		if h.has_meta("tragbar") and not h.is_queued_for_deletion() and Beute.name(anker) in texte(h): zeile = h
	pruefe(zeile != null, "Tasche: Zeile der Robe des Ankers")
	if zeile:
		var t := texte(zeile)
		print("Tasche: ", t)
		pruefe("◆" in t, "Tasche: gemischt mit ◆ gekennzeichnet")
		pruefe(t.any(func(s): return s.contains("Standhaftigkeit")), "Tasche: Zeile mit Wert, nicht nur der Platz")
	m.reiter = "ausruestung"
	m.baue()
	await process_frame
	m.waehle("CHEST")
	await process_frame
	var w := texte(m)
	print("Wechsel: ", w)
	var i := w.find(Beute.name(anker))
	pruefe(i >= 0, "Wechselschirm zeigt die Robe des Ankers")
	if i >= 0:
		var rest := w.slice(i, i + 4)
		pruefe("◆" in rest, "Wechselschirm: ◆ an der Robe des Ankers (%s)" % [rest])
		pruefe(rest.any(func(s): return s.contains("Standhaftigkeit")), "Wechselschirm: Zeile mit Wert (%s)" % [rest])
	# 523: Klang beim Benutzen wie alt (Trank „potion“, nichts bei vollem Helden)
	z.dazu("potion", 2)
	hw.leben = hw.max_leben()
	m.benutze_mit_klang("potion", "POTION")
	pruefe(m.letzter_klang == "" and z.anzahl("potion") == 2, "voller Held: kein Trank weg, kein Klang")
	hw.leben = 1
	m.benutze_mit_klang("potion", "POTION")
	pruefe(m.letzter_klang == "potion" and z.anzahl("potion") == 1, "Trank getrunken mit Klang „potion“ (%s)" % m.letzter_klang)
	print("ROBEN524 %d Fehler" % fehler)
	quit(1 if fehler else 0)
