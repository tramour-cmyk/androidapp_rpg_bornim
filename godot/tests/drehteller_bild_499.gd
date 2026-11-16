extends "res://tests/drehteller_499.gd"
# 499 Drehteller mit Bildern: dieselbe Messung wie drehteller_499.gd, dazu je Klasse ein Bild in drei Drehungen nebeneinander (PNG nach
# OBERFLAECHE_AUS); nur mit Fenster (godot.yml „Drehteller 499“, drehteller=ja)

func bilder(dt: Drehteller, k: String, aus: String) -> void:
	var reihe: Array[Image] = []
	for winkel in [0.0, 90.0, 200.0]:
		dt.teller.rotation.y = deg_to_rad(winkel)
		dt.set_process(false)
		for i in 4: await process_frame
		await RenderingServer.frame_post_draw
		reihe.append(dt.get_child(0).get_texture().get_image())
	var b := reihe[0].get_width(); var h := reihe[0].get_height()
	var ges := Image.create(b * 3, h, false, Image.FORMAT_RGBA8)
	ges.fill(Color(0.05, 0.04, 0.03))
	for i in 3:
		var x := reihe[i]; x.convert(Image.FORMAT_RGBA8)
		ges.blend_rect(x, Rect2i(0, 0, b, h), Vector2i(b * i, 0))
	ges.save_png(aus + "/499_%s.png" % k)
	print("BILD ", aus + "/499_%s.png" % k)
