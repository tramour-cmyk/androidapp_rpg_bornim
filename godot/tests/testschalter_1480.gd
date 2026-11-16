extends SceneTree
const Mars = preload("res://regeln/mars.gd")
# 1480 (Chef 16.11., 17:53: t293.7 mit Testschalter „Schnell“ getestet, falsches ✗): der Reiter „Test“ nennt oben in Rot jeden Schalter,
# der Prüfpunkte verfälscht (Unsterblich, Schnell); „Lage herstellen“ schaltet beide aus, außer die Lage verlangt sie.
# Run: godot --headless --path godot -s res://tests/testschalter_1480.gd  -> „TESTSCHALTER1480 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	Mars.held_unsterblich = false; Held.schnell = 1.0
	pruefe(Testmodus.verfaelscht(true) == "", "beide aus: keine Zeile")
	Held.schnell = 3.0
	pruefe(Testmodus.verfaelscht(true).begins_with("Schnell an"), "Schnell an: Zeile nennt Schnell (%s)" % Testmodus.verfaelscht(true))
	Mars.held_unsterblich = true
	pruefe(Testmodus.verfaelscht(false) == "Immortal + Fast on: skews checks", "beide an, englisch (%s)" % Testmodus.verfaelscht(false))
	pruefe(Testmodus.lage_fehler({"unsterblich": "", "schnell": ""}).is_empty(), "Lage kennt unsterblich und schnell")
	Testmodus.lage_schalter({"station": "Garrick"})
	pruefe(not Mars.held_unsterblich and Held.schnell == 1.0, "Lage ohne die Schlüssel schaltet beide aus")
	Testmodus.lage_schalter({"schnell": ""})
	pruefe(not Mars.held_unsterblich and Held.schnell > 1.0, "Lage mit schnell: nur Schnell an")
	Mars.held_unsterblich = false; Held.schnell = 1.0
	print("TESTSCHALTER1480 %d Fehler" % fehler)
	quit(1 if fehler else 0)
