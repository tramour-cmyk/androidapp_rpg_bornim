extends SceneTree
# 1119 (283.1 ungetestet; Chef 13.11., 16:28: Aussehen als Film statt am Handy): Fußstaub am Mittag auf dem Erdweg, wie im Spiel
# (spiel.tscn, Spielkamera): zweimal erst 2 s gehen, dann 2 s rennen, dazwischen kurz stehen; etwa 12 s, ohne Oberfläche.
# Nur mit Fenster und --write-movie (Schritt „Staubfilm (1119)“ im Lauf der APK), im Ordner godot:
#   xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 \
#     -s res://tests/film_staub_1119.gd

var spiel

func _initialize() -> void: _lauf.call_deferred()

func warte(s: float) -> void:
	for i in int(s * 30.0): await process_frame

func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 12 * 60
	spiel.betrete("village", Vector2i(17, 6), "UP")   # Erdweg wie film_dorf_814
	for i in 5: await process_frame
	spiel.licht.ziel = 0.0
	spiel.licht.stelle(0.0)   # Mittag (mit Argument folgt das Licht nicht der Uhr, film_dorf_814)
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	spiel.kamera.springe()
	print("BEGINN %.2f" % (Engine.get_process_frames() / 30.0))
	for runde in 2:
		var r := Vector3(0, 0, -1) if runde == 0 else Vector3(0, 0, 1)
		print("FILM1119 Runde %d gehen (Bild %d)" % [runde + 1, Engine.get_process_frames()])
		spiel.held.richtung = r
		await warte(2.0)
		spiel.held.richtung = Vector3.ZERO
		await warte(0.8)
		print("FILM1119 Runde %d rennen (Bild %d)" % [runde + 1, Engine.get_process_frames()])
		spiel.laufen_will = true
		spiel.held.richtung = r
		await warte(2.0)
		spiel.held.richtung = Vector3.ZERO
		spiel.laufen_will = false
		await warte(1.2)
	quit(0)
