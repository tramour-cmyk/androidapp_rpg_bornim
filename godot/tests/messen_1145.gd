extends SceneTree
# 1145 (Chef 13.11., 14:35: Hoehle hakelig, Bilder/s 45): im Testmenue je Teil des Bildes aus zum Messen am Geraet (Tusche, Tusche
# nach Lampen, Nebel, Schatten) und wieder an; die Anzeige „Bildrate“ nennt Grafik- und Rechenzeit, Takt und was aus ist.
# Massgeblich ist die Zeile MESSEN1145.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func teile(spiel) -> Dictionary:
	var k: Kamera = spiel.kamera
	var tusche := 0; var nebel := 0
	for c in k.get_children():
		if not (c is MeshInstance3D and c.visible and c.material_override is ShaderMaterial): continue
		if c.material_override in k.tusche_mats: tusche += 1
		elif c.material_override.shader.resource_path.ends_with("nebel.gdshader"): nebel += 1
	var schatten := 0
	for l in root.find_children("*", "Light3D", true, false):
		if (l as Light3D).shadow_enabled: schatten += 1
	return {"tusche": tusche, "nebel": nebel, "schatten": schatten, "lampen": k.lampen_an}

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.setze("cave_seen")
	spiel.betrete("cave", Vector2i(10, 17), "UP")
	for i in 3: await process_frame
	var vorher := teile(spiel)
	print("1145 vorher ", vorher)
	pruefe(vorher["tusche"] == 2 and vorher["nebel"] == 1 and vorher["schatten"] > 0 and vorher["lampen"], "alles an: zwei Tuscheflaechen, Nebel, Lichter mit Schatten, Tusche nach Lampen")
	Testmodus.ohne_tusche = true; Testmodus.ohne_tuschelampen = true; Testmodus.ohne_nebel = true; Testmodus.ohne_schatten = true
	Testmodus.leistung_anwenden(self)
	var aus := teile(spiel)
	print("1145 aus ", aus)
	pruefe(aus["tusche"] == 0 and aus["nebel"] == 0 and aus["schatten"] == 0 and not aus["lampen"], "alles aus")
	Testmodus.ohne_tusche = false; Testmodus.ohne_tuschelampen = false; Testmodus.ohne_nebel = false; Testmodus.ohne_schatten = false
	Testmodus.leistung_anwenden(self)
	var wieder := teile(spiel)
	print("1145 wieder ", wieder)
	pruefe(wieder == vorher, "wieder an wie vorher")
	# Anzeige: mit „Bildrate“ die Zeile Grafik, Rechnen, Bildschirm, und was aus ist
	Testmodus.bildrate = true
	Testmodus.ohne_schatten = true
	spiel.ui.mess.visible = true
	for i in 40: await process_frame
	var text: String = spiel.ui.mess.text
	print("1145 Anzeige: ", text.replace("\n", " | "))
	pruefe(text.contains("Grafikzeit") and text.contains("Rechenzeit") and text.contains("Hz") and text.contains("aus: Schatten"), "Anzeige nennt Grafikzeit, Rechenzeit, Takt und was aus ist")
	pruefe(teile(spiel)["schatten"] == 0, "Schatten aus auch über den Weltlauf (messe)")
	Testmodus.ohne_schatten = false
	print("MESSEN1145 " + ("gut" if fehler == 0 else "FEHLER %d" % fehler))
	quit(1 if fehler else 0)
