extends SceneTree
# 543 (Abgleich Build 249: „Startgold 15–25 und Start-Heiltränke fehlen, Wiederkehrort Schenke statt Tempel“): ohne Bild; ein
# neues Spiel beginnt wie alt (GameState.newGame, CharClass.startGold, startItems): Gold und Heiltraenke je Klasse, Wiederkehrort
# Tempel (Story.RESPAWN). Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/startwerte_543.gd
# -> „STARTWERTE n Fehler“

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])
	else: print("gut %s" % was)

func _lauf() -> void:
	pruefe("Wiederkehrort Tempel", Zustand.new().wiederkehr, {"karte": "temple", "x": 4, "y": 4, "blick": "UP"})
	var d := Heldwerte.lade()
	for k in d["klassen"]:
		var z := Zustand.new()
		var spiel_skript = load("res://skripte/spiel.gd")
		spiel_skript.startvorrat(z, String(k))
		var traenke := 0
		for id in d["klassen"][k]["start"]:
			if String(id) == "potion": traenke += 1
		pruefe("%s: Startgold" % k, z.gold, int(d["klassen"][k]["startgold"]))
		pruefe("%s: Heiltränke" % k, z.anzahl("potion"), traenke)
		pruefe("%s: Gold 15–25, mindestens ein Trank" % k, z.gold >= 15 and z.gold <= 25 and traenke >= 1, true)
		pruefe("%s: keine Ausrüstung in der Tasche" % k, z.taschen.keys().all(func(id): return not d["grundformen"].has(id)), true)
	print("STARTWERTE %d Fehler" % fehler)
	quit(1 if fehler else 0)
