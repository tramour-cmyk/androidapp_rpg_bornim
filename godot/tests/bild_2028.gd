extends SceneTree
# 2028 (Nora): Beleg Handgelenke, Spielkamera (spiel.tscn, Spielshader, Tusche) in Handygröße, nächster Fingerzoom (Kamera.NAH), von vorn.
# Aufbau wie bild_1654.gd (1654, Zweig claude/jerry-1653-kleid): Person in ihrem Raum, Held unsichtbar, Blick wie karten.json, Pose Stehen,
# Bild 0, gieren 0. Ein Bild nach --aus=<Datei>, Zeile BILD2028 mit den Bildpunkten der Handgelenke (Knochen hand_l, hand_r).
# Nur mit Fenster, im Ordner godot:
#   xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 1080x2340 -s res://tests/bild_2028.gd -- --aus=<Datei> --wer=rowena --karte=inn

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var aus := "user://bild_2028.png"
	var wer_id := "rowena"
	var karte := "inn"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
		if a.begins_with("--wer="): wer_id = a.substr(6)
		if a.begins_with("--karte="): karte = a.substr(8)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 12 * 60
	spiel.betrete(karte, Vector2i(1, 1), "DOWN")
	for i in 10: await process_frame
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	var wer: Leute = null
	for l in spiel.leute_liste():
		if String(l.daten.get("id", "")) == wer_id: wer = l
	if wer == null:
		print("BILD2028 FEHLER %s fehlt" % wer_id)
		quit(1)
		return
	spiel.held.setze(wer.kachel + Vector2i(0, 2), "UP")
	spiel.held.visible = false
	wer.set_process(false)
	wer.set_physics_process(false)
	wer.blick = {"UP": PI, "DOWN": 0.0, "LEFT": -PI / 2, "RIGHT": PI / 2}.get(String(wer.daten.get("blick", "DOWN")), 0.0)
	wer.rotation.y = wer.blick
	var ap := wer.anim
	ap.speed_scale = 0.0
	ap.play("Stehen", 0.0)
	ap.seek(0.0, true)
	var k: Kamera = spiel.kamera
	k.ziel = wer
	k.nah = true
	k.zoom = Kamera.NAH
	k.gieren_ziel = 0.0
	k.springe()
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var bild := root.get_texture().get_image()
	bild.save_png(aus)
	var sk := Gebiet.finde(wer, "Skeleton3D") as Skeleton3D
	var z := "BILD2028 %s" % aus
	for bn in ["hand_l", "hand_r"]:
		var p := k.unproject_position(sk.global_transform * sk.get_bone_global_pose(sk.find_bone(bn)).origin)
		z += " %s %d %d" % [bn, int(p.x), int(p.y)]
	var f := k.unproject_position(wer.global_position)
	var s := k.unproject_position(wer.global_position + Vector3(0, 1.8, 0))
	print(z + " Fuss %d %d Scheitel %d %d" % [int(f.x), int(f.y), int(s.x), int(s.y)])
	quit(0)
