extends SceneTree
# 397: Gebiet.ruhe_naechste ohne Bild: nach Stehen kommt eine andere Ruhebewegung einmal, danach wieder Stehen (zwei- bis viermal);
# ohne Stehen_2/Stehen_3 (ohne Kauf) bleibt es Stehen. Aufruf: im Ordner godot mit -s res://tests/ruhe_test.gd

func spieler(namen: Array) -> AnimationPlayer:
	var ap := AnimationPlayer.new()
	var lib := AnimationLibrary.new()
	for n in namen:
		var a := Animation.new()
		a.length = 2.5
		lib.add_animation(n, a)
	ap.add_animation_library("", lib)
	return ap

func _init() -> void:
	var fehler := 0
	var z := RandomNumberGenerator.new()
	z.seed = 397
	var ap := spieler(["Stehen", "Stehen_2", "Stehen_3"])
	var jetzt := "Stehen"
	var gesehen := {}
	for i in 200:
		var r := Gebiet.ruhe_naechste(ap, jetzt, z)
		var n: String = r[0]
		gesehen[n] = true
		if jetzt == "Stehen" and n == "Stehen": fehler += 1; print("FEHLER Stehen auf Stehen")
		if jetzt != "Stehen" and n != "Stehen": fehler += 1; print("FEHLER %s auf %s" % [n, jetzt])
		if n == "Stehen" and (float(r[1]) < 5.0 or float(r[1]) > 10.0): fehler += 1; print("FEHLER Dauer Stehen %s" % r[1])
		if n != "Stehen" and absf(float(r[1]) - 2.5) > 0.001: fehler += 1; print("FEHLER Dauer %s %s" % [n, r[1]])
		jetzt = n
	if gesehen.size() != 3: fehler += 1; print("FEHLER nicht alle drei: %s" % gesehen.keys())
	var nur := spieler(["Stehen"])
	if Gebiet.ruhe_naechste(nur, "Stehen", z)[0] != "Stehen": fehler += 1; print("FEHLER ohne Kauf")
	ap.free(); nur.free()
	print("RUHE %d Fehler" % fehler)
	quit(1 if fehler else 0)
