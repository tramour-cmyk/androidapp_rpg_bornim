extends SceneTree
# 390: Gegenprobe Rast (skripte/rast.gd) gegen Resting.kt und Game.rest, drinkMead, Cmd.Rest: Faelle mit den Zahlen des alten
# Spiels. Ohne Bild, endet mit Exit 0 oder 1. Vorher (wie held_golden.gd): ./gradlew -p core exportHero -Pout=$PWD/godot/daten/held.json
# und ./gradlew -p core exportTexts -Pout=$PWD/godot/daten/texte.json. Aufruf: Godot unsichtbar im Ordner godot mit -s res://tests/rast_test.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll:
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _init() -> void:
	Sprache.setze("de")
	if not FileAccess.file_exists("res://daten/held.json") or not FileAccess.file_exists("res://daten/texte.json"):
		print("RAST: daten/held.json oder texte.json fehlt")
		quit(1)
		return
	var hier := {"karte": "forest", "x": 10, "y": 12, "blick": "UP"}
	# kurze Rast am Feuer: eine Stunde, ein Viertel der TP aufgerundet, Ausdauer voll, Trank, Funke, Met enden
	var z := Zustand.new()
	var h := Heldwerte.erschaffe("Alrik", "HUMAN", "FIGHTER")
	h.tp = 1
	z.minuten = 23 * 60 + 30; z.tag = 3; z.ausdauer = 0.2; z.atemlos = true; z.ausdauer_trank = true; z.funke = true; z.met = 3
	z.dazu("raw_meat", 2)
	var r := Rast.rasten(z, h, "kurz", "feuer", hier)
	var viertel := (h.max_tp() + 3) / 4
	pruefe("kurz TP", h.tp, mini(h.max_tp(), 1 + viertel))
	pruefe("kurz Uhr", [z.tag, z.minuten], [4, 30])
	pruefe("kurz endet", [z.ausdauer, z.atemlos, z.ausdauer_trank, z.funke, z.met], [1.0, false, false, false, 0])
	pruefe("kurz Zeilen", r["zeilen"], ["Eine Stunde Ruhe. Die Ausdauer ist voll, +%d TP." % viertel, "Dein Funke ist verglommen.",
		"Du brätst 2× Fleisch über dem Feuer. Es duftet herrlich!"])
	pruefe("Fleisch", [z.anzahl("raw_meat"), z.anzahl("roast_meat")], [0, 2])
	pruefe("kurz Wiederkehr", z.wiederkehr, hier)
	pruefe("kurz Gold", z.gold, 0)
	# lange Rast: 8 Stunden, alles voll, Zustaende weg, einmal je Tag
	h.tp = 2; z.leiden = {"POISON": 3}; z.minuten = 20 * 60
	r = Rast.rasten(z, h, "lang", "feuer", hier)
	pruefe("lang TP ZP", [h.tp, h.zp], [h.max_tp(), h.max_zp()])
	pruefe("lang Uhr", [z.tag, z.minuten, z.lange_rast_tag], [5, 4 * 60, 5])
	pruefe("lang Leiden", z.leiden.size(), 0)
	pruefe("lang Zeilen", r["zeilen"], ["Acht Stunden Schlaf. TP, ZP und Ausdauer sind voll."])
	r = Rast.rasten(z, h, "lang", "feuer", hier)
	pruefe("lang zweimal", r, {"nein": "Heute hast du schon lange gerastet."})
	pruefe("kurz geht noch", Rast.rasten(z, h, "kurz", "feuer", hier).has("zeilen"), true)
	# Zimmer: 5 Gold, sonst nicht; kurz gibt es nur am Feuer; an der Theke gebucht: wach neben dem Bett
	var s := Zustand.new()
	var h2 := Heldwerte.erschaffe("Mira", "ELF", "WIZARD")
	var theke := {"karte": "inn", "x": 4, "y": 6, "blick": "UP"}
	s.gold = 4
	pruefe("Zimmer arm", Rast.rasten(s, h2, "lang", "schenke", theke), {"nein": "Dafür reicht dein Gold nicht."})
	pruefe("Zimmer kurz", Rast.rasten(s, h2, "kurz", "zimmer", theke), {})
	s.gold = 7
	r = Rast.rasten(s, h2, "lang", "schenke", theke)
	pruefe("Zimmer Gold", s.gold, 2)
	pruefe("Zimmer Klang", r["klang"], ["muenzen", "heilen"])
	pruefe("Zimmer Platz", [r["ort"], s.wiederkehr], [Rast.START, Rast.START])
	s.gold = 5
	r = Rast.rasten(s, h2, "lang", "zimmer", {"karte": "inn", "x": 9, "y": 2, "blick": "LEFT"})
	pruefe("Zimmer schon heute", r, {"nein": "Heute hast du schon lange gerastet."})
	# Met: 2 Gold, Ausdauer voll, der fuenfte macht betrunken, dann schenkt Rowena nicht mehr; nach Kapitel 1 frei
	var m := Zustand.new()
	m.gold = 20; m.ausdauer = 0.1
	pruefe("Met 1", Rast.met_trinken(m, "Alrik"), "Der Met wärmt. Die Ausdauer ist voll.")
	pruefe("Met Gold", [m.gold, m.ausdauer, m.met], [18, 1.0, 1])
	for i in 3: Rast.met_trinken(m, "Alrik")
	pruefe("Met 5", Rast.met_trinken(m, "Alrik"), "Ein Met zu viel. Du bist betrunken bis zur nächsten Rast.")
	pruefe("Met betrunken", [m.betrunken(), m.gold], [true, 10])
	pruefe("Met genug", Rast.met_trinken(m, "Alrik"), "Rowena: „Genug für heute, Alrik. Geh schlafen, die Treppe ist links.“")
	var arm := Zustand.new()
	pruefe("Met arm", Rast.met_trinken(arm, "Alrik"), "Dafür reicht dein Gold nicht.")
	arm.setze(Geschichte.CHAPTER1_DONE)
	pruefe("Met frei", [Rast.met_preis(arm), Rast.met_trinken(arm, "Alrik"), arm.gold], [0, "Der Met wärmt. Die Ausdauer ist voll.", 0])
	arm.setze(Geschichte.CAMP_TOLD)
	pruefe("Met wieder", Rast.met_preis(arm), 2)
	pruefe("Rowena", [Rast.rowena_sagt(Zustand.new(), "X", false).begins_with("Rowena: „Ein Met"), Rast.rowena_sagt(Zustand.new(), "X", true).begins_with("Rowena: „Oben")], [true, true])
	# Tempel (Cmd.Rest): alles voll, Wiederkehr hier; Heilen ohne Wiederkehr
	var t := Zustand.new()
	h.tp = 1; t.leiden = {"BLEED": 2}; t.ausdauer = 0.0
	Rast.heilen(t, h, {"karte": "temple", "x": 5, "y": 5, "blick": "UP"})
	pruefe("Tempel", [h.tp, t.leiden.size(), t.ausdauer, t.wiederkehr["karte"]], [h.max_tp(), 0, 1.0, "temple"])
	# Speichern und Laden behalten alles
	var neu := Zustand.aus_daten(z.als_daten())
	pruefe("Spielstand", [neu.lange_rast_tag, neu.wiederkehr, neu.tag, neu.minuten], [z.lange_rast_tag, z.wiederkehr, z.tag, z.minuten])
	print("RAST %s: %d Fehler" % ["OK" if fehler == 0 else "FALSCH", fehler])
	quit(1 if fehler else 0)
