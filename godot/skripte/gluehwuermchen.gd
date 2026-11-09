class_name Gluehwuermchen
extends Node3D
# 514 (Chef 03.11., 16:01: „Gibt es nachts vernünftige Glühwürmchen überall auf den Karten?“): wie alt (WorldScreen.kt Fireflies,
# 10.10., 4): kleine Schwaerme an festen Stellen der Welt, ueber Blumen und Wiesen, am Wasser und am Waldrand, ueber den Feldern im
# Dorf; wenig im tiefen Wald, auf Wegen selten. Jedes treibt langsam, mal stehend, mal steigend oder sinkend, leuchtet sanft auf
# und lange nach, dann Sekunden dunkel, im eigenen Takt; manchmal antwortet ein Nachbar kurz danach. Nur in manchen Naechten
# (zwei von fuenf, die Nacht gehoert zum Tag, an dem sie begann), erst wenn es dunkel ist. Ausser Sicht (Nebel, 505) vergehen sie.
# je Fliege {cx, cy, seed, period, offset, partner (-1: keiner), spread, sicht, mitte (Kachel des Schwarms)}
# Vorher: CPU-Teilchen nur an den Blumenbeeten des Dorfs (dorf.py „blumen“), jede Nacht, ohne Takt.
# Regen gibt es in Godot noch nicht (alt: nicht im Regen); kommt er, hier abschalten.

const T := 32.0                        # WorldArt.T: Bildpunkte je Kachel im alten Spiel, die Wege der Fliegen sind darin gerechnet
const KERN := Color(0.973, 1.0, 0.784)        # 0xF8FFC8
const HOF := Color(0.878, 0.973, 0.471)       # 0xE0F878
const BODEN := Color(0.784, 0.878, 0.439)     # 0xC8E070

var karte: Karte
var fliegen: Array = []
var nacht := 0.0                       # gebiet.nacht: 0 Tag, 1 Nacht
var zustand                            # spiel.gd: Tag und Uhr fuer „heute Nacht“
var sicht := Callable()                # spiel.gd (505): Kachel -> in Sicht; leer: alles sichtbar
var kern: MultiMesh
var hof: MultiMesh
var schein: MultiMesh
static var uhr_fest := -1              # Bildlauf (--gluehen): ein fester Augenblick statt der Uhr

func _init(k: Karte) -> void:
	karte = k
	name = "Gluehwuermchen"
	fliegen = schwaerme(k)

func _ready() -> void:
	if fliegen.is_empty(): return
	hof = netz(0.34, true)             # alt Radius 6 px: weicher Hof
	kern = netz(0.07, true)            # heller Kern
	schein = netz(0.9, false)          # alt: das schwache Licht auf dem Gras darunter (20 x 8 px); Bild 1 (Pruefer 18:16): scharfe helle Ellipsen, jetzt groesser und schwaecher

func netz(groesse: float, aufrecht: bool) -> MultiMesh:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var qm := QuadMesh.new()
	qm.size = Vector2(groesse, groesse * (1.0 if aufrecht else 0.7))
	if not aufrecht: qm.orientation = PlaneMesh.FACE_Y
	mm.mesh = qm
	mm.instance_count = fliegen.size()
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := Gebiet.punkt_mat(true)
	if not aufrecht: m.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	mi.material_override = m
	mi.extra_cull_margin = 64.0
	add_child(mi)
	for i in fliegen.size(): mm.set_instance_color(i, Color(0, 0, 0, 0))
	return mm

# ---------------------------------------------------------------- wie alt (Fireflies.of, Fly), Zahlen in Bildpunkten des alten Spiels
## Kotlin-Int: 32 Bit mit Ueberlauf
static func i32(x: int) -> int:
	x &= 0xFFFFFFFF
	return x - 0x100000000 if x >= 0x80000000 else x

## WorldScreen.hash
static func hash3(a: int, b: int, c: int = 0) -> int:
	var n := i32(i32(i32(a * 374761393) + i32(b * 668265263)) + i32(c * 1442695041))
	n = i32((n ^ ((n & 0xFFFFFFFF) >> 13)) * 1274126177)
	return (n ^ ((n & 0xFFFFFFFF) >> 16)) & 0x7fffffff

static func heute(tag: int, minuten: int) -> bool:
	var n := tag - 1 if minuten < 12 * 60 else tag
	return posmod(hash3(n, 77), 5) < 2

static func schwaerme(k: Karte) -> Array:
	var art := String(k.daten.get("art", ""))
	if art != "FOREST" and art != "TOWN": return []
	var zeichen := func(x: int, y: int) -> String:
		return k.zeichen(Vector2i(x, y)) if x >= 0 and y >= 0 and x < k.breite and y < k.hoehe else "T"
	var nah := func(x: int, y: int, was: Array) -> bool:
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if zeichen.call(x + dx, y + dy) in was: return true
		return false
	var mitten: Array[Vector2i] = []
	for y in k.hoehe:
		for x in k.breite:
			var hier: String = zeichen.call(x, y)
			if hier not in [".", "f", ","] and hier != "c" and hier != "v": continue
			var p := 0.02 if hier == "," else 0.0
			if hier == "f": p += 0.35
			if nah.call(x, y, ["~"]): p += 0.4
			if hier == "c" or hier == "v": p += 0.18
			var baeume := 0
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if zeichen.call(x + dx, y + dy) == "T": baeume += 1
			if art == "FOREST" and baeume >= 1 and baeume <= 3: p += 0.14
			if baeume >= 6: p *= 0.3
			if nah.call(x, y, ["=", "o"]): p *= 0.3
			if k.id == "deep_forest": p *= 0.3
			if (hash3(x, y, 88) % 1000) / 1000.0 >= p: continue
			var frei := true
			for m in mitten:
				if absi(m.x - x) + absi(m.y - y) < 4: frei = false; break
			if frei: mitten.append(Vector2i(x, y))
	var aus: Array = []
	for m in mitten:
		var x := m.x; var y := m.y
		# alt (21:1x: Schwaerme gleich gross): manche nur eins oder zwei, manche ein Haufen, nah oder weit verstreut
		var r := hash3(x, y, 89) % 100
		var n := (1 + r % 2) if r < 30 else ((3 + r % 3) if r < 75 else (6 + r % 4))
		var spread := 0.5 + (hash3(x, y, 91) % 100) / 100.0 * (1.4 if n > 5 else 0.9)
		for kk in n:
			var seed := hash3(x * 31 + kk, y, 90)
			var lead := hash3(x * 31 + kk / 2 * 2, y, 90)   # Paare teilen den Takt, so kann das zweite dem ersten antworten
			aus.append({
				"cx": x * T + T / 2.0 + (seed % 20 - 10) * spread,
				"cy": y * T + T / 2.0 + ((seed / 20) % 16 - 8) * spread,
				"seed": seed, "period": 5200 + lead % 6000, "offset": (seed / 7) % 9000,
				"partner": (lead / 7) % 9000 if kk % 2 == 1 else -1, "spread": spread, "sicht": 0.0, "mitte": m,
			})
	return aus

## Fly.at: wo sie zur Zeit uhr (ms) ist, in Bildpunkten des alten Spiels; dazu die Hoehe (alt: das Auf und Ab im Bild)
static func ort(f: Dictionary, uhr: int) -> Vector3:
	var t := uhr / 1000.0
	var s := int(f["seed"]) % 997 / 997.0 * 6.28
	var sp: float = f["spread"]
	var pace := 0.5 + 0.5 * sin(t * 0.13 + s)       # das Tempo selbst schwillt an und ab, mit Pausen
	var u := t * (0.16 + 0.12 * pace)
	var x: float = float(f["cx"]) + (sin(u * 0.9 + s) * 14.0 + sin(u * 2.3 + s * 2) * 3.0) * sp
	var y: float = float(f["cy"]) + cos(u * 0.7 + s * 1.3) * 9.0 * sp
	return Vector3(x, sin(t * 0.25 + s) * 4.0, y)

## Fly.glow: kurz auf, lange dunkel; manchmal antwortet sie dem Nachbarn einen Augenblick spaeter
static func glanz(f: Dictionary, uhr: int) -> float:
	var period: int = f["period"]
	var p: int = f["partner"]
	var antwortet := p >= 0 and posmod(hash3(int((uhr + p) / period), int(f["seed"])), 3) == 0
	var c := uhr + p - 650 if antwortet else uhr + int(f["offset"])
	var seit := posmod(c, period)
	var lang := 1300 + int(f["seed"]) % 900
	if seit >= lang: return 0.0
	var v := seit / float(lang)
	var k := v / 0.35 if v < 0.35 else (1.0 - v) / 0.65
	return k * k * (3.0 - 2.0 * k)

func _process(dt: float) -> void:
	if kern == null: return
	# alt: day < 0,4, sanft eingeblendet (fade = 1 - day / 0,4); hier Tag = 1 - nacht
	var tagl := 1.0 - nacht
	var an := tagl < 0.4 and (zustand == null or heute(int(zustand.tag), int(zustand.minuten)))
	visible = an
	if not an: return
	var fade := clampf(1.0 - tagl / 0.4, 0.0, 1.0)
	var uhr := uhr_fest if uhr_fest >= 0 else Time.get_ticks_msec()
	var ts := Karte.TS
	for i in fliegen.size():
		var f: Dictionary = fliegen[i]
		var o := ort(f, uhr)
		var kx := floori(o.x / T); var ky := floori(o.z / T)
		var soll := 1.0 if not sicht.is_valid() or sicht.call(Vector2i(kx, ky)) else 0.0
		f["sicht"] = move_toward(float(f["sicht"]), soll, dt * 3.0)   # wie der Nebel blendet (etwa 0,3 s)
		var g := glanz(f, uhr) * fade * float(f["sicht"])
		var p := Vector3(o.x / T * ts, 0.45 + o.y / T * ts * 0.6, o.z / T * ts)
		if g <= 0.02:
			kern.set_instance_color(i, Color(0, 0, 0, 0)); hof.set_instance_color(i, Color(0, 0, 0, 0)); schein.set_instance_color(i, Color(0, 0, 0, 0))
			continue
		kern.set_instance_transform(i, Transform3D(Basis(), p))
		hof.set_instance_transform(i, Transform3D(Basis(), p))
		schein.set_instance_transform(i, Transform3D(Basis(), Vector3(p.x, 0.03, p.z)))
		kern.set_instance_color(i, Color(KERN, g))
		hof.set_instance_color(i, Color(HOF, 0.45 * g))
		schein.set_instance_color(i, Color(BODEN, 0.06 * g))   # additiv auf dunklem Boden: 0,16 wie alt war zu hart (Bild 1)
