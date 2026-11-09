# 504.1 Gespräche in Varianten (Chef 03.11., 07:52; STORY-VARIANTEN-K1.md): headless, ohne Daten.
#  - jede Marke aus Varianten.V wird im Code benutzt (geschichte.gd oder spiel.gd TEXT_MARKE), jede hat mindestens drei Wortlaute
#  - erstes Hoeren Wortlaut 1; danach nie derselbe zweimal hintereinander; in 8 Gespraechen alle drei Wortlaute
#  - „nur Wiederholung“ (Krogg): nach dem ersten Mal nie Wortlaut 1
#  - der Ruf (Ruf.abdruck) bleibt gleich, egal welcher Wortlaut
#  - die Wahl steht im Spielstand (als_daten / aus_daten)
# Run: godot --headless --path godot -s res://tests/varianten_504.gd   (Ende 0 = alles richtig)
extends SceneTree

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("ok     " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

# wie spiel.gd weiter(): Befehl „variante“ zaehlt das Gehoerte
func hoere(befehle: Array, s: Zustand) -> String:
	var t := PackedStringArray()
	for c in befehle:
		if String(c["art"]) == "sagen": t.append(String(c["text"]["de"]))
		if String(c["art"]) == "variante":
			var v: Array = s.varianten.get(String(c["marke"]), [0, -1])
			s.varianten[String(c["marke"])] = [int(v[0]) + 1, int(c["wahl"])]
	return " / ".join(t)

func _initialize() -> void:
	var code := FileAccess.get_file_as_string("res://skripte/geschichte.gd") + FileAccess.get_file_as_string("res://skripte/spiel.gd")
	var fehlt: Array = []
	for m in Varianten.V:
		if not code.contains("\"%s\"" % m): fehlt.append(m)
		pruefe(1 + (Varianten.V[m]["v"] as Array).size() >= 3, "%s: %d Wortlaute" % [m, 1 + (Varianten.V[m]["v"] as Array).size()])
	pruefe(fehlt.is_empty(), "alle %d Marken im Code (fehlt: %s)" % [Varianten.V.size(), fehlt])
	var s := Zustand.new()
	var folge: Array = []
	for i in 8: folge.append(hoere(Geschichte.gespraech("jorin", s), s))
	pruefe(String(folge[0]).begins_with("Halt! Der Flüsterwald"), "Jorin zuerst Wortlaut 1")
	var doppelt := 0
	for i in range(1, folge.size()):
		if folge[i] == folge[i - 1]: doppelt += 1
	pruefe(doppelt == 0, "nie zweimal hintereinander derselbe (%d)" % doppelt)
	var arten := {}
	for f in folge: arten[f] = true
	pruefe(arten.size() == 3, "in 8 Gespraechen %d von 3 Wortlauten" % arten.size())
	var a1 := Ruf.abdruck(Geschichte.gespraech("jorin", s))
	hoere(Geschichte.gespraech("jorin", s), s)
	pruefe(a1 == Ruf.abdruck(Geschichte.gespraech("jorin", s)), "Ruf bleibt bei anderem Wortlaut gleich")
	var k: Array = []
	for i in 6: k.append(hoere(Geschichte.gespraech("krogg", s), s))
	pruefe(String(k[0]).begins_with("WER STÖRT KROGG"), "Krogg zuerst Wortlaut 1")
	var wieder := 0
	for i in range(1, k.size()):
		if String(k[i]).begins_with("WER STÖRT KROGG"): wieder += 1
	pruefe(wieder == 0, "Krogg (nur Wiederholung) danach nie Wortlaut 1 (%d)" % wieder)
	var z := Zustand.aus_daten(s.als_daten())
	pruefe(z.varianten == s.varianten, "Wahl im Spielstand (%d Marken)" % z.varianten.size())
	print("VARIANTEN504 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
