extends "res://kampf/zauber.gd"
## 1036 (Chef 12.11., 14:48, Build 280, Probekampf Brandflasche: „da sieht man kein Brennen. Das hatten wir alles schon unter
## Kotlin, die ganzen Effekte, die sichtbaren“): was ein Zustand an der Figur zeigt, solange er hält, wie alt BattleFx.kt
## drawStatus (Brennen, Gift, Bluten, Betäubt, Verlangsamt, Geschwächt, Geblendet, Betrunken), dazu die Blutlache (drawBloodPool)
## und je Runde das Aufflackern beim Schaden des Zustands (BattleFx.kt FxKind POISON, BURN, BLEED). Gemalt als Tafel in der Tiefe
## vor der Figur (tafel.gd, wie die Zauber), so verdecken Figuren davor es von selbst. Maße wie alt in u, mal KRAFT (unten).
## Der Körper (alt BodyFit) kommt aus kampf_ui.gd _koerper: Brust, Boden, Kopf, Umriss am Schirm.

const BILE := Color("9ab040")
const BLOOD_DARK := Color("7a0e12")
const FROST := Color("bfe8ff")
const CURSE := Color("8a58c8")
const VEIL := Color("3a2050")
const DAZE := Color("d8d0b0")
const MEAD := Color("c89a3a")
const POISON := Color("9ae04a")
const BLOOD := Color("e03a3a")

## Wie lange das Aufflackern je Runde spielt (BattleFx.kt baseFxDuration, Grundwert), ms
const FLARE_MS := 520.0


static func _cyc(t: float, i: int, speed: float) -> float:
	return fposmod(t * speed + i * 0.6180339, 1.0)


static func _hash(i: int, k: int) -> float:
	return float(((i * 73856093) ^ (k * 19349663)) & 0xFFFF) / 65535.0


## Linker und rechter Rand des Körpers am Schirm in der Höhe y, oder null neben dem Körper (über dem Kopf, unter einer Fledermaus
## im Flug): wie alt BodyFit.span
static func span(body: Dictionary, y: float):
	var r: Rect2 = body.rect
	if y < r.position.y or y > r.end.y + 2.0:
		return null
	return Vector2(body.cx - body.half, body.cx + body.half)


## 1036 (Chef 12.11., 17:02: „das ist viel zu klein oder unsichtbar … das muss intensiver sein“): alles am Körper um KRAFT größer
## als alt, dichter und deckender, dazu je Zustand ein farbiger Hauch über dem ganzen Körper (pulsiert), damit man ihn am Wolf so
## gut liest wie am Helden
const KRAFT := 1.9
const HAUCH := {"BURN": Color("ff7a1e"), "POISON": Color("8ad83a"), "BLEED": Color("b0141a"), "STUN": Color("f0e2a0"),
		"SLOW": Color("9fdcff"), "WEAK": Color("8a58c8"), "BLIND": Color("ffffff"), "DRUNK": Color("d8a040")}


## Der Hauch: ein weicher Schein in der Farbe des Zustands über dem Körper, langsam pulsierend
func _hauch(st: String, t: float, body: Dictionary, u: float) -> void:
	if not HAUCH.has(st):
		return
	var r: Rect2 = body.rect
	var top: float = maxf(r.position.y, body.chest.y - (body.ground - body.chest.y) * 0.9)
	var mid := Vector2(body.cx, (top + body.ground) / 2.0)
	var rx: float = maxf(body.half * 1.5, 12 * u)
	var ry: float = maxf((body.ground - top) / 2.0 * 1.15, 12 * u)
	var pul := 0.75 + 0.25 * sin(t * (5.0 if st == "BURN" else 2.6))
	var c: Color = HAUCH[st]
	_glow(mid, rx, [_a(c, 0.30 * pul), _a(c, 0.12 * pul), _a(c, 0.0)], ry / rx)


## Was der Zustand st an der Figur zeigt; t läuft in Sekunden weiter; blood: Blutstufe (0 aus)
func draw_status(st: String, t: float, body: Dictionary, u0: float, blood: int) -> void:
	var u := u0 * KRAFT
	var chest: Vector2 = body.chest
	var ground: float = body.ground
	var h := ground - chest.y
	var top := chest.y - h * 0.8
	var cx: float = body.cx
	var w: float = maxf(body.half * 2.0 * 0.9, 16 * u0)
	if st != "BLEED" or blood > 0:
		_hauch(st, t, body, u0)
	match st:
		"BURN":
			# Flammen am Umriss und an den Füßen, Glut und Rauch; nicht mitten auf den Körper geklebt
			for i in 11:
				var side := -1.0 if i % 2 == 0 else 1.0
				var by := ground - _hash(i, 2) * h * (0.05 if i >= 9 else 1.3)
				var edge = span(body, by)
				if edge == null:     # nichts vom Körper in dieser Höhe: keine Flamme in der Luft
					continue
				var bx: float
				if i >= 9:
					bx = lerpf(edge.x, edge.y, 0.3 + 0.4 * (i - 9))
				else:
					bx = (edge.x if side < 0 else edge.y) - side * (1.0 + 2.5 * _hash(i, 1)) * u0
				var life := _cyc(t, i, 1.3)
				var hh := (9 + 13 * _hash(i, 3)) * u * sin(life * PI) * (0.8 + 0.2 * sin(t * 17.0 + i))
				var lean := sin(t * 7.0 + i) * 2.0 * u
				_tongue(Vector2(bx, by), hh, 6.5 * u, lean, FIRE_DARK, 0.9)
				_tongue(Vector2(bx, by), hh * 0.7, 4.4 * u, lean, FIRE, 1.0)
				_tongue(Vector2(bx, by), hh * 0.35, 2.0 * u, lean * 0.5, FIRE_HOT, 1.0)
			for i in 7:
				var c := _cyc(t, i, 0.5)
				var p := Vector2(cx + (_hash(i, 4) - 0.5) * w + sin(c * 6.0 + i) * 4 * u, chest.y - c * h * 1.1)
				_glow(p, (4 + 7 * c) * u, [_a(SMOKE, 0.5 * (1 - c)), _a(SMOKE, 0.0)])
			for i in 12:
				var c := _cyc(t, i, 0.9)
				_square(FIRE_HOT if i % 2 == 0 else FIRE, Vector2(cx + (_hash(i, 5) - 0.5) * w * 1.3 + sin(c * 9.0 + i) * 3 * u, ground - h * 0.3 - c * h * 1.2), 1.6 * u, 1.0 - c)
		"POISON":
			# grüner Dunst steigt vom Körper, Blasen platzen, Tropfen Galle fallen
			for i in 9:
				var c := _cyc(t, i, 0.35)
				var p := Vector2(cx + (-1.0 if i % 2 == 0 else 1.0) * w * (0.3 + 0.3 * _hash(i, 1)) + sin(c * 5.0 + i) * 5 * u, ground - h * 0.4 - c * h * 1.4)
				_glow(p, (9 + 12 * c) * u, [_a(BILE, 0.5 * sin(c * PI)), _a(BILE, 0.0)])
			for i in 6:
				var c := _cyc(t, i + 3, 0.6)
				var p := Vector2(cx + (_hash(i, 9) - 0.5) * w * 1.1, chest.y + h * 0.2 - c * h * 1.2)
				_ring(p, (1.5 + 2.5 * c) * u, _a(POISON, 0.9 * (1.0 - c)), 0.9 * u)
			for i in 3:
				var c := _cyc(t, i, 0.45)
				if c < 0.6:
					var f := c / 0.6
					var x := cx + (_hash(i, 6) - 0.5) * w * 0.6
					_square(BILE, Vector2(x, chest.y + 6 * u0 + f * f * (ground - chest.y - 6 * u0)), 3.0 * u, 1.0)
		"BLEED":
			if blood <= 0:
				return
			# Tropfen fallen aus der Wunde (die Lache am Boden: pool)
			for i in (5 if blood >= 2 else 3):
				var c := _cyc(t, i, 0.8)
				var x := cx + (_hash(i, 7) - 0.5) * w * 0.6
				var y0 := chest.y + (_hash(i, 8) - 0.3) * h * 0.4
				_square(BLOOD, Vector2(x, y0 + c * c * (ground - y0)), 2.4 * u, 1.0)
				_square(BLOOD_DARK, Vector2(x, y0 + c * c * (ground - y0) - 2.5 * u0), 1.8 * u, 0.9)
		"STUN":
			# benommen: trüber Dunst um den Kopf, helle Funken kreisen darüber (der Körper schwankt, figur.gd _shake)
			var head: Vector2 = body.head
			for i in 3:
				var a := t * 2.2 + i * 2.1
				_glow(head + Vector2(cos(a) * 10 * u, sin(a) * 3 * u - 4 * u), 9 * u, [_a(DAZE, 0.45), _a(DAZE, 0.0)])
			for i in 5:
				var a := t * 3.4 + i * TAU / 5.0
				var p := head + Vector2(cos(a) * 12 * u, sin(a) * 3.5 * u - 9 * u)
				_square(HOLY if sin(a) > 0.0 else DAZE, p, 2.2 * u, 0.6 + 0.4 * sin(a))
		"SLOW":
			# Kälte: ein Frosthauch um den Körper, Reif glitzert darauf
			for i in 8:
				var c := _cyc(t, i, 0.25)
				var p := Vector2(cx + (_hash(i, 1) - 0.5) * w * 1.4 + sin(c * 4.0 + i) * 4 * u, ground - c * h * 1.0)
				_glow(p, (7 + 8 * c) * u, [_a(FROST, 0.45 * sin(c * PI)), _a(FROST, 0.0)])
			for i in 16:
				var glint := (sin(t * 3.0 + i * 1.7) + 1.0) / 2.0
				_square(FROST, Vector2(cx + (_hash(i, 2) - 0.5) * w, top + _hash(i, 3) * (ground - top)), 1.5 * u, 0.4 + 0.6 * glint * glint)
		"WEAK":
			# ein dunkelvioletter Schleier hängt am Körper und treibt von ihm fort
			var mid := Vector2(cx, (top + ground) / 2.0)
			_glow(mid, maxf(w, 1.0), [_a(CURSE, 0.35), _a(CURSE, 0.14), _a(CURSE, 0.0)], (ground - top) / 2.0 / maxf(w, 1.0))
			for i in 8:
				var c := _cyc(t, i, 0.3)
				var p := Vector2(cx + (_hash(i, 1) - 0.5) * w * 1.2 + sin(c * 3.0 + i) * 6 * u, ground - h * 0.2 - c * h * 1.3)
				_glow(p, (5 + 7 * c) * u, [_a(VEIL, 0.6 * (1 - c)), _a(VEIL, 0.0)])
		"BLIND":
			# ein greller Nachschein flackert vor den Augen
			var eyes: Vector2 = body.head
			var flick := 0.6 + 0.4 * sin(t * 13.0) * sin(t * 5.3)
			_glow(eyes, 14 * u, [_a(WHITE, 0.7 * flick), _a(WHITE, 0.2 * flick), _a(WHITE, 0.0)])
			ci.draw_line(eyes + Vector2(-14 * u, 0), eyes + Vector2(14 * u, 0), _a(WHITE, 0.6 * flick), 1.4 * u, true)
		"DRUNK":
			# Bernsteinflocken treiben neben dem Kopf hoch, langsam und taumelnd
			var head: Vector2 = body.head
			for i in 7:
				var c := _cyc(t, i, 0.3)
				_square(MEAD, Vector2(head.x + (_hash(i, 6) - 0.5) * w + sin(c * 7.0 + i) * 5 * u, head.y - c * h * 0.5), 1.8 * u, 1.0 - c)


## Die Lache, die ein blutender Körper dort lässt, wo er steht (alt drawBloodPool): bleibt am Boden, wenn er anspringt oder ausweicht
func pool(t: float, x: float, ground: float, u: float, blood: int) -> void:
	if blood <= 0:
		return
	var size := (0.6 + 0.4 * minf(t / 6.0, 1.0)) * (1.0 if blood >= 2 else 0.6) * KRAFT
	var rx := 14 * u * size
	var ry := 3.5 * u * size
	var pts := PackedVector2Array()
	for k in 16:
		pts.append(Vector2(x + cos(TAU * k / 16.0) * rx, ground + sin(TAU * k / 16.0) * ry))
	ci.draw_polygon(pts, PackedColorArray([_a(BLOOD_DARK, 0.9)]))


## Das Aufflackern je Runde beim Schaden des Zustands st, p von 0 bis 1 (alt BattleFx.kt FxKind POISON, BURN, BLEED)
func flare(st: String, sd: int, p: float, target: Vector2, u0: float) -> void:
	var u := u0 * KRAFT
	rnd.seed = sd
	var f := _fade(p)
	match st:
		"POISON":     # Ringe steigen auf
			for i in 10:
				var x := target.x + (_rf() - 0.5) * 50 * u
				var y := target.y + 20 * u - p * (30 + 30 * _rf()) * u
				var r := (2 + 3 * _rf()) * u
				_ring(Vector2(x, y), r, _a(POISON, f), 1.5 * u)
		"BURN":     # Glut steigt auf
			for i in 14:
				var x := target.x + (_rf() - 0.5) * 44 * u
				var rise := fmod(p + _rf() * 0.5, 1.0)
				var y := target.y + 26 * u - rise * 50 * u
				var col: Color = [FIRE_HOT, FIRE, FIRE_DARK][i % 3]
				_square(col, Vector2(x, y), (4.5 - rise * 3.0) * u, f * (1.0 - rise * 0.6))
		"BLEED":     # Tropfen laufen aus der Wunde
			for k in 10:
				var x := target.x + (_rf() - 0.5) * 30 * u
				var fall := clampf(p * 1.3 - k * 0.04, 0.0, 1.0)
				var y := target.y - 6 * u + fall * (18 + _rf() * 18) * u
				ci.draw_circle(Vector2(x, y), (1.6 + _rf()) * u, _a(BLOOD, (1.0 - fall * 0.7) * f))


func _ring(at: Vector2, r: float, c: Color, wd: float) -> void:
	var prev := at + Vector2(r, 0)
	for k in range(1, 13):
		var q := at + Vector2(cos(TAU * k / 12.0), sin(TAU * k / 12.0)) * r
		ci.draw_line(prev, q, c, wd, true)
		prev = q
