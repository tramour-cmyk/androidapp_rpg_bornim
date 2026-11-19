extends SceneTree
# 1406 (Chef 16.11. zu 1386: „Drehen auf der Stelle … ganz Entscheidendes“; 1416: „den 180-Degree Root Motion Turn“): ohne Bild.
# Eine Person ohne Modell (AnimationPlayer mit Stehen, Drehen_L/R und Drehen180_L/R, Kurven wie bei den Kaufbewegungen) dreht sich
# im Stehen zu einem ruhenden Ziel. Geprueft: ab 135 Grad genau eine Wende Drehen180 der richtigen Seite, am Ende zum Ziel gewandt;
# unter 135 Grad nie Drehen180; ohne Drehen180 (ohne Kaufdaten) wie bisher zwei Turn90.
# Aufruf im Ordner godot: --fixed-fps 30 -s res://tests/wende180_1406.gd -> „WENDE180 n Fehler“

func _initialize() -> void:
	_lauf.call_deferred()

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func kurve(grad: float, bilder: int) -> PackedFloat32Array:
	var k := PackedFloat32Array()
	for f in bilder + 1: k.append(deg_to_rad(grad) * smoothstep(0.0, 1.0, float(f) / bilder))
	return k

func spieler(n: Node3D) -> AnimationPlayer:
	var ap := AnimationPlayer.new()
	var lib := AnimationLibrary.new()
	for name in ["Stehen", "Drehen_L", "Drehen_R", "Drehen180_L", "Drehen180_R"]:
		var a := Animation.new()
		a.length = 1.33 if name.begins_with("Drehen180") else 2.0
		if name == "Stehen": a.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation(name, a)
	ap.add_animation_library("", lib)
	n.add_child(ap)
	return ap

var p: Leute

# dreht zum Ziel grad (gegen den Uhrzeigersinn von oben) und zaehlt die Wenden je Name bis zur Ruhe
func drehe_zu(grad: float) -> Dictionary:
	for i in 30: await process_frame
	var start := p.rotation.y
	p.blick = start + deg_to_rad(grad)
	var namen := {}
	var w_vorher := ""
	for i in 240:
		await process_frame
		if p.wende != "" and p.wende != w_vorher: namen[p.wende] = int(namen.get(p.wende, 0)) + 1
		if p.wende == "" and w_vorher == "" and i > 10 and absf(angle_difference(p.rotation.y, p.blick)) < deg_to_rad(0.5): break
		w_vorher = p.wende
	return {"namen": namen, "rest": rad_to_deg(absf(angle_difference(p.rotation.y, p.blick)))}

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.betrete("village", Vector2i(11, 7), "DOWN")
	for i in 5: await process_frame
	var k: Karte = spiel.karte
	for l in spiel.leute_liste(): l.visible = false
	p = Leute.new(k, {"id": "probe_1406", "x": 11, "y": 11, "streifen": 0}, spiel.held)
	spiel.add_child(p)
	await process_frame
	p.warte = 999.0
	p.held = null
	p.schaut = false
	p.anim = spieler(p)
	p.anim.play("Stehen")
	var alle := {"Drehen_L": kurve(90.0, 60), "Drehen_R": kurve(-90.0, 60), "Drehen180_L": kurve(180.0, 40), "Drehen180_R": kurve(-180.0, 40)}
	p.wende_kurve = alle.duplicate()
	p.rotation.y = 0.0
	# 1) 170 Grad links: eine halbe Drehung
	var r: Dictionary = await drehe_zu(170.0)
	print("WENDE180 170 links: ", r)
	pruefe(r["namen"].keys() == ["Drehen180_L"] and r["namen"]["Drehen180_L"] == 1, "170 Grad links: genau eine Drehen180_L (%s)" % str(r["namen"]))
	pruefe(r["rest"] < 3.0, "zum Ziel gewandt (%.1f Grad daneben)" % r["rest"])
	# 2) 150 Grad rechts
	r = await drehe_zu(-150.0)
	print("WENDE180 150 rechts: ", r)
	pruefe(r["namen"].keys() == ["Drehen180_R"], "150 Grad rechts: Drehen180_R (%s)" % str(r["namen"]))
	pruefe(r["rest"] < 3.0, "zum Ziel gewandt (%.1f Grad daneben)" % r["rest"])
	# 3) 100 Grad links: keine halbe Drehung (sie dreht ueber das Ziel hinaus)
	r = await drehe_zu(100.0)
	print("WENDE180 100 links: ", r)
	pruefe(not r["namen"].has("Drehen180_L") and r["namen"].has("Drehen_L"), "100 Grad: Drehen_L, nicht Drehen180 (%s)" % str(r["namen"]))
	pruefe(r["rest"] < 3.0, "zum Ziel gewandt (%.1f Grad daneben)" % r["rest"])
	# 4) ohne Drehen180 (ohne Kaufdaten): 170 Grad wie bisher mit Drehen_L
	p.wende_kurve = {"Drehen_L": alle["Drehen_L"], "Drehen_R": alle["Drehen_R"]}
	r = await drehe_zu(170.0)
	print("WENDE180 170 ohne Drehen180: ", r)
	pruefe(r["namen"].keys() == ["Drehen_L"], "ohne Drehen180: Drehen_L wie bisher (%s)" % str(r["namen"]))
	pruefe(r["rest"] < 3.0, "zum Ziel gewandt (%.1f Grad daneben)" % r["rest"])
	p.queue_free()
	print("WENDE180 %d Fehler" % fehler)
	quit(1 if fehler else 0)
