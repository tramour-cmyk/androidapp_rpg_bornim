# 1286 (Build 286, A56): nach „Zurück“ aus der Strahlprobe Fehler: busy/figures auf freigegebenem Objekt, data.tree null,
# create_timer auf null. Am Rechner ohne Paket und Kauf nicht nachstellbar (die Probe endet vor dem Feuern). Dieser Test geht den Weg
# des Chefs: Strahlprobe wie aus dem Reiter „Test“ (aktuelle Szene, mit Knöpfen), wartet, bis der erste Strahl läuft, tippt „Zurück“
# und lässt 4 s laufen; jede Fehlerzeile danach steht im Protokoll. Ende 0 ohne Paket oder Kauf.
# Aufruf: godot --headless --path . -s res://tests/strahl_zurueck_1286.gd 2>&1 | grep -E "ZURUECK1286|SCRIPT ERROR|ERROR"
extends SceneTree

const Strahlprobe = preload("res://kampf/strahlprobe.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	if not Strahlprobe.da() or not FileAccess.file_exists("res://daten/kampf-bewegungen.bin"):
		print("ZURUECK1286 ohne Paket oder Kauf, nichts zu prüfen")
		quit(0)
		return
	var s := Strahlprobe.new()
	root.add_child(s)
	current_scene = s
	var t := 0.0
	while s.jetzt == "" and t < 40.0:
		await process_frame
		t += 1.0 / 60.0
	print("ZURUECK1286 Strahl „%s“ nach %.1f s, tippe Zurück" % [s.jetzt, t])
	var knoepfe := s.find_children("*", "Button", true, false).filter(func(b): return (b as Button).text == "Zurück")
	if knoepfe.is_empty():
		print("ZURUECK1286 FEHLER: kein Knopf Zurück")
		quit(1)
		return
	(knoepfe[0] as Button).pressed.emit()
	for i in 240:
		await process_frame
	print("ZURUECK1286 Ende")
	quit(0)
