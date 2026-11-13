extends SceneTree
# 1062 (Sokrates 12.11., 18:00; Läufe 384, 389, 814: Filme zeigten nur das Hauptmenü, kein Argument hinter „--“): ein Film des
# Spiels ohne Argument bricht ab (spiel.gd film_ohne_ziel), ohne Film oder mit Argument läuft es wie bisher; dazu, ob die Engine
# den Filmpfad meldet (Engine.get_write_movie_path, hier ohne Film leer). 1196 (Spike, Lauf 442: fünf Filme ohne „--“, je ein
# Bild): dazu godot.yml lesen; jeder Filmaufruf (--write-movie) eines tests/film_*.gd, der spiel.tscn lädt, hat „--“ und ein
# Argument dahinter, auch über die Hilfsfunktion film() eines Schritts. Ohne Bild. Exit = Zahl der Fehler.
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
	_godot_yml()
	print("FILMWACHE1062 %d Fehler" % fehler)
	quit(fehler)


## 1196: Aufrufe in godot.yml; Zeilen mit „\\“ am Ende gehören zum selben Befehl, Schritte beginnen mit „- name:“
func _godot_yml() -> void:
	var pfad := ProjectSettings.globalize_path("res://").path_join("../.github/workflows/godot.yml")
	var text := FileAccess.get_file_as_string(pfad)
	if text == "":
		pruefe("godot.yml gelesen (%s)" % pfad, false)
		return
	var befehle := 0
	var schritt := ""
	var helfer := {}     # Name der Hilfsfunktion → [Befehl] im Schritt
	var zeilen: Array = []
	var stueck := ""
	for z in text.split("\n"):
		var t := String(z)
		if t.strip_edges().begins_with("- name:"):
			zeilen.append(["SCHRITT", t.strip_edges()])
		if t.rstrip(" ").ends_with("\\"):
			stueck += t.rstrip(" ").trim_suffix("\\") + " "
			continue
		zeilen.append(["", stueck + t])
		stueck = ""
	var offen := ""     # Name der Hilfsfunktion, deren Rumpf gerade läuft
	var kopf := RegEx.create_from_string("^\\s*(\\w+)\\(\\)\\s*\\{")
	for e in zeilen:
		if e[0] == "SCHRITT":
			schritt = e[1]
			helfer = {}
			offen = ""
			continue
		var b: String = e[1]
		var m := kopf.search(b)
		if m != null:
			offen = m.get_string(1)
			helfer[offen] = ""
		if offen != "":
			helfer[offen] += b + " "
			if b.rstrip(" ").ends_with("}"):
				if not helfer[offen].contains("$sk") and helfer[offen].contains("--write-movie"):
					befehle += 1
					_pruefe_aufruf(helfer[offen], schritt)
				offen = ""
			continue
		var aufruf := b.strip_edges().split(" ", false)
		# Aufruf einer Hilfsfunktion: film <name> <skript> …
		if aufruf.size() >= 3 and helfer.has(aufruf[0]) and helfer[aufruf[0]].contains("--write-movie") and helfer[aufruf[0]].contains("$sk"):
			befehle += 1
			_pruefe_aufruf(helfer[aufruf[0]].replace("$sk", aufruf[2]), schritt)
		elif b.contains("--write-movie"):
			befehle += 1
			_pruefe_aufruf(b, schritt)
	pruefe("godot.yml: %d Filmaufrufe gelesen" % befehle, befehle > 0)


func _pruefe_aufruf(b: String, schritt: String) -> void:
	var m := RegEx.create_from_string("-s res://tests/(film_\\w+)\\.gd(.*)").search(b)
	if m == null:
		return
	var skript := "res://tests/%s.gd" % m.get_string(1)
	if not FileAccess.file_exists(skript) or not FileAccess.get_file_as_string(skript).contains("spiel.tscn"):
		return
	var rest := m.get_string(2)
	var gut := RegEx.create_from_string("^\\s+--\\s+\\S").search(rest) != null
	pruefe("%s mit Argument hinter „--“ (%s)" % [m.get_string(1), schritt.trim_prefix("- name: ").left(50)], gut)
