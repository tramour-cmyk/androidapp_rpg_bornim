extends SceneTree
# 505 ohne Bild: Nebel auf der Karte im Menü (62c). Im Wald zeigt der Reiter Karte das Blatt des Walds (nicht mehr die Landkarte),
# darunter das Mischblatt mit dem Erkundeten (kartennebel.gdshader): gesehene Kacheln 1, ungesehene 0, wie Zustand.erkundet; das Dorf
# ohne Nebel wie bisher. Braucht godot/daten aus core (exportMapSheets). Maßgeblich ist die Zeile KARTENNEBEL505.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var z := Zustand.new()
	var k: Dictionary = Kartenreiter.blatt().get("karten", {}).get("forest", {})
	pruefe(k.get("nebel", false), "Wald im Kartenblatt mit Nebel")
	var w := int(k.get("breite", 0)); var h := int(k.get("hoehe", 0))
	# gesehen: die Kacheln um (9, 26), wie nebel.gd speichert (4 Kacheln je Ziffer)
	var ek := PackedByteArray(); ek.resize(w * h)
	for y in range(23, 30):
		for x in range(6, 13): ek[y * w + x] = 1
	var s := ""
	var i := 0
	while i < ek.size():
		var v := 0
		for b in 4:
			if i + b < ek.size() and ek[i + b] == 1: v |= 1 << b
		s += "%x" % v
		i += 4
	z.erkundet["forest"] = s
	var r := Kartenreiter.new(z, {"karte": "forest", "x": 9, "y": 26, "blick": "UP"}, 600.0, Callable())
	r.size = Vector2(400, 700)
	root.add_child(r)
	for f in 4: await process_frame
	pruefe(not r.uebersicht and r.gezeigt == "forest", "im Wald das Blatt des Walds, nicht die Landkarte")
	var fl = r.flaeche
	var unten: TextureRect = fl.get("unten") if fl else null
	pruefe(unten != null and unten.get_parent() == fl.get_parent(), "Mischblatt unter der Fläche")
	if unten:
		var m := unten.material as ShaderMaterial
		var img: Image = unten.get_meta("maske")
		pruefe(img.get_pixel(9, 26).r > 0.5 and img.get_pixel(1, 3).r < 0.5, "gesehen 1 bei (9, 26), ungesehen 0 bei (1, 3)")
		pruefe(m.get_shader_parameter("leer") != null and m.get_shader_parameter("rand") != null, "leeres Blatt und Rand geladen")
	r.queue_free()
	var r2 := Kartenreiter.new(z, {"karte": "village", "x": 10, "y": 10}, 600.0, Callable())
	root.add_child(r2)
	for f in 3: await process_frame
	pruefe(r2.flaeche != null and r2.flaeche.get("unten") == null, "Dorf ohne Nebel")
	print("KARTENNEBEL505 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
