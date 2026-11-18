extends SceneTree
# 1619 (Chef 18.11., 07:29 zu Film 458.3: „warum der Held gar so stakst“): Vergleich im Dorf wie im Spiel (spiel.tscn, Spielshader mit
# Tusche, Spielkamera nah, Aufbau wie film_staffel_4583). Der Held geht auf der Straße hin und her, je ABSCHNITT_S Sekunden: Langschwert
# bisher (Paketbewegung ganz), Langschwert neu (HeldFigur.waffen_gehen „A“: Beine und Rumpf aus Gehen, Arme aus dem Paket), dann
# Großaxt bisher und neu. Der Filmschreiber nimmt die Fenstergröße des Projekts (1080×2340).
#   xvfb-run -a godot --rendering-driver vulkan --rendering-method mobile --path . --write-movie <x.avi> --fixed-fps 30 \
#     -s res://tests/film_gang_dorf_1619.gd -- --film1619 (Wächter 1062)
# Probebild: BILDER=<ordner> ohne --write-movie: je Abschnitt ein Bild nach 1,5 s

const FOLGE := [["longsword", "Langschwert", "paket", "bisher"], ["longsword", "Langschwert", "A", "neu"],
	["greataxe", "Großaxt", "paket", "bisher"], ["greataxe", "Großaxt", "A", "neu"]]
const ABSCHNITT_S := 3.0

var spiel
var titel: Label
var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

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
	titel.position = Vector2(24, 210)
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
	Sprache.lang = "de"
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)   # Kämpfer mit Rüstung wie im Wiesenfilm
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	var bilder := OS.get_environment("BILDER")
	titel.add_theme_font_size_override("font_size", 44)
	spiel.kamera.drehe(70.0)   # schräg von der Seite: Schritt sichtbar
	spiel.kamera.springe()
	for i in FOLGE.size():
		var e: Array = FOLGE[i]
		HeldFigur.waffen_gehen = e[2]
		hw.ausruestung["MAIN_HAND"] = {"uid": 9000 + i, "base": e[0], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		spiel.held_figur_neu("")
		for c in spiel.held.stoesst.get_connections(): spiel.held.stoesst.disconnect(c["callable"])   # kein Text vom Schlagbaum
		var ap: AnimationPlayer = spiel.held.anim
		var gang := String(spiel.held.waffengang)
		var bew := "Gehen_" + gang if gang != "" and ap.has_animation("Gehen_" + gang) else "Gehen"
		var sps := 2.0 / ap.get_animation(bew).length
		print("FILMGANG1619 %s %s: %s, %.2f Schritte/s" % [e[0], e[2], bew, sps])
		if bew == "Gehen": fehler += 1
		titel.text = "%s · %s\n%s Schritte je Sekunde" % [e[1], e[3], ("%.1f" % sps).replace(".", ",")]
		spiel.held.richtung = Vector3(0, 0, 1) if i % 2 == 0 else Vector3(0, 0, -1)
		for f in int(ABSCHNITT_S * 30.0):
			await process_frame
			if bilder != "" and f == 45:
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(bilder + "/dorf1619_%d.png" % i)
	HeldFigur.waffen_gehen = "A"
	spiel.held.richtung = Vector3.ZERO
	print("FILMGANG1619 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler else 0)
