extends SceneTree
# 785.22 (Abgleich alt, WorldScreen.kt 2856–2858): die Leiste zeigt nach dem Essen „Satt“ als Plakette hinter den Zuständen, bis
# zum nächsten Kampf (Zustand.satt); ohne Satt keine. Ohne Bild. Maßgeblich ist die Zeile SATT78522.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func texte(l: Leiste) -> Array:
	var t := []
	for c in l.chips.get_children():
		if c is PanelContainer: t.append((c.get_child(0) as Label).text)
	return t

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	var l := Leiste.new()
	root.add_child(l)
	await process_frame
	l.zeige(hw, z, false)
	pruefe(texte(l).is_empty(), "nicht satt: keine Plakette (%s)" % str(texte(l)))
	z.satt = true
	l.zeige(hw, z, false)
	pruefe(texte(l) == ["Satt"], "satt: Plakette „Satt“ (%s)" % str(texte(l)))
	var k := l.chips.get_child(0) as PanelContainer
	var farbe: Color = (k.get_theme_stylebox("panel") as StyleBoxFlat).bg_color if k else Color.BLACK
	pruefe(farbe.is_equal_approx(Color(0xB07A30FF)), "Bernstein wie alt (%s)" % str(farbe))
	pruefe(not l.zustaende_da, "Satt allein öffnet keine Erklärung der Zustände")
	z.leiden["POISON"] = 2
	l.zeige(hw, z, false)
	pruefe(texte(l).size() == 2 and texte(l)[1] == "Satt", "mit Gift: Zustand vorn, „Satt“ dahinter (%s)" % str(texte(l)))
	Sprache.setze("en")
	l.zeige(hw, z, false)
	pruefe(texte(l).has("Fed"), "englisch „Fed“ (%s)" % str(texte(l)))
	print("SATT78522 %d Fehler" % fehler)
	quit(1 if fehler else 0)
