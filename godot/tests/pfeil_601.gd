extends SceneTree
# 601 (Chef 05.11., Build 266: „Bei Fehlschuss mit Bogen ist gar kein Pfeil zu sehen“): welcher Effekt zu einer Meldung des
# Goblin-Spähers fliegt (kampfort.gd _fx_of). Wie alt (SkirmishScreen, Rückläufer t58: „a ducked arrow flies too“): Treffer,
# Fehlschuss und Ducken („duckt sich“, ohne Wurf) zeigen den Pfeil; ein Goblin mit Säbel keinen. Ohne Bild, Sekunden.
# Aufruf: im Ordner godot mit -s res://tests/pfeil_601.gd   (Exit 0 = gut)

const Mars = preload("res://regeln/mars.gd")
const Kampfort = preload("res://kampf/kampfort.gd")


func _initialize() -> void:
	var tab: Dictionary = Tabellen.lade()
	var m := {}
	for x in tab.monsters: m[String(x.id)] = x
	var h: Dictionary = tab.probe.FIGHTER.hero
	var held = Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), h.hero, int(h.hp), h.hero.second, {})
	var spaeher = Mars.monster_fighter("scout", Vector2i(Mars.BACK, 0), m.goblin_archer, 7)
	var goblin = Mars.monster_fighter("gob1", Vector2i(Mars.FRONT, 0), m.goblin, 7)
	var kf = Kampfort.new()
	var faelle := [
		["Späher trifft", spaeher, {"roll": ["ATTACK", 15, 4, 17, true, 0, false], "spell": null, "cue": ""}, "ARROW"],
		["Späher daneben", spaeher, {"roll": ["ATTACK", 5, 4, 17, false, 0, false], "spell": null, "cue": ""}, "ARROW"],
		["Held duckt sich", spaeher, {"roll": null, "spell": null, "cue": "DUCKED"}, "ARROW"],
		["Goblin schlägt", goblin, {"roll": ["ATTACK", 15, 4, 17, true, 0, false], "spell": null, "cue": ""}, null],
		["Späher geht in den Schatten", spaeher, {"roll": null, "spell": null, "cue": ""}, null],
	]
	var fehler := 0
	for f in faelle:
		var fx = kf._fx_of(f[2], f[1], held, true)
		var gut: bool = fx == f[3]
		print("%s %s: %s" % ["PFEIL601 ok" if gut else "PFEIL601 FALSCH", f[0], fx])
		if not gut: fehler += 1
	kf.free()
	print("PFEIL601 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler else 0)
