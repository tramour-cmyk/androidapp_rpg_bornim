extends SceneTree
# 607 (Chef 07.11., t268: „nachts schläft Pim doch, oder? Zumindest lautet so der Text, wenn man an der Tür klopft. Er läuft aber um
# 0300 Uhr immer noch rum“): jeder Dorfbewohner mit Tagesablauf (VillageDay) ist nachts drinnen: von seinem Ort am Tag aus, um 3 Uhr,
# nach hoechstens 90 s Spielzeit an der eigenen Tuer hinein und nicht mehr zu sehen; ebenso, wenn die Uhr waehrend des Tages auf die
# Nacht springt (Reiter Test, Uhrzeit). Ohne Bild. Aufruf: im Ordner godot mit -s res://tests/nacht_607.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func lauf(l: Leute, sek: float) -> float:
	var t := 0.0
	while t < sek and not l.drinnen:
		l._process(1.0 / 30.0)
		t += 1.0 / 30.0
	return t

func _lauf() -> void:
	var k := Karte.lade("village")
	var held := Node3D.new()
	root.add_child(held)
	held.position = k.kachel_pos(Vector2i(2, 30))   # weit weg
	var eltern := Node3D.new()   # nicht im Baum: kein _ready, kein Modell noetig
	var uhr := [180]
	Leute.uhr = func(): return uhr[0]
	for p in k.daten.get("leute", []):
		var id := String(p["id"])
		if not Karte.tagesablauf.has(id) or not Karte.tagesablauf[id].any(func(e): return bool(e[4])): continue   # Bram bleibt nachts an seinem Zaun (VillageDay)
		for start_min in [12 * 60, 13 * 60 + 30, 17 * 60 + 30, 3 * 60]:
			uhr[0] = start_min
			var l := Leute.new(k, p, held)
			eltern.add_child(l)
			l.position = k.kachel_pos(l.kachel)
			l.da = true
			# erst den Tag ueber an seinem Ort (wie nach dem Laden am Mittag), dann springt die Uhr auf 3 Uhr
			if start_min == 12 * 60: lauf(l, 20.0)
			uhr[0] = 3 * 60
			var t := lauf(l, 90.0)
			var st := l.plan_jetzt()
			pruefe(l.drinnen and not l.visible, "%s um 3 Uhr (vorher %02d Uhr): %s nach %.0f s bei %s, Tuer %s" % [id, start_min / 60, "drinnen" if l.drinnen else "DRAUSSEN", t, l.kachel, Vector2i(int(st[1]), int(st[2])) if not st.is_empty() else "-"])
			l.free()
	# 607 (Chef 07.11.: „wenn man an der Tür klopft … läuft aber um 0300 Uhr immer noch rum“): wer klopft, steht auf der Kachel vor
	# der Tuer, und das ist die Kachel, auf der die Person fuer die Nacht hineingeht; besetzt, kam sie nie hinein und lief herum
	for p in k.daten.get("leute", []):
		var id := String(p["id"])
		if not Karte.tagesablauf.has(id) or not Karte.tagesablauf[id].any(func(e): return bool(e[4])): continue
		uhr[0] = 3 * 60
		var l := Leute.new(k, p, held)
		var st := l.plan_jetzt()
		var tuer := Vector2i(int(st[1]), int(st[2]))
		l.kachel = tuer + Vector2i(2, 1)
		if not k.begehbar(l.kachel): l.kachel = tuer + Vector2i(-2, 1)
		eltern.add_child(l)
		l.position = k.kachel_pos(l.kachel)
		l.da = true
		held.position = k.kachel_pos(tuer)   # der Held klopft
		var t := lauf(l, 90.0)
		pruefe(l.drinnen and not l.visible, "%s um 3 Uhr, Held klopft an der Tuer %s: %s nach %.0f s bei %s" % [id, tuer, "drinnen" if l.drinnen else "DRAUSSEN", t, l.kachel])
		l.free()
	held.position = k.kachel_pos(Vector2i(2, 30))
	print("NACHT607 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	Leute.uhr = Callable()
	quit(1 if fehler > 0 else 0)
