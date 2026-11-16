extends SceneTree
# 698 Bild: Systemmenü mit dem neuen Zeichen „Grafik“ (Gruppe „Spiel“), wie im Spiel gebaut. Nur 2D, jeder Renderer.
# Aufruf im Ordner godot (mit Bildschirm): -s res://tests/grafik_698_bild.gd -- --aus=<datei.png>

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var aus := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	Bedienung.lade()
	Grafik.probe = true; Grafik.wahl = "auto"
	var z := Zustand.new()
	var m := Menue.new(BrsHeld.fuer_spiel("Mira", "Elf", "Zauberlehrling", z.neue_uid), z)
	root.add_child(m)
	m.reiter = "system"; m.baue()
	for i in 10: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(aus)
	print("GRAFIK698 Bild ", aus)
	quit()
