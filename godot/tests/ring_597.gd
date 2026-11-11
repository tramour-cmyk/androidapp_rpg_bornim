extends SceneTree
# 597 (Chef 05.11., Build 266: „Ring wurde (glaube bei Fledermäusen) nicht ‚angekündigt‘, bitte grundsätzlich prüfen“; Regel 406.1:
# Ring nur bei angekündigten Nahangriffen): je Gegnergruppe des Probekampfs viele Kämpfe ohne Bild, Kämpfer (vorn) und Klerikerin,
# beide von Hand (kein Autopilot), Befehle zufällig (Angriff, Deckung, wo möglich). Jeder Ring wird gezählt: angesagt mit Ringzeichen
# (Absicht mit Ring, kampf_ui „ring“), durch eigene Deckung (Kämpfer zieht den Schlag auf sich) oder unangekündigt; dazu,
# ob der Ring einen anderen trifft als den angesagten. Ausgabe: Liste je Gruppe. Exit 0 = kein unangekündigter Ring.
# Aufruf: im Ordner godot mit -s res://tests/ring_597.gd

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Aufruf = preload("res://kampf/aufruf.gd")
const Probe = preload("res://kampf/probe.gd")

const KAEMPFE := 40

var tables: Dictionary
var zahl := {}
var vorher := {}     # Ansagen bei der letzten Wahl (mars.gd löscht die Absicht vor dem Schlag)


func _initialize() -> void:
	tables = Tabellen.lade()
	var monsters := {}
	for m in tables.monsters: monsters[String(m.id)] = m
	var skills := {}
	for s in tables.skills: skills[s.id] = s
	var schlecht := 0
	for foe in Probe.FOES:
		zahl = {"ring": 0, "zeichen": 0, "deckung": 0, "ohne": 0, "anderer": 0, "absichten": {}}
		for k in KAEMPFE:
			var dice := Wuerfel.new(5970 + k)
			var foes: Array = Aufruf.gegner(foe, monsters, dice)
			if foes.is_empty(): continue
			var h: Dictionary = tables.probe.FIGHTER.hero
			var c: Dictionary = tables.probe.CLERIC.merc
			var party := [Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), h.hero.duplicate(true), int(h.hp), h.hero.second, skills),
				Mars.hero_fighter("merc", "PARTY", Vector2i(Mars.BACK, 0), c.hero.duplicate(true), int(c.hp), c.hero.second, skills)]
			var mars = Mars.new(party, foes, tables, dice, Wuerfel.new(77 + k))
			var react := func(t, intent) -> String: return _ring(mars, t, intent)
			vorher = mars.intents.duplicate()
			mars.start(react)
			var zuege := 0
			while mars.outcome == "ONGOING" and zuege < 80:
				zuege += 1
				var f = mars.current()
				var o: Array = ["wait"]
				var g: Array = mars.guardable(f)
				var ziele: Array = mars.targets(f)
				if not g.is_empty() and dice.chance(0.4): o = ["guard"]
				elif not ziele.is_empty(): o = ["attack", ziele[dice.roll_expr([1, ziele.size(), -1])].id]
				vorher = mars.intents.duplicate()
				mars.act(o, react)
		var ohne: int = zahl.ohne
		if ohne: schlecht += 1
		print("%s %s (%s): Ringe %d, mit Ringzeichen %d, durch Deckung %d, unangekündigt %d, anderer Held als angesagt %d; Absichten %s" % [
			"RING597 ok" if ohne == 0 else "RING597 FALSCH", foe, Probe.FOES[foe], zahl.ring, zahl.zeichen, zahl.deckung, ohne, zahl.anderer, zahl.absichten])
	print("RING597 %s" % ("gut" if schlecht == 0 else "FALSCH %d Gruppen" % schlecht))
	quit(1 if schlecht else 0)


func _ring(mars, t, intent: Dictionary) -> String:
	zahl.ring += 1
	var art := String(intent.id)
	zahl.absichten[art] = int(zahl.absichten.get(art, 0)) + 1
	var mit := vorher.keys().filter(func(id): return vorher[id][0] == intent)
	var deckung: bool = mit.any(func(id): return id in t.cover_from)
	if intent.kind == "STRIKE" and bool(intent.get("ring", false)): zahl.zeichen += 1
	elif deckung: zahl.deckung += 1
	else: zahl.ohne += 1
	if not deckung and not mit.any(func(id): return t.id in vorher[id][1]): zahl.anderer += 1     # sonst nachgezielt (Ziel fiel)
	return Mars.GOOD
