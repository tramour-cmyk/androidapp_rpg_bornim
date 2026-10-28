class_name Laden
extends RefCounted
# 390 (Laden, Game.kt buy/sell/buyBack/brew, Story.shopStock, Recipes): Thessas Kramladen und Morwens Kraeuterhuette fuer Dinge
# (Traenke, Wurfzeug, Zutaten). Preise nach Charisma wie Perks (Jerrys regeln/talente.gd): kaufen voller Preis, verkaufen der halbe.
# Die letzten fuenf Verkaeufe eines Besuchs lassen sich zum erzielten Preis zurueckkaufen (59.4), nicht gespeichert.
# Ausruestung (Game.shopGear/buyGear/sellGear/sellAllCommon): Thessas Ware aus skripte/beute.gd, gewuerfelt wie im alten Spiel.
# Daten aus texte.json (TextExport: dinge, rezepte, laden) und held.json. Gegenprobe: tests/laden_test.gd, tests/beute_golden.gd.

const TALENTE := preload("res://regeln/talente.gd")
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
const GEWOEHNLICHE_WEG := {"de": "%d gewöhnliche Gegenstände verkauft.", "en": "Sold %d common items."}

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
static func preis(id: String) -> int: return int(ding(id).get("preis", 0))
static func verkaeuflich(id: String) -> bool: return String(ding(id).get("art", "")) != "KEY" and preis(id) > 0
static func kaufpreis(hw: Heldwerte, id: String) -> int: return TALENTE.buy_price(hw, preis(id))
static func verkaufspreis(hw: Heldwerte, id: String) -> int: return TALENTE.sell_price(hw, preis(id) / 2)
static func kann_kaufen(z: Zustand, hw: Heldwerte, id: String) -> int: return z.gold / kaufpreis(hw, id)

static func mit_anzahl(id: String, n: int) -> String: return name(id) + (" ×%d" % n if n > 1 else "")

# Game.Sold.name: ein Ding mit Anzahl oder ein Stueck Ausruestung
static func verkauft_name(s: Dictionary) -> String:
	return Beute.name(s["ausruestung"]) if s.has("ausruestung") else mit_anzahl(String(s["ding"]), int(s["anzahl"]))

# Game.buy
func kaufe(z: Zustand, hw: Heldwerte, id: String, n: int = 1) -> String:
	var p := kaufpreis(hw, id) * n
	if n < 1: return Sprache.u("nothing")
	if z.gold < p: return Sprache.u("notEnoughGold")
	z.gold -= p
	z.dazu(id, n)
	return Sprache.u("bought", [mit_anzahl(id, n)])

# Game.sell: nur Verkaeufliches, nur was er hat
func verkaufe(z: Zustand, hw: Heldwerte, id: String, n: int = 1) -> String:
	if n < 1 or not verkaeuflich(id) or z.anzahl(id) < n: return Sprache.u("cannotSell")
	z.weg(id, n)
	var p := verkaufspreis(hw, id) * n
	z.gold += p
	_verkauft({"ding": id, "anzahl": n, "preis": p})
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
static func ware(z: Zustand, hw: Heldwerte) -> Array:
	var satz := z.siege / 8
	return Beute.ladenware(hw, z.siege).filter(func(g): return String(g["base"]) == "torch" or not z.laden_verkauft.has("%d:%d" % [satz, int(g["uid"])]))

static func kaufpreis_von(hw: Heldwerte, g: Dictionary) -> int: return TALENTE.buy_price(hw, Beute.preis(g))
static func verkaufspreis_von(hw: Heldwerte, g: Dictionary) -> int: return TALENTE.sell_price(hw, maxi(1, Beute.preis(g) / 4))

# Game.buyGear: in die Tasche, mit neuer Kennung
func kaufe_ausruestung(z: Zustand, hw: Heldwerte, g: Dictionary) -> String:
	var p := kaufpreis_von(hw, g)
	if z.gold < p: return Sprache.u("notEnoughGold")
	z.gold -= p
	if String(g["base"]) != "torch": z.laden_verkauft["%d:%d" % [z.siege / 8, int(g["uid"])]] = true
	var neu := g.duplicate(true)
	neu["uid"] = 0
	z.ausruestung_dazu(neu)
	return Sprache.u("bought", [Beute.name(g)])

# Game.sellGear: Stueck [i] der Tasche
func verkaufe_ausruestung(z: Zustand, hw: Heldwerte, i: int) -> String:
	if i < 0 or i >= z.beutel.size(): return Sprache.u("cannotSell")
	var g: Dictionary = z.beutel[i]
	z.beutel.remove_at(i)
	var p := verkaufspreis_von(hw, g)
	z.gold += p
	_verkauft({"ausruestung": g, "anzahl": 1, "preis": p})
	return Sprache.u("sold", [Beute.name(g)])

# Game.sellAllCommon: alles Gewoehnliche auf einmal; gibt die Zahl
func verkaufe_gewoehnliches(z: Zustand, hw: Heldwerte) -> int:
	var weg_ := z.beutel.filter(func(g): return String(g["rarity"]) == "COMMON")
	for g in weg_:
		z.beutel.erase(g)
		z.gold += verkaufspreis_von(hw, g)
		_verkauft({"ausruestung": g, "anzahl": 1, "preis": verkaufspreis_von(hw, g)})
	return weg_.size()

static func rezepte() -> Array:
	Sprache.lade()
	return Sprache.texte.get("rezepte", [])

static func bezahlbar(z: Zustand, r: Dictionary) -> bool:
	if z.gold < int(r["gold"]): return false
	for id in r["zutaten"]:
		if z.anzahl(String(id)) < int(r["zutaten"][id]): return false
	return true

# Recipe.cost: „2× Heilkräuter, 5 Gold“
static func kosten(r: Dictionary) -> String:
	var teile: Array = []
	for id in r["zutaten"]: teile.append("%d× %s" % [int(r["zutaten"][id]), name(String(id))])
	if int(r["gold"]) > 0: teile.append(("%d Gold" if Sprache.aktiv() == "de" else "%d gold") % int(r["gold"]))
	return ", ".join(teile)

# Game.brew: Zutaten und Gold weg, ein Trank; ein kluger Held holt manchmal einen zweiten heraus (Perks.extraBrewChance).
# wurf: Zufallszahl 0..1 (Dice.chance), im Test fest
func braue(z: Zustand, hw: Heldwerte, r: Dictionary, wurf: float = randf()) -> String:
	if not bezahlbar(z, r): return Sprache.l("missing")
	for id in r["zutaten"]: z.weg(String(id), int(r["zutaten"][id]))
	z.gold -= int(r["gold"])
	var aus := String(r["ergebnis"])
	z.dazu(aus)
	if wurf < TALENTE.extra_brew_chance(hw):
		z.dazu(aus)
		return Sprache.l("brewedTwo", [name(aus)])
	return Sprache.l("brewed", [name(aus)])
