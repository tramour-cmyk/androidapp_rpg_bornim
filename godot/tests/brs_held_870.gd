extends SceneTree
# 870.4 (LISTE-UMZUG-BRS.md Schritt 4): der Held nach BRS ist die einzige Quelle seiner Werte (heldwerte.gd entfaellt). Ohne Bild:
# Startausruestung je Herkunft, Leben, Mana, Schutzwert, Schaden und Kritisch nach den Regelwerten, Leben der Welt gleich dem Leben
# im Kampf, das MARS-Blatt ohne Klasse, Vergleich an einer Abschrift, Spielstand Version 2, Rast nach BRS (2 und 9 Stunden), Trank fest.
# Aufruf: im Ordner godot mit -s res://tests/brs_held_870.gd -> „BRSHELD870 n Fehler“

const AufrufS = preload("res://kampf/aufruf.gd")
const BrsKampf = preload("res://regeln/brs_kampf.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll:
		fehler += 1
		print("FALSCH %s: %s statt %s" % [was, ist, soll])
	else:
		print("ok     %s" % was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	var W := BrsHeld.lade()
	if W.is_empty() or BrsHeld.daten().is_empty():
		print("BRSHELD870 ohne Daten (daten/werte.json, daten/held.json)")
		quit(1)
		return
	var wl: Dictionary = W["welt"]
	var hd: Dictionary = W["held"]
	# Startausruestung je Herkunft aus „welt“ „start“, jede Grundform da, die Waffe in der Gruppe der Herkunft
	for hk in BrsHeld.herkuenfte():
		var h := BrsHeld.fuer_spiel("Probe", "Mensch", hk)
		var soll: Array = wl["start"][hk]
		pruefe("%s: Start %s" % [hk, soll], soll.all(func(id): return h.ausruestung.values().any(func(g): return String(g["base"]) == id)), true)
		pruefe("%s: Waffengruppe wie die Herkunft" % hk, h.waffengruppe(), String(W["herkuenfte"][hk]["waffe"]))
		pruefe("%s: Ruestung wie die Herkunft" % hk, h.ruestung(), String(W["herkuenfte"][hk]["ruestung"]))
		pruefe("%s: voll" % hk, [h.leben, h.mana], [h.max_leben(), h.max_mana()])
	# Werte nach den Regelwerten
	var w := BrsHeld.fuer_spiel("Ada", "Zwerg", "Wachsoldat")
	pruefe("Leben", w.max_leben(), int(hd["leben_basis"]) + int(hd["leben_je_stufe"]) + int(hd["leben_je_zaehigkeit"]) * w.wert("zaehigkeit"))
	pruefe("Mana", w.max_mana(), int(hd["mana_basis"]) + int(hd["mana_je_wille"]) * w.wert("wille"))
	var ru: Dictionary = W["ruestungen"]
	var je := float(W["kampf"]["ruestungsfertigkeit_im_abzug_je_punkt"])
	pruefe("Schutzwert (Mittlere Ruestung, Schild)", w.schutzwert(), Brs.runde(float(ru["Mittlere Rüstung"]["wert"]) * (1.0 + 10 * je) + float(ru["schild_wert"]) * (1.0 + 10 * je)))
	pruefe("Schaden Einhaender", w.schaden(), Brs.runde((6.0 + w.wert("kraft")) * (1.0 + 10 * float(W["kampf"]["fertigkeit_im_schaden_je_punkt"]))))
	pruefe("Kritisch (952 D: Gewandtheit × Einhänder / 50)", w.krit_prozent(), roundi(float(W["kampf"]["kritisch_je_punkt"]) * w.wert("gewandtheit") * w.fertigkeit("Einhänder") / float(W["kampf"]["kritisch_fertigkeit_teiler"])))
	pruefe("952 D: Dolch nach Wahrnehmung, Heilmagie nie", [BrsKampf.krit_prozent({"wahrnehmung": 20, "gewandtheit": 5}, "Dolche", 20), BrsKampf.krit_prozent({"wille": 20}, "Heilmagie", 50)], [8.0, 0.0])
	pruefe("952 D: Evokation Schaden aus Verstand", BrsKampf.zauber_grundwert("Evokation"), "verstand")
	pruefe("870d: Schwaechen ab Verstand 6", [BrsHeld.neu("", "Zauberlehrling").kennt_schwaechen(), BrsHeld.neu("", "Wachsoldat").kennt_schwaechen()],
		[BrsHeld.neu("", "Zauberlehrling").wert("verstand") >= 6, BrsHeld.neu("", "Wachsoldat").wert("verstand") >= 6])
	pruefe("jeder darf alles tragen", w.kann_tragen({"uid": 1, "base": "plate", "rarity": "COMMON", "ilvl": 1, "plus": 0, "rolls": []}), true)
	# Zusatzeigenschaft auf einen Grundwert wirkt, im Kapitel gedeckelt (Kapitel 1: +1)
	var zaeh := w.wert("zaehigkeit")
	var leben := w.max_leben()
	w.anlegen({"uid": 9, "base": "ring", "rarity": "RARE", "ilvl": 3, "plus": 0, "rolls": [["CON", 2]], "unique": null})
	pruefe("Ring +2 Zaehigkeit wirkt +1 (Kapitel 1)", [w.wert("zaehigkeit"), w.ausruestung_gedeckelt("zaehigkeit")], [zaeh + 1, true])
	pruefe("Leben mit dem Ring", w.max_leben(), leben + int(hd["leben_je_zaehigkeit"]))
	# Leben der Welt = Leben im Kampf (kein Umrechnen mehr), Blatt ohne Klasse, mit Kampfblatt nach BRS
	var b := AufrufS.blatt(w, AufrufS.ersatzwaffe(w))
	pruefe("Blatt ohne Klasse", b.has("cls"), false)
	pruefe("Blatt Herkunft und Volk der Figur", [b["herkunft"], b["race"]], ["Wachsoldat", "DWARF"])
	pruefe("Kampfblatt Leben = Leben der Welt", int(b["brs"]["leben"]), w.max_leben())
	pruefe("Kampfblatt Werte mit Ausruestung", int(b["brs"]["werte"]["zaehigkeit"]), w.wert("zaehigkeit"))
	pruefe("Mana im Blatt", [int(b["sp"]), int(b["sp_max"])], [w.mana, w.max_mana()])
	pruefe("Kampf: Leben aus der Welt", BrsKampf.leben_held(BrsKampf.held(b)), w.max_leben())
	# Vergleich an einer Abschrift
	var vorher := JSON.stringify(w.spiel_daten())
	var v := Vergleich.von(w, {"uid": 10, "base": "plate", "rarity": "COMMON", "ilvl": 7, "plus": 0, "rolls": [], "unique": null})
	pruefe("Vergleich aendert den Helden nicht", JSON.stringify(w.spiel_daten()), vorher)
	pruefe("Vollplatte: Schutzwert steigt", v.zeilen.any(func(z): return String(z["wort"]) in ["Schutzwert", "Protection"] and int(z["besser"]) == 1), true)
	# Spielstand Version 2
	w.stufe = 4; w.leben = 11; w.mana = 3
	var r := BrsHeld.aus_spiel_daten(JSON.parse_string(JSON.stringify(w.spiel_daten())))
	pruefe("Spielstand", [r.name, r.volk, r.herkunft, r.stufe, r.leben, r.mana, r.ausruestung.size(), r.wert("zaehigkeit")],
		[w.name, w.volk, w.herkunft, 4, 11, 3, w.ausruestung.size(), w.wert("zaehigkeit")])
	pruefe("Spielstand Version", Spielstand.VERSION, 2)
	# Rast nach BRS: Kurze Erholung 2 h, Langes Ausruhen 9 h
	var z := Zustand.new()
	z.gold = 50
	var h := BrsHeld.fuer_spiel("Rast", "Mensch", "Wanderer")
	h.leben = 1
	var m0 := z.minuten
	Rast.rasten(z, h, "kurz", "feuer", {"karte": "forest", "x": 1, "y": 1, "blick": "DOWN"})
	pruefe("Kurze Erholung 2 Stunden, ein Viertel Leben", [z.minuten - m0, h.leben], [120, 1 + (h.max_leben() + 3) / 4])
	m0 = z.minuten
	Rast.rasten(z, h, "lang", "feuer", {"karte": "forest", "x": 1, "y": 1, "blick": "DOWN"})
	pruefe("Langes Ausruhen 9 Stunden, voll", [(z.minuten - m0 + 24 * 60) % (24 * 60), h.leben, h.mana], [540, h.max_leben(), h.max_mana()])
	pruefe("Wort der Rast", Sprache.r("short"), "Kurze Erholung · 2 Stunden" if Sprache.aktiv() == "de" else "Short Respite · 2 hours")
	# Heiltrank fest nach „welt“ „heilung“
	h.leben = 1
	z.dazu("potion", 1)
	Menue.benutze(z, h, "potion", func(a, b_): return 0)
	pruefe("Heiltrank heilt fest", h.leben, mini(h.max_leben(), 1 + int(wl["heilung"]["potion"])))
	# t276.5 (Chef 11.11., „11 statt 14“): fehlt viel, genau 14 und die Meldung nennt 14; fehlen 11, bis voll und die Meldung nennt 11;
	# im Kampf dieselben Zahlen
	var trank := int(wl["heilung"]["potion"])
	for fehlt in [h.max_leben() - 1, 11]:
		h.leben = h.max_leben() - fehlt
		z.dazu("potion", 1)
		var vor := h.leben
		var s := Menue.benutze(z, h, "potion", func(a, b_): return 0)
		pruefe("Heiltrank Welt, fehlen %d" % fehlt, [h.leben - vor, s.contains(" %d " % mini(fehlt, trank)) or s.contains(" %d " % mini(fehlt, trank))], [mini(fehlt, trank), true])
	var tab: Dictionary = Tabellen.lade()     # 870.3: tabellen.json ist weg, die Kampftabellen kommen aus Tabellen (werte.json)
	var skills := {}
	for sk in tab.skills: skills[sk.id] = sk
	var monsters := {}
	for mo in tab.monsters: monsters[mo.id] = mo
	var auf = AufrufS.new()
	for fehlt in [h.max_leben() - 1, 11]:
		h.leben = h.max_leben() - fehlt
		var held = auf._kaempfer("hero", h, -1, Vector2i(Mars.FRONT, 0), skills)
		var mars = Mars.new([held], [AufrufS.rudel(monsters, Wuerfel.new(3))[0]], tab, Wuerfel.new(5), Wuerfel.new(7), 0, false)
		mars.potions["potion"] = 1
		var vor: int = held.hp
		mars._drink(held, "potion", held)
		pruefe("Heiltrank Kampf, fehlen %d" % fehlt, [held.max_hp, held.hp - vor], [h.max_leben(), mini(fehlt, trank)])
	auf.free()
	# Heldenstufe: der Zustand fuehrt sie, Testmenue setzt sie
	Testmodus.stufe_setzen(h, z, 3)
	pruefe("Stufe im Zustand und am Helden", [z.stufe(), h.stufe, h.leben], [3, 3, h.max_leben()])
	print("BRSHELD870 %d Fehler" % fehler)
	quit(1 if fehler else 0)
