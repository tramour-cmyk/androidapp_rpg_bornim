class_name Laden
extends RefCounted
# 390 (Laden, Game.kt buy/sell/buyBack/brew, Story.shopStock, Recipes): Thessas Kramladen und Morwens Kraeuterhuette fuer Dinge
# (Traenke, Wurfzeug, Zutaten). 870.4: Preise nach der Fertigkeit Handeln (werte.json „welt“, statt Charisma nach regeln/talente.gd):
# kaufen voller Preis, verkaufen der halbe.
# Die letzten fuenf Verkaeufe eines Besuchs lassen sich zum erzielten Preis zurueckkaufen (59.4), nicht gespeichert.
# Ausruestung (Game.shopGear/buyGear/sellGear/sellAllCommon): Thessas Ware aus skripte/beute.gd, gewuerfelt wie im alten Spiel.
# Daten aus texte.json (TextExport: dinge, rezepte, laden) und held.json; Preise nur aus dem Gegenstandskatalog (458.2, katalog.gd),
# Einzelstuecke unverkaeuflich (458.2a). Gegenprobe: tests/laden_test.gd, tests/beute_golden.gd, tests/katalog_test.gd.

# 870.4 (LISTE-UMZUG-BRS.md Schritt 4): was frueher Charisma, Intelligenz, Weisheit, Konstitution taten (regeln/talente.gd, Perks.kt),
# tun Fertigkeiten und Grundwerte nach dem BRS; Zahlen aus werte.json „welt“
static func _wl() -> Dictionary: return BrsHeld.welt()
static func kauf_faktor(hw: BrsHeld) -> float: return 1.0 - float(_wl().get("handeln_je_punkt", 0.002)) * hw.fertigkeit("Handeln")
static func verkauf_faktor(hw: BrsHeld) -> float: return 1.0 + float(_wl().get("handeln_je_punkt", 0.002)) * hw.fertigkeit("Handeln")
static func buy_price(hw: BrsHeld, base: int) -> int: return maxi(1, roundi(base * kauf_faktor(hw)))
static func sell_price(hw: BrsHeld, base: int) -> int: return maxi(1, roundi(base * verkauf_faktor(hw)))
## Chance auf einen Trank mehr bei Morwens Sud (Alchemie)
static func brau_chance(hw: BrsHeld) -> float: return float(_wl().get("brauen_je_alchemie", 0.01)) * hw.fertigkeit("Alchemie")
## Chance auf ein Kraut mehr beim Pfluecken (Kraeuterkunde und Wahrnehmung)
static func kraut_chance(hw: BrsHeld) -> float:
	var wl := _wl()
	return float(wl.get("kraut_je_kraeuterkunde", 0.01)) * hw.fertigkeit("Kräuterkunde") \
		+ float(wl.get("kraut_je_wahrnehmung", 0.05)) * maxi(0, hw.wert("wahrnehmung") - int(wl.get("kraut_wahrnehmung_ab", 3)))
## Leben dazu aus einer Mahlzeit (Kochen)
static func essen_bonus(hw: BrsHeld) -> int: return roundi(float(_wl().get("essen_je_kochen", 0.2)) * hw.fertigkeit("Kochen"))
# Ueberschriften wie ShopScreen.kt (dort ohne eigenen Namen)
const VORRAETE := {"de": "Vorräte", "en": "Supplies"}
const HUETTE := {"de": "Morwens Hütte", "en": "Morwen's hut"}
const REZEPTE := {"de": "Morwens Rezepte", "en": "Morwen's recipes"}
const KRAEUTER := {"de": "Kräuter wachsen auf Blumenwiesen im Wald – einfach darüberlaufen.", "en": "Herbs grow in the forest's flower meadows – just walk over them."}
const ZURUECK := {"de": "Zurückkaufen", "en": "Buy back"}
const RUECKKAUF := 5
const AUSRUESTUNG := {"de": "Ausrüstung", "en": "Equipment"}
const NICHT_TRAGBAR := {"de": "Nicht tragbar", "en": "Can't wear"}
const NEUE_WARE := {"de": "Neue Ware nach jeweils 8 Siegen.", "en": "New stock every 8 victories."}
const GEWOEHNLICHE := {"de": "Gewöhnliche verkaufen", "en": "Sell common items"}
const MENGE := {"de": "Menge", "en": "Quantity"}
const BESITZ := {"de": "Im Besitz: ", "en": "Owned: "}
const ALLE := {"de": "Alle", "en": "All"}
const GEWOEHNLICHE_WEG := {"de": "%d gewöhnliche Gegenstände verkauft.", "en": "Sold %d common items."}
# 699: „1 Gegenstand:“ statt „1 Gegenstände:“ (Rueckfrage „Alle gewöhnlichen verkaufen?“; alt ShopScreen.kt 273 ohne Einzahl)
static func anzahl_gegenstaende(n: int, de: bool) -> String:
	if de: return "%d Gegenstand:" % n if n == 1 else "%d Gegenstände:" % n
	return "%d item:" % n if n == 1 else "%d items:" % n
# 525 (Sokrates 04.11.): Einzahl „1 gewöhnlicher Gegenstand verkauft“
const GEWOEHNLICHER_WEG := {"de": "1 gewöhnlicher Gegenstand verkauft.", "en": "Sold 1 common item."}
# 525 Brauen: was fehlt, wie oft es reicht
const FEHLT := {"de": "Fehlt: ", "en": "Missing: "}
const REICHT := {"de": "Reicht für %d×", "en": "Enough for %d×"}

static func gewoehnliche_text(n: int) -> String:
	return Sprache.t(GEWOEHNLICHER_WEG) if n == 1 else Sprache.t(GEWOEHNLICHE_WEG) % n

var waren: Array = []                  # Kennungen der Dinge im Angebot (Story.shopStock, HERBALIST_STOCK)
var brauen := false                    # Morwen braut (Mode.Shop.brewing)
var rueckkauf: Array = []              # {ding, anzahl, preis}, neueste zuerst (Game.buyback)

func _init(waren_: Array = [], brauen_: bool = false) -> void:
	waren = waren_.duplicate()
	brauen = brauen_

static func ding(id: String) -> Dictionary:
	Sprache.lade()
	return Sprache.texte.get("dinge", {}).get(id, {})

static func name(id: String) -> String: return Sprache.t(ding(id).get("name", id))
static func preis(id: String) -> int: return Katalog.preis(id)
static func verkaeuflich(id: String) -> bool: return String(ding(id).get("art", "")) != "KEY" and preis(id) > 0
static func kaufpreis(hw: BrsHeld, id: String) -> int: return buy_price(hw, preis(id))
static func verkaufspreis(hw: BrsHeld, id: String) -> int: return sell_price(hw, preis(id) / 2)
static func kann_kaufen(z: Zustand, hw: BrsHeld, id: String) -> int: return z.gold / kaufpreis(hw, id)

static func mit_anzahl(id: String, n: int) -> String: return name(id) + (" ×%d" % n if n > 1 else "")

# Game.Sold.name: ein Ding mit Anzahl oder ein Stueck Ausruestung
static func verkauft_name(s: Dictionary) -> String:
	return Beute.name(s["ausruestung"]) if s.has("ausruestung") else mit_anzahl(String(s["ding"]), int(s["anzahl"]))

# Game.buy
func kaufe(z: Zustand, hw: BrsHeld, id: String, n: int = 1) -> String:
	var p := kaufpreis(hw, id) * n
	if n < 1: return Sprache.u("nothing")
	if z.gold < p: return Sprache.u("notEnoughGold")
	z.gold -= p
	z.dazu(id, n)
	z.uebe("Handeln")   # 471
	return Sprache.u("bought", [mit_anzahl(id, n)])

# Game.sell: nur Verkaeufliches, nur was er hat
func verkaufe(z: Zustand, hw: BrsHeld, id: String, n: int = 1) -> String:
	if n < 1 or not verkaeuflich(id) or z.anzahl(id) < n: return Sprache.u("cannotSell")
	z.weg(id, n)
	var p := verkaufspreis(hw, id) * n
	z.gold += p
	_verkauft({"ding": id, "anzahl": n, "preis": p})
	z.uebe("Handeln")   # 471
	return Sprache.u("sold", [mit_anzahl(id, n)])

# Game.buyBack: zum erzielten Preis
func zurueck(z: Zustand, i: int) -> String:
	if i < 0 or i >= rueckkauf.size(): return Sprache.u("cannotSell")
	var s: Dictionary = rueckkauf[i]
	if z.gold < int(s["preis"]): return Sprache.u("notEnoughGold")
	z.gold -= int(s["preis"])
	if s.has("ausruestung"): z.beutel.append(s["ausruestung"])
	else: z.dazu(String(s["ding"]), int(s["anzahl"]))
	rueckkauf.remove_at(i)
	return Sprache.u("bought", [verkauft_name(s)])

func _verkauft(s: Dictionary) -> void:
	rueckkauf.push_front(s)
	while rueckkauf.size() > RUECKKAUF: rueckkauf.pop_back()

# ---------------------------------------------------------------- Ausruestung
# Game.shopGear: Thessas Ware ohne das schon Gekaufte; die Fackel geht nie aus (180)
static func ware(z: Zustand, hw: BrsHeld) -> Array:
	var satz := z.siege / 8
	return Beute.ladenware(hw, z.siege).filter(func(g): return String(g["base"]) == "torch" or not z.laden_verkauft.has("%d:%d" % [satz, int(g["uid"])]))

static func kaufpreis_von(hw: BrsHeld, g: Dictionary) -> int: return buy_price(hw, Beute.preis(g))
static func verkaufspreis_von(hw: BrsHeld, g: Dictionary) -> int: return sell_price(hw, maxi(1, Beute.preis(g) / 4))
# 458.2a: Einzelstuecke haben im Katalog Preis 0 und bleiben beim Helden
static func ausruestung_verkaeuflich(g: Dictionary) -> bool: return g.get("unique") == null or Katalog.verkaeuflich(String(g["unique"]))

# Game.buyGear: in die Tasche, mit neuer Kennung
func kaufe_ausruestung(z: Zustand, hw: BrsHeld, g: Dictionary) -> String:
	var p := kaufpreis_von(hw, g)
	if z.gold < p: return Sprache.u("notEnoughGold")
	z.gold -= p
	if String(g["base"]) != "torch": z.laden_verkauft["%d:%d" % [z.siege / 8, int(g["uid"])]] = true
	var neu := g.duplicate(true)
	neu["uid"] = 0
	z.ausruestung_dazu(neu)
	z.uebe("Handeln")   # 471
	return Sprache.u("bought", [Beute.name(g)])

# Game.sellGear: Stueck [i] der Tasche
func verkaufe_ausruestung(z: Zustand, hw: BrsHeld, i: int) -> String:
	if i < 0 or i >= z.beutel.size(): return Sprache.u("cannotSell")
	var g: Dictionary = z.beutel[i]
	if not ausruestung_verkaeuflich(g): return Sprache.u("cannotSell")
	z.beutel.remove_at(i)
	var p := verkaufspreis_von(hw, g)
	z.gold += p
	_verkauft({"ausruestung": g, "anzahl": 1, "preis": p})
	z.uebe("Handeln")   # 471
	return Sprache.u("sold", [Beute.name(g)])

# Game.sellAllCommon: alles Gewoehnliche auf einmal; gibt die Zahl
func verkaufe_gewoehnliches(z: Zustand, hw: BrsHeld) -> int:
	var weg_ := z.beutel.filter(func(g): return String(g["rarity"]) == "COMMON" and ausruestung_verkaeuflich(g))
	for g in weg_:
		z.beutel.erase(g)
		z.gold += verkaufspreis_von(hw, g)
		_verkauft({"ausruestung": g, "anzahl": 1, "preis": verkaufspreis_von(hw, g)})
	if not weg_.is_empty(): z.uebe("Handeln")   # 471: ein Handel
	return weg_.size()

static func rezepte() -> Array:
	Sprache.lade()
	return Sprache.texte.get("rezepte", [])

static func bezahlbar(z: Zustand, r: Dictionary) -> bool:
	if z.gold < int(r["gold"]): return false
	for id in r["zutaten"]:
		if z.anzahl(String(id)) < int(r["zutaten"][id]): return false
	return true

# 525: wie oft das Rezept mit dem, was der Held hat, reicht
static func wie_oft(z: Zustand, r: Dictionary) -> int:
	var n := 1 << 30
	if int(r["gold"]) > 0: n = z.gold / int(r["gold"])
	for id in r["zutaten"]: n = mini(n, z.anzahl(String(id)) / maxi(1, int(r["zutaten"][id])))
	return n

# 525: was fuer einmal Brauen fehlt, „1× Heilkräuter, 3 Gold“; leer, wenn nichts fehlt
static func fehlt(z: Zustand, r: Dictionary) -> String:
	var teile: Array = []
	for id in r["zutaten"]:
		var d := int(r["zutaten"][id]) - z.anzahl(String(id))
		if d > 0: teile.append("%d× %s" % [d, name(String(id))])
	var g := int(r["gold"]) - z.gold
	if g > 0: teile.append(("%d Gold" if Sprache.aktiv() == "de" else "%d gold") % g)
	return ", ".join(teile)

# Recipe.cost: „2× Heilkräuter, 5 Gold“
static func kosten(r: Dictionary) -> String:
	var teile: Array = []
	for id in r["zutaten"]: teile.append("%d× %s" % [int(r["zutaten"][id]), name(String(id))])
	if int(r["gold"]) > 0: teile.append(("%d Gold" if Sprache.aktiv() == "de" else "%d gold") % int(r["gold"]))
	return ", ".join(teile)

# Game.brew: Zutaten und Gold weg, ein Trank; ein kluger Held holt manchmal einen zweiten heraus (Perks.extraBrewChance).
# wurf: Zufallszahl 0..1 (Dice.chance), im Test fest
func braue(z: Zustand, hw: BrsHeld, r: Dictionary, wurf: float = randf()) -> String:
	if not bezahlbar(z, r): return Sprache.l("missing")
	for id in r["zutaten"]: z.weg(String(id), int(r["zutaten"][id]))
	z.gold -= int(r["gold"])
	var aus := String(r["ergebnis"])
	z.dazu(aus)
	if wurf < brau_chance(hw):
		z.dazu(aus)
		return Sprache.l("brewedTwo", [name(aus)])
	return Sprache.l("brewed", [name(aus)])

# 525 (Sokrates 04.11.: „×1, ×5, so viele wie möglich“): n-mal brauen; die Meldung nennt, was herauskam („Morwen braut dir: Heiltrank ×3.“)
func braue_mehr(z: Zustand, hw: BrsHeld, r: Dictionary, n: int, wurf: Callable = func(): return randf()) -> String:
	n = mini(n, wie_oft(z, r))
	if n < 1: return Sprache.l("missing")
	if n == 1: return braue(z, hw, r, float(wurf.call()))
	var aus := String(r["ergebnis"])
	var vorher := z.anzahl(aus)
	for i in n: braue(z, hw, r, float(wurf.call()))
	return Sprache.l("brewed", [mit_anzahl(aus, z.anzahl(aus) - vorher)])
