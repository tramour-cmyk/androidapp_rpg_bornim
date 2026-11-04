extends SceneTree
# 531 (Chef 03.11., 23:42, Build 249: „vertreibt keine Mobs“): ohne Bild. Flüsterwald: der Held steht an Garricks Feuer (Schutzort),
# ein Jaeger jagt ihn von Osten. Gemessen: kein Kampf, das Tier gibt auf und geht heim, die Meldung kommt; Garrick nimmt die Fackel
# (abwehr.gd), dreht sich zum Tier, die rechte Hand steigt ueber die Schulter, die Fackel schwenkt seitlich und ist danach wieder weg.
# Nur mit daten/ (Bauserver oder tools/godot/wald_daten.sh). Aufruf: im Ordner godot mit -s res://tests/garrick_531.gd -> „GARRICK531 n Fehler“

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _ende() -> void:
	print("GARRICK531 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func _lauf() -> void:
	if not FileAccess.file_exists("res://daten/forest.bin"):
		print("ohne daten/forest: nur auf dem Bauserver")
		_ende(); return
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.betrete("forest", Vector2i(10, 10), "RIGHT")
	for i in 5: await process_frame
	var garrick: Leute = null
	for l in spiel.leute.get_children():
		if l is Leute and String(l.daten.get("id", "")) == "garrick": garrick = l
	var h: Herde = spiel.herde
	pruefe(garrick != null and h != null, "Garrick und Herde da")
	if garrick == null or h == null:
		_ende(); return
	pruefe(not h.sicher(spiel.held.kachel).is_empty(), "Held am Feuer sicher")
	var angriffe := []
	h.kampf.disconnect(spiel._kampf_auf_karte)
	h.kampf.connect(func(m, e, w): angriffe.append(m))
	var meldungen := []
	h.gemeldet.connect(func(t): meldungen.append(t))
	var jaeger: Streuner = null
	for s in h.liste:
		if s.temper() == "JAEGER" and jaeger == null: jaeger = s
		else: s.ruhig_bis = 1 << 40; s.jagt = false
	pruefe(jaeger != null, "ein Jaeger auf der Karte")
	if jaeger == null:
		_ende(); return
	var t := Vector2i(14, 10)
	if not spiel.karte.begehbar(t): t = Vector2i(15, 9)
	jaeger.kachel = t; jaeger.von = t; jaeger.heim = t + Vector2i(3, 0); jaeger.jagt = true; jaeger.naechst_ms = 0
	jaeger.position = spiel.karte.kachel_pos(t)
	h.frieden_bis = 0
	var sk := Gebiet.finde(garrick.modell, "Skeleton3D") as Skeleton3D
	var hand_ueber := -9.0
	var vor := -9.0
	var kopf_abstand := 9.0
	var blick_fehler := 9.0
	var seiten := [0.0, 0.0]
	var fackel_sah := false
	var ab := Time.get_ticks_msec()
	while Time.get_ticks_msec() - ab < 6000:
		await process_frame
		if garrick.abwehr and garrick.abwehr.laeuft() and sk:
			var a := garrick.abwehr
			var s_ := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("upperarm_r")).origin
			# die Schicht wirkt nur innerhalb des Bilds (Godot setzt die Pose danach zurueck): die Fackel sitzt an der gedrehten Hand
			var h_: Vector3 = a.fackel.global_position if a.fackel else s_
			if a.t > 1.0 and a.t < 2.6:
				hand_ueber = maxf(hand_ueber, h_.y - s_.y)
				var zum := Vector3(a.ziel.x - s_.x, 0, a.ziel.z - s_.z).normalized()
				vor = maxf(vor, (h_ - s_).dot(zum))
				# E3: Stiel (0 bis 0,4 m laengs der Fackel) und Flamme nicht an Kopf und Kapuze
				var kopf := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head")).origin + Vector3(0, 0.1, 0)
				var ay: Vector3 = a.fackel.global_basis.y
				for k in 5: kopf_abstand = minf(kopf_abstand, (h_ + ay * (0.1 * k) - kopf).length())
				var soll := atan2(a.ziel.x - garrick.global_position.x, a.ziel.z - garrick.global_position.z)
				blick_fehler = minf(blick_fehler, absf(wrapf(garrick.rotation.y - soll, -PI, PI)))
				var quer := a.schwung()
				seiten[0] = minf(seiten[0], quer); seiten[1] = maxf(seiten[1], quer)
			if a.fackel and a.fackel.visible: fackel_sah = true
	pruefe(angriffe.is_empty(), "am Feuer kein Kampf (%s)" % [angriffe])
	pruefe(not jaeger.jagt, "der Jaeger gibt auf")
	pruefe(not meldungen.is_empty(), "Meldung am Schutzort: %s" % [meldungen])
	pruefe(garrick.abwehr != null, "Garrick nimmt die Fackel")
	pruefe(fackel_sah, "Fackel zu sehen")
	pruefe(hand_ueber > 0.05, "Fackelhand ueber der Schulter (%.2f m)" % hand_ueber)
	pruefe(kopf_abstand > 0.3, "Fackel nicht an Kopf und Kapuze (naechster Punkt %.2f m von der Kopfmitte)" % kopf_abstand)
	pruefe(vor > 0.2, "Fackel vor ihm, zum Tier hin (%.2f m)" % vor)
	pruefe(blick_fehler < 0.35, "Garrick schaut zum Tier (Abweichung %.0f Grad)" % rad_to_deg(blick_fehler))
	pruefe(seiten[0] < -0.8 and seiten[1] > 0.8, "schwenkt links und rechts (%.2f, %.2f)" % seiten)
	pruefe(garrick.abwehr == null or (not garrick.abwehr.laeuft() and not garrick.abwehr.fackel.visible), "danach Fackel wieder weg")
	_ende()
