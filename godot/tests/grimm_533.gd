# 533 (Abgleich 512 zu Build 249, Sokrates; alt Monsters.kt dire_wolf, Packs.kt guard): Grimmzahn ist kein Wolf, sondern der
# Leitwolf mit eigenen Werten und Boss (keine Flucht, kein Autopilot); seine Leibwache (zwei Wölfe, Biss 1W4, Angriff eins unter
# ihm, 55 % je Runde) flieht, wenn er fällt; der Lohn zählt sie nach dem BRS (Grimmzahn nach Modell D, je Wolf 0,25 dazu, 870.5). Prüfung ohne Grafik.
# Aufruf: im Ordner godot mit -s res://tests/grimm_533.gd (Exit 0 = richtig)
extends SceneTree

const AufrufS = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Figur = preload("res://kampf/figur.gd")

var fehler := 0


func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()


func _soll(gut: bool, was: String) -> void:
	print(("ok     " if gut else "FEHLER ") + was)
	if not gut:
		fehler += 1


func _lauf() -> void:
	var tab: Dictionary = Tabellen.lade()
	var monsters := {}
	for m in tab.monsters:
		monsters[m.id] = m
	_soll(monsters.has("dire_wolf"), "tabellen.json kennt dire_wolf")
	var foes: Array = AufrufS.gegner("GRIMM", monsters, Wuerfel.new(7))
	var g = foes[0]
	# 533 (Chef 04.11., 20:30, Blende mit „gelben Augen“): Art dire_wolf, Körper und Rudelregeln des Wolfs
	_soll(g.id == Figur.GRIMM and g.monster.id == Mars.DIRE_WOLF and Mars.koerper_of(g.monster) == Mars.WOLF and Mars.wolfig(g.monster) and Figur.vier(g),
		"Grimmzahn vorn, Art dire_wolf, Körper des Wolfs (id %s, Art %s, Körper %s)" % [g.id, g.monster.id, Mars.koerper_of(g.monster)])
	# 870.6: Werte nach BRS (werte.json „monster“ Grimmzahn, „merkmale“ „rudel“ „Leibwache“), keine RK, kein Würfel, keine EP der alten Fassung
	_soll(g.max_hp == int(Brs.monster("dire_wolf").leben), "Leben nach BRS %d (soll %d)" % [g.max_hp, int(Brs.monster("dire_wolf").leben)])
	_soll(g.boss(), "Boss %s" % g.boss())
	for w in foes.slice(1):
		_soll(w.follows == Figur.GRIMM and String(w.monster.get("rudel", "")) == "Leibwache" and is_equal_approx(float(w.monster.chance), 0.55),
			"%s Leibwache: folgt %s, Rudel %s, Anteil %s" % [w.id, w.follows, w.monster.get("rudel"), w.monster.get("chance")])
	# der Kampf: keine Flucht, kein Autopilot; Grimmzahn zuerst, dann muss die Leibwache fliehen
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = AufrufS.new()
	root.add_child(a)
	var ende := []
	a.ende.connect(func(e, tp, lohn): ende.append([e, tp, lohn]))
	a.starte("GRIMM", held.hero, null, "wald", "tag", 2, int(held.hp) * 3, -1, 11)
	while a.kampf == null or not a.kampf.is_inside_tree():
		await process_frame
	var k = a.kampf
	var held_f = k.mars.lead()
	var blende: Dictionary = Kampfblende.lage(k.mars)
	_soll(blende.get("id") == "dire_wolf", "Blende nimmt Grimmzahns Sätze (id %s)" % blende.get("id"))
	_soll(not k.mars.can_flee(held_f), "keine Flucht vor Grimmzahn")
	_soll(k.mars.autopilot_blocked() != null, "kein Autopilot gegen Grimmzahn")
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 90000:
		await process_frame
		if k.mars.outcome != "ONGOING" and not k.busy and not k.playing and k.beats.is_empty():
			break
		if not k.busy and not k.playing and k.beats.is_empty() and not k.ring_open and k.mars.outcome == "ONGOING":
			var c = k.mars.current()
			if c.side != "PARTY":
				k.go_on()
				continue
			var ts: Array = k.mars.targets(c)
			var ziel = null
			for x in ts:
				if x.id == Figur.GRIMM:
					ziel = x
			if ziel == null and not ts.is_empty():
				ziel = ts[0]
			k.order(["attack", ziel.id] if ziel != null else ["wait"])
	_soll(k.mars.outcome == "WON", "Kampf gewonnen (%s)" % k.mars.outcome)
	var wache: Array = k.mars.fighters().filter(func(f): return f.side == "FOES" and f.follows == Figur.GRIMM)
	_soll(wache.all(func(f): return f.fled or not f.standing()), "Leibwache geflohen oder gefallen: %s" % [wache.map(func(f): return "%s %s" % [f.id, "flieht" if f.fled else ("fällt" if not f.standing() else "steht")])])
	var lohn: Dictionary = k.reward
	var mates := wache.size()
	var soll_xp := roundi(Brs.erfahrung(int(k.mars.all[0].level()), "dire_wolf") * (1.0 + 0.25 * mates))     # 870.5: BRS, Leibwache 0,25
	_soll(int(lohn.get("xp", 0)) == soll_xp, "Erfahrung %s (soll %d)" % [lohn.get("xp"), soll_xp])
	print("GRIMM_533 %d Fehler" % fehler)
	quit(1 if fehler else 0)
