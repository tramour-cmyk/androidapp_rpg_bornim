extends SceneTree
# 490 ohne Bild: Flüsterwald begehbar wie alt (Story.kt:524). Aus dem Dorf durch den Weg nach Norden in den Wald (Gebietskarte, kein
# Kampf mehr), Held auf dem Weg; Garrick am Feuer; Monster auf der Karte (Anzahl, nur auf hohem Gras, keines am Schutzort); ein
# Jaeger neben dem Helden greift an (Signal kampf, ohne den Kampfort zu oeffnen), nach dem Sieg ist er fort; Rast am Feuer; Truhe
# einmal; Heilkraut pfluecken (Tasche +1 bis 3, danach weg bis morgen); Hoehlenmund als Tuer; Weg zurueck ins Dorf.
# Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/wald_490.gd; massgeblich ist die Zeile WALD490.

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
	# Dorf -> Wald
	var weg: Dictionary = {}
	for a in spiel.karte.daten.get("ausgaenge", []):
		if String(a["ziel"]["karte"]) == "forest": weg = a; break
	pruefe(not weg.is_empty(), "Dorf hat einen Ausgang in den Wald")
	await spiel.geh_hinaus(weg)
	for i in 5: await process_frame
	pruefe(spiel.karte.id == "forest" and spiel.kampf == null and not spiel.im_kampf, "im Wald (Gebietskarte), kein Kampf: %s" % spiel.karte.id)
	pruefe(spiel.karte.begehbar(spiel.held.kachel), "Held auf begehbarem Feld %s" % spiel.held.kachel)
	pruefe(spiel.gebiet.find_child("Dorf_Netz", true, false) != null, "Waldnetz geladen")
	# Garrick
	var garrick = null
	for l in spiel.leute.get_children():
		if l is Leute and String(l.daten.get("id", "")) == "garrick": garrick = l
	pruefe(garrick != null and garrick.kachel == Vector2i(10, 9), "Garrick links vom Feuer (10, 9)")
	# Monster auf der Karte
	var h: Herde = spiel.herde
	pruefe(h != null, "Herde da")
	if h == null:
		_ende(); return
	print("Monster: %s" % ", ".join(h.liste.map(func(s): return "%s %s" % [s.art, s.kachel])))
	pruefe(h.liste.size() >= 5 and h.liste.size() <= 7, "5 bis 7 Monster (alt 7, ohne Gruppe oder Modell weniger): %d" % h.liste.size())
	for s in h.liste:
		pruefe(spiel.karte.zeichen(s.heim) == "," and h.sicher(s.kachel).is_empty(), "%s auf hohem Gras erschienen, nicht am Schutzort" % s.art)
		pruefe(s.figur != null and s.figur.anim != null, "%s mit Modell und Bewegungen" % s.art)
	# ein Jaeger neben dem Helden greift an
	h.kampf.disconnect(spiel._kampf_auf_karte)
	var angriffe := []
	h.kampf.connect(func(m, e, w): angriffe.append([m, e, w]))
	var jaeger: Streuner = null
	for s in h.liste:
		if s.temper() == "JAEGER": jaeger = s; break
	if jaeger:
		var t := Vector2i(15, 9)   # hohes Gras oestlich des Feuers, ausserhalb des Schutzkreises
		spiel.held.setze(Vector2i(16, 9) if spiel.karte.begehbar(Vector2i(16, 9)) else Vector2i(15, 8), "LEFT")
		for s in h.liste:   # die anderen lassen ihn in Ruhe, damit der Angriff von diesem kommt
			if s != jaeger: s.ruhig_bis = 1 << 40; s.jagt = false; s.kachel = s.heim; s.von = s.heim
		jaeger.kachel = t; jaeger.von = t; jaeger.heim = t; jaeger.jagt = true; jaeger.naechst_ms = 0
		jaeger.gang = null; jaeger.position = spiel.karte.kachel_pos(t)   # 744: ein laufender Gang zoege ihn sonst weiter
		h.frieden_bis = 0
		for i in 20:
			h.schritt(0.05)
			if not angriffe.is_empty(): break
		pruefe(not angriffe.is_empty() and angriffe[0][2] == jaeger, "Jaeger neben dem Helden greift an: %s" % [angriffe])
		var vorher := h.liste.size()
		h.nach_kampf(jaeger, "WON")
		pruefe(h.liste.size() == vorher - 1 and Herde.wiederkehr.get("forest", []).size() == 1, "nach dem Sieg fort, kommt nach 60 Schritten wieder")
	else:
		pruefe(false, "kein Jaeger auf der Karte")
	# Schutzort: am Feuer jagt keiner
	spiel.held.setze(Vector2i(10, 10), "UP")
	pruefe(not h.sicher(spiel.held.kachel).is_empty(), "am Feuer sicher")
	# Rast am Feuer, Truhe
	spiel.held.setze(Vector2i(10, 9) + Vector2i(0, 1), "UP")
	pruefe(spiel.rast_kachel(Vector2i(11, 9)) == "feuer", "Feuer zum Rasten")
	spiel.held.setze(Vector2i(16, 5), "UP")
	var k: Dictionary = spiel.kiste(Vector2i(16, 4))
	pruefe(not k.is_empty() and spiel.angebot(Vector2i(16, 5))[0] == "OPEN", "Truhe (16, 4) mit dem Knopf: %s" % [spiel.angebot(Vector2i(16, 5))])
	spiel.held.setze(Vector2i(16, 16), "UP")
	var traenke: int = spiel.zustand.anzahl("potion")
	spiel.oeffne_kiste(spiel.kiste(Vector2i(16, 15)))
	for i in 3: spiel.weiter()
	pruefe(spiel.zustand.anzahl("potion") == traenke + 2 and spiel.zustand.has("kiste:forest_2"), "Truhe forest_2: zwei Heiltraenke")
	spiel.oeffne_kiste(spiel.kiste(Vector2i(16, 15)))
	pruefe(spiel.zustand.anzahl("potion") == traenke + 2, "zweites Oeffnen: leer")
	# Heilkraut
	var kraut := Vector2i(-1, -1)
	for y in spiel.karte.hoehe:
		for x in spiel.karte.breite:
			if kraut.x < 0 and spiel.kraut_da(Vector2i(x, y)): kraut = Vector2i(x, y)
	pruefe(kraut.x >= 0 and spiel.gebiet.kraeuter.size() > 0, "Heilkraeuter auf den Blumenwiesen: %d" % spiel.gebiet.kraeuter.size())
	if kraut.x >= 0:
		var vor: int = spiel.zustand.anzahl("herbs")
		spiel.pfluecke(kraut)
		var n: int = spiel.zustand.anzahl("herbs") - vor
		pruefe(n >= 1 and n <= 3 and not spiel.kraut_da(kraut) and not spiel.gebiet.kraeuter.has(kraut), "gepflueckt +%d, bis morgen weg" % n)
		spiel.zustand.tag += 1
		spiel.kraeuter_neu()
		print("am naechsten Tag dort: %s" % spiel.kraut_da(kraut))
	# Hoehlenmund ist eine Tuer: davor stehen, Knopf
	pruefe(spiel.karte.tuer(Vector2i(10, 0)) and not spiel.karte.begehbar(Vector2i(10, 0)), "Hoehlenmund (10, 0) ist eine Tuer")
	# zurueck ins Dorf
	var raus: Dictionary = {}
	for a in spiel.karte.daten.get("ausgaenge", []):
		if String(a["ziel"]["karte"]) == "village": raus = a; break
	await spiel.geh_hinaus(raus)
	for i in 5: await process_frame
	pruefe(spiel.karte.id == "village" and spiel.herde == null, "zurueck im Dorf, dort keine Monster")
	_ende()

func _ende() -> void:
	print("WALD490 %d Fehler" % fehler)
	quit(1 if fehler else 0)
