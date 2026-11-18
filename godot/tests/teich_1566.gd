extends SceneTree
# 1566 (Chef 17.11., 14:50; t298.5 18.11., 14:31 „fail“: Teich der Blutzahnhöhle leuchtet hell im Dunkeln, weit vom Pilzlicht):
# ohne Bild. Im Bau trägt das Wasser den Shader des R10-Kits (gebiet.gd kit_material), nicht wasser.gdshader; dessen Eigenlicht
# (kit_selbst: EMISSION + ALBEDO * kit_selbst) leuchtet ohne jedes Licht und bleibt unter dem Nebel (Deckung 0,92 von 0,83) sichtbar.
# Prüft in der Höhle: das Wasser hat kein Eigenlicht (Kit: kit_selbst 0; ohne Kit: wasser.gdshader beleuchtet, nicht unshaded).
# Ohne Karte cave (am Rechner ohne Bau): übersprungen, 0.
# Run: godot --headless --path godot -s res://tests/teich_1566.gd  -> „TEICH1566 0 Fehler“
func _initialize() -> void: _lauf.call_deferred()
func _lauf() -> void:
	if not Testmodus.da("cave"):
		print("TEICH1566 ohne Karte cave, 0 Fehler")
		quit(0)
		return
	Testmodus.an = true
	Testmodus.geladen = true
	var spiel = (load("res://spiel.tscn") as PackedScene).instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	var fertig := [false]
	var f := func():
		await spiel.lage_herstellen({"ort": "cave:5:10:DOWN", "uhr": "19:13"})
		fertig[0] = true
	f.call()
	for i in 900:
		if fertig[0]: break
		await process_frame
	var fehler := 0
	var m: ShaderMaterial = spiel.gebiet.wasser if spiel.get("gebiet") and spiel.gebiet else null
	if m == null:
		for g in root.find_children("*", "Gebiet", true, false):
			m = g.wasser
	if spiel.karte.id != "cave" or m == null:
		print("FEHLER TEICH1566 Höhle oder Wasser fehlt (Karte %s, Wasser %s)" % [spiel.karte.id, m])
		fehler += 1
	else:
		var kit: bool = m.shader.code.contains("kit_selbst")
		var selbst = m.get_shader_parameter("kit_selbst") if kit else null
		var unbeleuchtet: bool = m.shader.code.contains("unshaded")
		print("TEICH1566 Wasser: %s, kit_selbst %s, unshaded %s" % ["Kit" if kit else "wasser.gdshader", selbst, unbeleuchtet])
		if (kit and float(selbst if selbst != null else 0.0) > 0.0) or unbeleuchtet:
			print("FEHLER TEICH1566 das Höhlenwasser leuchtet von selbst")
			fehler += 1
	print("TEICH1566 %d Fehler" % fehler)
	quit(1 if fehler else 0)
