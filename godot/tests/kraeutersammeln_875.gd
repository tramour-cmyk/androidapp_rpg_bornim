# 875 (857a A, Chef 10.11., 13:35): Kräuterkunde heißt im Spiel Kräutersammeln, EN Foraging. Prüft Namen in Erschaffung und Daten,
# dass Pflücken Kräutersammeln übt und zählt, und dass ein Spielstand aus Build 276 („Kräuterkunde“ in Übung und Wahl) den Wert
# unter dem neuen Namen behält.
# Aufruf: im Ordner godot mit --headless -s res://tests/kraeutersammeln_875.gd   (Exit 0 = alles richtig)
extends SceneTree

var falsch := 0


func _initialize() -> void:
	_pruefe("Erschaffung: Kräutersammeln heißt EN Foraging", ErschaffungBrs.FERT.get("Kräutersammeln", ""), "Foraging")
	_pruefe("Erschaffung: kein Kräuterkunde mehr", ErschaffungBrs.FERT.has("Kräuterkunde"), false)
	var hk: Dictionary = BrsHeld.lade()["herkuenfte"]
	var alt := 0
	for k in BrsHeld.ohne_info(hk):
		if (hk[k].get("fertigkeiten", []) as Array).has("Kräuterkunde"): alt += 1
	_pruefe("Herkünfte ohne Kräuterkunde", alt, 0)
	_pruefe("Kräutersammler startet mit Kräutersammeln", BrsHeld.neu("Mensch", "Kräutersammler").fertigkeit("Kräutersammeln") > 0, true)
	# Spielstand aus Build 276
	var stand := {"brs": {"volk": "Mensch", "herkunft": "Wanderer", "verteilt": {}, "mensch_frei": "", "wahl": ["Kräuterkunde", "Spähen"]},
		"fert": {"werte": {"Kräuterkunde": 17, "Spähen": 5}, "uebung": {"Kräuterkunde": 3.5}, "decke": {"Kräuterkunde": 24}, "probe": {},
			"bekannt": ["Kräuterkunde", "Spähen"]}}
	var z := Zustand.aus_daten(stand)
	_pruefe("alter Stand: Wert unter dem neuen Namen", BrsFertigkeit.wert(z.fert, "Kräutersammeln"), 17)
	_pruefe("alter Stand: Übung mitgenommen", float(z.fert["uebung"].get("Kräutersammeln", 0.0)), 3.5)
	_pruefe("alter Stand: alter Name weg", (z.fert["werte"] as Dictionary).has("Kräuterkunde") or (z.fert["bekannt"] as Array).has("Kräuterkunde"), false)
	_pruefe("alter Stand: Wahl umbenannt", (z.brs.get("wahl", []) as Array).has("Kräutersammeln"), true)
	# Pflücken: Chance nach Kräutersammeln
	var h := BrsHeld.neu("Mensch", "Wanderer")
	var ohne := Laden.kraut_chance(h)
	h.geuebt["Kräutersammeln"] = 20
	_pruefe("Kräutersammeln hebt die Chance auf ein Kraut mehr", Laden.kraut_chance(h) > ohne, true)
	print("KRAEUTERSAMMELN875 %d falsch" % falsch)
	quit(1 if falsch > 0 else 0)


func _pruefe(was: String, ist, soll) -> void:
	var ok: bool = ist == soll
	print(("gut    " if ok else "FALSCH ") + "%s: %s" % [was, str(ist)])
	if not ok: falsch += 1
