extends SceneTree
# 1296 (t289.3 ✗, Chef 15.11., 20:47, Bildschirmfoto Kampfbericht Probekampf Wölfe): die goldene Eingebung „Er will springen …
# Wechsel, und mir bleibt noch ein halber Zug“ kam nach der Ansage von Wolf 3, danach sprangen Wolf 1 und Wolf 2, bevor der Held zog.
# Regeln ohne Bild: Held (Kämpfer) und Söldner gegen das Wolfsrudel, Züge wie „Held Auto“, viele Kämpfe; nach jeder Eingebung zu
# Anspringen oder Flanke darf kein Gegner anspringen oder flankieren, bevor der Held handelt.
# Aufruf: im Ordner godot mit -s res://tests/eingebung_1296.gd (Exit 0 = gut)

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Aufruf = preload("res://kampf/aufruf.gd")
const Brs = preload("res://regeln/brs.gd")
const Tabellen = preload("res://regeln/tabellen.gd")

const KAEMPFE := 60
const RAT := ["Er will springen", "He means to leap"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var tables = Tabellen.lade()
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	var eingebungen := 0
	var fehler := 0
	for k in KAEMPFE:
		var dice := Wuerfel.new(12960 + k)
		var foes: Array = Aufruf.gegner("WOLVES", monsters, dice)
		var hs: Dictionary = (tables.probe.FIGHTER.hero.hero as Dictionary).duplicate(true)
		hs.level = 1
		var party := [Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), hs, int(tables.probe.FIGHTER.hero.hp), hs.second, skills)]
		var mars = Mars.new(party, foes, tables, dice, Wuerfel.new(96 + k))
		mars.brs_einrichten()
		mars.chosen = true
		var log: Array = []
		var react := func(_t, _i) -> String: return Mars.NONE
		mars.start(react)
		log.append_array(mars._take_log())
		var zuege := 0
		while mars.outcome == "ONGOING" and zuege < 200:
			zuege += 1
			log.append_array(mars.act(mars._auto_order(mars.current()), react))
		var offen := -1     # Index der letzten Eingebung, auf die noch kein Zug des Helden folgte
		for i in log.size():
			var e: Dictionary = log[i]
			if e.get("cue") == "EINGEBUNG" and RAT.any(func(r): return String(e.text).begins_with(r)):
				eingebungen += 1
				offen = i
			elif offen >= 0 and e.get("actor") == "hero":
				offen = -1
			elif offen >= 0 and e.get("cue") == "FOE_STRIKES" and String(e.text).contains("Anspringen"):
				fehler += 1
				print("FALSCH Kampf %d: nach der Eingebung „%s“ zuerst „%s“, bevor der Held zog" % [k, String(log[offen].text).left(40), e.text])
				offen = -1
	print("gut  " if eingebungen > 0 else "FALSCH ", "Eingebungen zum Wechsel in %d Kämpfen: %d" % [KAEMPFE, eingebungen])
	if eingebungen == 0:
		fehler += 1
	print("EINGEBUNG1296 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
