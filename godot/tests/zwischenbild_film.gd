extends Node
# 399.1 am Rechner: das Intro einmal ganz, wie beim neuen Spiel (mit dem Autoload Klang, darum als Szene, nicht mit -s), dazu
# Standbilder; mit --write-movie als Film samt Ton. Aufruf im Ordner godot: Szene res://tests/zwischenbild_film.tscn mit
# --resolution 540x1170 --write-movie <datei>.avi --fixed-fps 30, nach „--“ --bilder=<ordner>; 613: mit --art=tempel die Morgenandacht
# (Musik TEMPLE, Kerzen und Staub), sonst das Intro

const STAND := [3000, 7900, 16400, 20400, 22300, 31800]   # Bild 1, Blende 1-2, Bild 3 (Zug), Bild 3 spaet, Blende 3-4, schwarz
const STAND_TEMPEL := [3000, 10200, 17400, 23500, 26600, 33000]   # 613: je Bild eines, Bild 4 zweimal (Staub treibt)
var ordner := ""
var art := "intro"
var z: Zwischenbild

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--bilder="): ordner = a.trim_prefix("--bilder=")
		if a.begins_with("--art="): art = a.trim_prefix("--art=")
	Sprache.lade()
	Sprache.setze("de")
	var k := get_node_or_null("/root/Klang")
	if k: k.spiele_szene("TEMPLE" if art == "tempel" else "TITLE")
	await get_tree().create_timer(1.0).timeout
	z = Zwischenbild.new(art, k)
	add_child(z)
	_bilder()
	await z.fertig
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()

func _bilder() -> void:
	if ordner == "": return
	DirAccess.make_dir_recursive_absolute(ordner)
	for t in (STAND_TEMPEL if art == "tempel" else STAND):
		while z.ms < t: await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s_%05d.png" % [ordner, art, t])
		print("BILD ", t)
	# die Rueckfrage beim Tippen
	z.frage()
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s_frage.png" % [ordner, art])
	z.fragt.queue_free(); z.fragt = null
