# 1118 (Chef 13.11., 10:06, Test 282: „Diesmal scheint der Zoom ein bisschen arg weit reinzugehen … eine Mindeststufe festlegen“;
# Bild: nur Rocksaum und Schuhe im Gras): ohne Bild. Im Dorf (Gebietskarte mit Randwald, 505c) mit zwei Fingern ganz hineinzoomen
# (Kamera.kneifen wie steuerung.gd), dann folgt die Kamera einige Bilder; gemessen wird die Bildbreite (size) und ob der Held von
# Kopf bis Fuss im Bild steht. Vorher (nachgestellt 13.11., 11:50): kneifen erlaubte NAH * 0,8 = 2,72 m, am_rand verlangt den Helden
# RAND_HELD 1,4 m vom Bildrand, bei 1,36 m halber Breite geht das nie, die Suche schrumpfte die Breite auf 0,3 × = 0,82 m.
# Aufruf: im Ordner godot mit --fixed-fps 30 -s res://tests/zoom_1118.gd -> „ZOOM1118 n Fehler“
extends SceneTree

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	for ort in [["village", Vector2i(30, 25)], ["village", Vector2i(3, 23)]]:
		spiel.betrete(ort[0], ort[1], "DOWN")
		for i in 10: await process_frame
		var kam: Kamera = spiel.kamera
		for i in 40: kam.kneifen(0.8)          # zwei Finger zusammen, so weit es geht
		for i in 90: await process_frame
		var held: Node3D = spiel.held
		var vp: Vector2 = root.get_visible_rect().size
		var fuss: Vector2 = kam.unproject_position(held.global_position)
		var kopf: Vector2 = kam.unproject_position(held.global_position + Vector3(0, 1.8, 0))
		print("%s %s: zoom %.2f m, Bildbreite %.2f m, Fuss %s, Kopf %s (Bild %s)" % [ort[0], ort[1], kam.zoom, kam.size, fuss.round(), kopf.round(), vp])
		pruefe(kam.size >= Kamera.NAH - 0.05, "%s %s: ganz hineingezoomt ist das Bild mindestens %.1f m breit (heute %.2f)" % [ort[0], ort[1], Kamera.NAH, kam.size])
		var r := Rect2(Vector2.ZERO, vp)
		pruefe(r.has_point(fuss) and r.has_point(kopf), "%s %s: Held von Kopf bis Fuss im Bild" % [ort[0], ort[1]])
		for i in 40: kam.kneifen(1.25)
		for i in 5: await process_frame
	print("ZOOM1118 %d Fehler" % fehler)
	quit(1 if fehler else 0)
