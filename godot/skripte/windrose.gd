class_name Windrose
extends Control
# 348.6 (Chef 25.10., 08:42): Windrose halbtransparent oben, dreht mit der Karte; Tippen dreht zurueck in die
# Nordausrichtung (Standardansicht). Goldlinien wie der Aktionsknopf, vier Spitzen, Norden gefuellt;
# dreht flach mit dem Gierwinkel der Kamera (Helfer: projiziert drehte sie bei 90 Grad nur um 60).

signal zurueck

const GROESSE := 52.0 * AktionsKnopf.DP

var winkel := 0.0                              # Norden auf dem Bildschirm, im Uhrzeigersinn von oben

func _init() -> void:
	custom_minimum_size = Vector2(GROESSE, GROESSE)
	size = custom_minimum_size
	modulate.a = 0.8                             # Helfer: auf hellem Stroh Gold auf Beige zu schwach
	mouse_filter = Control.MOUSE_FILTER_STOP

func richte(w: float) -> void:
	if absf(angle_difference(w, winkel)) < 0.002: return
	winkel = w
	queue_redraw()

func _gui_input(e: InputEvent) -> void:
	if (e is InputEventScreenTouch and not e.pressed) or (e is InputEventMouseButton and not e.pressed):
		zurueck.emit()
		accept_event()

func _draw() -> void:
	var m := size / 2
	var r := size.x / 2
	var dp := AktionsKnopf.DP
	draw_circle(m, r, Color(0, 0, 0, 0.7))
	draw_arc(m, r - 0.75 * dp, 0, TAU, 48, AktionsKnopf.RAND, 1.2 * dp, true)
	var dreh := func(v: Vector2) -> Vector2: return m + v.rotated(winkel)
	# vier Spitzen um die Mitte (Raute je Richtung); Norden lang und gefuellt, die anderen kurz im Umriss
	var breit := r * 0.13
	for k in 4:
		var lang := r * (0.56 if k == 0 else 0.4)
		var w := k * PI / 2
		var p := PackedVector2Array([dreh.call(Vector2(0, -lang).rotated(w)), dreh.call(Vector2(breit, -breit).rotated(w)),
			m, dreh.call(Vector2(-breit, -breit).rotated(w))])
		if k == 0: draw_colored_polygon(p, AktionsKnopf.HELL)
		p.append(p[0])
		draw_polyline(p, AktionsKnopf.HELL if k == 0 else AktionsKnopf.RAND, 1.1 * dp, true)
	var f := get_theme_default_font()
	var fs := int(11 * dp)
	var nc: Vector2 = dreh.call(Vector2(0, -r * 0.79))   # Buchstabe aufrecht, Mitte auf dem Kreis vor der Spitze
	var tw := f.get_string_size("N", HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	draw_string(f, nc + Vector2(-tw.x / 2, f.get_ascent(fs) - tw.y / 2), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, AktionsKnopf.HELL)
