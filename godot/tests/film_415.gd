# 415 (Chef „415 jetzt“ 02.11., 10:55): Film der Strahlenprobe im Kampfort (kampf/strahlprobe.gd): Magier gegen das Wolfsrudel im
# Spiellicht (Toon-Licht, Tusche nach Licht, Schatten; Signatur.wache), Kamera seitlich, die drei Strahlen der Beams-Probe (Blauer
# Laser, Feuerstrom, Blitzbogen) nacheinander aus der Stabspitze auf den nächsten Wolf. Schwarzblende am Anfang und Ende (G2).
# Ohne das Paket (godot/addons/reeboo_beams, nur im Bau aus bornim-kaufmodelle) meldet es „ohne Paket“ und endet mit 0.
# Aufruf (Bild, Probelauf nach 389): PROBE=415 xvfb-run godot --path godot --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_415.gd     Ohne Bild (--headless): läuft die Probe durch, Bilder je Sekunde ohne Aussage
extends SceneTree

const Strahlprobe = preload("res://kampf/strahlprobe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const BLENDE_BILDER := 8
const HOECHST_S := 40.0

var schwarz: ColorRect


func _initialize() -> void:
	_run.call_deferred()


func _blende(ziel: float) -> void:
	var von := schwarz.color.a
	for i in BLENDE_BILDER:
		await process_frame
		schwarz.color.a = lerpf(von, ziel, float(i + 1) / BLENDE_BILDER)


func _run() -> void:
	if not Strahlprobe.da():
		print("Film 415: ohne Paket (godot/addons/reeboo_beams), nichts zu filmen")
		quit(0)
		return
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin"):
		print("Film 415: ohne Kauf, nichts zu filmen")
		quit(0)
		return
	var deck := CanvasLayer.new()
	deck.layer = 128
	schwarz = ColorRect.new()
	schwarz.color = Color.BLACK
	schwarz.set_anchors_preset(Control.PRESET_FULL_RECT)
	schwarz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	deck.add_child(schwarz)
	root.add_child(deck)
	var s := Strahlprobe.new()
	s.film = true
	root.add_child(s)
	var t := 0.0
	while s.kf == null and t < 10.0:
		await process_frame
		t += 1.0 / 30.0
	if s.kf == null:
		print("FEHLER Film 415: kein Kampfort")
		quit(1)
		return
	for i in 6:
		await process_frame
	if not Signatur.wache(s.kf, self, "Film 415"):
		return
	await _blende(0.0)
	t = 0.0
	while not s.fertig and t < HOECHST_S:
		await process_frame
		t += 1.0 / 30.0
	print("Film 415: %s nach %.1f s; %s" % ["fertig" if s.fertig else "abgebrochen", t, s.lb.text.replace("\n", " · ") if s.lb else ""])
	await _blende(1.0)
	quit(0)
