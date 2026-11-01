class_name Reiterzeichen
extends Control
# 399.1 TabSign wie alt (MenuTabs.kt glyph, 60j): die Reiter des Menues als gezeichnetes Zeichen, Linien in Gold auf Schwarz,
# nie gefuellt, auf 24 mal 24 Einheiten; der Name des gewaehlten Reiters steht gross darueber (326). abzeichen: kleiner Stern oben
# rechts (Punkte zu verteilen). Arten: held, tasche, ausruestung, karte, chronik, system, test.

var art := "held"
var farbe := Stil.TEXT
var abzeichen := false

func _init(a: String, c: Color, stern := false) -> void:
	art = a; farbe = c; abzeichen = stern
	custom_minimum_size = Vector2(30, 30) * AktionsKnopf.DP
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var u := minf(size.x, size.y) / 24.0
	var o := func(x: float, y: float) -> Vector2: return Vector2(x, y) * u
	var w := 1.6 * u; var d := 1.1 * u
	var c := farbe
	var linie := func(pkt: Array, breite: float, zu := false) -> void:
		var p := PackedVector2Array()
		for q in pkt: p.append(o.call(q[0], q[1]))
		if zu: p.append(p[0])
		draw_polyline(p, c, breite, true)
	match art:
		"held":   # ein behelmter Kopf ueber den Schultern
			draw_arc(o.call(12, 7.75), 4.5 * u, PI, TAU, 16, c, w, true)
			linie.call([[7.5, 7.8], [7.5, 11.5]], w); linie.call([[16.5, 7.8], [16.5, 11.5]], w)
			linie.call([[7.5, 8.2], [16.5, 8.2]], d); linie.call([[12, 8.2], [12, 12]], d)
			linie.call([[3, 22], [4, 17], [8.5, 14.5], [15.5, 14.5], [20, 17], [21, 22]], w)
		"tasche":   # Umhaengetasche: Koerper mit runden Ecken, Klappe mit Schnalle, Riemen (wie die Leiste)
			var ecke := PackedVector2Array()
			for m in [[Vector2(17.5, 18.5), 0.0], [Vector2(6.5, 18.5), 0.5], [Vector2(6.5, 11.5), 1.0], [Vector2(17.5, 11.5), 1.5]]:
				for i in 7: ecke.append((m[0] + Vector2.from_angle((m[1] + i / 12.0) * PI) * 2.5) * u)
			ecke.append(ecke[0])
			draw_polyline(ecke, c, w, true)
			linie.call([[4.5, 10], [12, 15], [19.5, 10]], w)
			draw_rect(Rect2(o.call(11, 14.5), Vector2(2, 2.5) * u), c, false, d)
			draw_arc(o.call(12, 8.5), 5 * u, PI, TAU, 16, c, d, true)
		"ausruestung":   # ein Dreieckschild, ein Schwert darueber
			# Chef 29.10., 11:10 (Archiv „399.1, Menü Ausrüstung“): Schwert klarer durch den Schild, wirkte verschoben (alt lagen
			# Parierstange und Griff gut eine Einheit neben der Klinge); jetzt Klinge, Parierstange und Griff auf einer Achse
			linie.call([[5, 5], [15, 5], [15, 11], [14, 15], [10, 19], [6, 15], [5, 11]], w, true)
			linie.call([[19.5, 3.5], [10.5, 17]], w); linie.call([[7.84, 15.22], [13.16, 18.78]], w); linie.call([[10.5, 17], [8.5, 20]], w)
			draw_circle(o.call(8.06, 20.66), 0.9 * u, c)
		"karte":   # dreifach gefaltet, ein gepunkteter Weg und ein Kreuz
			linie.call([[3, 6], [9, 4], [15, 6], [21, 4], [21, 18], [15, 20], [9, 18], [3, 20]], w, true)
			linie.call([[9, 4], [9, 18]], d); linie.call([[15, 6], [15, 20]], d)
			for p in [[5.5, 15.5], [7.5, 13.5], [10.5, 12.8], [13, 11.5], [15.5, 10.5]]: draw_circle(o.call(p[0], p[1]), 0.7 * u, c)
			linie.call([[17, 7.5], [19.5, 10]], d); linie.call([[19.5, 7.5], [17, 10]], d)
		"chronik":   # 64: eine Rolle, an beiden Enden gerollt, drei Zeilen Schrift
			for y in [3.5, 17.0]:
				var r := StyleBoxFlat.new()
				r.draw_center = false; r.border_color = c
				r.set_border_width_all(maxi(1, int(round(w)))); r.set_corner_radius_all(int(round(1.7 * u))); r.anti_aliasing = true
				draw_style_box(r, Rect2(o.call(4, y), Vector2(16, 3.5) * u))
			linie.call([[6, 7], [6, 17]], w); linie.call([[18, 7], [18, 17]], w)
			for y in [9.5, 12.0, 14.5]: linie.call([[8.5, y], [12.5 if y == 14.5 else 15.5, y]], d)
		"system":   # eine Sanduhr: die Zeit des Spiels, Speichern und Laden
			linie.call([[5, 3.5], [19, 3.5]], w); linie.call([[5, 20.5], [19, 20.5]], w)
			linie.call([[7, 3.5], [7, 6], [11, 12], [7, 18], [7, 20.5]], w)
			linie.call([[17, 3.5], [17, 6], [13, 12], [17, 18], [17, 20.5]], w)
			draw_colored_polygon(PackedVector2Array([o.call(9, 19.5), o.call(12, 16), o.call(15, 19.5)]), c)
		"test":   # 399.1 wie alt (TabSign.TEST): ein Kolben mit engem Hals
			linie.call([[10, 3.5], [10, 9.5], [4.5, 19], [5.5, 21], [18.5, 21], [19.5, 19], [14, 9.5], [14, 3.5]], w)
			linie.call([[8.5, 3.5], [15.5, 3.5]], w); linie.call([[7, 15], [17, 15]], d)
	if abzeichen:   # Punkte zu verteilen: ein kleiner Stern, wie das ★ hinter dem Wort war
		var s := PackedVector2Array()
		for i in 10:
			var a := PI / 2 + i * PI / 5; var r := 3.2 if i % 2 == 0 else 1.3
			s.append(Vector2(21 + r * cos(a), 3.5 - r * sin(a)) * u)
		draw_colored_polygon(s, Stil.BRIGHT)

# TabButton: 46 dp hoch, gewaehlt erhaben mit hellem Rand, sonst schwarz mit duennem Rand; nur das Zeichen
static func knopf(a: String, wort: String, was: Callable, gewaehlt: bool, stern := false) -> Button:
	var b := Erschaffung.knopf("", was, gewaehlt)
	b.custom_minimum_size = Vector2(0, 46 * AktionsKnopf.DP)
	b.tooltip_text = wort
	var z := Reiterzeichen.new(a, Stil.BRIGHT if gewaehlt else Stil.GOLD, stern)
	z.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	z.position = -z.custom_minimum_size * 0.5
	b.add_child(z)
	return b
