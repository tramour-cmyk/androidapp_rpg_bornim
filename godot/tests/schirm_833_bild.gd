extends "res://tests/schirm_833.gd"
# 833: die Bilder zum Ablauf von schirm_833.gd, mit Fenster (xvfb-run), 1080 × 2340, nach BILD833_AUS (Vorgabe user://):
#   833_1_held_*, 833_2_gegner_*, 833_3_sieg_*   je heute und A: Mira am Zug, ein Wolf zieht (A: Tipp auf Angriff), Sieg

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("BILD833_AUS")
	if aus == "":
		aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")
