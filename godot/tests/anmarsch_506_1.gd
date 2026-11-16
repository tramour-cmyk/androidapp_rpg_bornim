extends SceneTree
# 506.1 (Chef 10.11., 12:25, Film 506: „der dritte Wiedergänger … steht ja so weit hinten … läuft ja allein schon eine halbe
# Stunde“): am echten Kampfort, ohne Bild, drei Wiedergänger (2 vorn, 1 hinten) und einer vorn, einer hinten. Je Gegner Tempo
# des Anmarschs, Weg bis zum Schlag und Dauer; Grenzen: langsame Gegner höchstens ANMARSCH_S (hinten ANMARSCH_HINTEN_S), die hintere Reihe bleibt
# hinter der vorderen, kein Paar deckt sich am Schirm mehr als DECKUNG (wie abstand_567), Wölfe und Goblins stehen wie vorher.
# Ohne Kaufmodelle (am Rechner) bekommen die Wiedergänger ein Probetempo PROBE_MPS, damit die Regel greift; mit Modellen das echte.
# Aufruf: im Ordner godot mit -s res://tests/anmarsch_506_1.gd   (Exit 0 = alle Grenzen gehalten)

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Kampfort = preload("res://kampf/kampfort.gd")
const Aufruf = preload("res://kampf/aufruf.gd")

const ANMARSCH_S := 4.0      # vorn (gemessen mit Kaufmodell: 2,3–2,6 s)
const ANMARSCH_HINTEN_S := 6.0     # hinten (vorher 8,2 s, Film 506)
const REICH_M := 1.0         # Ursprung bis Mitte des Ziels beim Schlag (figur.gd _hieb, Krallen 1,3 m vor dem Ursprung, Maß gerundet)
const DECKUNG := 0.35
const PROBE_MPS := 0.85     # wie der gekaufte Wiedergänger im Spiel (0,82–0,88 m/s)
const AUFSTELLUNGEN := [
	["2 vorn, 1 hinten", [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0)]],
	["1 vorn, 1 hinten", [Vector2i(0, 0), Vector2i(1, 0)]],
]

var fehler := 0
var tables: Dictionary


func _initialize() -> void:
	_lauf.call_deferred()


func _pruef(was: String, gut: bool, info := "") -> void:
	print(("gut " if gut else "FALSCH ") + was + ("" if info == "" else ": " + info))
	if not gut:
		fehler += 1


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	tables = Tabellen.lade()
	for a in AUFSTELLUNGEN:
		await _aufstellung("WIEDERGAENGER3", a[0], a[1], true)
		await _aufstellung("GOBLINS", a[0], a[1], false)
		await _aufstellung("WOLVES", a[0], a[1], false)
		await _aufstellung("SKELETONS", a[0], a[1], false)
	print("ANMARSCH506 %d Fehler" % fehler)
	quit(1 if fehler else 0)


func _aufstellung(art: String, name_: String, plaetze: Array, langsam: bool) -> void:
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	var hs: Dictionary = tables.probe["FIGHTER"].hero
	var ms: Dictionary = tables.probe["WIZARD"].merc
	var party := [
		Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), hs.hero, int(hs.hp), hs.hero.second, skills),
		Mars.hero_fighter("merc", "PARTY", Vector2i(Mars.BACK, 0), ms.hero, int(ms.hp), ms.hero.second, skills),
	]
	var dice = Wuerfel.new(7)
	var foes: Array = Aufruf.gegner(art, monsters, dice)
	if foes.is_empty():
		_pruef(art + ": Gruppe fehlt", false)
		return
	while foes.size() < plaetze.size():
		foes.append(Aufruf.gegner(art, monsters, dice)[0])
	foes.resize(plaetze.size())
	for i in foes.size():
		foes[i].id = "foe%d" % i
	var kf = Kampfort.new()
	if not kf.setup(party, foes, tables, {"potion": 0}, func(_o): pass, 7, {}):
		_pruef(art + " " + name_ + ": Kampf", false)
		return
	root.add_child(kf)
	await process_frame
	await process_frame
	for i in foes.size():
		kf.shown.places[foes[i].id] = plaetze[i]
	var probe := false
	for i in foes.size():
		var fig = kf.figures[foes[i].id]
		if langsam and fig.anmarsch_mps() <= 0.0:     # ohne Kaufmodell: Probeweg „Gehen“, eine Sekunde, PROBE_MPS weit
			fig.weg = {"Gehen": [[0.0, 0.0], [0.0, PROBE_MPS / fig.model.scale.x]]}
			fig.weg_fps = 1.0
			fig.tempo = {}
			probe = true
	var held: Vector3 = kf.figures["hero"].position
	var dp: float = root.size.x / 412.0
	var koerper := {}
	var a_vorn := INF
	var a_hinten := -INF
	for i in foes.size():
		var fig = kf.figures[foes[i].id]
		var neu: Vector3 = kf._spot_pos(fig.fighter, plaetze[i])
		fig.snap_to(neu)
		var v: float = fig.anmarsch_mps()
		var ab: Vector2 = kf._spot_ab(fig.fighter, plaetze[i])
		var weg: float = Vector2(neu.x - held.x, neu.z - held.z).length() - REICH_M
		var t: float = weg / v if v > 0.0 else 0.0
		print("  %s %s %s: Tempo %.2f m/s%s, Tiefe %.2f m, Weg %.2f m, %.1f s" % [art, name_, plaetze[i], v, " (Probe)" if probe else "", ab.x, weg, t])
		if plaetze[i].x == Mars.FRONT:
			a_vorn = minf(a_vorn, ab.x)
		else:
			a_hinten = maxf(a_hinten, ab.x)
		if v > 0.0 and v < kf.LANGSAM_MPS:
			var held_a: float = -(kf.FRONT_M + kf.NEAR_M)
			var soll: float = held_a + kf.NAH_VORN_M + (kf.NAH_REIHE_M if plaetze[i].x == Mars.BACK else 0.0)
			_pruef("%s %s %s Nahaufstellung" % [art, name_, plaetze[i]], ab.x <= soll + 0.01, "Tiefe %.2f, soll höchstens %.2f m" % [ab.x, soll])
			_pruef("%s %s %s Anmarsch" % [art, name_, plaetze[i]], t <= (ANMARSCH_HINTEN_S if plaetze[i].x == Mars.BACK else ANMARSCH_S), "%.1f s" % t)
		elif not langsam:
			# Wölfe, Goblins: unverändert wie vor 506.1 (_naeher gibt die Tiefe zurück)
			_pruef("%s %s %s unverändert" % [art, name_, plaetze[i]], kf._naeher(fig.fighter, ab, plaetze[i].x == Mars.BACK).is_equal_approx(ab))
	await process_frame
	if a_hinten > -INF:
		_pruef("%s %s hinten hinter vorn" % [art, name_], a_hinten >= a_vorn + 0.5, "%.2f / %.2f m" % [a_vorn, a_hinten])
	for i in foes.size():
		var fig = kf.figures[foes[i].id]
		var fuss: Vector2 = kf.screen_of(fig.position)
		var kopf: Vector2 = kf.screen_of(fig.head())
		var hoch := maxf(20 * dp, fuss.y - kopf.y)
		var wolf: bool = fig.fighter.monster != null and fig.fighter.monster.id == Mars.WOLF
		var halb := hoch * (0.8 if wolf else 0.45)
		koerper[i] = Rect2(fuss.x - halb, fuss.y - hoch, halb * 2.0, hoch)
		print("  %s %s %s: Fuß im Bild %d,%d" % [art, name_, plaetze[i], fuss.x, fuss.y])
	for hid in ["hero", "merc"]:
		var hf = kf.figures[hid]
		var hfuss: Vector2 = kf.screen_of(hf.position)
		var hhoch := maxf(20 * dp, hfuss.y - kf.screen_of(hf.head()).y)
		var hr := Rect2(hfuss.x - hhoch * 0.3, hfuss.y - hhoch, hhoch * 0.6, hhoch)
		for i in foes.size():
			var r: Rect2 = koerper[i]
			var anteil := r.intersection(hr).get_area() / minf(r.get_area(), hr.get_area())
			_pruef("%s %s %s gegen %s" % [art, name_, plaetze[i], hid], anteil <= DECKUNG, "%.0f %%" % (anteil * 100.0))
	for i in foes.size():
		for j in range(i + 1, foes.size()):
			var r1: Rect2 = koerper[i]
			var r2: Rect2 = koerper[j]
			var anteil := r1.intersection(r2).get_area() / minf(r1.get_area(), r2.get_area())
			_pruef("%s %s %s/%s Deckung" % [art, name_, plaetze[i], plaetze[j]], anteil <= DECKUNG, "%.0f %%" % (anteil * 100.0))
	kf.queue_free()
	await process_frame
