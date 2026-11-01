extends SceneTree
# 431, 416.4 (Tom 01.11.): Probefilm ohne Bild durchlaufen lassen (Laden, Umhängen der Haare, Bewegungen), Zeilen „FILM …“ prüfen.
# Aufruf im Ordner godot, kopflos mit fester Bildrate 30, Skript tests/drehfilm_431.gd, Umgebung CC0 und KAUF, Argument --film=431

func _initialize() -> void:
	root.add_child(load("res://probe/drehfilm.tscn").instantiate())
