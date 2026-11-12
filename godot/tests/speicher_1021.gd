extends SceneTree
# 1021 (Chef 12.11., 13:44 Build 280, Reiter „Test“: „Letztes Ende der App: Speicher knapp, vom System beendet“; Log 09:01: bei jedem
# Schritt „Image format RGBFloat … converting“ aus dorfeffekte.gd tritt → fussstaub): nachstellen, ob der Fußstaub sich häuft.
# Dorf, 300 Wölkchen wie 300 Schritte auf dem Erdweg (je 0,1 s), dann so lange warten, wie ein Wölkchen lebt, und zählen: Knoten unter
# DorfEffekte, alle Knoten, Objekte, Texturspeicher (am Rechner ohne Grafik 0). Ohne Vorlage (ohne Kaufpaket) nichts zu messen.
# Ausgabe „SPEICHER1021 <n> Fehler“ und die Messzeilen „SPEICHER …“.
#   ~/godot/godot --headless --path . -s res://tests/speicher_1021.gd

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _zaehle(de: Node) -> String:
	return "unter DorfEffekte %d, Knoten %d, Objekte %d, Ressourcen %d, Texturen %.1f MB" % [de.get_child_count(),
		Performance.get_monitor(Performance.OBJECT_NODE_COUNT), Performance.get_monitor(Performance.OBJECT_COUNT),
		Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT), Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0]

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	if spiel.karte.id != "village": spiel.betrete("village", Vector2i(17, 10), "UP")
	await create_timer(1.0).timeout
	var de: DorfEffekte = DorfEffekte.jetzt
	if de == null or de.szene("effects/footstep_dust.tscn") == null:
		print("SPEICHER1021 ohne Fußstaub-Vorlage, nichts zu messen")
		print("SPEICHER1021 0 Fehler")
		quit(0)
		return
	var vorher := de.get_child_count()
	var objekte := Performance.get_monitor(Performance.OBJECT_COUNT)
	print("SPEICHER vorher: " + _zaehle(de))
	var p: Vector3 = spiel.held.global_position
	for i in 300:
		de.fussstaub(Vector3(p.x + (i % 10) * 0.1, 0.02, p.z), i % 3 == 0)
		await create_timer(0.1).timeout
		if i == 149: print("SPEICHER nach 150: " + _zaehle(de))
	print("SPEICHER nach 300: " + _zaehle(de))
	await create_timer(DorfEffekte.STAUB_LEBEN * 2.0 + 2.0).timeout
	print("SPEICHER danach: " + _zaehle(de))
	var bleiben := de.get_child_count() - vorher
	if bleiben > 5:
		print("FEHLER %d Wölkchen bleiben liegen (je Schritt ein Knoten, der nie frei wird)" % bleiben)
		fehler += 1
	var mehr := Performance.get_monitor(Performance.OBJECT_COUNT) - objekte
	if mehr > 300:
		print("FEHLER %d Objekte mehr als vorher (je Schritt etwa %.1f)" % [mehr, mehr / 300.0])
		fehler += 1
	print("SPEICHER1021 %d Fehler" % fehler)
	quit(1 if fehler else 0)
