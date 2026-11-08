extends SceneTree
# 416.8 (Chef 03.11., 07:44: „völlig ohne irgendeine Form der Bewegung … auf der Stelle drehen … wie eine Schachfigur“): ohne Bild.
# Wenden im Stehen mit Schritten: eine Person ohne Modell bekommt einen AnimationPlayer mit Stehen, Drehen_L, Drehen_R (je 1 s) und
# Kurven wie aus geruest.py (90 Grad, langsam an und aus). Geprueft: 180 Grad = zwei Wenden derselben Seite, der Knoten folgt
# der Kurve (Standfuss steht), Tempo wie DREH_ZU, kleine Wenden ohne Schritte, danach Stehen. Mit gebauten Leuten (Kaufmodelle)
# dazu die echte Figur: Standfuss in der Welt waehrend der Wende (cm/s). Aufruf im Ordner godot: -s res://tests/wende_4168.gd
# -> „WENDE n Fehler“

func _initialize() -> void:
	_lauf.call_deferred()

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func kurve90(seite: float) -> PackedFloat32Array:
	var k := PackedFloat32Array()
	for f in 31: k.append(seite * deg_to_rad(90.0) * smoothstep(0.0, 1.0, f / 30.0))
	return k

func spieler(n: Node3D) -> AnimationPlayer:
	var ap := AnimationPlayer.new()
	var lib := AnimationLibrary.new()
	for name in ["Stehen", "Drehen_L", "Drehen_R"]:
		var a := Animation.new()
		a.length = 1.0
		if name == "Stehen": a.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation(name, a)
	ap.add_animation_library("", lib)
	n.add_child(ap)
	return ap

func grad(r: float) -> float:
	return rad_to_deg(r)

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.betrete("village", Vector2i(11, 7), "DOWN")
	for i in 5: await process_frame
	var k: Karte = spiel.karte
	# 4 Kacheln vom Helden (11, 7): weiter als 3, sonst schaut sie von selbst her (schauen_4168), hier nur das Wenden
	var p := Leute.new(k, {"id": "probe_4168", "x": 11, "y": 11, "streifen": 0}, spiel.held)
	spiel.add_child(p)
	await process_frame
	p.warte = 999.0
	p.anim = spieler(p)
	p.anim.play("Stehen")
	p.wende_kurve = {"Drehen_L": kurve90(1.0), "Drehen_R": kurve90(-1.0)}
	# 1) 180 Grad nach links: zwei Wenden Drehen_L, der Knoten folgt der Kurve
	p.rotation.y = 0.0
	p.blick = PI - 0.01
	await process_frame
	pruefe(p.wende == "Drehen_L", "180 Grad links beginnt mit Drehen_L (%s)" % p.wende)
	var erwart := Leute.DREH_STEH * 1.0 / deg_to_rad(90.0)
	pruefe(absf(p.anim.speed_scale - clampf(erwart, 0.7, 2.0)) < 0.01, "Tempo wie DREH_STEH (%.2f, erwartet %.2f)" % [p.anim.speed_scale, erwart])
	var abw := 0.0
	var wenden := {}
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 4000:
		await process_frame
		if p.wende != "":
			wenden[p.wende + str(snappedf(p.wende_start, 0.1))] = true
			if p.anim.current_animation == p.wende:
				var soll := p.wende_start + Leute.kurve(p.wende_kurve[p.wende], p.anim.current_animation_position)
				abw = maxf(abw, absf(angle_difference(p.rotation.y, soll)))
		elif absf(angle_difference(p.rotation.y, p.blick)) < 0.01: break
	pruefe(wenden.size() == 2, "180 Grad = zwei Wenden (%s)" % [wenden.keys()])
	pruefe(abw < deg_to_rad(1.0), "Knoten folgt der Kurve (hoechstens %.2f Grad daneben)" % grad(abw))
	pruefe(absf(angle_difference(p.rotation.y, p.blick)) < 0.02, "am Ziel (%.1f Grad daneben)" % grad(angle_difference(p.rotation.y, p.blick)))
	var dauer := (Time.get_ticks_msec() - t0) / 1000.0
	pruefe(dauer > 1.5 and dauer < 3.2, "180 Grad in %.1f s (DREH_STEH 1,4 rad/s: etwa 2,2 s)" % dauer)
	await process_frame
	pruefe(p.wende == "" and p.anim.current_animation == "Stehen", "danach Stehen (%s)" % p.anim.current_animation)
	# 2) nach rechts 60 Grad: eine Wende Drehen_R, endet am Ziel vor dem Ende der Bewegung
	p.blick = p.rotation.y - deg_to_rad(60.0)
	await process_frame
	pruefe(p.wende == "Drehen_R", "60 Grad rechts mit Drehen_R (%s)" % p.wende)
	for i in 120:
		await process_frame
		if p.wende == "": break
	pruefe(p.wende == "" and absf(angle_difference(p.rotation.y, p.blick)) < deg_to_rad(3.0), "60 Grad: am Ziel, Wende zu Ende (%.1f Grad daneben)" % grad(angle_difference(p.rotation.y, p.blick)))
	# 3) 15 Grad: ohne Schritte
	await process_frame
	p.blick = p.rotation.y + deg_to_rad(15.0)
	await process_frame
	pruefe(p.wende == "", "15 Grad ohne Schritte")
	# 4) zugewandt: Tempo DREH_ZU. Der Held steht 4 Kacheln entfernt 120 Grad zur Seite (ein Platzhalter: ohne gebaute Karten fehlt
	# spiel.held, dann setzte stehen() das Zuwenden sofort zurück und wendete mit DREH_STEH, Befund Jerry 08.11., 22:37)
	var hin := Node3D.new()
	spiel.add_child(hin)
	var a := p.rotation.y + deg_to_rad(120.0)
	hin.global_position = p.global_position + Vector3(sin(a), 0.0, cos(a)) * 4.0 * Karte.TS
	var held_vorher := p.held
	p.held = hin
	p.zugewandt_bis = 0
	p.wende_zu()
	await process_frame
	if p.wende != "":
		pruefe(absf(p.anim.speed_scale - clampf(Leute.DREH_ZU / deg_to_rad(90.0), 0.7, 2.0)) < 0.01, "zugewandt: Tempo wie DREH_ZU (%.2f)" % p.anim.speed_scale)
	else:
		pruefe(false, "zugewandt: keine Wende zum Helden (%.1f Grad daneben)" % grad(angle_difference(p.rotation.y, p.blick)))
	p.held = held_vorher
	hin.queue_free()
	p.queue_free()
	# 5) echte Figur (nur mit gebauten Leuten): Standfuss in der Welt waehrend einer Wende
	var echt: Leute = null
	for l in spiel.leute_liste():
		if l is Leute and l.visible and not l.daten.has("tier") and l.wende_kurve.size() == 2 and l.anim: echt = l; break
	if echt == null:
		print("ohne gebaute Leute mit Drehen_L/R (Bau ohne Kaufmodelle): echte Figur nicht geprueft")
	else:
		echt.warte = 999.0
		echt.ziel = Vector2i(-1, -1)
		var sk := Gebiet.finde(echt.modell, "Skeleton3D") as Skeleton3D
		var fuesse := [sk.find_bone("ball_l"), sk.find_bone("ball_r")]
		await create_timer(1.0).timeout
		echt.blick = echt.rotation.y + deg_to_rad(90.0)
		var spur := []
		for i in 200:
			await process_frame
			if echt.wende == "" and i > 2: break
			spur.append(fuesse.map(func(b): return sk.global_transform * sk.get_bone_global_pose(b).origin) + [Time.get_ticks_usec()])
		var tief := 99.0
		for s in spur: tief = minf(tief, minf(s[0].y, s[1].y))
		var v := []
		for i in range(1, spur.size()):
			var dt: float = maxf(1e-4, (spur[i][2] - spur[i - 1][2]) / 1e6)
			for j in 2:
				if spur[i][j].y < tief + 0.015 and spur[i - 1][j].y < tief + 0.015:
					v.append(Vector2(spur[i][j].x - spur[i - 1][j].x, spur[i][j].z - spur[i - 1][j].z).length() / dt * 100.0)
		v.sort()
		var med: float = v[v.size() / 2] if v.size() else 0.0
		print("RUTSCHEN %s: Standfuss %.1f cm/s im Mittel, hoechstens %.1f (%d Bilder)" % [echt.daten["id"], med, v.back() if v.size() else 0.0, spur.size()])
		# erst messen (416.8: „Füße ohne Rutschen (messen)“), die Grenze setzt der erste Lauf; Gehen: gehen_m_je_s ohne Gleiten
		pruefe(spur.size() > 10, "%s: Wende mit Schritten gemessen (%d Bilder)" % [echt.daten["id"], spur.size()])
	print("WENDE %d Fehler" % fehler)
	quit(1 if fehler else 0)
