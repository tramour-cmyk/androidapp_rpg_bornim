extends SceneTree
# 1569 (Chef 17.11., 16:12/16:16, t297.18): Bild alt gegen neu des angelegten Umhangs wie im Menü Ausrüstung (Drehteller). Jägerkind
# Mann mit Umhang: alt (Schrank ohne UMHANG, Stand Build 297) von hinten | neu von hinten | neu von vorn; Jägerkind Frau neu von hinten;
# Zauberlehrling Mann neu von hinten. Nur mit Fenster und Kaufdaten:
#   PROBE=1569 xvfb-run -a godot --path . --rendering-driver vulkan --rendering-method mobile -s res://tests/umhang_bild_1569.gd -- --aus=<ordner>
var aus := ""

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	_l.call_deferred()

func wahl(h: String, g: String) -> Dictionary:
	var hw := BrsHeld.fuer_spiel("Test", "Mensch", h)
	var a: Dictionary = hw.ausruestung.duplicate()
	a["CLOAK"] = {"base": "cloak"}
	return {"herkunft": h, "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": a}

func _l() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	var info := HeldFigur.lade_info()
	if not info.get("schrank", {}).get("M", {}).has("UMHANG"):
		print("UMHANGBILD1569 ohne Kaufdaten"); quit(0); return
	# Fenster und Teller in voller Größe (Bild 2: Teller füllten das Fenster nicht, grauer Rand, Titel winzig)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1500, 560)
	DisplayServer.window_set_size(Vector2i(1500, 560))
	var reihe := HBoxContainer.new()
	reihe.size = Vector2(1500, 560)
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.size = reihe.size
	root.add_child(bg)
	root.add_child(reihe)
	# 1569.1 (Bild 4): Umhang an den Seiten weiter; alt = Bild 3 (Telegram 18.11., 01:43), darum nur neu
	var titel := ["Jägerkind, hinten", "Jägerkind, vorn", "Jägerkind Frau, hinten", "Zauberlehrling, hinten", "Zauberlehrling, vorn"]
	var faelle := [["Jägerkind", "m", false, true], ["Jägerkind", "m", false, false], ["Jägerkind", "w", false, true],
		["Zauberlehrling", "m", false, true], ["Zauberlehrling", "m", false, false]]
	var umhang_m: Dictionary = info["schrank"]["M"]["UMHANG"]
	var umhang_w: Dictionary = info["schrank"].get("W", {}).get("UMHANG", {})
	for i in faelle.size():
		var f: Array = faelle[i]
		if f[2]:
			info["schrank"]["M"].erase("UMHANG")
			info["schrank"].get("W", {}).erase("UMHANG")
		var box := VBoxContainer.new()
		box.custom_minimum_size = Vector2(300, 560)
		var l := Label.new()
		l.text = titel[i]
		l.add_theme_font_size_override("font_size", 26)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(l)
		var d := Drehteller.new(wahl(f[0], f[1]), 1.6, false)
		d.custom_minimum_size = Vector2(300, 520)
		d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		d.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_child(d)
		reihe.add_child(box)
		if f[3] and d.teller: d.teller.rotation.y = PI
		info["schrank"]["M"]["UMHANG"] = umhang_m
		if not umhang_w.is_empty(): info["schrank"]["W"]["UMHANG"] = umhang_w
	for k in 20: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(aus + "/umhang_1569.png")
	print("BILD ", aus + "/umhang_1569.png")
	quit(0)
