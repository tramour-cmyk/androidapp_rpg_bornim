extends SceneTree
# 1205b Bild an den Chef (Lauf frei Sokrates 18.11., 16:32): Grafik Niedrig, dieselbe Stelle in Dorf und Flüsterwald, links vorher (unser
# Gras und die gezeichneten Blütenkleckse, kein Kit wie bis Build 299), rechts nachher (unser Gras und die Blumen des Kits, Kleckse aus,
# 1205b A). Vorher wird im selben Lauf nachgestellt: Kit-Blumen unsichtbar, Kleckse zurück. Spielkamera, Handygröße. Im Ordner godot:
#   PROBE=1205 xvfb-run -a -s "-screen 0 1080x2340x24" godot --path . --rendering-driver opengl3 --resolution 540x1170 \
#     -s res://tests/wiese_bild_1205b.gd -- --aus=<ordner>

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
	Grafik.zwang = Grafik.NIEDRIG
	Grafik.aktiv = Grafik.NIEDRIG
	var spiel = (load("res://spiel.tscn") as PackedScene).instantiate()
	root.add_child(spiel)
	for i in 20: await process_frame
	Grafik.aktiv = Grafik.NIEDRIG
	spiel.ui.mess.visible = false
	spiel.ui.oben.visible = false
	spiel.zustand.minuten = 10 * 60
	for o in [["dorf", "village", Vector2i(13, 10), "UP"], ["wald", "forest", Vector2i(5, 7), "LEFT"]]:
		spiel.betrete(o[1], o[2], o[3])
		if spiel.herde: spiel.herde.aus = true
		for i in 45: await process_frame
		var bilder := []
		for vorher in [true, false]:
			GrasBausatz.vorher = vorher
			for m in spiel.gebiet.kit_gras: m.queue_free()
			spiel.gebiet.kit_gras.clear()
			spiel.gebiet.gras_neu()
			if vorher:
				for m in spiel.gebiet.kit_gras: m.visible = false   # wie bis Build 299: in Niedrig kein Kit
			spiel.held.setze(o[2], o[3]); spiel.kamera.springe()
			spiel.ui.textfeld.visible = false
			var img: Image = await _knips(spiel)
			print("WIESE1205B %s %s Stufe %d, Kit %d Netze, nur Blumen %s" % [o[0], "vorher" if vorher else "nachher", Grafik.aktiv, spiel.gebiet.kit_gras.size(), spiel.gebiet.kit_nur_blumen])
			img.save_png("%s/1205b_%s_%s.png" % [aus, o[0], "vorher" if vorher else "nachher"])
			bilder.append(img)
	GrasBausatz.vorher = false
	quit()
