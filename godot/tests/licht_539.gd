extends SceneTree
# 539 (Abgleich Build 249: „Licht folgt der Uhr nicht: wechselt nur bei Rast oder Testknopf; nachts gespeichert lädt als Tag“): ohne
# Bild; wie alt (Game.daylight, isNight): das Licht folgt der Uhr, weich in der Daemmerung, beim Betreten oder Laden sofort zur
# Stunde; Nacht ab Tageslicht unter 0,35. Aufruf: im Ordner godot mit -s res://tests/licht_539.gd -> „LICHT n Fehler“

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])
	else: print("gut %s" % was)

func _lauf() -> void:
	pruefe("Mittag Tag", Licht.nacht_um(12 * 60), 0.0)
	pruefe("20 Uhr halb", Licht.nacht_um(20 * 60), 0.5)
	pruefe("23 Uhr Nacht", Licht.nacht_um(23 * 60), 1.0)
	pruefe("6 Uhr halb", Licht.nacht_um(6 * 60), 0.5)
	pruefe("7 Uhr Tag", Licht.nacht_um(7 * 60), 0.0)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var z: Zustand = spiel.zustand
	z.minuten = 23 * 60
	spiel.betrete("village", Vector2i(10, 10), "DOWN")
	await process_frame
	pruefe("Betreten um 23 Uhr: gleich Nacht", [snappedf(spiel.licht.nacht, 0.01), spiel.licht.ist_nacht()], [1.0, true])
	z.minuten = 12 * 60
	await process_frame
	pruefe("die Uhr springt auf Mittag: Ziel Tag", spiel.licht.ziel, 0.0)
	await create_timer(2.0).timeout
	pruefe("nach 2 s Tag", [snappedf(spiel.licht.nacht, 0.01), spiel.licht.ist_nacht()], [0.0, false])
	z.minuten = 20 * 60 + 18
	await process_frame
	pruefe("20:18 Uhr: noch keine Nacht wie alt", Licht.nacht_um(z.minuten) > Licht.NACHT_AB, false)
	z.minuten = 20 * 60 + 30
	pruefe("20:30 Uhr: Nacht wie alt", Licht.nacht_um(z.minuten) > Licht.NACHT_AB, true)
	print("LICHT %d Fehler" % fehler)
	quit(1 if fehler else 0)
