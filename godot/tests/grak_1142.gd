extends SceneTree
# 1142 (Chef 13.11., 14:44, Build 282: „Karak einfach das erste Mal sozusagen regulär besiegt, da kommt irgendwie ein bisschen Text …
# dachte jetzt, ich gehe zu Lyra. Aber nee, dann kam nochmal der Kampf.“): Grak vor seiner Halle genau einmal. Nachstellen ohne Bild:
# der Held tritt auf (10, 4), Grak spricht, der Kampf (hier ein Ersatz, der wie kampf_im_wald am Ende den Helden mit held.setze auf
# seinen Platz stellt und „WON“ meldet), dann jede Zeile antippen wie am Handy. Verdacht: held.setze sendet steht_auf, solange die
# Flagge grak_defeated noch fehlt und kein Text offen ist; _betritt hängt dann ein zweites grak_talk an die Szene.
# Prüft: genau ein Kampf, Flagge gesetzt, die Szene endet mit Lyras Ruf, kein Text von Grak danach.
# Braucht godot/daten mit der Höhle wie im Bau (hoehle_492); ohne cave.bin übersprungen (exit 0). Maßgeblich die Zeile GRAK1142.
# Aufruf: im Ordner godot mit --headless -s res://tests/grak_1142.gd

class SpielStumm extends "res://skripte/spiel.gd":
	var kaempfe := 0
	func kampf_im_wald(zurueck: Vector2i, _gegner := "RUDEL", _probe: Array = [], _eroeffnung := "", _nr := 0, _spielprobe := false) -> String:
		kaempfe += 1
		for i in 3: await get_tree().process_frame
		held.setze(zurueck, blick_nach)     # wie das Ende von kampf_im_wald nach einem Sieg
		for i in 3: await get_tree().process_frame
		return "WON"

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	if not FileAccess.file_exists("res://daten/cave.bin"):
		print("GRAK1142 übersprungen: keine Höhle in godot/daten (wie im Bau: hoehle_492)")
		quit(0)
		return
	Streuner.gibt["hobgoblin_captain"] = true     # der Kampf läuft über den Ersatz, das Modell braucht er nicht
	var spiel := SpielStumm.new()
	root.add_child(spiel)
	for i in 5: await process_frame
	for f in ["cave_seen", "krogg_defeated", Geschichte.GATE_OPEN]: spiel.zustand.setze(f)
	spiel.betrete("cave", Vector2i(10, 6), "UP")
	for i in 5: await process_frame
	spiel.held.setze(Vector2i(10, 4), "UP")     # vor Graks Halle (ausloeser)
	var zeilen := []
	for i in 120:
		await process_frame
		if spiel.ui.spricht():
			var z := String(spiel.ui.text.text)
			if zeilen.is_empty() or zeilen[-1] != z: zeilen.append(z)
			spiel.ui.naechste()
		elif spiel.szene.is_empty() and not spiel.im_kampf and spiel.kaempfe > 0:
			break
	for i in 10: await process_frame
	print("Kämpfe %d, Zeilen %d, Szene übrig %d" % [spiel.kaempfe, zeilen.size(), spiel.szene.size()])
	pruefe(spiel.kaempfe == 1, "Grak kämpft genau einmal (%d)" % spiel.kaempfe)
	pruefe(spiel.zustand.has(Geschichte.GRAK_DEFEATED), "Flagge grak_defeated gesetzt")
	pruefe(spiel.szene.is_empty() and not spiel.ui.spricht(), "Szene zu Ende")
	pruefe(not zeilen.is_empty() and zeilen[-1].begins_with("Hier drüben"), "zuletzt Lyras Ruf: %s" % [zeilen.slice(-3)])
	pruefe(zeilen.filter(func(z): return z.begins_with("Unmöglich")).size() == 1, "„Unmöglich …“ genau einmal")
	print("GRAK1142 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler > 0 else 0)
