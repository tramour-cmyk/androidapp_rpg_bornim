class_name KapitelSchirm
extends Control
# 537: Kapitelende wie alt (ShopScreen.kt ChapterEndScreen, D2.1): schwarz, oben der Titel des Spiels (28 sp, fett, Veil.bright),
# darunter ein Kasten mit duennem Goldrand, rollend Story.chapterEndText (18 sp) und die Zeile des Helden (Name · Volk · Klasse ·
# Stufe, 15 sp fett), unten „Weiter“ (Game.advance, dann speichern). Was danach kommt (Tempelszene, Morgen), tut spiel.gd.

signal weiter
const DP := AktionsKnopf.DP

var hw: Heldwerte
var text: Dictionary

func _init(hw_: Heldwerte, text_: Dictionary) -> void:
	hw = hw_
	text = text_
	name = "Kapitelende"

static func fett(l: Label, farbe: Color) -> Label:   # wie menue.gd: es gibt nur den geraden Schnitt, fett ueber einen Umriss
	l.add_theme_constant_override("outline_size", int(DP * 0.6))
	l.add_theme_color_override("font_outline_color", farbe)
	return l

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	Rand.ruecke(self, Rand.oben(get_viewport()))   # 399.4: unter der Kamera des Handys
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right", "top", "bottom"]: rand.add_theme_constant_override("margin_" + s, int(16 * DP))
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", 0)
	rand.add_child(spalte)
	spalte.add_child(Erschaffung.luecke(24))
	var titel := fett(Stil.zeile(Sprache.u("title"), 28, Stil.BRIGHT), Stil.BRIGHT)
	titel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	spalte.add_child(titel)
	spalte.add_child(Erschaffung.luecke(16))
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	var innen := VBoxContainer.new()
	innen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	innen.add_theme_constant_override("separation", 0)
	rolle.add_child(innen)
	innen.add_child(Erschaffung.txt(Sprache.t(text), 18))
	innen.add_child(Erschaffung.luecke(12))
	var d := Heldwerte.lade()
	var wer := "%s · %s · %s · %s %d" % [hw.name, Sprache.t(d["voelker"][hw.volk]["name"]), Sprache.t(d["klassen"][hw.klasse]["name"]),
		Sprache.u("level"), hw.stufe]
	innen.add_child(fett(Erschaffung.txt(wer, 15), Stil.TEXT))
	var kasten := Erschaffung.kasten(rolle)
	kasten.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(kasten)
	spalte.add_child(Erschaffung.luecke(12))
	var k := Erschaffung.knopf(Sprache.u("next"), func(): weiter.emit())
	k.name = "Weiter"
	spalte.add_child(k)
