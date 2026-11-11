extends SceneTree
# 491 ohne Bild: Tiefer Flüsterwald begehbar wie alt (Story.kt:619). Aus dem Flüsterwald nach Osten in den Tiefen Wald (Gebietskarte,
# kein Probekampf mehr); Morwen an ihrem Feuer (25, 30), ihr Gespraech mit Laden und Brauen; Morwens Huette mit verschlossener Tuer;
# Grimmzahn (22, 4) als Modell des Kampforts, angesprochen: Erzaehlung, dann Kampf mit Leibwache (Gruppe GRIMM), besiegt verschwindet
# er; Monster auf der Karte (bis 13, nur auf hohem Gras), Schutz an Morwens Feuer; Schild, vier Truhen; zurueck in den Flüsterwald.
# Braucht godot/daten wie im Bau (tools/godot/wald_daten.sh). Massgeblich ist die Zeile WALD491.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.betrete("forest", Vector2i(18, 10), "RIGHT")
	for i in 3: await process_frame
	var weg: Dictionary = {}
	for a in spiel.karte.daten.get("ausgaenge", []):
		if String(a["ziel"]["karte"]) == "deep_forest": weg = a; break
	pruefe(not weg.is_empty(), "Flüsterwald hat einen Ausgang in den Tiefen Wald")
	await spiel.geh_hinaus(weg)
	for i in 5: await process_frame
	pruefe(spiel.karte.id == "deep_forest" and spiel.kampf == null and not spiel.im_kampf, "im Tiefen Wald (Gebietskarte), kein Kampf: %s" % spiel.karte.id)
	pruefe(spiel.held.kachel == Vector2i(1, 18) or spiel.karte.begehbar(spiel.held.kachel), "Held am Weg %s" % spiel.held.kachel)
	pruefe(spiel.gebiet.find_child("Dorf_Netz", true, false) != null, "Netz des Tiefen Walds geladen")
	# Morwen und Grimmzahn
	var morwen = null; var grimm = null
	for l in spiel.leute.get_children():
		if l is Leute and String(l.daten.get("id", "")) == "morwen": morwen = l
		if l is Leute and String(l.daten.get("id", "")) == "grimfang": grimm = l
	pruefe(morwen != null and morwen.kachel == Vector2i(25, 30), "Morwen an ihrem Feuer (25, 30)")
	var g: Array = Geschichte.gespraech("morwen", spiel.zustand)
	pruefe(g.any(func(c): return String(c["art"]) == "laden" and bool(c.get("brauen", false))), "Morwen: Laden mit Brauen")
	pruefe(grimm != null and grimm.kachel == Vector2i(22, 4) and grimm.modell != null and grimm.anim != null, "Grimmzahn (22, 4) mit Modell und Bewegungen")
	pruefe(grimm != null and spiel.held.leute.has(grimm), "Grimmzahn steht im Weg wie eine Person (Held.leute)")
	var gs: Array = Geschichte.gespraech("grimfang", spiel.zustand)
	var kampf: Array = gs.filter(func(c): return String(c["art"]) == "kampf")
	pruefe(kampf.size() == 1 and String(kampf[0]["monster"]) == "dire_wolf" and Streuner.GRUPPE.get("dire_wolf", "") == "GRIMM",
		"Grimmzahn angesprochen: Kampf mit Leibwache (GRIMM)")
	pruefe(String(gs[0]["art"]) == "sagen" and String(gs[gs.size() - 1]["art"]) == "sagen", "davor und danach erzaehlt")
	# besiegt: die Flagge, dann ist er fort
	spiel.zustand.setze(Geschichte.GRIMFANG_DEFEATED)
	spiel.sichtbar_neu()
	pruefe(grimm != null and not grimm.visible and not spiel.leute_liste().has(grimm), "besiegt: Grimmzahn fort")
	# Huette, Schild, Truhen
	pruefe(bool(spiel.karte.ausgang(Vector2i(23, 28)).get("verschlossen", false)) and not spiel.karte.begehbar(Vector2i(23, 28)), "Morwens Huette: Tuer (23, 28) verschlossen")
	pruefe(spiel.gebiet.find_child("Gruppe_haus_22_26", true, false) != null, "Morwens Huette steht (Gruppe_haus_22_26, 664: drei mal drei)")
	for k in [Vector2i(22, 28), Vector2i(24, 28), Vector2i(22, 26)]: pruefe(not spiel.karte.begehbar(k), "664: Huette drei mal drei, %s nicht begehbar" % k)
	pruefe(spiel.zeichen_lesbar(Vector2i(3, 19)), "Schild am Weg (3, 19)")
	var kisten := 0
	for t in [Vector2i(37, 7), Vector2i(9, 32), Vector2i(39, 31), Vector2i(27, 4)]:
		if not spiel.kiste(t).is_empty(): kisten += 1
	pruefe(kisten == 4, "vier Truhen: %d" % kisten)
	# Monster der Karte
	var h: Herde = spiel.herde
	pruefe(h != null and h.liste.size() >= 6 and h.liste.size() <= 13, "Monster auf der Karte (alt 13, ohne Gruppe oder Modell weniger): %d" % (h.liste.size() if h else -1))
	if h:
		var falsch := h.liste.filter(func(s): return spiel.karte.zeichen(s.heim) != "," or not h.sicher(s.kachel).is_empty())
		pruefe(falsch.is_empty(), "alle auf hohem Gras, keines am Schutzort")
		spiel.held.setze(Vector2i(21, 22), "UP")
		pruefe(not h.sicher(spiel.held.kachel).is_empty(), "an Morwens Feuer sicher")
	# zurueck
	var raus: Dictionary = {}
	for a in spiel.karte.daten.get("ausgaenge", []):
		if String(a["ziel"]["karte"]) == "forest": raus = a; break
	await spiel.geh_hinaus(raus)
	for i in 5: await process_frame
	pruefe(spiel.karte.id == "forest" and spiel.held.kachel == Vector2i(18, 10), "zurueck im Flüsterwald (18, 10): %s %s" % [spiel.karte.id, spiel.held.kachel])
	_ende()

func _ende() -> void:
	print("WALD491 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
