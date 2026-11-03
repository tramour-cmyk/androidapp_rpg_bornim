extends SceneTree
# 530 (Chef 03.11., 23:40, Build 249: „Schlagbaum öffnet sich nicht visuell“): ohne Bild. Ein Balken wie dorf.py
# („Gruppe_schlagbaum“, laengs x, 0,94 bis 1,14 m hoch) haengt gebiet.gd an den Drehpunkt; gemessen: zu bleibt er liegen,
# offen (Spielstand mit barrier_open oder Jorin) steht er senkrecht am Westende, Fuss auf Balkenhoehe; zweimal oeffnen dreht nicht weiter.
# Aufruf: im Ordner godot mit -s res://tests/schlagbaum_530.gd -> „SCHLAGBAUM n Fehler“

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func balken() -> Node3D:
	var netz := Node3D.new()
	var mi := MeshInstance3D.new()
	mi.name = "Gruppe_schlagbaum"
	var bm := BoxMesh.new()
	bm.size = Vector3(1.29, 0.21, 0.12)
	mi.mesh = bm
	mi.position = Vector3(20.3 + 0.645, 1.04, 4.1)   # Westende 20,3 m, Mitte 1,04 m hoch
	netz.add_child(mi)
	return netz

func aabb_welt(mi: MeshInstance3D) -> AABB:
	return mi.global_transform * mi.get_aabb()

func gebiet(flaggen: Dictionary) -> Gebiet:
	var k := Karte.new()
	k.flaggen = flaggen
	return Gebiet.new(k)

func _lauf() -> void:
	# zu: liegt wie gebaut
	var g := gebiet({})
	var netz := balken()
	root.add_child(netz)
	g.baue_schlagbaum(netz)
	var mi := netz.find_child("Gruppe_schlagbaum", true, false) as MeshInstance3D
	var a := aabb_welt(mi)
	pruefe(g.schlagbaum != null, "Drehpunkt gefunden")
	pruefe(absf(a.position.x - 20.3) < 0.01 and absf(a.size.x - 1.29) < 0.01 and absf(a.position.y - 0.935) < 0.01, "zu: Balken liegt wie gebaut (%s)" % a)
	# Jorin oeffnet (ohne Tween: sanft=false)
	g.schlagbaum_auf(false)
	a = aabb_welt(mi)
	print("offen: ", a)
	pruefe(absf(a.size.y - 1.29) < 0.01 and a.size.x < 0.22, "offen: senkrecht (Hoehe %.2f m, Breite %.2f m)" % [a.size.y, a.size.x])
	pruefe(absf(a.position.x - 20.3) < 0.01, "offen: steht am Westende neben dem Drehpfosten (x %.2f)" % a.position.x)
	pruefe(absf(a.position.y - 0.935) < 0.01, "offen: Fuss auf Balkenhoehe (%.2f m)" % a.position.y)
	g.schlagbaum_auf(true)
	pruefe(is_equal_approx(g.schlagbaum.rotation.z, PI / 2), "zweites Oeffnen dreht nicht weiter")
	netz.queue_free()
	g.free()
	# Spielstand mit barrier_open: gleich offen
	var g2 := gebiet({"barrier_open": true})
	var netz2 := balken()
	root.add_child(netz2)
	g2.baue_schlagbaum(netz2)
	var a2 := aabb_welt(netz2.find_child("Gruppe_schlagbaum", true, false) as MeshInstance3D)
	pruefe(absf(a2.size.y - 1.29) < 0.01, "Spielstand geladen: gleich offen (Hoehe %.2f m)" % a2.size.y)
	# im Baum: sanft hoch, nach 2,5 s senkrecht
	var g3 := gebiet({})
	var netz3 := balken()
	root.add_child(netz3)
	g3.baue_schlagbaum(netz3)
	g3.schlagbaum_auf(true)
	var ab := Time.get_ticks_msec()
	var hoechst := 0.0
	var halb := -1.0
	while Time.get_ticks_msec() - ab < 3000:
		await process_frame
		hoechst = maxf(hoechst, g3.schlagbaum.rotation.z)
		if halb < 0.0 and Time.get_ticks_msec() - ab >= 800: halb = g3.schlagbaum.rotation.z
	pruefe(halb > 0.4 and halb < 1.2, "sanft: nach 0,8 s halb oben (%.2f)" % halb)
	pruefe(absf(g3.schlagbaum.rotation.z - PI / 2) < 0.002, "sanft: nach dem Schwingen senkrecht (%.3f)" % g3.schlagbaum.rotation.z)
	pruefe(hoechst > PI / 2 and hoechst < PI / 2 + 0.08, "sanft: federt kurz nach (hoechst %.3f)" % hoechst)
	# im echten Dorf (nur auf dem Bauserver, wo daten/ gebaut ist): das Netz ist da, Jorin oeffnet ihn, er steht dann
	if FileAccess.file_exists("res://daten/" + Gebiet.datei("village") + ".bin"):
		var spiel = load("res://spiel.tscn").instantiate()
		root.add_child(spiel)
		for i in 5: await process_frame
		spiel.zustand.flaggen.erase(Geschichte.BARRIER_OPEN)
		spiel.betrete("village", Vector2i(17, 6), "UP")
		for i in 5: await process_frame
		pruefe(spiel.gebiet.schlagbaum != null, "Dorf: Netz Gruppe_schlagbaum im Dorf gefunden")
		if spiel.gebiet.schlagbaum:
			pruefe(absf(spiel.gebiet.schlagbaum.rotation.z) < 0.01, "Dorf: zu Beginn liegt er")
			spiel.zustand.setze(Geschichte.BARRIER_OPEN)
			spiel.flaggen_neu()
			await create_timer(3.0).timeout
			pruefe(absf(spiel.gebiet.schlagbaum.rotation.z - PI / 2) < 0.01, "Dorf: nach Jorin senkrecht")
			var frei := 0
			for y in spiel.karte.hoehe:
				for x in spiel.karte.breite:
					if spiel.karte.zeichen(Vector2i(x, y)) == "z" and spiel.karte.begehbar(Vector2i(x, y)): frei += 1
			pruefe(frei == 2, "Dorf: beide Kacheln des Schlagbaums begehbar (%d)" % frei)
	else: print("ohne daten/village: Dorfteil nur auf dem Bauserver")
	print("SCHLAGBAUM %d Fehler" % fehler)
	quit(1 if fehler else 0)
