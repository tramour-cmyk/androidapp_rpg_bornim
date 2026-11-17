class_name Rastzeichen
extends Control
# 549: Zeichen des Rastfensters nach DESIGN-STIL „Zeichen“ (Raster 24 × 24, Linie 1,6, fein 1,1, runde Enden, nie gefüllt ausser Punkten):
# REST (Flamme über gekreuzten Scheiten, wie aktionsknopf.gd), MOON (Sichel), CLOCK (Uhr wie zeichenknopf.gd), NEXT (zwei Winkel),
# BED (Bett: Zimmer), MUG (Krug: Met), MEAT (Keule: Fleisch verkaufen, 557), COIN (Münze), SCHENKE (Wirtshausschild: Rast an der Theke)

var art := "REST"
var farbe := Stil.GOLD

static func neu(art_: String, dp: float, farbe_: Color) -> Rastzeichen:
	var z := Rastzeichen.new()
	z.art = art_
	z.farbe = farbe_
	z.custom_minimum_size = Vector2(dp, dp) * AktionsKnopf.DP
	z.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return z

func _draw() -> void:
	var u := size.x / 24.0
	var dick := maxf(1.2 * AktionsKnopf.DP, 1.6 * u)
	var duenn := maxf(1.2 * AktionsKnopf.DP, 1.1 * u)
	var c := farbe
	var P := func(x: float, y: float) -> Vector2: return Vector2(x, y) * u
	var l := func(x1: float, y1: float, x2: float, y2: float, w := dick) -> void: draw_line(P.call(x1, y1), P.call(x2, y2), c, w, true)
	var zug := func(pkt: Array, zu := false, w := dick) -> void:
		var q := PackedVector2Array()
		for p in pkt: q.append(P.call(p.x, p.y))
		if zu: q.append(q[0])
		draw_polyline(q, c, w, true)
	var qb := func(p0: Vector2, p1: Vector2, p2: Vector2) -> Array:
		var pts: Array = []
		for i in range(1, 13):
			var t := i / 12.0
			pts.append(p0.lerp(p1, t).lerp(p1.lerp(p2, t), t))
		return pts
	match art:
		"REST":
			var flamme: Array = [Vector2(12, 3)]
			flamme.append_array(qb.call(Vector2(12, 3), Vector2(18, 10), Vector2(12, 15.5)))
			flamme.append_array(qb.call(Vector2(12, 15.5), Vector2(6, 10), Vector2(12, 3)))
			zug.call(flamme)
			var kern: Array = [Vector2(12, 8.5)]
			kern.append_array(qb.call(Vector2(12, 8.5), Vector2(14.5, 12), Vector2(12, 14)))
			kern.append_array(qb.call(Vector2(12, 14), Vector2(9.5, 12), Vector2(12, 8.5)))
			zug.call(kern, false, duenn)
			l.call(5, 20.5, 19, 16.5); l.call(5, 16.5, 19, 20.5)
		"MOON":   # Kreis 12,12 r 8 ohne Kreis 15,5,9,5 r 6,5, nur Umriss: der lange Bogen des einen, der innere des anderen
			var a := Vector2(12, 12); var ra := 8.0
			var b := Vector2(15.5, 9.5); var rb := 6.5
			var d := a.distance_to(b)
			var x := (d * d + ra * ra - rb * rb) / (2.0 * d)
			var h := sqrt(ra * ra - x * x)
			var wa := (b - a).angle(); var ha := atan2(h, x)
			var wb := (a - b).angle(); var hb := atan2(h, d - x)
			draw_arc(P.call(a.x, a.y), ra * u, wa + ha, wa - ha + TAU, 48, c, dick, true)
			draw_arc(P.call(b.x, b.y), rb * u, wb - hb, wb + hb, 32, c, dick, true)
		"CLOCK":
			draw_arc(P.call(12, 12), 9.5 * u, 0, TAU, 48, c, dick, true)
			l.call(12, 12, 12, 6); l.call(12, 12, 16.5, 14.5)
			draw_circle(P.call(12, 12), 1.1 * u, c)
		"NEXT":
			zug.call([Vector2(6, 6), Vector2(12, 12), Vector2(6, 18)])
			zug.call([Vector2(12, 6), Vector2(18, 12), Vector2(12, 18)])
		"BED":   # Kopfteil, Matratze, Kissen, Beine
			l.call(3, 6, 3, 20); l.call(21, 12, 21, 20)
			zug.call([Vector2(3, 14), Vector2(21, 14)]); zug.call([Vector2(3, 17.5), Vector2(21, 17.5)])
			zug.call([Vector2(5.5, 14), Vector2(5.5, 10.5), Vector2(10.5, 10.5), Vector2(10.5, 14)], false, duenn)
		"MUG":   # Krug mit Henkel und Schaum
			zug.call([Vector2(5, 7), Vector2(5, 20.5), Vector2(16, 20.5), Vector2(16, 7)])
			zug.call([Vector2(16, 10), Vector2(19.5, 10), Vector2(19.5, 16.5), Vector2(16, 16.5)])
			zug.call([Vector2(4.5, 7), Vector2(6.5, 4.5), Vector2(9.5, 5.5), Vector2(12, 3.8), Vector2(14.5, 5.5), Vector2(16.5, 7)], false, duenn)
		"PLUS":   # 557: neues Spiel in einen leeren Platz (Kreis mit Kreuz, wie MOON nur Umriss)
			draw_arc(P.call(12, 12), 9.0 * u, 0, TAU, 48, c, duenn, true)
			l.call(12, 7.5, 12, 16.5); l.call(7.5, 12, 16.5, 12)
		"KREUZ":   # 557: Löschen, leise
			l.call(7, 7, 17, 17, duenn); l.call(17, 7, 7, 17, duenn)
		"HAKEN":   # 1020.1: Prüfzeile passt (die Schrift hat kein ✓)
			zug.call([Vector2(6, 12.5), Vector2(10.5, 17), Vector2(18, 7)])
		"SCHENKE":   # 557 Runde 4 (Pruefer 17:12: an der Theke die Flamme vom Lagerfeuer): Wirtshausschild, am Arm haengend, darin ein Krug
			l.call(2.5, 3, 2.5, 9.5); l.call(2.5, 4, 21.5, 4); l.call(2.5, 8.5, 7, 4, duenn)
			l.call(8, 4, 8, 8, duenn); l.call(18, 4, 18, 8, duenn)
			zug.call([Vector2(5.5, 8), Vector2(20.5, 8), Vector2(20.5, 20.5), Vector2(5.5, 20.5)], true)
			zug.call([Vector2(9.5, 11.5), Vector2(9.5, 17.5), Vector2(14.5, 17.5), Vector2(14.5, 11.5)], false, duenn)
			zug.call([Vector2(14.5, 12.8), Vector2(16.8, 12.8), Vector2(16.8, 16), Vector2(14.5, 16)], false, duenn)
		"MEAT":   # 557 (Chef 19:54, Pruefer 19:47: Bild zu „Fleisch verkaufen“ ein Doppelring): Keule, Fleisch schraeg mit Knochen und Knauf
			var fl: Array = [Vector2(13.5, 14.5)]
			fl.append_array(qb.call(Vector2(13.5, 14.5), Vector2(3.0, 16.0), Vector2(5.0, 7.0)))
			fl.append_array(qb.call(Vector2(5.0, 7.0), Vector2(9.0, 2.0), Vector2(15.0, 5.5)))
			fl.append_array(qb.call(Vector2(15.0, 5.5), Vector2(17.5, 9.5), Vector2(13.5, 14.5)))
			zug.call(fl)
			zug.call(qb.call(Vector2(7.5, 8.0), Vector2(9.0, 5.5), Vector2(12.0, 6.0)), false, duenn)   # Glanz der Haut
			l.call(13.5, 14.5, 17.5, 18.5)   # Knochen
			draw_arc(P.call(18.6, 18.0), 1.6 * u, 0, TAU, 20, c, duenn, true)
			draw_arc(P.call(18.0, 19.6), 1.6 * u, 0, TAU, 20, c, duenn, true)
		"COIN":
			draw_arc(P.call(12, 12), 8.5 * u, 0, TAU, 48, c, dick, true)
			draw_arc(P.call(12, 12), 5.5 * u, 0, TAU, 40, c, duenn, true)
