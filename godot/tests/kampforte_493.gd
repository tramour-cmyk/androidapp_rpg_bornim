extends SceneTree
# 493: Kampforte im Wald wie alt (BattleScene.spotFor): Kampfort.platz_fuer wählt nach dem, was um die Kachel steht (Wasser bis 4
# Kacheln → Teich, stehende Steine bis 3 → Steinkreis, Stamm bis 3 → Baum, Felsen bis 3 → Felsen, 8 Bäume in 5 × 5 → Waldrand, sonst
# Lichtung); ein fehlendes Modell fällt auf die Lichtung zurück. Mit godot/daten (im Bau) dazu: jedes der sechs Modelle liegt im Bau,
# und auf der Karte des Flüsterwalds kommt jeder Ort vor, den sie trägt. Ohne Bild. Aufruf: im Ordner godot mit
# -s res://tests/kampforte_493.gd (Exit 0 = gut)

const KampfortS = preload("res://kampf/kampfort.gd")

var fehler := 0


func _initialize() -> void:
	_alles.call_deferred()


func _pruef(was: String, gut: bool, info := "") -> void:
	print(("gut " if gut else "FALSCH ") + was + ("" if info == "" else ": " + info))
	if not gut:
		fehler += 1


## eine Karte aus Zeilen, Zeichen wie World.kt (~ Wasser, I Menhir, O Stamm, r Fels, T Baum, . Gras)
func _karte(zeilen: Array) -> Karte:
	var k := Karte.new()
	k.kacheln = {"~": {"name": "WATER"}, "I": {"name": "MENHIR"}, "O": {"name": "LOG"}, "r": {"name": "ROCK"}, "T": {"name": "TREE"}, ".": {"name": "GRASS"}}
	k.zeilen = PackedStringArray(zeilen)
	k.breite = String(zeilen[0]).length()
	k.hoehe = zeilen.size()
	k.daten = {"rand": "T"}
	return k


func _alles() -> void:
	var leer := []
	for i in 11: leer.append("...........")
	var mitte := Vector2i(5, 5)
	_pruef("Gras: Lichtung", KampfortS.platz_fuer(_karte(leer), mitte) == "lichtung")
	var z := leer.duplicate(); z[1] = ".~........."
	_pruef("Wasser 4 Kacheln schräg: Teich", KampfortS.platz_fuer(_karte(z), mitte) == "teich")
	z = leer.duplicate(); z[0] = "~.........."
	_pruef("Wasser 5 weit: kein Teich", KampfortS.platz_fuer(_karte(z), mitte) == "lichtung")
	z = leer.duplicate(); z[2] = "........I.."; z[8] = "........O.."
	_pruef("Stein vor Stamm: Steinkreis", KampfortS.platz_fuer(_karte(z), mitte) == "steinkreis")
	z = leer.duplicate(); z[8] = "..O.....r.."
	_pruef("Stamm vor Fels: Baum", KampfortS.platz_fuer(_karte(z), mitte) == "baum")
	z = leer.duplicate(); z[3] = "..r........"
	_pruef("Fels: Felsen", KampfortS.platz_fuer(_karte(z), mitte) == "felsen")
	z = leer.duplicate(); z[3] = "...TTTTT..."; z[7] = "...TTT....."
	_pruef("8 Bäume: Waldrand", KampfortS.platz_fuer(_karte(z), mitte) == "waldrand")
	z[7] = "...TT......"
	_pruef("7 Bäume: Lichtung", KampfortS.platz_fuer(_karte(z), mitte) == "lichtung")
	_pruef("ohne Karte: Lichtung", KampfortS.platz_fuer(null, mitte) == "lichtung")
	var kf = KampfortS.new()
	kf.platz = "gibtesnicht"
	_pruef("fehlendes Modell: Lichtung", kf._platz_datei("kampfort-wald", "bin") == "res://kampf/daten/kampfort-wald.bin")
	# im Bau: die sechs Modelle und Masken, und die Orte auf der Karte des Flüsterwalds
	if FileAccess.file_exists("res://kampf/daten/kampfort-wald.bin"):
		for o in KampfortS.PLAETZE:
			kf.platz = o
			var p: String = kf._platz_datei("kampfort-wald", "bin")
			_pruef("Modell " + o, FileAccess.file_exists(p) and (o == "lichtung" or p.ends_with("-%s.bin" % o)), p)
			_pruef("Maske " + o, kf._platz_datei("wald-maske", "bild").ends_with("wald-maske.bild" if o == "lichtung" else "-%s.bild" % o))
		if FileAccess.file_exists("res://daten/karten.json"):
			for id in ["forest", "deep_forest"]:
				var alle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
				if not alle["karten"].has(id): continue
				var k := Karte.lade(id)
				var zahl := {}
				for y in k.hoehe:
					for x in k.breite:
						if k.begehbar(Vector2i(x, y)):
							var o := KampfortS.platz_fuer(k, Vector2i(x, y))
							zahl[o] = int(zahl.get(o, 0)) + 1
				print("Kampforte %s (begehbare Kacheln): %s" % [id, zahl])
	kf.free()
	print("KAMPFORTE493 %d Fehler" % fehler)
	quit(1 if fehler else 0)
