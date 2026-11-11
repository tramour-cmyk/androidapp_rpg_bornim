class_name Erschaffung
extends RefCounted
# Bausteine der Seite „Neues Spiel“ wie Theme.kt im schwarzen Look, ohne Kasten nach 549a (630): Text, Kopfzeile, Luecke, Wahlfeld,
# − und +, dazu der alte Knopf mit Rahmen (Hauptmenue, Testmenue). Die Seite selbst ist seit 470 (Chef 10.11., 12:58 „470 jetzt“;
# 09:32: „nicht die Herkünfte“) die Erschaffung nach BRS (erschaffung_brs.gd); die alte Klassenwahl nach dem SRD ist weg.

const DP := AktionsKnopf.DP

static func wahlfeld(t: String, an: bool, tat: Callable, frei := true) -> Control:
	var farbe := Stil.BRIGHT if an else (Stil.GOLD if frei else Color(Stil.DIM, 0.75))   # 470 (549a): nicht waehlbar gedaempft, lesbar
	var l := Stil.zeile(t.to_upper().replace("ß", "SS"), 14, farbe, 1.2)
	l.name = "Text"
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size.y = 48 * DP
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p := Spielstaende.tippbar(l, tat if frei or an else func(): pass)
	if an:
		var sb := Stil.kasten(Stil.RAISED, Color(0, 0, 0, 0), 0.0)
		p.add_theme_stylebox_override("panel", sb)
		p.gui_input.connect(func(_e): p.add_theme_stylebox_override("panel", sb), CONNECT_DEFERRED)   # bleibt erhaben nach dem Tippen
	p.set_meta("gewaehlt", an)
	p.set_meta("an", frei or an)
	return p

# − und + ohne Rahmen (549a, wie der Mengenkasten): 48 dp Tippflaeche, aus gedaempft lesbar
static func zahl_knopf(t: String, tat: Callable, an: bool) -> Control:
	var l := Stil.zeile(t, 24, Stil.BRIGHT if an else Stil.DIM)
	l.name = "Text"
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(48, 48) * DP
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p := Spielstaende.tippbar(l, tat if an else func(): pass)
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	p.set_meta("an", an)
	return p

# ---------------------------------------------------------------- Bausteine wie Theme.kt im schwarzen Look

static func kurz(a: String) -> String: return Sprache.t(Heldwerte.lade()["attribute"][a]["kurz"])
static func vorzeichen(n: int) -> String: return "+%d" % n if n >= 0 else str(n)

# Txt auf Schwarz: Alegreya, 0,95 der Groesse, nie kleiner als 13,7 sp, leicht gesperrt
# 584 (Abgleich 512b): [fett] = der halbfette Schnitt wie alt (Theme.kt Txt bold: SemiBold). Wo alt aus fettem Text in Textfarbe ab 15 sp
# einen Kopf in Versalien machte (MenuHead), bleibt es hier halbfett: Versalien nur fuer Titel, Zwischenueberschriften und Knoepfe, nie fuer
# Saetze, Namen oder Zahlen (549a, DESIGN-STIL.md „Schrift“); echte Koepfe setzt der Aufrufer selbst
static func txt(t: String, groesse_sp: float, farbe := Stil.TEXT, fett := false) -> Label:
	var l := Stil.zeile(Spielstaende.ohne_waise(t), maxf(groesse_sp, 13.7) * 0.95, farbe, 0.2, false, fett)   # 557 Runde 5: kein Wort allein in der letzten Zeile (nur Vorlage 2)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

# VeilHead: klein, gesperrte Versalien in Gold
static func kopfzeile(t: String) -> Label:
	return Stil.zeile(t.to_upper(), 12, Stil.GOLD, 3.0)

static func luecke(hoch_dp: float, breit_dp := 0.0) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(breit_dp, hoch_dp) * DP
	return c

# Panel auf Schwarz: Rand 1 dp Veil.line, innen 14 dp seitlich, 10 dp oben und unten
static func kasten(innen: Control) -> PanelContainer:
	var p := PanelContainer.new()
	var s := Stil.kasten(Color.BLACK, Stil.LINE, 1.0)
	s.content_margin_left = 14 * DP; s.content_margin_right = 14 * DP
	s.content_margin_top = 10 * DP; s.content_margin_bottom = 10 * DP
	p.add_theme_stylebox_override("panel", s)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.add_child(innen)
	return p

# PixelButton auf Schwarz: 48 dp, Versalien 13 sp gesperrt 1,2 sp; gewaehlt Veil.raised mit 1,5 dp Veil.bright; gesperrt blass
static func knopf(t: String, was: Callable, gewaehlt := false) -> Button:
	var b := Button.new()
	b.text = t.to_upper().replace("ß", "SS")   # Helfer 17:24: „SCHLIEßEN“; Compose schrieb „SCHLIESSEN“
	b.custom_minimum_size = Vector2(0, 48 * DP)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.clip_text = true
	b.add_theme_font_override("font", Stil.variante(1.2))
	b.add_theme_font_size_override("font_size", int(round(13 * Stil.SP)))
	var farbe := Stil.BRIGHT if gewaehlt else Stil.TEXT
	for z in ["font_color", "font_hover_color", "font_focus_color", "font_hover_pressed_color"]: b.add_theme_color_override(z, farbe)
	b.add_theme_color_override("font_pressed_color", Stil.BRIGHT)
	b.add_theme_color_override("font_disabled_color", Color(Stil.DIM, 0.6))
	var normal := Stil.kasten(Stil.RAISED, Stil.BRIGHT, 1.5) if gewaehlt else Stil.kasten(Color.BLACK, Stil.LINE, 1.0)
	var gedrueckt := Stil.kasten(Stil.RAISED, Stil.BRIGHT, 1.5)
	var blass := Stil.kasten(Color.BLACK, Color(Stil.DIM, 0.4), 1.0)
	for s in [normal, gedrueckt, blass]:
		s.content_margin_left = 6 * DP; s.content_margin_right = 6 * DP
	for z in ["normal", "hover", "focus"]: b.add_theme_stylebox_override(z, normal)
	b.add_theme_stylebox_override("pressed", gedrueckt)
	b.add_theme_stylebox_override("disabled", blass)
	b.pressed.connect(was)
	return b
