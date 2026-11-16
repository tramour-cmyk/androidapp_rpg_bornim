extends SceneTree
# 543 (Abgleich Build 249: „Startgold 15–25 und Start-Heiltränke fehlen, Wiederkehrort Schenke statt Tempel“): ohne Bild; ein
# neues Spiel beginnt wie alt (GameState.newGame): Gold und Heiltraenke (870.4: fuer jede Herkunft gleich, werte.json
# „wirtschaft“), Wiederkehrort Tempel (Story.RESPAWN). Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/startwerte_543.gd
# -> „STARTWERTE n Fehler“

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])
	else: print("gut %s" % was)

func _lauf() -> void:
	pruefe("Wiederkehrort Tempel", Zustand.new().wiederkehr, {"karte": "temple", "x": 4, "y": 4, "blick": "UP"})
	# 870.4: Gold und Heiltraenke fuer jede Herkunft gleich (werte.json „wirtschaft“), die Ausruestung legt BrsHeld.ausstatten an
	var wi: Dictionary = BrsHeld.lade()["wirtschaft"]
	var z := Zustand.new()
	var spiel_skript = load("res://skripte/spiel.gd")
	spiel_skript.startvorrat(z)
	pruefe("Startgold", z.gold, int(wi["startgold"]))
	pruefe("Heiltränke", z.anzahl("potion"), int(wi["start_heiltraenke"]))
	pruefe("Gold 15–25, mindestens ein Trank", z.gold >= 15 and z.gold <= 25 and z.anzahl("potion") >= 1, true)
	pruefe("keine Ausrüstung in der Tasche", z.taschen.keys().all(func(id): return not BrsHeld.daten()["grundformen"].has(id)), true)
	print("STARTWERTE %d Fehler" % fehler)
	quit(1 if fehler else 0)
