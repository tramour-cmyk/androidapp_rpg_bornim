# 1068 (1048 A, H, Chef 12.11., 20:05): jeder große Schlag der Gegner hat den Ring. Welche Absicht ihn hat und wie hart sie dann trifft,
# steht in werte.json „absichten“ „ring“ (Kennung: Schadensfaktor; 1049: kein Zweig in mars.gd). Geprüft je Eintrag:
# (1) die Absicht trägt den Ring (mars.gd I_<KENNUNG>.ring), kleine Schläge (stab, slash, bite, claw) nicht;
# (2) gut = heutiger Schaden (Faktor × halber Schaden), verfehlt = Faktor × Schaden, perfekt = kein Schaden; heute ist der Schaden
#     derselbe Schlag ohne Ring (Faktor 1, kein Ring), bei gleichem Würfel;
# (3) der Ring wird im Kampf wirklich gestellt (react bekommt die Absicht), an einer Art, die sie ansagt;
# (4) Chef 23.11., 11:27 (Archiv: „Anspringen mit Ring nur Leitwolf und Grimmzahn“; Leibwache Sokrates 13:06): Jungwölfe und
#     Grimmzahns Leibwache springen ohne Ring wie vor 1068 (Faktor 1, kein Ring gestellt); werte.json „absichten“ „ring_ohne“
#     (Absicht: Rudelnamen), kein Zweig in mars.gd.
# Run: godot --headless --path godot -s res://tests/ringschlag_1068.gd   (Exit 0 = grün)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const BrsKampf = preload("res://regeln/brs_kampf.gd")
const KLEIN := ["stab", "slash", "bite", "claw"]
## 1048 A, H: diese großen Schläge brauchen den Ring; neu Anspringen und Gift sammeln treffen doppelt (gut = heute). Der Prankenhieb
## Krogg kommt mit 1603 und erbt das Feld (jeder weitere Eintrag in werte.json wird ebenso geprüft)
const GROSS := {"heavy": 1.0, "web": 1.0, "breakthrough": 1.0, "pounce": 2.0, "venom": 2.0}

var tab: Dictionary
var fehler := 0


func _initialize() -> void:
	tab = Tabellen.lade()
	var R: Dictionary = BrsKampf.w().get("absichten", {}).get("ring", {})
	var alle := GROSS.duplicate()
	for id in GROSS:
		if not R.has(id):
			_fehl("%s: kein Eintrag in werte.json absichten.ring" % id)
		elif float(R[id]) != GROSS[id]:
			_fehl("%s: Faktor %s, soll %s" % [id, R[id], GROSS[id]])
	for id in R:
		if not alle.has(id):
			alle[id] = float(R[id])
	for id in alle:
		if String(id).begins_with("_"):
			continue
		var art := _art_mit(String(id))
		if art == "":
			print("  %s: keine Art sagt die Absicht an (erbt das Feld, sobald es sie gibt)" % id)
			continue
		var m = _mars(art, 1)
		var it = m.get("I_" + String(id).to_upper())
		if it == null:
			_fehl("%s: keine Absicht I_%s in mars.gd" % [id, String(id).to_upper()])
			continue
		if not bool(it.ring):
			_fehl("%s: ohne Ring" % id)
		_schaden(String(id), art, float(alle[id]))
		_gestellt(String(id), art)
	var m0 = _mars("goblin", 1)
	for id in KLEIN:
		if bool(m0.get("I_" + id.to_upper()).ring):
			_fehl("%s: kleiner Schlag mit Ring" % id)
	_jungwolf()
	print("RINGSCHLAG1068 %s, %d Fehler" % ["grün" if fehler == 0 else "rot", fehler])
	quit(1 if fehler > 0 else 0)


func _fehl(s: String) -> void:
	fehler += 1
	print("FEHLER " + s)


## die erste Art in „je_art“, die [id] ansagt
func _art_mit(id: String) -> String:
	var T: Dictionary = BrsKampf.w().get("absichten", {}).get("je_art", {})
	for art in T:
		if T[art] is Array and String(art) != "_sonst":
			for x in T[art]:
				if String(x[0]) == id:
					return String(art)
	return ""


func _mars(art: String, s: int):
	var monsters := {}
	for mm in tab.monsters:
		monsters[mm.id] = mm
	var skills := {}
	for sk in tab.skills:
		skills[sk.id] = sk
	var mo: Dictionary = monsters[art]
	var foe = Mars.monster_fighter("foe", Vector2i(Mars.FRONT, 0), mo, 999)
	var hero = load("res://kampf/aufruf.gd").new()._kaempfer("hero", BrsHeld.fuer_spiel("Alrik", "Mensch", "Wachsoldat"), -1, Vector2i(Mars.FRONT, 0), skills)
	var m = Mars.new([hero], [foe], tab, Wuerfel.new(s), Wuerfel.new(s + 281), 0, false)
	hero.max_hp = 9999     # nach Mars.new, das das Leben aus dem Blatt setzt; so begrenzt kein Rest den Verlust
	hero.hp = 9999
	return m


## Verlust des Helden durch einen Schlag [intent] mit Ergebnis [re], Würfel [s]
func _verlust(art: String, s: int, intent_id: String, re: String, ohne_ring: bool) -> int:
	var m = _mars(art, s)
	var it: Dictionary = m.get("I_" + intent_id.to_upper())
	if ohne_ring:
		it = it.duplicate()
		it.ring = false
		it.erase("ring_schaden")
	var hero = m.find("hero")
	var foe = m.find("foe")
	var vor: int = hero.hp
	m._strike(foe, hero, it, re)
	return vor - hero.hp


func _schaden(id: String, art: String, f: float) -> void:
	var n := 0
	for s in range(1, 200):
		var heute := _verlust(art, s, id, Mars.NONE, true)
		if heute <= 0:
			continue
		n += 1
		var gut := _verlust(art, s, id, Mars.GOOD, false)
		var daneben := _verlust(art, s, id, Mars.NONE, false)
		var perfekt := _verlust(art, s, id, Mars.PERFECT, false)
		var soll_gut := int(roundi(heute * f) * 0.5) if f != 1.0 else int(heute * 0.5)
		var soll_daneben := roundi(heute * f)
		if f != 1.0 and gut != heute:
			_fehl("%s Würfel %d: gut %d, heute %d (gut soll = heute)" % [id, s, gut, heute])
			return
		if f == 1.0 and gut != soll_gut:
			_fehl("%s Würfel %d: gut %d, soll %d" % [id, s, gut, soll_gut])
			return
		if daneben != soll_daneben:
			_fehl("%s Würfel %d: verfehlt %d, soll %d (Faktor %.1f × heute %d)" % [id, s, daneben, soll_daneben, f, heute])
			return
		if perfekt != 0:
			_fehl("%s Würfel %d: perfekt %d, soll 0" % [id, s, perfekt])
			return
		if n >= 20:
			break
	if n == 0:
		_fehl("%s: kein Treffer in 200 Würfen" % id)
	else:
		print("  %s (%s, Faktor %.1f): %d Treffer geprüft" % [id, art, f, n])


## die Absicht angesagt, dann der Zug des Gegners (_foe_turn): fragt er den Ring? Durchbrechen trifft nur hinten, darum steht der
## Held dort allein (kein Vorderer zum Wegstoßen)
func _gestellt(id: String, art: String) -> void:
	var m = _mars(art, 1)
	var gestellt := [false]
	var react := func(_t, intent):
		if String(intent.id) == id:
			gestellt[0] = true
		return Mars.GOOD
	m.start(react)
	var hero = m.find("hero")
	var foe = m.find("foe")
	if id == "breakthrough":
		hero.place = Vector2i(Mars.BACK, 0)
	m.intents[foe.id] = [m.get("I_" + id.to_upper()), ["hero"]]
	m.aim_spot[foe.id] = hero.place
	m._foe_turn(foe, react)
	if not gestellt[0]:
		_fehl("%s: im Zug von %s kein Ring gestellt" % [id, art])


## (4) Wolf mit Jungwölfen (aufruf.gd rudel) und Grimmzahn mit Leibwache: Leittier springt mit Ring, wer ihm folgt, ohne
func _jungwolf() -> void:
	for gruppe in ["RUDEL", "GRIMM"]:
		_folger(gruppe)


func _folger(gruppe: String) -> void:
	var monsters := {}
	for mm in tab.monsters:
		monsters[mm.id] = mm
	var skills := {}
	for sk in tab.skills:
		skills[sk.id] = sk
	var geprueft := {"leit": false, "jung": false}
	for s in range(1, 40):
		var foes: Array = load("res://kampf/aufruf.gd").gegner(gruppe, monsters, Wuerfel.new(s))
		var hero = load("res://kampf/aufruf.gd").new()._kaempfer("hero", BrsHeld.fuer_spiel("Alrik", "Mensch", "Wachsoldat"), -1, Vector2i(Mars.FRONT, 0), skills)
		var m = Mars.new([hero], foes, tab, Wuerfel.new(s), Wuerfel.new(s + 281), 0, false)
		hero.max_hp = 9999
		hero.hp = 9999
		var gestellt := []
		var react := func(_t, intent):
			gestellt.append(intent)
			return Mars.GOOD
		m.start(react)
		for f in foes:
			var jung: bool = f.follows != ""
			for i in 30:
				m.announce(f)
				if String(m.intents[f.id][0].id) == "pounce":
					break
			var it: Dictionary = m.intents[f.id][0]
			if String(it.id) != "pounce":
				continue
			if jung and bool(it.get("ring", false)):
				_fehl("%s Würfel %d: %s (folgt) springt mit Ring" % [gruppe, s, f.id])
			if jung and float(it.get("ring_schaden", 1.0)) != 1.0:
				_fehl("%s Würfel %d: %s (folgt) springt mit Faktor %s, soll 1 (wie vor 1068)" % [gruppe, s, f.id, it.ring_schaden])
			if not jung and not bool(it.get("ring", false)):
				_fehl("%s Würfel %d: Leittier %s ohne Ring" % [gruppe, s, f.id])
			gestellt.clear()
			m.aim_spot[f.id] = hero.place
			m._foe_turn(f, react)
			var mit: bool = gestellt.any(func(x): return String(x.id) == "pounce")
			if jung and mit:
				_fehl("%s Würfel %d: bei %s (folgt) Ring gestellt" % [gruppe, s, f.id])
			if not jung and not mit:
				_fehl("%s Würfel %d: beim Leittier %s kein Ring gestellt" % [gruppe, s, f.id])
			geprueft["jung" if jung else "leit"] = true
		if geprueft.leit and geprueft.jung:
			break
	if not (geprueft.leit and geprueft.jung):
		_fehl("%s: kein Anspringen gefunden %s" % [gruppe, geprueft])
	else:
		print("  pounce %s: Leittier mit Ring, wer folgt ohne: geprüft" % gruppe)
