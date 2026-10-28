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
	for id in ["click", "door", "coins", "pant_man", "pant_woman", "step_grass", "step_wood", "step_cobble", "step_earth", "step_stone"]:
		_pruef("Aufnahmen " + id, k.liste.get("sfx", []).any(func(n): return String(n) == id + "_1"))
	_pruef("Schritt Höhle", KlangS.schritt_klang("CAVE", "cave", "GRASS") == "step_stone")
	_pruef("Schritt Tempel", KlangS.schritt_klang("INTERIOR", "temple", "FLOOR") == "step_cobble")
	_pruef("Schritt Schenke", KlangS.schritt_klang("INTERIOR", "inn", "FLOOR") == "step_wood")
	_pruef("Schritt Brücke", KlangS.schritt_klang("TOWN", "village", "BRIDGE") == "step_wood")
	_pruef("Schritt Pflaster", KlangS.schritt_klang("TOWN", "village", "COBBLE") == "step_cobble")
	_pruef("Schritt Weg", KlangS.schritt_klang("TOWN", "village", "PATH") == "step_earth")
	_pruef("Schritt Gras", KlangS.schritt_klang("TOWN", "village", "GRASS") == "step_grass")
	# Keuchen (Panting.kt, PantingTest.kt): atemlos leer, dann im Stehen zurück bis Stamina.AGAIN (20 s für den vollen Vorrat)
	var atem := []
	var aus := 0.0
	var t := 0.0
	_pruef("kein Keuchen mit Atem", k.atem_pegel(false, 0.5, 0.0) < 0.0)
	while aus < 0.25:
		var p: float = k.atem_pegel(true, aus, t)
		if p > 0.0: atem.append([t, p])
		aus += 20.0 / 20000.0; t += 20.0
	_pruef("kein Keuchen, wenn der Atem zurück ist", k.atem_pegel(false, aus, t) < 0.0)
	var luecken := []
	for i in atem.size() - 1: luecken.append(atem[i + 1][0] - atem[i][0])
	_pruef("Keuchen sofort, dann Zug auf Zug, Pausen wachsen, leiser", atem.size() >= 3 and atem[0][0] == 0.0 and is_equal_approx(atem[0][1], 0.6)
		and luecken[0] <= KlangS.atem_ms(false) + 200 and range(luecken.size() - 1).all(func(i): return luecken[i + 1] >= luecken[i])
		and range(atem.size() - 1).all(func(i): return atem[i + 1][1] <= atem[i][1]), str(atem))
	_pruef("Atemzug Frau", KlangS.atem_ms(true) == 1600.0)
	# Kampfklang (MarsSound.kt): synthetische Klänge aus KlangExport.kt, Tabelle, Stimmen
	_pruef("kampfklang.json", String(k.kampftabelle.get("monster_fx", {}).get("wolf", "")) == "BITE")
	_pruef("Synthese lädt", k._strom("sfx/hit_slash_1") is AudioStream and k._strom("sfx/swing_heavy_3") is AudioStream)
	_pruef("Klang je Effekt", k._fx_klang("BITE") == "bite" and k._fx_klang("SLASH", true) == "crit" and k._fx_klang("FIRE_BOLT") == "fire" and k._fx_klang("ARROW", true) == "arrow")
	_pruef("Wolfsstimme", k.liste.get("sfx", []).has("wolf_angriff_1") and k.liste.get("sfx", []).has("wolf_tod_3"))
	_pruef("Mischung", is_equal_approx(KlangS.gain(100, 50), 0.25) and is_equal_approx(KlangS.gain(50, 50), 0.0625))
	# Ortsklang (PlaceSound.kt, Ambience.kt, RiverSound.kt) und Raumklang (Room.kt)
	_pruef("Ortsart", KlangS.ortsart_von("TOWN", "village") == "OUTSIDE" and KlangS.ortsart_von("INTERIOR", "inn") == "TAVERN"
		and KlangS.ortsart_von("INTERIOR", "temple") == "HALL" and KlangS.ortsart_von("INTERIOR", "smithy") == "ROOM" and KlangS.ortsart_von("CAVE", "cave") == "CAVE")
	_pruef("Knistern", KlangS.ziel(null, 6.0, 1.0, 0.5) == 0.0 and is_equal_approx(KlangS.ziel(1.0, 6.0, 1.0, 0.5), 0.5) and is_equal_approx(KlangS.ziel(3.5, 6.0, 1.0, 0.5), 0.25))
	_pruef("nie ein Sprung", is_equal_approx(KlangS.naeher(0.0, 0.5, 0.5, 100.0, 1000.0), 0.05))
	_pruef("Husten nur mit Gast", KlangS.ereignisse("TAVERN", ["innkeeper"]) == [["creak", 2]] and KlangS.ereignisse("TAVERN", ["innkeeper", "farmer"]).size() == 2
		and KlangS.ereignisse("OUTSIDE", ["farmer"]).is_empty())
	var kf := {"kacheln": {".": {"name": "FLOOR"}, "#": {"name": "WALL"}, "f": {"name": "HEARTH"}}, "daten": {"art": "INTERIOR"}, "breite": 7, "hoehe": 3,
		"zeilen": ["f.#....", "..#....", "......."]}
	var karte := _Probekarte.new(kf)
	# die Wand dazwischen: unten herum 5 gerade Schritte und einer schräg (schräg nie an der Wand vorbei), drinnen 1,5-mal so weit getragen
	var um = KlangS.feuer_weit(karte, Vector2i(3, 0))
	_pruef("Feuer um die Wand", um != null and is_equal_approx(float(um), (5.0 + sqrt(2.0)) / 1.5), str(um))
	_pruef("Feuer zu weit", KlangS.feuer_weit(_Probekarte.new({"kacheln": kf.kacheln, "daten": {"art": "TOWN"}, "breite": 7, "hoehe": 3, "zeilen": kf.zeilen}), Vector2i(3, 0)) == null)
	_pruef("Raumfassungen", k.liste.get("raum", {}).get("tavern", []).has("creak_1") and k.liste.get("raum", {}).get("cave", []).has("hit_slash_1")
		and not k.liste.get("raum", {}).get("cave", []).has("drip_1"))
	# Schwarzblende (Hush, VeilGate): still darin, danach in 400 ms wieder ganz
	k.verhuelle(true)
	var zu: float = k.schleier_pegel()
	k.verhuelle(false)
	var gleich: float = k.schleier_pegel()
	await create_timer(0.6).timeout
	_pruef("Schwarzblende", zu == 0.0 and gleich < 0.2 and k.schleier_pegel() == 1.0, "%.2f %.2f %.2f" % [zu, gleich, k.schleier_pegel()])
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


## Eine kleine Karte wie skripte/karte.gd (zeichen, kacheln, daten, breite, hoehe) für feuer_weit
class _Probekarte:
	var kacheln: Dictionary
	var daten: Dictionary
	var breite: int
	var hoehe: int
	var zeilen: Array
	var id := "probe"

	func _init(d: Dictionary) -> void:
		kacheln = d.kacheln
		daten = d.daten
		breite = d.breite
		hoehe = d.hoehe
		zeilen = d.zeilen

	func zeichen(t: Vector2i) -> String:
		return String(zeilen[t.y][t.x])
