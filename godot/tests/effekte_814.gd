extends SceneTree
# 814 (Spike): Effekte Szene 1 Dorf am Abend (dorfeffekte.gd) ohne Bild: im Dorf am Abend Kaminrauch an jedem Kamin statt unseres
# Rauchs, zwei Fackeln am Schlagbaum und eine an der Schenke (brennen), die Fahne, Fussstaub auf dem Erdweg, Federn beim Huhn;
# Staub im Licht in Schenke und Laden; ausgeschaltet (Testmenue „Gras“, DorfEffekte.an) alles weg und unser Rauch wieder da.
# Ohne Pakete (kein KAUF_TOKEN): nur „ohne Pakete“ und Ende 0. Ausgabe „EFFEKTE814 <n> Fehler“.
#   ~/godot/godot --headless --path . -s res://tests/effekte_814.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func warte(n: int) -> void:
	for i in n: await process_frame

func _lauf() -> void:
	if not DorfEffekte.da():
		print("EFFEKTE814 ohne Pakete, nichts zu pruefen")
		print("EFFEKTE814 0 Fehler")
		quit(0)
		return
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await warte(5)
	spiel.zustand.minuten = 20 * 60 + 30
	spiel.betrete("village", Vector2i(17, 4), "UP")
	await warte(10)
	var g: Gebiet = spiel.gebiet
	var fx: DorfEffekte = g.effekte
	pruefe(fx != null, "Dorf: Effekte gebaut")
	if fx == null:
		print("EFFEKTE814 %d Fehler" % fehler); quit(1); return
	var kamine := (g.info["lichter"] as Array).filter(func(l): return l["art"] == "rauch").size()
	pruefe(kamine > 0 and fx.kaminrauch.size() == kamine, "Kaminrauch an jedem Kamin: %d von %d" % [fx.kaminrauch.size(), kamine])
	var unser := g.rauch.filter(func(r): return r.visible and not g.feuer.any(func(f): return f["rauch"] == r)).size()
	pruefe(unser == 0, "unser Kaminrauch aus (sichtbar %d)" % unser)
	for k in fx.kaminrauch:
		pruefe(k.find_child("Embers", true, false) == null, "Kaminrauch ohne Glut")
		break
	pruefe(fx.fackeln.size() == 3, "drei Fackeln (Schlagbaum 2, Schenke 1): %d" % fx.fackeln.size())
	var nb: Nebel = spiel.nebel
	for f in fx.fackeln:
		var o: OmniLight3D = f["licht"]
		var t: Vector2i = g.karte.pos_kachel(o.global_position)
		print("        Fackel %s brennt %s, Licht sichtbar %s, Nebel %s" % [t, f["brennt"], o.visible, str(nb.nebel(t.x, t.y)) if nb and nb.an else "aus"])
	pruefe(fx.fackeln.all(func(f): return f["brennt"]), "Fackeln brennen am Abend (nacht %.2f)" % fx.nacht_k)
	# 505: ein Licht auf nie gesehener Kachel bleibt aus, bis der Held dort war (nebel.gd dinge_zeigen); mit „alles sichtbar“ alle
	Testmodus.alles_sichtbar = true
	if nb: nb.dinge_zeigen()
	pruefe(fx.fackeln.all(func(f): return (f["licht"] as OmniLight3D).visible), "Fackeln leuchten (alles sichtbar)")
	Testmodus.alles_sichtbar = false
	if nb: nb.dinge_zeigen()
	pruefe(fx.stoffe.size() == 1, "eine Fahne: %d" % fx.stoffe.size())
	pruefe(g.insel_liste.size() == g.insel_ohne.size() + 1, "Lichtinsel der Schenkenfackel: %d -> %d" % [g.insel_ohne.size(), g.insel_liste.size()])
	pruefe(fx.laub.size() > 0, "Laub im Wind: %d Materialien" % fx.laub.size())
	# Fussstaub: Erde vor dem Schlagbaum (Strasse „==“ ist Erde in der Bodenmaske)
	pruefe(fx.erde(g.karte.kachel_pos(Vector2i(17, 6))), "Erdweg bei (17, 6) ist Erde")
	pruefe(not fx.erde(g.karte.kachel_pos(Vector2i(16, 14))), "Dorfplatz (16, 14) ist keine Erde (Pflaster)")
	# dritter Fund t278.2 (unsichtbar): Ausblendung am Boden hoechstens 5 cm, ohne Funken, Puffs gross, deckend und lang genug
	var fs := fx.fussstaub(g.karte.kachel_pos(Vector2i(17, 6)) + Vector3(0, 0.02, 0), false)
	pruefe(fs != null, "Fussstaub gesetzt")
	if fs:
		var puffs := fs.get_node_or_null("Puffs") as GPUParticles3D
		var mat := puffs.material_override as ShaderMaterial if puffs else null
		pruefe(fs.get_node_or_null("Specks") == null, "Fussstaub ohne Funken")
		pruefe(mat != null and float(mat.get_shader_parameter("proximity_fade")) <= 0.05, "Fussstaub: Ausblendung am Boden hoechstens 5 cm")
		pruefe(puffs != null and puffs.lifetime >= 1.0, "Fussstaub lebt mindestens 1 s: %.2f" % (puffs.lifetime if puffs else 0.0))
		var pm := puffs.process_material as ParticleProcessMaterial if puffs else null
		pruefe(pm != null and pm.scale_max >= 0.8, "Fussstaub: Puffs bis mindestens 0,8 m: %.2f" % (pm.scale_max if pm else 0.0))
		var hoch := 0.0
		if pm: for i in pm.color_ramp.gradient.get_point_count(): hoch = maxf(hoch, pm.color_ramp.gradient.get_color(i).a)
		pruefe(hoch >= 0.8, "Fussstaub: am dichtesten mindestens 80 %% deckend: %.2f" % hoch)
	var vor := fx.get_child_count()
	fx.federn(g.karte.kachel_pos(Vector2i(10, 28)))
	await warte(2)
	pruefe(fx.get_child_count() == vor + 1, "Federn beim Huhn")
	# 492/505: Abend nach dem Tag ueber spiel._nacht (wie die Uhr): Fackeln auf nie gesehenen Kacheln bleiben unter dem Nebel aus
	if nb and nb.an:
		spiel._nacht(0.0)
		spiel._nacht(0.75)
		var soll := fx.fackeln.map(func(f): return (f["licht"] as OmniLight3D).visible)
		nb.dinge_zeigen()
		pruefe(soll == fx.fackeln.map(func(f): return (f["licht"] as OmniLight3D).visible), "Abend: Fackeln unter dem Nebel bleiben aus (505) %s" % [soll])
	# Tag: Fackeln kalt
	g.nacht(0.0)
	pruefe(fx.fackeln.all(func(f): return not f["brennt"] and not (f["fx"] as Node3D).visible), "am Tag brennen die Fackeln nicht")
	g.nacht(0.7)
	# ausschalten (Testmenue „Gras“ schaltet bis zum Umzugsende auch die Effekte)
	GrasBausatz.an = false
	g.gras_neu()
	await warte(3)
	pruefe(g.effekte == null and not is_instance_valid(fx), "aus: Effekte weg")
	pruefe(g.rauch.all(func(r): return r.visible), "aus: unser Rauch wieder da")
	pruefe(g.insel_liste.size() == g.insel_ohne.size(), "aus: Lichtinseln wie vorher")
	GrasBausatz.an = true
	g.gras_neu()
	await warte(3)
	pruefe(g.effekte != null, "wieder an")
	# Schenke und Laden: kein Staub im Licht (990)
	for ort in ["inn", "shop"]:
		spiel.betrete(ort, Vector2i(4, 6), "UP")
		await warte(10)
		var e: DorfEffekte = spiel.gebiet.effekte
		var staub := 0
		if e: staub = e.get_children().filter(func(c): return String(c.scene_file_path).ends_with("dust_motes.tscn")).size()
		pruefe(staub == 0, "%s: Staub im Licht in Innenräumen (990: entfällt), %d Schwaerme" % [ort, staub])
	print("EFFEKTE814 %d Fehler" % fehler)
	quit(1 if fehler else 0)
