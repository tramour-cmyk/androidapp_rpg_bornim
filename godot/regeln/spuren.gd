# 390 (core Tracks.kt, Idee 7, Entwurf): Spuren, die eine Weile bleiben: Blut, wo ein Gegner fiel, Fußspuren im nassen
# Boden nach Regen (mit Schlamm an den Stiefeln ein paar blasse auf Stein und Dielen), Staub beim Rennen auf trockenem Weg.
# Nur im Speicher, nie gespeichert; jede verblasst von selbst. Orte in Feldern, Zeiten in ms der Uhr. Der Boden kommt als
# Name der Kachel wie in core Tile („GRASS“, „PATH“ …). Gezeichnet wird in Toms Karte.
extends RefCounted

const BLOOD := "BLOOD"
const PRINT := "PRINT"
const DUST := "DUST"
## Schlüssel des Helden unter den Füßen der Gehenden
const HERO := "@hero"
const BLOOD_MS := 6 * 60000
const PRINT_MS := 2 * 60000
const CARRIED_MS := 60000
const DUST_MS := 900
const FADE_FROM := 0.6
## so lange trocknet der Boden nach dem Regen (ms); kurz (61b), der nasse Boden wird nicht gezeichnet
const DRY_MS := 60000.0
## ab dieser Nässe hält weicher Boden Spuren; unter DRY ist ein Weg trocken genug für Staub
const WET := 0.3
const DRY := 0.05
## so weit setzt ein Fuß vor den anderen, gehend und rennend (Felder)
const STEP := 0.42
const RUN_STEP := 0.6
## so weit neben der Linie setzt ein Fuß auf (Felder)
const SIDE := 0.07
## Spuren, die schlammige Stiefel noch auf Stein und Dielen lassen, und wie deutlich die erste ist
const MUD_STEPS := 8
const CARRIED := 0.55
const MAX := 240

## der Prüfschalter: Spuren entstehen und werden gezeichnet (Entwurf)
static var draft := true


## Eine Spur auf [map] bei ([x], [y]), entstanden um [at]; [yaw] wohin der Fuß zeigte (0 nach unten, 90 nach rechts), [left]
## welcher Fuß, [strength] wie deutlich, [seed] ihre Form.
class Mark:
	var kind: String
	var map: String
	var x: float
	var y: float
	var at: int
	var yaw: float
	var left: bool
	var strength: float
	var seed: int

	func _init(k: String, m: String, px: float, py: float, t: int, w := 0.0, l := false, s := 1.0, sd := 0) -> void:
		kind = k; map = m; x = px; y = py; at = t; yaw = w; left = l; strength = s; seed = sd

	func life() -> int:
		match kind:
			"BLOOD":
				return BLOOD_MS
			"PRINT":
				return PRINT_MS if strength >= 1.0 else CARRIED_MS
		return DUST_MS

	## 0 (neu) bis 1 (vergangen)
	func age(now: int) -> float:
		return clampf(float(now - at) / life(), 0.0, 1.0)

	## wie stark sie sich zeigt: voll den größten Teil ihres Lebens, dann verblassend
	func alpha(now: int) -> float:
		var a := age(now)
		return strength * (1.0 if a < FADE_FROM else (1.0 - (a - FADE_FROM) / (1.0 - FADE_FROM)))


var marks: Array = []
## wie nass der Boden noch ist, 0 bis 1: so nass wie der Regen, danach langsam trocknend
var wet := 0.0
## je Gehendem: {mud, stride, left, x, y, map}
var _feet := {}


## Schlammspuren, die die Stiefel des Helden noch lassen.
func mud() -> int:
	return int(_feet[HERO].mud) if _feet.has(HERO) else 0


## Trocknet den Boden um [delta_ms] bei Regen [rain] (0 bis 1).
func weather(rain: float, delta_ms: int) -> void:
	wet = maxf(rain, wet - delta_ms / DRY_MS)


## Boden sofort so nass wie der Regen (Vorschau, Test).
func settle(rain: float) -> void:
	wet = rain


## Blut, wo ein Gegner fiel.
func blood(map: String, x: float, y: float, now: int, seed: int) -> void:
	if not draft:
		return
	_add(Mark.new(BLOOD, map, x, y, now, 0.0, false, 1.0, seed))


## Die Füße des Helden (oder eines Dorfbewohners, [who] seine Kennung, 61) bei ([x], [y]) auf [map], unterwegs nach [yaw], auf
## [ground]; [outdoors] ob Regen den Boden erreicht, [running] ob er rennt. Je Schritt eine Spur, wo der Boden nass und weich
## ist (oder die Stiefel noch schlammig), je Doppelschritt eine Staubwolke auf trockenem Weg beim Rennen.
func walked(map: String, x: float, y: float, yaw: float, ground: String, outdoors: bool, running: bool, now: int, who := HERO) -> void:
	if not draft:
		return
	if not _feet.has(who):
		_feet[who] = {"mud": 0, "stride": 0.0, "left": false, "x": NAN, "y": NAN, "map": ""}
	var f: Dictionary = _feet[who]
	if map != f.map or is_nan(f.x):
		f.map = map; f.x = x; f.y = y; f.stride = 0.0
		return
	f.stride += Vector2(x - f.x, y - f.y).length()
	f.x = x; f.y = y
	var step := RUN_STEP if running else STEP
	if f.stride < step:
		return
	f.stride = 0.0
	f.left = not f.left
	var left_foot: bool = f.left
	# der Fuß setzt neben der Linie auf, links oder rechts davon
	var r := deg_to_rad(yaw)
	var side := (-1 if left_foot else 1) * SIDE
	var fx := x + cos(r) * side
	var fy := y - sin(r) * side
	var soft := ground in ["GRASS", "PATH", "FLOWERS"]
	var muddy := outdoors and soft and wet >= WET
	if muddy:
		f.mud = MUD_STEPS
		_add(Mark.new(PRINT, map, fx, fy, now, yaw, left_foot, 1.0))
	elif int(f.mud) > 0 and ground != "TALL_GRASS" and ground != "WATER":
		_add(Mark.new(PRINT, map, fx, fy, now, yaw, left_foot, CARRIED * int(f.mud) / MUD_STEPS))
		f.mud = int(f.mud) - 1
	if running and wet < DRY and ground in ["PATH", "CAVE_FLOOR"] and not left_foot:
		_add(Mark.new(DUST, map, x - sin(r) * 0.2, y - cos(r) * 0.2, now, yaw, false, 1.0, now % 997))


## Die Spuren auf [map], die um [now] noch zu sehen sind.
func on(map: String, now: int) -> Array:
	return marks.filter(func(m): return m.map == map and now - m.at < m.life())


func _add(m: Mark) -> void:
	marks = marks.filter(func(o): return m.at - o.at < o.life())
	if marks.size() >= MAX:
		var i := -1
		for k in marks.size():
			if marks[k].kind != BLOOD:
				i = k
				break
		marks.remove_at(i if i >= 0 else 0)
	marks.append(m)
