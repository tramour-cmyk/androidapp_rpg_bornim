extends SceneTree
# 500 (Chef 03.11., 07:24, Build 204): die Probeknoepfe rechts in der Welt (Tag/Nacht, Nah/Fern, Drehen, Sprache, Tiere) sind weg;
# Windrose, Aktions- und Laufknopf bleiben. Tag/Nacht steht im Testmenue (testmodus_399). Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/probeknoepfe_500.gd -> „PROBEKNOEPFE500 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	var ui := Steuerung.new()
	root.add_child(ui)
	await process_frame
	pruefe(ui.oben.get_child_count() == 0, "rechts stehen noch %d Probeknoepfe" % ui.oben.get_child_count())
	var texte := ui.find_children("*", "Button", true, false).map(func(b): return String(b.text))
	for alt in ["Tag / Nacht", "Nah / Fern", "Drehen ◀", "Drehen ▶", "Deutsch / English", "Tiere"]:
		pruefe(not texte.has(alt), "Knopf „%s“ noch da" % alt)
	pruefe(ui.windrose != null and ui.aktion_knopf != null and ui.lauf_knopf != null, "Windrose, Aktions- oder Laufknopf fehlt")
	print("PROBEKNOEPFE500 %d Fehler" % fehler)
	quit(1 if fehler else 0)
