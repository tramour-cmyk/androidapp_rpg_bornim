extends SceneTree
# 753 Probe mit Bild am Rechner (nicht im Bau): Blende nach der Rast, vorher (Label 40 px, Standardschrift) und neu wie die
# Ortsblende (Ortsblende.worte_spalte), kurze Rast, lange Rast am Feuer, Zimmer in der Schenke; die Worte voll sichtbar.
# PNG nach OBERFLAECHE_AUS. Aufruf: im Ordner godot, mit Fenster (xvfb-run), --resolution 1080x2340; braucht daten/texte.json

const SpielSkript = preload("res://skripte/spiel.gd")

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("OBERFLAECHE_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var fehler := 0
	for fall in [["alt", "lang", "feuer"], ["kurz", "kurz", "feuer"], ["lang", "lang", "feuer"], ["zimmer", "lang", "zimmer"]]:
		var grund := Ortsblende.schwarz()
		root.add_child(grund)
		var satz_text := Sprache.r("hourGone" if fall[1] == "kurz" else "hoursGone")
		var teil: Control
		if fall[0] == "alt":
			var satz := Label.new()
			satz.text = satz_text
			satz.add_theme_font_size_override("font_size", 40)
			satz.add_theme_color_override("font_color", Steuerung.GOLD)
			satz.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
			satz.grow_horizontal = Control.GROW_DIRECTION_BOTH; satz.grow_vertical = Control.GROW_DIRECTION_BOTH
			teil = satz
		else:
			var mitte := CenterContainer.new()
			mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			var name_ := String(SpielSkript.rast_name(fall[1], fall[2]))
			var w := Ortsblende.worte_spalte(name_, satz_text)
			w.custom_minimum_size.x = 1080 - 2 * 36 * AktionsKnopf.DP
			mitte.add_child(w)
			teil = mitte
			print("RAST753 %s: %s / %s" % [fall[0], name_, satz_text])
			if name_ == "" or satz_text in ["hourGone", "hoursGone"]: fehler += 1
		root.add_child(teil)
		await _bild("753_%s" % fall[0])
		teil.free(); grund.free()
		await process_frame
	print("RAST753 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler else 0)
