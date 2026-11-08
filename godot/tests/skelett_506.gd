extends SceneTree
# 506 ohne Bild: Probekampf „Skelette“ (aufruf.gd SKELETONS): drei Skelette mit ihren eigenen Regeln aus tabellen.json (Monsters.kt
# skeleton: Name, Trefferpunkte 2W8+4, Kurzschwert 1W6+2, gegen Gift gefeit), MARS spielt den Kampf auf Autopilot zu Ende.
# Aufruf: im Ordner godot mit -s res://tests/skelett_506.gd (Exit 0 = gut)

const Probe = preload("res://kampf/probe.gd")

var fehler := 0


func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()


func _lauf() -> void:
	for k in ["FIGHTER", "CLERIC", "WIZARD"]:
		await _kampf(k, k == "FIGHTER")
	print("SKELETT506 %s" % ("0 Fehler" if fehler == 0 else "%d FEHLER" % fehler))
	quit(1 if fehler > 0 else 0)


## [bis_ende]: MARS spielt auf Autopilot zu Ende; unter einem Drittel der Lebenspunkte gibt er den Zug an den Spieler zurück
## (autopilot_blocked), darum nur mit dem Kämpfer, der drei Skelette sicher besiegt; sonst nur Aufstellung und Regeln
func _kampf(k: String, bis_ende: bool) -> void:
	var p = Probe.new()
	p.hero_cls = k
	p.merc_cls = "CLERIC" if k != "CLERIC" else "FIGHTER"
	p.foe = OS.get_environment("FOE") if OS.has_environment("FOE") else "SKELETONS"
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
	if feinde.size() != 3 or feinde.any(func(f): return String(f.monster.id) != "skeleton" or String(f.monster.de) != "Skelett"):
		fehler += 1
		print("FEHLER Gegner: %s" % [feinde.map(func(f): return "%s/%s" % [f.monster.id, f.monster.de])])
	for f in feinde:
		if f.max_hp < 6 or f.max_hp > 20:
			fehler += 1
			print("FEHLER Trefferpunkte %d (6–20)" % f.max_hp)
	if not bis_ende:
		print("Skelett 506 %s gegen drei Skelette: aufgestellt, TP %s" % [k, feinde.map(func(f): return f.max_hp)])
		kf.queue_free()
		p.queue_free()
		for i in 3:
			await process_frame
		return
	kf.mars.find("merc").auto = true
	kf.mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 90000 and kf.mars.outcome == "ONGOING":
		await process_frame
	print("Skelett 506 %s gegen drei Skelette: %s, TP %s" % [k, kf.mars.outcome, feinde.map(func(f): return f.max_hp)])
	if kf.mars.outcome == "ONGOING":
		var c = kf.mars.current()
		print("  dran %s, Zug %d, busy %s, TP %s" % [c.id if c else "-", kf.mars.turn, kf.busy, kf.mars.fighters().map(func(f): return "%s:%d" % [f.id, f.hp])])
		fehler += 1
		print("FEHLER Kampf endet nicht (%s)" % k)
	kf.queue_free()
	p.queue_free()
	for i in 3:
		await process_frame
