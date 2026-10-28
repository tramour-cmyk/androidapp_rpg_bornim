# 348.12f/348.12i: jedes gekaufte Modell aus kampf/daten/kauf.txt liegt verschlüsselt („BKV1“) und wird mit dem Schlüssel des Laufs
# (schluessel.gd) wieder zu einem glTF-Binärmodell („glTF“ am Anfang), wie figur.gd lade_bin es lädt.
# Run: godot --headless --path godot -s res://tests/kauf_entschluesseln.gd   (exit code 0 = alle lesbar)
extends SceneTree

const Figur = preload("res://kampf/figur.gd")


func _init() -> void:
	var liste := "res://kampf/daten/kauf.txt"
	var fehler := 0
	var n := 0
	if not FileAccess.file_exists(liste):
		print("kauf.txt fehlt")
		quit(1)
		return
	for zeile in FileAccess.get_file_as_string(liste).split("\n", false):
		var p := "res://" + zeile.strip_edges()
		n += 1
		var roh := FileAccess.get_file_as_bytes(p)
		var b := Figur.lade_bin(p)
		var verschl := roh.size() >= 4 and roh.slice(0, 4).get_string_from_ascii() == "BKV1"
		var gltf := b.size() >= 4 and b.slice(0, 4).get_string_from_ascii() == "glTF"
		if not (verschl and gltf):
			fehler += 1
			print("FEHLER %s: verschlüsselt %s, entschlüsselt glTF %s" % [p, verschl, gltf])
	print("Kaufmodelle: %d, verschlüsselt und lesbar %d" % [n, n - fehler])
	quit(1 if fehler > 0 or n == 0 else 0)
