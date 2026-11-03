extends SceneTree
# 507: Kampforte der Höhle wie alt (CaveScene.spotFor): Kampfort.hoehlenplatz_fuer wählt nach dem, was um die Kachel steht (Ausgang oder
# Eingang bis 3 → Eingang, Feuer, Kiste, Schlaflager bis 3 → Lager, Wasser bis 3 → Teich, Stützbalken bis 1 → Gang, weniger als 13
# begehbare Kacheln in 5 × 5 → Gang, sonst Halle); Vorrang in dieser Reihenfolge wie alt. Ohne Bild, ohne godot/daten.
# Aufruf: im Ordner godot mit -s res://tests/hoehle_507.gd; massgeblich ist die Zeile HOEHLE507.

const KampfortS = preload("res://kampf/kampfort.gd")

var fehler := 0

func _initialize() -> void:
	_alles.call_deferred()

func _pruef(was: String, gut: bool, info := "") -> void:
	print(("gut " if gut else "FALSCH ") + was + ("" if info == "" else ": " + info))
	if not gut: fehler += 1

## eine Höhle aus Zeilen, Zeichen wie Tile.kt (X Wand, _ Boden, E Eingang, + Ausgang, F Feuer, u Kiste, e Schlaflager, ~ Wasser, H Stütze)
func _karte(zeilen: Array) -> Karte:
	var k := Karte.new()
	k.kacheln = {"X": {"name": "CAVE_WALL", "begehbar": false}, "_": {"name": "CAVE_FLOOR", "begehbar": true},
		"E": {"name": "CAVE_ENTRANCE", "begehbar": true}, "+": {"name": "CAVE_EXIT", "begehbar": true}, "F": {"name": "CAMPFIRE", "begehbar": false},
		"u": {"name": "CRATE", "begehbar": false}, "e": {"name": "BEDROLL", "begehbar": true}, "~": {"name": "WATER", "begehbar": false},
		"H": {"name": "SUPPORT", "begehbar": true}}
	k.zeilen = PackedStringArray(zeilen)
	k.breite = String(zeilen[0]).length()
	k.hoehe = zeilen.size()
	k.daten = {"rand": "X"}
	return k

func _setze(z: Array, x: int, y: int, c: String) -> Array:
	var n := z.duplicate()
	var s := String(n[y])
	n[y] = s.substr(0, x) + c + s.substr(x + 1)
	return n

func _alles() -> void:
	var halle := []
	for i in 11: halle.append("___________")
	var m := Vector2i(5, 5)
	var p := func(z: Array) -> String: return KampfortS.hoehlenplatz_fuer(_karte(z), m)
	_pruef("offener Boden: Halle", p.call(halle) == "halle")
	_pruef("Ausgang 3 Kacheln schräg: Eingang", p.call(_setze(halle, 2, 2, "+")) == "eingang")
	_pruef("Eingang 3 Kacheln: Eingang", p.call(_setze(halle, 8, 5, "E")) == "eingang")
	_pruef("Ausgang 4 Kacheln: nicht Eingang", p.call(_setze(halle, 1, 5, "+")) == "halle")
	_pruef("Feuer: Lager", p.call(_setze(halle, 3, 3, "F")) == "lager")
	_pruef("Kiste: Lager", p.call(_setze(halle, 7, 7, "u")) == "lager")
	_pruef("Schlaflager: Lager", p.call(_setze(halle, 5, 8, "e")) == "lager")
	_pruef("Wasser 3: Teich", p.call(_setze(halle, 8, 8, "~")) == "teich")
	_pruef("Wasser 4: Halle", p.call(_setze(halle, 9, 5, "~")) == "halle")
	_pruef("Stütze daneben: Gang", p.call(_setze(halle, 6, 6, "H")) == "gang")
	_pruef("Stütze 2 Kacheln: Halle", p.call(_setze(halle, 7, 5, "H")) == "halle")
	# Vorrang: Eingang vor Lager vor Teich vor Gang
	var alle := _setze(_setze(_setze(_setze(halle, 2, 2, "+"), 3, 3, "F"), 8, 8, "~"), 6, 6, "H")
	_pruef("Eingang vor Lager, Teich, Gang", p.call(alle) == "eingang")
	_pruef("Lager vor Teich", p.call(_setze(_setze(halle, 3, 3, "F"), 8, 8, "~")) == "lager")
	_pruef("Teich vor Gang", p.call(_setze(_setze(halle, 8, 8, "~"), 6, 6, "H")) == "teich")
	# enger Gang: eine Spalte Boden (5 von 25 begehbar), dann drei Spalten (15 von 25)
	var eng := []
	for i in 11: eng.append("XXXXX_XXXXX")
	_pruef("enger Gang: Gang", p.call(eng) == "gang")
	var breit := []
	for i in 11: breit.append("XXXX___XXXX")
	_pruef("drei Kacheln breit: Halle (15 offen)", p.call(breit) == "halle")
	var zwei := []
	for i in 11: zwei.append("XXXX__XXXXX")
	_pruef("zwei Kacheln breit: Gang (10 offen)", p.call(zwei) == "gang")
	_pruef("am Kartenrand: Wand außerhalb zählt nicht", KampfortS.hoehlenplatz_fuer(_karte(halle), Vector2i(0, 0)) == "gang")
	_pruef("ohne Karte: Halle", KampfortS.hoehlenplatz_fuer(null, m) == "halle")
	_pruef("fünf Orte", KampfortS.HOEHLENPLAETZE == ["eingang", "gang", "halle", "teich", "lager"])
	print("HOEHLE507 %s, %d Fehler" % ["gut" if fehler == 0 else "FEHLER", fehler])
	quit(1 if fehler else 0)
