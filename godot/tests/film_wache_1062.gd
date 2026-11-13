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
	_ablauf()
	print("FILMWACHE1062 %d Fehler" % fehler)
	quit(fehler)


## 1196 (Spike, Lauf 442: fünf Filme in build-284 riefen das Spiel ohne „--“ auf, je 1 Bild; die Wache griff erst im Lauf): jeder
## Aufruf eines tests/film_*.gd in .github/workflows/godot.yml, dessen Skript spiel.tscn lädt, gibt hinter „--“ ein Argument mit
func _ablauf() -> void:
	var pfad := ProjectSettings.globalize_path("res://").path_join("../.github/workflows/godot.yml")
	if not FileAccess.file_exists(pfad):
		print("ok     godot.yml nicht da (Export ohne Ablauf), nicht geprüft")
		return
	var zeilen := FileAccess.get_file_as_string(pfad).split("\n")
	var ganz := []     # Fortsetzungszeilen („\“ am Ende) zu einem Befehl zusammen
	var stueck := ""
	for z in zeilen:
		var t := String(z).strip_edges()
		if t.ends_with("\\"):
			stueck += t.trim_suffix("\\") + " "
			continue
		ganz.append(stueck + t)
		stueck = ""
	var re := RegEx.create_from_string("res://tests/(film_[a-z0-9_]+)\\.gd")
	var mit := RegEx.create_from_string("res://tests/film_[a-z0-9_]+\\.gd\\s+--\\s+\\S")
	var spiel := {}
	var n := 0
	var ohne := []
	for b in ganz:
		for m in re.search_all(b):
			var name := m.get_string(1)
			if not spiel.has(name):
				var q := "res://tests/%s.gd" % name
				spiel[name] = FileAccess.file_exists(q) and FileAccess.get_file_as_string(q).contains("spiel.tscn")
			if not spiel[name] or b.begins_with("#") or name == "film_wache_1062":
				continue
			n += 1
			if mit.search(b) == null:
				ohne.append(name)
	# die Prüfung selbst: ein Aufruf ohne „--“ fällt auf, einer mit nicht
	pruefe("Prüfmuster: ohne „--“ erkannt, mit „--“ nicht", mit.search("-s res://tests/film_pim_1086.gd > x.log") == null and mit.search("-s res://tests/film_pim_1086.gd -- --film=1086 > x.log") != null)
	pruefe("godot.yml: %d Aufrufe von Filmen des Spiels, alle mit Argument hinter „--“%s" % [n, "" if ohne.is_empty() else " (ohne: %s)" % ", ".join(PackedStringArray(ohne))], ohne.is_empty() and n > 0)
