extends SceneTree
# 1234 (Homer, Fremdprüfung 1232): nach 870.15 heißt Krogg im Text „Bärenschrat“ / „bearbrute“, nie mehr „Grottenschrat“ /
# „bugbear“ (STORY-BRS-OBERFLAECHE.md [870.15.namen.monster]). Prüft alle Zeichenketten in daten/texte.json und die
# Zeichenketten im Quelltext von skripte/ (ohne Kommentare); eine Zeichenkette, die nur aus der Kennung „bugbear“ besteht,
# ist intern und erlaubt. Aufruf: im Ordner godot mit -s res://tests/namen_1234.gd (Exit 0 = kein alter Name).

const ALT := "(?i)grottenschrat|\\bbugbears?\\b(?!_)"

var r := RegEx.new()
var fehler := 0


func _initialize() -> void:
	r.compile(ALT)
	var f := FileAccess.open("res://daten/texte.json", FileAccess.READ)
	if f == null:
		print("NAMEN1234 FALSCH daten/texte.json fehlt")
		quit(1)
		return
	_pruefe(JSON.parse_string(f.get_as_text()), "texte.json")
	var dir := DirAccess.open("res://skripte")
	var zeichen := RegEx.new()
	zeichen.compile("\"([^\"]*)\"")
	for name in dir.get_files():
		if not name.ends_with(".gd"):
			continue
		var zeilen := FileAccess.get_file_as_string("res://skripte/" + name).split("\n")
		for n in zeilen.size():
			var code: String = zeilen[n].split("#")[0]
			for m in zeichen.search_all(code):
				var s := m.get_string(1)
				if s != "bugbear" and r.search(s) != null:
					_falsch("skripte/%s:%d" % [name, n + 1], s)
	print("NAMEN1234 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)


func _pruefe(x, wo: String) -> void:
	if x is Dictionary:
		for k in x:
			_pruefe(x[k], wo + "/" + str(k))
	elif x is Array:
		for v in x:
			_pruefe(v, wo)
	elif x is String and x != "bugbear" and r.search(x) != null:
		_falsch(wo, x)


func _falsch(wo: String, s: String) -> void:
	fehler += 1
	print("NAMEN1234 FALSCH %s: %s" % [wo, s.left(100)])
