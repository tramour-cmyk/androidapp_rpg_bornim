class_name AktionsKnopf
extends Button
# 348.6 (Befund 7): Aktionsknopf wie das alte Spiel (WorldScreen.ActionButton, ActionSigns.actionGlyph, 326): rund, schwarz
# 70 %, duenner Goldrand, das Zeichen in Goldlinien auf einem Raster von 24, nie gefuellt ausser Punkten.

const RAND := Color(0.710, 0.604, 0.416)       # Veil.gold 0xB59A6A
const HELL := Color(0.851, 0.737, 0.510)       # Veil.bright 0xD9BC82
const DP := 1080.0 / 411.0                     # alt: dp auf einem Handy mit 411 dp Breite

var zeichen := ""                              # ENTER, READ, LOOK, TALK, OPEN (ActionKind); ACT, NEXT, RUN (ActionSign)
var gedrueckt := false
var matt := false                              # 399.1 alt dim: Rand Veil.rim, Zeichen Gold zu 45 % (nichts zu tun, Rennen aus)

func _init(groesse := 76.0) -> void:
	custom_minimum_size = Vector2(groesse, groesse) * DP
	size = custom_minimum_size
	flat = true
	focus_mode = Control.FOCUS_NONE
	for z in ["normal", "hover", "pressed", "focus", "disabled"]: add_theme_stylebox_override(z, StyleBoxEmpty.new())
	button_down.connect(func(): gedrueckt = true; queue_redraw())
	button_up.connect(func(): gedrueckt = false; queue_redraw())

func setze(z: String) -> void:
	zeichen = z
	queue_redraw()

func _draw() -> void:
	var r := size.x / 2
	var m := size / 2
	draw_circle(m, r, Color(0.090, 0.078, 0.059, 0.85) if gedrueckt else Color(0, 0, 0, 0.7))   # Veil.raised beim Druecken
	draw_arc(m, r - 0.75 * DP, 0, TAU, 64, Stil.RIM if matt else (HELL if gedrueckt else RAND), 1.5 * DP, true)
	# Zeichen auf halber Knopfgroesse, Raster 24
	var s := size.x * 0.5
	var u := s / 24.0
	var o := m - Vector2(s, s) / 2
	var c := Color(RAND, 0.45) if matt else HELL
	var dick := 1.6 * u
	var duenn := 1.1 * u
	var P := func(x: float, y: float) -> Vector2: return o + Vector2(x, y) * u
	var l := func(x1: float, y1: float, x2: float, y2: float, w: float = dick) -> void: draw_line(P.call(x1, y1), P.call(x2, y2), c, w, true)
	var punkt := func(x: float, y: float, rr: float) -> void: draw_circle(P.call(x, y), rr * u, c)
	var zug := func(pts: Array, zu: bool = false, w: float = dick) -> void:
		var q := PackedVector2Array()
		for p in pts: q.append(P.call(p.x, p.y))
		if zu: q.append(q[0])
		draw_polyline(q, c, w, true)
	match zeichen:
		"ENTER":
			# ein Rundbogentor, die Tuer weit offen
			var bogen: Array = [Vector2(5, 21), Vector2(5, 10)]
			for k in range(13): bogen.append(Vector2(12 - 7 * cos(PI * k / 12.0), 10 - 7 * sin(PI * k / 12.0)))
			bogen.append(Vector2(19, 21))
			zug.call(bogen)
			l.call(3, 21, 21, 21)
			zug.call([Vector2(5, 10.5), Vector2(13, 14), Vector2(13, 21)])
			punkt.call(10.5, 17, 0.9)
		"READ":
			# ein Anschlagbrett mit Dach auf zwei Pfosten, zwei Zeilen Schrift
			zug.call([Vector2(3.5, 4), Vector2(20.5, 4), Vector2(20.5, 14), Vector2(3.5, 14)], true)
			zug.call([Vector2(2.5, 4), Vector2(12, 1.5), Vector2(21.5, 4)])
			l.call(8, 14, 8, 21); l.call(16, 14, 16, 21)
			l.call(7, 7.5, 17, 7.5); l.call(7, 10.5, 14, 10.5)
		"LOOK":
			# ein Auge: die Lider, die Iris, die Pupille
			var lid: Array = []
			for k in range(17):
				var t := k / 16.0
				lid.append(Vector2(3 + 18 * t, 12 - 17 * 2 * t * (1 - t)))     # quadratisch durch (12, 3,5)
			for k in range(1, 17):
				var t := 1.0 - k / 16.0
				lid.append(Vector2(3 + 18 * t, 12 + 17 * 2 * t * (1 - t)))
			zug.call(lid)
			draw_arc(P.call(12, 12), 3.2 * u, 0, TAU, 32, c, dick, true)
			punkt.call(12, 12, 1.2)
		"TALK":
			# eine Sprechblase, der Schwanz nach links unten, drei Punkte
			var b := Rect2(P.call(3, 4), Vector2(18, 12) * u)
			var sb := StyleBoxFlat.new()
			sb.draw_center = false; sb.border_color = c; sb.set_border_width_all(int(round(dick))); sb.set_corner_radius_all(int(3 * u)); sb.anti_aliasing = true
			draw_style_box(sb, b)
			zug.call([Vector2(11, 16), Vector2(7, 20.5), Vector2(8, 16)])
			for x in [8.0, 12.0, 16.0]: punkt.call(x, 10, 0.9)
		"REST":
			# 390 (ActionSigns.REST): eine Flamme ueber zwei gekreuzten Scheiten
			var qb := func(p0: Vector2, p1: Vector2, p2: Vector2) -> Array:
				var pts: Array = []
				for i in range(1, 13):
					var t := i / 12.0
					pts.append(p0.lerp(p1, t).lerp(p1.lerp(p2, t), t))
				return pts
			var flamme: Array = [Vector2(12, 3)]
			flamme.append_array(qb.call(Vector2(12, 3), Vector2(18, 10), Vector2(12, 15.5)))
			flamme.append_array(qb.call(Vector2(12, 15.5), Vector2(6, 10), Vector2(12, 3)))
			zug.call(flamme)
			var kern: Array = [Vector2(12, 8.5)]
			kern.append_array(qb.call(Vector2(12, 8.5), Vector2(14.5, 12), Vector2(12, 14)))
			kern.append_array(qb.call(Vector2(12, 14), Vector2(9.5, 12), Vector2(12, 8.5)))
			zug.call(kern, false, duenn)
			l.call(5, 20.5, 19, 16.5); l.call(5, 16.5, 19, 20.5)
		"OPEN":
			# eine Truhe: Kasten, gewoelbter Deckel, Baender, Schloss
			zug.call([Vector2(3, 11.5), Vector2(21, 11.5), Vector2(21, 20.5), Vector2(3, 20.5)], true)
			var d: Array = []
			for k in range(13): d.append(Vector2(12 - 9 * cos(PI * k / 12.0), 11.5 - 7 * sin(PI * k / 12.0)))
			zug.call(d)
			l.call(7.5, 5.6, 7.5, 11.5, duenn); l.call(16.5, 5.6, 16.5, 11.5, duenn)
			zug.call([Vector2(10, 10), Vector2(14, 10), Vector2(14, 15), Vector2(10, 15)], true)
			punkt.call(12, 12.6, 0.9)
		"ACT":
			# 399.1 (ActionSign.ACT, Klassisch): ein Funke, vier Spitzen
			zug.call([Vector2(12, 3), Vector2(14, 10), Vector2(21, 12), Vector2(14, 14), Vector2(12, 21), Vector2(10, 14), Vector2(3, 12), Vector2(10, 10)], true)
		"NEXT":
			# ActionSign.NEXT: zwei Winkel nach rechts
			zug.call([Vector2(6, 6), Vector2(12, 12), Vector2(6, 18)])
			zug.call([Vector2(12, 6), Vector2(18, 12), Vector2(12, 18)])
		"RUN":
			# ActionSign.RUN: ein Stiefel, Schaft und Sohle, drei Striche Tempo dahinter
			var stiefel: Array = [Vector2(10, 3), Vector2(16, 3), Vector2(16, 11.5)]
			for i in range(1, 9):
				var t := i / 8.0
				stiefel.append(Vector2(16, 11.5).lerp(Vector2(21, 12.5), t).lerp(Vector2(21, 12.5).lerp(Vector2(21.5, 17), t), t))
			stiefel.append_array([Vector2(21.5, 19.5), Vector2(10, 19.5)])
			for i in range(1, 9):
				var t := i / 8.0
				stiefel.append(Vector2(10, 19.5).lerp(Vector2(8.5, 19), t).lerp(Vector2(8.5, 19).lerp(Vector2(9, 16.5), t), t))
			zug.call(stiefel, true)
			l.call(10, 6.5, 16, 6.5, duenn); l.call(9.5, 17, 21.5, 17, duenn)
			l.call(2.5, 8, 6.5, 8); l.call(1.5, 12, 6.5, 12); l.call(2.5, 16, 6, 16)
