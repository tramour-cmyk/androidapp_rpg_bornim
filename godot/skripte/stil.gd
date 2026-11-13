class_name Stil
extends RefCounted
# 399.1 (Chef 28.10., 14:38 „das alte Spiel nehmen … die Schriftart umstellen und auch in den Dialogen“; 14:39 „an die Designvorgaben
# halten“): Farben und Schrift der schwarzen Schirme wie im alten Spiel (Theme.kt Veil, DialogDraft.kt BoxInk), DESIGN-STIL.md
# „Oberfläche“: eine Schrift (Alegreya) ueberall, Titel und Knoepfe in gesperrten Versalien, Kaesten schwarz mit duennem Goldrand,
# Text in gebrochenem Weiss, Hervorhebungen in gedaempftem Gold. Masse in dp/sp des alten Spiels (AktionsKnopf.DP, TypeLook.scale).

const TEXT := Color("e6ddcb")       # Veil.text, gebrochenes Weiss
const DIM := Color("948a78")        # Veil.dim
const GOLD := Color("b59a6a")       # Veil.gold, gedaempftes Gold
const BRIGHT := Color("d9bc82")     # Veil.bright
const RIM := Color("b59a6aaa")      # Veil.rim
const LINE := Color("9a8155")       # Veil.line
const RAISED := Color("17140f")     # Veil.raised
const WARN := Color("d9785a")       # Veil.warn (399.1 Erschaffung: Punkte uebrig)
# 586a (Chef 05.11., 09:39: „586a 7-12“): die Titel der Fenster und Rueckfragen so gross wie die Titel der Schirme (22 sp, 549a)
const TITEL_SP := 22.0
# 498 (Chef 03.11., 07:13: „scheint im Godot-Spiel die Schrift kleiner zu sein … Auch wenn der Text der gleiche ist“): gemessen
# (tests/masse_498.gd) sind Groesse und Zeile bei 411 dp und Schriftgroesse 1,0 gleich wie alt (16 sp: 42 px, alt 41,5 px); die alte
# Fassung rechnete sp aber nach der Schriftgroesse des Handys (Einstellungen, Anzeige; Compose sp = dp x fontScale), Godot fest.
# Jetzt wie alt: der Faktor des Handys (TypedValue sp gegen dp bei 16 sp, auch nichtlinear ab Android 14), sonst 1.
static var geraet: Dictionary = _geraet_sicher()   # {dichte, faktor, breite_dp} oder leer (nicht Android, Fehler)
static var schriftfaktor: float = float(geraet.get("faktor", 1.0))
static var SP := AktionsKnopf.DP * 1.04 * schriftfaktor   # sp mit TypeLook.scale fuer Alegreya (Theme.kt scales[2])

## ein Fehler im Java-Aufruf bricht nur _geraet ab (Rueckgabe null), der Start bleibt bei Faktor 1
static func _geraet_sicher() -> Dictionary:
	var g = _geraet()
	return g if typeof(g) == TYPE_DICTIONARY else {}

static func _geraet():
	if OS.get_name() != "Android" or not Engine.has_singleton("AndroidRuntime"): return {}
	var rt = Engine.get_singleton("AndroidRuntime")
	var ctx = rt.getApplicationContext() if rt else null
	var res = ctx.getResources() if ctx else null
	var m = res.getDisplayMetrics() if res else null
	var tv = JavaClassWrapper.wrap("android.util.TypedValue")
	if m == null or tv == null: return {}
	var dp = tv.applyDimension(1, 16.0, m)   # COMPLEX_UNIT_DIP
	var sp = tv.applyDimension(2, 16.0, m)   # COMPLEX_UNIT_SP
	if typeof(dp) != TYPE_FLOAT or typeof(sp) != TYPE_FLOAT or float(dp) <= 0.0: return {}
	var d := float(dp) / 16.0
	var g := {"dichte": d, "faktor": clampf(float(sp) / float(dp), 0.85, 2.0), "breite_dp": DisplayServer.screen_get_size().x / d}
	print("SCHRIFT498 ", g)
	return g

static var _schrift: FontFile
static var _halbfett: FontFile
static var _varianten := {}

static func schrift() -> FontFile:
	if _schrift == null: _schrift = load("res://kampf/schrift/alegreya_regular.ttf")
	return _schrift

# 584 (Abgleich 512b: „kein halbfetter Schnitt“): der halbfette Schnitt wie alt (Theme.kt Serif: alegreya_semibold, FontWeight.SemiBold),
# echt statt kuenstlich verdickt; fehlt die Datei, der gerade Schnitt
static func halbfett() -> FontFile:
	if _halbfett == null:
		_halbfett = load("res://kampf/schrift/alegreya_semibold.ttf") if ResourceLoader.exists("res://kampf/schrift/alegreya_semibold.ttf") else schrift()
	return _halbfett

# Alegreya mit Sperrung (sp) und, fuer erzaehlten Text, schraeg wie Compose FontStyle.Italic (es gibt nur den geraden Schnitt)
static func variante(sperrung_sp: float, schraeg := false, fett := false) -> FontVariation:
	var k := "%.2f/%s/%s" % [sperrung_sp, schraeg, fett]
	if not _varianten.has(k):
		var v := FontVariation.new()
		v.base_font = halbfett() if fett else schrift()
		v.spacing_glyph = int(round(sperrung_sp * SP))
		v.opentype_features = {TextServerManager.get_primary_interface().name_to_tag("lnum"): 1}   # Ziffern auf der Linie wie alt (Theme.kt Txt „lnum“); Alegreya hat sonst Mediaevalziffern
		# 583 (Abgleich 512b): Transform2D(xx, xy, yx, yy) geht als FreeType-Matrix an die Umrisse, x' = x + 0,2 · y kippt wie Italic
		# (Godot-Handbuch zu variation_transform); die alte Zeile scherte senkrecht: nicht schraeg, i-Punkte verrutscht
		if schraeg: v.variation_transform = Transform2D(Vector2(1, 0.2), Vector2(0, 1), Vector2.ZERO)
		_varianten[k] = v
	return _varianten[k]

static func zeile(t: String, groesse_sp: float, farbe: Color, sperrung_sp := 0.0, schraeg := false, fett := false) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_override("font", variante(sperrung_sp, schraeg, fett))
	l.add_theme_font_size_override("font_size", int(round(groesse_sp * SP)))
	l.add_theme_color_override("font_color", farbe)
	return l

# Kasten wie PixelButton im schwarzen Look: schwarz, Rand 1 dp Veil.line; gewaehlt Veil.raised mit 1,5 dp Veil.bright
static func kasten(grund: Color, rand: Color, breite_dp: float) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = grund
	s.border_color = rand
	s.set_border_width_all(maxi(1, int(round(breite_dp * AktionsKnopf.DP))))
	return s

# ---------------------------------------------------------------- Bausteine der Seiten (870.4: aus erschaffung.gd, das entfaellt)
# Wie Theme.kt im schwarzen Look, ohne Kasten nach 549a (630): Text, Kopfzeile, Luecke, Wahlfeld, − und +, dazu der alte Knopf mit
# Rahmen (Hauptmenue, Testmenue) und der Rahmen um Inhalt (Panel)

static func wahlfeld(t: String, an: bool, tat: Callable, frei := true) -> Control:
	var farbe := Stil.BRIGHT if an else (Stil.GOLD if frei else Color(Stil.DIM, 0.75))   # 470 (549a): nicht waehlbar gedaempft, lesbar
	var l := Stil.zeile(t.to_upper().replace("ß", "SS"), 14, farbe, 1.2)
	l.name = "Text"
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size.y = 48 * AktionsKnopf.DP
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
	l.custom_minimum_size = Vector2(48, 48) * AktionsKnopf.DP
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p := Spielstaende.tippbar(l, tat if an else func(): pass)
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	p.set_meta("an", an)
	return p

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
	c.custom_minimum_size = Vector2(breit_dp, hoch_dp) * AktionsKnopf.DP
	return c

# Panel auf Schwarz: Rand 1 dp Veil.line, innen 14 dp seitlich, 10 dp oben und unten
static func rahmen(innen: Control) -> PanelContainer:
	var p := PanelContainer.new()
	var s := Stil.kasten(Color.BLACK, Stil.LINE, 1.0)
	s.content_margin_left = 14 * AktionsKnopf.DP; s.content_margin_right = 14 * AktionsKnopf.DP
	s.content_margin_top = 10 * AktionsKnopf.DP; s.content_margin_bottom = 10 * AktionsKnopf.DP
	p.add_theme_stylebox_override("panel", s)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.add_child(innen)
	return p

# PixelButton auf Schwarz: 48 dp, Versalien 13 sp gesperrt 1,2 sp; gewaehlt Veil.raised mit 1,5 dp Veil.bright; gesperrt blass
static func knopf(t: String, was: Callable, gewaehlt := false) -> Button:
	var b := Button.new()
	b.text = t.to_upper().replace("ß", "SS")   # Helfer 17:24: „SCHLIEßEN“; Compose schrieb „SCHLIESSEN“
	b.custom_minimum_size = Vector2(0, 48 * AktionsKnopf.DP)
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
		s.content_margin_left = 6 * AktionsKnopf.DP; s.content_margin_right = 6 * AktionsKnopf.DP
	for z in ["normal", "hover", "focus"]: b.add_theme_stylebox_override(z, normal)
	b.add_theme_stylebox_override("pressed", gedrueckt)
	b.add_theme_stylebox_override("disabled", blass)
	b.pressed.connect(was)
	return b
