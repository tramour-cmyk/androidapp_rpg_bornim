extends SceneTree
# 1091 (Chef 13.11., 15:53: „einen hellen Ausgang sehe ich de facto mal auf jeden Fall nicht“, 15:57: „identisch … egal ob 12 Uhr
# mittags oder 22 Uhr abends“): Bild aus dem Lauf, Höhlengang zum Ausgang, der Held am Beginn des Gangs mit Blick hinaus, mittags
# und um 22 Uhr. Braucht die Kaufmodelle (im Lauf der APK, Schritt „Ausgangsbild (1091)“); mit Fenster (xvfb-run), PNG nach
# BILD1091_AUS: 1091_mittag, 1091_nacht (das Zusammensetzen macht der Schritt). Massgeblich ist die Zeile AUSGANGBILD1091.
# Aufruf mit einem Argument hinter „--“ (-- --bild=1091): ohne startet spiel.gd das Hauptmenü (Lauf 464: beide Bilder Hauptmenü).

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var aus := OS.get_environment("BILD1091_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.setze("cave_seen")
	spiel.betrete("cave", Vector2i(10, 15), "DOWN")
	if spiel.herde:
		spiel.herde.aus = true
		spiel.herde.process_mode = Node.PROCESS_MODE_DISABLED
	await create_timer(1.5).timeout   # 285 (Lauf 464): die Blende nach dem Betreten läuft in Sekunden, nicht in Bildern (wie rand_bild_1022)
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	# den Gang hinab und zurück, damit der Nebel ihn kennt (505), dann am Beginn des Gangs stehen, Blick nach Süden zum Ausgang
	for t in [Vector2i(10, 16), Vector2i(10, 17), Vector2i(10, 18), Vector2i(10, 17), Vector2i(10, 16)]:
		spiel.held.setze(t, "DOWN"); spiel.kamera.springe()
		for i in 8: await process_frame
	spiel.kamera.nah = false
	spiel.kamera.zoom = spiel.kamera.fern
	spiel.kamera.gieren_ziel = 180.0
	for z in [["mittag", 0.0, 12 * 60], ["nacht", 1.0, 22 * 60]]:
		spiel.zustand.minuten = int(z[2])
		spiel.licht.stelle(z[1]); spiel._nacht(z[1])
		spiel.kamera.springe()
		await create_timer(1.2).timeout
		for n in ["textfeld"]:
			var k = spiel.ui.get(n)
			if k: k.visible = false
		await RenderingServer.frame_post_draw
		var p: String = aus + "/1091_" + String(z[0]) + ".png"
		root.get_texture().get_image().save_png(p)
		print("BILD ", p)
	print("AUSGANGBILD1091 fertig")
	quit(0)
