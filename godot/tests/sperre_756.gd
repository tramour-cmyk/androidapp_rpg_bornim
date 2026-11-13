extends SceneTree
# 756 A (Chef 09.11., 17:46: „Sperren zeigen“): das Gegenstandsfenster sagt, warum „Anlegen“ matt ist ([870.14.ding.stufe]
# „Erst ab Heldenstufe %d.“, 644a A), zuerst und hervorgehoben; nicht an Getragenem (bleibt angelegt). Zustand und Zeichen am Bild nur
# mit Menue.merkmale (an seit dem „passt“ des Chefs 12.11., 20:14); Schlecht in vier Varianten (Vorlage, Chef 20:23).
# Ohne Bildbefehl. Aufruf: im Ordner godot mit -s res://tests/sperre_756.gd -> „SPERRE756 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func texte(zeilen: Array) -> String:
	var aus: PackedStringArray = []
	for c in zeilen:
		if c is Label: aus.append((c as Label).text)
		for l in (c as Node).find_children("*", "Label", true, false): aus.append((l as Label).text)
	return " | ".join(aus).replace(" ", " ")

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	pruefe(Menue.merkmale, "Menue.merkmale ist aus (an seit 756 passt)")
	Menue.merkmale = false
	var hoch := {"uid": z.neue_uid.call(), "base": "longsword", "rarity": "COMMON", "ilvl": 3, "guete": 1, "zustand": 2, "rolls": [], "unique": null, "name_seed": 1}
	var tief := {"uid": z.neue_uid.call(), "base": "shortsword", "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
	pruefe(hw.stufe < 3 and not hw.kann_tragen(hoch), "Held der Stufe %d kann ein Stück der Stufe 3 anlegen" % hw.stufe)
	var h := Menue.tragen_hinweise(hw, hoch)
	pruefe(not h.is_empty() and String(h[0][0]) == "Erst ab Heldenstufe 3." and bool(h[0][1]), "Sperre fehlt oder steht nicht zuerst: %s" % [h])
	for zeilen in [Menue.stueck_zeilen_von(hw, hoch), Menue.stueck_zeilen_b(hw, hoch)]:
		var t := texte(zeilen)
		pruefe(t.contains("Erst ab Heldenstufe 3."), "Fenster ohne Sperre: %s" % t)
		pruefe(not t.contains("Zustand"), "Zustand ohne Menue.merkmale: %s" % t)
	pruefe(not texte(Menue.stueck_zeilen_b(hw, tief)).contains("Heldenstufe"), "Sperre an einem tragbaren Stück")
	# Getragenes bleibt angelegt (644a A): keine Sperre daran
	hw.ausruestung["MAIN_HAND"] = hoch
	pruefe(not texte(Menue.stueck_zeilen_b(hw, hoch)).contains("Heldenstufe"), "Sperre an Getragenem")
	hw.ausruestung.erase("MAIN_HAND")
	# Zustand im Fenster, Zeichen am Bild
	Menue.merkmale = true
	var t2 := texte(Menue.stueck_zeilen_b(hw, hoch))
	pruefe(t2.contains("Zustand: Beschädigt") and t2.contains("Güte: Gut"), "ohne Zustand oder Güte: %s" % t2)
	var r := Menue.stueck_rahmen(hoch, 46)
	pruefe(r.get_child_count() == 2, "Zeichen fehlen am Bild (%d Kinder)" % r.get_child_count())
	var schlicht := Menue.stueck_rahmen(tief, 46)
	pruefe(schlicht.get_child_count() == 1, "Zeichen an normalem, makellosem Stück")
	r.free(); schlicht.free()
	# Schlecht (mit 976): jede Variante legt ein Zeichen ans Bild
	for art in Menue.SCHLECHT.size():
		var sl := tief.duplicate()
		sl["guete"] = -1; sl["schlecht_art"] = art
		var rs := Menue.stueck_rahmen(sl, 46)
		pruefe(rs.get_child_count() == 2, "Schlecht, Variante %d: kein Zeichen am Bild" % art)
		rs.free()
	print("SPERRE756 %d Fehler" % fehler)
	quit(1 if fehler else 0)
