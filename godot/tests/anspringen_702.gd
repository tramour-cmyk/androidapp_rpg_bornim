# 702 (Chef 08.11., 21:27: „1 Minute lang zugeguckt … wie ich jedes Mal einen Angriff verloren habe“): Messung ohne Bild, nur
# die Regeln (mars.gd), aufgestellt wie rudel_mess.gd (Held Stufe 1 je Klasse aus regeln/brs_held.gd (870.4), Rudel aus aufruf.gd,
# 2 Heiltränke, ohne Söldner). Der Spieler greift jeden Zug den ersten erreichbaren Gegner an (kein Autopilot), wahlweise
# weicht er einem angekündigten Sprung aus (Platz wechseln, dann angreifen). Gezählt: Züge des Helden, davon verloren
# (Aufstehen), längste Folge verlorener Züge, Kämpfe mit 3 und mehr verlorenen Zügen am Stück, Siege. Je Regel (mars.gd
# anspringen): „heute“ (wie Skirmish.kt) und „handeln“ (702 C, Chef 09.11., 06:56); nach SRD und nach BRS.
# Run: godot --headless --path godot -s res://tests/anspringen_702.gd   (Tabelle, Exit 0; braucht daten/held.json)
extends SceneTree

const Aufruf = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const N := 300


func _initialize() -> void:
	if not (FileAccess.file_exists("res://daten/held.json")):
		print("Heldwerte fehlen: keine Messung")
		quit(0)
		return
	var tab: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var skills := {}
	for s in tab.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tab.monsters:
		monsters[m.id] = m
	var a = Aufruf.new()
	var nur := OS.get_environment("NUR")
	print("Rechnung Regel   Spieler  Klasse   Gegner  Siege  Züge  verloren  längste  ≥3 am Stück")
	for rechnung in ["BRS"]:     # 870.5: SRD fiel
		for regel in ["", "handeln"]:
			for ausweichen in [false, true]:
				for k in ["Wachsoldat", "Zauberlehrling", "Herumtreiber", "Klosterschüler"]:   # 870.4: Herkunft statt Klasse
					for gegner in ["RUDEL", "WOLF"]:
						if nur != "" and not (k + gegner).contains(nur):
							continue
						var z := _messe(a, null, tab, skills, monsters, regel, ausweichen, k, gegner)
						print("%-8s %-8s %-8s %-8s %-7s %4d%%  %4.1f  %5.0f%%  %5.1f  %6d%%" % [rechnung, regel if regel != "" else "heute",
							"weicht" if ausweichen else "haut", k, gegner, z.siege * 100 / N, float(z.zuege) / N,
							100.0 * z.verloren / maxi(1, z.zuege), float(z.laengste) / N, z.drei * 100 / N])
	a.free()
	quit(0)


func _messe(a, _hw, tab: Dictionary, skills: Dictionary, monsters: Dictionary, regel: String, ausweichen: bool, k: String, gegner: String) -> Dictionary:
	var z := {"siege": 0, "zuege": 0, "verloren": 0, "laengste": 0, "drei": 0}
	for s in N:
		var foes: Array = Aufruf.rudel(monsters, Wuerfel.new(s * 7 + 1))
		if gegner == "WOLF":
			foes = [foes[0]]
		var hero = a._kaempfer("hero", BrsHeld.fuer_spiel("Alrik", "Mensch", k), -1, Vector2i(Mars.FRONT, 0), skills)
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
		var n := 0
		while mars.outcome == "ONGOING" and n < 400:
			n += 1
			var f = mars.current()
			z.zuege += 1
			folge[0] = 0
			if ausweichen and not f.moved and _sprung_auf(mars, f):
				var frei = _freier_platz(mars, f)
				if frei != null:
					mars.act(["swap", frei, false], react)
					if mars.outcome != "ONGOING":
						break
			var ts: Array = mars.targets(f)
			mars.act(["attack", ts[0].id] if not ts.is_empty() else ["wait"], react)
		if mars.outcome == "WON":
			z.siege += 1
		z.laengste += folge[1]
		if folge[1] >= 3:
			z.drei += 1
	return z


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
