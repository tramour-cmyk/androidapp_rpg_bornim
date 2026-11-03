extends SceneTree
# 497 (Chef 03.11., 07:09, Build 204): „Über das Spiel“ nennt die Godot Engine mit ihrer Lizenz (MIT) und ihre Drittteile; die
# Texte kommen aus der Engine selbst (Engine.get_license_text, get_copyright_info, get_license_info; Godot-Doku „Complying with
# licenses“), Schrift nennt Alegreya und Fondamento. Ohne Bild.
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
			if not t.contains(String(li[k]).strip_edges().split("\n")[0]): ohne.append(k)
		pruefe(ohne.is_empty(), "Lizenztexte fehlen: %s" % [ohne])
		knopf.pressed.emit()
		await process_frame
		pruefe(not texte(hm).contains("Permission is hereby granted"), "zweites Tippen schliesst nicht")
	print("LIZENZ497 %d Fehler" % fehler)
	quit(1 if fehler else 0)
