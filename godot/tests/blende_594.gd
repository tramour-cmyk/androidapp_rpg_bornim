extends SceneTree
# 594 (Chef 05.11., Build 266, Probekampf „Spinne“: Wolfstext in der Blende): Kampfblende.lage wählt wie alt SkirmishScreen den
# Boss, sonst den Gegner mit den meisten EP (Gleichstand: der erste), Rudel nur bei mehr als einem dieser Art. Ohne Bild, Sekunden.
# Aufruf: im Ordner godot mit -s res://tests/blende_594.gd   (Exit 0 = gut)

const Kampfblende = preload("res://kampf/kampfblende.gd")


class Kaempfer:
	var side := "FOES"
	var monster: Dictionary
	func _init(m: Dictionary) -> void: monster = m


class Lage:
	var lang := 0
	var liste: Array = []
	func fighters() -> Array: return liste


func _initialize() -> void:
	var tab: Dictionary = Tabellen.lade()
	var m := {}
	for x in tab.monsters: m[String(x.id)] = x
	var grimm: Dictionary = (m["dire_wolf"] as Dictionary).duplicate(true)
	grimm.id = "wolf"     # aufruf.gd: Grimmzahn mit der id des Wolfs
	var held := Kaempfer.new({}); held.side = "PARTY"
	var faelle := [
		["Riesenspinne und Wolf", [m.wolf, m.giant_spider], "giant_spider", false, false],
		["Wolfsrudel", [m.wolf, m.wolf, m.wolf], "wolf", false, true],
		["Grimmzahn", [grimm, m.wolf, m.wolf], "wolf", true, true],
		["Goblin-Späher und Goblin", [m.goblin, m.goblin_archer], "goblin", false, false],
		["Riesenratte allein", [m.giant_rat], "giant_rat", false, false],
	]
	var fehler := 0
	for f in faelle:
		var l := Lage.new()
		l.liste.append(held)
		for x in f[1]: l.liste.append(Kaempfer.new(x))
		var e: Dictionary = Kampfblende.lage(l)
		var gut: bool = e.id == f[2] and e.boss == f[3] and e.rudel == f[4]
		print("%s %s: %s (%s), Boss %s, Rudel %s" % ["BLENDE594 ok" if gut else "BLENDE594 FALSCH", f[0], e.id, e.name, e.boss, e.rudel])
		if not gut: fehler += 1
	print("BLENDE594 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler else 0)
