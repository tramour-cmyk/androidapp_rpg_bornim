# 623.5 (Jerry): Effektprobe (kampf/effektprobe.gd) ohne Bild: läuft sie durch, wann kommt welcher Effekt (für BILD_S des Probebilds
# aus tests/film_6235.gd), fehlt ein Paket, gibt es Skriptfehler. Ohne Pakete oder Kauf: meldet es und endet mit 0.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/effekt_mess_6235.gd
extends SceneTree

const Effektprobe = preload("res://kampf/effektprobe.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not Effektprobe.da() or not FileAccess.file_exists("res://daten/kampf-bewegungen.bin"):
		print("Effekte 623.5: ohne Pakete oder Kauf")
		quit(0)
		return
	var s := Effektprobe.new()
	s.film = true
	root.add_child(s)
	var t := 0.0
	var vorher := ""
	var bereit_t := -1.0
	while not s.fertig and t < 150.0:
		if s.bereit and bereit_t < 0.0:
			bereit_t = t
			print("Effekte 623.5: bereit bei %.1f s, Bild %d" % [t, Engine.get_process_frames()])
		await process_frame
		t += 1.0 / 30.0
		if s.jetzt != vorher:
			if s.jetzt != "":
				print("Effekte 623.5: %5.1f s %s" % [t, s.jetzt])
			vorher = s.jetzt
	print("Effekte 623.5: %s nach %.1f s; gezeigt %d; fehlt: %s" % ["fertig" if s.fertig else "abgebrochen", t, s.gespielt.size(),
		", ".join(s.fehlen) if not s.fehlen.is_empty() else "nichts"])
	quit(0 if s.fertig else 1)
