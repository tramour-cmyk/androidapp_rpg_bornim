extends SceneTree
# 538 (Abgleich Build 249: „Heldenstufe kommt in Gesprächen nie an (Garrick warnt immer), Stufengrenze 6 für Kapitel 1 fehlt“):
# ohne Bild; in Kapitel 1 endet die Erfahrung bei Stufe 6 (Story.levelCap, Hero.gainXp: was darueber geht, verfaellt), ab
# Kapitel 2 nicht; vor jedem Gespraech kennt der Spielstand die Stufe des Helden, Garrick warnt vor Krogg nur unter Stufe 3.
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
	var tab: Array = Heldwerte.regel("ep_fuer_stufe")
	var z := Zustand.new()
	pruefe("Deckel Kapitel 1", Geschichte.stufendeckel(z), 6)
	var hw := Heldwerte.erschaffe("Mira", "HUMAN", "FIGHTER", {}, z.neue_uid)
	hw.ep_dazu(int(tab[9]), Geschichte.stufendeckel(z))
	pruefe("Kapitel 1: hoechstens Stufe 6, Erfahrung darueber verfaellt", [hw.stufe, hw.ep], [6, int(tab[6])])
	z.setze(Geschichte.CHAPTER2_STARTED)
	hw.ep_dazu(int(tab[9]) - hw.ep, Geschichte.stufendeckel(z))
	pruefe("Kapitel 2: weiter bis Stufe 9", hw.stufe, 9)
	# Gespraech: die Stufe des Helden kommt an
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var w: Heldwerte = spiel.held_werte()
	var sz: Zustand = spiel.zustand
	pruefe("Stufe 1: Garrick warnt", warnt(sz), true)
	w.ep_dazu(int(tab[5]), Geschichte.stufendeckel(sz))
	spiel.stufe_abgleichen()
	pruefe("abgeglichen: der Spielstand kennt Stufe 5", sz.stufe(), 5)
	pruefe("Stufe 5: Garrick warnt nicht", warnt(sz), false)
	print("STUFE %d Fehler" % fehler)
	quit(1 if fehler else 0)
