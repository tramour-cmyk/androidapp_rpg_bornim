# 390 (core Status.kt): Zustände im Kampf. Ein Gegenmittel heilt alle. Gift und Blutung überdauern den Kampf und zehren auf
# der Karte weiter; ein Fluch (WEAK) bleibt bis zur Rast, zum Gegenmittel oder zum Priester; die übrigen enden mit dem Kampf.
# Namen, Kürzel und Farben stehen in mars.gd (ST_INFO); hier die Regeln dazu.
extends RefCounted

## Runden eines Zustands, der nicht von selbst vergeht (ein Fluch, von Kampf zu Kampf getragen)
const LASTING := 99


static func damaging(st: String) -> bool:
	return st in ["POISON", "BURN", "BLEED"]


## Ob der Held diesen Zustand nach dem Kampf behält.
static func lingers(st: String) -> bool:
	return st in ["POISON", "BLEED", "WEAK"]


## Wesen, die einen Zustand gar nicht erleiden können ([m] Monster aus tabellen.json: id, immune = Schadensarten; ein Zustand
## mit Namen in immune zählt auch, wie bisher in mars.gd und tests/mars_regeln.gd).
static func immune(m: Dictionary, st: String) -> bool:
	if st in m.get("immune", []):
		return true
	match st:
		"BLEED":
			return str(m.get("id", "")) in ["skeleton", "ochre_jelly", "zombie"]
		"STUN", "BLIND":
			return str(m.get("id", "")) == "ochre_jelly"
	return false
