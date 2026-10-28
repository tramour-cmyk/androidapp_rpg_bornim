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
	modulate.a = 0.8                            # Runde 11 (Chefrunde 11:48: durchsichtiger); Gold nicht unter 0,75 (Helfer Runde 8: matt)
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
	draw_circle(m, r, Color(0, 0, 0, 0.18))        # Runde 11: Scheibe 0,62 -> 0,18, die Karte scheint durch (Helfer: bei 0,34 kaum durchsichtig)
	draw_arc(m, r - 0.3 * dp, 0, TAU, 48, Color(0, 0, 0, 0.6), 0.8 * dp, true)   # dunkler Aussenrand: Ring verschwamm im Stroh
	draw_arc(m, r - 1.4 * dp, 0, TAU, 48, AktionsKnopf.RAND, 1.6 * dp, true)
	var dreh := func(v: Vector2) -> Vector2: return m + v.rotated(winkel)
	# vier Spitzen wie eine gestochene Kartenrose: jede Spitze aus zwei Dreiecken, hell und dunkel (Helfer: hohl wirkte
	# sie wie ein Fensterkreuz); Norden lang und golden, die anderen kurz und gedeckt
	var breit := r * 0.16
	for k in 4:
		var lang := r * (0.6 if k == 0 else 0.46)
		var w := k * PI / 2
		var spitze: Vector2 = dreh.call(Vector2(0, -lang).rotated(w))
		var re: Vector2 = dreh.call(Vector2(breit, -breit).rotated(w))
		var li: Vector2 = dreh.call(Vector2(-breit, -breit).rotated(w))
		var hell := AktionsKnopf.HELL if k == 0 else AktionsKnopf.RAND
		var dunkel := hell.darkened(0.45)
		draw_colored_polygon(PackedVector2Array([spitze, re, m]), hell)
		draw_colored_polygon(PackedVector2Array([spitze, m, li]), dunkel)
		draw_polyline(PackedVector2Array([spitze, re, m, li, spitze]), hell, 0.8 * dp, true)
	var f := get_theme_default_font()
	var fs := int(10 * dp)
	var nc: Vector2 = dreh.call(Vector2(0, -r * 0.73))   # Buchstabe aufrecht vor der Spitze, innerhalb des Rings (Helfer: sass auf dem Ring)
	var tw := f.get_string_size("N", HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	draw_string(f, nc + Vector2(-tw.x / 2, f.get_ascent(fs) - tw.y / 2), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, AktionsKnopf.HELL)
