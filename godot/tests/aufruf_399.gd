# 399.2: der Kampfort aus einem Aufruf (kampf/aufruf.gd) wie aus dem Dorf: je Gegnergruppe und Tageszeit ein Kampf auf Autopilot,
# am Ende „Zurück“; geprüft wird das Signal ende (Ergebnis WON oder LOST, Trefferpunkte von Held und Söldner, Lohn nach dem Sieg)
# und dass der Aufruf sich danach entfernt.
# Run: godot --headless --path godot -s res://tests/aufruf_399.gd   (exit code 0 = jeder Kampf meldet sein Ende)
extends SceneTree

const Aufruf = preload("res://kampf/aufruf.gd")
const LIMIT_MS := 60000

var _ende := []


func _initialize() -> void:
	Engine.time_scale = 30.0
	_alle.call_deferred()


func _alle() -> void:
	var tab: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var fehler := 0
	var n := 0
	for fall in [["WOLVES", "tag"], ["RATS", "abend"], ["GRAK", "nacht"], ["GRIMM", "tag"]]:
		n += 1
		var held: Dictionary = tab.probe.FIGHTER.hero
		var merc: Dictionary = tab.probe.CLERIC.merc
		var r: String = await _einer(fall[0], fall[1], held.hero, int(held.hp), merc.hero, int(merc.hp))
		var gut := r.begins_with("WON ") or r.begins_with("LOST ")
		print(("endet " if gut else "FEHLER ") + "%s %s: %s" % [fall[0], fall[1], r])
		if not gut:
			fehler += 1
	# mit Toms Heldwerten (skripte/heldwerte.gd, daten/held.json), sobald beide im Zweig liegen (399.1): neu erschaffener Held je
	# Klasse gegen das Wolfsrudel, Blatt wie MarsGoldenTest.sheet
	if FileAccess.file_exists("res://skripte/heldwerte.gd") and FileAccess.file_exists("res://daten/held.json"):
		var HW = load("res://skripte/heldwerte.gd")
		for k in ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]:
			n += 1
			var h = HW.erschaffe("Alrik", "HUMAN", k)
			var r: String = await _einer("WOLVES", "tag", h, -1, tab.probe.CLERIC.merc.hero, int(tab.probe.CLERIC.merc.hp))
			var gut := r.begins_with("WON ") or r.begins_with("LOST ")
			print(("endet " if gut else "FEHLER ") + "Heldwerte %s: %s" % [k, r])
			if not gut:
				fehler += 1
	else:
		print("Heldwerte fehlen (vor 399.1): nur Blätter aus tabellen.json")
	# ohne LP kein Kampf: ende kommt gleich mit NONE
	var a = Aufruf.new()
	root.add_child(a)
	a.ende.connect(func(e, tp, lohn): _ende.append([e, tp, lohn]))
	_ende.clear()
	var lief: bool = a.starte("WOLVES", tab.probe.FIGHTER.hero.hero, null, "wald", "tag", 2, 0)
	await process_frame
	await process_frame
	var none: bool = not lief and _ende.size() == 1 and _ende[0][0] == "NONE"
	print(("endet " if none else "FEHLER ") + "ohne LP: gestartet %s, Ende %s" % [lief, _ende])
	if not none:
		fehler += 1
	print("Aufruf 399.2: %d Kämpfe, %d ohne richtiges Ende" % [n + 1, fehler])
	quit(1 if fehler > 0 else 0)


func _einer(gegner: String, zeit: String, held, held_tp: int, merc: Dictionary, merc_tp: int) -> String:
	var a = Aufruf.new()
	root.add_child(a)
	_ende.clear()
	a.ende.connect(func(e, tp, lohn): _ende.append([e, tp, lohn]))
	if not a.starte(gegner, held, merc, "wald", zeit, 2, held_tp, merc_tp, 7):
		return "nicht gestartet"
	await process_frame
	await process_frame
	var k = a.kampf
	if k.tageszeit != zeit:
		return "Tageszeit %s statt %s" % [k.tageszeit, zeit]
	k.mars.find("merc").auto = true
	k.mars.set_autopilot(true)
	if not k.busy:
		k.go_on()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < LIMIT_MS:
		await process_frame
		if k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty():
			break
		if not k.busy and not k.playing and k.beats.is_empty() and k.mars.outcome == "ONGOING":
			if k.mars.pilot_next() or k.mars.set_autopilot(true):
				k.go_on()
			else:     # gegen einen Anführer kein Autopilot: der Held schlägt den ersten, den er erreicht
				var c = k.mars.current()
				var ts: Array = k.mars.targets(c)
				k.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	if k.mars.outcome == "ONGOING":
		return "hängt"
	k.finish()     # „Zurück“
	await process_frame
	await process_frame
	if _ende.size() != 1:
		return "%s, ende %d-mal" % [k.mars.outcome if is_instance_valid(k) else "?", _ende.size()]
	var e: Array = _ende[0]
	if not (e[1].has("hero") and e[1].has("merc")):
		return "%s ohne Trefferpunkte %s" % [e[0], e[1]]
	if e[0] == "WON" and e[2].is_empty():
		return "WON ohne Lohn"
	if is_instance_valid(a) and a.is_inside_tree():
		return "%s, Aufruf bleibt" % e[0]
	return "%s TP %s Lohn %s" % [e[0], e[1], e[2].keys()]
