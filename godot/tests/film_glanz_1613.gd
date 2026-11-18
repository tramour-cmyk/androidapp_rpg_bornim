extends SceneTree
# 1613 (Chef 02.11., 11:28: „cool, wenn man da irgendwie noch eine Art Effekt draufkriegen“): Effekt statt Färbung für episch und
# göttlich im Dorf wie im Spiel (spiel.tscn, Spielshader mit Tusche, Spielkamera nah), Aufbau wie film_staffel_4583.gd. Der Held geht
# auf der Straße hin und her; alle REIHE_S Sekunden die nächste Waffe: Schein und Glut (Fassung C, Vorentscheid 18.11.) am epischen und
# göttlichen Langschwert und am epischen Morgenstern, zuletzt selten ohne Effekt. Ohne Bild (headless): prüft die Glut an der Waffe.
# Nur mit Fenster und --write-movie, im Ordner godot:
#   xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 \
#     -s res://tests/film_glanz_1613.gd -- --film1613

const FOLGE := [["longsword", 11, "EPIC", "episch, Langschwert"], ["longsword", 11, "DIVINE", "göttlich, Langschwert"],
	["morningstar", 11, "EPIC", "episch, Morgenstern"], ["longsword", 11, "RARE", "selten, ohne Effekt"]]
const REIHE_S := 2.4

var spiel
var titel: Label
var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var reihe: Array = FOLGE
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
	spiel.zustand.minuten = 15 * 60
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	spiel.licht.ziel = 0.0
	spiel.licht.stelle(0.0)
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	spiel.kamera.zoom = spiel.kamera.NAH
	spiel.kamera.springe()
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	for i in reihe.size():
		var e: Array = reihe[i]
		var g := {"uid": 9000 + i, "base": e[0], "rarity": e[2], "ilvl": e[1], "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		hw.ausruestung["MAIN_HAND"] = g
		spiel.held_figur_neu("")
		var schl := Staffel.schluessel(g)
		var am: bool = spiel.held.modell != null and (not spiel.held.modell.find_children("Getragen*", "", false, false).is_empty() \
			or not spiel.held.modell.find_children("Ruecken*", "", true, false).is_empty())
		print("FILM1613 %s %s: %s %s" % [e[0], e[2], schl, "am Helden" if am else "FEHLT"])
		if not (am and schl.contains("#")): fehler += 1
		var glut: bool = spiel.held.modell.find_child("Glanz_Glut", true, false) != null
		print("FILM1613 Glut %s (soll %s)" % [glut, e[2] != "RARE"])
		if glut != (e[2] != "RARE"): fehler += 1
		titel.text = "1613 · %s" % e[3]
		spiel.held.richtung = Vector3(0, 0, -1) if i % 2 == 0 else Vector3(0, 0, 1)
		spiel.kamera.drehe(50.0)
		for f in int(REIHE_S * 30.0): await process_frame
	spiel.held.richtung = Vector3.ZERO
	print("FILM1613 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler else 0)
