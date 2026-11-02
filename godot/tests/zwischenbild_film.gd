extends Node
# 399.1 am Rechner: das Intro einmal ganz, wie beim neuen Spiel (mit dem Autoload Klang, darum als Szene, nicht mit -s), dazu
# Standbilder; mit --write-movie als Film samt Ton. Aufruf im Ordner godot: Szene res://tests/zwischenbild_film.tscn mit
# --resolution 540x1170 --write-movie <datei>.avi --fixed-fps 30, nach „--“ --bilder=<ordner>

const STAND := [3000, 7900, 16400, 20400, 22300, 31800]   # Bild 1, Blende 1-2, Bild 3 (Zug), Bild 3 spaet, Blende 3-4, schwarz
var ordner := ""
var z: Zwischenbild

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--bilder="): ordner = a.trim_prefix("--bilder=")
	Sprache.lade()
	Sprache.setze("de")
	var k := get_node_or_null("/root/Klang")
	if k: k.spiele_szene("TITLE")
	await get_tree().create_timer(1.0).timeout
	z = Zwischenbild.new("intro", k)
	add_child(z)
	_bilder()
	await z.fertig
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()

func _bilder() -> void:
	if ordner == "": return
	DirAccess.make_dir_recursive_absolute(ordner)
	for t in STAND:
		while z.ms < t: await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/intro_%05d.png" % [ordner, t])
		print("BILD ", t)
	# die Rueckfrage beim Tippen
	z.frage()
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/intro_frage.png" % ordner)
	z.fragt.queue_free(); z.fragt = null
