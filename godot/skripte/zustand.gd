class_name Zustand
extends RefCounted
# 390: der Spielstand, soweit Gespraeche und Quests ihn brauchen (GameState.kt: flags, inventory, gold, Stufe des Helden);
# als Woerterbuch speicherbar (Spielstand folgt). Uhr, Rast und Laden (390) sind dabei.

var name := "Alrik"
var aussehen := {}                     # 376.1 Kopfform, Haar, Bart, Haar- und Hautfarbe (HeldFigur.VORGABE)
var stufe_held := 1
var gold := 0
var taschen := {}                      # Ding -> Anzahl (GameState.inventory)
var flaggen := {}                      # Flagge -> true (GameState.flags)
var minuten := 8 * 60                  # 390: Minute des Tages (GameState.minutes), eine Spielminute je Sekunde (Game.tickClock)
var tag := 1
var uhr_rest := 0.0
# 390 (Rast, Resting.kt): was eine Rast beendet oder fuellt (GameState.stamina, winded, staminaBoost, spark, longRestDay, mead, ailments)
var ausdauer := 1.0
var atemlos := false
var ausdauer_trank := false
var funke := false
var satt := false                     # 399.1: GameState.wellFed, nach dem Essen bis zum naechsten Kampf
var lange_rast_tag := 0
var met := 0
var leiden := {}                       # Zustand -> Runden (GameState.ailments)
var wiederkehr := {"karte": "inn", "x": 8, "y": 2, "blick": "DOWN"}   # GameState.respawn, anfangs Story.START
# 390 (Laden): Ausruestung in der Tasche (GameState.bag, Woerterbuecher wie Gear), Siege (battlesWon), schon gekaufte Ware (shopSold)
var beutel: Array = []
var siege := 0
var schritte := 0                 # 399.1 GameState.steps
var laden_verkauft := {}               # "Satz:uid" -> true
var gehoert := {}                      # 399.1 Person -> Fingerabdruecke der letzten Gespraeche (GameState.heard, Ruf.gd)
var uid_zaehler := 0                   # GameState.uidCounter

func has(f: String) -> bool: return flaggen.has(f)
func setze(f: String) -> void: flaggen[f] = true
func anzahl(ding: String) -> int: return int(taschen.get(ding, 0))
func stufe() -> int: return stufe_held
func betrunken() -> bool: return met >= Rast.BETRUNKEN

func uhr(dt: float) -> void:
	uhr_rest += dt
	while uhr_rest >= 1.0:
		uhr_rest -= 1.0
		minuten += 1
		if minuten >= 24 * 60:
			minuten = 0
			tag += 1

func dazu(ding: String, n: int = 1) -> void: taschen[ding] = anzahl(ding) + n

# wie GameState.remove: nie unter null, leere Eintraege weg
func weg(ding: String, n: int = 1) -> void:
	var rest := anzahl(ding) - n
	if rest > 0: taschen[ding] = rest
	else: taschen.erase(ding)

func neue_uid() -> int:
	uid_zaehler += 1
	return uid_zaehler

# GameState.addGear: ohne eigene Kennung bekommt das Stueck eine neue
func ausruestung_dazu(g: Dictionary) -> Dictionary:
	var eigen := g.duplicate(true)
	if int(eigen.get("uid", 0)) <= 0: eigen["uid"] = neue_uid()
	beutel.append(eigen)
	return eigen

# ein Stueck Ausruestung aus JSON: Zahlen wieder ganz
static func stueck(g: Dictionary) -> Dictionary:
	var rolls: Array = []
	for r in g.get("rolls", []): rolls.append([String(r[0]), int(r[1])])
	return {"uid": int(g.get("uid", 0)), "base": String(g["base"]), "rarity": String(g.get("rarity", "COMMON")), "ilvl": int(g.get("ilvl", 1)),
		"plus": int(g.get("plus", 0)), "rolls": rolls, "unique": g.get("unique"), "name_seed": int(g.get("name_seed", 0))}

func als_daten() -> Dictionary:
	return {"name": name, "stufe": stufe_held, "gold": gold, "taschen": taschen.duplicate(), "flaggen": flaggen.keys(), "minuten": minuten, "tag": tag,
		"ausdauer": ausdauer, "atemlos": atemlos, "ausdauer_trank": ausdauer_trank, "funke": funke, "satt": satt, "lange_rast_tag": lange_rast_tag,
		"met": met, "leiden": leiden.duplicate(), "wiederkehr": wiederkehr.duplicate(), "beutel": beutel.duplicate(true), "siege": siege, "schritte": schritte,
		"laden_verkauft": laden_verkauft.keys(), "uid_zaehler": uid_zaehler, "gehoert": gehoert.duplicate(true), "aussehen": aussehen.duplicate()}

static func aus_daten(d: Dictionary) -> Zustand:
	var z := Zustand.new()
	z.aussehen = (d.get("aussehen", {}) as Dictionary).duplicate()
	z.name = String(d.get("name", z.name)); z.stufe_held = int(d.get("stufe", 1)); z.gold = int(d.get("gold", 0))
	for k in d.get("taschen", {}): z.taschen[String(k)] = int(d["taschen"][k])
	for f in d.get("flaggen", []): z.flaggen[String(f)] = true
	z.minuten = int(d.get("minuten", z.minuten)); z.tag = int(d.get("tag", 1))
	z.ausdauer = float(d.get("ausdauer", 1.0)); z.atemlos = bool(d.get("atemlos", false)); z.ausdauer_trank = bool(d.get("ausdauer_trank", false))
	z.funke = bool(d.get("funke", false)); z.satt = bool(d.get("satt", false)); z.lange_rast_tag = int(d.get("lange_rast_tag", 0)); z.met = int(d.get("met", 0))
	for k in d.get("leiden", {}): z.leiden[String(k)] = int(d["leiden"][k])
	if d.has("wiederkehr"):
		var w: Dictionary = d["wiederkehr"]
		z.wiederkehr = {"karte": String(w["karte"]), "x": int(w["x"]), "y": int(w["y"]), "blick": String(w.get("blick", "DOWN"))}
	for g in d.get("beutel", []): z.beutel.append(stueck(g))
	z.siege = int(d.get("siege", 0)); z.schritte = int(d.get("schritte", 0)); z.uid_zaehler = int(d.get("uid_zaehler", 0))
	for k in d.get("laden_verkauft", []): z.laden_verkauft[String(k)] = true
	for k in d.get("gehoert", {}): z.gehoert[String(k)] = (d["gehoert"][k] as Array).map(func(x): return int(x))
	return z
