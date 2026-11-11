extends SceneTree
# 632 (Abgleich 620.2b): die Truhe der Höhle (cave_3, 4/14) gibt eine Waffe, nicht das Ding „@class_weapon“; 870.4: nach der
# stärksten Fertigkeit (STORY-BRS-HELD.md). Prüft die Zuordnung, dass jede Waffe als Einzelstück da ist und dass die Truhe sie über
# spiel.gd oeffne_kiste bekommt. Ohne Bild.
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
	# 870.4 (STORY-BRS-HELD.md „Die Truhe in der Blutzahnhöhle“): die Waffe zur stärksten Fertigkeit, Gleichstand nach der Folge
	var faelle := [[{}, "longsword_oakford"], [{"Einhänder": 10, "Schild": 10}, "longsword_oakford"], [{"Dolche": 12, "Einhänder": 10}, "rapier_whisper"],
		[{"Bogen": 12, "Dolche": 10}, "rapier_whisper"], [{"Evokation": 10, "Schutzmagie": 10}, "staff_of_embers"], [{"Heilmagie": 10, "Stumpfe Waffen": 10}, "mace_of_dawn"],
		[{"Heilmagie": 12, "Einhänder": 10}, "mace_of_dawn"], [{"Einhänder": 10, "Evokation": 10}, "longsword_oakford"], [{"Zweihänder": 20, "Stumpfe Waffen": 5}, "mace_of_dawn"]]
	for f in faelle:
		var w := Geschichte.truhen_waffe(f[0])
		pruefe(w == f[1], "%s bekommt %s (soll %s)" % [f[0], w, f[1]])
	for w in Geschichte.TRUHE_STUECK.values():
		pruefe(Sprache.texte.get("einzelstuecke", {}).get(w, {}).has("grundform"), "%s ist ein Einzelstück mit Grundform" % w)
	pruefe(Geschichte.truhen_waffe(BrsHeld.fuer_spiel("T", "Mensch", "Jägerkind").fertigkeiten_jetzt()) == "longsword_oakford", "Jägerkind ohne Bogenstück: Einhänder")
	pruefe(Geschichte.truhen_waffe(BrsHeld.fuer_spiel("T", "Mensch", "Zauberlehrling").fertigkeiten_jetzt()) == "staff_of_embers", "Zauberlehrling: Glutstab")
	var k: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))["karten"]
	var truhe := {}
	for c in k.get("cave", {}).get("kisten", []):
		if String(c["id"]) == "cave_3": truhe = c
	pruefe(String(truhe.get("ding", "")) == Geschichte.CLASS_WEAPON, "cave_3 enthält %s" % Geschichte.CLASS_WEAPON)
	var spiel := FileAccess.get_file_as_string("res://skripte/spiel.gd")
	pruefe(spiel.contains("Geschichte.truhen_waffe(held_werte().fertigkeiten_jetzt())"), "oeffne_kiste löst @class_weapon nach der stärksten Fertigkeit auf")
	print("TRUHE632 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
