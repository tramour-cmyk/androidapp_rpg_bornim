extends SceneTree
# 494 ohne Bild (von Tom, 492: Krogg bewacht in der Höhle den rostigen Schlüssel): Probekampf „Krogg“ (aufruf.gd KROGG) mit seinen
# eigenen Regeln aus tabellen.json (Monsters.kt bugbear: Name, Trefferpunkte 5W8+5, Boss, Beute rostiger Schlüssel), gespielt bis zum
# Ende (der Held schlägt zu, Autopilot nie gegen Bosse). Morwens Rauch (D4.1): mit Rauchbündel wirft der Held eins zu Beginn, ohne Zug, Krogg verfehlt den ersten Schlag;
# ohne Bündel keine Meldung.
# Aufruf: im Ordner godot mit -s res://tests/krogg_494.gd

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

var fehler := 0


func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()


func _lauf() -> void:
	var tab: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var krogg: Array = tab.monsters.filter(func(m): return m.id == "bugbear")
	if krogg.is_empty() or not krogg[0].boss or krogg[0].loot.filter(func(l): return l.item == "rusty_key").is_empty():
		fehler += 1
		print("FEHLER tabellen.json: Krogg fehlt, ist kein Boss oder ohne rostigen Schlüssel")
	for k in ["FIGHTER", "WIZARD"]:
		await _kampf(k)
	for rauch in [0, 1, 2]:
		_rauch(tab, rauch)
	print("KROGG 494 %s" % ("gut" if fehler == 0 else "%d FEHLER" % fehler))
	quit(1 if fehler > 0 else 0)


func _kampf(k: String) -> void:
	var p = Probe.new()
	p.hero_cls = k
	p.merc_cls = "CLERIC"
	p.foe = "KROGG"
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
	var m = kf.mars
	var feinde: Array = m.fighters().filter(func(f): return f.side == "FOES")
	if feinde.size() != 1 or String(feinde[0].monster.id) != "bugbear" or String(feinde[0].monster.de) != "Krogg der Grobian":
		fehler += 1
		print("FEHLER Gegner: %s" % [feinde.map(func(f): return "%s/%s" % [f.monster.id, f.monster.de])])
	elif feinde[0].max_hp != int(preload("res://regeln/brs.gd").monster("bugbear").get("leben", -1)):
		# 900 (Lauf 336 am Rechner, Tom: 55 statt 10–45 SRD): Leben nach BRS aus werte.json (Krogg 55)
		fehler += 1
		print("FEHLER Trefferpunkte %d (werte.json %d)" % [feinde[0].max_hp, int(preload("res://regeln/brs.gd").monster("bugbear").get("leben", -1))])
	# Autopilot nie gegen Bosse (72p.1): der Held schlägt den ersten, den er erreicht, wie tests/kampfort_lauf.gd
	kf.mars.find("merc").auto = true
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 90000:
		await process_frame
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				var ts: Array = kf.mars.targets(kf.mars.current())
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	print("Krogg 494 %s: %s, %d TP" % [k, kf.mars.outcome, feinde[0].max_hp if not feinde.is_empty() else 0])
	if kf.mars.outcome == "WON" and not "rusty_key" in kf.reward.get("items", []):
		fehler += 1
		print("FEHLER Sieg ohne rostigen Schlüssel: %s" % [kf.reward])
	if kf.mars.outcome == "ONGOING":
		fehler += 1
		var c = kf.mars.current()
		print("FEHLER Kampf endet nicht (%s): am Zug %s, busy %s, Leben %s" % [k, c.id if c else "-", kf.busy,
			kf.mars.fighters().map(func(f): return "%s %d" % [f.id, f.hp])])
	kf.queue_free()
	p.queue_free()
	for i in 3:
		await process_frame


## D4.1: ein MARS-Kampf Held gegen Krogg aus dem Hinterhalt (Krogg zuerst), jeder Wurf 20 (Krogg träfe immer kritisch); mit [rauch]
## Bündeln: genau eins fliegt zu Beginn, Kroggs erster Schlag geht fehl (und mit ihm der Überraschungsschlag), der Rest bleibt; ohne: er trifft
func _rauch(tab: Dictionary, rauch: int) -> void:
	var skills := {}
	for s in tab.skills:
		skills[s.id] = s
	var sheet: Dictionary = tab.probe.FIGHTER.hero.hero.duplicate(true)
	var held = Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var krogg: Dictionary = tab.monsters.filter(func(m): return m.id == "bugbear")[0]
	var foe = Mars.monster_fighter("krogg", Mars.SPOTS[0], krogg, 999)
	var m = Mars.new([held], [foe], tab, Wuerfel.new(range(400).map(func(_i): return 20)), Wuerfel.new(7), 0, false, "AMBUSHED")
	m.smoke = rauch
	var gehoert := []
	m.listener = func(e): gehoert.append(e)
	m.start()
	var n := 0
	while n < 12 and m.outcome == "ONGOING" and gehoert.filter(func(e): return e.actor == "krogg" and e.roll != null).is_empty():
		m.act(["wait"])
		n += 1
	var wirft := gehoert.filter(func(e): return "Rauchbündel" in String(e.text)).size()
	var schlag: Array = gehoert.filter(func(e): return e.actor == "krogg" and e.roll != null)
	var trifft: bool = not schlag.is_empty() and bool(schlag[0].roll[4])
	var soll := [1 if rauch > 0 else 0, rauch == 0, maxi(rauch - 1, 0)]
	var ist := [wirft, trifft, m.smoke]
	print("Krogg 494 Rauch %d: geworfen %d, erster Schlag %s, übrig %d" % [rauch, wirft, "trifft" if trifft else "fehl", m.smoke])
	if schlag.is_empty() or ist != soll:
		fehler += 1
		print("FEHLER Rauch %d: %s statt %s" % [rauch, ist, soll])
