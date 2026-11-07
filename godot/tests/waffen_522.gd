extends SceneTree
# 522 (Chef 04.11., 11:55, t257 251.6: „von Schwert und Schild auf … Streitkolben und Dolch. Fakt ist, die alte Bewaffnung und Ausrüstung
# war weg, aber die neue ist nicht sichtbar gewesen“): jede Waffe, die waffen.py bauen kann, hat ein Modell fuer den Helden; ein Dolch in
# der Nebenhand haengt nicht als Schild auf dem Ruecken. Die Waffen ohne Modell (458.3) nennt der Test. Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/waffen_522.gd -> „WAFFEN522 gut“ oder „n Fehler“
const MIT_MODELL := ["longsword", "shortsword", "quarterstaff", "dagger", "scimitar", "handaxe", "shortbow", "shield", "round_shield"]

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	for b in MIT_MODELL:
		pruefe(FileAccess.file_exists("res://daten/waffen/%s.bin" % b), "%s: Modell fuer den Helden" % b)
	var ohne: Array = []
	for b in Beute.d_()["grundformen"]:
		var g: Dictionary = Beute.grundform(b)
		if String(g["slot"]) in ["MAIN_HAND", "OFF_HAND"] and not FileAccess.file_exists("res://daten/waffen/%s.bin" % b): ohne.append(b)
	print("bekannt, noch ohne Modell (458.3): ", ohne)
	if FileAccess.file_exists("res://daten/held.bin") and FileAccess.file_exists("res://daten/waffen/dagger.bin"):
		var m := Gebiet.lade_glb("res://daten/held.bin")
		root.add_child(m)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		HeldFigur.bewaffne(m, sk, {"MAIN_HAND": {"base": "longsword"}, "OFF_HAND": {"base": "dagger"}})
		pruefe(sk.find_children("RueckenSchild", "", true, false).is_empty(), "Dolch in der Nebenhand haengt nicht als Schild auf dem Ruecken")
		HeldFigur.bewaffne(m, sk, {"MAIN_HAND": {"base": "longsword"}, "OFF_HAND": {"base": "shield"}})
		pruefe(not sk.find_children("RueckenSchild", "", true, false).is_empty(), "Schild in der Nebenhand haengt auf dem Ruecken")
	print("WAFFEN522 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
