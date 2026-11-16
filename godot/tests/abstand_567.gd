extends SceneTree
# 567 (Chef 04.11., 17:00–17:15, Build 257: zwei Goblins, zwei Wölfe stehen im Kampfort fast übereinander): am echten Kampfort,
# ohne Bild, je Aufstellung der Gegner (1 vorn + 1 hinten, 2 + 1, 1 + 2, 2 + 2) der Fußpunkt und der Körper jeder Figur am Schirm
# (Handyformat 1080 × 2340). Grenzen: kein Paar deckt sich mehr als DECKUNG (Anteil des kleineren Körpers), der Kopf des hinteren
# bleibt frei (KOPF_FREI); der hintere steht
# seitlich mindestens SEITE_DP neben dem vorderen, nie mit den Füßen auf dessen Kopfhöhe genau darüber; alle im Bild.
# Aufruf: im Ordner godot mit -s res://tests/abstand_567.gd   (Exit 0 = alle Grenzen gehalten)

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Kampfort = preload("res://kampf/kampfort.gd")
const Aufruf = preload("res://kampf/aufruf.gd")

const DECKUNG := 0.35
const KOPF_FREI := 0.2      # vom oberen Drittel des hinteren höchstens so viel vom vorderen verdeckt
const SEITE_DP := 40.0
const AUFSTELLUNGEN := [
	["1 vorn, 1 hinten", [Vector2i(0, 0), Vector2i(1, 0)], true],
	["2 vorn, 1 hinten", [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0)], true],
	# nur gemessen (Grimmzahn-Aufstellung 348.7, Reihen hintereinander): Zeilen „Hinweis“, zählen nicht
	["1 vorn, 2 hinten", [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)], false],
	["2 vorn, 2 hinten", [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)], false],
]

var fehler := 0
var streng := true
var tables: Dictionary


func _initialize() -> void:
	_lauf.call_deferred()


func _pruef(was: String, gut: bool, info := "") -> void:
	print(("gut " if gut else ("FALSCH " if streng else "Hinweis ")) + was + ("" if info == "" else ": " + info))
	if not gut and streng:
		fehler += 1


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	tables = Tabellen.lade()
	for art in ["SCOUTS", "WOLVES", "GOBLINS"]:
		for a in AUFSTELLUNGEN:
			streng = a[2]
			await _aufstellung(art, a[0], a[1])
	print("ABSTAND567 %d Fehler" % fehler)
	quit(1 if fehler else 0)


func _aufstellung(art: String, name_: String, plaetze: Array) -> void:
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
	var dp: float = root.size.x / 412.0
	var koerper := {}
	for i in foes.size():
		var fig = kf.figures[foes[i].id]
		fig.snap_to(kf._spot_pos(fig.fighter, plaetze[i]))
	await process_frame
	for i in foes.size():
		var fig = kf.figures[foes[i].id]
		var fuss: Vector2 = kf.screen_of(fig.position)
		var kopf: Vector2 = kf.screen_of(fig.head())
		var hoch := maxf(20 * dp, fuss.y - kopf.y)
		var wolf: bool = fig.fighter.monster != null and fig.fighter.monster.id == Mars.WOLF
		var halb := hoch * (0.8 if wolf else 0.45)
		koerper[i] = Rect2(fuss.x - halb, fuss.y - hoch, halb * 2.0, hoch)
		print("  %s %s %s: Fuß %d,%d Höhe %d" % [art, name_, plaetze[i], fuss.x, fuss.y, hoch])
		var sr: Rect2 = kf.scene_rect()
		_pruef("%s %s %s im Bild" % [art, name_, plaetze[i]], fuss.x - halb >= 0 and fuss.x + halb <= sr.size.x and fuss.y - hoch >= 0, "%d–%d von %d" % [fuss.x - halb, fuss.x + halb, sr.size.x])
	# die Gegner nie auf Held oder Söldner (vorn links ein Stück weiter zur Mitte, SOLO_FRONT_B)
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
			var schnitt := r1.intersection(r2)
			var anteil := schnitt.get_area() / minf(r1.get_area(), r2.get_area())
			var was := "%s %s %s/%s" % [art, name_, plaetze[i], plaetze[j]]
			_pruef(was + " Deckung", anteil <= DECKUNG, "%.0f %%" % (anteil * 100.0))
			var hi: Rect2 = r1 if r1.end.y < r2.end.y else r2
			var vo: Rect2 = r2 if r1.end.y < r2.end.y else r1
			var kopf := Rect2(hi.position, Vector2(hi.size.x, hi.size.y * 0.35))
			var kd := kopf.intersection(vo).get_area() / kopf.get_area()
			_pruef(was + " Kopf frei", kd <= KOPF_FREI, "%.0f %% verdeckt" % (kd * 100.0))
			if plaetze[i].x != plaetze[j].x:
				var vorn: Rect2 = r1 if plaetze[i].x == Mars.FRONT else r2
				var hinten: Rect2 = r2 if plaetze[i].x == Mars.FRONT else r1
				var seite := absf(hinten.get_center().x - vorn.get_center().x) / dp
				var drueber := hinten.end.y <= vorn.position.y + vorn.size.y * 0.35
				_pruef(was + " seitlich", seite >= SEITE_DP or not drueber, "%.0f dp, Füße hinten %s" % [seite, "auf Kopfhöhe" if drueber else "tiefer"])
	kf.queue_free()
	await process_frame
