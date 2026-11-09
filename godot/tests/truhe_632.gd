extends SceneTree
# 632 (Abgleich 620.2b): die Truhe der Höhle (cave_3, 4/14) gibt die Waffe der Klasse wie alt (Story.classWeapon, Game.openChest),
# nicht das Ding „@class_weapon“. Prüft die Zuordnung gegen Story.kt, dass jede Waffe als Einzelstück da ist und dass die Truhe sie
# über spiel.gd oeffne_kiste bekommt. Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/truhe_632.gd -> „TRUHE632 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FALSCH ", was)
	else:
		print("ok     ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	var story := FileAccess.get_file_as_string("res://../core/src/main/kotlin/de/bornim/core/Story.kt")
	var re := RegEx.create_from_string("CharClass\\.(\\w+) -> \"(\\w+)\"")
	var alt := {}
	for m in re.search_all(story): alt[m.get_string(1)] = m.get_string(2)
	pruefe(alt.size() == 4, "Story.classWeapon nennt vier Klassen (%d)" % alt.size())
	for kl in alt:
		var w := Geschichte.klassen_waffe(kl)
		pruefe(w == alt[kl], "%s bekommt %s wie alt (%s)" % [kl, w, alt[kl]])
		pruefe(Sprache.texte.get("einzelstuecke", {}).get(w, {}).has("grundform"), "%s ist ein Einzelstück mit Grundform" % w)
	var k: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))["karten"]
	var truhe := {}
	for c in k.get("cave", {}).get("kisten", []):
		if String(c["id"]) == "cave_3": truhe = c
	pruefe(String(truhe.get("ding", "")) == Geschichte.CLASS_WEAPON, "cave_3 enthält %s" % Geschichte.CLASS_WEAPON)
	var spiel := FileAccess.get_file_as_string("res://skripte/spiel.gd")
	pruefe(spiel.contains("Geschichte.klassen_waffe(held_werte().klasse)"), "oeffne_kiste löst @class_weapon nach der Klasse auf")
	print("TRUHE632 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
