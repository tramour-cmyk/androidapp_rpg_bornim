extends SceneTree
# 531 Vorlage (Chef 03.11., 23:42: „Gesicht wirkt sonderbar, Bogen fehlt, vertreibt keine Mobs. Hat er schon Animation?“; Figur zuerst als
# Standbild): Garrick am Feuer im Flüsterwald, Kamera nah auf ihn (wie „Nah“ im Spiel), Blick wie im Spiel; 1 Tag in Ruhe, 2 Tag mitten
# in der Abwehr (Fackel hoch, Schwung), 3 Nacht in der Abwehr. Bildlauf: nur mit PROBE=531 (389).
# Aufruf: im Ordner godot: xvfb-run godot --path . --resolution 720x1280 -s res://tests/garrick_bild_531.gd -- --ordner=<dir>

var dir := "/tmp/garrick531"

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ordner="): dir = a.substr(9)
	DirAccess.make_dir_recursive_absolute(dir)
	_lauf.call_deferred()

func knips(spiel, n: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, n])
	print("BILD ", n)

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 10 * 60
	spiel.betrete("forest", Vector2i(7, 12), "UP")
	if spiel.herde: spiel.herde.aus = true
	spiel.ui.mess.visible = false
	spiel.ui.oben.visible = false
	var g: Leute = null
	for l in spiel.leute.get_children():
		if l is Leute and String(l.daten.get("id", "")) == "garrick": g = l
	if g == null:
		print("kein Garrick"); quit(1); return
	spiel.kamera.ziel = g
	spiel.kamera.nah_fern()
	spiel.kamera.springe()
	await create_timer(2.0).timeout
	spiel.ui.textfeld.visible = false
	await knips(spiel, "1_tag_ruhe")
	var wo: Vector3 = g.global_position + Vector3(3.5, 0, 3.5)   # das Tier suedoestlich, zur Kamera hin
	g.wehre_ab(wo)
	while g.abwehr.t < 1.15: await process_frame
	spiel.ui.textfeld.visible = false
	await knips(spiel, "2_tag_abwehr")
	await create_timer(3.0).timeout
	spiel.licht.umschalten()
	spiel.zustand.minuten = 23 * 60
	await create_timer(2.5).timeout
	g.wehre_ab(wo)
	while g.abwehr.t < 1.7: await process_frame
	spiel.ui.textfeld.visible = false
	await knips(spiel, "3_nacht_abwehr")
	print("GARRICKBILD fertig")
	quit()
