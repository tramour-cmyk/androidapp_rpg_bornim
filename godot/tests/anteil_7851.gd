extends SceneTree
# 785.1 (MenuScreen.kt 633–651): der Reiter Held zeigt neben jedem Grundwert den Anteil der Ausruestung blau („+2“), leer ohne
# Anteil, und darunter den Satz zur Farbe, nur wenn irgendein Grundwert einen Anteil hat; der Satz zur Obergrenze entfaellt (644b A).
# Aufruf: im Ordner godot mit -s res://tests/anteil_7851.gd -> „ANTEIL7851 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	for mit in [false, true]:
		var z := Zustand.new()
		z.name = "Thora"
		var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
		if mit: hw.ausruestung["AMULET"] = {"uid": z.neue_uid(), "base": "amulet", "rarity": "RARE", "ilvl": 1, "plus": 0,
			"rolls": [["STR", 2], ["ALL_STATS", 1]], "unique": null, "name_seed": 0}
		var m := Menue.new(hw, z)
		ebene.add_child(m)
		await process_frame
		for g in BrsHeld.grundwerte():
			var b := m.find_child("Ausruestung_" + String(g), true, false) as Label
			pruefe(b != null, "Anteil %s fehlt" % g)
			if b == null: continue
			var soll := ("+3" if g == "kraft" else "+1") if mit else ""
			pruefe(b.text == soll, "Anteil %s: '%s' statt '%s'" % [g, b.text, soll])
		var s := m.find_child("Ausruestung_Satz", true, false) as Label
		pruefe((s != null) == mit, "Satz zur Farbe %s" % ("fehlt" if mit else "ohne Anteil da"))
		if s: pruefe(s.text.replace(char(0xA0), " ") == "Blau: Bonus durch Ausrüstung (im Wert enthalten)", "Wortlaut: %s" % s.text)
		if mit: pruefe(hw.wert("kraft") == hw.grundwert("kraft") + hw.uebungs_plus("kraft") + 3, "Wert Kraft ohne Anteil")
		m.free()
	print("ANTEIL7851 %d Fehler" % fehler)
	quit(1 if fehler else 0)
