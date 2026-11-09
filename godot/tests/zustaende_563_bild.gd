extends "res://tests/zustaende_563.gd"
# 563: die Bilder zum Ablauf von zustaende_563.gd, mit Fenster (xvfb-run), 1080 × 2340, nach BILD563_AUS (Vorgabe user://):
#   563_jetzt, 563_A   derselbe Augenblick (zwei Ansagen, die Gruppe am Zug, alle Wölfe „Blut 3“): heute und Vorschlag A

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD563_AUS")
	if aus == "":
		aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")
