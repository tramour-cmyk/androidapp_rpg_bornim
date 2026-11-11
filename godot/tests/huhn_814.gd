extends SceneTree
# 814 (Chef 11.11., 16:14: „der Held steht direkt beim Hühnchen. Da passiert halt einfach wieder nichts“; Sokrates: Ursache nachstellen,
# Abstand je Bild loggen und welche Bedingung in leute.gd fliehe() greift): der Held geht im Dorf auf jedes Huhn zu; alle 5 Bilder
# Abstand in Kacheln, ob das Huhn gerade läuft (ziel, dann prüft _process fliehe() nicht), still, da, drinnen, flucht, die
# Fluchtkachel und der Abstand von daheim. Ausgabe „HUHN814 …“; am Ende je Huhn, ob es aufflog. Ohne Bild, Ende 0 (nur Messung).
#   ~/godot/godot --headless --path . -s res://tests/huhn_814.gd

var spiel

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 10 * 60
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 10: await process_frame
	var huehner := []
	for l in spiel.leute.get_children():
		if l is Leute and String(l.daten.get("tier", "")) == "huhn": huehner.append(l)
	print("HUHN814 %d Hühner im Dorf" % huehner.size())
	var flogen := 0
	for huhn in huehner:
		var k: Vector2i = huhn.kachel
		var start := k + Vector2i(-3, 0)
		for d in [Vector2i(-3, 0), Vector2i(3, 0), Vector2i(0, 3), Vector2i(0, -3), Vector2i(-2, 0), Vector2i(2, 0), Vector2i(0, 2), Vector2i(0, -2)]:
			if spiel.karte.begehbar(k + d): start = k + d; break
		spiel.held.setze(start, "RIGHT")
		for i in 3: await process_frame
		print("HUHN814 Huhn %s (daheim %s), Held %s, Weg %s" % [huhn.kachel, huhn.heim, start, spiel.held.geh_zu(huhn.position)])
		var flog := false
		var am_naechsten := 99.0
		for i in 240:
			await process_frame
			var a: float = huhn.held_abstand()
			am_naechsten = minf(am_naechsten, a)
			if huhn.flucht and not flog:
				flog = true
				print("HUHN814   fliegt auf nach %.1f s bei %.2f Kacheln" % [i / 60.0, a])
			if i % 5 == 0:
				var fk: Vector2i = huhn.flucht_kachel()
				print("HUHN814   %3d: Abstand %.2f, läuft %s (ziel %s), still %s, da %s, drinnen %s, flucht %s, Fluchtkachel %s, von daheim %d, Held auf %s" % [i,
					a, huhn.ziel.x >= 0, huhn.ziel, huhn.still, huhn.da, huhn.drinnen, huhn.flucht, fk,
					absi(huhn.kachel.x - huhn.heim.x) + absi(huhn.kachel.y - huhn.heim.y), spiel.held.kachel])
			if i % 30 == 29 and not flog: spiel.held.geh_zu(huhn.position)
		print("HUHN814 Huhn %s: %s, am nächsten %.2f Kacheln (FLUCHT_NAH %.2f)" % [huhn.kachel, "flog auf" if flog else "flog NICHT auf", am_naechsten, Leute.FLUCHT_NAH])
		if flog: flogen += 1
		spiel.held.richtung = Vector3.ZERO
		for i in 60: await process_frame
	print("HUHN814 %d von %d Hühnern flogen auf" % [flogen, huehner.size()])
	quit(0)
