# 744 A (Chef 09.11., 11:18: „nicht wie auf Schienen laufen … nicht ständig laufen, 2 Sekunden maximal Pause, dann wieder drehen auf der
# Stelle wie so ein Roboter … mal verweilen, eine Ruheanimation haben“) ohne Bild: der Bewegungsbaustein gang.gd und sein Einsatz auf der
# Karte (streuner.gd). Bogen ohne Sprung und ohne Drehen auf der Stelle mitten im Gang, weich anlaufen und länger bremsen, Kürzen ohne
# Sprung, Streifgang im Heimradius ohne Ecken abzuschneiden, Verweilen meist 3–12 s, Ruhebewegung beim Verweilen (mit Modell).
# Aufruf: im Ordner godot -s res://tests/gang_744.gd (Exit 0 = alles gut)
extends SceneTree

const DT := 1.0 / 30.0
const MS := 672.0                 # 420 ms * PACE 1,6 auf Gras

var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _pruefe(gut: bool, was: String) -> void:
	print("GANG744 %s %s" % ["gut   " if gut else "FEHLER", was])
	if not gut:
		fehler += 1


func _weg(a: Array) -> Array[Vector2i]:
	var r: Array[Vector2i] = []
	for p in a: r.append(Vector2i(p[0], p[1]))
	return r


## läuft den Gang in Bildern ab: größter Sprung je Bild (Kacheln), größte Drehrate (rad/s), Drehen ohne Weg, Index rückwärts
func _ablauf(g: Gang, von_ms: int, bis_ms: int) -> Dictionary:
	var r := {"sprung": 0.0, "dreh": 0.0, "auf_stelle": 0, "rueck": 0, "bilder": 0}
	var vor := g.lage(von_ms)
	var yaw := g.blick_bei(von_ms)
	var idx := g.index_bei(von_ms)
	var t := von_ms
	while t < bis_ms:
		t += int(DT * 1000)
		var p := g.lage(t)
		var y := g.blick_bei(t)
		var d := p.distance_to(vor)
		var dy := absf(angle_difference(yaw, y))
		r["sprung"] = maxf(r["sprung"], d)
		r["dreh"] = maxf(r["dreh"], dy / DT)
		if dy > 0.02 and d < 0.001: r["auf_stelle"] += 1
		if g.index_bei(t) < idx: r["rueck"] += 1
		idx = g.index_bei(t)
		vor = p
		yaw = y
		r["bilder"] += 1
	return r


func _run() -> void:
	var v_max := DT * 1000.0 / MS        # Kacheln je Bild bei vollem Gehen
	# 1. Bogen um eine Ecke
	var g := Gang.neu(_weg([[5, 5], [6, 5], [7, 5], [7, 6], [7, 7]]), 1000, MS)
	_pruefe(g.lage(1000).distance_to(Vector2(5, 5)) < 0.001, "beginnt auf der Startkachel")
	_pruefe(g.lage(g.ende_ms()).distance_to(Vector2(7, 7)) < 0.001, "endet auf der Mitte der letzten Kachel")
	_pruefe(g.dauer_ms > 4.0 * MS, "dauert länger als 4 Schritte (%.0f ms; Anlauf und Bremsen)" % g.dauer_ms)
	var a := _ablauf(g, 1000, g.ende_ms() + 100)
	_pruefe(a["sprung"] <= v_max * 1.05, "kein Sprung: höchstens %.3f Kacheln je Bild (voll %.3f)" % [a["sprung"], v_max])
	_pruefe(a["dreh"] <= 5.0, "dreht im Gehen, höchstens %.2f rad/s (soll ≤ 5)" % a["dreh"])
	_pruefe(a["auf_stelle"] == 0, "dreht mitten im Gang nie auf der Stelle (%d Bilder)" % a["auf_stelle"])
	_pruefe(a["rueck"] == 0, "Kachel zählt nur vorwärts")
	_pruefe(g.index_bei(g.ende_ms()) == 4, "zählt am Ende auf der letzten Kachel")
	# an der Ecke nicht durch die Mitte der Eckkachel, sondern im Bogen innen vorbei
	var mitte_ecke := 99.0
	for t in range(1000, g.ende_ms(), 10): mitte_ecke = minf(mitte_ecke, g.lage(t).distance_to(Vector2(7, 5)))
	_pruefe(mitte_ecke > 0.15, "Ecke als Bogen: %.2f Kacheln an der Eckmitte vorbei" % mitte_ecke)
	# Anlauf und Bremsen (D1): weich, Bremsen länger als Anlauf
	_pruefe(g.tempo_bei(1000 + 33) < 0.2, "läuft weich an (Tempo %.2f nach einem Bild)" % g.tempo_bei(1033))
	_pruefe(g.tempo_bei(g.ende_ms() - 33) < 0.15, "bremst weich (Tempo %.2f ein Bild vor dem Ende)" % g.tempo_bei(g.ende_ms() - 33))
	var an := 0
	var ab := 0
	for t in range(1000, g.ende_ms(), 5):
		var v := g.tempo_bei(t)
		if v < 0.95 and t < 1000 + g.dauer_ms / 2: an += 5
		elif v < 0.95: ab += 5
	_pruefe(ab > an, "bremst länger (%d ms) als es anläuft (%d ms)" % [ab, an])
	# 2. Kürzen mitten im Gang (ein Jäger bemerkt den Helden)
	g = Gang.neu(_weg([[0, 0], [1, 0], [2, 0], [3, 1], [4, 1], [5, 1]]), 0, MS)
	var tk := int(g.dauer_ms * 0.35)
	var vor_k := g.lage(tk)
	var i_k := g.index_bei(tk)
	g.kuerze(tk)
	_pruefe(g.lage(tk).distance_to(vor_k) < 0.001, "Kürzen ohne Sprung")
	a = _ablauf(g, tk, g.ende_ms() + 100)
	_pruefe(a["sprung"] <= v_max * 1.1 and a["rueck"] == 0, "nach dem Kürzen ohne Sprung (%.3f) und vorwärts" % a["sprung"])
	_pruefe(g.lage(g.ende_ms()).distance_to(Vector2(g.kacheln[i_k + 1])) < 0.001 and g.kacheln.size() == i_k + 2,
		"gekürzt endet es auf der nächsten Kachel (%s)" % str(g.kacheln[-1]))
	_pruefe(g.ende_ms() - tk < 2000, "kommt nach dem Kürzen bald zum Stehen (%d ms)" % (g.ende_ms() - tk))
	# 3. gleich nach dem Betreten einer Kachel enden (die nächste ist belegt)
	g = Gang.neu(_weg([[0, 0], [1, 0], [2, 1], [3, 1]]), 0, MS)
	var th := 0
	while g.index_bei(th) < 2: th += int(DT * 1000)
	vor_k = g.lage(th)
	g.kuerze_hier(th)
	_pruefe(g.lage(th).distance_to(vor_k) < 0.06, "Halt auf dieser Kachel ohne Sprung (%.3f)" % g.lage(th).distance_to(vor_k))
	a = _ablauf(g, th, g.ende_ms() + 100)
	_pruefe(a["sprung"] <= v_max * 1.1 and a["dreh"] <= 5.0, "danach ohne Sprung und ohne Ruck im Blick (%.2f rad/s)" % a["dreh"])
	_pruefe(g.lage(g.ende_ms()).distance_to(Vector2(2, 1)) < 0.001, "steht auf der Mitte der betretenen Kachel")
	# 4. Streifgang um den Heimplatz
	var z := RandomNumberGenerator.new()
	z.seed = 744
	var heim := Vector2i(10, 10)
	var mauer := Vector2i(11, 10)
	var frei := func(p: Vector2i) -> bool: return p != mauer
	var ausserhalb := 0
	var doppelt := 0
	var knick := 0
	var ecke := 0
	var laengen := {}
	var start := heim
	var yaw := 0.0
	for k in 2000:
		var w := Gang.streife(start, yaw, heim, 3, frei, z)
		laengen[w.size()] = laengen.get(w.size(), 0) + 1
		for i in w.size():
			if maxi(absi(w[i].x - heim.x), absi(w[i].y - heim.y)) > 3: ausserhalb += 1
			if w.find(w[i]) != i: doppelt += 1
			if w[i] == mauer: ecke += 1
			if i >= 2:
				var d1 := Vector2(w[i - 1] - w[i - 2])
				var d2 := Vector2(w[i] - w[i - 1])
				if absf(d1.angle_to(d2)) > PI / 4.0 + 0.01: knick += 1
			if i >= 1:
				var d := w[i] - w[i - 1]
				if d.x != 0 and d.y != 0 and (w[i - 1] + Vector2i(d.x, 0) == mauer or w[i - 1] + Vector2i(0, d.y) == mauer): ecke += 1
		if w.size() >= 2:
			start = w[-1]
			yaw = atan2(float(w[-1].x - w[-2].x), float(w[-1].y - w[-2].y))
	_pruefe(ausserhalb == 0, "bleibt im Heimradius 3 (%d außerhalb)" % ausserhalb)
	_pruefe(doppelt == 0, "geht in einem Gang nie über eigene Kacheln zurück")
	_pruefe(knick == 0, "nach dem ersten Schritt höchstens 45° je Kachel (%d Knicke)" % knick)
	_pruefe(ecke == 0, "nie durch die Mauer, keine Ecke abgeschnitten (%d)" % ecke)
	var mehr := 0
	for n in laengen: if n >= 3: mehr += laengen[n]
	_pruefe(mehr >= 1400, "meist Gänge über 2 und mehr Schritte (%d von 2000; Längen %s)" % [mehr, str(laengen)])
	# 5. Verweilen statt Takt von 0,9–2,5 s
	var lang := 0
	var summe := 0
	var hoch := 0
	for k in 2000:
		var m := Gang.verweile_ms(z)
		if m >= 3000: lang += 1
		hoch = maxi(hoch, m)
		summe += m
	_pruefe(lang >= 1700, "verweilt meist 3 s und länger (%d von 2000)" % lang)
	_pruefe(hoch <= 12000 and summe / 2000 >= 5000, "im Mittel %d ms, höchstens %d ms" % [summe / 2000, hoch])
	# 6. auf der Karte: ein Wolf geht den Gang im Bogen, zieht die Kachel nach, steht danach, verweilt mit Ruhebewegung
	var s := Streuner.new()
	s.art = "wolf"
	s.karte = Karte.new()
	s.kachel = Vector2i(5, 5)
	s.heim = s.kachel
	s.von = s.kachel
	s.blick = Vector2i(1, 0)
	root.add_child(s)
	await process_frame
	var mit_bild: bool = s.figur != null and s.figur.anim != null
	if not mit_bild:
		print("GANG744 ohne Modell (%s fehlt): Gehen und Ruhebewegung nicht geprüft" % (String(s.figur._model_path()) if s.figur else "Figur"))
	var jetzt := 10000
	for i in 40:
		s.zeichne(jetzt, DT)
		jetzt += int(DT * 1000)
	var alle := func(_p: Vector2i) -> bool: return true
	s.geh_gang(_weg([[5, 5], [6, 5], [7, 6], [7, 7]]), jetzt, MS)
	var ort := s.position
	var sprung := 0.0
	var gehen := 0
	var bilder := 0
	var kacheln: Array = [s.kachel]
	while s.gang != null and bilder < 400:
		s.gang_takt(jetzt, alle)
		s.zeichne(jetzt, DT)
		sprung = maxf(sprung, s.position.distance_to(ort))
		ort = s.position
		if s.kachel != kacheln[-1]: kacheln.append(s.kachel)
		if mit_bild and s.figur.anim.current_animation == "Gehen": gehen += 1
		bilder += 1
		jetzt += int(DT * 1000)
	_pruefe(kacheln == [Vector2i(5, 5), Vector2i(6, 5), Vector2i(7, 6), Vector2i(7, 7)], "zieht die Kachel mit (%s)" % str(kacheln))
	_pruefe(sprung <= v_max * Karte.TS * 1.1, "Karte: ohne Sprung (%.3f m je Bild)" % sprung)
	_pruefe(s.blick == Vector2i(0, 1), "blickt danach in Richtung des letzten Schritts (%s)" % str(s.blick))
	for i in 20:
		s.zeichne(jetzt, DT)
		jetzt += int(DT * 1000)
	_pruefe(s.position.distance_to(s.karte.kachel_pos(Vector2i(7, 7))) < 0.01, "steht auf der Mitte der letzten Kachel")
	if mit_bild:
		_pruefe(gehen >= bilder * 0.8, "geht im Gang (%d von %d Bildern Gehen)" % [gehen, bilder])
		_pruefe(s.figur.anim.current_animation == "Stehen", "steht danach (%s)" % s.figur.anim.current_animation)
		# Verweilen: binnen 20 s mindestens eine Ruhebewegung, nie dieselbe zweimal hintereinander
		s.verweilen_bis = jetzt + 20000
		s.geste_ab = jetzt
		var gesten: Array = []
		var z2 := RandomNumberGenerator.new()
		z2.seed = 7
		var beginn := Streuner.geste_zuletzt_ms
		while jetzt < s.verweilen_bis:
			s.verweile(jetzt, z2)
			s.zeichne(jetzt, DT)
			if Streuner.geste_zuletzt_ms != beginn:
				beginn = Streuner.geste_zuletzt_ms
				gesten.append(s.geste_vor)
			jetzt += int(DT * 1000)
		_pruefe(not gesten.is_empty(), "verweilt mit Ruhebewegungen (%s)" % str(gesten))
		var zweimal := 0
		for i in range(1, gesten.size()):
			if gesten[i] == gesten[i - 1]: zweimal += 1
		_pruefe(zweimal == 0, "nie dieselbe Ruhebewegung zweimal hintereinander")
	print("GANG744 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
