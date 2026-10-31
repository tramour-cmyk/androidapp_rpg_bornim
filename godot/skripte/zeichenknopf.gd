class_name Zeichenknopf
extends Button
# 425 (Chef 31.10., 21:30 zu Build 143: alte Menues mit Zeichen „super klasse“, neue „viel zu viel Text“; DESIGN-STIL.md 426):
# ein Eintrag im Menue „System“ wie alt (MenuSigns.kt Sign, 326): 80 dp breit, oben ein Kreis von 48 dp mit duennem Goldrand, darin
# ein gezeichnetes Zeichen (24 dp, Raster 22, Linie 1,5) oder ein Buchstabe, darunter der Name und in Gold der Wert. Antippen tut
# den naechsten Schritt (mit Klick), Gedrueckthalten erklaert den Eintrag in einem Fenster ueber dem Menue (Menue.erklaere).
# Farben (Homer 10:18): gegeben Gold, offen (Erklaerung offen) hell mit 1,5 dp Rand, aus Gold zu 45 % und Rand Veil.rim, das Zeichen
# dazu durchgestrichen. Arten wie alt (G): SAVE, ABOUT, RULES, MENU, BLOOD, TEMPO, TEXT, MAP, CONTROLS, STICK, HAND, BUZZ, STEPS;
# RUN ist der Stiefel des Rennknopfs (AktionsKnopf.stiefel), kein eigenes Zeichen.

const DP := AktionsKnopf.DP
const HALTEN := 0.4                  # Compose: Gedrueckthalten nach 400 ms (ViewConfiguration.longPressTimeoutMillis)

static var offen := ""               # MenuExplain.shown: der Eintrag, dessen Erklaerung offen ist

var wort := ""                       # Name des Eintrags
var wert = null                      # was eingestellt ist, oder null
var erklaerung := ""                 # der Satz zum Gedrueckthalten
var an := true
var zeichen := ""                    # Art (oben) oder ""
var buchstabe := ""                  # statt eines Zeichens: „DE“, „?“, „M“
var tat: Callable
var lang: Callable                   # Gedrueckthalten: wort, erklaerung
var kreis: Control
var _uhr := 0.0
var _gehalten := false
var _ab := Vector2.INF

func _init(wort_: String, wert_, erklaerung_: String, tat_: Callable, lang_: Callable, an_ := true, zeichen_ := "", buchstabe_ := "") -> void:
	wort = wort_; wert = wert_; erklaerung = erklaerung_; tat = tat_; lang = lang_; an = an_; zeichen = zeichen_; buchstabe = buchstabe_
	tooltip_text = wort
	flat = true
	focus_mode = Control.FOCUS_NONE
	for z in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]: add_theme_stylebox_override(z, StyleBoxEmpty.new())
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", 0)
	spalte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spalte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(spalte)
	kreis = Control.new()
	kreis.custom_minimum_size = Vector2(48, 48) * DP
	kreis.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	kreis.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kreis.draw.connect(_zeichne)
	spalte.add_child(kreis)
	if buchstabe != "":
		var b := Stil.zeile(buchstabe, 22 if buchstabe.length() == 1 else 15, _tinte(), 1.0)
		b.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.name = "Buchstabe"
		kreis.add_child(b)
	var l4 := Erschaffung.luecke(4)
	l4.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spalte.add_child(l4)
	for t in [[wort, Stil.TEXT]] + ([[String(wert), Stil.GOLD]] if wert != null else []):
		var l := Stil.zeile(String(t[0]), 13, t[1])   # 326 (Homer 10:18): gemischt geschrieben in voller Groesse, Versalien nur fuer Ueberschriften
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		spalte.add_child(l)
	button_down.connect(func(): _uhr = HALTEN)
	button_up.connect(func(): _uhr = 0.0)
	pressed.connect(func():
		if _gehalten: _gehalten = false; return
		var k := get_node_or_null("/root/Klang") if is_inside_tree() else null   # LocalClick: Sound.CLICK zu 35 %
		if k: k.effekt("click", 0.35)
		tat.call())
	gui_input.connect(_eingabe)
	set_process(true)

# Column(Modifier.width(80.dp)): der Knopf so gross wie Kreis, Name und Wert (Button nimmt _get_minimum_size nicht)
func _ready() -> void:
	var s: Vector2 = get_child(0).get_combined_minimum_size()
	custom_minimum_size = Vector2(maxf(80 * DP, s.x), s.y)

# verschoben zum Rollen (ueber 12 dp) tut nichts, wie Compose ueber der Beruehrschwelle
func _eingabe(e: InputEvent) -> void:
	if (e is InputEventScreenTouch or e is InputEventMouseButton) and e.pressed: _ab = e.position; _gehalten = false
	elif (e is InputEventScreenDrag or e is InputEventMouseMotion) and _ab != Vector2.INF and e.position.distance_to(_ab) > 12 * DP:
		_uhr = 0.0; _gehalten = true   # gerollt: weder Erklaerung noch Tippen

func _process(d: float) -> void:
	if _uhr <= 0.0: return
	_uhr -= d
	if _uhr > 0.0: return
	_uhr = 0.0
	if not button_pressed and not is_pressed(): return
	_gehalten = true
	lang.call(wort, erklaerung)

func _tinte() -> Color:
	if offen == wort: return Stil.BRIGHT
	return Stil.GOLD if an else Color(Stil.GOLD, 0.45)

func neu_zeichnen() -> void:
	kreis.queue_redraw()
	var b := kreis.get_node_or_null("Buchstabe")
	if b: (b as Label).add_theme_color_override("font_color", _tinte())

func _zeichne() -> void:
	var auf := offen == wort
	var r := kreis.size.x / 2
	var breit := (1.5 if auf else 1.0) * DP
	kreis.draw_arc(kreis.size / 2, r - breit / 2, 0, TAU, 64, Stil.BRIGHT if auf else (Stil.GOLD if an else Stil.RIM), breit, true)
	if buchstabe != "": return
	var s := 24 * DP
	var o := (kreis.size - Vector2(s, s)) / 2
	if zeichen == "RUN":
		AktionsKnopf.stiefel(kreis, o, s / 24.0, _tinte())
		return
	if zeichen != "": Zeichenknopf.glyphe(kreis, zeichen, o, s / 22.0, _tinte(), an)

# MenuSigns.kt drawGlyph: Raster 22, Linie 1,5, runde Enden; gefuellt nur Punkte, das Dreieck des Textes und die Sohlen
static func glyphe(ci: CanvasItem, g: String, o: Vector2, u: float, c: Color, an_: bool) -> void:
	var w := 1.5 * u
	var P := func(x: float, y: float) -> Vector2: return o + Vector2(x, y) * u
	var linie := func(x1: float, y1: float, x2: float, y2: float) -> void: ci.draw_line(P.call(x1, y1), P.call(x2, y2), c, w, true)
	var zug := func(pkt: Array, zu := false) -> void:
		var q := PackedVector2Array()
		for p in pkt: q.append(P.call(p.x, p.y))
		if zu: q.append(q[0])
		ci.draw_polyline(q, c, w, true)
	var ring := func(m: Vector2, r: float) -> void: ci.draw_arc(P.call(m.x, m.y), r * u, 0, TAU, 48, c, w, true)
	var punkt := func(m: Vector2, r: float) -> void: ci.draw_circle(P.call(m.x, m.y), r * u, c)
	match g:
		"SAVE":   # ein Buch mit Lesezeichen
			zug.call([Vector2(5, 3), Vector2(17, 3), Vector2(17, 19), Vector2(5, 19)], true)
			linie.call(8, 3, 8, 19)
			zug.call([Vector2(12, 3), Vector2(12, 9), Vector2(13.5, 7.5), Vector2(15, 9), Vector2(15, 3)])
		"ABOUT":
			ring.call(Vector2(11, 11), 9); punkt.call(Vector2(11, 7), 1.1); linie.call(11, 10, 11, 15.5)
		"RULES":   # ein offenes Buch
			var p: Array = [Vector2(11, 6)]
			p += _quad(Vector2(11, 6), Vector2(7, 3.5), Vector2(2.5, 5))
			p.append(Vector2(2.5, 18))
			p += _quad(Vector2(2.5, 18), Vector2(7, 16.5), Vector2(11, 19))
			p += _quad(Vector2(11, 19), Vector2(15, 16.5), Vector2(19.5, 18))
			p.append(Vector2(19.5, 5))
			p += _quad(Vector2(19.5, 5), Vector2(15, 3.5), Vector2(11, 6))
			p.append(Vector2(11, 19))
			zug.call(p)
			linie.call(5, 9, 8.5, 9.5); linie.call(5, 12.5, 8.5, 13); linie.call(13.5, 9.5, 17, 9); linie.call(13.5, 13, 17, 12.5)
		"MENU":   # ein Turm mit drei Zinnen (Homer 10:18: kein Tor, das ist „Eintreten“)
			var k := 22.0 / 24.0
			var t: Array = []
			for q in [[8.5, 21], [8.5, 10], [6, 8], [6, 2.5], [8.8, 2.5], [8.8, 6], [10.6, 6], [10.6, 2.5], [13.4, 2.5], [13.4, 6], [15.2, 6],
					[15.2, 2.5], [18, 2.5], [18, 8], [15.5, 10], [15.5, 21]]:
				t.append(Vector2(q[0], q[1]) * k)
			zug.call(t)
			linie.call(4 * k, 21 * k, 20 * k, 21 * k)
		"BLOOD":   # ein Tropfen
			var p: Array = [Vector2(11, 3)]
			p += _kubisch(Vector2(11, 3), Vector2(13, 8), Vector2(17, 11), Vector2(17, 14))
			p += _kubisch(Vector2(17, 14), Vector2(17, 18), Vector2(14, 20), Vector2(11, 20))
			p += _kubisch(Vector2(11, 20), Vector2(8, 20), Vector2(5, 18), Vector2(5, 14))
			p += _kubisch(Vector2(5, 14), Vector2(5, 11), Vector2(9, 8), Vector2(11, 3))
			zug.call(p)
		"TEMPO":   # ein Metronom
			zug.call([Vector2(5, 19), Vector2(17, 19), Vector2(13.5, 3), Vector2(8.5, 3)], true)
			linie.call(11, 16, 16.5, 6); punkt.call(Vector2(14.6, 9.5), 1.2)
		"TEXT":
			linie.call(4, 6, 18, 6); linie.call(4, 11, 18, 11); linie.call(4, 16, 11, 16)
			ci.draw_colored_polygon(PackedVector2Array([P.call(14, 14), P.call(18, 16.5), P.call(14, 19)]), c)
		"MAP":   # eine Lupe mit Plus
			ring.call(Vector2(9, 9), 6); linie.call(13.5, 13.5, 19, 19); linie.call(9, 6.5, 9, 11.5); linie.call(6.5, 9, 11.5, 9)
		"CONTROLS":
			ring.call(Vector2(11, 11), 9); punkt.call(Vector2(13, 9), 3.5)
		"STICK":   # innerer Kreis, aussen der Ring gestrichelt (2 an, 2 aus)
			ring.call(Vector2(11, 11), 4)
			var n := int(round(TAU * 9 / 4.0))
			for i in n:
				var a0 := TAU * i / n
				ci.draw_arc(P.call(11, 11), 9 * u, a0, a0 + TAU / n / 2, 4, c, 1.0 * u, true)
		"HAND":   # ein Pfeil zur Seite, wo der Knopf sitzt
			linie.call(4, 11, 17, 11); zug.call([Vector2(13, 6.5), Vector2(17.5, 11), Vector2(13, 15.5)]); punkt.call(Vector2(17.5, 11), 2)
		"BUZZ":   # ein Handy mit zwei Wellen
			var rr := 1.2
			var e: Array = []
			for m in [[Vector2(14 - rr, 18.5 - rr), 0.0], [Vector2(8 + rr, 18.5 - rr), 0.5], [Vector2(8 + rr, 3.5 + rr), 1.0], [Vector2(14 - rr, 3.5 + rr), 1.5]]:
				for i in 5: e.append(m[0] + Vector2.from_angle((m[1] + i / 8.0) * PI) * rr)
			zug.call(e, true)
			ci.draw_arc(P.call(6.5, 11), 4 * u, deg_to_rad(120), deg_to_rad(240), 16, c, w, true)
			ci.draw_arc(P.call(15.5, 11), 4 * u, deg_to_rad(-60), deg_to_rad(60), 16, c, w, true)
		"STEPS":   # zwei Sohlen mit Absatz, versetzt
			for ov in [[Vector2(6.5, 11.75), Vector2(2.5, 3.75)], [Vector2(6.5, 18.1), Vector2(1.9, 1.8)], [Vector2(15, 5.75), Vector2(2.5, 3.75)], [Vector2(15, 12.1), Vector2(1.9, 1.8)]]:
				var q := PackedVector2Array()
				for i in 24: q.append(P.call(ov[0].x + ov[1].x * cos(TAU * i / 24), ov[0].y + ov[1].y * sin(TAU * i / 24)))
				ci.draw_colored_polygon(q, c)
	if not an_: linie.call(3, 20, 19, 2)

static func _quad(a: Vector2, b: Vector2, e: Vector2) -> Array:
	var r := []
	for i in range(1, 11):
		var t := i / 10.0
		r.append(a.lerp(b, t).lerp(b.lerp(e, t), t))
	return r

static func _kubisch(a: Vector2, b: Vector2, c: Vector2, e: Vector2) -> Array:
	var r := []
	for i in range(1, 13):
		var t := i / 12.0
		r.append(a.bezier_interpolate(b, c, e, t))
	return r
