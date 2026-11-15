extends SceneTree
# 785.6 (MenuScreen.kt 882–887): die Kampfwerte im Reiter Ausruestung zeigen die Boni der getragenen Stuecke, die in keinem anderen
# Wert stecken: nach BRS Zauberschaden und Abwehrprobe in Prozent, nur wenn groesser 0; Lebensraub, Widerstand, Goldfund, EP nicht.
# Aufruf: im Ordner godot mit -s res://tests/kampfwerte_7856.gd -> „KAMPFWERTE7856 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func texte(n: Node) -> Array:
	return n.find_children("*", "Label", true, false).map(func(l): return (l as Label).text.replace(char(0xA0), " "))

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	for mit in [false, true]:
		var z := Zustand.new()
		var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
		if mit: hw.ausruestung["AMULET"] = {"uid": z.neue_uid(), "base": "amulet", "rarity": "RARE", "ilvl": 1, "plus": 0,
			"rolls": [["SPELL", 5], ["TENACITY", 3]], "unique": null, "name_seed": 0}
		var m := Menue.new(hw, z)
		ebene.add_child(m)
		m.reiter = "ausruestung"; m.baue()
		await process_frame
		var t := texte(m.inhalt)
		for p in [["Zauberschaden", "+5 %"], ["Abwehrprobe", "+3 %"]]:
			var k := t.find(p[0])
			pruefe((k >= 0) == mit, "%s %s" % [p[0], "fehlt" if mit else "ohne Bonus da"])
			if mit and k >= 0: pruefe(k + 1 < t.size() and t[k + 1] == p[1], "%s: %s statt %s" % [p[0], t[k + 1] if k + 1 < t.size() else "-", p[1]])
		for alt in ["Lebensraub", "Widerstand", "Goldfund"]: pruefe(not t.has(alt), "%s steht da" % alt)
		m.free()
	print("KAMPFWERTE7856 %d Fehler" % fehler)
	quit(1 if fehler else 0)
