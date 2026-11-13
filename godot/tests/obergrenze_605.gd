extends SceneTree
# 605 (Chef 06.11., 21:22, Bild): Ausruestung, leeres Kopffeld, ein Stueck waehlen: jeder Bonus stand „wirkt nicht (Obergrenze)“, als
# vergliche das Fenster gegen das leere Feld. Je Platz ein Stueck mit Boni auf einem leeren Feld: was es bringt (Vergleich.wirkung)
# und was das Fenster schreibt. Ohne Bild. Aufruf im Ordner godot: headless, -s res://tests/obergrenze_605.gd
var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Zwerg", "Wachsoldat", z.neue_uid)
	for platz in ["HEAD", "CLOAK", "ARMS", "LEGS", "RING", "AMULET"]:
		var id := ""
		for b in Beute.grundformen():
			if String(Beute.grundform(b)["slot"]) == platz: id = b; break
		var g := z.ausruestung_dazu({"uid": 0, "base": id, "rarity": "RARE", "ilvl": 1, "plus": 0, "rolls": [["CON", 1], ["HP", 3]], "unique": null, "name_seed": 0})
		var vorher = hw.ding(platz)
		var wk := Vergleich.wirkung(hw, g)
		var texte: Array = []
		for c in Menue.stueck_zeilen_b(hw, g):
			for l in ([c] if c is Label else c.find_children("*", "Label", true, false)): texte.append((l as Label).text)
		var nicht := texte.filter(func(t): return t.contains("wirkt nicht"))
		pruefe(nicht.is_empty(), "%s (%s, vorher %s): wirkung %s, Fenster %s" % [platz, id, "leer" if vorher == null else Beute.name(vorher), str(wk), str(nicht)])
	# wie im Bild des Chefs: eine goettliche Kapuze (alle Attribute und einzelne Attribute) auf dem leeren Kopffeld, sonst nichts angelegt
	for seed in [1, 2, 3, 4, 5]:
		var g := z.ausruestung_dazu(Beute.wuerfle(z.neue_uid(), "hood", 1, "DIVINE", KotlinZufall.new(seed)))
		var texte: Array = []
		for c in Menue.stueck_zeilen_b(hw, g):
			for l in ([c] if c is Label else c.find_children("*", "Label", true, false)): texte.append((l as Label).text)
		var w := texte.filter(func(t): return t.contains("wirkt") or t.contains("Obergrenze"))
		var alle: int = g["rolls"].filter(func(r): return String(r[0]) in BrsHeld.AFFIX.values() or String(r[0]) == "ALL_STATS").size()
		var nicht := w.filter(func(t): return t.contains("wirkt nicht"))
		pruefe(alle == 0 or nicht.size() < alle, "goettlich %d: %s; Fenster %s" % [seed, str(g["rolls"]), str(w)])
	print("OBERGRENZE605 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
