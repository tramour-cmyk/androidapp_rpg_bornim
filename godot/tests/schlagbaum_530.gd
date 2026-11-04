extends SceneTree
# 530 (Chef 03.11., 23:40, Build 249: „Schlagbaum öffnet sich nicht visuell.“): der Balken war fest im Dorfnetz (dorf.py), nur zu.
# Jetzt zwei eigene Netze je Kachel („Schlagbaum_zu_<c>_<r>“, „Schlagbaum_auf_<c>_<r>“); Gebiet.schlagbaum zeigt je nach barrier_open
# eines, beim Laden (_ready) und nach jeder neuen Flagge (spiel.gd flaggen_neu). Ohne Dorfmodell am Rechner: Netze nachgebaut.
# Ohne Bildbefehl. Aufruf: im Ordner godot mit -s res://tests/schlagbaum_530.gd -> „SCHLAGBAUM530 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var flaggen := {}
	var k := Karte.lade("village", flaggen)
	var g := Gebiet.new(k)
	var netz := Node3D.new()   # wie das glTF: Wurzel, darunter die Netze mit ihren Namen
	g.add_child(netz)
	var teile := {}
	for nm in ["Schlagbaum_zu_17_2", "Schlagbaum_zu_18_2", "Schlagbaum_auf_17_2", "Dorf_Netz"]:
		var m := MeshInstance3D.new(); m.name = nm
		netz.add_child(m); teile[nm] = m
	g.schlagbaum(flaggen.has("barrier_open"))
	pruefe(teile["Schlagbaum_zu_17_2"].visible and teile["Schlagbaum_zu_18_2"].visible and not teile["Schlagbaum_auf_17_2"].visible, "zu: Balken nicht quer über dem Weg")
	flaggen["barrier_open"] = true
	g.schlagbaum(flaggen.has("barrier_open"))
	pruefe(not teile["Schlagbaum_zu_17_2"].visible and not teile["Schlagbaum_zu_18_2"].visible and teile["Schlagbaum_auf_17_2"].visible, "offen: Balken steht nicht aufrecht")
	pruefe(teile["Dorf_Netz"].visible, "Dorfnetz verschwunden")
	pruefe(k.begehbar(Vector2i(17, 2)) and k.begehbar(Vector2i(18, 2)), "offener Schlagbaum (17/2, 18/2) nicht begehbar")
	# dorf.py baut die Netze, spiel.gd ruft nach jeder Flagge
	var py := FileAccess.get_file_as_string("res://../tools/blender348/v3/dorf.py")
	if py != "": pruefe(py.contains("'Schlagbaum_auf_%d_%d'") and py.contains("'Schlagbaum_zu_%d_%d'"), "dorf.py baut die Balken nicht einzeln")
	var sp := FileAccess.get_file_as_string("res://skripte/spiel.gd")
	var i := sp.find("func flaggen_neu()")
	pruefe(i >= 0 and sp.substr(i, 200).contains("gebiet.schlagbaum("), "flaggen_neu stellt den Schlagbaum nicht neu")
	g.free()
	print("SCHLAGBAUM530 %d Fehler" % fehler)
	quit(1 if fehler else 0)
