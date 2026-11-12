# 348.7: rules the Kotlin MARS lacked and the port adds (Test 89.2), checked by counting the hero's attack rolls.
# Run: godot --headless --path godot -s res://tests/mars_regeln.gd   (exit code 0 = all as the SRD says)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Lohn = preload("res://regeln/lohn.gd")
const Kampfort = preload("res://kampf/kampfort.gd")
const Wucht = preload("res://regeln/trefferwucht.gd")

var tables: Dictionary
var failed := 0


func _init() -> void:
	tables = Tabellen.lade()
	# 870.5 (870a 3 A): ein Schlag je Angriff; Extra-Angriff, Doppelzug und Zweiwaffenkampf entfallen (vorher 89.2 c)
	_check("ein Schwert, Angriff", _blows(false, [], ["attack"]), 1)
	_check("zwei Waffen, Angriff", _blows(true, [], ["attack"]), 1)
	_check("Stufe 5 mit Extra-Angriff, zwei Waffen", _blows(true, ["EXTRA_ATTACK"], ["attack"]), 1)
	_check("zwei Waffen, Armbrust gezogen", _blows(true, [], ["attack"], true), 1)
	# 702 C (Chef 09.11., 06:56): angesprungen steht der Held in seinem Zug auf und handelt gleich, nur ohne Platzwechsel
	_anspringen_702()
	# 296.2: getting away as in the old fight, never from a boss; who strikes first
	_flight()
	_openings()
	# 296.2: the statuses of the old fight
	_statuses()
	# 296.2 (Test 89.2 b): never a fight without life points; what a won fight brings
	_no_life()     # der Lohn nach dem BRS: tests/lohn_870.gd (870.5)
	# 249: the halt as a blow lands (HitWeight.kt)
	_weights()
	# 348.7b (Chef 28.10., 10:43: „brennende Hände gehen ja auf eine Reihe … da dürften ja auch theoretisch dann mehr getroffen sein“)
	_row_spell("Z_FAECHER")     # 870.5: Flammenfächer, Glutkugel nach dem BRS
	_row_spell("Z_GLUT")
	# 399.2a (Chef 14:19 „Wolf mit 1 bis 2 Jungwölfen“): fällt der Wolf, fliehen die Jungwölfe, der Kampf ist gewonnen
	_pack_flees()
	# 399.2b (Chef 15:32 „Jungwölfe beißen wie im alten Spiel nur zu 50 % je Runde“)
	_cub_chance()
	# 399.2 (Tom 17:15): satt in den Kampf: +1 auf Angriff und Schaden des Helden (Battle.fedBonus), mit Zeile zu Beginn
	_fed()
	# 870.5: Grimmzahns Leibwache nicht angreifbar (werte.json „rudel“, 444), Krogg überfällt zuerst (werte.json „ueberfall“)
	_leibwache_ueberfall()
	print("MARS Regeln: %d abweichend" % failed)
	quit(1 if failed > 0 else 0)


func _check(what: String, got: int, want: int) -> void:
	if got != want:
		failed += 1
		print("FEHLER %s: %d Hiebe statt %d" % [what, got, want])
	else:
		print("gleich %s: %d" % [what, got])


## The hero's attack rolls in its first turn against wolves too tough to fall.
func _blows(two: bool, extra: Array, order: Array, drawn := false) -> int:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	sheet.skills.append_array(extra)
	if two:
		sheet["off"] = {"id": "shortsword", "de": "Kurzschwert", "en": "Shortsword", "atk": 5, "dmg": [1, 6, 0], "ranged": false, "reach": false, "two": false}
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var wolf: Dictionary
	for m in tables.monsters:
		if m.id == "wolf":
			wolf = m
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	hero.drawn = drawn
	var foes := [Mars.monster_fighter("w1", Vector2i(Mars.FRONT, 0), wolf, 999), Mars.monster_fighter("w2", Vector2i(Mars.FRONT, 1), wolf, 999)]
	var mars = Mars.new([hero], foes, tables, Wuerfel.new(7), Wuerfel.new(7))
	var heard := []
	mars.listener = func(e): heard.append(e)
	mars.start()
	for f in foes:     # 870.5: nach dem Umrechnen der Leben (BRS) wieder zu zäh zum Fallen
		f.max_hp = 999
		f.hp = 999
	assert(mars.current() == hero)
	heard.clear()
	var o: Array = order.duplicate()
	o.append("w1")
	if o[0] == "use":
		assert(mars.blocked(hero, o[1]) == null)
	mars.act(o)
	var n := 0
	for e in heard:
		if e.actor == "hero" and Mars.ist_angriff(e.roll):
			n += 1
		elif e.actor != null and e.actor != "hero" and n > 0:     # 702 C: Zeilen ohne Täter (Blutung) zählen nicht als fremder Zug
			break
	return n


## 702 C: Held gegen zwei Wölfe, die nur anspringen; jeder Zug ein Angriff. Gezählt: wie oft er aufsteht, wie oft er danach
## gleich wählen darf (am Zug, ohne Platzwechsel), Zeilen mit „Zug verloren“.
func _anspringen_702() -> void:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var wolf := _monster("wolf")
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var foes := [Mars.monster_fighter("w1", Vector2i(Mars.FRONT, 0), wolf, 999), Mars.monster_fighter("w2", Vector2i(Mars.FRONT, 1), wolf, 999)]
	var mars = Mars.new([hero], foes, tables, Wuerfel.new(11), Wuerfel.new(11))
	var heard := []
	mars.listener = func(e): heard.append(e)
	mars.start()
	var auf := 0
	var gleich := 0
	var verloren := 0
	for i in 30:
		if mars.outcome != "ONGOING":
			break
		for e in heard:
			if e.actor == "hero" and e.cue == "RISES":
				auf += 1
				if mars.current() == hero and not mars.can_swap(hero):
					gleich += 1
			if e.has("text") and ("Zug verloren" in str(e.text) or "turn lost" in str(e.text)):
				verloren += 1
		heard.clear()
		mars.act(["attack", mars.targets(hero)[0].id])
	_check_s("Anspringen 702 C: aufgestanden, gleich am Zug ohne Platzwechsel, Zug verloren", "%s %s %d" % [auf > 0, auf == gleich, verloren], "true true 0")


func _monster(id: String) -> Dictionary:
	for m in tables.monsters:
		if m.id == id:
			return m
	return {}


func _fight(sheet: Dictionary, foe_ids: Array, tape, opening := "NORMAL"):
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var foes := []
	for i in foe_ids.size():
		foes.append(Mars.monster_fighter("f%d" % i, Mars.SPOTS[i], _monster(foe_ids[i]), 999))
	return Mars.new([hero], foes, tables, Wuerfel.new(tape), Wuerfel.new(7), 0, false, opening)


func _flight() -> void:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var wolf := _monster("wolf")
	# 870.5 (870a 5 A): Probe in Prozent, Gewandtheit gegen den schnellsten Gegner; Wurf 0–99 unter der Chance gelingt
	var probe = _fight(sheet, ["wolf"], [20, 1] + _ones())
	var c: int = roundi(probe._probe_chance(probe.by_id("hero"), "gewandtheit", probe.by_id("f0"), "gewandtheit"))
	for k in [[c - 1, "FLED"], [c, "ONGOING"]]:
		var m = _fight(sheet, ["wolf"], [99, 1] + _ones())
		m.start()
		m.dice.tape = [k[0]] + _ones()
		m.dice.pos = 0
		m.act(["flee"])
		_check_s("Flucht mit %d bei %d %%" % [k[0], c], m.outcome, k[1])
	var d = _fight(sheet, ["wolf"], [99, 1] + _ones())
	d.start()
	d.by_id("hero").status["DRUNK"] = 3
	_check_s("betrunken: Flucht mit Ungunst", str(roundi(d._probe_chance(d.by_id("hero"), "gewandtheit", d.by_id("f0"), "gewandtheit", -absf(Mars.BrsKampf.nachteil())))), str(maxi(5, c - 25)))
	var b = _fight(sheet, ["hobgoblin_captain"], 1)
	_check_s("Flucht vor Grak", str(b.can_flee(b.by_id("hero"))), "false")


func _ones() -> Array:
	return range(200).map(func(_i): return 1)


func _openings() -> void:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var a = _fight(sheet, ["wolf", "wolf"], 3, "AMBUSHED")
	_check_s("Hinterhalt: Gegner zuerst", ",".join(a.order.map(func(x): return x.side)), "FOES,FOES,PARTY")
	var h = _fight(sheet, ["wolf", "wolf"], 3, "HERO_FIRST")
	_check_s("Von hinten: Held zuerst", ",".join(h.order.map(func(x): return x.side)), "PARTY,FOES,FOES")
	var heard := []
	h.listener = func(e): heard.append(e.text)
	h.start()
	h.act(["wait"])
	var still := heard.filter(func(x): return "überrascht" in x).size()
	_check_s("Von hinten: Gegner verlieren den ersten Zug", str(still), "2")


func _check_s(what: String, got: String, want: String) -> void:
	if got != want:
		failed += 1
		print("FEHLER %s: %s statt %s" % [what, got, want])
	else:
		print("gleich %s: %s" % [what, got])


func _statuses() -> void:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	# a critical hit with a blade makes bleed 3 turns (2 left after the wolf's own turn); 870.5: nach dem BRS kritisch über den
	# Testschalter (held_immer_krit), der erste Treffer zählt, der Wolf hält ihn aus
	var blutet := "kein Treffer"
	for seed in 20:
		var c = _fight(sheet, ["wolf"], [20, 1] + _ones())
		c.held_immer_krit = true
		var hits := []
		c.listener = func(e): if e.actor == "hero" and Mars.ist_krit(e.roll): hits.append(e)
		c.start()
		c.dice.rng.seed = seed
		var wf = c.by_id("f0")
		wf.max_hp = 999
		wf.hp = 999
		c.dice.tape = _ones()
		c.dice.pos = 0
		c.act(["attack", "f0"])
		if not hits.is_empty():
			blutet = str(wf.status)
			break
	_check_s("Krit mit Klinge: blutet", blutet, str({"BLEED": 2}))
	# bleeding hurts at the start of its turn (1d4 + level / 3), then counts down; the line names it
	var b = _fight(sheet, ["wolf"], [20, 1] + _ones())
	var heard := []
	b.listener = func(e): heard.append(e)
	b.by_id("f0").status["BLEED"] = 3
	b.start()
	b.act(["wait"])
	var bled: Array = heard.filter(func(e): return "verliert Blut" in e.text)
	_check_s("Blutung schadet", str(bled.map(func(e): return e.damage)), str([b._anteil(b.by_id("f0"), float(b._zw().get("schaden_anteil", {}).get("BLEED", 0.08)))]))     # 870.6: Anteil am vollen Leben (werte.json „zustaende“), massstab gibt es nicht mehr
	_check_s("Blutung zählt herunter", str(b.by_id("f0").status), str({"BLEED": 2}))
	_check_s("Zeichen im Ereignis", str(bled[0].status.get("f0", {})), str({"BLEED": 2}))
	# bleeding to death ends the fight
	var d = _fight(sheet, ["wolf"], [20, 1] + _ones())
	d.by_id("f0").status["BLEED"] = 3
	d.start()
	d.by_id("f0").hp = 1     # 870.5: nach dem Umrechnen der Leben (BRS)
	d.act(["wait"])
	_check_s("Verblutet: Sieg", d.outcome, "WON")
	# a stunned hero loses the turn, and is not stunned again for three turns
	var s = _fight(sheet, ["wolf"], [20, 1] + _ones())
	var lines := []
	s.listener = func(e): lines.append(e.text)
	var hero = s.by_id("hero")
	hero.status["STUN"] = 1
	hero.stun_guard = 3
	s.start()
	_check_s("Betäubt: Zug verloren", str(lines.filter(func(x): return "kann nicht handeln" in x).size()), "1")
	_check_s("Betäubt: dann wieder dran", str(s.current() == hero and s.outcome == "ONGOING"), "true")
	_check_s("Betäubt: Schutz vor neuer Betäubung", str(s._inflict(hero, "STUN", 1)), "false")
	# slowed and weakened hit less often, weakened deals less (870.6: werte.json „zustaende“)
	var w = _fight(sheet, ["wolf"], 1)
	var foe = w.by_id("f0")
	foe.status["SLOW"] = 2
	foe.status["WEAK"] = 2
	var zt: Dictionary = w._zw().get("treffer", {})     # 870.6: Prozentpunkte aus werte.json „zustaende“ „treffer“
	_check_s("Verlangsamt und geschwächt: Trefferchance", str(w._treffer_mod(foe)), str(float(zt.get("SLOW", -10)) + float(zt.get("WEAK", -10))))
	_check_s("Geschwächt: Schaden", str(w._schaden_faktor(foe)), str(float(w._zw().get("schaden_faktor", {}).get("WEAK", 0.8))))
	# a foe immune to it takes none; a boss shakes off a stun half the time
	var i = _fight(sheet, ["wolf"], 1)
	var im = i.by_id("f0")
	im.monster = im.monster.duplicate()
	im.monster["immune"] = ["BLEED"]
	_check_s("Immun gegen Blutung", str(i._inflict(im, "BLEED", 3)), "false")
	var g = _fight(sheet, ["hobgoblin_captain"], 1)
	_tape(g, [0])
	_check_s("Boss schüttelt Betäubung ab", str(g._inflict(g.by_id("f0"), "STUN", 1)), "false")
	# a dwarf resists poison half the time, a save above the DC resists it
	var dw: Dictionary = sheet.duplicate(true)
	dw["race"] = "DWARF"
	var z = _fight(dw, ["wolf"], 1)
	_tape(z, [0])
	_check_s("Zwerg widersteht Gift", str(z._inflict(z.by_id("hero"), "POISON", 3)), "false")
	var sv = _fight(sheet, ["wolf"], 1)
	_tape(sv, [0])     # 870.5: Abwehrprobe in Prozent, kleiner Wurf gelingt
	_check_s("Abwehrprobe gelingt", str(sv._inflict(sv.by_id("hero"), "POISON", 3, ["zaehigkeit", 11])), "false")
	var fl = _fight(sheet, ["wolf"], 1)
	_tape(fl, [99, 999])
	_check_s("Abwehrprobe misslingt", str(fl._inflict(fl.by_id("hero"), "POISON", 3, ["zaehigkeit", 11])), "true")


## The next numbers of [m]'s dice, from here on.
func _tape(m, numbers: Array) -> void:
	m.dice.tape = numbers
	m.dice.pos = 0


func _no_life() -> void:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var m = _fight(sheet, ["wolf", "wolf"], 1)
	m.all[0].hp = 0
	_check_s("Held ohne LP darf nicht kämpfen", str(Mars.can_fight([m.all[0]])), "false")
	m.start()
	_check_s("Held ohne LP: Kampf endet sofort", m.outcome, "LOST")
	var k = Kampfort.new()
	_check_s("Kampfort nimmt Held ohne LP nicht", str(k.setup([m.all[0]], m.all.slice(1), tables, {}, Callable())), "false")
	k.free()
	_check_s("Held mit LP darf kämpfen", str(Mars.can_fight([_fight(sheet, ["wolf"], 1).all[0]])), "true")


func _weights() -> void:
	_check_s("Wucht: gewöhnlich", Wucht.of(false, 3, 11), "NORMAL")
	_check_s("Wucht: ein Drittel ist hart", Wucht.of(false, 4, 12), "HARD")
	_check_s("Wucht: kritisch vor hart", Wucht.of(true, 9, 12), "CRIT")
	_check_s("Wucht: tödlich vor kritisch", Wucht.of(true, 9, 12, true), "KILL")
	_check_s("Wucht: ohne LP-Höchstwert nie hart", Wucht.of(false, 5, 0), "NORMAL")
	_check_s("Wucht: Ruck nur kritisch und tödlich", "%s %s %s" % [Wucht.jolt_dp("HARD"), Wucht.jolt_dp("CRIT"), Wucht.jolt_dp("KILL")], "0.0 4.0 7.0")
	_check_s("Wucht: Ruck hin und zurück", "%.2f %.2f %.2f" % [Wucht.jolt(0.0), Wucht.jolt(0.5), Wucht.jolt(1.0)], "0.00 1.00 0.00")


## 348.7b: a row spell strikes every standing foe in the target's row and none in the other row (Skirmish.kt:726); 870.5 nach dem
## BRS: ein Schlag der Schule je Gegner der Reihe (Evokation 40 kennt Flammenfächer und Glutkugel)
func _row_spell(spell: String) -> void:
	var sheet: Dictionary = tables.probe.WIZARD.hero.hero.duplicate(true)
	sheet["brs_fert"] = {"Evokation": 40}
	sheet.level = maxi(int(sheet.level), 5)
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var wolf: Dictionary     # 870.5: Goblins (Wölfe fliehen vor Feuer, Gegenwirkung)
	for m in tables.monsters:
		if m.id == "goblin":
			wolf = m
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var foes := [Mars.monster_fighter("w1", Vector2i(Mars.FRONT, 0), wolf, 999), Mars.monster_fighter("w2", Vector2i(Mars.FRONT, 1), wolf, 999),
		Mars.monster_fighter("w3", Vector2i(Mars.BACK, 0), wolf, 999)]
	var mars = Mars.new([hero], foes, tables, Wuerfel.new(7), Wuerfel.new(7))
	var heard := []
	mars.listener = func(e): heard.append(e)
	mars.start()
	for w in foes:     # 870.5: nach dem Umrechnen der Leben (BRS) zu zäh zum Fallen
		w.max_hp = 9999
		w.hp = 9999
	assert(mars.current() == hero)
	var why = mars.blocked(hero, spell)
	if why != null:
		failed += 1
		print("FEHLER %s gesperrt: %s" % [spell, why])
		return
	# die Wölfe ziehen vor dem Helden und tauschen dabei Plätze: Ziel ist ein Wolf, dessen Reihe zwei Stehende hat
	var t = null
	var want := []
	for w in foes:
		var row := foes.filter(func(x): return x.standing() and x.place.x == w.place.x).map(func(x): return x.id)
		if row.size() >= 2:
			t = w
			want = row
			break
	if t == null:
		failed += 1
		print("FEHLER %s: keine Reihe mit zwei stehenden Wölfen" % spell)
		return
	want.sort()
	heard.clear()
	mars.act(["use", spell, t.id])
	var hit := {}
	for e in heard:
		if e.actor == "hero" and Mars.ist_angriff(e.roll):
			hit[e.target] = true
		elif e.actor != "hero" and not hit.is_empty():
			break
	var keys := hit.keys()
	keys.sort()
	var got := ",".join(PackedStringArray(keys))
	var soll := ",".join(PackedStringArray(want))
	if got != soll:
		failed += 1
		print("FEHLER %s auf %s: Schläge %s statt %s (ganze Reihe, die andere nicht)" % [spell, t.id, got, soll])
	else:
		print("gleich %s auf %s: Schläge %s (ganze Reihe, die andere nicht)" % [spell, t.id, got])


## 399.2a: the wolf with its young (aufruf.gd rudel): they follow it, flee when it falls, the fight is won; the reward counts
## them as its pack (lohn.gd, werte.json erfahrung_anteil 0,3 each, 870.5)
func _pack_flees() -> void:
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	var Aufruf = load("res://kampf/aufruf.gd")
	var foes: Array = Aufruf.rudel(monsters, Wuerfel.new(3))
	var cubs := foes.filter(func(f): return f.follows == "wolf1")
	if foes[0].id != "wolf1" or cubs.size() < 1 or cubs.size() > 2 or cubs.any(func(c): return String(c.monster.get("rudel", "")) != "Jungwolf" or String(c.monster.get("anfuehrer", "")) != "wolf"):
		failed += 1
		print("FEHLER Rudel: Aufstellung %s" % [foes.map(func(f): return [f.id, f.follows, f.monster.get("rudel", ""), f.max_hp])])
		return
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var mars = Mars.new([hero], foes, tables, Wuerfel.new(7), Wuerfel.new(7))
	var heard := []
	mars.listener = func(e): heard.append(e)
	mars.start()
	var wolf = mars.find("wolf1")
	# die Wölfe tauschen Plätze (Einkreisen), der Wolf steht oft hinten: der Fall direkt, wie ein tödlicher Treffer
	mars._hurt(wolf, wolf.hp, "hero", "Probe: Wolf fällt")
	var names := foes.map(func(f): return f.name(0))
	var flohen := heard.filter(func(e): return e.cue == "FOE_FLEES").size()
	var ok: bool = not wolf.standing() and cubs.all(func(c): return c.fled and c.hp > 0) and flohen == cubs.size() and mars.outcome == "WON"
	if ok:
		var r: Dictionary = Lohn.reward(mars, {}, Wuerfel.new(1))     # 870.5: BRS, je Jungwolf 0,3 (werte.json)
		var soll := roundi(Brs.erfahrung(int(hero.level()), "wolf") * (1.0 + 0.3 * cubs.size()))
		ok = int(r.xp) == soll
		ok = ok and names[0] == "Wolf" and (names[1] == "Jungwolf" if cubs.size() == 1 else names[1] == "Jungwolf 1")
		print(("gleich" if ok else "FEHLER") + " Rudel: Wolf fällt, %d Jungwölfe fliehen, gewonnen, Erfahrung %d (soll %d), Namen %s" % [cubs.size(), int(r.xp), soll, names])
	else:
		print("FEHLER Rudel: Wolf steht %s, geflohen %s, Meldungen %d, Ausgang %s" % [wolf.standing(), cubs.map(func(c): return c.fled), flohen, mars.outcome])
	if not ok:
		failed += 1


## 399.2b: a young wolf bites in about half of its turns (Packs.kt cubs chance 0,5), otherwise it growls (cue GROWLS)
func _cub_chance() -> void:
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	var Aufruf = load("res://kampf/aufruf.gd")
	var foes: Array = Aufruf.rudel(monsters, Wuerfel.new(3))
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 9999, sheet.second, skills)
	var mars = Mars.new([hero], foes, tables, Wuerfel.new(11), Wuerfel.new(7))
	var heard := []
	mars.listener = func(e): heard.append(e)
	mars.start()
	var cub = mars.find(foes[1].id)
	var turns := 0
	var growls := 0
	var angesagt_geknurrt := 0
	var stumm := 0
	for i in 400:
		mars.intents.erase(cub.id)
		mars.announce(cub)
		var eff: String = String(mars.intents[cub.id][0].effect)
		if eff == "CIRCLE":
			continue
		var knurrt := eff == "GROWL"
		heard.clear()
		hero.hp = 9999
		mars._foe_turn(cub, Callable())
		turns += 1
		var g := heard.filter(func(e): return e.cue == "GROWLS" and e.actor == cub.id).size()
		growls += g
		# Homer [399.2b.knurrt]: eine der drei Zeilen mit dem Namen
		stumm += heard.filter(func(e): return e.cue == "GROWLS" and not String(e.text).begins_with(cub.name(mars.lang))).size()
		# kündigt keinen Biss an, wenn er nur knurrt: keine Ansage, kein Angriffswurf
		if knurrt and (g != 1 or heard.any(func(e): return e.actor == cub.id and e.roll != null)):
			angesagt_geknurrt += 1
	var share := float(growls) / maxi(turns, 1)
	var ok := turns >= 100 and share > 0.4 and share < 0.6 and angesagt_geknurrt == 0 and stumm == 0
	print(("gleich" if ok else "FEHLER") + " Jungwolf knurrt statt zu beißen: %d von %d Zügen (%.0f %%, soll etwa 50), Knurren mit Biss %d, ohne Zeile %d" % [growls, turns, share * 100.0, angesagt_geknurrt, stumm])
	if not ok:
		failed += 1


func _fed() -> void:
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var loss := []
	var bonus := []
	var said := []
	for fed in [false, true]:
		var m = _fight(sheet, ["wolf"], [15, 4, 4, 4, 4])
		m.fed = fed
		var heard := []
		m.listener = func(e): heard.append(e)
		m.start()
		_tape(m, [15, 4, 4, 4, 4])
		var foe = m.all.filter(func(f): return f.side == "FOES")[0]
		foe.max_hp = 999
		foe.hp = 999
		var hp0: int = foe.hp
		said.append(heard.any(func(e): return String(e.text).contains("gestärkt") or String(e.text).contains("well fed")))
		var att := []
		for seed in 20:     # 870.5: nach dem BRS, derselbe Wurf mit und ohne Sättigung, der erste Treffer zählt
			m.dice.rng.seed = seed
			heard.clear()
			m._weapon_attack(m.lead(), foe)
			att = heard.filter(func(e): return Mars.ist_angriff(e.roll) and e.roll[4])
			if not att.is_empty():
				break
		loss.append(hp0 - foe.hp)
		bonus.append(int(att[-1].roll[3]) if not att.is_empty() else -99)     # Trefferchance in Prozent
	var ok: bool = loss[1] > loss[0] and bonus[1] > bonus[0] and said == [false, true]     # 870.5: im Maß des BRS
	print(("gleich" if ok else "FEHLER") + " satt: Schaden %s, Angriff %s, Zeile %s" % [loss, bonus, said])
	if not ok:
		failed += 1


func _leibwache_ueberfall() -> void:
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	var Aufruf = load("res://kampf/aufruf.gd")
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var mars = Mars.new([hero], Aufruf.gegner("GRIMM", monsters, Wuerfel.new(3)), tables, Wuerfel.new(7), Wuerfel.new(7))
	var ziele: Array = mars.feinde(hero).map(func(f): return f.id)
	var ok: bool = ziele.size() == 1 and mars.find(ziele[0]).boss()
	print(("gleich" if ok else "FEHLER") + " Leibwache nicht angreifbar: Ziele %s" % [ziele])
	if not ok:
		failed += 1
	var held2 := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var m2 = Mars.new([held2], Aufruf.gegner("KROGG", monsters, Wuerfel.new(3)), tables, Wuerfel.new(7), Wuerfel.new(7))
	ok = m2.order[0].side == "FOES"
	print(("gleich" if ok else "FEHLER") + " Krogg überfällt zuerst: %s" % [m2.order.map(func(f): return f.id)])
	if not ok:
		failed += 1
