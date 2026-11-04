extends SceneTree
# 489 (Chef 03.11., 07:07): im Hauptmenü wie in der alten Fassung (App.kt) drei runde Zeichen: Sprache, Musik, Effekte. Musik und
# Effekte schalten stumm (Klang.schalte, Bus leise, gespeichert in user://klang.cfg), ein zweites Tippen wieder an; das Zeichen ist
# durchgestrichen, solange aus. Braucht godot/daten wie im Bau (Hauptmenü). Aufruf: im Ordner godot mit
# -s res://tests/klangschalter_489.gd (Exit 0 = gut). Der Einstellungsstand vorher wird am Ende wiederhergestellt.

const KlangS = preload("res://klang/klang.gd")

var fehler := 0


func _initialize() -> void:
	_alles.call_deferred()


func _pruef(was: String, gut: bool, info := "") -> void:
	print(("gut " if gut else "FALSCH ") + was + ("" if info == "" else ": " + info))
	if not gut:
		fehler += 1


func _db(bus: String) -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))


func _gespeichert(schluessel: String) -> bool:
	var c := ConfigFile.new()
	c.load("user://klang.cfg")
	return bool(c.get_value("klang", schluessel, true))


## die runden Zeichen des Hauptmenüs mit Zeichnung (Musik, Effekte), in der Reihenfolge im Baum
func _zeichen(hm: Node) -> Array:
	var r := []
	for b in hm.find_children("*", "Button", true, false):
		for c in b.get_children():
			if c is Control and not (c is Label) and c.draw.get_connections().size() > 0:
				r.append(b)
				break
	return r


func _alles() -> void:
	var k = get_root().get_node_or_null("Klang")
	if k == null:
		k = KlangS.new()
		k.name = "Klang"
		root.add_child(k)
	await process_frame
	var vorher := [k.musik_an, k.effekte_an]
	if not k.musik_an: k.schalte("music")
	if not k.effekte_an: k.schalte("fx")
	var laut_m := _db("Musik")
	var laut_e := _db("Effekte")
	k.schalte("music")
	_pruef("Musik aus", not k.musik_an and _db("Musik") < -70.0 and _db("Effekte") == laut_e, "%.0f dB" % _db("Musik"))
	_pruef("Musik aus gespeichert", not _gespeichert("music"))
	k.schalte("music")
	_pruef("Musik wieder an", k.musik_an and is_equal_approx(_db("Musik"), laut_m) and _gespeichert("music"), "%.0f dB" % _db("Musik"))
	k.schalte("fx")
	_pruef("Effekte aus", not k.effekte_an and _db("Effekte") < -70.0 and is_equal_approx(_db("Musik"), laut_m), "%.0f dB" % _db("Effekte"))
	_pruef("Effekte aus gespeichert", not _gespeichert("sfx"))
	k.schalte("fx")
	_pruef("Effekte wieder an", k.effekte_an and is_equal_approx(_db("Effekte"), laut_e) and _gespeichert("sfx"))
	# im Hauptmenü: zwei Zeichen neben der Sprache, Tippen schaltet und zeichnet neu
	Hauptmenue.vorspann_gezeigt = true
	var hm := Hauptmenue.new(null)
	root.add_child(hm)
	await process_frame
	var z := _zeichen(hm)
	_pruef("zwei Zeichen Musik, Effekte", z.size() == 2, str(z.size()))
	if z.size() == 2:
		_pruef("Zeichen in einer Reihe mit der Sprache", z[0].get_parent() == z[1].get_parent() and z[0].get_parent().get_child_count() == 3)
		(z[0] as Button).pressed.emit()
		await process_frame
		_pruef("Tippen Musik: aus", not k.musik_an)
		var z2 := _zeichen(hm)
		_pruef("Menü neu, wieder zwei Zeichen", z2.size() == 2)
		if z2.size() == 2:
			(z2[1] as Button).pressed.emit()
			await process_frame
			_pruef("Tippen Effekte: aus", not k.effekte_an)
	# Stand von vorher
	if k.musik_an != vorher[0]: k.schalte("music")
	if k.effekte_an != vorher[1]: k.schalte("fx")
	print("KLANGSCHALTER489 %d Fehler" % fehler)
	quit(1 if fehler else 0)
