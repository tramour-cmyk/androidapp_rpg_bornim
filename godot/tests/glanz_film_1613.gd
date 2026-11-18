extends "res://tests/drehteller_film_499.gd"
# 1613 (Chef 02.11., 11:28: „cool, wenn man da irgendwie noch eine Art Effekt draufkriegen“; Vorentscheid Sokrates 18.11.): Waffen
# episch und höher mit Effekt statt Färbung, drei Fassungen nacheinander am selben Langschwert (Staffel.glanz_art): A Schein (Rand und
# Streifen), B Glut (Funken steigen auf), C beides; danach göttlich und ein epischer Morgenstern mit C. Der Kämpfer geht über die Wiese
# wie im Film 458.3, die Kamera pendelt vor der Waffenseite, Bildbreite enger, damit man die Waffe sieht.
# Film:  xvfb-run godot --path godot --rendering-driver vulkan --rendering-method mobile --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 -s res://tests/glanz_film_1613.gd
# Probebild: BILD=<ordner> ohne --write-movie, je Fassung ein Bild nach 1,5 s
# Ohne Bild (headless): legt jede Fassung an und prüft Schein (next_pass) und Glut (Teilchen) an der Waffe

const FOLGE_1613 := [["longsword", 11, "EPIC", "schein", "A Schein"], ["longsword", 11, "EPIC", "glut", "B Glut"],
	["longsword", 11, "EPIC", "beides", "C Schein und Glut"], ["longsword", 11, "DIVINE", "beides", "C göttlich"],
	["morningstar", 11, "EPIC", "beides", "C episch, Morgenstern"], ["longsword", 11, "RARE", "beides", "selten: ohne Effekt"]]
const ABSCHNITT_S := 2.4   # sechs Abschnitte, Film unter 15 s (1076)

func _waffe(modell: Node) -> Node:
	for n in modell.find_children("*", "", true, false):
		if n.has_meta("staffel"): return n
	return null

func _lauf() -> void:
	Sprache.lade()
	baue_welt()
	kam.size = 1.9
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var w := HeldFigur.wahl(hw, z)
	var aus: Dictionary = (w.get("ausruestung", {}) as Dictionary).duplicate()
	aus.erase("OFF_HAND")
	var e0: Array = FOLGE_1613[0]
	Staffel.glanz_art = e0[3]
	aus["MAIN_HAND"] = {"base": e0[0], "ilvl": e0[1], "rarity": e0[2]}
	w["ausruestung"] = aus
	var mats := []
	var modell := HeldFigur.baue(w, mats)
	if modell == null: print("GLANZ1613 kein Held"); quit(1); return
	welt.add_child(modell)
	for m in mats:
		(m as ShaderMaterial).set_shader_parameter("metall", 1.0)
		(m as ShaderMaterial).set_shader_parameter("licht_dir", Basis.from_euler(sonne.rotation).z)
	var anim := Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
	Gebiet.bewegungen(anim, ["Gehen", "Stehen"])
	var t := 0.0
	var v := 0.9
	for i in FOLGE_1613.size():
		var e: Array = FOLGE_1613[i]
		Staffel.glanz_art = e[3]
		if i > 0:
			aus["MAIN_HAND"] = {"base": e[0], "ilvl": e[1], "rarity": e[2]}
			HeldFigur.bewaffne(modell, sk, aus)
		await process_frame
		var wa := _waffe(modell)
		var schein := false
		var glut := wa != null and wa.find_child("Glanz_Glut", true, false) != null
		if wa:
			for mi in wa.find_children("*", "MeshInstance3D", true, false) + ([wa] if wa is MeshInstance3D else []):
				for k in (mi as MeshInstance3D).mesh.get_surface_count():
					var sm := (mi as MeshInstance3D).get_surface_override_material(k) as ShaderMaterial
					if sm and sm.next_pass: schein = true
		var soll_s: bool = e[2] != "RARE" and e[3] in ["schein", "beides"]
		var soll_g: bool = e[2] != "RARE" and e[3] in ["glut", "beides"]
		pruefe(wa != null and schein == soll_s and glut == soll_g, "%s %s %s: Waffe %s, Schein %s, Glut %s" % [e[0], e[2], e[3], wa != null, schein, glut])
		var gang := String(modell.get_meta("gang", ""))
		var bew := "Gehen_" + gang if gang != "" and anim.has_animation("Gehen_" + gang) else "Gehen"
		if anim.current_animation != bew: anim.play(bew, 0.2)
		schrift.text = "1613 · %s" % e[4]
		var t0 := t
		while t < t0 + ABSCHNITT_S:
			modell.position = Vector3(0, 0, t * v)
			stelle_kamera(modell.position + Vector3(0, 1.0, 0), 300.0 + 70.0 * sin(t * 0.9))   # pendelt vor der Waffenseite
			await process_frame
			if OS.get_environment("BILD") != "" and t < t0 + 1.5 and t + DT >= t0 + 1.5:   # Probebild: je Fassung ein Bild
				root.get_texture().get_image().save_png("%s/glanz_%d.png" % [OS.get_environment("BILD"), i])
			t += DT
	print("GLANZ1613 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler else 0)
