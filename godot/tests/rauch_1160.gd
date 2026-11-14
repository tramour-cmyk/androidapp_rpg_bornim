extends SceneTree
# 1160 (Archivprüfung Sokrates; 427.1 Chef 02.11., 20:22; 427.2a Chef 03.11., 15:44): nach einer Niederlage gegen Krogg ein Hinweis
# auf Morwens Rauch als zweite Zeile nach [504.erwachen] ([427.2.rauch]: mit Garricks Rat, ohne ihn, mit verbrauchtem Bündel; je drei
# Wortlaute, erster beim ersten Mal); mit verbrauchtem Bündel gibt Morwen beim nächsten Besuch ein neues ([427.2a.morwen.rauch]),
# solange Krogg lebt und keins in der Tasche ist, vor ihrem üblichen Gruß. Ohne Bild, ohne Kampf.
# Aufruf: im Ordner godot mit -s res://tests/rauch_1160.gd -> „RAUCH1160 n Fehler“

const G = preload("res://skripte/geschichte.gd")

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])
	else: print("gut %s" % was)

func _initialize() -> void: _lauf.call_deferred()

# was Morwen sagt und gibt (Befehle der Geschichte)
func morwen(z: Zustand) -> Dictionary:
	var r := {"texte": [], "gibt": 0, "weg": false}
	for c in G.gespraech("morwen", z):
		match String(c["art"]):
			"sagen": r["texte"].append(String(c["text"]["de"]))
			"geben": if String(c["ding"]) == G.SMOKE_BUNDLE: r["gibt"] += int(c["anzahl"])
			"flagge_weg": if String(c["flagge"]) == G.SMOKE_DUE: r["weg"] = true
			"variante":
				var vv: Array = z.varianten.get(String(c["marke"]), [0, -1])
				z.varianten[String(c["marke"])] = [int(vv[0]) + 1, int(c["wahl"])]
	return r

func _lauf() -> void:
	var z := Zustand.new()
	# Hinweis nach der Niederlage
	var kn: Array = G.krogg_niederlage(z, false)
	pruefe("ohne Garrick: Jäger am Lagerfeuer", [String(kn[0]), String(kn[1][0][0]).contains("Jäger")], ["427.2.rauch.ohne", true])
	z.setze(G.HUNTER_MET)
	kn = G.krogg_niederlage(z, false)
	pruefe("mit Garricks Rat: Morwen", [String(kn[0]), String(kn[1][0][0]).contains("Garrick hat dich gewarnt")], ["427.2.rauch", true])
	kn = G.krogg_niederlage(z, true)
	pruefe("mit Rauch verloren: neues Bündel", [String(kn[0]), String(kn[1][0][0]).contains("neues Bündel")], ["427.2.rauch.buendel", true])
	pruefe("je drei Wortlaute", [(G.krogg_niederlage(Zustand.new(), false)[1] as Array).size(), (kn[1] as Array).size()], [3, 3])
	pruefe("erster beim ersten Mal", Skript.wahl(z, "427.2.rauch", 3), 0)
	z.varianten["427.2.rauch"] = [1, 0]
	pruefe("danach nicht derselbe", Skript.wahl(z, "427.2.rauch", 3) != 0, true)
	# Morwen: erstes Bündel wie bisher, dann ohne Niederlage keins
	z.setze(G.HERBALIST_MET)
	var m := morwen(z)
	pruefe("erstes Bündel (wants_smoke)", m["gibt"], 1)
	z.setze(G.SMOKE_GIVEN)
	m = morwen(z)
	pruefe("ohne Niederlage kein zweites", m["gibt"], 0)
	# Niederlage mit verbrauchtem Bündel: fällig, solange keins in der Tasche ist und Krogg lebt
	z.setze(G.SMOKE_DUE)
	z.dazu(G.SMOKE_BUNDLE)
	pruefe("Bündel in der Tasche: nicht fällig", G.smoke_due(z), false)
	z.weg(G.SMOKE_BUNDLE, 1)
	m = morwen(z)
	pruefe("fällig: Morwen gibt eins und löscht das Zeichen", [m["gibt"], m["weg"]], [1, true])
	pruefe("ihre Zeile vor dem Gruß", m["texte"].size() >= 2 and String(m["texte"][0]).begins_with("Krogg hat dich erwischt"), true)
	z.flaggen.erase(G.SMOKE_DUE)
	pruefe("danach nicht noch eins", morwen(z)["gibt"], 0)
	z.setze(G.SMOKE_DUE)
	pruefe("zweite Gabe: anderer Wortlaut", String(morwen(z)["texte"][0]).begins_with("Krogg hat dich erwischt"), false)
	z.setze(G.KROGG_DEFEATED)
	pruefe("Krogg besiegt: nicht fällig", G.smoke_due(z), false)
	# im Spiel: der Befehl flagge_weg löscht das Zeichen
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.setze(G.SMOKE_DUE)
	spiel.spiele([{"art": "flagge_weg", "flagge": G.SMOKE_DUE}])
	for i in 3: await process_frame
	pruefe("spiele: flagge_weg", spiel.zustand.has(G.SMOKE_DUE), false)
	print("RAUCH1160 %d Fehler" % fehler)
	quit(1 if fehler else 0)
