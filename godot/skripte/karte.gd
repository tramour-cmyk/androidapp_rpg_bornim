class_name Karte
extends RefCounted
# 348.6: eine Karte aus dem Export von core (daten/karten.json, MapExport.kt): Kacheln, Begehbarkeit wie MapDef.walkable,
# Ausgaenge, Leute, Schilder; Kachel (spalte, zeile) liegt in Godot ab (spalte * ts, zeile * ts), Norden = -z.

const TS := 1.16                       # Meter je Kachel (Probe Build 11, Dorf alt/neu im Verhaeltnis zum Helden)

var id: String
var daten: Dictionary
var kacheln: Dictionary                # Zeichen -> {name, begehbar}
var breite := 0
var hoehe := 0
var zeilen: PackedStringArray
var buesche := {}                      # Vector2i -> true: Baum als Busch, langsam begehbar (291)
var ausgaenge := {}                    # Vector2i -> Dictionary
var flaggen := {}                      # Spielstand, solange es keinen gibt (Schlagbaum, Tor)
var astar := AStarGrid2D.new()
var gehen := 1.84                      # Kacheln je Sekunde auf Gras (FreeWalk.WALK)
var laufen := 3.68                     # FreeWalk.RUN
var busch_schritt := 1.5
var schlagbaum := ""                   # Anstossen am Schlagbaum (Game.barrier)

static func lade(karte_id: String) -> Karte:
	var alle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	var k := Karte.new()
	k.id = karte_id
	k.kacheln = alle["kacheln"]
	k.gehen = float(alle["gehen"]); k.laufen = float(alle["laufen"]); k.busch_schritt = float(alle["busch_schritt"])
	k.schlagbaum = String(alle["schlagbaum"]["de"])
	k.daten = alle["karten"][karte_id]
	k.breite = int(k.daten["breite"])
	k.hoehe = int(k.daten["hoehe"])
	k.zeilen = PackedStringArray(k.daten["zeilen"])
	for b in k.daten["buesche"]: k.buesche[Vector2i(int(b[0]), int(b[1]))] = true
	for a in k.daten["ausgaenge"]: k.ausgaenge[Vector2i(int(a["x"]), int(a["y"]))] = a
	k.baue_wege()
	return k

func name_de() -> String: return String(daten["name"]["de"])

func zeichen(t: Vector2i) -> String:
	if t.x < 0 or t.y < 0 or t.x >= breite or t.y >= hoehe: return String(daten["rand"])
	return zeilen[t.y][t.x]

# wie MapDef.walkable ohne Leute: Kachel begehbar, Busch, offenes Tor oder offener Schlagbaum;
# ein Ausgang, der etwas braucht, sperrt wie in Game.move (ausser auf einer Tuer: dort klopft man mit dem Knopf)
func begehbar(t: Vector2i) -> bool:
	if t.x < 0 or t.y < 0 or t.x >= breite or t.y >= hoehe: return false
	if not sperrt(t).is_empty() or tuer(t): return false
	var c := zeichen(t)
	if bool(kacheln[c]["begehbar"]): return true
	if c == "T" and buesche.has(t): return true
	if c == "L" and flaggen.has("gate_open"): return true
	if c == "z" and flaggen.has("barrier_open"): return true
	return false

# wie lange ein Schritt auf t dauert, gemessen an Gras (Terrain.stepFactor): Weg schneller, hohes Gras, Busch langsamer
func schritt(t: Vector2i) -> float:
	if zeichen(t) == "T" and buesche.has(t): return busch_schritt
	return float(kacheln.get(zeichen(t), {}).get("schritt", 1.0))

func ausgang(t: Vector2i) -> Dictionary:
	return ausgaenge.get(t, {})

# Tuer mit Ausgang: in Godot Teil der Hauswand; man steht davor und nimmt sie mit dem Knopf (215)
func tuer(t: Vector2i) -> bool:
	return zeichen(t) == "D" and ausgaenge.has(t)

func sperrt(t: Vector2i) -> Dictionary:
	var a: Dictionary = ausgaenge.get(t, {})
	if a.is_empty() or zeichen(t) in ["D", "E"] or not a.has("braucht") or flaggen.has(a["braucht"]): return {}
	return a

func kachel_pos(t: Vector2i) -> Vector3:
	return Vector3((t.x + 0.5) * TS, 0.0, (t.y + 0.5) * TS)

func pos_kachel(p: Vector3) -> Vector2i:
	return Vector2i(floori(p.x / TS), floori(p.z / TS))

func baue_wege() -> void:
	astar.region = Rect2i(0, 0, breite, hoehe)
	astar.cell_size = Vector2.ONE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()
	for y in hoehe:
		for x in breite:
			var t := Vector2i(x, y)
			astar.set_point_solid(t, not begehbar(t))
			if buesche.has(t): astar.set_point_weight_scale(t, 3.0)

# Weg von a nach b ueber Kachelmitten; leer, wenn b nicht erreichbar ist
func weg(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var r: Array[Vector2i] = []
	if not begehbar(a) or not begehbar(b): return r
	for p in astar.get_id_path(a, b): r.append(p)
	return r
