extends SceneTree
# 834 (Spike, Chef 10.11., 10:21): ohne Bild; der Weg Testmenue „Erschaffung BRS“ → „Abenteuer beginnen“. Ein laufendes Spiel in Platz 1,
# die Seite gibt einen Helden nach BRS in den ersten freien Platz (2); nach dem Neuladen der Szene (Spiel.neu_brs) beginnt ohne Hauptmenue
# ein neues Spiel: zustand.brs mit Fertigkeiten, gespeichert in Platz 2, Platz 1 unveraendert. Sind alle Plaetze belegt, kommt die Platzwahl.
# Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/brs_held_834.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if str(ist) != str(soll):
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _initialize() -> void: _lauf.call_deferred()

func ankunft_ueberspringen() -> void:
	for i in 30:
		await process_frame
		var zb := root.find_children("*", "Zwischenbild", true, false)
		if not zb.is_empty(): zb[0].fertig.emit(); break
	for i in 5: await process_frame

func _lauf() -> void:
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	var z := Zustand.new()
	z.name = "Alt"; z.gold = 777
	Spielstand.platz = 1
	Spielstand.speichere(z, BrsHeld.fuer_spiel("Alt", "Mensch", "Wachsoldat", z.neue_uid), {"karte": "village", "x": 19, "y": 13, "blick": "DOWN"})
	# die Seite selbst: Herkunft gewaehlt, alles verteilt; ziel 0 wie im Testmenue → erster freier Platz
	var e := ErschaffungBrs.new()
	e.ziel = 0
	root.add_child(e)
	await process_frame
	e.name_ = "Brs"
	e.volk_waehlen("Zwerg")   # Mensch waehlt noch eine Fertigkeit mehr
	e.herkunft_waehlen("Wachsoldat")
	var w := {}
	e.fertig.connect(func(x): w.merge(x))   # Lambdas fangen Variablen als Wert; das Woerterbuch selbst ist ein Verweis
	e.beginne()
	pruefe("Abenteuer beginnen moeglich", w.is_empty(), false)
	pruefe("erster freier Platz", w.get("platz"), 2)
	e.queue_free()
	# wie spiel.gd nach „Abenteuer beginnen“: neu_brs setzen, Szene neu; _ready beginnt das neue Spiel
	var S = load("res://skripte/spiel.gd")
	S.neu_brs = w
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await ankunft_ueberspringen()
	pruefe("neu_brs verbraucht", (S.neu_brs as Dictionary).is_empty(), true)
	pruefe("Name", spiel.zustand.name, "Brs")
	pruefe("Platz", Spielstand.platz, 2)
	var f: Dictionary = (spiel.zustand.brs as Dictionary).get("fertigkeiten", {})
	print("BRS834 Held: %s, Fertigkeiten %s, Herkunft %s" % [spiel.zustand.name, f, spiel.held_werte().herkunft])
	pruefe("zustand.brs mit Fertigkeiten", f.is_empty(), false)
	pruefe("Ort: Bett der Schenke", [spiel.karte.id, spiel.held.kachel], [String(Rast.START["karte"]), Vector2i(int(Rast.START["x"]), int(Rast.START["y"]))])
	spiel.speichere()
	var neu := Spielstand.lade(2)
	pruefe("Platz 2 mit BRS gespeichert", neu.is_empty() or (neu["zustand"].get("brs", {}) as Dictionary).is_empty(), false)
	pruefe("Platz 1 unveraendert", int(Spielstand.lade(1)["zustand"].get("gold", 0)), 777)
	spiel.queue_free()
	await process_frame
	# alle Plaetze belegt: Platzwahl statt fertig (795)
	for n in range(1, Spielstand.PLAETZE + 1):
		Spielstand.platz = n
		Spielstand.speichere(z, BrsHeld.fuer_spiel("Alt", "Mensch", "Wachsoldat", z.neue_uid), {"karte": "village", "x": 19, "y": 13, "blick": "DOWN"})
	var e2 := ErschaffungBrs.new()
	root.add_child(e2)
	await process_frame
	e2.volk_waehlen("Zwerg")
	e2.herkunft_waehlen("Wachsoldat")
	var w2 := {}
	e2.fertig.connect(func(x): w2.merge(x))
	var vorher := e2.get_child_count()
	e2.beginne()
	pruefe("alle belegt: kein Start", w2.is_empty(), true)
	pruefe("alle belegt: Platzwahl offen", e2.get_child_count() > vorher, true)
	for n in range(1, Spielstand.PLAETZE + 1): Spielstand.loesche(n)
	print("BRS834 %d Fehler" % fehler)
	quit(1 if fehler else 0)
