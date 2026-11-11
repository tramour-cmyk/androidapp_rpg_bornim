extends SceneTree
# 814 (Spike): Film der Effekte Szene 1 Dorf am Abend (dorfeffekte.gd), wie im Spiel (spiel.tscn, Spielshader, Spielkamera), 20:30 Uhr:
#   1 Schlagbaum ohne, dann mit Effekten (gleiche Einstellung): Fackeln, Fahne, Kaminrauch; Held geht auf dem Erdweg (Fussstaub)
#   2 Schenke: Wandfackel neben der Tuer, Rauch; Held rennt die Strasse entlang (Fussstaub staerker)
#   3 Hühner: Held geht auf ein Huhn zu, es fliegt auf (Federn)
#   4 in der Schenke: Staub im Licht
# Nur mit Fenster und --write-movie, im Ordner godot:
#   xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 \
#     -s res://tests/film_dorf_814.gd

var spiel
var titel: Label

func _initialize() -> void:
	_lauf.call_deferred()

func warte(s: float) -> void:
	for i in int(s * 30.0):
		await process_frame

func abschnitt(text: String) -> void:
	titel.text = text
	print("FILM814 %s (Bild %d)" % [text, Engine.get_process_frames()])

# Lauf 1 (11.11., 12:52): mit Argument folgt das Licht nicht der Uhr (spiel.gd licht_nach_uhr), der Film lief am Tag; Abend von Hand
func abend() -> void:
	spiel.licht.ziel = 0.75
	spiel.licht.stelle(0.75)

func ui_aus() -> void:
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false

func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
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
	spiel.zustand.minuten = 20 * 60 + 30
	# 1 Schlagbaum ohne, dann mit
	GrasBausatz.an = false
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	abend()
	ui_aus()
	spiel.kamera.springe()
	print("FILM814 Anfang nacht %.2f" % spiel.gebiet.nacht_jetzt)
	print("BEGINN %.2f" % (Engine.get_process_frames() / 30.0))
	abschnitt("814 · Schlagbaum, 20:30 · ohne Effekte")
	await warte(3.0)
	GrasBausatz.an = true
	spiel.gebiet.gras_neu()
	abschnitt("814 · Schlagbaum, 20:30 · mit Effekten")
	await warte(3.0)
	abschnitt("814 · Gehen auf dem Erdweg: Fußstaub")
	spiel.held.richtung = Vector3(0, 0, -1)
	await warte(2.0)
	spiel.held.richtung = Vector3.ZERO
	await warte(2.5)
	# 2 Schenke
	spiel.held.setze(Vector2i(4, 8), "RIGHT")
	spiel.kamera.springe()
	abschnitt("814 · Schenke: Wandfackel, Rauch")
	await warte(3.5)
	abschnitt("814 · Rennen: Fußstaub")
	spiel.laufen_will = true
	spiel.held.richtung = Vector3(1, 0, 0)
	await warte(2.5)
	spiel.held.richtung = Vector3.ZERO
	spiel.laufen_will = false
	await warte(2.0)
	# 3 Huehner
	var huhn = null
	for l in spiel.leute.get_children():
		if String(l.daten.get("tier", "")) == "huhn": huhn = l; break
	if huhn:
		var k: Vector2i = huhn.kachel
		var start := k + Vector2i(-3, 0)
		for d in [Vector2i(-3, 0), Vector2i(3, 0), Vector2i(0, 3), Vector2i(0, -3)]:
			if spiel.karte.begehbar(k + d): start = k + d; break
		spiel.held.setze(start, "RIGHT")
		spiel.kamera.springe()
		abschnitt("814 · Huhn fliegt auf: Federn")
		await warte(1.0)
		print("FILM814 Huhn %s, Held %s, Weg %s" % [k, start, spiel.held.geh_zu(spiel.karte.kachel_pos(k))])
		# Lauf 1: das Huhn floh nicht, der Held kam nicht nah genug (FLUCHT_NAH 1,45 Kacheln); jetzt bis zu 6 s auf das Huhn zu
		for i in 180:
			await process_frame
			if huhn.flucht: print("FILM814 Huhn flieht nach %.1f s" % (i / 30.0)); break
			if i % 30 == 29: spiel.held.geh_zu(huhn.position)
		await warte(2.5)
	else:
		print("FILM814 kein Huhn")
	# 4 Schenke innen
	spiel.betrete("inn", Vector2i(4, 6), "UP")
	for i in 5: await process_frame
	abend()
	ui_aus()
	spiel.kamera.springe()
	abschnitt("814 · in der Schenke: Staub im Licht")
	await warte(5.0)
	print("FILM814 fertig")
	quit(0)
