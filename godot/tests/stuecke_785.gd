extends SceneTree
# Rückläufer t288 (Sokrates 15.11., 16:18): Lage „stuecke=785“ legt feste Stücke in die Tasche, ohne Zufall: Ring „+1 Kraft“ (785.1),
# Amulett „+5 % Zauberschaden“, Handschuhe „+5 % Abwehrprobe“ (785.6); die Lage ist gültig und nennt sich im Text.
# Aufruf: im Ordner godot mit -s res://tests/stuecke_785.gd -> „STUECKE785 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var l := {"stuecke": "785"}
	pruefe(Testmodus.lage_fehler(l).is_empty(), "Lage stuecke=785 nicht gültig: %s" % [Testmodus.lage_fehler(l)])
	pruefe(not Testmodus.lage_fehler({"stuecke": "x"}).is_empty(), "stuecke=x gilt als gültig")
	pruefe(Testmodus.lage_text(l, true).contains("Stücke 785"), "Lagetext ohne „Stücke 785“: %s" % Testmodus.lage_text(l, true))
	for runde in 3:   # ohne Zufall: dreimal dasselbe
		var z := Zustand.new()
		var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
		var vor := z.beutel.size()
		var s := Testmodus.stuecke(hw, z, "785")
		pruefe(z.beutel.size() == vor + 3, "Runde %d: %d statt 3 Stücke in der Tasche" % [runde, z.beutel.size() - vor])
		for g in s: pruefe(String(g["rolls"][0][0]) != "Kraft", "Zusatz „Kraft“ ohne Schlüssel aus den Daten")
		var worte := s.map(func(g): return Beute.zusatz_text(g["rolls"][0], "de"))
		for w in ["+1 Kraft", "+5 % Zauberschaden", "+5 % Abwehrprobe"]:
			pruefe(worte.has(w), "Runde %d: „%s“ fehlt (%s)" % [runde, w, worte])
	print("STUECKE785 %d Fehler" % fehler)
	quit(1 if fehler else 0)
