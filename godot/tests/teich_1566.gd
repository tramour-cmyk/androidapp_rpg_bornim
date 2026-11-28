extends SceneTree
# 1566 (Chef 17.11., 14:50; t298.5 18.11., 14:31 „fail“: Teich der Blutzahnhöhle leuchtet hell im Dunkeln, weit vom Pilzlicht):
# ohne Bild. Im Bau trägt das Wasser den Shader des R10-Kits (gebiet.gd kit_material), nicht wasser.gdshader; dessen Eigenlicht
# (kit_selbst: EMISSION + ALBEDO * kit_selbst) leuchtet ohne jedes Licht und bleibt unter dem Nebel (Deckung 0,92 von 0,83) sichtbar.
# Prüft jede Karte mit „hoehle“ (daten/<karte>-info.json, alle Karten aus karten.json): jede Wasserfläche hat kein Eigenlicht
# (Kit: kit_selbst 0; ohne Kit: wasser.gdshader beleuchtet, nicht unshaded); das Kit-Wasser liest die Nebelkarte (kit_sicht). Ohne gebaute Karte (am Rechner ohne Bau): übersprungen, 0.
# Run: godot --headless --path godot -s res://tests/teich_1566.gd  -> „TEICH1566 0 Fehler“
func _initialize() -> void: _lauf.call_deferred()

func hoehlenkarten() -> Array:
	var alle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	var aus := []
	for id in alle["karten"]:
		var p := "res://daten/%s-info.json" % Gebiet.datei(id)
		if Testmodus.da(id) and FileAccess.file_exists(p):
			var info = JSON.parse_string(FileAccess.get_file_as_string(p))
			if info is Dictionary and info.get("hoehle", false): aus.append(id)
	return aus

func erste_kachel(k: Karte) -> Vector2i:
	for y in k.hoehe:
		for x in k.breite:
			if k.begehbar(Vector2i(x, y)): return Vector2i(x, y)
	return Vector2i.ZERO

func _lauf() -> void:
	var karten := hoehlenkarten()
	if karten.is_empty():
		print("TEICH1566 ohne gebaute Höhlenkarte, 0 Fehler")
		quit(0)
		return
	Testmodus.an = true
	Testmodus.geladen = true
	var spiel = (load("res://spiel.tscn") as PackedScene).instantiate()
	root.add_child(spiel)
	for i in 10: await process_frame
	var fehler := 0
	var flaechen := 0
	for id in karten:
		var ort := "cave:5:10:DOWN" if id == "cave" else "%s:%d:%d:DOWN" % [id, erste_kachel(Karte.lade(id)).x, erste_kachel(Karte.lade(id)).y]
		var fertig := [false]
		var f := func():
			await spiel.lage_herstellen({"ort": ort, "uhr": "19:13"})
			fertig[0] = true
		f.call()
		for i in 900:
			if fertig[0]: break
			await process_frame
		var n := 0
		for mi in (spiel.gebiet as Node).find_children("*Wasser*", "MeshInstance3D", true, false) if spiel.karte.id == id and spiel.gebiet else []:
			for s in (mi as MeshInstance3D).mesh.get_surface_count():
				var m := (mi as MeshInstance3D).get_surface_override_material(s) as ShaderMaterial
				if m == null: continue
				n += 1
				var kit: bool = m.shader.code.contains("kit_selbst")
				var selbst = m.get_shader_parameter("kit_selbst") if kit else null
				var unbeleuchtet: bool = m.shader.code.contains("unshaded")
				print("TEICH1566 %s %s: %s, kit_selbst %s, unshaded %s" % [id, mi.name, "Kit" if kit else "wasser.gdshader", selbst, unbeleuchtet])
				if (kit and float(selbst if selbst != null else 0.0) > 0.0) or unbeleuchtet:
					print("FEHLER TEICH1566 %s %s: das Höhlenwasser leuchtet von selbst" % [id, mi.name])
					fehler += 1
				# Messlauf 22.11., 21:05 (Mobile): der Nebel deckt das Kit-Wasser nicht; das Wasser muss die Nebelkarte selbst lesen
				# (wasser_kit kit_sicht), sonst funkelt es außer Sicht hinter Wänden
				if kit:
					var nt = m.get_shader_parameter("kit_nebel")
					var ng = m.get_shader_parameter("kit_nebel_groesse")
					var ok: bool = m.shader.code.contains("kit_sicht(v_world)") and nt == spiel.nebel.tex and ng is Vector2 and (ng as Vector2).x > 0.0
					print("TEICH1566 %s %s: Nebel im Wasser %s (Größe %s)" % [id, mi.name, ok, ng])
					if not ok:
						print("FEHLER TEICH1566 %s %s: das Kit-Wasser liest den Nebel nicht und bleibt außer Sicht sichtbar" % [id, mi.name])
						fehler += 1
		if spiel.karte.id != id or (id == "cave" and n == 0):   # die Blutzahnhöhle hat den Teich des Funds
			print("FEHLER TEICH1566 %s: Karte nicht geladen oder ohne Wasser (Karte %s, Flächen %d)" % [id, spiel.karte.id, n])
			fehler += 1
		flaechen += n
	print("TEICH1566 Höhlenkarten %d (%s), Wasserflächen %d" % [karten.size(), ", ".join(karten), flaechen])
	print("TEICH1566 %d Fehler" % fehler)
	quit(1 if fehler else 0)
