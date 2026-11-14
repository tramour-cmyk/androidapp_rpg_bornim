extends SceneTree
# 1062 (Sokrates 12.11., 18:00; Läufe 384, 389, 814: Filme zeigten nur das Hauptmenü, kein Argument hinter „--“): ein Film des
# Spiels ohne Argument bricht ab (spiel.gd film_ohne_ziel), ohne Film oder mit Argument läuft es wie bisher; dazu, ob die Engine
# den Filmpfad meldet (Engine.get_write_movie_path, hier ohne Film leer). Ohne Bild. Exit = Zahl der Fehler.
# Aufruf: im Ordner godot --headless -s res://tests/film_wache_1062.gd

const Spiel = preload("res://skripte/spiel.gd")

var fehler := 0


func pruefe(was: String, gut: bool) -> void:
	if not gut:
		fehler += 1
	print(("ok     " if gut else "FALSCH ") + was)


func _initialize() -> void:
	pruefe("Film ohne Argument bricht ab", Spiel.film_ohne_ziel(PackedStringArray(), "/tmp/x.avi"))
	pruefe("Film mit Argument läuft", not Spiel.film_ohne_ziel(PackedStringArray(["--film1040"]), "/tmp/x.avi"))
	pruefe("ohne Film (Handy) läuft das Hauptmenü", not Spiel.film_ohne_ziel(PackedStringArray(), ""))
	pruefe("ohne Film meldet die Engine keinen Filmpfad", Engine.get_write_movie_path() == "")
	print("FILMWACHE1062 %d Fehler" % fehler)
	quit(fehler)
