extends SceneTree
# 680 (Chef 08.11., 16:16, 16:18, Build 269: Testmenue Sprung Wald -> Dorf, in der Schenke schon hakelig, nach Met immer zaeher,
# beim naechsten Sprung in den Wald Absturz ohne Fehlerzeile): ohne Bild; springt wie das Testmenue (test_tat „teleport“)
# mehrmals Wald -> Dorf -> Schenke und zaehlt nach jedem Ortswechsel Objekte, Knoten, verwaiste Knoten, Ressourcen und Speicher.
# Waechst etwas mit jeder Runde, bleibt beim Ortswechsel etwas liegen. Dazu fuenf Met an der Theke und dreimal das Testmenue.
# Braucht godot/daten wie im Bau (ohne Modelle misst er nichts Echtes); mit Bild (opengl3) auch der Grafikspeicher.
# Aufruf: im Ordner godot mit -s res://tests/sprung_680.gd -> „SPRUNG 680 n Fehler“

const RUNDEN := 5

func _initialize() -> void: _lauf.call_deferred()

func zahlen() -> Dictionary:
	return {"objekte": int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		"knoten": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"verwaist": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
		"ressourcen": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
		"speicher_mb": snappedf(Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0, 0.1),
		"grafik_mb": snappedf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, 0.1),
		"texturen_mb": snappedf(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0, 0.1),
		"puffer_mb": snappedf(Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / 1048576.0, 0.1),
		"zeichenaufrufe": int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))}

func rechenzeit(n := 120) -> float:   # mittlere Zeit fuer _process je Bild in ms
	var s := 0.0
	for i in n:
		await process_frame
		s += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	return snappedf(s / n, 0.01)

func menue_auf_zu(spiel) -> void:   # wie das Testmenue: auf, ein paar Bilder, zu
	spiel.oeffne_menue("test")
	for i in 10: await process_frame
	for e in spiel.get_children():
		for m in e.get_children():
			if m is Menue: m.zu.emit()
	for i in 10: await process_frame

func met(spiel) -> void:   # an der Theke fuenf Met (der fuenfte macht betrunken), dann gehen
	spiel.zustand.gold = 500
	spiel.oeffne_rast("schenke")
	for i in 5:
		spiel._rast_wahl("met")
		for j in 10: await process_frame
	spiel._rast_wahl("")
	spiel.zustand.met = 0
	for i in 10: await process_frame

var vorher := {}
func schritt(was: String) -> void:   # Zuwachs je Schritt
	var z := zahlen()
	if not vorher.is_empty():
		print("SCHRITT %-9s objekte %+5d  speicher %+7.1f MB" % [was, z["objekte"] - vorher["objekte"], z["speicher_mb"] - vorher["speicher_mb"]])
	vorher = z

func waisen() -> void:   # welche Knoten haengen ausserhalb des Baums (nur Debug-Godot kennt sie)
	var arten := {}
	for id in Node.get_orphan_node_ids():
		var n = instance_from_id(id)
		if n == null: continue
		var wurzel: Node = n
		while wurzel.get_parent(): wurzel = wurzel.get_parent()
		var k := "%s %s (Wurzel %s %s)" % [n.get_class(), n.name, wurzel.get_class(), wurzel.name]
		if n == wurzel: arten[k] = int(arten.get(k, 0)) + 1
	for k in arten: print("WAISE %dx %s" % [arten[k], k])

func springe(spiel, ziel: Array) -> void:
	var fertig := [false]
	var lauf := func(): await spiel.test_tat("teleport", ziel); fertig[0] = true
	lauf.call()
	var t0 := Time.get_ticks_msec()
	while not fertig[0] and Time.get_ticks_msec() - t0 < 20000: await process_frame
	for i in 30: await process_frame

func _lauf() -> void:
	var fehler := 0
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 30: await process_frame
	var reihe: Array = []
	for r in RUNDEN:
		await springe(spiel, ["forest", 10, 20, "UP"])
		schritt("Wald")
		await springe(spiel, ["village", 11, 7, "DOWN"])
		schritt("Dorf")
		await springe(spiel, ["inn", 1, 1, "DOWN"])
		schritt("Schenke")
		await met(spiel)
		schritt("Met")
		for i in 3: await menue_auf_zu(spiel)
		schritt("Testmenue")
		var z := zahlen()
		z["process_ms"] = await rechenzeit()
		reihe.append(z)
		print("RUNDE %d %s" % [r, z])
		if r == RUNDEN - 1: waisen()
	# ab der zweiten Runde darf nichts mehr wachsen (die erste fuellt Zwischenspeicher); vor der Behebung je Runde +105 MB, +170 Objekte
	for k in ["objekte", "knoten", "verwaist", "ressourcen", "speicher_mb", "grafik_mb"]:
		var zuwachs: float = (reihe[RUNDEN - 1][k] - reihe[1][k]) / float(RUNDEN - 2)
		if zuwachs > (2.0 if k.ends_with("_mb") else 5.0):
			fehler += 1
			print("FEHLER %s waechst je Runde um etwa %.1f" % [k, zuwachs])
	print("SPRUNG 680 %d Fehler" % fehler)
	quit(1 if fehler else 0)
