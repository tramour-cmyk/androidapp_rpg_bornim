extends SceneTree
# 1091 (Chef 13.11., 15:53: „einen hellen Ausgang sehe ich de facto mal auf jeden Fall nicht. So ein Hauch von Licht vorne.“, 15:57:
# „identisch … egal ob 12 Uhr mittags oder 22 Uhr abends“) ohne Bild: Tageslicht des Hoehlenausgangs am Boden des Gangs, gerechnet wie
# Godot (Abfall nach Reichweite, Kegel, Einfallswinkel), mittags und nachts. Alt (MapLight CAVE_EXIT): Licht 3,4 Kacheln um jede
# Ausgangskachel, tags FFF4D8, nachts Mond 3,0 Kacheln schwach. Massgeblich ist die Zeile TAGESLICHT1091.
# Braucht godot/daten wie im Bau (cave.bin, cave-info.json aus hoehle.py).

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

# Godot 4 (scene_forward_lights_inc): Abfall nach Reichweite und Abstand, Kegel mit weichem Rand, Lambert am Boden (Normale nach oben)
static func am_boden(s: SpotLight3D, p: Vector3) -> float:
	var rel := p - s.global_position
	var d := rel.length()
	var nd := d / s.spot_range
	nd = nd * nd; nd = nd * nd
	var abfall := maxf(1.0 - nd, 0.0)
	abfall *= abfall
	abfall *= pow(maxf(d, 0.0001), -s.spot_attenuation)
	var dir := -s.global_transform.basis.z
	var cutoff := cos(deg_to_rad(s.spot_angle))
	var scos := maxf(rel.normalized().dot(dir), cutoff)
	var rim := maxf(0.0001, (1.0 - scos) / (1.0 - cutoff))
	abfall *= 1.0 - pow(rim, s.spot_angle_attenuation)
	var lambert := maxf(0.0, -rel.normalized().y)
	return s.light_energy * abfall * lambert

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.setze("cave_seen")
	spiel.betrete("cave", Vector2i(10, 17), "DOWN")
	for i in 3: await process_frame
	var ts := Karte.TS
	var nr: int = spiel.karte.hoehe
	var spot: SpotLight3D = null
	for f in spiel.gebiet.raumlicht.fenster:
		var s: SpotLight3D = f[0]
		if s.global_position.z > (nr - 1) * ts: spot = s
	pruefe(spot != null, "Tageslicht am Ausgang vorhanden")
	if spot == null:
		print("TAGESLICHT1091 FEHLER kein Licht"); quit(1); return
	print("1091 Licht bei %s, Reichweite %.2f m, Winkel %.0f" % [spot.global_position, spot.spot_range, spot.spot_angle])
	var werte := {}
	for z in [["mittag", 0.0], ["nacht", 1.0]]:
		spiel.licht.stelle(z[1]); spiel._nacht(z[1])
		var zeile := []
		# Mitte jeder Zeile im Gang, von der Ausgangskachel (nr - 1) bis vier Kacheln hinein
		for r in range(nr - 1, nr - 6, -1):
			var e := am_boden(spot, Vector3(spot.global_position.x, 0.0, (r + 0.5) * ts))
			zeile.append(e)
		werte[z[0]] = zeile
		print("1091 %s Boden je Zeile %s: %s" % [z[0], range(nr - 1, nr - 6, -1), zeile.map(func(e): return "%.2f" % e)])
	# alt: 3,4 Kacheln um die Ausgangskachel; drei Kacheln hinein (Zeile nr − 4, erste Zeile des Raums vor dem Gang) noch Licht
	var tag: Array = werte["mittag"]; var nacht: Array = werte["nacht"]
	pruefe(tag[0] >= 0.6, "mittags an der Ausgangskachel hell (%.2f, mindestens 0,6)" % tag[0])
	pruefe(tag[3] >= 0.25, "mittags drei Kacheln hinein noch Tageslicht (%.2f, mindestens 0,25; alt 3,4 Kacheln)" % tag[3])
	pruefe(nacht[0] <= 0.5 * tag[0], "nachts an der Ausgangskachel hoechstens halb so hell wie mittags (%.2f gegen %.2f)" % [nacht[0], tag[0]])
	print("TAGESLICHT1091 " + ("gut" if fehler == 0 else "FEHLER %d" % fehler))
	quit(1 if fehler else 0)
