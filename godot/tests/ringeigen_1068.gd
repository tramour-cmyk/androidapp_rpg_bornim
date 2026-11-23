# 1068 D (1048 D, Chef 12.11., 20:05): Ring beim eigenen Schlag, Schuss, Zauber; nur perfekt zählt, die Automatik nie perfekt.
# Faktor in werte.json „absichten“ „ring_eigen“ (Rechnung ring_1068.gd TEIL=D: f = 1,5). Geprüft:
# (1) werte.json trägt ring_eigen = 1,5;
# (2) Angriff mit der Waffe, Funkenpfeil (Schaden) und Wundsegen (Heilung) einer selbst gesteuerten Figur fragen den Ring einmal
#     (react bekommt die Absicht „eigen“ und die Figur selbst); perfekt = Wirkung × f, gut und verfehlt = wie ohne Ring, bei
#     gleichem Würfel;
# (3) die Meldung des Treffers trägt bei perfekt „ring_eigen“ (schaden, heilung) für die Anzeige [1069.ring.*], sonst nicht;
# (4) die Automatik fragt keinen eigenen Ring; Abwehr (wait) und Bannschild ohne Schaden und Heilung auch nicht.
# Run: godot --headless --path godot -s res://tests/ringeigen_1068.gd   (Exit 0 = grün)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const BrsKampf = preload("res://regeln/brs_kampf.gd")
const F := 1.5

var tab: Dictionary
var skills := {}
var fehler := 0


func _initialize() -> void:
	tab = Tabellen.lade()
	for sk in tab.skills:
		skills[sk.id] = sk
	var f := float(BrsKampf.w().get("absichten", {}).get("ring_eigen", 0.0))
	if f != F:
		_fehl("werte.json absichten.ring_eigen = %s, soll %s" % [f, F])
	_pruefe("Waffe", "Wachsoldat", ["attack", "foe"], "schaden")
	_pruefe("Funkenpfeil", "Zauberlehrling", ["use", "Z_FUNKEN", "foe"], "schaden")
	_pruefe("Wundsegen", "", ["use", "Z_WUND", "hero"], "heilung")
	_ohne_ring("Automatik", "Wachsoldat", ["attack", "foe"], true)
	_ohne_ring("Abwehr", "Wachsoldat", ["wait"], false)
	print("RINGEIGEN1068 %s, %d Fehler" % ["grün" if fehler == 0 else "rot", fehler])
	quit(1 if fehler > 0 else 0)


func _fehl(s: String) -> void:
	fehler += 1
	print("FEHLER " + s)


## Herkunft, die den Zauber [z] kennt
func _herkunft_mit(z: String) -> String:
	for k in ["Wachsoldat", "Zauberlehrling", "Herumtreiber", "Klosterschüler"]:
		var m = _mars(k, 1, false)
		if z in m.find("hero").zauber:
			return k
	return ""


func _mars(k: String, s: int, auto: bool):
	var monsters := {}
	for mm in tab.monsters:
		monsters[mm.id] = mm
	var foe = Mars.monster_fighter("foe", Vector2i(Mars.FRONT, 0), monsters["goblin"], 999)
	var hero = load("res://kampf/aufruf.gd").new()._kaempfer("hero", BrsHeld.fuer_spiel("Alrik", "Mensch", k), -1, Vector2i(Mars.FRONT, 0), skills)
	var m = Mars.new([hero], [foe], tab, Wuerfel.new(s), Wuerfel.new(s + 281), 0, false)
	hero.max_hp = 9999
	hero.hp = 9999
	foe.max_hp = 9999
	foe.hp = 9999
	hero.sp = 99
	hero.auto = auto
	return m


## ein Zug des Helden mit Befehl [o] und Ringantwort [re]: [Wirkung (Schaden am Gegner oder Heilung), Ringe eigen, Marke]
func _zug(k: String, s: int, o: Array, re: String) -> Array:
	var m = _mars(k, s, false)
	var hero = m.find("hero")
	if o[0] == "use" and o[1] == "Z_WUND":
		hero.hp = 1
	var ringe := [0]
	var react := func(t, intent):
		if String(intent.id) == "eigen":
			ringe[0] += 1
			if t != hero:
				_fehl("eigener Ring an %s statt am Helden" % t.id)
		return re
	m.start(Callable())
	var n := 0
	while m.outcome == "ONGOING" and m.current() != hero and n < 20:
		n += 1
		m.proceed(Callable())
	var marke := [""]
	var wirkung := [0]
	m.listener = func(e):
		if e.actor != "hero" or wirkung[0] != 0:
			return
		if int(e.damage) > 0 and e.target == "foe":
			wirkung[0] = int(e.damage)
		elif e.cue == "HEAL":
			wirkung[0] = int(e.hp["hero"]) - 1
		else:
			return
		marke[0] = String(e.get("ring_eigen", ""))
	m.act(o, react)
	return [wirkung[0], ringe[0], marke[0]]


func _pruefe(name: String, k: String, o: Array, marke: String) -> void:
	if k == "":
		k = _herkunft_mit(String(o[1]))
		if k == "":
			_fehl("%s: keine Herkunft kennt den Zauber" % name)
			return
	var n := 0
	for s in range(1, 300):
		var ohne: Array = _zug(k, s, o, Mars.NONE)
		if ohne[0] <= 0:
			continue
		n += 1
		var gut: Array = _zug(k, s, o, Mars.GOOD)
		var perf: Array = _zug(k, s, o, Mars.PERFECT)
		if ohne[1] != 1 or gut[1] != 1 or perf[1] != 1:
			_fehl("%s (%s) Würfel %d: eigener Ring %d/%d/%d mal gefragt, soll je 1" % [name, k, s, ohne[1], gut[1], perf[1]])
			return
		if gut[0] != ohne[0]:
			_fehl("%s Würfel %d: gut %d, soll wie verfehlt %d" % [name, s, gut[0], ohne[0]])
			return
		if perf[0] != roundi(ohne[0] * F):
			_fehl("%s Würfel %d: perfekt %d, soll %d (%.1f × %d)" % [name, s, perf[0], roundi(ohne[0] * F), F, ohne[0]])
			return
		if perf[2] != marke or gut[2] != "" or ohne[2] != "":
			_fehl("%s Würfel %d: Marke perfekt „%s“ (soll „%s“), gut „%s“, verfehlt „%s“ (soll leer)" % [name, s, perf[2], marke, gut[2], ohne[2]])
			return
		if n >= 15:
			break
	if n == 0:
		_fehl("%s: keine Wirkung in 300 Würfen" % name)
	else:
		print("  %s (%s): %d Fälle geprüft" % [name, k, n])


func _ohne_ring(name: String, k: String, o: Array, auto: bool) -> void:
	for s in range(1, 20):
		var m = _mars(k, s, auto)
		var hero = m.find("hero")
		var ringe := [0]
		var react := func(_t, intent):
			if String(intent.id) == "eigen":
				ringe[0] += 1
			return Mars.PERFECT
		if auto:
			m.start(react)     # der Held spielt sich selbst (_skip_to_choice); kein eigener Ring
			var n := 0
			while m.outcome == "ONGOING" and n < 40:
				n += 1
				m.proceed(react)
		else:
			m.start(Callable())
			var n := 0
			while m.outcome == "ONGOING" and m.current() != hero and n < 20:
				n += 1
				m.proceed(Callable())
			m.act(o, react)
		if ringe[0] != 0:
			_fehl("%s Würfel %d: eigener Ring %d mal gefragt, soll nie" % [name, s, ringe[0]])
			return
	print("  %s: nie gefragt" % name)
