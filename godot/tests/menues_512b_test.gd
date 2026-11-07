extends SceneTree
# 512b ohne Bild: laeuft alle Zustaende von menues_512b_schritte.gd durch und meldet je Zustand „ok <name>“ mit der Zahl offener
# Fenster und sichtbarer Texte, „GLEICH“, wenn sich gegen den vorigen Zustand nichts sichtbar geaendert hat, „FEHLT“ fuer Schirme,
# die es neu nicht gibt. Schreibt je Zustand die sichtbaren Texte (Ort, Text) nach --ordner=<dir>/<name>.txt.
# Aufruf: im Ordner godot: timeout 300 godot --headless --path . -s res://tests/menues_512b_test.gd -- --ordner=<dir>

var ordner := ""
var schritte
var vorher := ""
var zahl := 0
var gleich := 0

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ordner="): ordner = a.substr(9)
	if ordner != "": DirAccess.make_dir_recursive_absolute(ordner)
	_lauf.call_deferred()

func knips(n: String) -> void:
	for i in 3: await process_frame
	var t: Array = schritte.texte()
	var jetzt := "\n".join(PackedStringArray(t))
	var w := ""
	if jetzt == vorher:
		w = "  GLEICH wie vorher"
		gleich += 1
	vorher = jetzt
	zahl += 1
	print("ok %s fenster=%d texte=%d%s" % [n, schritte.fenster_zahl(), t.size(), w])
	if ordner != "":
		var f := FileAccess.open("%s/%s.txt" % [ordner, n], FileAccess.WRITE)
		f.store_string(jetzt + "\n")
		f.close()

func fehlt(n: String, grund: String) -> void:
	print("FEHLT %s: %s" % [n, grund])

func _lauf() -> void:
	var skript = load("res://tests/menues_512b_schritte.gd")
	if skript == null or not skript.can_instantiate():
		print("FEHLER Schritte laden nicht")
		quit(1)
		return
	schritte = skript.new(self, self)
	await schritte.lauf()
	print("512b fertig: %d Zustaende, %d gleich wie vorher" % [zahl, gleich])
	quit(0)
