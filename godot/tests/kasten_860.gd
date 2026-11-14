extends SceneTree
# 860 (Chef 10.11., 13:07, t274.10 „Ja“; 549a): Chronik (Aufträge, Bisher geschehen) und Filter der Karte ohne Kasten: kein Rahmen
# (StyleBox mit Randlinie) und kein Button in Chronik und Kartenkopf; gewählter Umschalter hell auf RAISED. Ausgabe „KASTEN860 n Fehler“.
#   ~/godot/godot --headless --path . -s res://tests/kasten_860.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func kaesten(n: Node) -> Array:
	var aus := []
	for c in n.find_children("*", "", true, false):
		if c is Button: aus.append("Button " + String((c as Button).text))
		elif c is PanelContainer:
			var s = (c as PanelContainer).get_theme_stylebox("panel")
			if s is StyleBoxFlat and (s as StyleBoxFlat).border_color.a > 0.05 and ((s as StyleBoxFlat).border_width_left > 0 or (s as StyleBoxFlat).border_width_top > 0):
				aus.append("Kasten %s in %s" % [c.name, c.get_parent().name])
	return aus

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Probe", "Mensch", "Wachsoldat", z.neue_uid)
	var alle: Array = Auftraege.alle()
	if not alle.is_empty():
		Auftraege.nimm(z, alle[0])
		z.setze("met_" + String(alle[0]["geber"]))
	var m := Menue.new(hw, z)
	root.add_child(m)
	m.reiter = "chronik"
	m.baue()
	await process_frame
	var k := kaesten(m.inhalt)
	pruefe(k.is_empty(), "Chronik, Aufträge ohne Kasten und Button: %s" % [k])
	var w := m.inhalt.find_children("*", "PanelContainer", true, false).filter(func(x): return x.has_meta("gewaehlt")).filter(func(x): return bool(x.get_meta("gewaehlt", false)))
	pruefe(w.size() == 1, "genau ein Umschalter gewählt (%d)" % w.size())
	m.bisher = true
	m.baue()
	await process_frame
	k = kaesten(m.inhalt)
	pruefe(k.is_empty(), "Chronik, Bisher geschehen ohne Kasten und Button: %s" % [k])
	m.bisher = false
	m.reiter = "karte"
	m.baue()
	for i in 3: await process_frame
	var kr := m.inhalt.get_child(0) if m.inhalt.get_child_count() > 0 else null
	if kr is Kartenreiter:
		var filter := (kr as Node).find_children("*", "PanelContainer", true, false).filter(func(x): return x.has_meta("gewaehlt"))
		pruefe(filter.size() >= 3, "Filter der Karte als Wahl ohne Kasten (%d)" % filter.size())
	print("KASTEN860 %d Fehler" % fehler)
	quit(1 if fehler else 0)
