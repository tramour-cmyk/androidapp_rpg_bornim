class_name Steuerung
extends CanvasLayer
# 348.6: Bedienung am Handy: Tippen = hingehen, Ziehen = Joystick, zwei Finger = drehen und zoomen;
# Knopf Laufen (131) und Aktionsknopf (215: Ausgaenge nur mit dem Knopf, nicht beim Betreten); Textfeld schwarz-gold;
# oben Ortsname, Tag/Nacht, Nah/Fern, Drehen und die Messzeile.

signal tippen(bildpunkt: Vector2)
signal joystick(v: Vector2)            # Laenge 0..1, Bildschirmachsen
signal kneifen(faktor: float, drehung_grad: float)
signal aktion
signal laufen(an: bool)
signal knopf(was: String)

const GOLD := Color(0.86, 0.68, 0.32)
const JOY := 110.0

var finger := {}
var kneif_d := 0.0
var kneif_w := 0.0
var unten := false
var zieht := false
var joy_von := Vector2.ZERO
var joy_v := Vector2.ZERO
var zeichner: Control
var aktion_knopf: AktionsKnopf
var ort_schild: Label                  # wohin der Ausgang fuehrt, neben dem Knopf (alt 215, 254: actionPlace)
var lauf_knopf: Button
var ort: Label
var mess: Label
var textfeld: PanelContainer
var text: Label
var zeilen: Array = []
var lauf_an := false

func _ready() -> void:
	name = "Steuerung"
	zeichner = Control.new()
	zeichner.set_anchors_preset(Control.PRESET_FULL_RECT)
	zeichner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zeichner.draw.connect(_zeichne_joy)
	add_child(zeichner)
	ort = schild(Vector2(24, 40), 34)
	mess = schild(Vector2(24, 100), 22)
	mess.visible = "--messen" in OS.get_cmdline_user_args() or OS.is_debug_build()
	var oben := VBoxContainer.new()
	oben.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	oben.position = Vector2(-300, 40)
	oben.add_theme_constant_override("separation", 12)
	add_child(oben)
	for spec in [["Tag / Nacht", "nacht"], ["Nah / Fern", "nah"], ["Drehen ◀", "links"], ["Drehen ▶", "rechts"]]:
		var b := knopf_neu(spec[0], Vector2(260, 84), 28)
		b.pressed.connect(func(): knopf.emit(spec[1]))
		oben.add_child(b)
	# 348.6 (Befund 7): rund mit Zeichen wie alt (76 dp, 22 dp vom Rand), das Schild links daneben (106 dp, 46 dp)
	aktion_knopf = AktionsKnopf.new()
	aktion_knopf.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	aktion_knopf.position = Vector2(-98, -98) * AktionsKnopf.DP
	aktion_knopf.visible = false
	aktion_knopf.pressed.connect(func(): aktion.emit())
	add_child(aktion_knopf)
	ort_schild = Label.new()
	ort_schild.add_theme_font_size_override("font_size", int(14 * AktionsKnopf.DP * 1.15))
	ort_schild.add_theme_color_override("font_color", AktionsKnopf.RAND)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.7); sb.border_color = Color(0.604, 0.506, 0.333); sb.set_border_width_all(int(AktionsKnopf.DP))
	sb.content_margin_left = 8 * AktionsKnopf.DP; sb.content_margin_right = 8 * AktionsKnopf.DP
	sb.content_margin_top = 3 * AktionsKnopf.DP; sb.content_margin_bottom = 3 * AktionsKnopf.DP
	ort_schild.add_theme_stylebox_override("normal", sb)
	ort_schild.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	ort_schild.grow_vertical = Control.GROW_DIRECTION_BEGIN
	ort_schild.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	ort_schild.offset_right = -106 * AktionsKnopf.DP; ort_schild.offset_bottom = -46 * AktionsKnopf.DP
	ort_schild.offset_left = ort_schild.offset_right; ort_schild.offset_top = ort_schild.offset_bottom
	ort_schild.visible = false
	add_child(ort_schild)
	lauf_knopf = knopf_neu("Laufen", Vector2(200, 110), 30)
	lauf_knopf.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	lauf_knopf.position = Vector2(-240, -170)
	lauf_knopf.toggle_mode = true
	lauf_knopf.toggled.connect(func(an): lauf_an = an; laufen.emit(an))
	add_child(lauf_knopf)
	textfeld = PanelContainer.new()
	textfeld.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	textfeld.offset_left = 30; textfeld.offset_right = -30; textfeld.offset_top = -480; textfeld.offset_bottom = -60
	textfeld.add_theme_stylebox_override("panel", rahmen())
	textfeld.visible = false
	textfeld.gui_input.connect(_text_tippen)
	add_child(textfeld)
	text = Label.new()
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 36)
	text.add_theme_color_override("font_color", Color(0.93, 0.88, 0.76))
	textfeld.add_child(text)

func rahmen() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0, 0, 0, 0.82)
	s.border_color = GOLD
	s.set_border_width_all(2)
	s.set_content_margin_all(28)
	return s

func schild(p: Vector2, groesse: int) -> Label:
	var l := Label.new()
	l.position = p
	l.add_theme_font_size_override("font_size", groesse)
	l.add_theme_color_override("font_color", GOLD)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 8)
	add_child(l)
	return l

func knopf_neu(t: String, groesse: Vector2, schrift: int) -> Button:
	var b := Button.new()
	b.text = t
	b.custom_minimum_size = groesse
	b.size = groesse
	b.add_theme_font_size_override("font_size", schrift)
	b.add_theme_color_override("font_color", GOLD)
	b.add_theme_color_override("font_pressed_color", Color(1, 0.9, 0.6))
	for zustand in ["normal", "hover", "focus"]: b.add_theme_stylebox_override(zustand, rahmen_knopf(0.7))
	b.add_theme_stylebox_override("pressed", rahmen_knopf(0.9))
	return b

func rahmen_knopf(a: float) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0, 0, 0, a)
	s.border_color = GOLD
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	return s

# ---------------------------------------------------------------- Aktionsknopf, Textfeld
# z: Zeichen wie ActionKind (ENTER, READ, LOOK, TALK, OPEN), "" = nichts; wohin: Name des Ziels oder ""
func biete_an(z: String, wohin: String = "") -> void:
	aktion_knopf.setze(z)
	aktion_knopf.visible = z != "" and not textfeld.visible
	ort_schild.text = wohin
	ort_schild.visible = wohin != "" and aktion_knopf.visible

func sage(neu: Array) -> void:
	# neu: [{wer?: String, text: String}, ...], eine Zeile je Tippen
	zeilen = neu.duplicate()
	naechste()

func spricht() -> bool: return textfeld.visible

func naechste() -> void:
	if zeilen.is_empty():
		textfeld.visible = false
		lauf_knopf.visible = true
		return
	var z: Dictionary = zeilen.pop_front()
	text.text = (String(z["wer"]) + ": " if z.has("wer") else "") + String(z["text"])
	textfeld.visible = true
	aktion_knopf.visible = false
	ort_schild.visible = false
	lauf_knopf.visible = false   # schien durch das Textfeld (Helferbefund 348.6)

func _text_tippen(e: InputEvent) -> void:
	if (e is InputEventScreenTouch and not e.pressed) or (e is InputEventMouseButton and not e.pressed):
		naechste()

# ---------------------------------------------------------------- Finger
func _zeichne_joy() -> void:
	if not zieht: return
	zeichner.draw_circle(joy_von, JOY, Color(0, 0, 0, 0.25))
	zeichner.draw_arc(joy_von, JOY, 0, TAU, 48, Color(GOLD, 0.6), 4)
	zeichner.draw_circle(joy_von + joy_v * JOY, 46, Color(GOLD, 0.55))

func _unhandled_input(e: InputEvent) -> void:
	if textfeld.visible:
		if e is InputEventScreenTouch and not e.pressed: naechste()
		return
	if e is InputEventScreenTouch:
		var t := e as InputEventScreenTouch
		if t.pressed: finger[t.index] = t.position
		else: finger.erase(t.index)
		if finger.size() >= 2:
			var ks := finger.keys()
			var a: Vector2 = finger[ks[0]]; var b: Vector2 = finger[ks[1]]
			kneif_d = a.distance_to(b); kneif_w = (b - a).angle()
			unten = false; zieht = false; joy_v = Vector2.ZERO
			joystick.emit(joy_v)
		elif t.index == 0:
			if t.pressed:
				unten = true; zieht = false; joy_von = t.position; joy_v = Vector2.ZERO
			else:
				if unten and not zieht: tippen.emit(t.position)
				unten = false; zieht = false; joy_v = Vector2.ZERO
				joystick.emit(joy_v)
		zeichner.queue_redraw()
	elif e is InputEventScreenDrag:
		var dg := e as InputEventScreenDrag
		finger[dg.index] = dg.position
		if finger.size() >= 2:
			var ks := finger.keys()
			var a: Vector2 = finger[ks[0]]; var b: Vector2 = finger[ks[1]]
			var d := a.distance_to(b); var w := (b - a).angle()
			if kneif_d > 1.0: kneifen.emit(kneif_d / maxf(d, 1.0), rad_to_deg(angle_difference(kneif_w, w)))
			kneif_d = d; kneif_w = w
			return
		if unten and dg.index == 0:
			var d := dg.position - joy_von
			if d.length() > 28: zieht = true
			joy_v = d / JOY
			if joy_v.length() > 1.0: joy_v = joy_v.normalized()
			if zieht: joystick.emit(joy_v)
			zeichner.queue_redraw()

func messe(times: Array) -> void:
	if not mess.visible or Engine.get_process_frames() % 15 != 0 or times.is_empty(): return
	var s := times.duplicate()
	s.sort()
	var avg := 0.0
	for x in s: avg += x
	avg /= s.size()
	var p95: float = s[int(s.size() * 0.95) - 1] if s.size() > 20 else s[s.size() - 1]
	mess.text = "Bilder/s %d  (Mittel %.1f ms, 95 %% unter %.1f ms)\nSpeicher %.0f MB, Grafik %.0f MB, Zeichenaufrufe %d, Dreiecke %dk" % [
		Engine.get_frames_per_second(), avg * 1000.0, p95 * 1000.0,
		OS.get_static_memory_usage() / 1048576.0,
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME) / 1000.0)]
