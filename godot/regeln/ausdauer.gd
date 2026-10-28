# 390 (core Stamina.kt; 86.3, 131 im alten Spiel): Atem fürs Rennen auf der Karte. Rennen ist kurz: der Vorrat hält etwa
# 6 s bei Konstitution 10, je Punkt des Modifikators 2 s mehr oder weniger und je zwei Stufen 1 s mehr, halb so lang in
# schwerer Rüstung ohne die Stärke dafür. Er füllt sich beim Gehen in 40 s, im Stehen in 20 s, mit einer Rast sofort.
# Leer geht der Held, bis ein Viertel zurück ist. Der Vorrat gehört zum Spielstand (GameState.stamina, winded, running),
# hier als eigenes Objekt, bis Toms Spielstand (godot/skripte/zustand.gd) ihn aufnimmt.
extends RefCounted

const WALK_REFILL_MS := 40000.0
const STAND_REFILL_MS := 20000.0
## 84.4: Rennen ist laut; Monster bemerken den Helden so viele Felder früher (im Test zu eichen)
const RUN_NOISE := 2
## außer Atem darf der Held ab so viel wieder rennen
const AGAIN := 0.25

var stamina := 1.0
var winded := false
var running := false


## Wie lange ein voller Vorrat beim Rennen hält (ms): [con_mod] Modifikator der Konstitution, [level] Stufe, [heavy_armor] schwere
## Rüstung ohne die Stärke dafür, [boost] Ausdauertrank (86.6) verdoppelt.
static func lasts_ms(con_mod: int, level: int, heavy_armor := false, boost := false) -> float:
	var s := maxf(6.0 + 2.0 * con_mod + floori(level / 2.0), 2.0)
	return s * 1000.0 * (0.5 if heavy_armor else 1.0) * (2.0 if boost else 1.0)


## Schwere Rüstung am Leib ohne die Stärke dafür (Stärke unter 13, wie das Kettenhemd im SRD): [chest_weight] das Gewicht
## der Rüstung („HEAVY“ …, leer ohne), [strength] der Wert der Stärke.
static func heavy(chest_weight: String, strength: int) -> bool:
	return chest_weight == "HEAVY" and strength < 13


## Ein Bild von [dt] ms: der Held [moving], will [run]; [lasts] aus lasts_ms(). Gibt zurück, ob er rennt: nicht außer Atem
## und nicht betrunken (181), bis ein Viertel des Vorrats zurück ist.
func step(dt: float, moving: bool, run: bool, lasts: float, drunk := false) -> bool:
	var runs := moving and run and not winded and not drunk
	if runs:
		stamina -= dt / lasts
	elif moving:
		stamina += dt / WALK_REFILL_MS
	else:
		stamina += dt / STAND_REFILL_MS
	stamina = clampf(stamina, 0.0, 1.0)
	if stamina <= 0.0:
		winded = true
	elif winded and stamina >= AGAIN:
		winded = false
	running = runs and not winded
	return running


## Eine Rast füllt den Vorrat.
func refill() -> void:
	stamina = 1.0
	winded = false


func to_dict() -> Dictionary:
	return {"stamina": stamina, "winded": winded}


static func from_dict(d: Dictionary):
	var a = load("res://regeln/ausdauer.gd").new()
	a.stamina = float(d.get("stamina", 1.0))
	a.winded = bool(d.get("winded", false))
	return a
