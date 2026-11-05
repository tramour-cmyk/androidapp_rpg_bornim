# 573 (Chef 04.11., 20:33, Build 257, Probekampf „Wolf mit Jungwölfen“: der zuletzt gefallene Jungwolf wurde tot in die Mitte
# gezogen): wer gefallen ist, bleibt liegen, wo er fiel. Spielt Probekämpfe (Rudel, Wölfe, Ratten) im Kampfort mit Autopilot
# im Zeitraffer, je ohne und mit dem Haken „ich gewinne“ nach dem ersten Gefallenen (Würfel 4 und 8: drei fallen), und misst jede Figur ab dem Fall (Regeln: keine Trefferpunkte, Figur liegt) bis sie ausgeblendet ist.
# Aufruf: godot --headless --path godot -s res://tests/tote_573.gd   (Exit 0 = kein Toter bewegt sich)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const LIMIT_MS := 60000
const WEIT := 0.05     # m

var fehler := 0


func _initialize() -> void:
	Engine.time_scale = 30.0
	_alle.call_deferred()


func _alle() -> void:
	var n := 0
	# 494 (Prüfer 512b): Krogg und Grak bleiben liegen und sprangen beim Neueinpassen der Kamera am Ende (Ergebnisfeld) auf ihren
	# Platz; gemessen gegen den Boden (_ground), der beim Einpassen mitrückt
	for foe in ["RUDEL", "WOLVES", "RATS", "KROGG", "GRAK"]:
		for kl in [["FIGHTER", "CLERIC"], ["CLERIC", "WIZARD"]]:
			for seed in [4, 8]:
				for haken in [false, true]:
					n += 1
					await _einer(foe, kl[0], kl[1], seed, haken)
	print("tote_573: %d Kämpfe, %d Tote bewegt" % [n, fehler])
	quit(1 if fehler > 0 else 0)


## [haken]: nach dem ersten Gefallenen der Haken „ich gewinne“ des Testmodus (kampfort.test_end), wie beim Chef
func _einer(foe: String, hero: String, merc: String, seed: int, haken: bool) -> void:
	var p = Probe.new()
	p.hero_cls = hero
	p.merc_cls = merc
	p.foe = foe
	root.add_child(p)
	await process_frame
	p._start(seed)
	await process_frame
	await process_frame
	var k = p.fight
	k.mars.find("merc").auto = true
	k.mars.set_autopilot(true)
	if not k.busy:
		k.go_on()
	var gehakt := haken
	var liegt := {}     # id -> Ort beim Fall
	var bewegt := {}
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < LIMIT_MS:
		await process_frame
		for id in k.figures:
			var fg = k.figures[id]
			if fg.fighter.hp > 0:
				liegt.erase(id)     # wieder auf den Beinen (Held geheilt)
				continue
			if not fg.down or not fg.visible:
				continue
			if not liegt.has(id):
				liegt[id] = (fg.global_position - k._ground(0, 0))
			elif (fg.global_position - k._ground(0, 0)).distance_to(liegt[id]) > WEIT and not bewegt.has(id):
				bewegt[id] = (fg.global_position - k._ground(0, 0)).distance_to(liegt[id])
		var ende: bool = k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty()
		if ende:
			k._fit_camera()     # wie beim Ergebnisfeld (kampf_ui: Bedienfeld wächst)
			for i in 90:     # noch 3 s Spielzeit: liegen die Toten noch, wo sie fielen?
				await process_frame
				for id in liegt:
					var fg = k.figures[id]
					if fg.visible and (fg.global_position - k._ground(0, 0)).distance_to(liegt[id]) > WEIT and not bewegt.has(id):
						bewegt[id] = (fg.global_position - k._ground(0, 0)).distance_to(liegt[id])
			break
		if haken and not liegt.is_empty() and k.mars.outcome == "ONGOING":
			k.test_end(true)
			haken = false
			continue
		if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
			if k.mars.pilot_next() or k.mars.set_autopilot(true):
				k.go_on()
			else:
				var c = k.mars.current()
				var ts: Array = k.mars.targets(c)
				k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	for id in bewegt:
		print("FEHLER %s %s+%s Würfel %d%s: %s tot um %.2f m verschoben" % [foe, hero, merc, seed, " Haken" if gehakt else "", id, bewegt[id]])
		fehler += 1
	print("%s %s+%s Würfel %d%s: %s, %d gefallen, %d bewegt" % [foe, hero, merc, seed, " Haken" if gehakt else "", k.mars.outcome, liegt.size(), bewegt.size()])
	k.finish()
	p.queue_free()
	await process_frame
