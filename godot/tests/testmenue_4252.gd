extends SceneTree
# 425 (Chef 01.11., 11:20: „425 passt inklusive der Voten zu den Nummern 1 bis 8“; jetzt 2, 3, 5, 8): ohne Bild. Im Reiter „Test“
# Tag/Nacht (an die Welt), Fackel an und aus (Nebenhand, Tasche), Unbeachtet, Rettung, Kritisch; in MARS misslingt der Rettungswurf
# eines Gegners trotz der 20 und der Held trifft mit der 2 kritisch (Meldung mit „krit“, kampfort.gd krit); aus wie bisher. In der
# Welt: Tag/Nacht sofort mit Uhr, Unbeachtet laesst den Kampf am Waldrand aus. Nr. 5 (Monster neben den Helden holen) wartet auf
# Monster auf der Gebietskarte. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/testmenue_4252.gd

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Kampfort = preload("res://kampf/kampfort.gd")

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])
	else: print("gut ", was)

func knopf(n: Node, wort: String) -> Zeichenknopf:
	for b in n.find_children("*", "Zeichenknopf", true, false):
		if b.is_visible_in_tree() and String(b.wort) == wort: return b
	print("FEHLER kein Zeichen ", wort)
	fehler += 1
	return null

func druecke(m: Menue, wort: String) -> void:
	var b := knopf(m, wort)
	if b: b.tat.call()
	await process_frame

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var vorher := Testmodus.ist_an()
	if not vorher: Testmodus.umschalten()
	_menue()
	await process_frame
	await _menue_druck()
	_mars()
	await _welt()
	Testmodus.unbeachtet = false; Testmodus.rettung_aus = false; Testmodus.krit_immer = false
	if Testmodus.an != vorher: Testmodus.umschalten()
	print("TESTMENUE_4252 %d Fehler" % fehler)
	quit(1 if fehler else 0)

var m: Menue
var hw: Heldwerte
var z: Zustand
var taten := []

func _menue() -> void:
	z = Zustand.new()
	hw = Heldwerte.erschaffe("Mira", "HUMAN", "FIGHTER", {}, z.neue_uid)
	m = Menue.new(hw, z)
	root.add_child(m)
	m.test.connect(func(w, mit): taten.append([w, mit]))
	m.reiter = "test"

func _menue_druck() -> void:
	m.baue()
	await process_frame
	var tn := knopf(m, "Tag/Nacht")
	pruefe("Tag/Nacht zeigt Tag mit Sonne", [tn.wert, tn.zeichen] if tn else [], ["Tag", "SUN"])
	m.nacht = true
	m.baue()
	await process_frame
	tn = knopf(m, "Tag/Nacht")
	pruefe("Tag/Nacht zeigt Nacht mit Mond", [tn.wert, tn.zeichen] if tn else [], ["Nacht", "MOON"])
	await druecke(m, "Tag/Nacht")
	pruefe("Tag/Nacht an die Welt", taten.map(func(x): return x[0]), ["tagnacht"])
	# Fackel: ohne Fackel in der Tasche eine neue in die Nebenhand, dann zurueck in die Tasche, dann dieselbe wieder in die Hand
	z.beutel = z.beutel.filter(func(g): return String(g["base"]) != "torch")
	var neben := func() -> String: return String(hw.ding("OFF_HAND")["base"]) if hw.ding("OFF_HAND") != null else ""
	var fackeln := func() -> int: return z.beutel.filter(func(g): return String(g["base"]) == "torch").size()
	var vor_neben: String = neben.call()
	await druecke(m, "Fackel")
	pruefe("Fackel an: Nebenhand, Tasche", [neben.call(), fackeln.call(), knopf(m, "Fackel").wert], ["torch", 0, "an"])
	if vor_neben != "": pruefe("was die Hand hielt, in der Tasche", z.beutel.any(func(g): return String(g["base"]) == vor_neben), true)
	var uid := int(hw.ding("OFF_HAND")["uid"]) if hw.ding("OFF_HAND") != null else -1
	await druecke(m, "Fackel")
	pruefe("Fackel aus: Tasche", [neben.call(), fackeln.call(), knopf(m, "Fackel").wert], ["", 1, "aus"])
	await druecke(m, "Fackel")
	pruefe("Fackel wieder an: dieselbe", [neben.call(), fackeln.call(), int(hw.ding("OFF_HAND")["uid"]) if hw.ding("OFF_HAND") != null else -2], ["torch", 0, uid])
	# Schalter
	var wert := func(n: String) -> bool:
		match n:
			"Unbeachtet": return Testmodus.unbeachtet
			"Rettung": return Testmodus.rettung_aus
		return Testmodus.krit_immer
	for s in [["Unbeachtet", "an"], ["Rettung", "misslingt"], ["Kritisch", "immer"]]:
		pruefe(s[0] + " aus", [wert.call(s[0]), knopf(m, s[0]).an], [false, false])
		await druecke(m, s[0])
		pruefe(s[0] + " an", [wert.call(s[0]), knopf(m, s[0]).an, knopf(m, s[0]).wert], [true, true, s[1]])
	pruefe("Unbeachtet gilt nur im Testmodus", Testmodus.unbeachtet_gilt(), true)
	m.queue_free()

func _kampf(cls: String, tape: Array) -> Array:
	var tables: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var sheet: Dictionary = tables.probe[cls].hero.hero.duplicate(true)
	var skills := {}
	for s in tables.skills: skills[s.id] = s
	var wolf: Dictionary
	for mo in tables.monsters:
		if mo.id == "wolf": wolf = mo
	var held := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var w := Mars.monster_fighter("w1", Vector2i(Mars.FRONT, 0), wolf, 999)
	var mars = Mars.new([held], [w], tables, Wuerfel.new(7), Wuerfel.new(7))
	mars.dice.tape = tape   # erst nach der Initiative: die Wuerfel des Schlags
	mars.dice.pos = 0
	var gehoert := []
	mars.listener = func(e): gehoert.append(e)
	return [mars, held, w, gehoert]

func _letzte(gehoert: Array, art: String):
	for i in range(gehoert.size() - 1, -1, -1):
		if gehoert[i].roll != null and gehoert[i].roll[0] == art: return gehoert[i]
	return null

func _mars() -> void:
	var zweien := []
	for i in 40: zweien.append(2)
	# Kritisch: mit der 2 trifft der Kaempfer den Wolf (RK 13) nicht; erzwungen trifft er kritisch, die Meldung traegt „krit“
	for an in [false, true]:
		var k := _kampf("FIGHTER", zweien)
		k[0].hero_crits_always = an
		k[0]._weapon_attack(k[1], k[2])
		var e = _letzte(k[3], "ATTACK")
		pruefe("Kritisch %s: Wurf, trifft, krit" % an, [e.roll[1], e.roll[4], Kampfort.krit(e)] if e else [], [2, an, an])
		if an and e: pruefe("Kritisch: doppelte Wuerfel (2 W8 + 3)", e.damage, 2 + 2 + 3)
	# eine 1 bleibt daneben
	var k1 := _kampf("FIGHTER", [1, 2, 2])
	k1[0].hero_crits_always = true
	k1[0]._weapon_attack(k1[1], k1[2])
	var e1 = _letzte(k1[3], "ATTACK")
	pruefe("Kritisch: die 1 bleibt daneben", [e1.roll[4], Kampfort.krit(e1)] if e1 else [], [false, false])
	# Rettung: der Wolf rettet sich mit der 20 vor dem Feuerpfeil-Muster (_save_spell, ganz oder nichts); erzwungen nicht
	for an in [false, true]:
		var k := _kampf("WIZARD", [20, 20, 20])
		k[0].foes_fail_saves = an
		k[0]._save_spell(k[1], k[2], 7, false)
		var e = _letzte(k[3], "SAVE")
		pruefe("Rettung %s: gerettet, Schaden" % an, [e.roll[4], e.damage] if e else [], [not an, 7 if an else 0])
	# der Held rettet sich weiter selbst (nur Gegner verfehlen)
	var kh := _kampf("WIZARD", [20, 20, 20])
	kh[0].foes_fail_saves = true
	kh[0]._save_spell(kh[1], kh[1], 7, false)
	var eh = _letzte(kh[3], "SAVE")
	pruefe("Rettung: der Held rettet sich weiter", eh.roll[4] if eh else null, true)

func _welt() -> void:
	if not ResourceLoader.exists("res://spiel.tscn"): return
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	if spiel.held == null: fehler += 1; print("FEHLER Spiel ohne Held"); return
	# Tag/Nacht sofort: Licht ohne Uebergang, Uhr 23 bzw. 12 Uhr
	var war_nacht: bool = spiel.licht.ziel > 0.5
	await spiel.test_tat("tagnacht", [])
	pruefe("Tag/Nacht sofort", [spiel.licht.nacht, spiel.licht.ziel, spiel.zustand.minuten], [0.0 if war_nacht else 1.0, 0.0 if war_nacht else 1.0, 12 * 60 if war_nacht else 23 * 60])
	await spiel.test_tat("tagnacht", [])
	pruefe("Tag/Nacht zurueck", spiel.licht.nacht, 1.0 if war_nacht else 0.0)
	# Unbeachtet: der Weg in den Wald bringt keinen Kampf
	var a := {}
	for r in spiel.karte.daten.get("ausgaenge", []):
		if String(r["ziel"]["karte"]) in spiel.WALD: a = r
	if a.is_empty(): print("Wald: kein Ausgang auf ", spiel.karte.id)
	else:
		Testmodus.unbeachtet = true
		await spiel.geh_hinaus(a)
		pruefe("Unbeachtet: kein Kampf am Waldrand", [spiel.kampf == null, spiel.visible], [true, true])
	spiel.queue_free()
	await process_frame
