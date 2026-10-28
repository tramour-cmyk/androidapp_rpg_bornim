class_name Zustand
extends RefCounted
# 390: der Spielstand, soweit Gespraeche und Quests ihn brauchen (GameState.kt: flags, inventory, gold, Stufe des Helden);
# als Woerterbuch speicherbar (Spielstand folgt). Uhr und Rast (390) sind dabei; Ausruestung kommt mit ihrem Punkt dazu.

var name := "Alrik"
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
var lange_rast_tag := 0
var met := 0
var leiden := {}                       # Zustand -> Runden (GameState.ailments)
var wiederkehr := {"karte": "inn", "x": 8, "y": 2, "blick": "DOWN"}   # GameState.respawn, anfangs Story.START

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

func als_daten() -> Dictionary:
	return {"name": name, "stufe": stufe_held, "gold": gold, "taschen": taschen.duplicate(), "flaggen": flaggen.keys(), "minuten": minuten, "tag": tag,
		"ausdauer": ausdauer, "atemlos": atemlos, "ausdauer_trank": ausdauer_trank, "funke": funke, "lange_rast_tag": lange_rast_tag,
		"met": met, "leiden": leiden.duplicate(), "wiederkehr": wiederkehr.duplicate()}

static func aus_daten(d: Dictionary) -> Zustand:
	var z := Zustand.new()
	z.name = String(d.get("name", z.name)); z.stufe_held = int(d.get("stufe", 1)); z.gold = int(d.get("gold", 0))
	for k in d.get("taschen", {}): z.taschen[String(k)] = int(d["taschen"][k])
	for f in d.get("flaggen", []): z.flaggen[String(f)] = true
	z.minuten = int(d.get("minuten", z.minuten)); z.tag = int(d.get("tag", 1))
	z.ausdauer = float(d.get("ausdauer", 1.0)); z.atemlos = bool(d.get("atemlos", false)); z.ausdauer_trank = bool(d.get("ausdauer_trank", false))
	z.funke = bool(d.get("funke", false)); z.lange_rast_tag = int(d.get("lange_rast_tag", 0)); z.met = int(d.get("met", 0))
	for k in d.get("leiden", {}): z.leiden[String(k)] = int(d["leiden"][k])
	if d.has("wiederkehr"): z.wiederkehr = (d["wiederkehr"] as Dictionary).duplicate()
	return z
