extends SceneTree
# 397: Gebiet.ruhe_naechste ohne Bild: nach Stehen kommt eine andere Ruhebewegung einmal, danach wieder Stehen (zwei- bis viermal);
# ohne Stehen_2 (ohne Kauf) bleibt es Stehen; Stehen_3 (Muede) nie (592). Aufruf: im Ordner godot mit -s res://tests/ruhe_test.gd

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
	# 592 („592 so“): Stehen_3 (Muede, vornueber gebeugt) nur noch atemlos (held.gd), nie als Ruhe
	if gesehen.size() != 2 or gesehen.has("Stehen_3"): fehler += 1; print("FEHLER Ruhe: %s" % gesehen.keys())
	var nur := spieler(["Stehen"])
	if Gebiet.ruhe_naechste(nur, "Stehen", z)[0] != "Stehen": fehler += 1; print("FEHLER ohne Kauf")
	# 1044 zurueck (Chef 13.11., 09:35): je Person eigene Ruhebewegungen, keine zwei gleich, nie Muede, jede kommt vor
	var alle := spieler(["Stehen", "Stehen_2", "Stehen_3", "Gesten", "Ruhe_Tresen", "Ruhe_Trinken", "Ruhe_Weinen", "Ruhe_Greifen"])
	var mengen := {}
	for id in HeldFigur.RUHE_JE:
		var l: Array = HeldFigur.ruhe_von(id)
		var sortiert: Array = []
		for x in l.slice(1): if not sortiert.has(x): sortiert.append(x)
		sortiert.sort()
		var k := ",".join(PackedStringArray(sortiert))
		if mengen.has(k): fehler += 1; print("FEHLER %s und %s haben dieselben Ruhebewegungen %s" % [id, mengen[k], k])
		mengen[k] = id
		if l[0] != "Stehen" or l.has("Stehen_3"): fehler += 1; print("FEHLER %s: %s" % [id, l])
		var seen := {}
		jetzt = "Stehen"
		for i in 200:
			var r := Gebiet.ruhe_naechste(alle, jetzt, z, l)
			jetzt = String(r[0]); seen[jetzt] = true
		for n in l:
			if not seen.has(n): fehler += 1; print("FEHLER %s: %s kommt nie" % [id, n])
		if seen.size() != sortiert.size() + 1: fehler += 1; print("FEHLER %s: fremde Ruhe %s" % [id, seen.keys()])
	ap.free(); nur.free(); alle.free()
	print("RUHE %d Fehler" % fehler)
	quit(1 if fehler else 0)
