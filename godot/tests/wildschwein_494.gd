extends SceneTree
# 494 ohne Bild: Probekampf „Wildschwein“ (aufruf.gd BOARS): ein Wildschwein mit seinen eigenen Regeln aus tabellen.json (Monsters.kt boar:
# Name, Trefferpunkte 2W8+2, Hauer), MARS spielt es auf Autopilot zu Ende; im Bild ein Vierbeiner (Figur.vier), mit Kaufmodell der Keiler.
# Dazu der Riesen-Hundertfüßer (CENTIPEDES, Monsters.kt giant_centipede, 2W6+1), Riesenegel (LEECHES) und Säureschnecke (SLUGS).
# Aufruf: im Ordner godot mit -s res://tests/wildschwein_494.gd

const Probe = preload("res://kampf/probe.gd")
const Figur = preload("res://kampf/figur.gd")

var fehler := 0


func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()


func _lauf() -> void:
	for k in ["FIGHTER", "WIZARD"]:
		await _kampf(k, "BOARS", "boar", "Wildschwein", 4, 18)
	await _kampf("FIGHTER", "CENTIPEDES", "giant_centipede", "Riesen-Hundertfüßer", 3, 13)
	# Kauf 348.12c: Riesenegel (Regeln der Stirge, 2W4+1) und Säureschnecke (Regeln der Ockergallerte, 5W10+5), Namen nach LISTE-FIGUREN
	await _kampf("FIGHTER", "LEECHES", "stirge", "Riesenegel", 3, 9)
	await _kampf("FIGHTER", "SLUGS", "ochre_jelly", "Säureschnecke", 10, 55)
	print("WILDSCHWEIN 494 %s" % ("gut" if fehler == 0 else "%d FEHLER" % fehler))
	quit(1 if fehler > 0 else 0)


func _kampf(k: String, foe: String, id: String, de: String, lo: int, hi: int) -> void:
	var p = Probe.new()
	p.hero_cls = k
	p.merc_cls = "CLERIC"
	p.foe = foe
	root.add_child(p)
	await process_frame
	p._start(3)
	for i in 6:
		await process_frame
	var kf = p.fight
	if kf == null:
		fehler += 1
		print("FEHLER kein Kampfort (%s)" % k)
		return
	var feinde: Array = kf.mars.fighters().filter(func(f): return f.side == "FOES")
	if feinde.size() != 1 or String(feinde[0].monster.id) != id or String(feinde[0].monster.de) != de:
		fehler += 1
		print("FEHLER Gegner: %s" % [feinde.map(func(f): return "%s/%s" % [f.monster.id, f.monster.de])])
	elif feinde[0].max_hp < lo or feinde[0].max_hp > hi:
		fehler += 1
		print("FEHLER Trefferpunkte %d (%d–%d)" % [feinde[0].max_hp, lo, hi])
	var fig = kf.figures.get(String(feinde[0].id)) if not feinde.is_empty() else null
	if fig == null or not Figur.vier(fig.fighter):
		fehler += 1
		print("FEHLER Figur %s kein Vierbeiner" % de)
	kf.mars.find("merc").auto = true
	kf.mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 60000 and kf.mars.outcome == "ONGOING":
		await process_frame
	print("Wildschwein 494 %s gegen %s: %s, %d TP, Modell %s" % [k, de, kf.mars.outcome, feinde[0].max_hp if not feinde.is_empty() else 0,
		fig._model_path() if fig != null else "-"])
	if kf.mars.outcome == "ONGOING":
		fehler += 1
		print("FEHLER Kampf endet nicht (%s)" % k)
	kf.queue_free()
	p.queue_free()
	for i in 3:
		await process_frame
