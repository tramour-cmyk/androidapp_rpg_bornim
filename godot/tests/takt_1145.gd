extends SceneTree
# 1145 Test 285: der Knopf „Takt“ im Testmenü begrenzt die Bilder je Sekunde reihum (frei, 60, 40, 30) und fängt wieder bei frei an;
# das Testmenü baut mit der Zeile ohne Fehler. Massgeblich ist die Zeile TAKT1145.
var fehler := 0
func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1
func _initialize() -> void: _lauf.call_deferred()
func _lauf() -> void:
	pruefe(Engine.max_fps == 0 and Testmodus.takt_i == 0, "beim Start frei")
	var soll := [60, 40, 30, 0]
	for s in soll:
		Testmodus.takt_setzen(Testmodus.takt_i + 1)
		pruefe(Engine.max_fps == s, "Takt %d (ist %d)" % [s, Engine.max_fps])
	print("TAKT1145 " + ("gut" if fehler == 0 else "FEHLER %d" % fehler))
	quit(1 if fehler else 0)
