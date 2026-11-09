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
static var _varianten := {}

static func schrift() -> FontFile:
	if _schrift == null: _schrift = load("res://kampf/schrift/alegreya_regular.ttf")
	return _schrift

# Alegreya mit Sperrung (sp) und, fuer erzaehlten Text, schraeg wie Compose FontStyle.Italic (es gibt nur den geraden Schnitt)
static func variante(sperrung_sp: float, schraeg := false) -> FontVariation:
	var k := "%.2f/%s" % [sperrung_sp, schraeg]
	if not _varianten.has(k):
		var v := FontVariation.new()
		v.base_font = schrift()
		v.spacing_glyph = int(round(sperrung_sp * SP))
		v.opentype_features = {TextServerManager.get_primary_interface().name_to_tag("lnum"): 1}   # Ziffern auf der Linie wie alt (Theme.kt Txt „lnum“); Alegreya hat sonst Mediaevalziffern
		# 583 (Abgleich 512b): Transform2D(xx, xy, yx, yy) geht als FreeType-Matrix an die Umrisse, x' = x + 0,2 · y kippt wie Italic
		# (Godot-Handbuch zu variation_transform); die alte Zeile scherte senkrecht: nicht schraeg, i-Punkte verrutscht
		if schraeg: v.variation_transform = Transform2D(Vector2(1, 0.2), Vector2(0, 1), Vector2.ZERO)
		_varianten[k] = v
	return _varianten[k]

static func zeile(t: String, groesse_sp: float, farbe: Color, sperrung_sp := 0.0, schraeg := false) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_override("font", variante(sperrung_sp, schraeg))
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
