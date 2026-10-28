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
			if not s is GDScript or not s.can_instantiate():
				fehler += 1
				print("FALSCH ", ordner, "/", f)
	print("SKRIPTE %d geladen, %d Fehler" % [n, fehler])
	quit(1 if fehler else 0)
