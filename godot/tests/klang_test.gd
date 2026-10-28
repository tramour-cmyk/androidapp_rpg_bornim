extends SceneTree
# 399.3: Klang wie alt (klang/klang.gd): die Aufnahmen liegen in daten/klang (godot.yml „Klang“), jede Szene hat Stücke, ein
# Stück und ein Effekt laden als Klangstrom, Schritte nach dem Boden wie Footsteps.kt, Mischung wie Mix.gain; ein Ortswechsel
# startet die Musik nach Ausblenden und Ruhe (2000 + 500 ms), ein Kampf nach 300 + 500 ms.
# Aufruf: im Ordner godot mit -s res://tests/klang_test.gd (Exit 0 = alles wie alt)

const KlangS = preload("res://klang/klang.gd")

var fehler := 0


func _initialize() -> void:
	_alles.call_deferred()


func _pruef(was: String, gut: bool, info := "") -> void:
	print(("gut " if gut else "FALSCH ") + was + ("" if info == "" else ": " + info))
	if not gut:
		fehler += 1


func _alles() -> void:
	var k = KlangS.new()
	root.add_child(k)
	await process_frame
	_pruef("liste.json", k.liste.get("music", []).size() == 41 and k.liste.get("sfx", []).size() >= 300, "%d Stücke, %d Effekte" % [k.liste.get("music", []).size(), k.liste.get("sfx", []).size()])
	for sz in ["TITLE", "VILLAGE", "FOREST", "CAVE", "BATTLE", "BOSS", "VICTORY"]:
		_pruef("Stücke " + sz, not k._stuecke(sz).is_empty(), str(k._stuecke(sz).size()))
	_pruef("BOSS ohne Tempelstück", not "boss_ancient_legend" in k._stuecke("BOSS"))
	var m = k._strom("music/" + String(k._stuecke("VILLAGE")[0])) if not k._stuecke("VILLAGE").is_empty() else null
	_pruef("Stück lädt", m is AudioStream)
	var e = k._strom("sfx/click_1")
	_pruef("Effekt lädt", e is AudioStream)
	for id in ["click", "door", "coins", "step_grass", "step_wood", "step_cobble", "step_earth", "step_stone"]:
		_pruef("Aufnahmen " + id, k.liste.get("sfx", []).any(func(n): return String(n) == id + "_1"))
	_pruef("Schritt Höhle", KlangS.schritt_klang("CAVE", "cave", "GRASS") == "step_stone")
	_pruef("Schritt Tempel", KlangS.schritt_klang("INTERIOR", "temple", "FLOOR") == "step_cobble")
	_pruef("Schritt Schenke", KlangS.schritt_klang("INTERIOR", "inn", "FLOOR") == "step_wood")
	_pruef("Schritt Brücke", KlangS.schritt_klang("TOWN", "village", "BRIDGE") == "step_wood")
	_pruef("Schritt Pflaster", KlangS.schritt_klang("TOWN", "village", "COBBLE") == "step_cobble")
	_pruef("Schritt Weg", KlangS.schritt_klang("TOWN", "village", "PATH") == "step_earth")
	_pruef("Schritt Gras", KlangS.schritt_klang("TOWN", "village", "GRASS") == "step_grass")
	_pruef("Mischung", is_equal_approx(KlangS.gain(100, 50), 0.25) and is_equal_approx(KlangS.gain(50, 50), 0.0625))
	# nie zweimal dasselbe Stück hintereinander
	var l: Array = k._stuecke("FOREST")
	var zweimal := false
	var vor := ""
	for i in 40:
		var n: String = k._waehle("FOREST", l)
		zweimal = zweimal or (l.size() > 1 and n == vor)
		vor = n
	_pruef("nie zweimal hintereinander", not zweimal)
	# Ortswechsel: erst nach 2,5 s spielt die neue Musik
	k.spiele_szene("VILLAGE")
	await create_timer(2.2).timeout
	var still: bool = not k._spieler.any(func(p): return p.playing)
	await create_timer(0.6).timeout
	var spielt: bool = k._spieler.any(func(p): return p.playing)
	_pruef("Ortsmusik nach 2,5 s", still and spielt, "vorher still %s, danach spielt %s" % [still, spielt])
	# Kampf: altes Stück aus in 0,3 s, Kampfmusik nach 0,8 s, in Schleife
	k.spiele_szene("BATTLE")
	await create_timer(1.0).timeout
	var kampf = k._spieler.filter(func(p): return p.playing)
	var schleife: bool = kampf.size() == 1 and kampf[0].stream is AudioStreamOggVorbis and kampf[0].stream.loop
	_pruef("Kampfmusik nach 0,8 s in Schleife", schleife and String(kampf[0].stream.resource_path).get_file().begins_with("kampf_"))
	print("KLANG %d Fehler" % fehler)
	quit(1 if fehler else 0)
