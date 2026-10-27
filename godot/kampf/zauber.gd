extends RefCounted
## 348.7, Rest aus 249: Zauber und Pfeile im Kampfort wie im alten MARS (BattleFx.kt, BattleFxLayer und drawFx), gezeichnet in die
## Anzeige über der Szene. Nur, was MARS wirft: Feuerpfeil, Magisches Geschoss, Sengender Strahl, Feuerball, Heilige Flamme,
## Heilung, Segen und der Pfeil. Maß wie alt: u = Höhe des Getroffenen / 40 (ein Wolf steht rund 40 Einheiten hoch).

## Was fliegt, geht beim Fehlschlag am Ziel vorbei (BattleFx.kt FLYING)
const FLYING := ["ARROW", "FIRE_BOLT", "MISSILES", "RAYS", "FIREBALL", "SACRED_FLAME"]

const WHITE := Color(1, 1, 1)
const STEEL := Color("cfe4ff")
const FIRE := Color("ff9a2e")
const FIRE_HOT := Color("ffe27a")
const FIRE_DARK := Color("d83a1a")
const HOLY := Color("fff2a8")
const SMOKE := Color("2e2a28")
const FORCE := Color("8c6cff")
const FORCE_CORE := Color("ede6ff")
const HEAL_LIGHT := Color("ffe2a0")
const GOLD_LIGHT := Color("ffe6a8")
## Helfer Runde 2 (Heilige Flamme: weiße Splitter „wie Eis“): heiliges Licht warmweiß statt reinweiß
const WARM_WHITE := Color("fff4d6")
const DUST := Color("8a7458")
const NONE := Color(0, 0, 0, 0)

## Chef 21.10., 14:46: wie hoch ein Pfeil im Flug steigt, im Verhältnis zur Weite
const ARROW_RISE := 0.12

var ci: CanvasItem
var rnd := RandomNumberGenerator.new()
## 348.7 (Helfer Lauf 126: Feuerpfeil, Feuerball, Geschosse flogen vor dem näheren Wolf durch): so viele Bildpunkte steigt die
## Bahn in der Mitte über die Gerade, damit sie über die Köpfe derer geht, die vor ihr stehen (kampf_ui.gd setzt es je Effekt)
static var over := 0.0


## Wie lange ein Effekt spielt (BattleFx.kt baseFxDuration), in ms
static func duration(kind: String) -> float:
	match kind:
		"FIREBALL", "SACRED_FLAME":
			return 900.0
		"MISSILES", "FIRE_BOLT", "ARROW", "HEAL", "BLESS":
			return 750.0
	return 520.0


## Wann er am Ziel ankommt (fxArrives), in ms ab dem Loslassen
static func arrives(kind: String) -> float:
	var share := 0.3
	match kind:
		"ARROW":
			share = 0.6
		"FIREBALL", "FIRE_BOLT", "MISSILES":
			share = 0.42
		"RAYS":
			share = 0.22
	return duration(kind) * share


func _rf() -> float:
	return rnd.randf()


static func _a(c: Color, a: float) -> Color:
	return Color(c, clampf(a, 0.0, 1.0))


static func _arc(a: Vector2, b: Vector2, t: float, bend: float) -> Vector2:
	var base := a.lerp(b, t)
	var d := b - a
	var ln := maxf(d.length(), 1.0)
	var lift := sin(t * PI) * bend
	return Vector2(base.x - d.y / ln * lift, base.y + d.x / ln * lift - sin(t * PI) * over)


static func _fade(p: float) -> float:
	return p / 0.15 if p < 0.15 else ((1.0 - p) / 0.4 if p > 0.6 else 1.0)


func _square(c: Color, at: Vector2, s: float, alpha := 1.0) -> void:
	if alpha <= 0.0:
		return
	# Funken rund mit Schein (Helfer Lauf 126: „Pixelquadrate“)
	ci.draw_circle(at, s, _a(c, c.a * alpha * 0.25))
	ci.draw_circle(at, s * 0.45, _a(c, c.a * alpha))


## Weicher Kreis (radialGradient): Farben von der Mitte nach außen, gleich verteilt; sy staucht ihn zur Ellipse
func _glow(at: Vector2, r: float, cols: Array, sy := 1.0) -> void:
	if r <= 0.5:
		return
	var n := 20
	var rings := cols.size() - 1
	for i in rings:
		var r0 := r * i / rings
		var r1 := r * (i + 1) / rings
		var c0: Color = cols[i]
		var c1: Color = cols[i + 1]
		if c0.a <= 0.003 and c1.a <= 0.003:
			continue
		for k in n:
			var a0 := TAU * k / n
			var a1 := TAU * (k + 1) / n
			var p00 := at + Vector2(cos(a0) * r0, sin(a0) * r0 * sy)
			var p01 := at + Vector2(cos(a1) * r0, sin(a1) * r0 * sy)
			var p10 := at + Vector2(cos(a0) * r1, sin(a0) * r1 * sy)
			var p11 := at + Vector2(cos(a1) * r1, sin(a1) * r1 * sy)
			if i == 0:
				ci.draw_polygon(PackedVector2Array([at, p10, p11]), PackedColorArray([c0, c1, c1]))
			else:
				ci.draw_polygon(PackedVector2Array([p00, p10, p11, p01]), PackedColorArray([c0, c1, c1, c0]))


## Fläche mit senkrechtem Verlauf (verticalGradient): Farben von y0 bis y1 gleich verteilt, je Eckpunkt nach seiner Höhe
func _vgrad(pts: PackedVector2Array, y0: float, y1: float, cols: Array) -> void:
	var cs := PackedColorArray()
	for q in pts:
		var f := clampf((q.y - y0) / maxf(y1 - y0, 0.001), 0.0, 1.0) * (cols.size() - 1)
		var i := mini(int(f), cols.size() - 2)
		cs.append((cols[i] as Color).lerp(cols[i + 1], f - i))
	ci.draw_polygon(pts, cs)


## Eine Flammenzunge auf base, h hoch, um lean geneigt: weich am Grund, hell im Leib (tongue)
func _tongue(base: Vector2, h: float, w: float, lean: float, c: Color, a: float, cols := []) -> void:
	if h <= 0.5 or a <= 0.01:
		return
	var pts := PackedVector2Array()
	var l0 := Vector2(base.x - w / 2, base.y)
	var lc := Vector2(base.x - w * 0.6, base.y - h * 0.45)
	var tip := Vector2(base.x + lean, base.y - h)
	var rc := Vector2(base.x + w * 0.6, base.y - h * 0.45)
	var r0 := Vector2(base.x + w / 2, base.y)
	for i in 7:
		var t := i / 6.0
		pts.append(l0.lerp(lc, t).lerp(lc.lerp(tip, t), t))
	for i in range(1, 7):
		var t := i / 6.0
		pts.append(tip.lerp(rc, t).lerp(rc.lerp(r0, t), t))
	# am Grund weich auslaufen (Helfer Lauf 126: harte waagrechte Unterkante wie eine abgeschnittene Karte)
	var cs: Array = cols if not cols.is_empty() else [_a(c, 0.0), _a(c, a), _a(c, a * 0.5)]
	cs = cs + [_a(cs[cs.size() - 1], 0.0)]
	_vgrad(pts, base.y - h, base.y, cs)


func _smoke(at: Vector2, t: float, u: float, n: int, rise: float, a: float) -> void:
	if t <= 0.0 or t >= 1.0:
		return
	for i in n:
		var d := _rf()
		var side := (_rf() - 0.5) * 16 * u
		var c := Vector2(at.x + side + sin(t * 4.0 + i) * 3 * u, at.y - rise * u * t * (0.5 + d))
		_glow(c, (4 + 7 * t + 3 * d) * u, [_a(SMOKE, a * (1 - t)), _a(SMOKE, 0.0)])


func _clinging_fire(at: Vector2, t: float, u: float, size := 1.0) -> void:
	if t <= 0.0 or t >= 1.0:
		return
	var f := t / 0.15 if t < 0.15 else (1 - t) / 0.85
	_glow(at, 26 * u * size, [_a(FIRE, 0.4 * f), _a(FIRE_DARK, 0.14 * f), NONE])
	# Zungen leben (Helfer Runde 2: Flammen am Wolf „wie Aufkleber“, standen still auf festem Platz): jede wächst, steigt,
	# löst sich und vergeht, dann wächst an anderer Stelle eine neue; durchscheinend, so liegt der Körper darunter
	for i in 8:
		var off := _rf()
		var rate := 2.4 + _rf() * 1.8
		var cyc := t * rate + off
		var ph := fmod(cyc, 1.0)
		var r := RandomNumberGenerator.new()
		r.seed = int(cyc) * 7919 + i * 131 + rnd.seed
		var bx := at.x + (r.randf() - 0.5) * 22 * u * size + sin(ph * 3.0 + i) * 1.5 * u
		var by := at.y + (r.randf() - 0.2) * 14 * u * size - ph * 7 * u * size
		var life := sin(ph * PI)
		var h := (8 + r.randf() * 12) * u * size * f * life
		var lean := sin(t * 23.0 + i) * 2.5 * u + (r.randf() - 0.5) * 3 * u * ph
		var a := 1.0 - ph * 0.6
		_tongue(Vector2(bx, by), h, 6 * u * size * (0.6 + 0.4 * life), lean, FIRE_DARK, 0.55 * a)
		_tongue(Vector2(bx, by), h * 0.75, 4 * u * size, lean, FIRE, 0.7 * a)
		_tongue(Vector2(bx, by), h * 0.4, 2.4 * u * size, lean * 0.5, FIRE_HOT, 0.8 * a)
	_smoke(Vector2(at.x, at.y - 8 * u), t, u, 4, 40.0, 0.45)
	for i in 6:
		var e := clampf(t * (0.7 + _rf() * 0.6), 0.0, 1.0)
		_square(FIRE_HOT if i % 2 == 0 else FIRE, Vector2(at.x + (_rf() - 0.5) * 26 * u + sin(e * 9.0 + i) * 3 * u, at.y - e * 46 * u), 1.8 * u, (1 - e) * f)


func _burst(at: Vector2, t: float, u: float, cols: Array, n := 10, reach := 18.0) -> void:
	if t <= 0.0 or t >= 1.0:
		return
	for i in n:
		var a := _rf() * TAU
		var d := (0.4 + _rf() * 0.8) * reach * u * t
		_square(cols[i % cols.size()], at + Vector2(cos(a) * d, sin(a) * d), u * (2.5 - 1.5 * t), 1.0 - t)


## Heilige Flamme: Licht wie eine Flamme fällt von oben auf den Gegner, unten lecken weißgoldene Zungen um die Füße
func _sacred_flame(p: float, x: float, ground: float, u: float) -> void:
	var f := _fade(p)
	var down := minf(p / 0.3, 1.0)
	var front := ground * (1.0 - (1.0 - down) * (1.0 - down))
	var sway := sin(p * 9.0) * 1.5 * u
	if front < 2.0 * u:
		return
	for col in [[46.0, 26.0, HOLY, 0.28], [24.0, 13.0, HOLY, 0.6], [9.0, 5.0, WARM_WHITE, 0.8]]:
		var wt: float = col[0] * u
		var wl: float = col[1] * u
		var c: Color = col[2]
		var a: float = col[3]
		var pts := PackedVector2Array()
		for i in 7:
			var t := i / 6.0
			pts.append(Vector2(x - wt / 2, 0).lerp(Vector2(x + sway - wl / 2, front), t))
		for i in 7:
			var t := 1.0 - i / 6.0
			pts.append(Vector2(x + wt / 2, 0).lerp(Vector2(x + sway + wl / 2, front), t))
		_vgrad(pts, 0.0, front + 6 * u, [_a(c, 0.0), _a(c, a * 0.5 * f), _a(c, a * f), _a(c, 0.0)])
	if down < 1.0:
		return
	var burn := clampf((p - 0.28) / 0.2, 0.0, 1.0) * f
	_glow(Vector2(x, ground), 40 * u, [_a(HOLY, 0.55 * burn), _a(HOLY, 0.18 * burn), NONE], 0.25)
	for i in 11:
		var bx := x + (i - 5) * 4.2 * u + (_rf() - 0.5) * 3 * u
		var edge := 1.0 - absf(i - 5) / 6.0
		var h := (16 + 30 * edge + _rf() * 12) * u * burn * (0.75 + 0.25 * sin(p * 38.0 + i * 1.9))
		var w := (6 + 4 * edge) * u
		var lean := sin(p * 21.0 + i) * 3 * u + (i - 5) * 0.8 * u
		var b := Vector2(bx, ground + 2 * u)
		_tongue(b, h, w, lean, HOLY, 0.75 * burn, [_a(HOLY, 0.0), _a(HOLY, 0.75 * burn), _a(HOLY, 0.45 * burn)])
		_tongue(b, h * 0.55, w * 0.55, lean, WARM_WHITE, 0.8 * burn, [_a(WARM_WHITE, 0.0), _a(WARM_WHITE, 0.8 * burn), _a(WARM_WHITE, 0.48 * burn)])
	# Glut steigt weich und golden auf (Helfer Runde 2: weiße Splitter „wie Eis“)
	for i in 9:
		var t := clampf((p - 0.3) / 0.7 * (0.6 + _rf() * 0.6) + _rf() * 0.2, 0.0, 1.0)
		var ex := x + (_rf() - 0.5) * 40 * u + sin(t * 8.0 + i) * 3 * u
		_glow(Vector2(ex, ground - t * 70 * u), 3.2 * u, [_a(GOLD_LIGHT if i % 2 == 0 else HOLY, 0.85 * (1 - t) * f), _a(HOLY, 0.0)])


## Feuerpfeil: ein zischender Funke, weißglühend an der Spitze, mit Flammenschweif und dunklem Rauch; zerplatzt am Gegner
func _fire_bolt(p: float, from: Vector2, to: Vector2, u: float) -> void:
	var travel := 0.42
	var bend := (_rf() - 0.5) * 50 * u
	var t := minf(p / travel, 1.0)
	for k in range(1, 10):
		var tt := t - k * 0.06
		if tt <= 0.0:
			continue
		var age := clampf((p - tt * travel) / 0.5, 0.0, 1.0)
		var c := _arc(from, to, tt, bend) + Vector2(0, -age * 8 * u)
		_glow(c, (5 + 9 * age) * u, [_a(SMOKE, 0.5 * (1 - age)), _a(SMOKE, 0.0)])
	if p < travel:
		var head := _arc(from, to, t, bend)
		var back := _arc(from, to, maxf(t - 0.05, 0.0), bend)
		var dir := (head - back).normalized() if head.distance_to(back) > 0.01 else Vector2.RIGHT
		for k in range(11, -1, -1):
			var d := k * 3.6 * u
			var wob := sin(p * 60.0 + k * 1.7) * 1.2 * u
			var c := Vector2(head.x - dir.x * d - dir.y * wob, head.y - dir.y * d + dir.x * wob)
			var col := FIRE_HOT if k == 0 else (FIRE if k < 4 else FIRE_DARK)
			ci.draw_circle(c, (8.0 - k * 0.6) * u, _a(col, 1.0 - k * 0.075))
		_glow(head, 24 * u, [_a(FIRE, 0.4), NONE])
		ci.draw_circle(head, 3.2 * u, _a(WHITE, 0.9))
		for i in 5:
			var st := maxf(t - _rf() * 0.3, 0.0)
			var sp := _arc(from, to, st, bend) + Vector2((_rf() - 0.5) * 8 * u, (t - st) * 30 * u)
			_square(FIRE_HOT, sp, 1.6 * u, 1.0 - (t - st) * 3.0)
	else:
		var s := (p - travel) / (1 - travel)
		var flash := clampf(1 - s / 0.3, 0.0, 1.0)
		if flash > 0.0:
			_glow(to, 24 * u, [_a(WHITE, 0.8 * flash), _a(FIRE_HOT, 0.5 * flash), _a(FIRE, 0.2 * flash), NONE])
		_burst(to, s / 0.5, u, [FIRE_HOT, FIRE, FIRE_DARK], 10, 20.0)
		_clinging_fire(to, s, u, 1.35)


## Magisches Geschoss: drei schmale Splitter kalten violetten Lichts, jeder auf eigener Bahn, nacheinander
func _force_dart(sd: int, p: float, i: int, from: Vector2, to0: Vector2, u: float) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = sd + i * 977
	var to := Vector2(to0.x + (r.randf() - 0.5) * 16 * u, to0.y + (r.randf() - 0.5) * 20 * u)
	var delay := i * 0.13
	var travel := 0.42
	var t := clampf((p - delay) / travel, 0.0, 1.0)
	var bend := (1 if i % 2 == 0 else -1) * (40 + r.randf() * 50) * u
	if t > 0.0 and t < 1.0:
		var prev := _arc(from, to, maxf(t - 0.22, 0.0), bend)
		for k in range(1, 9):
			var pt := _arc(from, to, maxf(t - 0.22 + k * 0.0275, 0.0), bend)
			ci.draw_line(prev, pt, _a(FORCE, 0.06 * k), (0.6 + 0.35 * k) * u, true)
			prev = pt
		var head := _arc(from, to, t, bend)
		var back := _arc(from, to, maxf(t - 0.07, 0.0), bend)
		_glow(head, 12 * u, [_a(FORCE, 0.4), NONE])
		ci.draw_line(back, head, FORCE, 3.2 * u, true)
		ci.draw_line(back.lerp(head, 0.4), head, FORCE_CORE, 1.4 * u, true)
	var s := (p - delay - travel) / 0.32
	if s > 0.0 and s < 1.0:
		_glow(to, 14 * u, [_a(FORCE_CORE, 0.85 * (1 - s)), _a(FORCE, 0.4 * (1 - s)), NONE])
		for k in 6:
			var a := k * PI / 3 + r.randf() * 0.5
			var ln := (6 + 12 * s) * u
			ci.draw_line(to + Vector2(cos(a), sin(a)) * ln * 0.4, to + Vector2(cos(a), sin(a)) * ln, _a(FORCE_CORE, 1 - s), 1.2 * u, true)


## Sengender Strahl: ein Feuerstrahl, flackernd in der eigenen Hitze, außen dunkelrot, im Kern weißgelb; das Ziel glimmt
func _scorching_ray(p: float, from0: Vector2, to: Vector2, u: float) -> void:
	var from := Vector2(from0.x, from0.y + (_rf() - 0.5) * 4 * u)
	var reach := minf(p / 0.22, 1.0)
	var life := 1.0 if p < 0.5 else (1 - p) / 0.5
	var end := from.lerp(to, reach)
	var dv := end - from
	var ln := maxf(dv.length(), 1.0)
	var nrm := Vector2(-dv.y / ln, dv.x / ln)
	for band in [[11.0, FIRE_DARK, 0.25, 2.5, 0.0], [6.0, FIRE, 0.65, 1.6, 1.3], [2.4, FIRE_HOT, 0.95, 0.8, 2.1], [1.0, Color("ffe8c0"), 0.18, 4.0, 4.0]]:
		var prev := from
		for k in range(1, 15):
			var f := k / 14.0
			var w: float = sin(f * 19.0 + p * 70.0 + float(band[4])) * float(band[3]) * u * sin(f * PI)
			var pt := from + dv * f + nrm * w
			ci.draw_line(prev, pt, _a(band[1], band[2] * life), band[0] * u * (0.6 + 0.4 * f), true)
			prev = pt
	if reach >= 1.0:
		var s := (p - 0.22) / 0.78
		var flash := clampf(1 - s / 0.25, 0.0, 1.0)
		if flash > 0.0:
			_glow(to, 18 * u, [_a(FIRE_HOT, 0.7 * flash), _a(FIRE, 0.25 * flash), NONE])
		_clinging_fire(to, s, u, 0.7)


## Feuerball: eine wälzende Masse, am Rand dunkel, innen weißglühend; am Ziel ein Blitz, Flammenballen, der Boden brennt
func _fireball(p: float, from: Vector2, to: Vector2, ground: float, u: float) -> void:
	var travel := 0.42
	var bend := (_rf() - 0.5) * 60 * u
	var t := minf(p / travel, 1.0)
	for k in range(1, 11):
		var tt := t - k * 0.055
		if tt <= 0.0:
			continue
		var age := clampf((p - tt * travel) / 0.55, 0.0, 1.0)
		var c := _arc(from, to, tt, bend) + Vector2(0, -age * 12 * u)
		_glow(c, (8 + 12 * age) * u, [_a(SMOKE, 0.55 * (1 - age)), _a(SMOKE, 0.0)])
	if p < travel:
		var head := _arc(from, to, t, bend)
		_glow(head, 34 * u, [_a(FIRE, 0.45), _a(FIRE_DARK, 0.15), NONE])
		for k in 16:
			var a := _rf() * TAU + p * (8.0 + k)
			var d := (4 + _rf() * 10) * u
			var col := FIRE_DARK if k < 7 else (FIRE if k < 13 else FIRE_HOT)
			_glow(head + Vector2(cos(a), sin(a)) * d, (6.5 + _rf() * 6.0) * u, [col, _a(col, 0.0)])
		_glow(head, 6 * u, [_a(WHITE, 0.85), _a(FIRE_HOT, 0.0)])
		for i in 6:
			var st := maxf(t - _rf() * 0.25, 0.0)
			var sp := _arc(from, to, st, bend) + Vector2((_rf() - 0.5) * 12 * u, (t - st) * 40 * u)
			_square(FIRE_HOT if i % 2 == 0 else FIRE, sp, 1.8 * u, 1.0 - (t - st) * 3.0)
		return
	var s := (p - travel) / (1 - travel)
	var flash := clampf(1 - s / 0.18, 0.0, 1.0)
	if flash > 0.0:
		_glow(to, 70 * u, [_a(WHITE, 0.85 * flash), _a(FIRE_HOT, 0.6 * flash), _a(FIRE, 0.25 * flash), NONE])
	_clinging_fire(Vector2(to.x, ground), s, u, 1.9)
	var ausw := 1.0 - (1.0 - s) * (1.0 - s)
	for k in 30:
		var a := _rf() * TAU
		var d := (6 + _rf() * 50) * u * ausw
		var c := to + Vector2(cos(a) * d, sin(a) * d * 0.75 - s * 18 * u)
		var rad := (14 + _rf() * 14) * u * (0.45 + 0.75 * ausw)
		var heat := clampf(1.0 - s * (1.0 + _rf() * 0.7) + (1.0 - d / (56 * u)) * 0.25, 0.0, 1.0)
		# ohne Rauchballen (Helfer Lauf 126 und Runde 2: zwei dunkle runde Flecken „wie Augen“); Rauch steigt in _smoke darüber auf
		var col := FIRE_HOT if heat > 0.7 else (FIRE if heat > 0.4 else FIRE_DARK)
		var a0 := (1 - s * 0.7) * (1.0 if heat > 0.15 else 0.4)
		_glow(c, rad, [_a(col, a0), _a(col, a0 * 0.4), _a(col, 0.0)])
	_smoke(to + Vector2(0, -10 * u), (s - 0.25) / 0.75, u, 6, 70.0, 0.55)
	_burst(to, s, u, [FIRE_HOT, FIRE, FIRE_DARK], 16, 50.0)


## Heilung: warmes Licht sammelt sich im Körper, Funken von ringsum, ein Schein schwillt in der Brust und vergeht. Helfer
## Runde 2 (Heilung ohne erkennbaren Wirkenden): erst leuchten die Hände des Wirkenden, von dort zieht das Licht zum Ziel
func _mending(p: float, src: Vector2, chest: Vector2, u: float, c: Color, core: Color) -> void:
	var f := _fade(p)
	var hand := sin(clampf(p / 0.5, 0.0, 1.0) * PI)
	_glow(src, 22 * u, [_a(core, 0.7 * hand), _a(c, 0.3 * hand), NONE])
	if src.distance_to(chest) > 8 * u:
		for i in 10:
			var t := clampf((p - 0.05 - i * 0.025) / 0.35, 0.0, 1.0)
			if t <= 0.0 or t >= 1.0:
				continue
			var q := _arc(src, chest, t, (i % 3 - 1) * 14 * u)
			_glow(q, 4.2 * u, [_a(core, 0.9 * sin(t * PI)), _a(c, 0.0)])
	var swell := sin(clampf(p, 0.0, 1.0) * PI)
	_glow(chest, 46 * u, [_a(core, 0.55 * swell), _a(c, 0.3 * swell), NONE])
	_glow(chest, 26 * u, [_a(c, 0.22 * swell), NONE], 60.0 / 26.0)
	for i in 24:
		var a := _rf() * TAU
		var d0 := (30 + _rf() * 22) * u
		var t := clampf((p - _rf() * 0.35) / 0.6, 0.0, 1.0)
		if t <= 0.0 or t >= 1.0:
			continue
		var d := d0 * (1 - t * t)
		_glow(Vector2(chest.x + cos(a) * d * 0.7, chest.y + sin(a) * d - t * 6 * u), 4.6 * u, [_a(core, 0.95 * f), _a(c, 0.0)])


## Segen: weiches goldenes Licht fällt von oben auf den Helden, Staub darin, kurz glüht das Sonnenzeichen an der Brust
func _blessing(p: float, chest: Vector2, ground: float, u: float) -> void:
	var f := _fade(p)
	var down := minf(p / 0.3, 1.0)
	var front := ground * (1.0 - (1.0 - down) * (1.0 - down))
	var x := chest.x
	if front < 2.0 * u:
		return
	# drei Kegel ineinander, so laufen die Ränder weich aus (Helfer Runde 2: harte gerade Kanten, teilte den Wolf)
	for wk in [1.0, 0.72, 0.45]:
		var pts := PackedVector2Array()
		for i in 7:
			pts.append(Vector2(x - 14 * u * wk, 0).lerp(Vector2(x - 32 * u * wk, front), i / 6.0))
		for i in 7:
			pts.append(Vector2(x + 14 * u * wk, 0).lerp(Vector2(x + 32 * u * wk, front), 1.0 - i / 6.0))
		_vgrad(pts, 0.0, front + 8 * u, [_a(GOLD_LIGHT, 0.0), _a(GOLD_LIGHT, 0.06 * f), _a(GOLD_LIGHT, 0.11 * f), _a(GOLD_LIGHT, 0.0)])
	for i in 14:
		var t := fmod(p * (0.7 + _rf() * 0.5) + _rf() * 0.3, 1.0)
		var dx := (_rf() - 0.5) * 44 * u + sin(t * 6.0 + i) * 3 * u
		_square(GOLD_LIGHT, Vector2(x + dx * (0.5 + 0.5 * t), front * (0.2 + 0.8 * t)), 1.6 * u, f * 0.8 * sin(t * PI))
	var zeichen := clampf((p - 0.3) / 0.25, 0.0, 1.0) * (1.0 - clampf((p - 0.65) / 0.35, 0.0, 1.0))
	# nur ein Schein in der Brust (Helfer Runde 2: das gezeichnete Sonnenzeichen wirkte wie ein Bedien-Symbol)
	if zeichen > 0.0:
		var c := Vector2(x, chest.y + 4 * u)
		_glow(c, 18 * u, [_a(WARM_WHITE, 0.7 * zeichen), _a(GOLD_LIGHT, 0.3 * zeichen), NONE])


## Pfeil (Rückläufer t55, t64): dünner dunkler Schaft, kleine Spitze, graubraune Federn, im Bogen geworfen, die Spitze voran
func _arrow(p: float, from: Vector2, hit: Vector2, u: float) -> void:
	var t := minf(p / 0.6, 1.0)
	if p >= 0.6:
		_arrow_lands(p, from, hit, u)
		return
	var rise := hit.distance_to(from) * ARROW_RISE
	var fly := func(x: float) -> Vector2:
		var c := clampf(x, 0.0, 1.0)
		return from.lerp(hit, c) - Vector2(0, 4 * rise * c * (1 - c) + sin(c * PI) * over)
	var head: Vector2 = fly.call(t)
	var ahead := Vector2(hit.x - from.x, hit.y - from.y - 4 * rise * (1 - 2 * t) - PI * cos(t * PI) * over)
	var d := ahead.normalized() if ahead.length() > 0.001 else Vector2.RIGHT
	var n := Vector2(-d.y, d.x)
	var tail := head - d * (15 * u)
	for k in 4:
		ci.draw_line(fly.call(t - 0.06 * (k + 1)), tail if k == 0 else fly.call(t - 0.06 * k), Color(1, 1, 1, 0.3 - 0.06 * k), 1.2 * u, true)     # Spur kräftiger: Pfeil „praktisch unsichtbar“ (Helfer Lauf 126)
	# Schaft hell und kräftiger (Helfer Runde 2: 3 px brauner Strich auf braunem Weg)
	ci.draw_line(tail, head - d * (2.5 * u), Color("b89a70"), 1.3 * u, true)
	var b := head - d * (3.5 * u)
	ci.draw_colored_polygon(PackedVector2Array([head, b + n * 1.5 * u, b - n * 1.5 * u]), Color("c8ccd0"))
	for side in [1.0, -1.0]:
		ci.draw_line(tail + d * (2.5 * u), tail - d * (0.5 * u) + n * (side * 1.4 * u), Color("a08c6c", 0.75), 0.8 * u, true)


## Einschlag (Helfer Runde 2: Pfeil ohne Einschlag): er steckt kurz, wo er traf, ein Ruck Splitter und Staub, dann vergeht er
func _arrow_lands(p: float, from: Vector2, hit: Vector2, u: float) -> void:
	var s := (p - 0.6) / 0.4
	var rise := hit.distance_to(from) * ARROW_RISE
	var d := Vector2(hit.x - from.x, hit.y - from.y + 4 * rise + PI * over).normalized()
	var a := 1.0 - clampf((s - 0.5) / 0.5, 0.0, 1.0)
	var tail := hit - d * (12 * u)
	ci.draw_line(tail, hit, _a(Color("b89a70"), a), 1.3 * u, true)
	for side in [1.0, -1.0]:
		ci.draw_line(tail + d * (2.5 * u), tail - d * (0.5 * u) + Vector2(-d.y, d.x) * (side * 1.4 * u), _a(Color("a08c6c"), 0.75 * a), 0.8 * u, true)
	var flash := clampf(1.0 - s / 0.2, 0.0, 1.0)
	if flash > 0.0:
		_glow(hit, 7 * u, [_a(WARM_WHITE, 0.7 * flash), NONE])
	_burst(hit, s / 0.45, u * 0.6, [DUST, Color("c8b08a")], 7, 14.0)


## Ein Effekt bei p (0..1) von source nach target; ground: Boden unter dem Ziel (drawFx)
func draw_fx(kind: String, sd: int, p: float, source: Vector2, target: Vector2, u: float, ground: float, exact := false) -> void:
	rnd.seed = sd
	var hit := Vector2(target.x + (_rf() - 0.5) * 14 * u, target.y + (_rf() - 0.5) * 14 * u)
	if exact:
		hit = target
	match kind:
		"ARROW":
			_arrow(p, source, hit, u)
		"FIRE_BOLT":
			_fire_bolt(p, source, hit, u)
		"FIREBALL":
			_fireball(p, source, hit, ground, u)
		"MISSILES":
			var base := rnd.randi()
			for i in 3:
				_force_dart(base, p, i, source, hit, u)
		"RAYS":
			_scorching_ray(p, source, hit, u)
		"SACRED_FLAME":
			_sacred_flame(p, hit.x, ground, u)
		"HEAL":
			_mending(p, source, target, u, HEAL_LIGHT, WHITE)
		"BLESS":
			_blessing(p, target, ground, u)


## Wie BattleFxLayer: trifft er nicht, fliegt er seitlich am Ziel vorbei (wide); eine Flamme von oben schlägt dort ein, wo
## der Gegner eben stand, während er beiseite springt (on_spot)
func draw(kind: String, sd: int, p: float, source: Vector2, target: Vector2, u: float, ground: float, missed: bool) -> void:
	if not missed:
		draw_fx(kind, sd, p, source, target, u, ground)
		return
	if kind == "SACRED_FLAME":
		var away := -1.0 if sd % 2 == 0 else 1.0
		draw_fx(kind, sd, p, source, Vector2(target.x + away * 30 * u, target.y), u, ground)
		return
	if not (kind in FLYING):
		return
	var dv := target - source
	var ln := maxf(dv.length(), 1.0)
	var side := 1.0 if sd % 2 == 0 else -1.0
	var by := Vector2(target.x + dv.x / ln * 34 * u - dv.y / ln * side * 30 * u, target.y + dv.y / ln * 34 * u + dv.x / ln * side * 30 * u)
	# Helfer Runde 2 (Feuerpfeil daneben brannte in der Luft): was vorbeifliegt, schlägt hinter dem Ziel in den Boden
	var floor_y := ground + (by.y - target.y)
	if kind != "MISSILES":
		by.y = floor_y - 2 * u
	draw_fx(kind, sd, p, source, by, u * 0.8, floor_y, kind != "MISSILES")
