extends SceneTree
# 1270.4 (1270 A, Chef 15.11., 10:51; 22:43: „Da wäre jetzt, glaube ich, wieder ein Film gut, weil da soll man ja was sehen.“):
# Vergleichsfilm Glühen und vorberechnetes Höhlenlicht, wie im Spiel (spiel.tscn, Spielkamera, Renderer mobile). Der Held geht mit
# brennender Fackel durch die Blutzahnhöhle: Lager mit Lagerfeuer, Graks Halle mit Wandfackeln, Westflügel mit Kristallen und Pilzen. Dieselbe Folge
# einmal je Fassung (--glow1270=0/1, cave.bin mit oder ohne GEBACKEN=1 aus hoehle.py); nebeneinander setzt sie ffmpeg zusammen.
# Nur mit Fenster und --write-movie, im Ordner godot:
#   xvfb-run … godot --rendering-driver vulkan --rendering-method mobile --path . --resolution 540x1170 --write-movie a.avi
#     --fixed-fps 30 -s res://tests/film_licht_1270.gd -- --glow1270=1

var spiel


func _geh(ziel: Vector2i, tempo := 0.6) -> void:
	var z: Vector3 = spiel.karte.kachel_pos(ziel)
	for i in 30 * 8:
		var d: Vector3 = z - spiel.held.position
		d.y = 0.0
		if d.length() < 0.12: break
		spiel.held.richtung = d.normalized() * tempo
		await process_frame
	spiel.held.richtung = Vector3.ZERO


# Zeilen beim Betreten („Ein modriger Geruch …“) halten den Helden an: wie am Handy antippen
func _durch() -> void:
	for i in 80:
		if not spiel.ui.spricht() and spiel.szene.is_empty(): return
		spiel.ui.naechste()
		await process_frame


func _warte(s: float) -> void:
	for i in int(s * 30.0):
		await process_frame


func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5:
		await process_frame
	spiel.zustand.minuten = 12 * 60
	spiel.betrete("cave", Vector2i(13, 16), "RIGHT")
	await create_timer(1.5).timeout     # Blende nach dem Betreten
	await _durch()
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	Testmodus.alles_sichtbar = true      # Prüfgegenstand ist das Licht, nicht der Nebel
	Herde.beachten_nicht = true          # keine Begegnung mitten im Film (alle Fassungen gleich)
	spiel.held.fackel_neu(true, false, true)
	print("FILM1270 Glühen %s, Fackel %s" % [Licht.gluehen_an(), spiel.held.traegt_fackel])
	spiel.kamera.zoom = 7.0
	spiel.kamera.springe()
	print("FILM1270 Start Bild %d" % Engine.get_frames_drawn())   # ab hier laufen alle Fassungen gleich (Schnitt mit ffmpeg)
	await _warte(0.5)
	await _geh(Vector2i(17, 16))           # Lager: am Lagerfeuer (16, 15) vorbei
	print("FILM1270 Lager, Held auf %s" % str(spiel.held.kachel))
	spiel.held.setze(Vector2i(8, 2), "RIGHT")
	spiel.kamera.springe()
	await _warte(0.5)
	await _geh(Vector2i(13, 2))            # Graks Halle: Wandfackeln (7, 1), (15, 1)
	print("FILM1270 Halle, Held auf %s" % str(spiel.held.kachel))
	spiel.held.setze(Vector2i(6, 9), "LEFT")
	spiel.kamera.springe()
	await _warte(0.5)
	await _geh(Vector2i(3, 9))             # Westflügel: Kristalle (3, 6), (6, 6), Leuchtpilze (2, 7), (7, 8), (2, 9)
	print("FILM1270 Westflügel, Held auf %s" % str(spiel.held.kachel))
	await _warte(0.5)
	print("FILM1270 fertig")
	quit(0)


func _initialize() -> void:
	_lauf.call_deferred()
