# 1003 (alt Panting.kt: „A man's or a woman's breath, by the hero“): atemlos keucht die Heldin mit Frauenstimme, der Held mit
# Männerstimme; spiel.gd gibt klang.atme das Geschlecht aus der Erschaffung mit. Ohne Bild, im ganzen Spiel (spiel.tscn); gemessen
# an der Länge des Atemzugs (Klang.atem_ms: Frau 1600 ms, Mann 1420 ms), die Klang nach dem ersten Zug vormerkt.
# Aufruf: im Ordner godot mit -s res://tests/keuchen_1003.gd (Exit 0 = richtig)
extends SceneTree

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _zug(spiel, klang, g: String) -> float:
	spiel.zustand.aussehen["geschlecht"] = g
	spiel.zustand.atemlos = true
	spiel.zustand.ausdauer = 0.0
	klang._atem_naechst = 0.0
	var vorher := float(Time.get_ticks_msec())
	await process_frame
	await process_frame
	return klang._atem_naechst - vorher


func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 10:
		await process_frame
	var klang = root.get_node_or_null("Klang")
	if klang == null or spiel.held == null:
		print("FEHLER kein Klang oder kein Held (Klang %s, Held %s)" % [klang, spiel.held])
		quit(1)
		return
	var w: float = await _zug(spiel, klang, "w")
	var m: float = await _zug(spiel, klang, "m")
	var ok_w: bool = absf(w - klang.atem_ms(true)) < 80.0
	var ok_m: bool = absf(m - klang.atem_ms(false)) < 80.0
	print(("ok     " if ok_w else "FEHLER ") + "Heldin: Atemzug %.0f ms (Frau %.0f)" % [w, klang.atem_ms(true)])
	print(("ok     " if ok_m else "FEHLER ") + "Held: Atemzug %.0f ms (Mann %.0f)" % [m, klang.atem_ms(false)])
	fehler = int(not ok_w) + int(not ok_m)
	print("Keuchen 1003: %s" % ("alles richtig" if fehler == 0 else "%d Fehler" % fehler))
	quit(0 if fehler == 0 else 1)
