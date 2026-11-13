extends SceneTree
# 211.14 (Rest 211.13, Sokrates 20.10.: „Leistung am A56 messen“): ohne Bild; Messung zählt jeden Kampf für sich (Schnitt, langsamstes
# 1 %, längste Pause, Pausen über 50 ms) und zeigt ihn unter „Gerät zeigen“ und in der Zeile über dem Kampfort (Testmodus „Bildrate“).
# Aufruf: im Ordner godot mit -s res://tests/kampf_leistung_21114.gd -> „KAMPFLEISTUNG n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _init() -> void:
	pruefe(Messung.kampf_werte().is_empty(), "ohne Kampf keine Werte")
	pruefe(not Messung.zeilen().any(func(z): return String(z).begins_with("Letzter Kampf")), "ohne Kampf keine Zeile unter „Gerät“")
	Messung.kampf_beginn("RUDEL, lichtung")
	for i in 198: Messung.kampf_bild(1.0 / 60.0)
	Messung.kampf_bild(0.080)
	Messung.kampf_bild(0.120)
	var w := Messung.kampf_werte()
	var sek := 198.0 / 60.0 + 0.2
	pruefe(absf(float(w["sek"]) - sek) < 0.01, "Dauer %.2f s (soll %.2f)" % [w["sek"], sek])
	pruefe(absf(float(w["fps"]) - 200.0 / sek) < 0.5, "Schnitt %.1f je s (soll %.1f)" % [w["fps"], 200.0 / sek])
	pruefe(int(w["langsam"]) == 2, "zwei Pausen über 50 ms (%d)" % w["langsam"])
	pruefe(absf(float(w["laengste"]) - 120.0) < 0.01, "längste 120 ms (%.1f)" % w["laengste"])
	pruefe(absf(float(w["eins"]) - 80.0) < 0.01, "langsamstes 1 %% = 80 ms (%.1f)" % w["eins"])
	var z: Array = Messung.zeilen().filter(func(x): return String(x).begins_with("Letzter Kampf (RUDEL, lichtung)"))
	pruefe(z.size() == 1, "Zeile unter „Gerät“: %s" % (z[0] if z.size() else "fehlt"))
	pruefe(Messung.kampf_zeile().contains("im Kampf"), "Zeile über dem Kampfort: %s" % Messung.kampf_zeile().replace("\n", " | "))
	Messung.kampf_beginn("RATS, teich")
	pruefe(Messung.kampf_werte().is_empty(), "neuer Kampf beginnt leer")
	print("KAMPFLEISTUNG %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
