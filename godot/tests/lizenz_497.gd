extends SceneTree
# 497 (Chef 03.11., 07:09, Build 204): „Über das Spiel“ nennt die Godot Engine mit ihrer Lizenz (MIT) und ihre Drittteile; die
# Texte kommen aus der Engine selbst (Engine.get_license_text, get_copyright_info, get_license_info; Godot-Doku „Complying with
# licenses“), Schrift nennt Alegreya und Fondamento; Absaetze zusammengezogen statt 80-Spalten-Umbruch (Chef 23:43). Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/lizenz_497.gd -> „LIZENZ497 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func texte(n: Node) -> String:
	var t := ""
	for l in n.find_children("*", "Label", true, false):
		if l.is_visible_in_tree(): t += String(l.text) + "\n"
	return t

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	print("ENGINE %d Drittteile, %d Lizenzen" % [Engine.get_copyright_info().size(), Engine.get_license_info().size()])
	Hauptmenue.vorspann_gezeigt = true
	var hm := Hauptmenue.new(null)
	root.add_child(hm)
	await process_frame
	hm.ueber()
	await process_frame
	var t := texte(hm)
	pruefe(t.contains("Alegreya") and t.contains("Fondamento"), "Schrift nennt nicht Alegreya und Fondamento")
	pruefe(t.contains("Godot Engine") and t.contains("MIT"), "Zeile Godot Engine (MIT) fehlt")
	pruefe(not t.contains("Permission is hereby granted"), "Lizenztext schon offen, soll erst nach Tippen")
	# 623.7: „Mit Dank an“ mit allen sieben Zeilen, Haendlernamen wie auf RenderHub
	pruefe(t.contains("MIT DANK AN") and t.contains("Diese Chronik entstand nicht allein."), "„Mit Dank an“ fehlt")
	for w in ["Effekte: REEBOO Labs", "Game-Ready Studios", "Wernerkurt", "Klang: AlanCat", "OpenGameArt", "Musik: beardalaxy", "Schriften: Juan Pablo del Peral", "Engine: Godot Engine – Juan Linietsky"]:
		pruefe(t.contains(w), "Dank: „%s“ fehlt" % w)
	pruefe(t.find("MIT DANK AN") > t.find("Godot Engine – MIT"), "Dank steht unter den Lizenzen")
	var knopf: Button = null
	for b in hm.find_children("*", "Button", true, false):
		if String(b.text).begins_with("LIZENZEN"): knopf = b
	pruefe(knopf != null, "Knopf „Lizenzen“ fehlt")
	if knopf:
		knopf.pressed.emit()
		await process_frame
		t = texte(hm)
		pruefe(t.contains(Engine.get_license_text().strip_edges().split("\n")[0]), "Lizenztext der Engine fehlt")
		var fehlt := []
		for c in Engine.get_copyright_info():
			if not t.contains(String(c["name"])): fehlt.append(c["name"])
		pruefe(fehlt.is_empty(), "Drittteile fehlen: %s" % [fehlt])
		var li := Engine.get_license_info()
		var ohne := []
		for k in li:
			if not t.contains(Hauptmenue.umbrechen(String(li[k]).strip_edges().split("\n")[0])): ohne.append(k)
		pruefe(ohne.is_empty(), "Lizenztexte fehlen: %s" % [ohne])
		# 497 (Chef 03.11., 23:43): kein fester Umbruch mitten im Satz (Zeile endet klein oder mit Komma, naechste beginnt klein)
		var stummel := RegEx.create_from_string("[a-z,;]\n[a-z]")
		var mitten := []
		for l in hm.find_children("*", "Label", true, false):
			var m := stummel.search(String(l.text))
			if m: mitten.append(String(l.text).substr(maxi(0, m.get_start() - 30), 60).c_escape())
		pruefe(mitten.is_empty(), "%d Texte mit festem Umbruch mitten im Satz, z. B. %s" % [mitten.size(), mitten.slice(0, 3)])
		pruefe(not t.contains("Â©") and not t.contains("  "), "Kodierfehler „Â©“ oder doppelte Leerzeichen")
		pruefe(t.contains("Permission is hereby granted, free of charge, to any person obtaining a copy of this software"), "MIT-Absatz nicht zusammengezogen")
		knopf.pressed.emit()
		await process_frame
		pruefe(not texte(hm).contains("Permission is hereby granted"), "zweites Tippen schliesst nicht")
	print("LIZENZ497 %d Fehler" % fehler)
	quit(1 if fehler else 0)
