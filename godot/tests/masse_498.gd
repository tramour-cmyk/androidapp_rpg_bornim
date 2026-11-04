extends SceneTree
# 498 ohne Bild: Masse der Schrift wie alt (Theme.kt Txt: Groesse sp x 0,95 x TypeLook.scale 1,04, Zeilenhoehe 1,35 x, Sperrung 0,2 sp)
# gegen Godot (Stil.zeile, Erschaffung.txt) bei 411 dp Breite und Schriftgroesse 1,0 (am Rechner kein Handy: Faktor 1). Zeile MASSE498.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	var f: FontFile = load("res://kampf/schrift/alegreya_regular.ttf")
	var dp := 1080.0 / 411.0
	var px := int(round(16 * 0.95 * Stil.SP))
	var alt := 16 * 0.95 * 1.04 * dp
	pruefe(Stil.schriftfaktor == 1.0 and Stil.geraet.is_empty(), "am Rechner Faktor 1 (kein Handy)")
	pruefe(absf(px - alt) <= 1.0, "Text 16 sp: Godot %d px, alt %.1f px" % [px, alt])
	pruefe(absf(f.get_height(px) - 1.35 * alt) <= 0.05 * 1.35 * alt, "Zeile: Godot %.1f px (%.2f x), alt %.1f px (1,35 x)" % [f.get_height(px), f.get_height(px) / float(px), 1.35 * alt])
	print("Sperrung: Godot %d px, alt %.2f px" % [int(round(0.2 * Stil.SP)), 0.2 * dp])
	print("MASSE498 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
