class_name Zustand
extends RefCounted
# 390: der Spielstand, soweit Gespraeche und Quests ihn brauchen (GameState.kt: flags, inventory, gold, Stufe des Helden);
# als Woerterbuch speicherbar (Spielstand folgt). Ausruestung, Zeit, Rast kommen mit ihren Punkten dazu.

var name := "Alrik"
var stufe_held := 1
var gold := 0
var taschen := {}                      # Ding -> Anzahl (GameState.inventory)
var flaggen := {}                      # Flagge -> true (GameState.flags)

func has(f: String) -> bool: return flaggen.has(f)
func setze(f: String) -> void: flaggen[f] = true
func anzahl(ding: String) -> int: return int(taschen.get(ding, 0))
func stufe() -> int: return stufe_held

func dazu(ding: String, n: int = 1) -> void: taschen[ding] = anzahl(ding) + n

# wie GameState.remove: nie unter null, leere Eintraege weg
func weg(ding: String, n: int = 1) -> void:
	var rest := anzahl(ding) - n
	if rest > 0: taschen[ding] = rest
	else: taschen.erase(ding)

func als_daten() -> Dictionary:
	return {"name": name, "stufe": stufe_held, "gold": gold, "taschen": taschen.duplicate(), "flaggen": flaggen.keys()}

static func aus_daten(d: Dictionary) -> Zustand:
	var z := Zustand.new()
	z.name = String(d.get("name", z.name)); z.stufe_held = int(d.get("stufe", 1)); z.gold = int(d.get("gold", 0))
	for k in d.get("taschen", {}): z.taschen[String(k)] = int(d["taschen"][k])
	for f in d.get("flaggen", []): z.flaggen[String(f)] = true
	return z
