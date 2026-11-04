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
	# Dorftiere (401): je Tier mindestens drei Aufnahmen, jede da; leiser mit dem Abstand, ab 6 Kacheln still
	for tier in KlangS.TIERLAUT:
		var a: Dictionary = KlangS.TIERLAUT[tier]
		var ids: Array = [a.fressen[0]] + a.held.map(func(l): return l[0]) + ([a.ruf[0]] if a.has("ruf") else []) + ([a.anfang[0]] if a.has("anfang") else [])
		var takes := {}
		for id in ids:
			for n in k.liste.get("sfx", []):
				if String(n).begins_with(id + "_") and String(n).substr(String(id).length() + 1).is_valid_int(): takes[n] = true
		_pruef("Laute " + tier, takes.size() >= 3 and ids.all(func(id): return takes.keys().any(func(n): return String(n).begins_with(id + "_"))), str(takes.keys()))
	_pruef("Tiere nach Abstand", is_equal_approx(KlangS.tier_pegel(1.0, 0.4), 0.4) and KlangS.tier_pegel(6.0, 0.4) == 0.0
		and KlangS.tier_pegel(3.0, 0.4) > KlangS.tier_pegel(4.5, 0.4))
	# im Ablauf: eine Ziege 2 Kacheln vor dem Helden beginnt zu fressen (Grasrupfen), dann kommt er heran (Meckern)
	var hof := Node3D.new()
	root.add_child(hof)
	var held := Node3D.new()
	hof.add_child(held)
	var ziege := _Probetier.new()
	hof.add_child(ziege)
	ziege.position = Vector3(2.32, 0, 0)
	k._held = held
	k._tierlaute(100.0)
	var vorher: int = k._naechster
	ziege.pause = "Fressen"
	for i in 5: k._tierlaute(100.0)
	var gerupft: int = k._naechster - vorher
	ziege.nah = true
	k._tierlaute(100.0)
	_pruef("Ziege rupft und meckert", gerupft == 1 and k._naechster - vorher == 2 and String(k._effekte[(k._naechster + 7) % 8].stream.resource_path).get_file().begins_with("goat_bleat"),
		"%d, %d" % [gerupft, k._naechster - vorher])
	k._held = null
	hof.queue_free()
	# Kampfklang (MarsSound.kt): synthetische Klänge aus KlangExport.kt, Tabelle, Stimmen
	_pruef("kampfklang.json", String(k.kampftabelle.get("monster_fx", {}).get("wolf", "")) == "BITE")
	_pruef("Synthese lädt", k._strom("sfx/hit_slash_1") is AudioStream and k._strom("sfx/swing_heavy_3") is AudioStream)
	_pruef("Klang je Effekt", k._fx_klang("BITE") == "bite" and k._fx_klang("SLASH", true) == "crit" and k._fx_klang("FIRE_BOLT") == "fire" and k._fx_klang("ARROW", true) == "arrow")
	_pruef("Wolfsstimme", k.liste.get("sfx", []).has("wolf_angriff_1") and k.liste.get("sfx", []).has("wolf_tod_3"))
	# 575: Ratte im Wolfskörper (aufruf.gd ART) spricht und beißt als Ratte
	_pruef("Art statt Körper", KlangS.art_von({"id": "giant_rat", "koerper": "wolf"}) == "giant_rat" and KlangS.art_von({"id": "wolf"}) == "wolf")
	_pruef("Rattenstimme da", String(k.kampftabelle.get("stimme", {}).get("giant_rat", {}).get("stimme", "")) == "giant_rat" and k.liste.get("sfx", []).has("giant_rat_angriff_1"))
	_pruef("Mischung", is_equal_approx(KlangS.gain(100, 50), 0.25) and is_equal_approx(KlangS.gain(50, 50), 0.0625))
	# Ortsklang (PlaceSound.kt, Ambience.kt, RiverSound.kt) und Raumklang (Room.kt)
	_pruef("Ortsart", KlangS.ortsart_von("TOWN", "village") == "OUTSIDE" and KlangS.ortsart_von("INTERIOR", "inn") == "TAVERN"
		and KlangS.ortsart_von("INTERIOR", "temple") == "HALL" and KlangS.ortsart_von("INTERIOR", "smithy") == "ROOM" and KlangS.ortsart_von("CAVE", "cave") == "CAVE")
	# 517 Kleines Leben, ferne Laute (WildSound.kt)
	_pruef("Wildart", KlangS.wild_art("FOREST", "deep_forest") == "DEEP_WOOD" and KlangS.wild_art("FOREST", "forest") == "WOOD"
		and KlangS.wild_art("TOWN", "village") == "VILLAGE" and KlangS.wild_art("CAVE", "cave") == "CAVE" and KlangS.wild_art("INTERIOR", "inn") == "NONE")
	var z := RandomNumberGenerator.new()
	z.seed = 517
	var wald_nacht := {}
	for i in 300:
		wald_nacht[KlangS.leben("WOOD", true, false, z)] = true
	_pruef("Wald nachts Eule und Grillen", wald_nacht.has("owl") and wald_nacht.has("cricket") and wald_nacht.size() == 2, str(wald_nacht.keys()))
	_pruef("am Tag Vögel, im Tiefen Wald keine", KlangS.leben("WOOD", false, false, z) == "bird" and KlangS.leben("VILLAGE", false, false, z) == "bird"
		and KlangS.leben("DEEP_WOOD", false, false, z) == "" and KlangS.leben("DEEP_WOOD", true, false, z) == "cricket"
		and KlangS.leben("VILLAGE", true, false, z) == "cricket" and KlangS.leben("WOOD", false, true, z) == "" and KlangS.leben("CAVE", false, false, z) == "")
	_pruef("fern: Wolf im Tiefen Wald, Berg in der Höhle", KlangS.fern("DEEP_WOOD") == "wolf_far" and KlangS.fern("CAVE") == "rumble"
		and KlangS.fern("WOOD") == "" and KlangS.fern("VILLAGE") == "")
	var p_n := KlangS.fern_pause_ms("DEEP_WOOD", true, z)
	var p_t := KlangS.fern_pause_ms("DEEP_WOOD", false, z)
	_pruef("Wolf selten, am Tag seltener", p_n >= 60000.0 and p_n <= 150000.0 and p_t >= 120000.0 and p_t <= 300000.0, "%.0f %.0f" % [p_n, p_t])
	var sei := KlangS.seite(z)
	_pruef("von der Seite, nie geradeaus", absf(sei) >= 0.35 and absf(sei) <= 0.85 and is_equal_approx(KlangS.panner(0.5), 0.4))
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
	await _wald_517(k)
	print("KLANG %d Fehler" % fehler)
	quit(1 if fehler else 0)


## 517: im Tiefen Wald nachts Grillen und von einer Seite ein ferner Wolf, am Tag dort nichts als Wind; im Wald nachts auch die Eule,
## am Tag Vögel (WildSound.kt); die Uhr des Orts läuft hier ohne Warten (_ortsklang je 100 ms wie WorldScreen.kt)
func _wald_517(k) -> void:
	var sp := Node3D.new()
	var skript := GDScript.new()
	skript.source_code = "extends Node3D\nvar licht\n"
	skript.reload()
	sp.set_script(skript)
	var lk := Node.new()
	var lskript := GDScript.new()
	lskript.source_code = "extends Node\nvar nacht := 1.0\n"
	lskript.reload()
	lk.set_script(lskript)
	sp.set("licht", lk)
	var held := Node3D.new()
	sp.add_child(held)
	root.add_child(sp)
	k.spiele_szene("FOREST")
	for fall in [["deep_forest", 1.0], ["deep_forest", 0.0], ["forest", 1.0], ["forest", 0.0]]:
		var karte := _Probekarte.new({"kacheln": {".": {"name": "GRASS"}}, "daten": {"art": "FOREST"}, "breite": 3, "hoehe": 3, "zeilen": ["...", "...", "..."]})
		karte.id = fall[0]
		lk.set("nacht", fall[1])
		k._karte = null
		k.ort(karte, held)
		var gehoert := {}
		var fern := 0
		var fern_seite := 0.0
		for i in 1800:     # 3 Minuten
			k._ortsklang(100.0)
			for pl in k._effekte:
				if pl.playing and pl.stream != null:
					gehoert[String(pl.stream.resource_path).get_file().get_slice("_", 0)] = true
			if k._fern.playing and k._fern.stream != null and k._fern.get_playback_position() < 0.15:
				fern += 1
				fern_seite = (AudioServer.get_bus_effect(AudioServer.get_bus_index("Fern"), 0) as AudioEffectPanner).pan
			for pl in k._effekte + [k._fern]:
				pl.stop()
		var g := gehoert.keys()
		g.sort()
		var soll: bool
		match fall:
			["deep_forest", 1.0]:
				soll = g == ["cricket"] and fern >= 1 and absf(fern_seite) >= 0.28
			["deep_forest", 0.0]:
				soll = g.is_empty() and fern >= 1     # am Tag halb so oft, in 3 Minuten mindestens einmal (2–5 Minuten Pause, das erste nach 20–60 s)
			["forest", 1.0]:
				soll = g == ["cricket", "owl"] and fern == 0
			_:
				soll = g == ["bird"] and fern == 0
		_pruef("517 %s %s" % [fall[0], "nachts" if fall[1] > 0.5 else "am Tag"], soll, "%s, fern %d (Seite %.2f)" % [g, fern, fern_seite])
	sp.queue_free()


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

	func pos_kachel(p: Vector3) -> Vector2i:
		return Vector2i(clampi(floori(p.x / 1.16), 0, breite - 1), clampi(floori(p.z / 1.16), 0, hoehe - 1))



## Ein Dorftier wie skripte/leute.gd (daten.tier, pause, kachel, ziel, nah_am_held) für _tierlaute
class _Probetier extends Node3D:
	var daten := {"tier": "ziege"}
	var pause := "Stehen"
	var kachel := Vector2i(2, 0)
	var ziel := Vector2i(-1, -1)
	var nah := false

	func nah_am_held(_t: Vector2i) -> bool:
		return nah
