extends SceneTree
# 939 (Tom 786, alt SkirmishScreen 548, 713, 726; BattleScreen 523, 587): Kampfklang wie alt. Statt des Autoloads Klang hört ein
# Zeuge mit: Ring geht auf → swing_heavy 0,6; perfekt → block 0,8, gut → block 0,5, verpasst → kein Block; Wölfe heulen beim
# Erscheinen in etwa der Hälfte der Kämpfe; Sieg → loot_epic, loot oder coins nach der Beute, level_up danach bei einer Stufe.
# Aufruf: im Ordner godot mit -s res://tests/kampfklang_939.gd
const Aufruf = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")

class Zeuge extends Node:
	var gehoert: Array = []
	func effekt(id: String, pegel := 0.8, _tempo := 1.0, _nr := -1) -> void: gehoert.append([id, snappedf(pegel, 0.01)])
	func kampf(_e, _mars, _ms := -1) -> void: pass
	func ids() -> Array: return gehoert.map(func(x): return x[0])

var zeuge := Zeuge.new()

func _initialize() -> void: _lauf.call_deferred()

func _kampf(gegner: String, seed: int):
	var tab = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte(gegner, held.hero, null, "wald", "tag", 2, int(held.hp), -1, seed, Callable(), {"eroeffnung": "HERO_FIRST"}):
		print("FEHLER nicht gestartet"); return null
	await process_frame
	await process_frame
	return a

func _lauf() -> void:
	var f := 0
	var alt = root.get_node_or_null("Klang")
	if alt != null:
		root.remove_child(alt)
		alt.queue_free()
	zeuge.name = "Klang"
	root.add_child(zeuge)
	# Geheul: zwanzig Wolfskämpfe, etwa die Hälfte heult (alt: Random < 0.5); Ratten nie
	var heult := 0
	for i in 20:
		zeuge.gehoert.clear()
		var a = await _kampf("WOLVES", 100 + i)
		if zeuge.ids().has("howl"): heult += 1
		a.kampf.queue_free(); a.queue_free()
		await process_frame
	zeuge.gehoert.clear()
	var r = await _kampf("RATS", 3)
	var ratten_heul: bool = zeuge.ids().has("howl")
	print("Geheul beim Erscheinen: %d von 20 Wolfskämpfen, Ratten %s" % [heult, ratten_heul])
	if heult < 4 or heult > 16 or ratten_heul:
		f += 1
	# Ring: aufgehen, dann perfekt, gut, verpasst
	var k = r.kampf
	var ergebnis := {}
	for antwort in [Mars.PERFECT, Mars.GOOD, Mars.NONE]:
		zeuge.gehoert.clear()
		k._play_ring("hero", {})
		await process_frame
		k._answer_ring(antwort)
		ergebnis[antwort] = zeuge.gehoert.duplicate()
	print("Ring: perfekt %s, gut %s, verpasst %s" % [ergebnis[Mars.PERFECT], ergebnis[Mars.GOOD], ergebnis[Mars.NONE]])
	if ergebnis[Mars.PERFECT] != [["swing_heavy", 0.6], ["block", 0.8]] or ergebnis[Mars.GOOD] != [["swing_heavy", 0.6], ["block", 0.5]] \
			or ergebnis[Mars.NONE] != [["swing_heavy", 0.6]]:
		f += 1
	# Sieg: Lohn ohne Beute → Münzen; mit Beute → loot; mit epischer → loot_epic; mit Stufe → danach level_up
	var faelle := [[{"gear": [], "items": [], "levels": 0}, ["coins"]], [{"gear": [], "items": ["potion"], "levels": 0}, ["loot"]],
		[{"gear": [{"rarity": "RARE"}, {"rarity": "EPIC"}], "items": [], "levels": 1}, ["loot_epic", "level_up"]]]
	for fall in faelle:
		zeuge.gehoert.clear()
		k.reward = fall[0]
		k._sieg_klang()
		await create_timer(k.STUFE_KLANG_MS / 1000.0 + 0.3).timeout
		print("Sieg %s: %s" % [fall[0], zeuge.ids()])
		if zeuge.ids() != fall[1]:
			f += 1
	print("KAMPFKLANG939 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
