extends SceneTree
# 1021 (Chef 12.11., 08:09): nach einem Ende im Hintergrund geht es gleich im Spielstand weiter. Prüft fortsetzen.gd: ohne Marke 0;
# mit Marke und Spielstand der Platz; nach der Frist oder ohne Spielstand 0; vergiss() löscht. Dazu spiel.gd: Pause setzt die
# Marke, Zurückkommen löscht sie.
# Aufruf: im Ordner godot mit -s res://tests/fortsetzen_1021.gd -> „FORTSETZEN1021 0 Fehler“ (Exit 0)

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var p := 4
	var sicher := ""
	if FileAccess.file_exists(Spielstand.datei(p)): sicher = FileAccess.get_file_as_string(Spielstand.datei(p))
	Fortsetzen.vergiss()
	pruefe(Fortsetzen.offen() == 0, "ohne Marke nicht 0")
	var f := FileAccess.open(Spielstand.datei(p), FileAccess.WRITE)
	f.store_string("{}")
	f.close()
	Fortsetzen.merke(p)
	var t := int(Time.get_unix_time_from_system())
	pruefe(Fortsetzen.offen(t + 60) == p, "eine Minute nach der Pause nicht Platz %d" % p)
	pruefe(Fortsetzen.offen(t + Fortsetzen.FRIST_S + 1) == 0, "nach der Frist nicht 0")
	Fortsetzen.vergiss()
	pruefe(Fortsetzen.offen(t + 60) == 0, "nach vergiss() nicht 0")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Spielstand.datei(p)))
	Fortsetzen.merke(p)
	pruefe(Fortsetzen.offen(t + 60) == 0, "ohne Spielstand nicht 0")
	Fortsetzen.vergiss()
	# spiel.gd: Pause im Spiel setzt die Marke, Zurückkommen löscht sie (ohne Kommandozeile wie am Gerät)
	var quelle := FileAccess.get_file_as_string("res://skripte/spiel.gd")
	pruefe(quelle.contains("Fortsetzen.merke(Spielstand.platz)") and quelle.contains("Fortsetzen.offen()"), "spiel.gd merkt oder fragt nicht")
	if sicher != "":
		var g := FileAccess.open(Spielstand.datei(p), FileAccess.WRITE)
		g.store_string(sicher)
		g.close()
	print("FORTSETZEN1021 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
