extends SceneTree
# 1040 (Chef 12.11., 15:12, Grimmzahn: „wenn ich um den rumlaufe, dann dreht er sich … wie als ob er ein Playmobil-Männchen wäre“):
# Rechnung ohne Bild. Der Held geht (2,1 m/s) in 3 m Abstand um ein Monster der Geschichte herum; es wendet sich ihm mit fester Rate
# zu (leute.gd stehen: Leute.drehe, Streuner.DREH). Gezählt: in wie vielen Bildern es dabei tritt, nach der alten Regel (nur über
# DREH_TRITT Rest) und nach der neuen (Streuner.tritt_bis). Erwartet: alt fast nie (die Ursache), neu fast immer; steht der Held
# still, tritt es nach TRITT_NACH_MS nicht mehr. Exit = Zahl der Fehler.
# Aufruf: im Ordner godot --headless -s res://tests/tritt_1040.gd

const Leute = preload("res://skripte/leute.gd")
const Streuner = preload("res://skripte/streuner.gd")


func _init() -> void:
	var fehler := 0
	var dt := 1.0 / 30.0
	var r := 3.0
	var v := 2.1
	var rot := 0.0
	var bis := 0
	var alt := 0
	var neu := 0
	var bilder := 0
	var ms := 0
	for i in 200:     # gut 6,6 s im Kreis, die erste Sekunde zum Einholen nicht gezählt
		var w := v / r * i * dt
		var held := Vector2(sin(w), cos(w)) * r
		var blick := atan2(held.x, held.y)
		var vorher := rot
		rot = Leute.drehe(rot, blick, Streuner.DREH * dt)
		ms += int(dt * 1000.0)
		bis = Streuner.tritt_bis(bis, angle_difference(vorher, rot), dt, ms)
		if i < 30:
			continue
		bilder += 1
		if absf(angle_difference(rot, blick)) > Streuner.DREH_TRITT:
			alt += 1
		if absf(angle_difference(rot, blick)) > Streuner.DREH_TRITT or ms < bis:
			neu += 1
	print("Tritt 1040 im Kreis: alt %d von %d Bildern, neu %d von %d" % [alt, bilder, neu, bilder])
	if neu < bilder * 0.95:
		fehler += 1
		print("FEHLER es tritt nicht beim Folgen (%d von %d)" % [neu, bilder])
	# der Held bleibt stehen: nach dem Einholen und TRITT_NACH_MS kein Tritt mehr
	var blick_fest := rot + 0.3
	var noch := 0
	for i in 60:
		var vorher := rot
		rot = Leute.drehe(rot, blick_fest, Streuner.DREH * dt)
		ms += int(dt * 1000.0)
		bis = Streuner.tritt_bis(bis, angle_difference(vorher, rot), dt, ms)
		if i >= 30 and (absf(angle_difference(rot, blick_fest)) > Streuner.DREH_TRITT or ms < bis):
			noch += 1
	print("Tritt 1040 nach dem Halt: %d Bilder" % noch)
	if noch > 0:
		fehler += 1
		print("FEHLER es tritt weiter, obwohl es steht")
	print("TRITT1040 %d Fehler" % fehler)
	quit(fehler)
