class_name Steuerung
extends CanvasLayer
# 348.6: Bedienung am Handy: Tippen = hingehen, Ziehen = Joystick, zwei Finger = drehen und zoomen;
# Knopf Laufen (131) und Aktionsknopf (215: Ausgaenge nur mit dem Knopf, nicht beim Betreten); Textfeld schwarz-gold;
# oben Ortsname, Windrose, Tag/Nacht, Nah/Fern, Drehen und die Messzeile.

signal tippen(bildpunkt: Vector2)
signal joystick(v: Vector2)            # Laenge 0..1, Bildschirmachsen
signal kneifen(faktor: float, drehung_grad: float)
signal aktion
signal laufen(an: bool)
signal knopf(was: String)
signal gelesen                          # 390: Textfeld zu, die Szene geht weiter (Game.advance)
signal gewaehlt(id: String)             # 390 (Rast): Knopf im Wahlfeld, "" = Weiter

const GOLD := Color(0.86, 0.68, 0.32)
var JOY := 94.0 * AktionsKnopf.DP            # 131 (alt StickFeel.runAt): im Ring gehen, darueber hinaus laufen; 399.1 nach Bedienung.ring
const NACHTLICHT := Color("2c2a48")          # Colors.nightLight: Grund der Leiste „Klassisch“
const KREUZ := 150.0                         # DPad: 150 dp, Arme 50 dp

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
var lauf_knopf: AktionsKnopf             # 399.1 wie alt ActionButton(RUN, 58 dp): Stiefel, matt, solange er nicht rennt
var kreuz_leiste: ColorRect              # 399.1 Klassisch (ClassicControls): Leiste unten, Steuerkreuz und Knoepfe
var kreuz: Steuerkreuz
var ort: Label
var mess: Label
var textfeld: PanelContainer
var sprecher: Label                     # 399.1: Name im Kasten, gesperrte Versalien in Gold
var weiter_zeichen: Label               # ▼, blinkt wie alt alle 400 ms
var text: Label
var zeilen: Array = []
var lauf_an := false
var ring_lauf := false
var windrose: Windrose
var wahl_grund: ColorRect               # 390 (RestScreen): die Welt gedimmt dahinter, nicht zu beruehren
var wahl_box: VBoxContainer
var wahl_rolle: ScrollContainer
const WAHL_HOEHE := 1500.0
var leiste: Leiste                       # 399.1 Leiste oben wie alt (HudChip)
var oben: VBoxContainer                 # Probeknoepfe (Tag/Nacht, Nah/Fern, Drehen): gibt es im alten Spiel nicht, in Vergleichsbildern aus

func _ready() -> void:
	name = "Steuerung"
	zeichner = Control.new()
	zeichner.set_anchors_preset(Control.PRESET_FULL_RECT)
	zeichner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zeichner.draw.connect(_zeichne_joy)
	add_child(zeichner)
	# 399.1 Leiste oben wie alt (HudChip, Test 132): ueber die ganze Breite; Ortsname, Windrose und Probeknoepfe darunter
	leiste = Leiste.new()
	leiste.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	add_child(leiste)
	var oy := leiste.get_combined_minimum_size().y + 8 * AktionsKnopf.DP
	ort = schild(Vector2(24, oy), 34)
	# 348.6 (Befund 7, „Bornim“ schlecht lesbar): auf dunklem Grund wie HudChip (0xAA000000, Ecken 8 dp)
	var chip := StyleBoxFlat.new()
	chip.bg_color = Color(0, 0, 0, 0.667); chip.set_corner_radius_all(int(8 * AktionsKnopf.DP))
	chip.content_margin_left = 6 * AktionsKnopf.DP; chip.content_margin_right = 6 * AktionsKnopf.DP
	chip.content_margin_top = 3 * AktionsKnopf.DP; chip.content_margin_bottom = 3 * AktionsKnopf.DP
	ort.add_theme_stylebox_override("normal", chip)
	mess = schild(Vector2(24, oy + 60), 22)
	mess.visible = "--messen" in OS.get_cmdline_user_args() or OS.is_debug_build()
	windrose = Windrose.new()                # 348.6 Runde 11 (Chefrunde 25.10., 11:48): rechts oben, Probeknoepfe darunter
	windrose.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	windrose.position = Vector2(-Windrose.GROESSE - 16 * AktionsKnopf.DP, oy)
	add_child(windrose)
	oben = VBoxContainer.new()
	oben.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	oben.position = Vector2(-300, oy + Windrose.GROESSE + 16 * AktionsKnopf.DP)
	oben.add_theme_constant_override("separation", 12)
	add_child(oben)
	var knoepfe := [["Tag / Nacht", "nacht"], ["Nah / Fern", "nah"], ["Drehen ◀", "links"], ["Drehen ▶", "rechts"], ["Deutsch / English", "sprache"]]   # 390: Sprache wie alt im Systemmenue, hier nur zum Testen
	if DirAccess.dir_exists_absolute("res://daten/tiere"): knoepfe.append(["Tiere", "tiere"])   # 348.6: Tiere zum Anschauen (Chef 16:52), nur Test
	for spec in knoepfe:
		var b := knopf_neu(spec[0], Vector2(260, 84), 28)
		b.pressed.connect(func(): knopf.emit(spec[1]))
		oben.add_child(b)
	# 348.6 (Befund 7): rund mit Zeichen wie alt (76 dp, 22 dp vom Rand), das Schild links daneben (106 dp, 46 dp)
	aktion_knopf = AktionsKnopf.new()
	aktion_knopf.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	aktion_knopf.position = Vector2(-98, -98) * AktionsKnopf.DP
	aktion_knopf.visible = false
	# Klassisch im Gespraech „Weiter“ (pressA: dialog -> advance); kurz ruetteln, wenn vor dir etwas zu tun ist (WorldScreen buzz)
	aktion_knopf.pressed.connect(func():
		if textfeld.visible: naechste(); return
		if angebot != "": Bedienung.ruettle()
		aktion.emit())
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
	# 348.6 (Befund: verdeckte den Tuerknopf): wie alt (131) ueber dem Aktionsknopf, 58 dp, 31 dp vom Rand, 112 dp von unten; Wischen:
	# Antippen schaltet um (runLatch), Klassisch: rennen, solange gedrueckt (ClassicControls onRun)
	lauf_knopf = AktionsKnopf.new(58)
	lauf_knopf.setze("RUN")
	lauf_knopf.matt = true
	lauf_knopf.button_down.connect(func():
		lauf_an = not lauf_an if not Bedienung.klassisch else true
		lauf_knopf.matt = not lauf_an
		laufen.emit(lauf_an))
	lauf_knopf.button_up.connect(func():
		if Bedienung.klassisch: lauf_an = false; lauf_knopf.matt = true; laufen.emit(false)
		lauf_knopf.queue_redraw())
	add_child(lauf_knopf)
	# 399.1 (Chef 14:38 „auch in den Dialogen“): Textkasten wie im alten Spiel (DialogDraft.kt DialogBoxVeil, 42b): ganz schwarz,
	# duenner Goldrand, Sprecher klein, gesperrt, in Versalien und Gold im Kasten, Worte in gebrochenem Weiss, Erzaehltes schraeg,
	# ▼ in Gold blinkt; mindestens 132 dp hoch, waechst mit dem Text nach oben
	textfeld = PanelContainer.new()
	textfeld.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	textfeld.offset_left = 30; textfeld.offset_right = -30; textfeld.offset_bottom = -60
	textfeld.offset_top = textfeld.offset_bottom - 132 * AktionsKnopf.DP
	textfeld.grow_vertical = Control.GROW_DIRECTION_BEGIN
	textfeld.custom_minimum_size.y = 132 * AktionsKnopf.DP
	var tk := Stil.kasten(Color.BLACK, Stil.RIM, 1.0)
	tk.content_margin_left = 18 * AktionsKnopf.DP; tk.content_margin_right = 18 * AktionsKnopf.DP
	tk.content_margin_top = 12 * AktionsKnopf.DP; tk.content_margin_bottom = 16 * AktionsKnopf.DP
	textfeld.add_theme_stylebox_override("panel", tk)
	textfeld.visible = false
	textfeld.gui_input.connect(_text_tippen)
	add_child(textfeld)
	# 399.1 Klassisch (ClassicControls): ueber der Welt, unter den Knoepfen und dem Textfeld; das Wahlfeld liegt darueber
	kreuz_leiste = ColorRect.new()
	kreuz_leiste.color = NACHTLICHT
	kreuz_leiste.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	kreuz_leiste.offset_top = -(KREUZ + 28) * AktionsKnopf.DP
	kreuz_leiste.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(kreuz_leiste)
	kreuz = Steuerkreuz.new()
	kreuz.richtung.connect(func(v: Vector2): joystick.emit(v))
	kreuz_leiste.add_child(kreuz)
	move_child(kreuz_leiste, aktion_knopf.get_index())   # unter Aktions- und Renntaste, sonst verdeckt und sperrt sie die Leiste
	wahl_grund = ColorRect.new()
	wahl_grund.color = Color(0, 0, 0, 0.6)                      # alt 0x99000000
	wahl_grund.set_anchors_preset(Control.PRESET_FULL_RECT)
	wahl_grund.mouse_filter = Control.MOUSE_FILTER_STOP
	wahl_grund.visible = false
	add_child(wahl_grund)
	var wahlfeld := PanelContainer.new()
	wahlfeld.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	wahlfeld.offset_left = 30; wahlfeld.offset_right = -30; wahlfeld.offset_bottom = -60
	wahlfeld.grow_vertical = Control.GROW_DIRECTION_BEGIN
	wahlfeld.add_theme_stylebox_override("panel", rahmen())
	wahl_grund.add_child(wahlfeld)
	wahl_rolle = ScrollContainer.new()     # 390 (Laden): lange Listen rollen, hoechstens WAHL_HOEHE hoch
	wahl_rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	wahlfeld.add_child(wahl_rolle)
	wahl_box = VBoxContainer.new()
	wahl_box.add_theme_constant_override("separation", 14)
	wahl_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wahl_rolle.add_child(wahl_box)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", int(6 * AktionsKnopf.DP))
	textfeld.add_child(spalte)
	sprecher = Stil.zeile("", 12, Stil.GOLD, 3.0)
	spalte.add_child(sprecher)
	text = Stil.zeile("", 17, Stil.TEXT, 0.3)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_constant_override("line_spacing", int(4 * Stil.SP))   # Zeilenhoehe 24 sp bei 17 sp
	spalte.add_child(text)
	weiter_zeichen = Stil.zeile("▼", 12, Stil.GOLD)
	weiter_zeichen.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	weiter_zeichen.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	weiter_zeichen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textfeld.add_child(weiter_zeichen)
	var blinken := Timer.new()
	blinken.wait_time = 0.4
	blinken.autostart = true
	blinken.timeout.connect(func(): weiter_zeichen.modulate.a = 1.0 - weiter_zeichen.modulate.a)
	add_child(blinken)
	richte_ein()

# 399.1 Bedienung aus dem Menue System (Bedienung.gd): Wischen oder Klassisch, Ring, Renntaste, Seite des Aktionsknopfs.
# Masse wie alt in dp: Wischen Aktionsknopf 76, 22 vom Rand, Renntaste 58, 31 vom Rand, 112 von unten, Schild 106 und 46;
# Klassisch Leiste 178 hoch (Kreuz 150, Rand 16 und 14), Knoepfe in 140 x 140: Aktion 70 oben aussen, Rennen 58 unten innen
func richte_ein() -> void:
	Bedienung.lade()
	var dp := AktionsKnopf.DP
	var k := Bedienung.klassisch
	var li := Bedienung.links
	JOY = Bedienung.ring_dp() * dp
	if k and (unten or zieht):
		unten = false; zieht = false; joy_v = Vector2.ZERO
		joystick.emit(joy_v)
		ring(false)
	if lauf_an:
		lauf_an = false; laufen.emit(false)
	lauf_knopf.matt = true
	kreuz_leiste.visible = k
	var a := 70.0 if k else 76.0
	aktion_knopf.custom_minimum_size = Vector2(a, a) * dp
	aktion_knopf.size = aktion_knopf.custom_minimum_size
	for c in [aktion_knopf, lauf_knopf]:
		c.set_anchors_preset(Control.PRESET_BOTTOM_LEFT if li else Control.PRESET_BOTTOM_RIGHT)
	if k:
		var mitte := -(14 + KREUZ - 5)   # Oberkante der 140er Flaeche
		aktion_knopf.position = Vector2(16 if li else -(16 + 70), mitte + 6) * dp
		lauf_knopf.position = Vector2(16 + 140 - 58 if li else -(16 + 140), mitte + 140 - 6 - 58) * dp
		kreuz.anchor_left = 1.0 if li else 0.0
		kreuz.anchor_right = kreuz.anchor_left
		kreuz.offset_left = -(16 + KREUZ) * dp if li else 16 * dp
		kreuz.offset_right = kreuz.offset_left + KREUZ * dp
		kreuz.offset_top = 14 * dp; kreuz.offset_bottom = (14 + KREUZ) * dp
	else:
		aktion_knopf.position = Vector2(22 if li else -98, -98) * dp
		lauf_knopf.position = Vector2(31 if li else -(31 + 58), -(112 + 58)) * dp
	ort_schild.set_anchors_preset(Control.PRESET_BOTTOM_LEFT if li else Control.PRESET_BOTTOM_RIGHT)
	ort_schild.grow_horizontal = Control.GROW_DIRECTION_END if li else Control.GROW_DIRECTION_BEGIN
	ort_schild.offset_left = 106 * dp if li else -106 * dp
	ort_schild.offset_right = ort_schild.offset_left
	ort_schild.offset_bottom = -46 * dp; ort_schild.offset_top = ort_schild.offset_bottom
	# Textfeld ueber der Leiste (alt: das Kartenfeld endet ueber ClassicControls)
	textfeld.offset_bottom = -((KREUZ + 28) * dp + 8 * dp) if k else -60.0
	textfeld.offset_top = textfeld.offset_bottom - 132 * dp
	zeige_knoepfe()

# was gerade zu sehen ist: Wischen den Aktionsknopf nur mit Angebot, Klassisch immer (matt ohne Angebot, im Gespraech „Weiter“)
func zeige_knoepfe() -> void:
	var k := Bedienung.klassisch
	var frei := not textfeld.visible and not wahl_grund.visible
	if k:
		aktion_knopf.visible = not wahl_grund.visible
		aktion_knopf.matt = frei and angebot == ""
		aktion_knopf.setze("NEXT" if textfeld.visible else (angebot if angebot != "" else "ACT"))
	else:
		aktion_knopf.matt = false
		aktion_knopf.setze(angebot)
		aktion_knopf.visible = angebot != "" and frei
	lauf_knopf.visible = frei and (k or Bedienung.lauf_taste)
	ort_schild.visible = ort_schild.text != "" and aktion_knopf.visible and not k and frei

var angebot := ""

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
	angebot = z
	ort_schild.text = wohin
	zeige_knoepfe()

func sage(neu: Array) -> void:
	# neu: [{wer?: String, text: String}, ...], eine Zeile je Tippen
	zeilen = neu.duplicate()
	naechste()

func spricht() -> bool: return textfeld.visible

# ---------------------------------------------------------------- Wahlfeld (390, RestScreen): Titel gold, Zeilen darunter,
# je Wahl ein Knopf und darunter matt, was sie tut oder warum nicht; unten „Weiter“
# knoepfe: [{text, info, an, id}]; notiz: Antwort auf die letzte Wahl (Met, kein Gold)
func zeige_wahl(titel: String, zeilen_: Array, knoepfe: Array, weiter_text: String, notiz: String = "") -> void:
	for c in wahl_box.get_children():
		wahl_box.remove_child(c)
		c.queue_free()
	var t := Label.new()
	t.text = titel
	t.add_theme_font_size_override("font_size", 44)
	t.add_theme_color_override("font_color", GOLD)
	wahl_box.add_child(t)
	for z in zeilen_ + ([notiz] if notiz != "" else []):
		if z is Control:   # 399.1 (Laden): fertige Zeilen wie GearDetails
			wahl_box.add_child(z)
			continue
		var l := Label.new()
		l.text = String(z)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_font_size_override("font_size", 30)
		l.add_theme_color_override("font_color", Color(0.93, 0.88, 0.76))
		wahl_box.add_child(l)
	for k in knoepfe + [{"text": weiter_text, "id": ""}]:
		if k.has("zeile"):   # 399.1 (Anschlagbrett): ein Satz zwischen den Knoepfen, matt mit „matt“
			var zl := Label.new()
			zl.text = String(k["zeile"])
			zl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			zl.add_theme_font_size_override("font_size", 30)
			zl.add_theme_color_override("font_color", Color(0.62, 0.58, 0.50) if k.get("matt", false) else Color(0.93, 0.88, 0.76))
			wahl_box.add_child(zl)
			continue
		if k.has("kopf"):   # Ueberschrift eines Teils (Laden: Vorraete, Brauen, Verkaufen, Zurueckkaufen)
			var kl := Label.new()
			kl.text = String(k["kopf"])
			kl.add_theme_font_size_override("font_size", 34)
			kl.add_theme_color_override("font_color", GOLD)
			wahl_box.add_child(kl)
			continue
		var b := knopf_neu(String(k["text"]), Vector2(0, 96), 32)
		b.disabled = not bool(k.get("an", true))
		var id := String(k["id"])
		b.pressed.connect(func(): gewaehlt.emit(id))
		wahl_box.add_child(b)
		if k.has("info"):
			var l := Label.new()
			l.text = String(k["info"])
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.add_theme_font_size_override("font_size", 26)
			l.add_theme_color_override("font_color", Color(0.62, 0.58, 0.50))   # Colors.textDim
			wahl_box.add_child(l)
	if unten or zieht:
		unten = false; zieht = false; joy_v = Vector2.ZERO
		joystick.emit(joy_v)
		ring(false)
		zeichner.queue_redraw()
	wahl_grund.visible = true
	zeige_knoepfe()
	_wahl_hoehe.call_deferred()

func _wahl_hoehe() -> void:
	wahl_rolle.custom_minimum_size.y = minf(wahl_box.get_combined_minimum_size().y, WAHL_HOEHE)

func schliesse_wahl() -> void:
	wahl_grund.visible = false
	zeige_knoepfe()
func waehlt() -> bool: return wahl_grund.visible

func naechste() -> void:
	if zeilen.is_empty():
		var war := textfeld.visible
		textfeld.visible = false
		zeige_knoepfe()
		if war: gelesen.emit()
		return
	var z: Dictionary = zeilen.pop_front()
	# 390 (Pruefer): ein Finger, der schon lag (Joystick), laeuft nicht weiter und schaltet die Zeile nicht weiter
	if not textfeld.visible and (unten or zieht):
		unten = false; zieht = false; joy_v = Vector2.ZERO
		joystick.emit(joy_v)
		ring(false)
		zeichner.queue_redraw()
	if not textfeld.visible: druck_im_text = false
	sprecher.text = String(z["wer"]).to_upper() if z.has("wer") else ""
	sprecher.visible = z.has("wer")
	text.text = String(z["text"])
	text.add_theme_font_override("font", Stil.variante(0.3, not z.has("wer")))   # Erzaehltes schraeg wie alt
	textfeld.visible = true
	zeige_knoepfe()   # Renntaste schien durch das Textfeld (Helferbefund 348.6); Klassisch zeigt „Weiter“

# 390 (Pruefer): ein Tippen kommt als Beruehrung und als nachgebildete Maus; nur Beruehrungen zaehlen, je Bild hoechstens eine,
# und nur ein Druck, der bei offenem Textfeld begann
var druck_im_text := false
var letzter_tipp := -1

func _text_tippen(e: InputEvent) -> void:
	if e is InputEventScreenTouch: _tipp_text(e as InputEventScreenTouch)

func _tipp_text(t: InputEventScreenTouch) -> void:
	if t.pressed:
		druck_im_text = true
		return
	if not druck_im_text or Engine.get_process_frames() == letzter_tipp: return
	druck_im_text = false
	letzter_tipp = Engine.get_process_frames()
	naechste()

# 390: Aufschriften neu nach dem Sprachwechsel
func sprache_neu() -> void:
	pass

# ---------------------------------------------------------------- Finger
func _zeichne_joy() -> void:
	if not zieht: return
	zeichner.draw_circle(joy_von, JOY, Color(0, 0, 0, 0.25))
	zeichner.draw_arc(joy_von, JOY, 0, TAU, 48, Color(GOLD, 0.9 if ring_lauf else 0.45), 6 if ring_lauf else 4)   # alt: Ring golden, solange er laeuft
	zeichner.draw_circle(joy_von + joy_v * JOY * 1.15, 46, Color(GOLD, 0.55))

func _unhandled_input(e: InputEvent) -> void:
	if wahl_grund.visible: return
	if textfeld.visible:
		if e is InputEventScreenTouch: _tipp_text(e as InputEventScreenTouch)
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
		elif t.index == 0 and Bedienung.klassisch:
			unten = false
		elif t.index == 0:
			if t.pressed:
				unten = true; zieht = false; joy_von = t.position; joy_v = Vector2.ZERO
			else:
				if unten and not zieht: tippen.emit(t.position)
				unten = false; zieht = false; joy_v = Vector2.ZERO
				joystick.emit(joy_v)
				ring(false)
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
			joy_v = d / (JOY * 1.15)
			if joy_v.length() > 1.0: joy_v = joy_v.normalized()
			if zieht: joystick.emit(joy_v)
			ring(zieht and d.length() > JOY)
			zeichner.queue_redraw()

func ring(an: bool) -> void:
	if an == ring_lauf or lauf_an: return
	ring_lauf = an
	laufen.emit(an)
	if unten: Bedienung.ruettle(an)   # 131: kurz beim Anfang und Ende des Rennens (LongPress, TextHandleMove)

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

# 399.1 DPad (WorldScreen.kt) wie alt: Kreuz 150 dp, Arme 50 dp, Mitte frei (10 %); vier Richtungen auf dem Bildschirm, gedrueckt
# heller; die Welt geht in Bildschirmrichtung wie beim Joystick (spiel.gd kamera.richtung)
class Steuerkreuz extends Control:
	signal richtung(v: Vector2)
	const DUNKEL := Color("2a2a3a")
	const HELL := Color("4a4a66")
	const PFEIL := Color("9090b0")
	var jetzt := Vector2.ZERO
	var finger := -1

	func _init() -> void:
		custom_minimum_size = Vector2.ONE * Steuerung.KREUZ * AktionsKnopf.DP
		size = custom_minimum_size
		mouse_filter = Control.MOUSE_FILTER_STOP

	func dir_bei(p: Vector2) -> Vector2:
		var d := p - size / 2
		if absf(d.x) < size.x * 0.1 and absf(d.y) < size.y * 0.1: return Vector2.ZERO
		if absf(d.x) > absf(d.y): return Vector2(signf(d.x), 0)
		return Vector2(0, signf(d.y))

	func setze(v: Vector2) -> void:
		if v == jetzt: return
		jetzt = v
		richtung.emit(v)
		queue_redraw()

	func _gui_input(e: InputEvent) -> void:
		if e is InputEventScreenTouch:
			if e.pressed and finger < 0: finger = e.index; setze(dir_bei(e.position))
			elif not e.pressed and e.index == finger: finger = -1; setze(Vector2.ZERO)
			accept_event()
		elif e is InputEventScreenDrag:
			if e.index == finger: setze(dir_bei(e.position))
			accept_event()
		elif e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.device != InputEvent.DEVICE_ID_EMULATION:
			setze(dir_bei(e.position) if e.pressed else Vector2.ZERO)
			accept_event()
		elif e is InputEventMouseMotion and e.device != InputEvent.DEVICE_ID_EMULATION and (e.button_mask & MOUSE_BUTTON_MASK_LEFT):
			setze(dir_bei(e.position))

	func _draw() -> void:
		var dp := AktionsKnopf.DP
		var arm := 50.0 * dp
		var g := size.x
		var sb := StyleBoxFlat.new()
		sb.bg_color = DUNKEL
		sb.set_corner_radius_all(int(8 * dp))
		draw_style_box(sb, Rect2((g - arm) / 2, 0, arm, g))
		draw_style_box(sb, Rect2(0, (g - arm) / 2, g, arm))
		# ▲ ▼ ◀ ▶ in 18 sp als Dreiecke (Alegreya hat die Zeichen nicht)
		var h := 18.0 * Stil.SP * 0.36
		for p in [[Vector2(0, -1), Vector2((g - arm) / 2, 0)], [Vector2(0, 1), Vector2((g - arm) / 2, g - arm)],
				[Vector2(-1, 0), Vector2(0, (g - arm) / 2)], [Vector2(1, 0), Vector2(g - arm, (g - arm) / 2)]]:
			var b := sb.duplicate() as StyleBoxFlat
			b.bg_color = HELL if jetzt == p[0] else DUNKEL
			draw_style_box(b, Rect2(p[1], Vector2(arm, arm)))
			var v: Vector2 = p[0]
			var m: Vector2 = p[1] + Vector2(arm, arm) / 2
			var q := Vector2(-v.y, v.x)
			draw_colored_polygon(PackedVector2Array([m + v * h, m - v * h * 0.7 + q * h, m - v * h * 0.7 - q * h]), PFEIL)
