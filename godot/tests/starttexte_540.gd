extends SceneTree
# 540 (Abgleich Build 249: „Texte hängen am Spielbeginn“): ohne Bild; wie alt (Story.southEdge, Game.barrier, lockedDoor 12/5,
# Story.inn): der Suedrand denkt nach dem Stand der Geschichte (je Abschnitt erst lang, dann kurz, im Spielstand gemerkt; nach
# Lyras Lager „Kapitel 2 folgt“), der Schlagbaum nach dem Auftrag „Sprich mit Wache Jorin“, 12/5 nach Kapitel 1 anders, der Tipp
# beim Erwachen nach der Steuerung. Aufruf: im Ordner godot mit -s res://tests/starttexte_540.gd -> „STARTTEXTE n Fehler“

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])
	else: print("gut %s" % was)

func rand(z: Zustand) -> String: return String(Geschichte.suedrand(z)["text"]["de"])

func tipp(z: Zustand) -> String:
	var k := Skript.new()
	Geschichte.intro(k, z)
	for b in k.befehle:
		if b["art"] == "sagen" and String(b["text"]["de"]).begins_with("Tipp:"): return String(b["text"]["de"])
	return ""

func _lauf() -> void:
	var z := Zustand.new()
	pruefe("Südrand vorher lang", rand(z).begins_with("Du bist von Süden gekommen"), true)
	pruefe("Südrand vorher kurz", rand(z), "Erst willst du wissen, was in Bornim geschehen ist.")
	z.setze(Geschichte.QUEST_STARTED)
	pruefe("Südrand mit Auftrag lang", rand(z), "Lyra ist irgendwo im Norden. Der Weg nach Süden kann warten.")
	pruefe("Südrand mit Auftrag kurz", rand(z), "Der Weg nach Süden kann warten.")
	var neu := Zustand.aus_daten(z.als_daten())
	pruefe("gemerkt im Spielstand", rand(neu), "Der Weg nach Süden kann warten.")
	z.setze(Geschichte.CHAPTER1_DONE)
	pruefe("Südrand nach Kapitel 1 lang", rand(z).begins_with("Der Brief mit dem grauen Siegel"), true)
	pruefe("Südrand nach Kapitel 1 kurz", rand(z), "Die Antwort liegt nicht im Süden.")
	z.setze(Geschichte.CAMP_TOLD)
	var kap2 := "Der Weg nach Süden ist noch nicht begehbar. Kapitel 2 folgt mit einem späteren Update."
	pruefe("Südrand nach Lyras Lager", [rand(z), rand(z)], [kap2, kap2])
	var z2 := Zustand.new()
	pruefe("Schlagbaum vorher", Geschichte.schlagbaum(z2), Geschichte.BARRIER_DOWN)
	z2.setze(Geschichte.QUEST_STARTED)
	pruefe("Schlagbaum mit Auftrag", String(Geschichte.schlagbaum(z2)["de"]), "Der Schlagbaum ist unten. Sprich mit Wache Jorin, damit er ihn öffnet.")
	pruefe("12/5 vor Kapitel 1 wie karten.json", Geschichte.klopfen("village", Vector2i(12, 5), z2), {})
	z2.setze(Geschichte.CHAPTER1_DONE)
	pruefe("12/5 nach Kapitel 1", String(Geschichte.klopfen("village", Vector2i(12, 5), z2)["de"]), "„Du hast die Goblins vertrieben? … Morgen vielleicht. Heute nicht.“")
	pruefe("andere Tür unverändert", Geschichte.klopfen("village", Vector2i(23, 5), z2), {})
	pruefe("Tipp Wischen (663: nur Touch)", tipp(Zustand.new()).begins_with("Tipp: Zieh den Finger"), true)
	print("STARTTEXTE %d Fehler" % fehler)
	quit(1 if fehler else 0)
