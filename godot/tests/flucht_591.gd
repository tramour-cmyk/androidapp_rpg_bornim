extends SceneTree
# 591 ohne Bild: Huhn und Kaninchen fliehen vor dem Helden wie alt (MapHen FLEE/WARY): näher als 1,45 Kacheln rennt das Tier
# weg, bis 2,8 Kacheln; dann 2,5 s wachsam; danach streift es heim. Die Ziege bleibt stehen. Aufruf: im Ordner godot mit
# -s res://tests/flucht_591.gd

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var k := Karte.lade("village")
	var held := Node3D.new()
	root.add_child(held)
	var eltern := Node3D.new()   # nicht im Baum: kein _ready, kein Modell noetig
	var start := Vector2i(27, 24)   # Kaninchen am Ufer (Leute.DORFTIERE)
	var l := Leute.new(k, {"id": "kaninchen1", "x": start.x, "y": start.y, "streifen": 2, "tier": "kaninchen", "fell": "grau"}, held)
	eltern.add_child(l)
	l.position = k.kachel_pos(l.kachel)
	if not Leute.tierboden(k, start): fehler += 1; print("FEHLER kein Tierboden bei ", start)
	# Held weit weg: keine Flucht
	held.position = k.kachel_pos(start + Vector2i(-4, 0))
	if l.fliehe(): fehler += 1; print("FEHLER flieht auf 4 Kacheln")
	# Held kommt von Westen auf die Nachbarkachel: das Kaninchen rennt nach Osten (weg vom Helden)
	held.position = k.kachel_pos(start + Vector2i(-1, 0))
	if not l.fliehe(): fehler += 1; print("FEHLER flieht nicht")
	if not l.flucht: fehler += 1; print("FEHLER flucht nicht gesetzt")
	if l.ziel.x <= start.x: fehler += 1; print("FEHLER Ziel nicht vom Helden weg: ", l.ziel)
	print("Flucht 591: von ", start, " nach ", l.ziel, ", Tempo ", "%.2f" % l.flucht_tempo(), " m/s")
	# laufen lassen wie im Spiel, bis es sicher steht
	var t := 0.0
	var max_ab := 0.0
	while t < 8.0 and (l.flucht or l.ziel.x >= 0):
		l._process(1.0 / 30.0)
		t += 1.0 / 30.0
		max_ab = maxf(max_ab, l.held_abstand())
		if absi(l.kachel.x - l.heim.x) + absi(l.kachel.y - l.heim.y) > Leute.FLUCHT_LEINE: fehler += 1; print("FEHLER über die Leine: ", l.kachel); break
	if l.flucht: fehler += 1; print("FEHLER nach 8 s noch auf der Flucht")
	if l.held_abstand() < Leute.FLUCHT_SICHER and max_ab < Leute.FLUCHT_SICHER:
		print("Flucht 591: eingeklemmt bei ", l.kachel, " (", "%.1f" % l.held_abstand(), " Kacheln)")
	print("Flucht 591: steht nach %.1f s bei %s, %.1f Kacheln vom Helden, wartet %.1f s" % [t, l.kachel, l.held_abstand(), l.warte])
	if l.ziel.x < 0 and absf(l.warte - Leute.WACHSAM) > 0.05 and l.held_abstand() > Leute.FLUCHT_SICHER: fehler += 1; print("FEHLER nicht wachsam: ", l.warte)
	# Held geht weg: nach der Wache streift es heim
	held.position = k.kachel_pos(start + Vector2i(-12, 0))
	# weiter weg als sein Streifen (nach einer langen Flucht): an einen Tierboden 3–4 Kacheln von daheim
	for dx in range(-4, 5):
		for dy in range(-4, 5):
			var q := start + Vector2i(dx, dy)
			if absi(dx) + absi(dy) >= 3 and absi(dx) + absi(dy) <= Leute.FLUCHT_LEINE and Leute.tierboden(k, q) and k.weg(q, start).size() > 0:
				l.kachel = q
	l.position = k.kachel_pos(l.kachel)
	l.ziel = Vector2i(-1, -1)
	var weg_von_heim := absi(l.kachel.x - l.heim.x) + absi(l.kachel.y - l.heim.y)
	t = 0.0
	while t < 30.0 and absi(l.kachel.x - l.heim.x) + absi(l.kachel.y - l.heim.y) > l.streifen_n:
		l._process(1.0 / 30.0)
		t += 1.0 / 30.0
	var zuletzt := absi(l.kachel.x - l.heim.x) + absi(l.kachel.y - l.heim.y)
	print("Flucht 591: zurück von %d auf %d Kacheln von daheim in %.1f s" % [weg_von_heim, zuletzt, t])
	if zuletzt > l.streifen_n: fehler += 1; print("FEHLER nicht heimgekehrt")
	# die Ziege flieht nicht
	var z := Leute.new(k, {"id": "ziege1", "x": 30, "y": 27, "streifen": 2, "tier": "ziege", "fell": "natur"}, held)
	eltern.add_child(z)
	z.position = k.kachel_pos(z.kachel)
	held.position = k.kachel_pos(Vector2i(29, 27))
	if z.fliehe(): fehler += 1; print("FEHLER Ziege flieht")
	# Leute fliehen nicht
	var p := Leute.new(k, {"id": "probe", "x": 20, "y": 13}, held)
	eltern.add_child(p)
	p.position = k.kachel_pos(p.kachel)
	held.position = k.kachel_pos(Vector2i(19, 13))
	if p.fliehe(): fehler += 1; print("FEHLER Person flieht")
	print("ok Flucht 591" if fehler == 0 else "FEHLER Flucht 591: %d" % fehler)
	eltern.free()
	quit(1 if fehler else 0)
