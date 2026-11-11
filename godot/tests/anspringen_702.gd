# 702 (Chef 08.11., 21:27: „1 Minute lang zugeguckt … wie ich jedes Mal einen Angriff verloren habe“): Messung ohne Bild, nur
# die Regeln (mars.gd nach dem BRS), Held Stufe 1 je Herkunft (BrsHeld wie tests/sim444_870.gd, Startfertigkeiten), Rudel aus
# aufruf.gd, 2 Heiltränke, ohne Söldner. Spielweisen: „haut“ greift jeden Zug den ersten erreichbaren Gegner an, „weicht“ dazu
# einem angekündigten Sprung aus (Platz wechseln, dann angreifen), „zaubert“ (705, Sokrates 10.11., 11:47, Chef „829 A, ein
# Zauberer zaubert“): Heiltrank unter 40 % Leben, Arkanpfeil auf einen Gegner mit höchstens 9 Leben, sonst der Autopilot
# (mars.gd _auto_order: Flächenzauber auf zwei in einer Reihe, sonst Funkenpfeil, Feuer gegen ein Rudel auf den Leitwolf);
# „schwach“ wie „zaubert“, der Funkenpfeil aber auf den Schwächsten (wie der Autopilot vor 705, der Leitwolf flieht später);
# „erntet“ will Fell und Erfahrung: Arkanpfeil (ohne Feuer) auf den Leitwolf, Funkenpfeil erst unter halbem Leben (Not).
# Gezählt: Siege, davon vertrieben (das Rudel floh vor dem Feuer: kein Fell, keine Erfahrung, 870c 3 A), Züge des Helden, davon
# verloren (Aufstehen), längste Folge, Kämpfe mit 3 und mehr verlorenen Zügen am Stück. Regel „handeln“ (702 C, Chef 09.11.,
# 06:56) wie im Spiel; REGEL=alle dazu „heute“ (wie Skirmish.kt).
# Run: godot --headless --path godot -s res://tests/anspringen_702.gd   [NUR=Zauberlehrling] [N=300] [REGEL=alle]
#   (Tabelle, Exit 0; braucht daten/werte.json = tools/sim444/werte.json)
extends SceneTree

const Aufruf = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Brs = preload("res://regeln/brs.gd")
const Sim870 = preload("res://tests/sim444_870.gd")
const HERKUENFTE := ["Wachsoldat", "Zauberlehrling", "Herumtreiber", "Klosterschüler"]


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	if Brs.lade().is_empty():
		print("daten/werte.json fehlt: keine Messung")
		quit(0)
		return
	var tab: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var skills := {}
	for s in tab.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tab.monsters:
		monsters[m.id] = m
	var nur := OS.get_environment("NUR")
	var n := int(OS.get_environment("N")) if OS.get_environment("N") != "" else 300
	var regeln := ["", "handeln"] if OS.get_environment("REGEL") == "alle" else ["handeln"]
	print("Regel    Spieler  Herkunft        Gegner  Siege  vertrieben  Züge  verloren  längste  ≥3 am Stück")
	for regel in regeln:
		for weise in ["haut", "weicht", "zaubert", "schwach", "erntet"]:
			for hk in HERKUENFTE:
				for gegner in ["RUDEL", "WOLF"]:
					if nur != "" and not (hk + gegner).contains(nur):
						continue
					var z := _messe(Sim870._blatt(hk, 1, {}, tab), tab, skills, monsters, regel, weise, gegner, n)
					print("%-8s %-8s %-15s %-7s %4d%%  %8d%%  %4.1f  %5.0f%%  %5.1f  %6d%%" % [regel if regel != "" else "heute", weise, hk,
						gegner, z.siege * 100 / n, z.vertrieben * 100 / n, float(z.zuege) / n, 100.0 * z.verloren / maxi(1, z.zuege),
						float(z.laengste) / n, z.drei * 100 / n])
	quit(0)


func _messe(sheet: Dictionary, tab: Dictionary, skills: Dictionary, monsters: Dictionary, regel: String, weise: String, gegner: String, n: int) -> Dictionary:
	var z := {"siege": 0, "vertrieben": 0, "zuege": 0, "verloren": 0, "laengste": 0, "drei": 0}
	for s in n:
		var foes: Array = Aufruf.rudel(monsters, Wuerfel.new(s * 7 + 1))
		if gegner == "WOLF":
			foes = [foes[0]]
		var hero = Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, int(sheet.brs.leben), null, skills)
		var mars = Mars.new([hero], foes, tab, Wuerfel.new(s * 7 + 2), Wuerfel.new(s * 7 + 281), 0, false)
		mars.anspringen = regel
		mars.potions["potion"] = 2
		var folge := [0, 0]     # laufende, längste Folge verlorener Züge
		mars.listener = func(e):
			if e.cue == "RISES" and e.actor == "hero" and regel != "handeln":     # „handeln“: er steht auf und handelt im selben Zug
				z.verloren += 1
				z.zuege += 1
				folge[0] += 1
				folge[1] = maxi(folge[1], folge[0])
		var react := func(_t, _i): return Mars.NONE
		mars.start(react)
		var k := 0
		while mars.outcome == "ONGOING" and k < 400:
			k += 1
			var f = mars.current()
			z.zuege += 1
			folge[0] = 0
			if weise in ["zaubert", "schwach"]:
				mars.act(_zaubert(mars, f, weise == "schwach"), react)
				continue
			if weise == "erntet":
				mars.act(_erntet(mars, f), react)
				continue
			if weise == "weicht" and not f.moved and _sprung_auf(mars, f):
				var frei = _freier_platz(mars, f)
				if frei != null:
					mars.act(["swap", frei, false], react)
					if mars.outcome != "ONGOING":
						break
			var ts: Array = mars.targets(f)
			mars.act(["attack", ts[0].id] if not ts.is_empty() else ["wait"], react)
		if mars.outcome == "WON":
			z.siege += 1
			if mars.kein_lohn:
				z.vertrieben += 1
		z.laengste += folge[1]
		if folge[1] >= 3:
			z.drei += 1
	return z


## 705 Spielweise „zaubert“: Heiltrank unter 40 %, Arkanpfeil auf einen Gegner mit höchstens 9 Leben, sonst der Autopilot
func _zaubert(mars, f, schwach_zuerst: bool) -> Array:
	if f.hp < f.max_hp * 0.4 and mars.potions.get("potion", 0) > 0:
		return ["drink", "potion", f.id]
	if "Z_ARKAN" in mars.moves(f) and mars.blocked(f, "Z_ARKAN") == null:
		var wenig: Array = mars.feinde(f).filter(func(x): return x.hp <= 9)
		if not wenig.is_empty():
			return ["use", "Z_ARKAN", mars._min_hp(wenig).id]
	var o: Array = mars._auto_order(f)
	if schwach_zuerst and o[0] == "use" and o[1] == "Z_FUNKEN":
		o[2] = mars._min_hp(mars.feinde(f)).id
	return o


## 705 Spielweise „erntet“: ohne Feuer, solange das Leben über der Hälfte ist (das Rudel flieht sonst ohne Fell und Erfahrung)
func _erntet(mars, f) -> Array:
	if f.hp < f.max_hp * 0.4 and mars.potions.get("potion", 0) > 0:
		return ["drink", "potion", f.id]
	if f.hp * 2 >= f.max_hp and "Z_ARKAN" in mars.moves(f) and mars.blocked(f, "Z_ARKAN") == null:
		var ziel = mars._anfuehrer(mars.feinde(f))
		return ["use", "Z_ARKAN", (ziel if ziel != null else mars._min_hp(mars.feinde(f))).id]
	return _zaubert(mars, f, false)


func _sprung_auf(mars, f) -> bool:
	for id in mars.intents:
		var p: Array = mars.intents[id]
		if p[0].effect == "POUNCE" and mars.aim_spot.get(id) == f.place:
			return true
	return false


func _freier_platz(mars, f):
	for sp in Mars.SPOTS:
		if sp != f.place and not mars.all.any(func(x): return x.side == f.side and x.place == sp and x.standing()):
			return sp
	return null
