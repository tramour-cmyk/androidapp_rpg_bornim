extends SceneTree
# 509 ohne Bild: Frösche und Libellen am Teich wie alt (PondLife.kt, PondSound.kt). Ein runder Teich auf einer kleinen Karte mit
# Bodenmaske wie dorf.py (Alpha = Wasserfeld): Plätze am Ufer, Libellen über tiefem Wasser; Frosch springt, wenn der Held nah
# kommt, kommt zurück, wenn er fort ist; Ruf und Chor in der Dämmerung, Schwirren nah; Libellen nachts fort; keine Sprünge.
# Aufruf: im Ordner godot mit -s res://tests/teich_509.gd; maßgeblich ist die Zeile TEICH509.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	var ts := Karte.TS
	var k := Karte.new()
	k.id = "teich_probe"
	k.breite = 9; k.hoehe = 9
	k.daten = {"rand": "T", "art": "FOREST"}
	var z := PackedStringArray()
	for r in 9:
		var zeile := ""
		for c in 9: zeile += "~" if abs(r - 4) <= 1 and abs(c - 4) <= 1 else ("T" if r == 0 else ".")
		z.append(zeile)
	k.zeilen = z
	var mitte := Vector2(4.5, 4.5) * ts
	var m := Image.create(9 * 16, 9 * 16, false, Image.FORMAT_RGBA8)
	for y in m.get_height():
		for x in m.get_width():
			var p := Vector2((x + 0.5) / 16.0, (y + 0.5) / 16.0) * ts
			m.set_pixel(x, y, Color(0, 0, 0, clampf(1.0 - (p.distance_to(mitte) - 1.0) / 1.5, 0, 1)))
	var held := Node3D.new()
	held.position = Vector3(0.5 * ts, 0, 8.5 * ts)
	var t := Teichleben.baue(k, m, held)
	t._hoeren = false
	root.add_child(t)
	t.set_process(false)
	pruefe(t.froesche.size() >= 1 and t.froesche.size() <= 3, "Frösche am Ufer: %d (alt höchstens 3)" % t.froesche.size())
	pruefe(t.libellen.size() >= 1 and t.libellen.size() <= 2, "Libellen über dem Wasser: %d (alt höchstens 2)" % t.libellen.size())
	for f in t.froesche:
		var u: Vector2 = f["ufer"]
		var wv := t.w(u.x, u.y)
		pruefe(wv >= 0.36 and wv <= 0.47 and k.zeichen(k.pos_kachel(Vector3(u.x, 0, u.y))) != "~", "Frosch am Ufer (Wasserfeld %.2f)" % wv)
		pruefe(t.w(f["wasser"].x, f["wasser"].y) > 0.58, "springt ins Wasser")
	# Tag, Held fern: alle sitzen, Libellen fliegen, keine Sprünge im Bild
	t.nacht_k = 0.0
	var vorher := {}
	var spruenge := 0
	var hoch_min := 9.0; var hoch_max := -9.0; var weg_max := 0.0
	for i in 600:
		t.schritt(33)
		for f in t.froesche:
			var n: Node3D = f["n"]
			if vorher.has(n) and n.position.distance_to(vorher[n]) > 0.2: spruenge += 1
			vorher[n] = n.position
		for l in t.libellen:
			var n: Node3D = l["n"]
			if vorher.has(n) and n.position.distance_to(vorher[n]) > 0.2: spruenge += 1
			vorher[n] = n.position
			hoch_min = minf(hoch_min, n.position.y - Teichleben.SPIEGEL); hoch_max = maxf(hoch_max, n.position.y - Teichleben.SPIEGEL)
			weg_max = maxf(weg_max, Vector2(n.position.x, n.position.z).distance_to(l["c"]))
	pruefe(t.froesche.all(func(f): return int(f["lage"]) == Teichleben.SITZT), "Held fern: alle Frösche sitzen")
	pruefe(t.libellen.all(func(l): return (l["n"] as Node3D).visible), "Libellen bei Tag sichtbar")
	pruefe(hoch_min > 0.25 and hoch_max < 0.65, "Libellen 0,25–0,65 m über dem Wasser: %.2f–%.2f" % [hoch_min, hoch_max])
	pruefe(weg_max < 2.0 * 26.0 * Teichleben.PX, "Libellen bleiben bei ihrem Stück Wasser: %.2f m" % weg_max)
	pruefe(spruenge == 0, "keine Sprünge (über 0,2 m in 33 ms): %d" % spruenge)
	# Dämmerung: Rufe und Chor
	t.nacht_k = 0.5
	held.position = Vector3(mitte.x, 0, mitte.y + 3.0 * ts)
	var rufe := 0; var schwirren := 0
	for i in 1800:
		for e in t.schritt(33):
			if e[0] == "frog": rufe += 1
			if e[0] == "dragonfly": schwirren += 1
	pruefe(rufe >= 3, "Frösche rufen in der Dämmerung (60 s): %d" % rufe)
	pruefe(t.chor_ziel(Vector2(held.position.x, held.position.z), true) > 0.0, "Chor in der Dämmerung, 3 Kacheln vom Teich")
	pruefe(t.chor_ziel(Vector2(held.position.x, held.position.z), false) == 0.0, "kein Chor bei Tag")
	t.nacht_k = 0.0
	held.position = Vector3(mitte.x, 0, mitte.y + 1.8)
	for i in 900:
		for e in t.schritt(33):
			if e[0] == "dragonfly": schwirren += 1
	pruefe(schwirren >= 1, "Libelle schwirrt, wenn sie nah vorbeischießt: %d" % schwirren)
	# Held geht an den ersten Frosch: er springt, ist unter Wasser (Ringe), kommt zurück, wenn der Held fort ist
	var f0: Dictionary = t.froesche[0]
	var u0: Vector2 = f0["ufer"]
	held.position = Vector3(u0.x, 0, u0.y) + Vector3(0.8, 0, 0)
	for i in 3: t.schritt(33)
	pruefe(int(f0["lage"]) == Teichleben.SPRINGT, "Held 0,8 m nah: Frosch springt")
	for i in 20: t.schritt(33)
	pruefe(int(f0["lage"]) == Teichleben.UNTER and not (f0["n"] as Node3D).visible and (f0["ringe"][0] as Node3D).visible, "unter Wasser, Ringe auf dem Wasser")
	for i in 300: t.schritt(33)
	pruefe(int(f0["lage"]) == Teichleben.UNTER, "bleibt unten, solange der Held nah ist")
	held.position = Vector3(0.5 * ts, 0, 8.5 * ts)
	var gesehen := {}
	for i in 600:
		t.schritt(33)
		gesehen[int(f0["lage"])] = true
	pruefe(gesehen.has(Teichleben.AUFTAUCHEN) and gesehen.has(Teichleben.SCHWIMMT) and gesehen.has(Teichleben.KLETTERT), "taucht auf, schwimmt, klettert hinaus")
	pruefe(int(f0["lage"]) == Teichleben.SITZT and (f0["n"] as Node3D).position.distance_to(Vector3(u0.x, (f0["n"] as Node3D).position.y, u0.y)) < 0.01, "sitzt wieder an seinem Platz")
	# Nacht: Libellen fort
	t.nacht_k = 1.0
	t.schritt(33)
	pruefe(t.libellen.all(func(l): return not (l["n"] as Node3D).visible), "nachts keine Libellen")
	print("TEICH509 %s, %d Fehler" % ["gut" if fehler == 0 else "FALSCH", fehler])
	quit(1 if fehler else 0)
