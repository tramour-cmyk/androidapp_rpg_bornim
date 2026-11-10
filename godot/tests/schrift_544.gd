# 544 (Chef 03.11., 23:49 „Stimmt die Schrift?“): der Kampfschirm zeigte im APK die Ersatzschrift, weil kampf_ui.gd die rohe .ttf mit
# load_dynamic_font las; im APK steht nur die importierte .fontdata (export_presets include_filter ohne .ttf). Prüft: der Kampfschirm
# hat Alegreya über den Import, und kein Spielskript liest eine Schrift außerhalb von daten/ roh. Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/schrift_544.gd
extends SceneTree

const Ui = preload("res://kampf/kampf_ui.gd")

var fehler := 0


func _init() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	# ohne Kampfort meldet kampf_ui.gd _ready Fehler nach dem Laden der Schrift; hier zählt nur die Schrift. Nachgestellt (03.11.,
	# 23:57): ohne die rohe .ttf (wie im APK) gab die alte Fassung eine leere Schrift ohne Namen, die neue Alegreya
	var ui = Ui.new()
	root.add_child(ui)
	await process_frame
	var f: Font = ui.font
	if f == null or not f.get_font_name().to_lower().begins_with("alegreya"):
		fehler += 1
		print("FEHLER Kampfschrift: „%s“" % (f.get_font_name() if f != null else "keine"))
	ui.queue_free()
	# rohes Lesen einer Schrift nur aus daten/ (dort liegen die Dateien roh im APK)
	for ordner in ["res://kampf", "res://skripte", "res://regeln"]:
		for d in DirAccess.get_files_at(ordner):
			if not d.ends_with(".gd"):
				continue
			var text := FileAccess.get_file_as_string(ordner + "/" + d)
			var at := text.find("load_dynamic_font(\"res://")
			if at >= 0 and not text.substr(at, 40).contains("res://daten/"):
				fehler += 1
				print("FEHLER %s/%s liest eine Schrift roh (fehlt im APK)" % [ordner, d])
	print("SCHRIFT 544 %s" % ("ok" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
