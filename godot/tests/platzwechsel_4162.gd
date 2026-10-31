extends SceneTree
# 416.2 (Chef 31.10., Build 143: „Platzwechsel statt nur Schieben … teils kein Weiterkommen“): ohne Bild; wie alt Game.makeWay:
# wer geschoben wird, tritt zur Seite oder voran, und wo beides nicht geht, tauscht er mit dem Helden den Platz und laesst ihn
# solange durch. Rowena in der Schenke an eine Stelle ohne Ausweg gestellt, der Held davor schiebt; dann an eine offene Stelle.
# Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/platzwechsel_4162.gd -> „PLATZWECHSEL n Fehler“

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func offen(k: Karte, t: Vector2i) -> bool: return k.begehbar(t) and k.ausgang(t).is_empty()

func stelle(spiel, l: Leute, t: Vector2i, h: Vector2i) -> void:
	l.ziel = Vector2i(-1, -1); l.warte = 30.0
	if "durch_bis" in l: l.durch_bis = 0
	l.kachel = t; l.position = spiel.karte.kachel_pos(t)
	spiel.held.setze(h, "DOWN")
	spiel.held.richtung = Vector3.ZERO   # losgelassen: _schiebt wartet nicht

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.betrete("inn", Vector2i(1, 1), "DOWN")
	for i in 5: await process_frame
	var k: Karte = spiel.karte
	var wer: Leute = null
	for l in spiel.leute_liste():
		if String(l.daten.get("id", "")) == "rowena": wer = l
	if wer == null:
		pruefe(false, "Rowena fehlt")
	else:
		Leute.still = false
		# eine Stelle ohne Ausweg: vorn und beide Seiten zu, der Held dahinter
		var eng := [Vector2i(-1, -1), Vector2i.ZERO]
		var weit := [Vector2i(-1, -1), Vector2i.ZERO]
		for y in k.hoehe:
			for x in k.breite:
				var t := Vector2i(x, y)
				if not offen(k, t): continue
				for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
					if not offen(k, t - d): continue
					var seiten := [t + Vector2i(d.y, d.x), t - Vector2i(d.y, d.x), t + d]
					var zu := seiten.filter(func(n): return not offen(k, n)).size()
					if zu == 3 and eng[0].x < 0: eng = [t, d]
					if zu == 0 and weit[0].x < 0: weit = [t, d]
		pruefe(eng[0].x >= 0, "Stelle ohne Ausweg in der Schenke: %s" % [eng])
		if eng[0].x >= 0:
			var t: Vector2i = eng[0]; var h: Vector2i = t - eng[1]
			stelle(spiel, wer, t, h)
			await spiel._schiebt(t)
			pruefe(wer.ziel == h, "ohne Ausweg tauscht sie: Ziel %s (Held %s)" % [wer.ziel, h])
			pruefe(spiel.held.frei(wer.position), "waehrend des Tauschs geht der Held durch sie hindurch")
			await create_timer(2.5).timeout
			pruefe(wer.kachel == h, "nach 2 s steht sie auf dem Platz des Helden: %s" % wer.kachel)
		if weit[0].x >= 0:
			var t: Vector2i = weit[0]; var h: Vector2i = t - weit[1]
			stelle(spiel, wer, t, h)
			await spiel._schiebt(t)
			pruefe(wer.ziel.x >= 0 and wer.ziel != h, "mit Platz tritt sie zur Seite: Ziel %s (Held %s)" % [wer.ziel, h])
			pruefe(not spiel.held.frei(wer.position), "beim Seitenschritt sperrt sie weiter")
	print("PLATZWECHSEL %d Fehler" % fehler)
	quit(1 if fehler else 0)
