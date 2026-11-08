# 702 (Chef 08.11., 21:27, t270: „1 Minute lang zugeguckt bei den Wölfen … wie ich jedes Mal einen Angriff verloren habe“):
# Nachstellung ohne Grafik. Gruppe nach Probe (Kämpfer, dazu Kleriker hinten) gegen das Wolfsrudel (aufruf.gd rudel: Wolf und
# ein bis zwei Jungwölfe), beide Seiten nach Autopilot, viele Würfelfolgen. Gezählt je Held: Züge, davon durch Anspringen
# verloren, längste Folge verlorener Züge, Kämpfe, in denen er nie handelte. Ändert nichts; Exit 0, nur Messung.
# Varianten für den Vorschlag (nur im Test nachgebildet): JETZT wie gebaut; SCHUTZ nach einem verlorenen Zug ist der nächste
# sicher (wie stun_guard bei Betäubung); RETTUNG Rettungswurf Stärke gegen SG 11 (Kämpfer +5, Kleriker +2), gelingt er, kein Sturz.
# Aufruf: im Ordner godot mit --headless -s res://tests/wolf_zug_702.gd   (KAEMPFE=n, Vorgabe 400)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")


class Zaehl extends "res://regeln/mars.gd":
	var zuege := {}      # id -> Züge
	var verloren := {}   # id -> durch Anspringen verloren
	var folge := {}      # id -> laufende Folge verlorener Züge
	var folge_max := {}  # id -> längste Folge
	var gehandelt := {}  # id -> in diesem Kampf mindestens einmal gehandelt
	var gelesen := 0
	var variante := "JETZT"
	var schutz := {}     # id -> nächster Zug sicher (SCHUTZ)
	var rettung := {"hero": 5, "merc": 2}

	func _init(party: Array, foes: Array, tables: Dictionary, p_dice, p_words) -> void:
		super(party, foes, tables, p_dice, p_words)

	func _next_turn() -> void:
		var f = order[turn]
		if f.side == "FOES":
			# was dieser Gegner eben tat: hat er jemanden angesprungen, greift die Variante
			for i in range(gelesen, _log.size()):
				var e: Dictionary = _log[i]
				if e.cue == "POUNCED" and e.target != null:
					var t = find(e.target)
					if t == null or not t.held:
						continue
					if variante == "SCHUTZ" and schutz.get(t.id, false):
						t.held = false
						t.prone = false
					elif variante == "RETTUNG" and dice.roll_expr([1, 20, int(rettung.get(t.id, 0))]) >= 11:
						t.held = false
						t.prone = false
		if f.side == "PARTY":
			var lost := false
			for i in range(gelesen, _log.size()):
				var e: Dictionary = _log[i]
				if e.cue == "RISES" and e.actor == f.id:
					lost = true
			zuege[f.id] = int(zuege.get(f.id, 0)) + 1
			schutz[f.id] = lost
			if lost:
				verloren[f.id] = int(verloren.get(f.id, 0)) + 1
				folge[f.id] = int(folge.get(f.id, 0)) + 1
				folge_max[f.id] = maxi(int(folge_max.get(f.id, 0)), int(folge[f.id]))
			else:
				folge[f.id] = 0
				gehandelt[f.id] = true
		gelesen = _log.size()
		super()


func _initialize() -> void:
	var tables: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var Aufruf = load("res://kampf/aufruf.gd")
	var n := int(OS.get_environment("KAEMPFE")) if OS.get_environment("KAEMPFE") != "" else 400
	for lauf in [["JETZT", false], ["JETZT", true], ["SCHUTZ", false], ["SCHUTZ", true], ["RETTUNG", false], ["RETTUNG", true]]:
		var variante: String = lauf[0]
		var mit_kleriker: bool = lauf[1]
		var sum := {"zuege": {}, "verloren": {}, "nie": {}, "folge3": {}, "folge_max": {}}
		var gewonnen := 0
		for k in n:
			var foes: Array = Aufruf.rudel(monsters, Wuerfel.new(1000 + k))
			var sh: Dictionary = tables.probe.FIGHTER.hero
			var party := [Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sh.hero.duplicate(true), int(sh.hp), sh.hero.second, skills)]
			if mit_kleriker:
				var sm: Dictionary = tables.probe.CLERIC.merc
				party.append(Mars.hero_fighter("merc", "PARTY", Vector2i(Mars.BACK, 0), sm.hero.duplicate(true), int(sm.hp), sm.hero.second, skills))
			var m := Zaehl.new(party, foes, tables, Wuerfel.new(k), Wuerfel.new(k + 7))
			m.variante = variante
			for p in party:
				p.auto = true
			m.start()
			var schritte := 0
			while m.outcome == "ONGOING" and schritte < 2000:
				m._skip_to_choice(func(_t, _i): return [Mars.NONE, Mars.GOOD, Mars.PERFECT][randi() % 3])
				m._log = []
				m.gelesen = 0
				schritte += 1
			if m.outcome == "WON":
				gewonnen += 1
			for id in m.zuege:
				sum.zuege[id] = int(sum.zuege.get(id, 0)) + int(m.zuege[id])
				sum.verloren[id] = int(sum.verloren.get(id, 0)) + int(m.verloren.get(id, 0))
				sum.folge_max[id] = maxi(int(sum.folge_max.get(id, 0)), int(m.folge_max.get(id, 0)))
				if not m.gehandelt.has(id):
					sum.nie[id] = int(sum.nie.get(id, 0)) + 1
				if int(m.folge_max.get(id, 0)) >= 3:
					sum.folge3[id] = int(sum.folge3.get(id, 0)) + 1
		print("702 %s, %s, %d Kämpfe, gewonnen %d" % [variante, "Kämpfer und Kleriker" if mit_kleriker else "Kämpfer allein", n, gewonnen])
		for id in sum.zuege:
			var z: int = sum.zuege[id]
			var v: int = sum.verloren.get(id, 0)
			print("  %s: %d Züge, %d verloren (%.0f %%), Kämpfe ohne eigene Handlung %d, mit 3+ verlorenen Zügen in Folge %d, längste Folge %d" % [
				id, z, v, 100.0 * v / maxi(1, z), sum.nie.get(id, 0), sum.folge3.get(id, 0), sum.folge_max.get(id, 0)])
	quit(0)
