extends SceneTree
# 399.1 ohne Bild: Anschlagbrett wie alt (Jobs.kt, BoardScreen.kt, ChronicleTab): Aushaenge in Wellen, gelesen, annehmen, in der
# Chronik mit Stand, abgeben beim Auftraggeber (Gold, Gaben, Kopfschutz von Jorin). Aufruf: im Ordner godot mit -s res://tests/brett_test.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll:
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _initialize() -> void: _lauf.call_deferred()

func ids(a: Array) -> Array: return a.map(func(j): return String(j["id"]))

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	pruefe("erste Welle", ids(Auftraege.am_brett(z)), ["pelts", "ring", "tusks"])
	pruefe("frisch", Auftraege.frisch(z), true)
	Auftraege.lies(z)
	pruefe("gelesen", Auftraege.frisch(z), false)
	z.setze(String(Auftraege.von("stones")["nach"]))   # Krogg besiegt
	pruefe("zweite Welle", [ids(Auftraege.am_brett(z)), Auftraege.frisch(z)], [["pelts", "ring", "tusks", "glands", "stones"], true])
	# annehmen: in der Chronik, Stern am Reiter
	Chronik.gelesen(z)
	Auftraege.nimm(z, Auftraege.von("pelts"))
	pruefe("getragen", ids(Auftraege.getragen(z)), ["pelts"])
	pruefe("Chronik neu", Chronik.frisch(z), true)
	Chronik.gelesen(z)
	pruefe("Chronik gelesen", Chronik.frisch(z), false)
	z.dazu("wolf_pelt", 3)
	pruefe("Stand", Auftraege.stand(z, Auftraege.von("pelts")), 3)
	pruefe("noch nicht abzugeben", Auftraege.abgabe(z, "thessa"), [])
	z.dazu("wolf_pelt", 4)
	var c := Auftraege.abgabe(z, "thessa")
	pruefe("Abgabe", c.map(func(x): return x["art"]), ["sagen", "sagen", "nehmen", "flagge", "gold"])
	pruefe("Abgabe Werte", [c[2]["ding"], c[2]["anzahl"], c[3]["flagge"], c[4]["anzahl"]], ["wolf_pelt", 5, "job_pelts_done", 60])
	pruefe("Dank wortgleich", Sprache.t(c[1]["text"]), "Fünf. Gut. Die Felle riechen noch nach Blut – das wäscht sich aus. Hier, dein Lohn.")
	pruefe("andere nicht", Auftraege.abgabe(z, "borin"), [])
	# Menue Chronik zeigt den Auftrag mit Stand
	var hw := Heldwerte.erschaffe("Mira", "ELF", "WIZARD", {}, z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.reiter = "chronik"; m.baue()
	await process_frame
	var t := " | ".join(PackedStringArray(m.find_children("*", "Label", true, false).map(func(l): return l.text)))
	for soll in ["Nebenaufträge", "Felle für den Winter", "von Thessa", "Bereit zur Abgabe – bei Thessa", "Lohn: 60 Gold"]:
		if not t.contains(soll): fehler += 1; print("FALSCH Chronik ohne ", soll)
	m.free()
	# Karte: das gelesene Brett vor der Schenke, Thessa als Auftraggeberin (kennt der Held sie)
	z.setze("met_thessa")
	var kr := Kartenreiter.new(z, {"karte": "village", "x": 4, "y": 8, "blick": "UP"}, 800.0, func(): pass)
	var marken := kr.zeichen()
	var brett_m := marken.filter(func(x): return x["art"] == "BOARD")
	var geber_m := marken.filter(func(x): return x["art"] == "GIVER" and x.get("wer", "") == "thessa")
	pruefe("Karte Brett", brett_m.map(func(x): return [x["x"], x["y"], x["text"]["de"]]), [[4, 7, "Anschlagbrett: ein neuer Aushang"]])
	pruefe("Karte Thessa", [geber_m.size(), String(geber_m[0]["text"]["de"]).begins_with("Thessa: Felle für den Winter") if geber_m.size() > 0 else false], [1, true])
	kr.free()
	# das Spiel: Brett, Annehmen, Abgabe ausfuehren, Jorins Kopfschutz
	var spiel = load("res://skripte/spiel.gd").new()
	var ui := Steuerung.new()
	root.add_child(ui)
	await process_frame
	var k := Karte.lade("village")
	var h := Held.new(k)
	h.setze(Vector2i(4, 8), "UP")
	spiel.ui = ui; spiel.zustand = z; spiel.werte = hw; spiel.karte = k; spiel.held = h
	pruefe("Brett vor dem Helden", [spiel.brett(Vector2i(4, 7)), spiel.vor_ihm(Vector2i(4, 8)), spiel.angebot(Vector2i(4, 8))[0]], [true, Vector2i(4, 7), "READ"])
	spiel.oeffne_brett()
	pruefe("Brett offen", [spiel.brett_offen, ui.waehlt()], [true, true])
	var knoepfe: Array = ui.wahl_box.get_children().filter(func(b): return b is Button).map(func(b): return b.text)
	pruefe("Knoepfe", knoepfe.slice(0, 2), ["Angenommen", "Annehmen"])
	spiel._brett_wahl("nimm:stones")
	pruefe("Jorin angenommen", Auftraege.angenommen(z, Auftraege.von("stones")), true)
	spiel._brett_wahl("")
	pruefe("Brett zu", [spiel.brett_offen, ui.waehlt()], [false, false])
	var vorher := z.beutel.size()
	var n: String = spiel.gear_gabe("@gear:UNCOMMON:HEAD")
	var g: Dictionary = z.beutel[z.beutel.size() - 1]
	pruefe("Kopfschutz", [z.beutel.size() - vorher, String(Beute.grundform(String(g["base"]))["slot"]), Beute.stufe_von(String(g["rarity"])) >= Beute.stufe_von("UNCOMMON")], [1, "HEAD", true])
	print("Gabe: ", n)
	spiel.szene = []
	var gold := z.gold
	spiel.spiele(c)
	for i in 12:   # spiel liegt nicht im Baum: „gelesen“ ist nicht verbunden, darum weiter() von Hand
		if ui.spricht(): ui.naechste()
		if not ui.spricht(): spiel.weiter()
	pruefe("nach der Abgabe", [z.anzahl("wolf_pelt"), z.gold - gold, Auftraege.erledigt(z, Auftraege.von("pelts")), ids(Auftraege.am_brett(z)).has("pelts")], [2, 60, true, false])
	h.free(); spiel.free(); ui.free()
	# 399.1 Ruf (Hail.kt): nur wer bekannt ist und Neues hat; Abgabe bereit zaehlt; gehoert nach dem Gespraech
	var y := Zustand.new()
	pruefe("Ruf unbekannt", Ruf.neu(y, "jorin"), false)
	y.setze("met_jorin")
	pruefe("Ruf alter Stand", Ruf.neu(y, "jorin"), false)
	Ruf.gehoert(y, "jorin", false)
	Ruf.gehoert(y, "jorin", true)
	pruefe("Ruf gehoert", Ruf.neu(y, "jorin"), false)
	y.setze(Geschichte.QUEST_STARTED)
	pruefe("Ruf neu nach dem Auftrag", Ruf.neu(y, "jorin"), true)
	y.setze("met_thessa")
	Ruf.gehoert(y, "thessa", true)
	Auftraege.nimm(y, Auftraege.von("pelts"))
	pruefe("Ruf ohne Felle", Ruf.neu(y, "thessa"), false)
	y.dazu("wolf_pelt", 5)
	pruefe("Ruf Abgabe", Ruf.neu(y, "thessa"), true)
	pruefe("Ruf Zeiten", [Ruf.zeigt(0), Ruf.zeigt(1500), Ruf.zeigt(3300), Ruf.zeigt(4700)], [true, false, true, false])
	# 134.3 Ruf ohne Worte (Hail.voice, callVolume); leute.json wie im Bau
	if FileAccess.file_exists(Ruf.LEUTE):
		pruefe("Ruf Stimmen", ["pim", "thessa", "aldric", "borin", "wache"].map(Ruf.stimme), ["hail_child", "hail_woman", "hail_man", "hail_man", ""])
	else: print("ohne daten/leute/leute.json: Stimmen nicht geprueft")
	pruefe("Ruf Pegel", [1, 3, 5, 9].map(func(d): return snappedf(Ruf.pegel(d), 0.01)), [0.6, 0.45, 0.3, 0.3])
	var hr := Heldwerte.erschaffe("A", "HUMAN", "ROGUE")
	hr.basis["DEX"] = 10
	var r10 := Ruf.reichweite(hr)
	hr.basis["DEX"] = 18
	pruefe("Ruf Reichweite", [r10, Ruf.reichweite(hr)], [4, 2])
	var rund := Zustand.aus_daten(JSON.parse_string(JSON.stringify(y.als_daten())))
	pruefe("Ruf gespeichert", rund.gehoert, y.gehoert)
	var lp := Leute.new(Karte.lade("village"), {"id": "probe", "x": 20, "y": 13}, null)
	lp.rufe(true)
	pruefe("Ruf Zeichen", [lp.ruf_zeichen != null and lp.ruf_zeichen.visible, lp.ruf_zeichen.text, is_equal_approx(lp.ruf_zeichen.position.y, 1.75 + 0.35)], [true, "!", true])
	lp.rufe(false)
	pruefe("Ruf aus", lp.ruf_zeichen.visible, false)
	lp.free()
	print("BRETT %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
