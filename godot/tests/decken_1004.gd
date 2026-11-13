# 1004 (alt 72.10a.9; Homer [870.14.ansage.heavy], STORY-BRS-KAMPF.md): „Decken“ ist eine Fähigkeit des Wächters, der Held nach BRS
# hat den Knopf in Kapitel 1 nicht; kein Hinweis außer dem des Knopfs selbst (COVER) nennt ihn. Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/decken_1004.gd (Exit 0 = richtig)
extends SceneTree


func _initialize() -> void:
	var fehler := 0
	var texte := {}
	var karte: Dictionary = (load("res://kampf/marstips.gd") as Script).get_script_constant_map()
	for n in karte:
		var v = karte[n]
		if n == "COVER":
			continue
		if v is Array:
			texte[n] = v
		elif v is Dictionary:
			for k in v:
				texte["%s.%s" % [n, k]] = v[k]
	for n in texte:
		var de := String(texte[n][0]) if texte[n].size() > 0 else ""
		var en := String(texte[n][1]) if texte[n].size() > 1 else ""
		if de.contains("Decken") or en.contains("Cover"):
			fehler += 1
			print("FEHLER %s nennt Decken: %s" % [n, de])
	print("Decken 1004: %d Hinweise gelesen, %s" % [texte.size(), "keiner nennt Decken" if fehler == 0 else "%d nennen Decken" % fehler])
	quit(1 if fehler else 0)
