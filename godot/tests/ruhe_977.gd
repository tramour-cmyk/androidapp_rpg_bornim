extends SceneTree
# 977 (Tuffy 744): Grimmzahn im Tiefwald steht als Figur des Kampforts mit Streuner.Stub als Kampfort-Ersatz; dessen Uhr blieb bei 0,
# figur._ruhebewegung wartete darum ewig, Grimmzahn zeigte nie eine Ruhebewegung (Lefzen, Scharren, Knurren). Prüft: binnen 12 s
# (Ruhe 3-7 s) spielt Grimmzahn eine Ruhegeste. Ohne Kaufmodell des Wolfs (Bau ohne Kaufmodelle) nur „übersprungen“.
# Aufruf: im Ordner godot mit -s res://tests/ruhe_977.gd -> „RUHE977 gut“ oder „RUHE977 FEHLER …“ (Exit 1)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var k := Karte.lade("deep_forest")
	var d := {}
	for l in k.daten.get("leute", []):
		if String(l.get("id", "")) == "grimfang": d = l
	if d.is_empty():
		print("RUHE977 FEHLER Grimmzahn nicht in deep_forest")
		quit(1)
		return
	var held := Node3D.new()
	root.add_child(held)
	held.position = Vector3(1000, 0, 1000)   # weit weg: nicht bedroht, kein Angriff
	var g := Leute.new(k, d, held)
	root.add_child(g)
	await process_frame
	if g.anim == null or not g.anim.has_animation("Lefzen"):
		print("RUHE977 übersprungen: Grimmzahn ohne Ruhegesten (Bau ohne Kaufmodelle)")
		quit(0)
		return
	var gesehen := ""
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 12000 and gesehen == "":
		await process_frame
		var a := String(g.anim.current_animation)
		if a != "Stehen" and a != "" and a in ["Lefzen", "Scharren", "ScharrenR", "Knurren", "Hecheln"]:
			gesehen = a
	if gesehen == "":
		print("RUHE977 FEHLER binnen 12 s keine Ruhegeste (Uhr des Kampfort-Ersatzes %.0f ms)" % float(g.modell.kampfort.clock_ms))
		quit(1)
		return
	print("RUHE977 gut: %s nach %.1f s" % [gesehen, (Time.get_ticks_msec() - t0) / 1000.0])
	quit(0)
