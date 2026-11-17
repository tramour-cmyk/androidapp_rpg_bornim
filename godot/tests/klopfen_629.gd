extends SceneTree
# 629.1 (Homer [629.sprecher], Chef 611): an jeder Tuer des Dorfs, Tag und Nacht, auch Wortlaut 2 und 3 und Edriks Satz nach Kapitel 1:
# Gesprochenes mit dem Namen der Stimme und ohne Anfuehrungszeichen, Erzaehltes ohne Namen. Aufruf: -s res://tests/klopfen_629.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var k: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))["karten"]["village"]
	var n := 0
	for a in k["ausgaenge"]:
		if not a.has("klopfen"): continue
		var t := Vector2i(int(a["x"]), int(a["y"]))
		for zeit in ["tag", "nacht"]:
			var basis: Array = a["klopfen"][zeit]
			var de := String(basis[0]["text"]["de"])
			# dazu ein Wortlaut 2 wie aus variiere (spiel.gd): Gesagtes kommt dort wieder in Anfuehrungszeichen
			for z in Geschichte.klopf_sprecher("village", t, basis) + Geschichte.klopf_sprecher("village", t, [{"text": {"de": "„Zweiter Wortlaut.“", "en": "“Second.”"}}] if de.begins_with("„") else []):
				n += 1
				var d := String(z["text"]["de"])
				if de.begins_with("„"):
					pruefe(z.has("wer") and not d.begins_with("„") and not d.ends_with("“") and not String(z["text"]["en"]).begins_with("“"), "%s %s: %s sagt „%s“" % [t, zeit, Sprache.t(z.get("wer", {"de": "NIEMAND"})) if z.has("wer") else "NIEMAND", d])
				else:
					pruefe(not z.has("wer"), "%s %s: erzählt ohne Namen: %s" % [t, zeit, d])
	var ende := Geschichte.klopf_sprecher("village", Vector2i(12, 5), [{"text": {"de": "„Du hast die Goblins vertrieben? … Morgen vielleicht. Heute nicht.“", "en": "“You drove off the goblins? … Tomorrow, maybe. Not today.”"}}])
	pruefe(ende[0].get("wer", {}).get("de", "") == "Bäcker Edrik" and String(ende[0]["text"]["de"]).begins_with("Du hast"), "Edrik nach Kapitel 1: %s" % [ende])
	pruefe(n >= 15, "%d Zeilen geprüft" % n)
	print("KLOPFEN629 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
