extends SceneTree
# 505 ohne Bild: Nebel des Krieges wie alt (Fog.kt). Im Dorf Nebel (505 Lauf 2), Haeuser als Ganzes; im Wald: die Kachel des Helden und die vor ihm in Sicht,
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
	# 505 Lauf 2 (Chef 16:12, 505c (1) Wald, Dorf und Hoehle): auch im Dorf Nebel; ein Haus ist ganz bekannt oder ganz unbekannt
	var nd: Nebel = spiel.nebel
	pruefe(nd != null and nd.an and nd.dorf, "505 Lauf 2: im Dorf Nebel")
	pruefe(not nd.rand_an and nd.flaeche != null, "1022: im Dorf dunkelt der Rand im Netz ab (rand_licht), nicht doppelt im Nebel")
	# neben das erste Haus stellen (vom Start aus ist keins in Sicht)
	var ht: int = nd.haeuser[0][0]
	var neben := Vector2i(-1, -1)
	for d in [Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, 1)]:
		var t: Vector2i = Vector2i(ht % nd.breite, ht / nd.breite) + d
		if neben.x < 0 and nd.innen(t.x, t.y) and spiel.karte.begehbar(t): neben = t
	spiel.held.setze(neben, "UP")
	for i in 10: await process_frame
	var gemischt := 0; var bekannt := 0
	for teile in nd.haeuser:
		var st := {}
		for j in teile: st[nd.nebel(j % nd.breite, j / nd.breite)] = true
		if st.size() > 1: gemischt += 1
		if not st.has(0): bekannt += 1
	pruefe(nd.haeuser.size() >= 5 and gemischt == 0 and bekannt >= 1, "Dorf: %d Haeuser, %d gemischt, %d bekannt" % [nd.haeuser.size(), gemischt, bekannt])
	# Chef 16:12 (1): Schwarz ist 0; Pruefer 17:21: keine Saeume in einem Kanal. Die Umgebung steht auf Kontrast 1, die Farbkorrektur
	# macht den Kontrast oberhalb des Knies nach und laeuft darunter gerade auf 0 (nichts abgeschnitten)
	var env: Environment = spiel.licht.env
	var cc = env.adjustment_color_correction
	var kw: float = spiel.licht.kontrast
	var gr: Gradient = (cc as GradientTexture1D).gradient if cc is GradientTexture1D else null
	pruefe(gr != null and env.adjustment_contrast == 1.0 and kw < 0.95 and gr.sample(0.0).r < 0.002 and gr.sample(0.03).r > 0.03
		and absf(gr.sample(0.5).r - 0.5) < 0.002 and absf(gr.sample(0.8).r - (0.5 + 0.3 * kw)) < 0.003,
		"505 Lauf 2: Schwarz 0, dunkles Gruen 0,03 bleibt %.3f (vorher 0 oder 0,075), Kontrast %.2f darueber" % [gr.sample(0.03).r if gr else -1.0, kw])
	spiel.betrete("forest", Vector2i(9, 26), "UP")
	if spiel.herde: spiel.herde.aus = true
	for i in 3: await process_frame
	var n: Nebel = spiel.nebel
	pruefe(n.an, "im Wald Nebel")
	# 505c (Chef 04.11., 14:06, Zu 505 (Rand)): B gilt, ueber dem Randwald kein Nebel, das Dorf hat nur den Rand ins Dunkel
	# 505 Lauf 2 (Pruefer 16:01, Chef 16:12 (2)): hinter dem Rand der Nebel der Randkachel (keine Kappe), kein heller Wald hinter Schwarz
	pruefe(Nebel.baeume == "boden" and n.rand() == 1.0, "505 Lauf 2: Fassung B, Randwald mit dem Nebel der Randkachel (%s, %.2f)" % [Nebel.baeume, n.rand()])
	pruefe(n.flaeche != null and float(n.mat.get_shader_parameter("rand_schwarz")) > 1.0e5, "1022: Randdunkel im Wald im Netz (rand_licht), nicht doppelt im Nebel")
	n.fassung("alt")   # die alten Pruefungen unten mit A, B folgt weiter unten
	pruefe(n.nebel(9, 26) == 2, "Kachel des Helden in Sicht")
	pruefe(n.nebel(9, 23) == 2, "drei vor ihm (Weg nach Norden) in Sicht")
	pruefe(n.nebel(9, 29) == 2, "drei hinter ihm in Sicht (rundum, Chef 10:08 „505 C“): %d" % n.nebel(9, 29))
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
	# 505c: „erkundet“ deutlich dunkler (GESEHEN statt 0,5): ein Teil zwei Kacheln neben dem Weg ausser Sicht, gesehen
	pruefe(Nebel.GESEHEN >= 0.65 and Nebel.GESEHEN < 0.9, "505c: gesehen %.2f (alt 0,5 zu hell)" % Nebel.GESEHEN)
	var k := (3 * Nebel.SUB + 1) * w + 9 * Nebel.SUB + 1
	pruefe(n.bild.get_pixel(k % w, k / w).r > 0.98, "Nebelbild schwarz weit weg")
	# weitergehen: was gesehen war, bleibt gesehen
	spiel.held.setze(Vector2i(9, 16), "UP")     # rundum: sieben Felder weiter, damit (9, 23) aus der Sicht ist
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
	# Fassung B (Chef 16:13: „… ich sehe trotzdem die Baeume dahinter“): ein Baum zeigt, was der Held vom naechsten Boden weiss
	spiel.held.setze(Vector2i(9, 26), "UP")
	for i in 3: await process_frame
	n.fassung("boden")
	pruefe(n.nebel(0, 26) == 0, "B: Baum (0, 26) neben nie gesehenem Boden schwarz: %d" % n.nebel(0, 26))
	pruefe(n.nebel(13, 23) >= 1, "B: Baum (13, 23) neben gesehenem Weg nicht schwarz: %d" % n.nebel(13, 23))
	var tief := 0
	for i in n.naechster: if (n.naechster[i] as PackedInt32Array).is_empty(): tief += 1
	pruefe(n.naechster.size() > 0 and tief == 0, "B: jeder Baum hat einen naechsten Boden (%d Baeume, %d ohne)" % [n.naechster.size(), tief])
	n.fassung("alt")
	pruefe(n.nebel(0, 26) == 1, "A: Baum ausser Sicht wieder gedaempft (t732): %d" % n.nebel(0, 26))
	# die alte Form (Kegel 160°, Bildlauf --nebel) sieht nicht hinter sich
	Nebel.form = "kegel"
	spiel.held.setze(Vector2i(9, 26), "UP")
	for i in 3: await process_frame
	pruefe(n.nebel(9, 29) != 2, "Form Kegel: hinter dem Helden nicht in Sicht")
	Nebel.form = "kreis"
	_ende()

func _ende() -> void:
	print("NEBEL505 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
