extends SceneTree
# 538 (Abgleich Build 249: „Heldenstufe kommt in Gesprächen nie an (Garrick warnt immer), Stufengrenze 6 für Kapitel 1 fehlt“):
# ohne Bild; 870.4: in Kapitel 1 endet die Erfahrung an der Grenze nach BRS (Kapitelgrenze plus weiche Grenze, Brs.gib_erfahrung);
# vor jedem Gespraech kennt der Spielstand die Stufe des Helden, Garrick warnt vor Krogg nur unter Stufe 3.
# Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/stufe_538.gd -> „STUFE n Fehler“

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])
	else: print("gut %s" % was)

func warnt(z: Zustand) -> bool:
	var k := Skript.new()
	Geschichte.krogg_tip(k, z)
	return k.befehle.any(func(b): return b.get("art") == "sagen" and Sprache.t(b["text"]).contains("Krogg dich mit einem Schlag"))

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	# 870.4: die Heldenstufe nach BRS (zustand.brs_stufe, Brs.gib_erfahrung): Kapitelgrenze, weiche Grenze, dann nichts mehr
	var z := Zustand.new()
	var st := z.stufe_brs()
	Brs.gib_erfahrung(st, 100000.0, "quest")
	pruefe("Kapitel 1: hoechstens Kapitelgrenze plus weiche Grenze", st["stufe"], Brs.hoechste_stufe())
	pruefe("Zustand kennt die Stufe", z.stufe(), Brs.hoechste_stufe())
	var r := Brs.gib_erfahrung(st, 100.0, "kampf")
	pruefe("auf der hoechsten Stufe verfaellt alles", [r.gegeben, r.verfallen], [0.0, 100.0])
	# Gespraech: die Stufe des Helden kommt an
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var w: BrsHeld = spiel.held_werte()
	var sz: Zustand = spiel.zustand
	pruefe("Stufe 1: Garrick warnt", warnt(sz), true)
	sz.stufe_brs()["stufe"] = 5
	spiel.stufe_abgleichen()
	pruefe("der Held spiegelt die Stufe, voll geheilt", [w.stufe, w.leben], [5, w.max_leben()])
	pruefe("abgeglichen: der Spielstand kennt Stufe 5", sz.stufe(), 5)
	pruefe("Stufe 5: Garrick warnt nicht", warnt(sz), false)
	print("STUFE %d Fehler" % fehler)
	quit(1 if fehler else 0)
