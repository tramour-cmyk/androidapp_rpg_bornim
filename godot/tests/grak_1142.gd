extends SceneTree
# 1142 (Chef 13.11., 14:44, Build 282: nach dem Sieg über Grak „etwas Text … dann kam nochmal der Kampf“): nach dem Kampf setzt
# kampf_im_wald den Helden auf seine Kachel zurück (held.setze → steht_auf → _betritt), bevor grak_defeated gesetzt ist; auf dem
# Auslöser vor Graks Halle (10|11, 4) hängte sich ein zweites grak_talk an die laufende Szene. Prüft: der Auslöser gäbe ohne Flagge
# wirklich ein zweites grak_talk (die Falle), Geschichte.ausloeser_frei sperrt ihn im Kampf und bei laufender Szene, nach dem Sieg
# gibt es keinen Auslöser mehr, und ein Szenenkampf mit gesetzter Flagge wird übersprungen. Ohne Bildbefehl.
# Aufruf: im Ordner godot mit -s res://tests/grak_1142.gd -> „GRAK1142 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func kaempfe(bef: Array) -> Array:
	return bef.filter(func(c): return String(c["art"]) == "kampf")

func _lauf() -> void:
	Sprache.setze("de")
	var z := Zustand.new()
	var szene := Geschichte.ausloeser("cave", Vector2i(10, 4), z)
	var k := kaempfe(szene)
	pruefe(k.size() == 1 and String(k[0]["flagge"]) == Geschichte.GRAK_DEFEATED, "vor der Halle kein Kampf gegen Grak: %s" % [k])
	# die Szene läuft bis zum Kampf; der Rest („Unmöglich …“, Lyra) wartet in der Schlange
	var i := szene.find(k[0])
	var rest := szene.slice(i + 1)
	pruefe(not rest.is_empty(), "nach dem Kampf kein Text mehr in der Szene")
	# im Kampf, vor der Flagge: derselbe Auslöser gäbe ein zweites grak_talk (so kam der zweite Kampf)
	pruefe(kaempfe(Geschichte.ausloeser("cave", Vector2i(10, 4), z)).size() == 1, "Falle nicht nachgestellt: ohne Flagge kein zweites grak_talk")
	pruefe(not Geschichte.ausloeser_frei(false, true, false), "Auslöser im Kampf frei")
	pruefe(not Geschichte.ausloeser_frei(false, false, false), "Auslöser bei laufender Szene frei")
	pruefe(not Geschichte.ausloeser_frei(true, false, true), "Auslöser im Gespräch frei")
	pruefe(Geschichte.ausloeser_frei(false, false, true), "Auslöser sonst gesperrt")
	# nach dem Sieg
	z.setze(Geschichte.GRAK_DEFEATED)
	pruefe(Geschichte.ausloeser("cave", Vector2i(10, 4), z).is_empty(), "nach dem Sieg spricht Grak wieder")
	pruefe(Geschichte.ausloeser("cave", Vector2i(11, 4), z).is_empty(), "nach dem Sieg spricht Grak wieder (11|4)")
	pruefe(Geschichte.kampf_schon_gewonnen(k[0], z), "Kampf mit gesetzter Flagge nicht übersprungen")
	pruefe(not Geschichte.kampf_schon_gewonnen({"art": "kampf", "monster": "wolf", "flagge": ""}, z), "Kampf ohne Flagge übersprungen")
	print("GRAK1142 %d Fehler" % fehler)
	quit(1 if fehler else 0)
