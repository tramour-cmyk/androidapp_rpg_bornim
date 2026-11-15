extends SceneTree
# 416.2 (Chef 02.11., 10:52, Build 146, 146.5: „Ziege wird geschoben, kein Platztausch“): ohne Bild. Die Ziege im Dorf suedlich
# des Flusses, der Held haelt von jeder Seite gegen sie; gemessen: kommt er binnen 6 s an ihr vorbei, wie oft tritt sie, tauscht sie.
# Aufruf: im Ordner godot mit -s res://tests/ziege_4162.gd -> „ZIEGE n Fehler“

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

# 1079 (Lauf 413, 450, 467 rot nur auf dem Bauserver, am Rechner ohne Kaufmodelle grün): beim ersten Schritt der Ziege, wer um den
# Helden steht und ob der Platztausch frei waere (Leute.weiche: Nachbar und frei_fuer_mich), damit ein Rot die Ursache zeigt
func _umfeld(spiel, z: Leute, h: Vector2i) -> void:
	var hk: Vector2i = z.held_kachel()
	var nah := []
	for l in spiel.leute.get_children():
		if l is Leute and l != z and (absi(l.kachel.x - hk.x) + absi(l.kachel.y - hk.y) <= 2 or absi(l.ziel.x - hk.x) + absi(l.ziel.y - hk.y) <= 1):
			nah.append("%s %s -> %s%s%s" % [l.daten.get("id", "?"), l.kachel, l.ziel, "" if l.visible else " unsichtbar", " Flucht" if l.flucht else ""])
	print("Umfeld Held %s (gestellt %s, Position %s), Ziege Leib %.2f, frei %s; nah: %s" % [hk, h, spiel.held.position, z.leib, z.frei_fuer_mich(hk, true), nah])

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.betrete("village", Vector2i(30, 25), "DOWN")
	for i in 5: await process_frame
	var k: Karte = spiel.karte
	var z: Leute = null
	for l in spiel.leute_liste():
		if String(l.daten.get("tier", "")) == "ziege" or String(l.daten.get("id", "")).begins_with("ziege"): z = l
	if z == null:
		# am Rechner ohne gekaufte Tiermodelle (daten/dorftiere): eine Ziege wie Leute.dorftiere, Leib wie Laenge 1 m
		var p: Array = Leute.DORFTIERE["village"][0]
		z = Leute.new(k, {"id": "ziege1", "x": p[1], "y": p[2], "blick": "DOWN", "streifen": 2, "tier": "ziege"}, spiel.held)
		spiel.leute.add_child(z)
		z.leib = 0.65
		print("Ziege selbst gestellt (ohne Modell)")
		# 1079: die Hühner wie Leute.dorftiere am Heuhaufen (33, 28), (33, 29), sonst fehlen sie am Rechner
		for hp in [Vector2i(32, 28), Vector2i(33, 27), Vector2i(32, 29), Vector2i(34, 29)]:
			spiel.leute.add_child(Leute.new(k, {"id": "huhn_%d_%d" % [hp.x, hp.y], "x": hp.x, "y": hp.y, "blick": "DOWN", "streifen": 2, "tier": "huhn"}, spiel.held))
		spiel.held.leute = spiel.leute.get_children()
	Leute.still = false
	var start := z.kachel
	print("Ziege auf ", start, " Daten ", z.daten)
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var h: Vector2i = start - d
		if not (k.begehbar(h) and k.begehbar(start + d)): print("Seite ", d, ": Held- oder Zielkachel zu"); continue
		z.ziel = Vector2i(-1, -1); z.warte = 30.0; z.durch_bis = 0
		z.kachel = start; z.position = k.kachel_pos(start)
		spiel.held.setze(h, "DOWN")
		spiel.held.richtung = Vector3(d.x, 0, d.y)
		var tritte := []; var vorbei := -1.0
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 6000:
			await process_frame
			if z.ziel.x >= 0 and (tritte.is_empty() or tritte[-1][1] != z.ziel):
				tritte.append([z.kachel, z.ziel, z.durch_bis > Time.get_ticks_msec()])
				if not tritte[-1][2]: print("Ziege tritt ohne Tausch; auf oder unterwegs zur Kachel des Helden: ", im_weg(spiel, z, k.pos_kachel(spiel.held.position)))
				if tritte.size() == 1: _umfeld(spiel, z, h)
			var hk := k.pos_kachel(spiel.held.position)
			if vorbei < 0 and (hk - start) == d: vorbei = (Time.get_ticks_msec() - t0) / 1000.0
		spiel.held.richtung = Vector3.ZERO
		print("Seite ", d, ": Held ", h, " -> ", k.pos_kachel(spiel.held.position), ", vorbei nach ", vorbei, " s; Schritte der Ziege [von, nach, Tausch]: ", tritte)
		pruefe(vorbei >= 0, "von %s kommt der Held an der Ziege vorbei" % [d])
		pruefe(not tritte.is_empty() and tritte[0][1] == h and tritte[0][2], "von %s tauscht die Ziege mit dem Helden den Platz" % [d])
		await create_timer(0.5).timeout
	# 1325 (Lauf 499, 500 rot: von Westen trat die Ziege erst voran, dann Tausch; Ursache am Rechner nachgestellt): wer gerade
	# zur Kachel des Helden unterwegs ist (sein Schritt galt vor dem Helden), sperrte den Tausch. Eine Person geht hinter dem
	# Helden auf dessen Kachel zu, waehrend er von Westen gegen die Ziege drueckt
	var d2 := Vector2i(-1, 0)
	var h2: Vector2i = start - d2
	var p: Leute = null
	for l in spiel.leute_liste():
		if l != z and not l.daten.has("tier") and not l.daten.has("runde"): p = l; break
	var von := h2 + Vector2i(1, 0)
	if p == null and k.begehbar(von):
		# am Rechner ohne Personenmodelle: eine Person wie Leute.alle, ohne Tier
		p = Leute.new(k, {"id": "gaenger", "x": von.x, "y": von.y, "blick": "LEFT", "streifen": 1}, spiel.held)
		spiel.leute.add_child(p)
		spiel.held.leute = spiel.leute.get_children()
	if p != null and k.begehbar(von):
		z.ziel = Vector2i(-1, -1); z.warte = 30.0; z.durch_bis = 0
		z.kachel = start; z.position = k.kachel_pos(start)
		spiel.held.setze(h2, "DOWN")
		p.kachel = von; p.position = k.kachel_pos(von); p.weg.clear(); p.warte = 30.0; p.ziel = h2
		spiel.held.richtung = Vector3(d2.x, 0, d2.y)
		var erst := []
		var t1 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t1 < 4000 and erst.is_empty():
			await process_frame
			if p.ziel == h2 and p.kachel != h2: p.warte = 30.0
			if z.ziel.x >= 0: erst = [z.kachel, z.ziel, z.durch_bis > Time.get_ticks_msec()]
		spiel.held.richtung = Vector3.ZERO
		print("Seite ", d2, " mit ", p.daten.get("id"), " unterwegs auf ", h2, ": erster Schritt der Ziege ", erst)
		pruefe(not erst.is_empty() and erst[1] == h2 and erst[2], "1325: tauscht auch, wenn jemand zur Kachel des Helden unterwegs ist")
	else:
		print("Seite 1325: keine Person oder Kachel ", von, " zu")
	print("ZIEGE %d Fehler" % fehler)
	quit(1 if fehler else 0)

# 1325: wer auf der Kachel h steht oder zu ihr unterwegs ist (ausser der Ziege)
func im_weg(spiel, z, h: Vector2i) -> Array:
	var r := []
	for l in spiel.leute_liste():
		if l != z and (l.kachel == h or l.ziel == h): r.append([l.daten.get("id"), l.kachel, l.ziel, l.flucht])
	return r
