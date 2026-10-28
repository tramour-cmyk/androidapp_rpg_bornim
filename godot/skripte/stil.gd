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
const SP := AktionsKnopf.DP * 1.04  # sp mit TypeLook.scale fuer Alegreya (Theme.kt scales[2])

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
		if schraeg: v.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)
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
