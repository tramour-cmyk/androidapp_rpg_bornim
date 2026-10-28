extends SceneTree
# 390: laedt jedes Skript unter res://skripte und res://regeln, ohne eine Szene zu starten; ein Parsefehler gibt Exit 1.
# Aufruf: im Ordner godot mit -s res://tests/skripte_pruefen.gd

func _init() -> void:
	var fehler := 0
	var n := 0
	for ordner in ["res://skripte", "res://regeln"]:
		var dir := DirAccess.open(ordner)
		if dir == null: continue
		for f in dir.get_files():
			if not f.ends_with(".gd"): continue
			n += 1
			var s = load(ordner + "/" + f)
			# 399.1 Test 130: FileAccess.file_exists auf Skripte, Szenen, Shader ist im APK immer falsch; ResourceLoader.exists nehmen
			var quelltext := FileAccess.get_file_as_string(ordner + "/" + f)
			var re := RegEx.create_from_string("FileAccess\\.file_exists\\(\"res://[^\"]*\\.(gd|tscn|gdshader)\"\\)")
			if re.search(quelltext) != null:
				fehler += 1
				print("FALSCH ", ordner, "/", f, ": FileAccess.file_exists auf ein Skript, im APK immer falsch")
			if not s is GDScript or not s.can_instantiate():
				fehler += 1
				print("FALSCH ", ordner, "/", f)
	print("SKRIPTE %d geladen, %d Fehler" % [n, fehler])
	quit(1 if fehler else 0)
