# 284.7b (Jerry; Chef 13.11., 16:28: „1003 Keuchen = Film mit Ton“): Film mit Ton zu 1003 (alt Panting.kt): im Dorf keucht der Held
# atemlos, erst als Heldin (Frauenstimme), dann als Held (Männerstimme), je ATEM_S Sekunden, Beschriftung oben. spiel.gd gibt klang.atme
# jedes Bild das Geschlecht aus aussehen.geschlecht mit (keuchen_1003 misst dasselbe ohne Bild).
# Aufruf (Film): xvfb-run godot --path godot --rendering-driver opengl3 --resolution 540x1170 --write-movie <datei>.avi --fixed-fps 30
#   -s res://tests/film_keuchen_1003.gd -- --film1003=1     (ein Argument hinter „--“, sonst legt spiel.gd das Hauptmenü darüber)
extends SceneTree

const ATEM_S := 7.0
const FPS := 30.0

var _gesperrt := -1.0
var _zug_echt := 0.0

var lb: Label


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 30:
		await process_frame
	var klang = root.get_node_or_null("Klang")
	if klang == null or spiel.held == null or spiel.zustand == null:
		print("FEHLER kein Klang oder kein Held")
		quit(1)
		return
	var cl := CanvasLayer.new()
	cl.layer = 100
	root.add_child(cl)
	var vs: Vector2 = root.get_visible_rect().size
	lb = Label.new()
	lb.position = Vector2(vs.x * 0.05, vs.y * 0.08)
	lb.add_theme_font_size_override("font_size", int(vs.x / 16.0))
	lb.add_theme_color_override("font_color", Color(0.95, 0.82, 0.45))
	lb.add_theme_color_override("font_outline_color", Color.BLACK)
	lb.add_theme_constant_override("outline_size", 6)
	cl.add_child(lb)
	for i in 30:
		await process_frame
	# Takt nach Filmzeit: klang.atme rechnet in echter Zeit (Time.get_ticks_msec); der Film läuft mit --fixed-fps langsamer als die
	# Uhr, dann käme der Atemzug im Film zu oft. Darum gibt der Film den Zeitpunkt jedes Zugs frei (_atem_naechst), den Zug selbst,
	# Stimme und Pegel spielt das Spiel (spiel.gd → klang.atme mit dem Geschlecht aus aussehen.geschlecht)
	for g in ["w", "m"]:
		lb.text = "1003 · atemlos: " + ("Heldin" if g == "w" else "Held")
		spiel.zustand.aussehen["geschlecht"] = g
		var b0 := Engine.get_process_frames()
		var naechst := 0.0
		var zuege := 0
		print("FILM1003 %s ab Bild %d" % [g, b0])
		while Engine.get_process_frames() - b0 < int(ATEM_S * FPS):
			spiel.zustand.atemlos = true
			spiel.zustand.ausdauer = 0.0
			var jetzt := (Engine.get_process_frames() - b0) * 1000.0 / FPS
			var echt := float(Time.get_ticks_msec())
			if klang._atem_naechst > echt and klang._atem_naechst < echt + 1.0e8 and klang._atem_naechst != _gesperrt:
				zuege += 1     # das Spiel hat eben einen Zug gespielt und den nächsten in echter Zeit vorgemerkt
				naechst = jetzt + (klang._atem_naechst - _zug_echt)
			if jetzt >= naechst:
				klang._atem_naechst = 0.0
				_zug_echt = echt
			else:
				_gesperrt = echt + 1.0e9
				klang._atem_naechst = _gesperrt
			await process_frame
		print("FILM1003 %s: %d Atemzüge in %.1f s Film (Atemzug %.0f ms)" % [g, zuege, ATEM_S, klang.atem_ms(g == "w")])
		spiel.zustand.atemlos = false
		spiel.zustand.ausdauer = 1.0
		for i in int(1.2 * FPS):
			await process_frame
	print("FILM1003 fertig, Bild %d" % Engine.get_process_frames())
	quit(0)
