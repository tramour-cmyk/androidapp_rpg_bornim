extends SceneTree
# 1417 Bild an den Chef: die Wachsoldatin des Hauptmenüs, links vorher (Schildarm hängt am Bein, schild_abspreiz 0), rechts nachher
# (HELDEN schild_abspreiz), sonst gleich (Hauptmenü wie im Spiel, dieselbe Stelle der Bewegung). Nur mit Fenster (godot.yml
# „Schild im Hauptmenü (1417)“), im Ordner godot:
#   PROBE=1417 xvfb-run -a godot --path . --rendering-driver vulkan --rendering-method mobile --resolution 1080x2340 \
#     -s res://tests/schild_bild_1417.gd -- --aus=<ordner>

var aus := ""

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	_lauf.call_deferred()

func _lauf() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	Hauptmenue.vorspann_gezeigt = true
	var hm := Hauptmenue.new(null)
	root.add_child(hm)
	for i in 40: await process_frame   # Lauf 531: nach 10 Bildern war alles schwarz (Einblendung des Menüs)
	var neu: HauptmenueHelden = null
	for c in hm.find_children("*", "HauptmenueHelden", true, false): neu = c
	if neu == null or neu.figuren.is_empty():
		print("SCHILDBILD1417 keine Helden"); quit(1); return
	var sk := Gebiet.finde(neu.figuren[0], "Skeleton3D") as Skeleton3D
	var ap := Gebiet.finde(neu.figuren[0], "AnimationPlayer") as AnimationPlayer
	var tr: Tragen = null
	for c in sk.get_children():
		if c is Tragen and (c as Tragen).gang == "schildarm": tr = c
	var soll := tr.schild_abspreiz
	var stelle := ap.current_animation_position if ap else 0.0
	var bilder := []
	for a in [0.0, soll]:
		tr.schild_abspreiz = a
		if ap: ap.seek(stelle, true); ap.pause()
		neu._bilder = 0
		neu._v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		for k in 20: await process_frame
		await RenderingServer.frame_post_draw
		var img := root.get_texture().get_image()
		img.save_png(aus + "/1417_ganz_%d.png" % int(a))   # zur eigenen Prüfung
		var mass := Vector2(img.get_size()) / root.get_visible_rect().size
		var g := neu.get_global_rect()
		# linkes Drittel des Bilds: die Wachsoldatin ganz, ohne den Zauberlehrling
		var r := Rect2i(Vector2i(g.position * mass), Vector2i(Vector2(g.size.x * 0.34, g.size.y) * mass)).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		bilder.append(img.get_region(r))
		print("SCHILDBILD1417 abspreiz %.0f Ausschnitt %s" % [a, r])
	var w: int = bilder[0].get_width(); var h: int = bilder[0].get_height()
	var ganz := Image.create(w * 2 + 8, h, false, Image.FORMAT_RGBA8)
	ganz.fill(Color(0, 0, 0))
	ganz.blit_rect(bilder[0], Rect2i(0, 0, w, h), Vector2i(0, 0))
	ganz.blit_rect(bilder[1], Rect2i(0, 0, w, h), Vector2i(w + 8, 0))
	ganz.save_png(aus + "/1417_vorher_nachher.png")
	print("BILD ", aus + "/1417_vorher_nachher.png")
	quit()
