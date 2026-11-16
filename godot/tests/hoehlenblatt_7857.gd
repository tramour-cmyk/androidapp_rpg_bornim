extends SceneTree
# 785.7 ohne Bild: die Höhle als Kartenblatt mit Nebel (62o) und ihr Mund auf dem Wald (62p). In der Höhle zeigt der Reiter Karte
# das Blatt der Höhle (nicht die Landkarte), davon nur einen Ausschnitt von 30 Kacheln um das Erkundete wie MapSheet.window;
# auf dem Blatt des Walds öffnet Antippen des Höhlenmunds den Grundriss, sobald der Held in der Höhle war. Maßgeblich ist die
# Zeile HOEHLENBLATT7857.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func hex(ek: PackedByteArray) -> String:
	var s := ""
	var i := 0
	while i < ek.size():
		var v := 0
		for b in 4:
			if i + b < ek.size() and ek[i + b] == 1: v |= 1 << b
		s += "%x" % v
		i += 4
	return s

func auf_blatt(a: Rect2) -> bool:
	return a.position.x >= 0 and a.position.y >= 0 and a.end.x <= 1.0001 and a.end.y <= 1.0001

func _lauf() -> void:
	var z := Zustand.new()
	var k: Dictionary = Kartenreiter.blatt().get("karten", {}).get("cave", {})
	pruefe(k.get("nebel", false) and k.has("fenster"), "Höhle im Kartenblatt mit Nebel und Ausschnitt")
	pruefe(Kartenreiter.bild("karte-cave") != null and Kartenreiter.bild("karte-cave-leer") != null and Kartenreiter.bild("karte-cave-rand") != null, "Blätter der Höhle da (voll, leer, Rand)")
	var w := int(k.get("breite", 0)); var h := int(k.get("hoehe", 0))
	pruefe(Kartenreiter.fenster(z, "cave", k) == Rect2i(0, 0, 30, 30), "nichts erkundet: Ausschnitt 0, 0, 30 × 30 wie alt")
	# gesehen: der Gang vom Eingang (10, 18) nach Norden, Kacheln x 8–13, y 12–19
	var ek := PackedByteArray(); ek.resize(w * h)
	for y in range(12, 20):
		for x in range(8, 14): ek[y * w + x] = 1
	z.erkundet["cave"] = hex(ek)
	var win := Kartenreiter.fenster(z, "cave", k)
	pruefe(win == Rect2i(-4, 1, 30, 30), "Ausschnitt um das Erkundete: %s (erwartet -4, 1, 30 × 30)" % str(win))
	pruefe(auf_blatt(Kartenreiter.ausschnitt(k, win)), "Ausschnitt liegt auf dem Blatt: %s" % str(Kartenreiter.ausschnitt(k, win)))
	# ganz erkundet und jede Ecke allein: der Ausschnitt liegt immer auf dem Blatt
	var alles := PackedByteArray(); alles.resize(w * h); alles.fill(1)
	var z2 := Zustand.new(); z2.erkundet["cave"] = hex(alles)
	var w2 := Kartenreiter.fenster(z2, "cave", k)
	pruefe(w2.encloses(Rect2i(0, 0, w, h)) and auf_blatt(Kartenreiter.ausschnitt(k, w2)), "ganz erkundet: %s deckt die Höhle, liegt auf dem Blatt" % str(w2))
	for ecke in [Vector2i(0, 0), Vector2i(w - 1, 0), Vector2i(0, h - 1), Vector2i(w - 1, h - 1)]:
		var e := PackedByteArray(); e.resize(w * h); e[ecke.y * w + ecke.x] = 1
		var z4 := Zustand.new(); z4.erkundet["cave"] = hex(e)
		pruefe(auf_blatt(Kartenreiter.ausschnitt(k, Kartenreiter.fenster(z4, "cave", k))), "nur Ecke %s erkundet: Ausschnitt auf dem Blatt" % str(ecke))
	z.setze("besucht:cave")
	var r := Kartenreiter.new(z, {"karte": "cave", "x": 10, "y": 18, "blick": "UP"}, 600.0, Callable())
	r.size = Vector2(400, 700)
	root.add_child(r)
	for f in 4: await process_frame
	pruefe(not r.uebersicht and r.gezeigt == "cave", "in der Höhle das Blatt der Höhle, nicht die Landkarte")
	var fl = r.flaeche
	pruefe(fl != null and fl.tex is AtlasTexture and fl.tex.get_size().is_equal_approx(Vector2(780, 780)), "nur der Ausschnitt (780 × 780 Bildpunkte): %s" % (str(fl.tex.get_size()) if fl and fl.tex else "–"))
	var unten: TextureRect = fl.get("unten") if fl else null
	pruefe(unten != null and unten.get_parent() == fl.get_parent(), "Mischblatt unter der Fläche")
	if unten:
		var m := unten.material as ShaderMaterial
		var img: Image = unten.get_meta("maske")
		pruefe(img.get_pixel(10, 18).r > 0.5 and img.get_pixel(3, 2).r < 0.5, "gesehen 1 bei (10, 18), ungesehen 0 bei (3, 2)")
		pruefe(m.get_shader_parameter("ab") == Vector2(-15, -15) and m.get_shader_parameter("blatt") == Vector2(52, 50), "Blatt beginnt bei -15, -15, 52 × 50 Kacheln")
	if fl:
		# Kachel (10, 18) liegt im Ausschnitt (-4, 1) an Rand + 14 bzw. 17 Kacheln
		var b: Dictionary = Kartenreiter.blatt()
		var c := float(b["kachel"]); var rd := float(b["rand"])
		pruefe(absf(fl.cx(10) - (rd + 14 * c + c / 2) * fl.fein) < 0.01 and absf(fl.cy(18) - (rd + 17 * c + c / 2) * fl.fein) < 0.01, "Held an der richtigen Stelle des Ausschnitts")
	r.queue_free()
	# 62p: auf dem Wald öffnet der Mund (10, 0) die Höhle, erst wenn der Held drin war
	var mz := Kartenreiter.hoehlen("forest")
	pruefe(mz.size() == 1 and int(mz[0]["x"]) == 10 and int(mz[0]["y"]) == 0 and mz[0]["ziel"] == "cave", "Wald hat einen Höhlenmund bei (10, 0)")
	pruefe(Kartenreiter.hoehlen("cave").is_empty() and Kartenreiter.hoehlen("village").is_empty(), "Höhle und Dorf ohne Höhlenmund")
	for besucht in [false, true]:
		var z3 := Zustand.new()
		if besucht: z3.setze("besucht:cave")
		var r3 := Kartenreiter.new(z3, {"karte": "forest", "x": 10, "y": 2, "blick": "UP"}, 600.0, Callable())
		r3.size = Vector2(400, 700)
		root.add_child(r3)
		for f in 4: await process_frame
		var f3 = r3.flaeche
		f3.tippe(f3.an(10, 0))
		for f in 3: await process_frame
		if besucht: pruefe(r3.gezeigt == "cave" and not r3.uebersicht, "Mund antippen öffnet die Höhle, nachdem der Held drin war")
		else: pruefe(r3.gezeigt == "forest", "Mund antippen öffnet nichts, solange der Held nicht drin war")
		r3.queue_free()
	print("HOEHLENBLATT7857 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
