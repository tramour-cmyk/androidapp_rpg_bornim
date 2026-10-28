extends SceneTree
# 399 ohne Bild: Erschaffung (Heldwerte.erschaffe) und Spielstand hin und zurueck (Zustand, Heldwerte, Ort); Hauptmenue Schritt fuer
# Schritt bis „Abenteuer beginnen“. Aufruf: im Ordner godot mit -s res://tests/spielstand_test.gd

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var z := Zustand.new()
	z.name = "Mira"; z.gold = 23; z.dazu("potion", 2); z.setze("met_jorin")
	var hw := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	hw.tp = 3
	Spielstand.speichere(z, hw, {"karte": "inn", "x": 4, "y": 6, "blick": "UP"})
	var d := Spielstand.lade()
	var z2 := Zustand.aus_daten(d["zustand"])
	var h2 := Heldwerte.aus_daten(d["held"])
	if z2.gold != 23 or z2.anzahl("potion") != 2 or not z2.has("met_jorin"): fehler += 1; print("FEHLER Zustand")
	if h2.klasse != "WIZARD" or h2.volk != "ELF" or h2.tp != 3 or h2.max_tp() != hw.max_tp() or h2.rk() != hw.rk(): fehler += 1; print("FEHLER Held %s" % h2.als_daten())
	if String(d["ort"]["karte"]) != "inn": fehler += 1; print("FEHLER Ort")
	print("Spielstand: %s %s %s, TP %d/%d, RK %d" % [h2.name, h2.volk, h2.klasse, h2.tp, h2.max_tp(), h2.rk()])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Spielstand.DATEI))
	var st := Steuerung.new()
	root.add_child(st)
	var m := Hauptmenue.new(st)
	st.add_child(m)
	await process_frame
	var ergebnis := {}
	m.fertig.connect(func(w): ergebnis.merge(w))
	var druecke := func(i: int):
		await process_frame
		var bs: Array = m.box.get_children().filter(func(c): return c is Button and not c.is_queued_for_deletion())
		bs[i].pressed.emit()
	await druecke.call(0)   # Neues Spiel (ohne Spielstand der erste Knopf): 399.1 Erschaffung auf einer Seite (erschaffung.gd)
	await process_frame
	var e: Erschaffung = m.get_node("Erschaffung")
	var knoepfe := func() -> Array:
		await process_frame
		return e.find_children("*", "Button", true, false).filter(func(c): return not c.is_queued_for_deletion())
	var bs: Array = await knoepfe.call()
	bs[2].pressed.emit()    # Volk: Zwerg (Reihe Mensch, Elf, Zwerg, Halbling, Halbork)
	bs = await knoepfe.call()
	bs[5 + 3].pressed.emit()   # Klasse: Kleriker (Kaempfer, Magier, Schurke, Kleriker)
	bs = await knoepfe.call()
	var minus: Button = bs[5 + 4 + 1]   # nach Vorschlag: − und + je Attribut, STR zuerst
	minus.pressed.emit()    # STR einen weniger, ein Punkt frei
	bs = await knoepfe.call()
	bs[bs.size() - 1].pressed.emit()   # Abenteuer beginnen (unten rechts)
	await process_frame
	print("Hauptmenue: %s" % ergebnis)
	if ergebnis.get("volk") != "DWARF" or ergebnis.get("klasse") != "CLERIC" or String(ergebnis.get("name", "")) == "": fehler += 1; print("FEHLER Hauptmenue")
	var vor := Heldwerte.vorschlag("CLERIC")
	if int(ergebnis.get("werte", {}).get("STR", 0)) != int(vor["STR"]) - 1 or not Heldwerte.gueltiger_kauf(ergebnis.get("werte", {})): fehler += 1; print("FEHLER Punktekauf")
	var h3 := Heldwerte.erschaffe(String(ergebnis["name"]), "DWARF", "CLERIC", ergebnis["werte"])
	if h3.basis["STR"] != int(vor["STR"]) - 1 + 1: fehler += 1; print("FEHLER Punktekauf im Helden: STR %d" % h3.basis["STR"])   # Zwerg STR +1
	print("SPIELSTAND %d Fehler" % fehler)
	quit(1 if fehler else 0)
