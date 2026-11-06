extends SceneTree
# 555 (Chef 04.11., 17:20, t257 D: Uhr auf 1 Uhr nachts gestellt, „Es ist aber taghell“; 17:22: „da es nie Nacht wird“) ohne Bild:
# das Licht folgt der Uhr wie alt (Game.daylight), auch nach dem Vorstellen, beim Betreten eines Orts und in der Daemmerung; das
# Zeichen der Leiste zeigt nachts den Mond. Braucht godot/daten. Maßgeblich ist die Zeile UHRLICHT555.

const SpielGd = preload("res://skripte/spiel.gd")

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func warte(sek: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < sek * 1000.0: await process_frame

func _lauf() -> void:
	pruefe(SpielGd.tageslicht(12 * 60) == 1.0 and SpielGd.tageslicht(1 * 60 + 51) == 0.0 and absf(SpielGd.tageslicht(20 * 60) - 0.5) < 0.01
		and absf(SpielGd.tageslicht(6 * 60) - 0.5) < 0.01, "Tageslicht wie alt: Mittag 1, 1:51 Uhr 0, 20 und 6 Uhr halb")
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 12 * 60
	await warte(2.0)
	pruefe(spiel.licht.nacht < 0.05, "mittags Tag (%.2f)" % spiel.licht.nacht)
	# wie das Testmenue: Uhr vorgestellt auf 1:51
	spiel.zustand.minuten = 1 * 60 + 51
	await warte(2.0)
	pruefe(spiel.licht.nacht > 0.95, "1:51 Uhr Nacht (%.2f)" % spiel.licht.nacht)
	pruefe(spiel.licht.nacht > 0.65, "Leiste zeigt den Mond (Nacht ueber 0,65)")
	# beim Betreten eines Orts gleich Nacht, ohne Uebergang
	spiel.betrete("forest", Vector2i(9, 26), "UP")
	pruefe(spiel.licht.nacht > 0.95, "nach dem Betreten des Walds sofort Nacht (%.2f)" % spiel.licht.nacht)
	# Daemmerung: 20 Uhr halb
	spiel.zustand.minuten = 20 * 60
	await warte(2.0)
	pruefe(absf(spiel.licht.nacht - 0.5) < 0.05, "20 Uhr Daemmerung (%.2f)" % spiel.licht.nacht)
	print("UHRLICHT555 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
