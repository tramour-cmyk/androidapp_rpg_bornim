extends SceneTree
# 870.6 (LISTE-UMZUG-BRS.md Schritt 6): kein Gegenstand nennt Altwerte. Ohne Bild: viele Zufallsstücke (Beute je Stufe, Boss, Laden)
# tragen nur Zusatzeigenschaften der Liste DESIGN-BRS 11 mit deren Zahlen (werte.json „gegenstaende“), kein „plus“, Güte 0–2, Namen
# und Listenzeilen ohne Würfel; getragen wirken sie: Leben, kritisch, Schutzwert, Abwehrprobe, Zauberschaden im Kampfblatt.
# Aufruf: im Ordner godot mit -s res://tests/gegenstaende_870_6.gd -> „GEGENSTAENDE8706 n Fehler“

const BrsKampf = preload("res://regeln/brs_kampf.gd")
const ERLAUBT := ["STR", "DEX", "CON", "INT", "WIS", "CHA", "AC", "HP", "SP", "CRIT", "SPELL", "ABWEHR"]
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
	if W.is_empty() or BrsHeld.daten().is_empty() or not W.has("gegenstaende"):
		print("GEGENSTAENDE8706 ohne Daten (daten/werte.json mit „gegenstaende“, daten/held.json)")
		quit(1)
		return
	var Z: Dictionary = W["gegenstaende"]["zusatz"]
	var wuerfel := RegEx.create_from_string("\\d+[Wd]\\d+")
	var h := BrsHeld.fuer_spiel("Probe", "Mensch", "Wachsoldat")
	var stuecke: Array = []
	var uid := [0]
	var neu := func() -> int:
		uid[0] += 1
		return uid[0]
	for saat in 400:
		var w := KotlinZufall.new(saat)
		h.stufe = 1 + saat % 10
		h.kapitel = 1 + saat % 5
		stuecke.append_array(Beute.beute(h, w, h.stufe, saat % 7 == 0, saat % 5 == 0, neu))
		for r in Beute.SELTENHEIT:
			stuecke.append(Beute.erzeuge(w, neu.call(), h.stufe, r))
	h.stufe = 3
	h.kapitel = 1
	stuecke.append_array(Beute.ladenware(h, 16))
	var altwerte := 0
	var plus := 0
	var falsch_wert := 0
	var guete_aus := 0
	var mit_wuerfel := 0
	var gesehen := {}
	for g in stuecke:
		if int(g.get("plus", 0)) != 0:
			plus += 1
		if not (int(g.get("guete", -1)) in [0, 1, 2]):
			guete_aus += 1
		for r in g["rolls"]:
			var a := String(r[0])
			gesehen[a] = true
			if not (a in ERLAUBT):
				altwerte += 1
				if altwerte <= 3:
					print("  Altwert %s an %s" % [a, g["base"]])
				continue
			var soll := int(Z[a]["wert"])
			var zwei: bool = a == "AC" and int(r[1]) == soll + 1 and int(g["ilvl"]) >= int(Z["AC"]["zwei_ab_stufe"])
			if int(r[1]) != soll and not zwei:
				falsch_wert += 1
		for sp in ["de", "en"]:
			var t := Beute.name(g, sp) + " · " + Beute.listen_zeile(g, sp) + " · " + Beute.kennwert(g, sp)
			if wuerfel.search(t) != null:
				mit_wuerfel += 1
				if mit_wuerfel <= 3:
					print("  Würfel in „%s“" % t)
	print("%d Stücke, Zusatzeigenschaften gesehen: %s" % [stuecke.size(), ", ".join(gesehen.keys())])
	pruefe("keine Altwerte (Liste DESIGN-BRS 11)", altwerte, 0)
	pruefe("kein „plus“", plus, 0)
	pruefe("Güte 0–2", guete_aus, 0)
	pruefe("Zahlen wie werte.json „zusatz“", falsch_wert, 0)
	pruefe("Namen und Zeilen ohne Würfel", mit_wuerfel, 0)
	pruefe("Güte über Normal kommt vor", stuecke.any(func(g): return int(g.get("guete", 0)) > 0), true)
	# getragen wirkt es
	var p := BrsHeld.fuer_spiel("Ada", "Mensch", "Wachsoldat")
	p.kapitel = 5
	var leben0 := p.max_leben()
	var mana0 := p.max_mana()
	var krit0 := p.krit_prozent()
	var schutz0 := p.schutzwert()
	p.ausruestung["AMULET"] = {"uid": 900, "base": _form("AMULET"), "rarity": "RARE", "ilvl": 3, "plus": 0, "guete": 0,
		"rolls": [["HP", 5], ["ABWEHR", 5]], "unique": null, "name_seed": 0}
	p.ausruestung["RING"] = {"uid": 901, "base": _form("RING"), "rarity": "RARE", "ilvl": 3, "plus": 0, "guete": 0,
		"rolls": [["CRIT", 3], ["SPELL", 10]], "unique": null, "name_seed": 0}
	var brust = p.ding("CHEST")
	var soll_schutz := 0
	if brust != null:
		brust["guete"] = 2
		soll_schutz = 2 * int(W["gegenstaende"]["guete"]["schutz_je_stufe"])
	pruefe("Leben +5", p.max_leben() - leben0, 5)
	pruefe("Mana gleich (kein Mana-Zusatz)", p.max_mana() - mana0, 0)
	pruefe("kritisch +3 %", p.krit_prozent() - krit0, 3)
	pruefe("Schutzwert + Güte Meisterhaft der Brust", p.schutzwert() - schutz0, soll_schutz)
	var b := BrsKampf.aus_blatt(p.mein_kampfblatt())
	pruefe("Kampfblatt: Abwehrprobe, Zauberschaden, kritisch", [int(b.zusatz.abwehr), int(b.zusatz.zauberschaden), int(b.zusatz.krit)], [5, 10, 3])
	pruefe("Kampfblatt: Leben wie in der Welt", int(b.leben), p.max_leben())
	pruefe("Abzug im Kampf = Schutzwert", Brs.runde(BrsKampf.held_abzug(b, true)), p.schutzwert())
	print("GEGENSTAENDE8706 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)

func _form(slot: String) -> String:
	for id in Beute.grundformen():
		if String(Beute.grundform(id)["slot"]) == slot:
			return id
	return ""
