extends SceneTree
# 870.6 (LISTE-UMZUG-BRS.md Schritt 6, DESIGN-BRS.md 11, 870a 6 A): Gegenstände und Beute nach dem BRS, ohne Grafik.
# Geprüft: kein „plus“, Güte 0 bis 2; Zusatzeigenschaften nur aus der Liste des Regelwerks mit dem Wert der Regelwerte; kein Name, keine
# Listenzeile, keine Zusatzeigenschaft nennt einen Altwert oder Würfel; Decken in Kapitel 1 (Seltenheit, Güte); Beute folgt den
# Fertigkeiten; Wirkung am Helden (Leben, Mana, kritisch, Schutzwert, Güte im Schaden) und im Kampfblatt; Händler verkaufen Güte Normal;
# Preis wächst mit der Güte.
# Aufruf: im Ordner godot mit -s res://tests/gegenstaende_870.gd -> „GEGENSTAENDE870 n Fehler“ (Exit 0 = richtig)

const BrsKampf = preload("res://regeln/brs_kampf.gd")

var fehler := 0

func _initialize() -> void:
	Sprache.lade()
	_funde()
	_kapitel1()
	_gewichtung()
	_wirkung()
	_laden_preis()
	_einzelstuecke()
	print("GEGENSTAENDE870 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		print("FALSCH " + was)
		fehler += 1

## Altwerte und Würfel, die kein Gegenstandstext mehr nennen darf (DESIGN-BRS.md 12, STORY-BRS-HELD.md)
const ALT := ["Rüstungsklasse", "Trefferpunkte", "Zauberpunkte", "Zauberkraft", "Stärke", "Konstitution", "Geschicklichkeit",
	"Intelligenz", "Weisheit", "Charisma", "Standhaftigkeit", "Lebensraub", "Schadensreduktion", "Hieb", "gleißend", "Kritischer Bereich",
	"Armor Class", "Hit points", "Spell points", "Spell power", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma", "Tenacity",
	"Life steal", "slashing", "piercing", "bludgeoning", " RK", "ZP"]
static func alt_in(t: String) -> String:
	for w in ALT:
		if t.contains(w): return w
	var r := RegEx.create_from_string("\\d+[Wd]\\d+")
	return "Würfel" if r.search(t) != null else ""

func _funde() -> void:
	var w := KotlinZufall.new(870)
	var zusatz: Dictionary = BrsHeld.lade()["gegenstaende"]["zusatz"]
	var n := 0
	for i in 1500:
		var stufe := 1 + i % 9
		var r: String = Beute.SELTENHEIT[i % 6]
		var g := Beute.erzeuge(w, i, stufe, r, null, "", i % 2 == 0)
		n += 1
		pruefe(not g.has("plus"), "Fund %d hat noch „plus“" % i)
		pruefe(int(g["guete"]) >= 0 and int(g["guete"]) <= 2, "Fund %d Güte %s" % [i, g["guete"]])
		pruefe((g["rolls"] as Array).size() == mini(Beute.zusatzzahl(r), Beute.zusatz_fuer(String(g["base"]), r).size()), "Fund %d: %d Zusatzeigenschaften bei %s" % [i, g["rolls"].size(), r])
		for ro in g["rolls"]:
			var a := String(ro[0])
			pruefe(zusatz.has(a), "Fund %d: Zusatzeigenschaft %s nicht in der Liste" % [i, a])
			pruefe(int(ro[1]) == Beute.zusatz_wert(a, stufe), "Fund %d: %s %d statt %d" % [i, a, int(ro[1]), Beute.zusatz_wert(a, stufe)])
			if a == "SKILL": pruefe(Beute.stufe_von(r) >= Beute.stufe_von("EPIC") and (ro as Array).size() == 3, "Fertigkeit +n nur ab episch, mit Fertigkeit")
			for sp in ["de", "en"]:
				var x := alt_in(Beute.zusatz_text(ro, sp))
				pruefe(x == "", "Zusatzeigenschaft „%s“ nennt %s" % [Beute.zusatz_text(ro, sp), x])
		for sp in ["de", "en"]:
			for t in [Beute.name(g, sp), Beute.listen_zeile(g, sp), Beute.kennwert(g, sp)]:
				var x := alt_in(String(t))
				pruefe(x == "", "„%s“ nennt %s" % [t, x])
	pruefe(n == 1500, "alle Funde erzeugt")
	# Zusatzeigenschaften im Wortlaut (STORY-BRS-HELD.md)
	pruefe(Beute.zusatz_text(["CRIT", 3], "de") == "+3 % kritisch", "kritisch: %s" % Beute.zusatz_text(["CRIT", 3], "de"))
	pruefe(Beute.zusatz_text(["SPELL", 10], "en") == "+10% spell damage", "spell damage: %s" % Beute.zusatz_text(["SPELL", 10], "en"))
	pruefe(Beute.zusatz_text(["TENACITY", 5], "de") == "+5 % Abwehrprobe", "Abwehrprobe: %s" % Beute.zusatz_text(["TENACITY", 5], "de"))
	pruefe(Beute.zusatz_text(["STR", 1], "de") == "+1 Kraft", "Kraft: %s" % Beute.zusatz_text(["STR", 1], "de"))
	pruefe(Beute.zusatz_text(["HP", 5], "de") == "+5 Leben", "Leben: %s" % Beute.zusatz_text(["HP", 5], "de"))
	# Anzeige ohne Würfel: Schaden als Zahl mit Schadensart, Güte in der Listenzeile
	var schwert := {"uid": 1, "base": "longsword", "rarity": "COMMON", "ilvl": 1, "guete": 2, "rolls": [], "unique": null, "name_seed": 0}
	pruefe(Beute.kennwert(schwert, "de") == "Schaden 8 · Schnitt", "Kennwert meisterhaftes Langschwert: %s" % Beute.kennwert(schwert, "de"))
	pruefe(Beute.listen_zeile(schwert, "de").contains("Meisterhaft"), "Listenzeile nennt die Güte: %s" % Beute.listen_zeile(schwert, "de"))

func _held(stufe := 1) -> BrsHeld:
	var h := BrsHeld.fuer_spiel("Probe", "Mensch", "Wachsoldat")
	h.stufe = stufe
	h.voll()
	return h

func _kapitel1() -> void:
	var w := KotlinZufall.new(1)
	var neu := func() -> int: return 0
	var h1 := _held(1)
	var h3 := _held(3)
	var sel := {}
	var guete_hoch := 0
	var boss_hoch := 0
	for i in 3000:
		for g in Beute.beute(h1, w, 1, false, false, neu): pruefe(String(g["rarity"]) == "COMMON", "Kapitel 1, Stufe 1: nur gewöhnlich (%s)" % g["rarity"])
		for g in Beute.beute(h3, w, 3, false, false, neu):
			sel[String(g["rarity"])] = true
			if int(g["guete"]) > 1: guete_hoch += 1
		for g in Beute.beute(h3, w, 3, true, false, neu):
			if Beute.stufe_von(String(g["rarity"])) > Beute.stufe_von("RARE"): boss_hoch += 1
	pruefe(sel.keys().all(func(r): return r in ["COMMON", "UNCOMMON"]) and sel.has("UNCOMMON"), "Kapitel 1 Beute höchstens ungewöhnlich: %s" % [sel.keys()])
	pruefe(guete_hoch == 0, "Kapitel 1 gewöhnliche Beute höchstens Gut (%d meisterhaft)" % guete_hoch)
	pruefe(boss_hoch == 0, "Kapitel 1 Boss höchstens selten (%d darüber)" % boss_hoch)

func _gewichtung() -> void:
	var ohne := _held()
	ohne.geuebt = {}
	ohne.herkunft = "Wanderer"; ohne.wahl = []
	var mit := _held()
	mit.geuebt = {"Bogen": 60}
	var zaehle := func(h) -> int:
		var w := KotlinZufall.new(77)
		var n := 0
		for i in 4000:
			if BrsHeld.fertigkeit_von(String(Beute.erzeuge(w, 0, 3, "COMMON", h)["base"])) == "Bogen": n += 1
		return n
	var a: int = zaehle.call(ohne)
	var b: int = zaehle.call(mit)
	pruefe(b > a * 2, "Bogenschütze findet öfter Bögen (%d gegen %d)" % [b, a])
	pruefe(a > 0, "ohne Bogen gibt es trotzdem Bögen (kein Filter): %d" % a)

func _wirkung() -> void:
	var h := _held()
	var leben := h.max_leben(); var mana := h.max_mana(); var krit := h.krit_prozent(); var schutz := h.schutzwert(); var schaden := h.schaden()
	h.anlegen({"uid": 91, "base": "amulet", "rarity": "RARE", "ilvl": 1, "guete": 0, "rolls": [["HP", 5], ["SP", 5]], "unique": null, "name_seed": 0})
	h.anlegen({"uid": 92, "base": "ring", "rarity": "RARE", "ilvl": 1, "guete": 0, "rolls": [["CRIT", 3], ["SPELL", 10]], "unique": null, "name_seed": 0})
	h.anlegen({"uid": 93, "base": "cloak", "rarity": "RARE", "ilvl": 4, "guete": 0, "rolls": [["AC", 2], ["TENACITY", 5]], "unique": null, "name_seed": 0})
	pruefe(h.max_leben() == leben + 5, "Leben +5: %d statt %d" % [h.max_leben(), leben + 5])
	pruefe(h.max_mana() == mana + 5, "Mana +5: %d statt %d" % [h.max_mana(), mana + 5])
	pruefe(h.krit_prozent() == krit + 3, "kritisch +3: %d statt %d" % [h.krit_prozent(), krit + 3])
	pruefe(h.schutzwert() == mini(schutz + 2, schutz + h.deckel("AC")), "Schutzwert +2 (Deckel %d): %d statt %d" % [h.deckel("AC"), h.schutzwert(), schutz + 2])
	pruefe(h.zauber_prozent() == 10 and h.abwehr_prozent() == 5, "Zauberschaden 10, Abwehrprobe 5: %d, %d" % [h.zauber_prozent(), h.abwehr_prozent()])
	var waffe = h.waffe()
	if waffe != null:
		waffe["guete"] = 2
		pruefe(h.schaden() > schaden, "meisterhafte Waffe trifft härter: %d gegen %d" % [h.schaden(), schaden])
	var kb := h.mein_kampfblatt()
	pruefe(int(kb["zusatz"]["krit"]) == 3 and int(kb["zusatz"]["zauber"]) == 10 and int(kb["zusatz"]["abwehr"]) == 5, "Kampfblatt mit Zusatz: %s" % [kb["zusatz"]])
	pruefe(int(kb["leben"]) == h.max_leben() and int(kb["mana"]) == h.max_mana(), "Kampfblatt Leben, Mana mit Ausrüstung")
	var b := BrsKampf.aus_blatt(kb)
	pruefe(is_equal_approx(float(b["waffe_faktor"]), 1.3) if waffe != null else true, "Güte Meisterhaft als Faktor 1,3: %s" % b.get("waffe_faktor"))
	var ohne := b.duplicate(true); ohne["zusatz"] = {}
	pruefe(is_equal_approx(BrsKampf.held_abzug(b, true) - BrsKampf.held_abzug(ohne, true), float(kb["zusatz"]["schutz"])), "Schutzwert der Zusatzeigenschaften im Abzug des Kampfs")
	# Fertigkeit +n (ab episch) im Kampfblatt
	h.anlegen({"uid": 94, "base": "helmet", "rarity": "EPIC", "ilvl": 6, "guete": 0, "rolls": [["SKILL", 2, "Einhänder"]], "unique": null, "name_seed": 0})
	pruefe(int(h.mein_kampfblatt()["fert"].get("Einhänder", 0)) == h.fertigkeit("Einhänder") + 2, "Fertigkeit +2 im Kampfblatt")

func _laden_preis() -> void:
	var h := _held(3)
	for g in Beute.ladenware(h, 8): pruefe(int(g.get("guete", 0)) == 0, "Händler verkauft Güte Normal: %s" % Beute.name(g))
	var g0 := {"uid": 1, "base": "longsword", "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null}
	var g2 := g0.duplicate(); g2["guete"] = 2
	pruefe(Beute.preis(g2) > Beute.preis(g0), "Meisterhaft teurer: %d gegen %d" % [Beute.preis(g2), Beute.preis(g0)])

func _einzelstuecke() -> void:
	var zusatz: Dictionary = BrsHeld.lade()["gegenstaende"]["zusatz"]
	var es: Dictionary = BrsHeld.lade()["gegenstaende"]["einzelstuecke"]
	for id in es:
		var g := Beute.einzel(String(id), 1, 4)
		var k := Katalog.eintrag(String(id))
		pruefe(not k.is_empty() and String(k.get("grundform", "")) == String(g["base"]), "Einzelstück %s: im Katalog mit derselben Grundform" % id)
		pruefe(Beute.name(g, "de") == String(k.get("name", {}).get("de", "")), "Einzelstück %s heißt wie im Katalog: %s" % [id, Beute.name(g, "de")])
		for ro in g["rolls"]: pruefe(zusatz.has(String(ro[0])), "Einzelstück %s: %s nicht in der Liste" % [id, ro[0]])
		for sp in ["de", "en"]:
			var x := alt_in(Beute.listen_zeile(g, sp))
			pruefe(x == "", "Einzelstück %s nennt %s" % [id, x])
	pruefe(Beute.name(Beute.einzel("gauntlets_ogre", 1, 4), "de") == "Kroggs Pranken", "Kroggs Pranken (870.15)")
	pruefe(Beute.name(Beute.einzel("cloak_protection", 1, 4), "en") == "Bulwark Cloak", "Wehrmantel englisch (870.15)")
	pruefe(BrsHeld.fertigkeit_von(String(Beute.einzel("rapier_whisper", 1, 4)["base"])) == "Dolche", "Flüsterklinge ist ein Dolch (870.14)")
	pruefe(int(Beute.einzel("greataxe_grak", 1, 6)["guete"]) == 2, "Graks Kriegsaxt meisterhaft (870a 6)")
	var anker := {"uid": 1, "base": "cloak", "rarity": "UNCOMMON", "ilvl": 1, "guete": 0, "rolls": [["TENACITY", 5]], "unique": null, "name_seed": 1}
	pruefe(Beute.name(anker, "de") == "Wehrhafter Umhang" and Beute.name(anker, "en") == "Defiant Cloak", "Abwehrprobe heißt nach Homer 925: %s / %s" % [Beute.name(anker, "de"), Beute.name(anker, "en")])
