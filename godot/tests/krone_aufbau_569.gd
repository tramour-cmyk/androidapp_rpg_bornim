extends SceneTree
# 569 Auflage (1) (Sokrates 04.11., 19:5x: Ursache der Fehlläufe 19:50:31 und 19:51:10 nachstellen, ohne Bildbefehl, kein Probelauf):
# krone_569.gd mass die Tusche an Bildpunkten, die Camera3D.unproject_position liefert. Das Projekt streckt auf 1080 × 2340
# (project.godot stretch canvas_items, expand); im Fenster 800 × 800 ist der sichtbare Bereich dann 2340 × 2340, die Kamera rechnet
# darin, das Bild der Textur hat 800 × 800: die Mitte der Kugel lag bei etwa 1170, ausserhalb des Bildes, gemessen wurde daneben.
# Hier ohne Bild: Fall A wie in den beiden Laeufen (ohne Umstellung), Fall B mit der Umstellung aus krone_569.gd.
# Aufruf: im Ordner godot: godot --headless --path . --resolution 800x800 -s res://tests/krone_aufbau_569.gd (Exit 0 = Ursache gezeigt, B stimmt)

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _pruef(was: String, gut: bool) -> void:
	print(("gut " if gut else "FALSCH ") + was)
	if not gut: fehler += 1

func _fall(name: String) -> Vector2:
	var welt := Node3D.new()
	root.add_child(welt)
	var cam := Camera3D.new()
	cam.fov = 40
	welt.add_child(cam)
	cam.look_at_from_position(Vector3(0, 2.5, 8), Vector3.ZERO)
	cam.make_current()
	await process_frame
	var m := cam.unproject_position(Vector3.ZERO)
	print("%s: Fenster %s, sichtbar %s, Mitte der Kugel %s" % [name, root.size, root.get_visible_rect().size, m])
	welt.free()
	return m

func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(800, 800))
	root.size = Vector2i(800, 800)
	await process_frame
	var a := await _fall("A wie Lauf 1 und 2")
	_pruef("A: Mitte ausserhalb des 800er Bildes (Ursache)", a.x > 800.0 or a.y > 800.0)
	root.content_scale_size = Vector2i(800, 800)
	await process_frame
	var b := await _fall("B mit content_scale_size 800")
	_pruef("B: Mitte im Bild nahe 400", absf(b.x - 400.0) < 5.0 and b.y > 0.0 and b.y < 800.0)
	print("KRONEAUFBAU569 %d Fehler" % fehler)
	quit(1 if fehler else 0)
