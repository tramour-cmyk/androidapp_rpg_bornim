# 585 (Abgleich 512b): der Titel des Hauptmenues bricht ausgewogen um, „CHRONIKEN / VON BORNIM“ wie alt, nicht „CHRONIKEN VON / BORNIM“;
# passt er in eine Zeile, bleibt er eine Zeile. Nur Masse der Schrift bei 1080 px Breite (DP wie im Spiel).
# Aufruf: godot --headless --path godot -s res://tests/titel_585.gd
extends SceneTree

func _initialize() -> void:
	var fehler := 0
	var breite := 1080.0 - 48 * AktionsKnopf.DP
	for f in [["CHRONIKEN VON BORNIM", "CHRONIKEN\nVON BORNIM"], ["CHRONICLES OF BORNIM", "CHRONICLES\nOF BORNIM"], ["BORNIM", "BORNIM"]]:
		var l := Stil.zeile(f[0], 33, Stil.BRIGHT, 6.0)
		Hauptmenue.ausgewogen(l, breite)
		var ok: bool = l.text == String(f[1])
		if not ok: fehler += 1
		print("TITEL585 %s → %s %s" % [f[0], l.text.replace("\n", " / "), "ok" if ok else "FALSCH, erwartet " + f[1].replace("\n", " / ")])
		l.free()
	print("TITEL585 %d Fehler" % fehler)
	quit(1 if fehler else 0)
