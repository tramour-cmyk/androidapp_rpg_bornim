extends SceneTree
# 588 (Chef 05.11., Build 266, Log: dreimal „_load_from_buffer: buffer_size == 0“ aus Gebiet.baue_leben nach kampf_im_wald):
# nach einem verlorenen Kampf kehrt der Held in die Schenke zurueck (Zustand.wiederkehr), betrete baut den Grundriss, und
# baue_leben las die Bodenmaske „inn-boden-maske.bild“, die raum.py nie schreibt. Je Karte aus karten.json:
#  - Karten mit Gras, Korn oder Busch (Zeichen wie baue_leben), deren Netz (.bin) im Bau liegt, haben ihre Bodenmaske;
#  - Gebiet.bodenmaske gibt ohne Datei null zurueck, ohne den Bildfehler (CI: Ausgabe ohne „buffer_size“).
# Braucht daten/karten.json; mit godot/daten wie im Bau prueft er auch die gebauten Karten.
# Aufruf: im Ordner godot mit -s res://tests/maske_588.gd   (Exit 0 = gut)

func _initialize() -> void:
	var fehler := 0
	var alle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	for id in alle["karten"]:
		var d: Dictionary = alle["karten"][id]
		var wald := String(d.get("art", "")) == "FOREST"
		var gras := 0
		for z in d["zeilen"]:
			for c in String(z):
				if c in [".", "f", "T", "c"] or (c == "," and wald): gras += 1
		var gebaut := FileAccess.file_exists("res://daten/" + Gebiet.datei(id) + ".bin")
		var hat := FileAccess.file_exists("res://daten/%s.bild" % Gebiet.maske(id))
		var img := Gebiet.bodenmaske(id)
		var gut := (img != null) == hat and (img == null or img.get_width() > 0)
		if gebaut and gras > 0 and not hat: gut = false
		print("%s %s: Graskacheln %d, gebaut %s, Maske %s" % ["MASKE588 ok" if gut else "MASKE588 FALSCH", id, gras, gebaut, hat])
		if not gut: fehler += 1
	print("MASKE588 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler else 0)
