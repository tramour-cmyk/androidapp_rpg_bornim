extends SceneTree
# 399.4 (Chef 31.10., Build 143: „Rand oben … fehlt, Handykamera im Bild (im Kampf gesehen)“): ohne Bild; das schwarze Band oben
# (rand.gd) haengt an der Welt (spiel.gd); im Kampf wird die Welt unsichtbar (visible = false). Bleibt das Band sichtbar?
# Aufruf: im Ordner godot mit -s res://tests/rand_kampf_3994.gd -> „RANDKAMPF n Fehler“

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var welt := Node3D.new()   # wie spiel.gd: Node3D, das Band als CanvasLayer darin
	root.add_child(welt)
	var band := Rand.band(80.0)
	welt.add_child(band)
	await process_frame
	var streifen := band.get_child(0) as ColorRect
	print("Welt sichtbar: Band %s" % streifen.is_visible_in_tree())
	welt.visible = false   # spiel.gd beim Kampfbeginn
	await process_frame
	var sichtbar := streifen.is_visible_in_tree() and band.visible
	print("Welt unsichtbar (Kampf): Band %s %s" % [sichtbar, "" if sichtbar else "FEHLER"])
	if not sichtbar: fehler += 1
	print("RANDKAMPF %d Fehler" % fehler)
	quit(1 if fehler else 0)
