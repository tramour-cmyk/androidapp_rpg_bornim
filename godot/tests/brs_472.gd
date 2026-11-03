extends SceneTree
# 472 ohne Bild: Heldenstufe aus Erfahrung (Brs.gib_erfahrung, regeln/brs.gd): 100 × Stufe bis zur nächsten,
# Fertigkeiten höchstens 40 % (wie Held.gib_ep in sim.py), weiche Grenze 6 + 2 mit einem Viertel (E 18),
# Topf je Gebiet (E 19, E 21). Aufruf: im Ordner godot mit -s res://tests/brs_472.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if str(ist) != str(soll):
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if Brs.lade().is_empty():
		print("FALSCH daten/werte.json fehlt"); quit(1); return
	pruefe("Grenzen", [Brs.grenze(), Brs.hoechste_stufe(), Brs.bedarf(1), Brs.bedarf(5)], [6, 8, 100.0, 500.0])
	pruefe("Töpfe", [Brs.topf_voll("Wald"), Brs.topf_voll("Tiefer Wald"), Brs.topf_voll("Höhle")], [400.0, 800.0, 920.0])
	# Aufstieg
	var h := Brs.neuer_stand()
	var r := Brs.gib_erfahrung(h, 100, "kampf")
	pruefe("100 EP: Stufe 2", [h.stufe, h.ep, r.aufstiege], [2, 0.0, 1])
	# Deckel 40 % von 200 = 80 aus Fertigkeiten
	r = Brs.gib_erfahrung(h, 50, "fertigkeit")
	pruefe("Fertigkeit 50", [r.gegeben, r.deckel, Brs.deckel_erreicht(h)], [50.0, false, false])
	r = Brs.gib_erfahrung(h, 50, "fertigkeit")
	pruefe("Fertigkeit an den Deckel", [r.gegeben, r.verfallen, r.deckel, Brs.deckel_erreicht(h)], [30.0, 20.0, true, true])
	r = Brs.gib_erfahrung(h, 10, "fertigkeit")
	pruefe("über dem Deckel verfällt", [r.gegeben, r.verfallen, h.ep], [0.0, 10.0, 80.0])
	r = Brs.gib_erfahrung(h, 120, "probe")
	pruefe("Probe hebt, Deckel neu", [h.stufe, h.ep, h.ep_fert, Brs.deckel_erreicht(h)], [3, 0.0, 0.0, false])
	# Topf Wald 400, leer nur ein Zehntel
	h = Brs.neuer_stand()
	r = Brs.gib_erfahrung(h, 350, "kampf", "Wald")
	pruefe("aus dem Topf", [r.gegeben, r.topf_leer, h.toepfe["Wald"], h.stufe, h.ep], [350.0, false, 50.0, 3, 50.0])
	r = Brs.gib_erfahrung(h, 100, "kampf", "Wald")
	pruefe("Topf leer", [r.gegeben, r.verfallen, r.topf_leer, h.toepfe["Wald"]], [55.0, 45.0, true, 0.0])
	r = Brs.gib_erfahrung(h, 40, "kampf", "Tiefer Wald")
	pruefe("anderes Gebiet voll", [r.gegeben, h.toepfe["Tiefer Wald"]], [40.0, 760.0])
	r = Brs.gib_erfahrung(h, 300, "kampf", "Wald", true)
	pruefe("Boss am Topf vorbei", [r.gegeben, h.toepfe["Wald"]], [300.0, 0.0])
	# weiche Grenze: ab 6 ein Viertel, bei 8 nichts mehr
	h = Brs.neuer_stand()
	h.stufe = 6
	r = Brs.gib_erfahrung(h, 100, "quest")
	pruefe("Stufe 6: ein Viertel", [r.gegeben, r.verfallen], [25.0, 75.0])
	r = Brs.gib_erfahrung(h, 10000, "quest")
	pruefe("hoch bis 8, nicht weiter", [h.stufe, h.ep, r.aufstiege], [8, 1225.0, 2])
	r = Brs.gib_erfahrung(h, 50, "kampf")
	pruefe("Stufe 8: nichts mehr", [r.gegeben, r.verfallen, h.ep], [0.0, 50.0, 1225.0])
	pruefe("nichts bei 0", Brs.gib_erfahrung(h, 0, "kampf").gegeben, 0.0)
	print("BRS472 ", "gut" if fehler == 0 else "%d FALSCH" % fehler)
	quit(1 if fehler else 0)
