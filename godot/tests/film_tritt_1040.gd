extends SceneTree
# 1040 (Chef 12.11., 15:12, Grimmzahn: „wenn ich um den rumlaufe, dann dreht er sich … wie als ob er ein Playmobil-Männchen wäre“):
# Film wie im Spiel (spiel.tscn, Spielkamera): Tiefer Wald, der Held geht in gut 2,5 m Abstand im Bogen um Grimmzahn herum, bleibt
# stehen, geht zurück. Grimmzahn wendet sich ihm zu und tritt dabei (leute.gd stehen, Streuner.tritt_bis). Im Protokoll je Sekunde:
# Bewegung von Grimmzahn und ob er tritt.
# Nur mit Fenster und --write-movie, im Ordner godot (Aufruf wie film_dorf_814.gd, Schritt kampf=1040 in godot.yml).

var spiel
var titel: Label
var grimm = null


func _initialize() -> void:
	_lauf.call_deferred()


func _bogen(s: float, seite: float) -> void:
	var r := 2.6
	for i in int(s * 30.0):
		await process_frame
		var off: Vector3 = spiel.held.position - grimm.position
		off.y = 0.0
		var d := maxf(off.length(), 0.01)
		var tangente := Vector3(-off.z, 0, off.x) / d * seite
		spiel.held.richtung = (tangente + off / d * (r - d) * 0.8).normalized() * 0.6     # gemächlich gehen
		if i % 30 == 0:
			var a: AnimationPlayer = grimm.anim
			print("FILM1040 %.1f s Abstand %.2f m, Grimmzahn %s %.2f, tritt %s" % [i / 30.0, d, a.current_animation if a else "-",
				a.speed_scale if a else 0.0, str(Time.get_ticks_msec() < int(grimm.tritt_bis))])
	spiel.held.richtung = Vector3.ZERO


func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5:
		await process_frame
	var ebene := CanvasLayer.new()
	ebene.layer = 60
	root.add_child(ebene)
	titel = Label.new()
	titel.add_theme_font_size_override("font_size", 28)
	titel.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	titel.position = Vector2(24, 90)
	ebene.add_child(titel)
	spiel.zustand.minuten = 12 * 60
	spiel.betrete("deep_forest", Vector2i(22, 7), "UP")
	for i in 10:
		await process_frame
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k:
			k.visible = false
	for l in spiel.leute.get_children():
		if l.get("monster") == true:
			grimm = l
	if grimm == null:
		print("FILM1040 kein Grimmzahn")
		quit(1)
		return
	spiel.kamera.springe()
	titel.text = "1040 · Grimmzahn, der Held geht herum"
	for i in 60:
		await process_frame
	await _bogen(7.0, 1.0)
	titel.text = "1040 · Held steht"
	for i in 60:
		await process_frame
	titel.text = "1040 · zurück"
	await _bogen(7.0, -1.0)
	for i in 45:
		await process_frame
	print("FILM1040 fertig")
	quit(0)
