extends SceneTree
# 399.1 (Test 139.10, Chef 28.10., 21:3x: „das Ab- und Anlegen von Ausrüstung über den Ausrüstungsbildschirm scheint noch nicht zu
# funktionieren wie vorher“): ohne Bild, mit Tippen wie am Handy (Druecken, Loslassen); Reiter Ausruestung: die Waffe antippen,
# „Ablegen“ (in der Tasche), den leeren Platz antippen, sie aus der Liste waehlen, „Anlegen“ (wieder in der Hand); dann „Wechseln“
# auf ein zweites Schwert. Aufruf: im Ordner godot mit -s res://tests/ausruestung_399.gd

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func tippe(c: Control) -> void:
	for gedrueckt in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT; e.pressed = gedrueckt; e.position = Vector2(5, 5)
		c.gui_input.emit(e)
	await process_frame
	await process_frame

func knopf(m: Node, anfang: String) -> Button:
	for b in m.find_children("*", "Button", true, false):
		if b.is_visible_in_tree() and not b.is_queued_for_deletion() and String(b.text).begins_with(anfang.to_upper()): return b
	fehler += 1; print("FEHLER kein Knopf ", anfang)
	return null

func druecke(m: Node, anfang: String) -> void:
	var b := knopf(m, anfang)
	if b: b.pressed.emit()
	await process_frame
	await process_frame

# der Platz [platz] im Reiter: das VBox mit dem Namen des Platzes darunter
func fach(m: Menue, platz: String) -> Control:
	var wort := m.platzname(platz)
	for l in m.inhalt.find_children("*", "Label", true, false):
		if l.text == wort: return l.get_parent()
	fehler += 1; print("FEHLER kein Platz ", platz)
	return null

func zeile_mit(m: Node, text: String) -> Control:
	for l in m.find_children("*", "Label", true, false):
		if not l.is_queued_for_deletion() and l.text == text and l.is_visible_in_tree():
			var p: Node = l.get_parent()
			while p and not (p is HBoxContainer): p = p.get_parent()
			return p
	fehler += 1; print("FEHLER keine Zeile ", text)
	return null

func _lauf() -> void:
	Sprache.lade()
	var z := Zustand.new()
	var hw := Heldwerte.erschaffe("Vera", "HUMAN", "FIGHTER", {}, z.neue_uid)
	var w = hw.waffe()
	if w == null: print("FEHLER Kaempferin ohne Waffe"); quit(1); return
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.reiter = "ausruestung"
	m.baue()
	await process_frame
	await tippe(fach(m, "MAIN_HAND"))
	await druecke(m, Sprache.u("unequip"))
	print("abgelegt: Hand %s, Tasche %d" % [hw.waffe(), z.beutel.size()])
	if hw.waffe() != null or not z.beutel.has(w): fehler += 1; print("FEHLER Ablegen")
	await tippe(fach(m, "MAIN_HAND"))
	var z_ := zeile_mit(m, Beute.name(w))
	if z_: await tippe(z_)
	await druecke(m, Sprache.u("equip"))
	print("angelegt: Hand %s" % [Beute.name(hw.waffe()) if hw.waffe() != null else "leer"])
	if hw.waffe() == null or int(hw.waffe()["uid"]) != int(w["uid"]): fehler += 1; print("FEHLER Anlegen aus der Liste")
	var zweit := z.ausruestung_dazu({"uid": 0, "base": "shortsword", "rarity": "UNCOMMON", "ilvl": 1, "plus": 0, "rolls": [], "unique": null, "name_seed": 0})
	m.baue()
	await process_frame
	await tippe(fach(m, "MAIN_HAND"))
	await druecke(m, "Wechseln")
	z_ = zeile_mit(m, Beute.name(zweit))
	if z_: await tippe(z_)
	await druecke(m, Sprache.u("equip"))
	print("gewechselt: Hand %s" % [Beute.name(hw.waffe()) if hw.waffe() != null else "leer"])
	if hw.waffe() == null or String(hw.waffe()["base"]) != "shortsword": fehler += 1; print("FEHLER Wechseln")
	print("AUSRUESTUNG %d Fehler" % fehler)
	quit(1 if fehler else 0)
