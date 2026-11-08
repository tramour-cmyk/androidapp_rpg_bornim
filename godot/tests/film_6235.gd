# 623.5 (Chef 08.11., 13:14 und 13:48): Film der Effektprobe im Kampfort (kampf/effektprobe.gd): Kämpfer und Magier gegen das Wolfsrudel
# im Spiellicht (Toon-Licht, Tusche nach Licht, Schatten; Signatur.wache), Spielkamera, jeder Effekt der Gratisproben einmal an seinem
# Anlass. Schwarzblende am Anfang und Ende (G2). Ohne Pakete (godot/addons/reeboo_*, character_shaders; nur im Bau aus
# bornim-kaufmodelle) meldet es „ohne Pakete“ und endet mit 0.
# Aufruf: xvfb-run godot --rendering-driver opengl3 --path godot --resolution 540x1170 --write-movie <datei>.avi --fixed-fps 30
#   -s res://tests/film_6235.gd
# Probebild (511): BILD_S=<Sekunden> schreibt nach so vielen Sekunden der Probe ein Bild nach BILD (Pfad) und endet (ohne Film)
extends SceneTree

const Effektprobe = preload("res://kampf/effektprobe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const BLENDE_BILDER := 8
const HOECHST_S := 120.0

var schwarz: ColorRect


func _initialize() -> void:
	_run.call_deferred()


func _blende(ziel: float) -> void:
	var von := schwarz.color.a
	for i in BLENDE_BILDER:
		await process_frame
		schwarz.color.a = lerpf(von, ziel, float(i + 1) / BLENDE_BILDER)


func _run() -> void:
	if not Effektprobe.da():
		print("Film 623.5: ohne Pakete (godot/addons/reeboo_*), nichts zu filmen")
		quit(0)
		return
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin"):
		print("Film 623.5: ohne Kauf, nichts zu filmen")
		quit(0)
		return
	var bild_s := float(OS.get_environment("BILD_S")) if OS.get_environment("BILD_S") != "" else -1.0
	var deck := CanvasLayer.new()
	deck.layer = 128
	schwarz = ColorRect.new()
	schwarz.color = Color.BLACK
	schwarz.set_anchors_preset(Control.PRESET_FULL_RECT)
	schwarz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	deck.add_child(schwarz)
	root.add_child(deck)
	var s := Effektprobe.new()
	s.film = true
	root.add_child(s)
	var t := 0.0
	while s.kf == null and t < 10.0:
		await process_frame
		t += 1.0 / 30.0
	if s.kf == null:
		print("FEHLER Film 623.5: kein Kampfort")
		quit(1)
		return
	for i in 6:
		await process_frame
	if not Signatur.wache(s.kf, self, "Film 623.5"):
		return
	# Einlauf des Rudels und Aufstellung (gut 20 s) bleiben schwarz; BEGINN sagt dem Bau, ab wann der Film geschnitten wird
	t = 0.0
	while not s.bereit and t < 40.0:
		await process_frame
		t += 1.0 / 30.0
	print("BEGINN %.2f" % maxf(0.0, Engine.get_frames_drawn() / 30.0 - 0.3))
	await _blende(0.0)
	t = 0.0
	var vorher := ""
	while not s.fertig and t < HOECHST_S:
		await process_frame
		t += 1.0 / 30.0
		if s.jetzt != "" and s.jetzt != vorher:
			print("Film 623.5: %5.1f s %s (%s)" % [t, s.jetzt, s.paket])
			vorher = s.jetzt
		if bild_s > 0.0 and t >= bild_s:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OS.get_environment("BILD"))
			print("Probebild 623.5: %.1f s, %s" % [t, s.jetzt])
			quit(0)
			return
	print("Film 623.5: %s nach %.1f s; gezeigt %d: %s; fehlt: %s" % ["fertig" if s.fertig else "abgebrochen", t, s.gespielt.size(),
		", ".join(s.gespielt), ", ".join(s.fehlen) if not s.fehlen.is_empty() else "nichts"])
	await _blende(1.0)
	quit(0)
