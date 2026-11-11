class_name Rast
extends RefCounted
# 390 (Rast, Resting.kt und Game.rest/drinkMead/Cmd.Rest): eine Rast kostet Zeit. Am Lagerfeuer „Rasten?“: 870.4 (DESIGN-BRS.md 12)
# Kurze Erholung 2 Stunden (Ausdauer voll, ein Viertel des Lebens zurueck), Langes Ausruhen 9 Stunden (Leben, Mana, Ausdauer voll,
# Zustaende geheilt), lang nur einmal je Spieltag. In der Schenke Met (der fuenfte macht betrunken bis zur naechsten Rast) und ein Zimmer fuer Gold (lange Rast).
# Jede Rast beendet Ausdauertrank, Funken und Met. Texte aus texte.json „rast“ (TextExport.rast), Gegenprobe tests/rast_test.gd.

const KURZ_MIN := 2 * 60   # 870.4: Kurze Erholung
const LANG_MIN := 9 * 60   # 870.4: Langes Ausruhen
const BETRUNKEN := 5
const MET_PREIS := 2
const ZIMMER_PREIS := 5
const START := {"karte": "inn", "x": 8, "y": 2, "blick": "DOWN"}   # Story.START: in der Schenke rechts oben (604: kein Bett mehr unten)

# Game.interact, Texte dort ohne eigenen Namen (Game.kt Tile.CAMPFIRE, Tile.BED)
const FEUER_HOEHLE := {"de": "Das Feuer der Goblins. Es ist viel zu gefährlich, hier in der Höhle zu rasten.", "en": "The goblins' fire. It is far too dangerous to rest here in the cave."}
const FREMDES_BETT := {"de": "Ein weiches Bett.", "en": "A soft bed."}

# Was ein Met kostet: nichts, solange Rowena dem Helden von Bornim ausgibt (nach Kapitel 1, bis vom Lager erzaehlt ist)
static func met_preis(z: Zustand) -> int:
	return 0 if z.has(Geschichte.CHAPTER1_DONE) and not z.has(Geschichte.CAMP_TOLD) else MET_PREIS

static func lange_erlaubt(z: Zustand) -> bool: return z.lange_rast_tag != z.tag
static func kurz_heilung(hw: BrsHeld) -> int: return (hw.max_leben() + 3) / 4

# die Uhr weiter, Tag fuer Tag
static func vergeht(z: Zustand, minuten: int) -> void:
	var m := z.minuten + minuten
	while m >= 24 * 60:
		m -= 24 * 60
		z.tag += 1
	z.minuten = m

static func ausdauer_voll(z: Zustand) -> void:
	z.ausdauer = 1.0
	z.atemlos = false

# was jede Rast beendet
static func endet(z: Zustand) -> void:
	ausdauer_voll(z)
	z.ausdauer_trank = false
	z.funke = false
	z.met = 0

# Game.rest: art "kurz"/"lang", ort "feuer"/"schenke"/"zimmer"; ort_jetzt = wo der Held steht ({karte, x, y, blick}).
# Zurueck {"nein": Text} oder {"zeilen": [Text …], "klang": [..], "ort": neuer Platz oder {}}. Wer aufruft, blendet ab und auf,
# stellt die Leute und das Licht auf die neue Stunde (Game: sunCut, walkers.clear, mapChanged) und zeigt die Zeilen.
static func rasten(z: Zustand, hw: BrsHeld, art: String, ort: String, ort_jetzt: Dictionary) -> Dictionary:
	if art == "lang" and not lange_erlaubt(z): return {"nein": Sprache.r("longDone")}
	if ort != "feuer" and art == "kurz": return {}
	if ort != "feuer" and z.gold < ZIMMER_PREIS: return {"nein": Sprache.r("noGold")}
	var klang: Array = []
	if ort != "feuer":
		z.gold -= ZIMMER_PREIS
		klang.append("muenzen")
	klang.append("heilen")
	vergeht(z, LANG_MIN if art == "lang" else KURZ_MIN)
	var funkte := z.funke
	endet(z)
	var zeilen: Array = []
	if art == "lang":
		hw.voll()
		z.leiden.clear()
		z.lange_rast_tag = z.tag
		zeilen.append(Sprache.r("longRested" if ort == "feuer" else "roomRested"))   # 604: das Zimmer liegt oben
	else:
		var vorher := hw.leben
		hw.leben = mini(hw.max_leben(), hw.leben + kurz_heilung(hw))
		zeilen.append(Sprache.r("shortRested", [hw.leben - vorher]))
	if funkte: zeilen.append(Sprache.r("sparkFaded"))
	# 114: ein Zimmer an Rowenas Theke gebucht: der Held wacht am Startplatz auf, nicht an der Theke (604: unten kein Bett)
	var neu := ort_jetzt.duplicate()
	if ort == "schenke" and String(ort_jetzt.get("karte", "")) == String(START["karte"]): neu = START.duplicate()
	z.wiederkehr = neu.duplicate()
	if ort == "feuer":
		var fleisch := z.anzahl("raw_meat")
		if fleisch > 0:   # rohes Fleisch kommt aufs Feuer, waehrend der Held rastet
			z.weg("raw_meat", fleisch)
			z.dazu("roast_meat", fleisch)
			zeilen.append(Sprache.r("roasted", [fleisch]))
			for i in fleisch: z.uebe("Kochen")   # 966 A (Vorentscheid Sokrates 11.11.): jedes Stück am Feuer uebt Kochen
			var auf := z.fert_notiz()
			if auf != "": zeilen.append(auf)
	return {"zeilen": zeilen, "klang": klang, "ort": neu if neu != ort_jetzt else {}}

# Game.drinkMead: Ausdauer voll; der fuenfte macht betrunken; betrunken schenkt Rowena nicht mehr nach
static func met_trinken(z: Zustand, name: String) -> String:
	if z.betrunken(): return rowena_sagt(z, name, false)
	var preis := met_preis(z)
	if z.gold < preis: return Sprache.r("noGold")
	z.gold -= preis
	ausdauer_voll(z)
	z.met += 1
	return Sprache.r("drunkNow") if z.betrunken() else Sprache.r("meadDrunk")

# 525 (Game.sellMeat, 139): Rowena kauft an der Theke alles rohe Fleisch zum Preis von Thessa und Morwen; null, wenn keins da
static func fleisch_preis(z: Zustand, hw: BrsHeld) -> int: return z.anzahl("raw_meat") * Laden.verkaufspreis(hw, "raw_meat")

static func fleisch_verkaufen(z: Zustand, hw: BrsHeld) -> String:
	var n := z.anzahl("raw_meat")
	if n < 1: return ""
	Laden.new().verkaufe(z, hw, "raw_meat", n)
	return Sprache.r("meatThanks")

# Resting.rowenaSays: was Rowena sagt, wenn die Theke aufgeht; zweites = Zimmer statt Met
static func rowena_sagt(z: Zustand, name: String, zweites: bool) -> String:
	var k := "rowenaEnough" if z.betrunken() else ("rowenaRoom" if zweites else "rowenaMead")
	return Sprache.r(k).replace("{name}", name)

# Cmd.Rest (Tempel, Szene) und Cmd.Heal: ganz geheilt, Zustaende weg, Ausdauer voll; Rest setzt dazu den Wiederkehrort
static func heilen(z: Zustand, hw: BrsHeld, ort_jetzt: Dictionary = {}) -> void:
	hw.voll()
	z.leiden.clear()
	ausdauer_voll(z)
	if not ort_jetzt.is_empty(): z.wiederkehr = ort_jetzt.duplicate()
