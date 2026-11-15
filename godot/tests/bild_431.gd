# 431: zwei Einzelbilder aus probe/drehfilm.tscn (DREH=<teil>, BILD=<pfad ohne Endung>) nach 3 und 9,5 s, nur zur eigenen Prüfung
# Aufruf: DREH=431u BILD=/tmp/b UMHANG=<ordner> VOELKER=<ordner> CC0=<cc0> godot --path godot --fixed-fps 10 -s res://tests/bild_431.gd
extends SceneTree

func _initialize() -> void:
	root.add_child(load("res://probe/drehfilm.tscn").instantiate())
	_bild.call_deferred()


func _bild() -> void:
	var bisher := 0
	for t in [3.0, 9.5]:
		while bisher < int(t * 10):
			await process_frame
			bisher += 1
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("BILD") + "-%d.png" % int(t))
	quit()
