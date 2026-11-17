extends SceneTree
# 1448 A (Chef 16.11., 14:47): Bild der Weltleiste und der Balken im Heldenmenü, deutsch, Zauberlehrling Stufe 3 (Leben, Mana,
# Erfahrung). Am Bauserver mit Fenster (xvfb-run, mobile), 1080 × 2340; schneidet je Gegenstand einen Ausschnitt und speichert
# BILD1448_AUS/leiste.png und BILD1448_AUS/held.png (Vorgabe user://). Vorher/nachher baut der Schritt „Leiste (1448)“ in godot.yml.

func _initialize() -> void: _lauf.call_deferred()

func _held() -> Array:
	var z := Zustand.new()
	z.name = "Mira"; z.tag = 3; z.minuten = 18 * 60 + 40; z.gold = 37
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", "Zauberlehrling", z.neue_uid)
	Testmodus.stufe_setzen(hw, z, 3)
	hw.leben = maxi(1, roundi(hw.max_leben() * 0.7)); hw.mana = maxi(0, roundi(hw.max_mana() * 0.5))
	return [hw, z]

func _schnitt(r: Rect2, name: String, aus: String) -> void:
	await RenderingServer.frame_post_draw
	var bild := root.get_texture().get_image()
	var g := Rect2i(r.grow(12)).intersection(Rect2i(Vector2i.ZERO, bild.get_size()))
	bild.get_region(g).save_png(aus + "/" + name)
	print("BILD1448 ", name, " ", g)

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var aus := OS.get_environment("BILD1448_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	var hz := _held()
	var grund := ColorRect.new(); grund.color = Color("2a3a22"); grund.set_anchors_preset(Control.PRESET_FULL_RECT)
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	ebene.add_child(grund)
	var l := Leiste.new()
	ebene.add_child(l)
	l.zeige(hz[0], hz[1], false)
	for i in 10: await process_frame
	await _schnitt(l.get_global_rect(), "leiste.png", aus)
	l.queue_free(); grund.queue_free()
	var m := Menue.new(hz[0], hz[1])
	ebene.add_child(m)
	await process_frame
	m.reiter = "held"
	m.baue()
	for i in 10: await process_frame
	# Balkenzeilen samt Kopf (Name, Stufe) darüber: von der Oberkante des Inhalts bis unter die letzte Balkenzeile
	var zeilen: Array = m.inhalt.find_children("Balken_*", "HBoxContainer", true, false)
	if zeilen.is_empty():   # Stand vor 1448: Zeilen ohne Namen, die mit einem Balken
		zeilen = m.inhalt.find_children("*", "HBoxContainer", true, false).filter(func(r): return r.get_children().any(func(c): return c is Leiste.Balken))
	var r := m.inhalt.get_global_rect()
	r.end.y = zeilen[-1].get_global_rect().end.y if not zeilen.is_empty() else r.position.y + 600
	await _schnitt(r, "held.png", aus)
	quit(0)
