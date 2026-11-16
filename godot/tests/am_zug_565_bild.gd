extends "res://tests/am_zug_565.gd"
# 565: die Bilder zum Ablauf von am_zug_565.gd, mit Fenster (xvfb-run), 1080 × 2340, nach BILD565_AUS (Vorgabe user://):
#   565_held_jetzt, 565_held_a, 565_held_b   Mira am Zug: heute, A (ihr Kasten wie ihr Feld in der Zugleiste), B (dazu die übrigen gedämpft)
#   565_gegner_a                            ein Gegner am Zug, A: kein Kasten hervorgehoben (Gegenargument)
#   565_soeldner_a                          der Söldner am Zug, A

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD565_AUS")
	if aus == "":
		aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")
