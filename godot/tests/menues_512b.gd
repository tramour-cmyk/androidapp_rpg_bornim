extends SceneTree
# 512b Probe mit Bild am Rechner (nicht im Bau): alle Zustaende von menues_512b_schritte.gd als PNG nach --ordner=<dir>/<name>.png,
# zum Vergleich mit der alten Fassung (tools/preview MENUE512B=1, tools/menues_512b_blatt.py). Vorher ohne Bild pruefen:
# tests/menues_512b_test.gd. Bildlauf nur mit PROBE=512b (389).
# Aufruf: im Ordner godot: PROBE=512b xvfb-run -a -s "-screen 0 1080x2340x24" godot --path . --resolution 1080x2340 -s res://tests/menues_512b.gd -- --ordner=<dir>

var ordner := "/tmp/menues512b"
var schritte
var zahl := 0

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ordner="): ordner = a.substr(9)
	DirAccess.make_dir_recursive_absolute(ordner)
	_lauf.call_deferred()

func knips(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/%s.png" % [ordner, n])
	zahl += 1
	print("BILD ", n)

func fehlt(n: String, grund: String) -> void:
	print("FEHLT %s: %s" % [n, grund])

func _lauf() -> void:
	var skript = load("res://tests/menues_512b_schritte.gd")
	if skript == null or not skript.can_instantiate():
		print("FEHLER Schritte laden nicht")
		quit(1)
		return
	schritte = skript.new(self, self)
	await schritte.lauf()
	print("512b fertig: %d Bilder" % zahl)
	quit(0)
