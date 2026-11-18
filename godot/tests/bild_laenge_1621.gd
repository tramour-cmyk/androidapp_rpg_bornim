extends SceneTree
# 1621 (Chef 18.11., 07:37, A: Zweihandwaffen kürzer): Bild alt gegen neu am Helden im Dorf wie im Spiel (Tusche, Spielkamera nah, Aufbau
# wie film_gang_dorf_1619). Der Kämpfer geht mit der neuen Waffe (Stufe 1) und wird angehalten, dahinter derselbe Held (Kopie
# in derselben Haltung, eigene Waffe über HeldFigur.bewaffne) mit der alten Länge
# (daten/waffen/ALT_<datei>.bin, vorher aus dem Bau gesichert). Je Waffe ein Bild nach BILDER=<ordner>.
#   BILDER=<ordner> xvfb-run -a godot --rendering-driver vulkan --rendering-method mobile --path . --resolution 1080x2340 \
#     -s res://tests/bild_laenge_1621.gd -- --bild1621

const FOLGE := [["greataxe", "Großaxt", "131", "110"], ["maul", "Kriegshammer", "115", "100"], ["greatsword", "Zweihänder", "128,5", "115"]]

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
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	var bilder := OS.get_environment("BILDER")
	titel.add_theme_font_size_override("font_size", 44)
	spiel.kamera.drehe(-120.0)   # schräg von vorn, der Held kommt auf die Kamera zu
	spiel.kamera.springe()
	# freie Stelle auf dem Weg (der Start liegt am Brunnen): einmal 80 Bilder gehen, dort beginnt jede Waffe
	hw.ausruestung["MAIN_HAND"] = {"uid": 9099, "base": "greataxe", "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
	spiel.held_figur_neu("")
	for c in spiel.held.stoesst.get_connections(): spiel.held.stoesst.disconnect(c["callable"])
	spiel.held.richtung = Vector3(0, 0, 1)
	for f in 80: await process_frame
	var start: Vector3 = spiel.held.position
	spiel.held.richtung = Vector3.ZERO
	for f in 10: await process_frame
	for i in FOLGE.size():
		var e: Array = FOLGE[i]
		var g := {"uid": 9100 + i, "base": e[0], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		hw.ausruestung["MAIN_HAND"] = g
		spiel.held_figur_neu("")
		for c in spiel.held.stoesst.get_connections(): spiel.held.stoesst.disconnect(c["callable"])
		spiel.held.position = start
		spiel.kamera.springe()
		spiel.held.richtung = Vector3(0, 0, 1)
		for f in 40: await process_frame
		spiel.held.process_mode = Node.PROCESS_MODE_DISABLED   # Gehen anhalten: Tragehaltung wie im Film 458.3
		var neu: Node3D = spiel.held.modell
		var ap0 := Gebiet.finde(neu, "AnimationPlayer") as AnimationPlayer
		var alt := neu.duplicate() as Node3D
		for n in alt.get_children():
			if String(n.name).contains("Getragen"): n.free()
		spiel.held.get_parent().add_child(alt)
		alt.global_transform = neu.global_transform
		var kb: Basis = spiel.kamera.global_transform.basis
		var tief := Vector3(-kb.z.x, 0, -kb.z.z).normalized()   # von der Kamera weg, auf dem Boden
		alt.global_position = neu.global_position + tief * 1.6 - kb.x * 0.2   # dahinter: im Bild darüber, die Waffe frei
		var sk := Gebiet.finde(alt, "Skeleton3D") as Skeleton3D
		var ap := Gebiet.finde(alt, "AnimationPlayer") as AnimationPlayer
		ap.play(ap0.current_animation); ap.seek(ap0.current_animation_position, true); ap.pause()
		HeldFigur.bewaffne(alt, sk, hw.ausruestung)
		var datei := Staffel.datei(Staffel.schluessel(g))
		var quelle := Gebiet.lade_glb("res://daten/waffen/ALT_%s.bin" % datei)
		var qm := quelle.find_children("*", "MeshInstance3D", true, false) + ([quelle] if quelle is MeshInstance3D else [])
		var getauscht := 0
		for gt in alt.get_children():
			if not String(gt.name).contains("Getragen"): continue
			var zm := gt.find_children("*", "MeshInstance3D", true, false) + ([gt] if gt is MeshInstance3D else [])
			for j in mini(zm.size(), qm.size()):
				(zm[j] as MeshInstance3D).mesh = (qm[j] as MeshInstance3D).mesh; getauscht += 1
		print("BILD1621 %s %s: %d Netze getauscht" % [e[0], datei, getauscht])
		if getauscht == 0: fehler += 1
		titel.text = "%s · hinten alt %s cm · vorn neu %s cm" % [e[1], e[2], e[3]]
		for f in 10: await process_frame
		if bilder != "":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(bilder + "/laenge1621_%s.png" % e[0])
			print("BILD ", bilder + "/laenge1621_%s.png" % e[0])
		alt.queue_free()
		quelle.free()
		spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
		spiel.held.richtung = Vector3.ZERO
		for f in 5: await process_frame
	spiel.held.richtung = Vector3.ZERO
	print("BILD1621 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler else 0)
