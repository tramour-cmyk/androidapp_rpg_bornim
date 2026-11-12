extends SceneTree
# 867 Probebild (Chef 10.11., 13:48; Zu 867 „Erst Bild vorlegen (welche Helden, Völker, Ausrüstung), dann bauen“): das Hauptmenü wie
# im Spiel, einmal mit dem alten Bild der vier Kotlin-Figuren (vorher), einmal mit HauptmenueHelden an derselben Stelle (nachher).
# Nur mit Fenster (godot.yml „Hauptmenübild (867)“), im Ordner godot:
#   PROBE=867 xvfb-run -a godot --path . --rendering-driver vulkan --rendering-method mobile --resolution 540x1170 \
#     -s res://tests/hauptmenue_bild_867.gd -- --aus=<ordner>

var aus := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	_lauf.call_deferred()


func knips(n: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")


func _lauf() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	Hauptmenue.vorspann_gezeigt = true
	var hm := Hauptmenue.new(null)
	root.add_child(hm)
	for i in 10: await process_frame
	var alt: TextureRect = null
	for r in hm.find_children("*", "TextureRect", true, false):
		if alt == null and (r as TextureRect).texture is ImageTexture and (r as TextureRect).custom_minimum_size.x > 200: alt = r
	if alt == null:
		print("MENU867 altes Bild nicht gefunden"); quit(1); return
	await knips("867_vorher")
	var neu := HauptmenueHelden.new(alt.custom_minimum_size.x / AktionsKnopf.DP)
	neu.size_flags_horizontal = alt.size_flags_horizontal
	var eltern := alt.get_parent()
	var i := alt.get_index()
	eltern.add_child(neu)
	eltern.move_child(neu, i)
	alt.visible = false
	for k in 15: await process_frame
	print("MENU867 Figuren %d: %s" % [neu.figuren.size(), HauptmenueHelden.HELDEN.map(func(h): return "%s %s %s" % [h["herkunft"], h["volk"], h["geschlecht"]])])
	for h in HauptmenueHelden.HELDEN:
		var w := HauptmenueHelden.wahl(h)
		print("MENU867 %s: Ausruestung %s" % [h["herkunft"], (w["ausruestung"] as Dictionary).keys().map(func(p): return "%s=%s" % [p, str(w["ausruestung"][p].get("base", "?")) if w["ausruestung"][p] is Dictionary else str(w["ausruestung"][p])])])
	await knips("867_nachher")
	quit()
