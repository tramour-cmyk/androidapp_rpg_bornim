extends SceneTree
# 785.23 (Abgleich alt, WorldScreen.kt 196: runLatch aus bei winded oder wasMoving && !moves): die eingerastete Renntaste geht von
# selbst aus, wenn der Held nach dem Gehen stehen bleibt oder außer Atem ist; im Stehen eingeschaltet bleibt sie an, bis er geht und
# wieder steht. Neues Spiel im Dorf, ohne Bild. Maßgeblich ist die Zeile RENNTASTE78523.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func an(spiel) -> void:
	spiel.ui.lauf_an = true
	spiel.ui.lauf_knopf.matt = false
	spiel.ui.laufen.emit(true)

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var ui: Steuerung = spiel.ui
	an(spiel)
	for i in 10: await physics_frame
	pruefe(ui.lauf_an, "im Stehen eingeschaltet bleibt sie an")
	spiel.held.richtung = Vector3(1, 0, 0)
	for i in 20: await physics_frame
	pruefe(ui.lauf_an and spiel.laufen_will, "im Gehen an, er will rennen")
	spiel.held.richtung = Vector3.ZERO
	for i in 40: await physics_frame
	pruefe(not ui.lauf_an and not spiel.laufen_will and ui.lauf_knopf.matt, "nach dem Stehenbleiben aus, Knopf matt")
	an(spiel)
	spiel.held.richtung = Vector3(-1, 0, 0)
	for i in 10: await physics_frame
	spiel.zustand.atemlos = true
	spiel.zustand.ausdauer = 0.0
	for i in 5: await physics_frame
	pruefe(not ui.lauf_an, "außer Atem aus")
	spiel.held.richtung = Vector3.ZERO
	print("RENNTASTE78523 %d Fehler" % fehler)
	quit(1 if fehler else 0)
