extends SceneTree
# 1420 (Chef 16.11., 12:44/12:45: Fußstaub „zu stark … sieht nach Comic aus“, im Wald keiner): Vergleichsfilm am Mittag, Spielkamera,
# ohne Oberfläche; je Stück 1,3 s gehen, 1,5 s rennen auf Erde nach Norden: Dorf vorher (Werte vor 1420), Dorf nachher, Wald nachher,
# tiefer Wald nachher (im Wald gab es vorher keinen Staub). Gibt je Stück „FILM1420 <stück> (Bild n)“ aus. Nur mit Fenster und
# --write-movie (Schritt „Staubfilm (1420)“), im Ordner godot:
#   xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 -s res://tests/film_staub_1420.gd

var spiel

func _initialize() -> void: _lauf.call_deferred()

func warte(s: float) -> void:
	for i in int(s * 30.0): await process_frame

## eine Kachel auf Erde mit sieben begehbaren Erdkacheln nach Norden
func erdweg(fx: DorfEffekte) -> Vector2i:
	var k: Karte = spiel.karte
	var best := Vector2i(-1, -1); var lang := 0
	for y in range(2, k.hoehe - 1):
		for x in range(1, k.breite - 1):
			var n := 0
			while n < 8 and y - n >= 1 and k.begehbar(Vector2i(x, y - n)) and fx.erde(k.kachel_pos(Vector2i(x, y - n))): n += 1
			if n > lang: lang = n; best = Vector2i(x, y)
	return best

func _lauf() -> void:
	DorfEffekte.an = true
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 12 * 60
	print("BEGINN %.2f" % (Engine.get_process_frames() / 30.0))
	for stueck in [["village", true], ["village", false], ["forest", false], ["deep_forest", false]]:
		DorfEffekte.staub_alt = stueck[1]
		spiel.betrete(stueck[0], Vector2i(2, 2), "UP")
		for i in 5: await process_frame
		var fx: DorfEffekte = spiel.gebiet.effekte
		if fx == null: print("FILM1420 FEHLER keine Effekte in ", stueck[0]); continue
		var t := erdweg(fx)
		spiel.held.setze(t, "UP")
		spiel.licht.ziel = 0.0
		spiel.licht.stelle(0.0)
		for n in ["mess", "oben", "leiste", "textfeld"]:
			var k = spiel.ui.get(n)
			if k: k.visible = false
		spiel.kamera.zoom = 5.0
		spiel.kamera.springe()
		await warte(0.4)
		print("FILM1420 %s %s (Bild %d, Kachel %s)" % [stueck[0], "vorher" if stueck[1] else "nachher", Engine.get_process_frames(), t])
		spiel.held.richtung = Vector3(0, 0, -1)
		await warte(1.3)
		spiel.laufen_will = true
		await warte(1.5)
		spiel.held.richtung = Vector3.ZERO
		spiel.laufen_will = false
		await warte(0.4)
	DorfEffekte.staub_alt = false
	quit(0)
