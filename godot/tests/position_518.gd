extends SceneTree
# 518 (Build 248, Chef 03.11., 20:47: Dorf ohne Haeuser, schwarze Striche): schreibt ein Shader POSITION nur in einem Zweig,
# nimmt Godot es trotzdem fuer jede Ecke; ungeschrieben fallen alle Ecken auf einen Punkt (Netz unsichtbar, Tusche und Schatten bleiben).
# Prueft jeden .gdshader: steht POSITION in vertex(), dann auch einmal auf oberster Ebene der Funktion (ein Tab eingerueckt).
var fehler := 0

func _init() -> void:
	for pfad in dateien("res://"):
		var text := FileAccess.get_file_as_string(pfad)
		var a := text.find("void vertex()")
		if a < 0: continue
		var e := text.find("\n}", a)
		var rumpf := text.substr(a, e - a)
		if rumpf.find("POSITION") < 0: continue
		var zeilen := rumpf.split("\n")
		var oben: bool = zeilen[0].begins_with("void vertex() { POSITION =")   # einzeilig: Vollbild-Dreieck der Tusche
		for z in zeilen:
			if z.begins_with("\tPOSITION =") or z.begins_with("\tPOSITION="): oben = true
		if not oben:
			fehler += 1
			print("FEHLER %s: POSITION nur in einem Zweig gesetzt" % pfad)
	print("POSITION518 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func dateien(dir: String) -> PackedStringArray:
	var aus: PackedStringArray = []
	var d := DirAccess.open(dir)
	if d == null: return aus
	for f in d.get_files():
		if f.ends_with(".gdshader"): aus.append(dir.path_join(f))
	for u in d.get_directories():
		if u.begins_with(".") or u == "addons": continue
		aus.append_array(dateien(dir.path_join(u)))
	return aus
