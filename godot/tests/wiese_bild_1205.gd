extends SceneTree
# 1205 Bild an den Chef: Blumenwiese und Wiese mit dem Gras des Kits, links vorher (Büschel kurz/mittel, hohes Gras nur „tall“, gezeichnete
# Blüten aus dorf.py), rechts nachher (mehr Büschelarten, Blumen des Kits dichter, ohne die Kleckse); dieselbe Stelle, dieselbe Zeit.
# Je Ort ein Bild: Flüsterwald Blumenwiese (Kräuterstelle wie --wald), Dorf Blumenfleck am Weg. Nur mit Fenster, im Ordner godot:
#   PROBE=1205 xvfb-run -a -s "-screen 0 1080x2340x24" godot --path . --rendering-driver opengl3 --resolution 540x1170 \
#     -s res://tests/wiese_bild_1205.gd -- --aus=<ordner>

var aus := ""

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	_lauf.call_deferred()

func _knips(spiel: Node) -> Image:
	for k in 30: await process_frame
	await RenderingServer.frame_post_draw
	return spiel.get_viewport().get_texture().get_image()

func _lauf() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	var spiel = (load("res://spiel.tscn") as PackedScene).instantiate()
	root.add_child(spiel)
	for i in 20: await process_frame
	spiel.ui.mess.visible = false
	spiel.ui.oben.visible = false
	spiel.zustand.minuten = 10 * 60
	for o in [["wald", "forest", Vector2i(5, 7), "LEFT"], ["dorf", "village", Vector2i(13, 10), "UP"]]:
		spiel.betrete(o[1], o[2], o[3])
		if spiel.herde: spiel.herde.aus = true
		for i in 45: await process_frame
		var bilder := []
		for vorher in [true, false]:
			GrasBausatz.vorher = vorher
			for m in spiel.gebiet.kit_gras: m.queue_free()
			spiel.gebiet.kit_gras.clear()
			spiel.gebiet.gras_neu()
			spiel.held.setze(o[2], o[3]); spiel.kamera.springe()
			spiel.ui.textfeld.visible = false
			var img: Image = await _knips(spiel)
			img.save_png("%s/1205_%s_%s.png" % [aus, o[0], "vorher" if vorher else "nachher"])   # zur eigenen Prüfung
			print("WIESE1205 %s %s Kit %d Netze, Blüten %d" % [o[0], "vorher" if vorher else "nachher", spiel.gebiet.kit_gras.size(), spiel.gebiet.blueten.size()])
			bilder.append(img)
		var w: int = bilder[0].get_width(); var h: int = bilder[0].get_height()
		var ganz := Image.create(w * 2 + 8, h, false, Image.FORMAT_RGBA8)
		ganz.fill(Color(0, 0, 0))
		ganz.blit_rect(bilder[0], Rect2i(0, 0, w, h), Vector2i(0, 0))
		ganz.blit_rect(bilder[1], Rect2i(0, 0, w, h), Vector2i(w + 8, 0))
		ganz.save_png("%s/1205_%s_vorher_nachher.png" % [aus, o[0]])
		print("BILD %s/1205_%s_vorher_nachher.png" % [aus, o[0]])
	GrasBausatz.vorher = false
	quit()
