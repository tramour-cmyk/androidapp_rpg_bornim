# 679 (Chef 08.11., 16:06–16:11, Build 269): im Kampf aus der Welt (Kleriker allein gegen Wölfe) fehlten Raster, Würfel, Gewinnen
# und Verlieren, „die Wölfe haben einen Lauf und ich habe keine Zusatzfunktionen mehr“; im Probekampf mit Söldner waren sie da.
# Ursache (nachgestellt): MARS rechnet im Hintergrund voraus; fällt der Held, steht „LOST“ fest, während die letzten Züge der Wölfe
# noch spielen, und die Oberfläche blendete die Schalter schon aus. Nachstellen wie spiel.gd kampf_im_wald (aufruf.gd, Blende, ohne
# Söldner), der Held wehrt nur ab, bis er fällt. Ohne Bild.
# Aufruf: im Ordner godot mit --headless -s res://tests/knoepfe_679.gd (Exit 0 = Schalter stehen, bis alles gezeigt ist)
extends SceneTree

const AufrufS = preload("res://kampf/aufruf.gd")

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _ein(name_: String, held, gegner: String, seed: int) -> void:
	var p = AufrufS.new()
	root.add_child(p)
	if not p.starte(gegner, held, null, "wald", "tag", 2, -1, -1, seed, Callable(), {"blende": true}):
		print("FEHLER %s: kein Kampf" % name_)
		fehler += 1
		return
	var w := 0
	while (p.kampf == null or not p.kampf.is_inside_tree()) and w < 60:
		await process_frame
		w += 1
	var kf = p.kampf
	var ui = kf.ui
	Engine.time_scale = 8.0
	var t := 0.0
	var nachspiel := 0.0     # Ausgang fest, Züge spielen noch
	var ohne := 0.0          # davon ohne Raster und Würfel
	while t < 600.0 and (kf.mars.outcome == "ONGOING" or kf.busy or kf.playing):
		await process_frame
		var dt := 1.0 / 60.0 * Engine.time_scale
		t += dt
		if kf.mars.outcome != "ONGOING" and kf.busy:
			nachspiel += dt
			if ui.dice_rect.size.x <= 0.0 or ui.grid_rect.size.x <= 0.0:
				ohne += dt
		if not kf.busy and not kf.playing and kf.mars.outcome == "ONGOING" and kf.mars.current().side == "PARTY":
			kf.order(["wait"])
	Engine.time_scale = 1.0
	await _frames(2)
	print("%s: %s nach %.0f s, Nachspiel %.1f s, davon ohne Schalter %.1f s, nach dem Ende Schalter %s" % [name_, kf.mars.outcome, t,
		nachspiel, ohne, ui.dice_rect.size.x > 0.0])
	if kf.mars.outcome == "ONGOING":
		fehler += 1
		print("FEHLER %s: Kampf nicht zu Ende" % name_)
	elif nachspiel <= 0.0:
		fehler += 1
		print("FEHLER %s: kein Nachspiel, nichts geprüft" % name_)
	elif ohne > 0.0:
		fehler += 1
		print("FEHLER %s: Schalter fehlten %.1f s, während die Züge noch spielten" % [name_, ohne])
	elif ui.dice_rect.size.x > 0.0:
		fehler += 1
		print("FEHLER %s: Schalter nach dem Ende noch da" % name_)
	if is_instance_valid(kf):
		kf.queue_free()
	if is_instance_valid(p):
		p.queue_free()
	await _frames(4)


func _lauf() -> void:
	Testmodus.geladen = true
	Testmodus.an = true
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await _frames(2)
	await _ein("Kleriker allein gegen Wolf mit Jungwölfen", Testmodus.probeheld("CLERIC", 1), "RUDEL", 7)
	print("KNOEPFE 679 %s" % ("ok" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
