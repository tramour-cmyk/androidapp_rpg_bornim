extends SceneTree
# 540 (t274.12: am Gerät kein Text am Südrand): der Held läuft mit dem Joystick nach Süden gegen den Dorfrand (Ausgänge y 31,
# umkehren), gerade und schräg; stößt er an, kommt der Gedanke (spiel.gd _stoesst). Ohne Bild. Aufruf: im Ordner godot mit
# -s res://tests/suedrand_540.gd -> „SUEDRAND540 n Fehler“

func _initialize() -> void: _lauf.call_deferred()

func lauf(k: Karte, start: Vector2i, r: Vector3, sek: float) -> Array:
	var h := Held.new(k)
	root.add_child(h)
	h.setze(start, "DOWN")
	var st := []
	h.stoesst.connect(func(t): st.append(t))
	h.richtung = r
	var t := 0.0
	while t < sek:
		h._process(1.0 / 30.0)
		t += 1.0 / 30.0
	var wo := h.kachel
	h.free()
	return [st, wo]

func _lauf() -> void:
	var fehler := 0
	var k := Karte.lade("village")
	for x in [15, 17, 20]: print("Kachel %d/30 begehbar %s, %d/31 begehbar %s, sperrt %s" % [x, k.begehbar(Vector2i(x, 30)), x, k.begehbar(Vector2i(x, 31)), not k.sperrt(Vector2i(x, 31)).is_empty()])
	for fall in [["gerade", Vector3(0, 0, 1)], ["schräg", Vector3(0.5, 0, 1).normalized()], ["schräg links", Vector3(-0.5, 0, 1).normalized()]]:
		var e := lauf(k, Vector2i(17, 28), fall[1], 3.0)
		var rand: Array = (e[0] as Array).filter(func(t): return not k.sperrt(t).is_empty() and bool(k.sperrt(t)["umkehren"]))
		print("%s: Stöße %s, steht auf %s" % [fall[0], e[0], e[1]])
		if rand.is_empty(): fehler += 1; print("FEHLER %s: kein Stoß an den Südrand" % fall[0])
		# t274.12: erst der lange Gedanke, beim zweiten Mal der kurze; ein Entlanggleiten darf ihn nicht gleich zweimal auslösen
		if rand.size() > 1: fehler += 1; print("FEHLER %s: %d Stöße in 3 s, der kurze Gedanke käme gleich nach dem langen" % [fall[0], rand.size()])
	print("SUEDRAND540 %d Fehler" % fehler)
	quit(1 if fehler else 0)
