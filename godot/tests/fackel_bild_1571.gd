extends SceneTree
# 1571 (Chef 17.11., 16:35, Bild t297-stab-fehlt.webp: „Fackel der Nebenhand sitzt in der rechten Hand“): Held der Ausruestung mit Fackel
# in der Nebenhand, von vorn und schraeg wie im Bild des Chefs, damit zu sehen ist, welche Hand der Figur die Fackel haelt.
#   PROBE=1571 xvfb-run -a godot --path . -s res://tests/fackel_bild_1571.gd -- --aus=<ordner>
var aus := ""

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	_l.call_deferred()

func _l() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(900, 600)
	DisplayServer.window_set_size(Vector2i(900, 600))
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.size = Vector2(900, 600)
	root.add_child(bg)
	var reihe := HBoxContainer.new()
	reihe.size = Vector2(900, 600)
	root.add_child(reihe)
	var titel := ["von vorn", "schräg wie im Bild 17.11., 16:34"]
	var winkel := [0.0, deg_to_rad(60.0)]
	for i in 2:
		var hw := BrsHeld.fuer_spiel("Test", "Mensch", "Zauberlehrling")
		var a: Dictionary = hw.ausruestung.duplicate()
		a["OFF_HAND"] = {"base": "torch"}
		var w := {"herkunft": "Zauberlehrling", "volk": "HUMAN", "aussehen": {"geschlecht": "m"}, "ausruestung": a}
		var box := VBoxContainer.new()
		box.custom_minimum_size = Vector2(450, 600)
		var l := Label.new()
		l.text = titel[i]
		l.add_theme_font_size_override("font_size", 26)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(l)
		var d := Drehteller.new(w, 1.6, false)
		d.custom_minimum_size = Vector2(450, 520)
		d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		d.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_child(d)
		reihe.add_child(box)
		if d.teller: d.teller.rotation.y = winkel[i]
	for k in 20: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(aus + "/fackel_1571.png")
	print("BILD ", aus + "/fackel_1571.png")
	quit(0)
