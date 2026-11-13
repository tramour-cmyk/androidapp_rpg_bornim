extends SceneTree
# 1073 Probe am Rechner (nicht im Bau): Reiter Tasche und Fenster eines Dings mit den Bildern aus godot/daten, als PNG nach DINGE_AUS
# (Vorgabe user://). Heiltrank, Heilkräuter, Gold, Langschwert, Lederkappe, Rundschild; dazu ein Gegenstand zum Auffüllen.
# Aufruf: im Ordner godot, mit Fenster (xvfb-run), -s res://tests/dingbilder_1073.gd --resolution 1080x2340

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("DINGE_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _stueck(z: Zustand, base: String, r: String) -> Dictionary:
	var g := Beute.wuerfle(z.neue_uid.call(), base, 1, r, KotlinZufall.new(base.length() * 7 + r.length()))
	z.beutel.append(g)
	return g

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var grund := ColorRect.new()
	grund.color = Color.BLACK
	grund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(grund)
	var z := Zustand.new()
	z.name = "Mira"; z.gold = 37; z.dazu("potion", 2); z.dazu("herbs", 3); z.tag = 3; z.minuten = 21 * 60 + 5
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", "Söldnerkind", z.neue_uid)
	var schwert := _stueck(z, "longsword", "COMMON")
	_stueck(z, "leather_cap", "UNCOMMON")
	_stueck(z, "round_shield", "RARE")
	var ebene := CanvasLayer.new()
	ebene.layer = 40
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	m.reiter = "tasche"; m.baue()
	await _bild("tasche")
	m.frage_stueck(schwert)
	await _bild("fenster_schwert")
	for c in m.get_children(): if c is ColorRect and c.color.a < 0.9: c.queue_free()
	m.reiter = "tasche"; m.baue()
	m.frage_ding("potion")
	await _bild("fenster_trank")
	quit(0)
