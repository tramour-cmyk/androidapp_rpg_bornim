extends SceneTree
# 836 (Homer 830): „Nahkampf erreicht nur die vordere Reihe.“ einmal je Spielstand, nicht in jedem Kampf. Zwei Kämpfe mit
# denselben Flaggen (wie Zustand.flaggen aus spiel.gd): im ersten der Hinweis und die Flagge, im zweiten kein Hinweis; ein Kampf
# ohne Flaggen (Probe) zeigt ihn. Aufruf: im Ordner godot mit -s res://tests/reihe_836.gd
const Aufruf = preload("res://kampf/aufruf.gd")
const Ui = preload("res://kampf/kampf_ui.gd")
const HINWEIS := "Nahkampf erreicht nur die vordere Reihe."

func _initialize() -> void: _lauf.call_deferred()

func _kampf(lage: Dictionary) -> bool:
	var tab = Tabellen.lade()     # 870.6: statt regeln/tabellen.json (Build 278)
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), lage):
		print("FEHLER nicht gestartet"); return false
	for i in 3:
		await process_frame
	var da: bool = a.kampf.ui.lines.has(HINWEIS)
	a.kampf.queue_free()
	a.queue_free()
	await process_frame
	return da

func _lauf() -> void:
	var f := 0
	var flaggen := {}
	var erst: bool = await _kampf({"eroeffnung": "HERO_FIRST", "flaggen": flaggen})
	var zweit: bool = await _kampf({"eroeffnung": "HERO_FIRST", "flaggen": flaggen})
	var probe: bool = await _kampf({"eroeffnung": "HERO_FIRST"})
	print("Hinweis: erster Kampf %s, zweiter %s, Probe ohne Spielstand %s; Flagge %s" % [erst, zweit, probe, flaggen.has(Ui.HINWEIS_REIHE)])
	if not erst or zweit or not probe or not flaggen.has(Ui.HINWEIS_REIHE):
		f += 1
	print("REIHE836 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
