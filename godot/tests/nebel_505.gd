extends SceneTree
# 505 ohne Bild: Nebel des Krieges wie alt (Fog.kt). Im Dorf kein Nebel; im Wald: die Kachel des Helden und die vor ihm in Sicht,
# hinter ihm (ausserhalb des kleinen Kreises) nicht, weit weg nie gesehen; ein Baum zwischen Held und Ziel sperrt; Gesehenes bleibt
# nach dem Weitergehen gesehen und kommt aus dem Spielstand wieder; Monster ausser Sicht unsichtbar; Nebelbild blendet zu den Zielen.
# Braucht godot/daten wie im Bau (tools/godot/wald_daten.sh). Massgeblich ist die Zeile NEBEL505.

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
	pruefe(spiel.nebel != null and not spiel.nebel.an, "im Dorf kein Nebel")
	spiel.betrete("forest", Vector2i(9, 26), "UP")
	if spiel.herde: spiel.herde.aus = true
	for i in 3: await process_frame
	var n: Nebel = spiel.nebel
	pruefe(n.an, "im Wald Nebel")
	pruefe(n.nebel(9, 26) == 2, "Kachel des Helden in Sicht")
	pruefe(n.nebel(9, 23) == 2, "drei vor ihm (Weg nach Norden) in Sicht")
	pruefe(n.nebel(9, 29) != 2, "drei hinter ihm nicht in Sicht: %d" % n.nebel(9, 29))
	pruefe(n.nebel(10, 27) == 2, "daneben (kleiner Kreis) in Sicht")
	pruefe(n.nebel(9, 3) == 0, "weit weg nie gesehen")
	pruefe(n.nebel(0, 26) == 1, "Baum ausser Sicht nie schwarz (t732): %d" % n.nebel(0, 26))
	# Zeile 23 „TTTTTff..“: (3, 23) und (4, 23) sind Baeume zwischen (6, 22) und (2, 24)
	pruefe(not n.sicht_frei(6, 22, 2, 24), "Baeume (4, 23), (3, 23) sperren die Sicht von (6, 22) nach (2, 24)")
	pruefe(n.sicht_frei(9, 26, 9, 21), "freier Weg sperrt nicht")
	# Blenden: nach einigen Bildern ist das Nebelbild am Ziel
	for i in 30: await process_frame
	var w := n.breite * Nebel.SUB
	var j := (26 * Nebel.SUB + 1) * w + 9 * Nebel.SUB + 1
	pruefe(n.ist[j] == 0.0 and n.bild.get_pixel(j % w, j / w).r < 0.02, "Nebelbild klar am Helden")
	var k := (3 * Nebel.SUB + 1) * w + 9 * Nebel.SUB + 1
	pruefe(n.bild.get_pixel(k % w, k / w).r > 0.98, "Nebelbild schwarz weit weg")
	# weitergehen: was gesehen war, bleibt gesehen
	spiel.held.setze(Vector2i(9, 18), "UP")
	for i in 3: await process_frame
	pruefe(n.nebel(9, 23) == 1, "(9, 23) nach dem Weitergehen gesehen, nicht in Sicht: %d" % n.nebel(9, 23))
	pruefe(n.nebel(9, 15) == 2, "(9, 15) jetzt in Sicht")
	# Spielstand: erkundet kommt wieder
	var d: Dictionary = spiel.zustand.als_daten()
	var z := Zustand.aus_daten(JSON.parse_string(JSON.stringify(d)))
	var b := Nebel.lade(z, "forest", n.breite * n.hoehe)
	pruefe(b[23 * n.breite + 9] == 1 and b[3 * n.breite + 9] == 0, "erkundet im Spielstand")
	# Monster ausser Sicht unsichtbar
	var h: Herde = spiel.herde
	var aus_sicht := 0; var falsch := 0
	for s in h.liste:
		if not n.zeigt(s.kachel):
			aus_sicht += 1
			if s.visible: falsch += 1
	pruefe(aus_sicht > 0 and falsch == 0, "Monster ausser Sicht unsichtbar (%d ausser Sicht, %d falsch)" % [aus_sicht, falsch])
	# Formen zur Wahl (Vorlage an den Chef): Kreis sieht auch hinter sich
	Nebel.form = "kreis"
	spiel.held.setze(Vector2i(9, 26), "UP")
	for i in 3: await process_frame
	pruefe(n.nebel(9, 29) == 2, "Form Kreis: auch hinter dem Helden in Sicht")
	Nebel.form = "kegel"
	_ende()

func _ende() -> void:
	print("NEBEL505 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
