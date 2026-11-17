extends SceneTree
# 701 (Chef 08.11., 20:37, t270.5: „die wiederholte Anzeige des Caps macht keinen Sinn und wirkt überbordend“; Foto: Amulett, unter
# jedem der sechs Grundwerte „mehr Bonus, wirkt nicht: Obergrenze …“, oben schon „+1 alle Attribute – wirkt nicht (Obergrenze)“).
# Ein Stueck fuellt die Obergrenze schon (Amulett „+1 alle Attribute“, wie kopffeld_605), ein Ring mit demselben Bonus kommt dazu:
# im Fenster (stueck_zeilen_b) steht der Deckel einmal, an der Bonuszeile; im alten Fenster (Laden, stueck_zeilen_von) ohne Hinweis
# an den Bonuszeilen einmal als Sammelzeile „Attribute“ wie alt. Ohne Bild. Aufruf im Ordner godot: headless, -s res://tests/obergrenze_701.gd
var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func texte(zeilen: Array) -> Array:
	var t: Array = []
	for c in zeilen:
		for l in ([c] if c is Label else c.find_children("*", "Label", true, false)): t.append((l as Label).text)
	return t

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	# 644b A (Chef 12.11., 13:40): kein Deckel mehr in werte.json; dann steht nirgends „Obergrenze“. Die Anzeige aus 701 bleibt für den
	# Fall, dass ein Deckel zurückkommt: geprüft mit dem alten Deckel, nur in diesem Test eingesetzt
	var deckel_jetzt = BrsHeld.lade().get("gegenstaende", {}).get("deckel", {})
	pruefe(deckel_jetzt is Dictionary and deckel_jetzt.is_empty(), "644b: werte.json ohne Deckel (%s)" % [deckel_jetzt])
	for klasse in ["Wachsoldat", "Zauberlehrling"]:
		var z0 := Zustand.new()
		var h0 := BrsHeld.fuer_spiel("Thora", "Mensch", klasse, z0.neue_uid)
		h0.anlegen({"uid": z0.neue_uid.call(), "base": "amulet", "rarity": "RARE", "ilvl": 1, "plus": 0, "rolls": [["ALL_STATS", 1]], "unique": null, "name_seed": 0})
		var r0 := z0.ausruestung_dazu({"uid": 0, "base": "ring", "rarity": "RARE", "ilvl": 1, "plus": 0, "rolls": [["ALL_STATS", 1]], "unique": null, "name_seed": 0})
		var o0 := texte(Menue.stueck_zeilen_b(h0, r0) + Menue.stueck_zeilen_von(h0, r0)).filter(func(t): return t.contains("Obergrenze"))
		pruefe(o0.is_empty(), "%s ohne Deckel: kein „Obergrenze“ (%s)" % [klasse, str(o0)])
	BrsHeld.lade()["gegenstaende"]["deckel"] = {"STR": [1, 0], "DEX": [1, 0], "CON": [1, 0], "INT": [1, 0], "WIS": [1, 0], "CHA": [1, 0], "AC": [1, 1]}
	for klasse in ["Wachsoldat", "Zauberlehrling"]:
		var z := Zustand.new()
		var hw := BrsHeld.fuer_spiel("Thora", "Mensch", klasse, z.neue_uid)
		hw.anlegen({"uid": z.neue_uid.call(), "base": "amulet", "rarity": "RARE", "ilvl": 1, "plus": 0, "rolls": [["ALL_STATS", 1]], "unique": null, "name_seed": 0})
		var ring := z.ausruestung_dazu({"uid": 0, "base": "ring", "rarity": "RARE", "ilvl": 1, "plus": 0, "rolls": [["ALL_STATS", 1]], "unique": null, "name_seed": 0})
		var v := Vergleich.von(hw, ring)
		var b := texte(Menue.stueck_zeilen_b(hw, ring)).filter(func(t): return t.contains("Obergrenze"))
		pruefe(b.size() == 1, "%s Fenster: Deckel einmal, %d-mal: %s" % [klasse, b.size(), str(b)])
		var alt := texte(Menue.stueck_zeilen_von(hw, ring)).filter(func(t): return t.contains("Obergrenze"))
		pruefe(alt.size() == 1 and String(alt[0]).begins_with("Alle Grundwerte"), "%s Laden: eine Sammelzeile, %d: %s" % [klasse, alt.size(), str(alt)])
		pruefe(v.urteil() == null, "%s: Urteil „bringt nichts“ (%s)" % [klasse, str(v.urteil())])
	print("OBERGRENZE701 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
