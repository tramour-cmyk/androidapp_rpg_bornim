class_name KapitelSchirm
extends Control
# 537: Kapitelende wie alt (ShopScreen.kt ChapterEndScreen, D2.1): schwarz, oben der Titel des Spiels (28 sp, fett, Veil.bright),
# darunter ein Kasten mit duennem Goldrand, rollend Story.chapterEndText (18 sp) und die Zeile des Helden (Name · Volk · Klasse ·
# Stufe, 15 sp fett), unten „Weiter“ (Game.advance, dann speichern). Was danach kommt (Tempelszene, Morgen), tut spiel.gd.

signal weiter
const DP := AktionsKnopf.DP

var hw: BrsHeld
var text: Dictionary

func _init(hw_: BrsHeld, text_: Dictionary) -> void:
	hw = hw_
	text = text_
	name = "Kapitelende"

static func fett(l: Label, farbe: Color) -> Label:   # wie menue.gd: es gibt nur den geraden Schnitt, fett ueber einen Umriss
	l.add_theme_constant_override("outline_size", int(DP * 0.6))
	l.add_theme_color_override("font_outline_color", farbe)
	return l

# 557 (Chef 04.11., 13:42, Gruppe 557): Entwurf B „ohne Kasten“ (549a), im Spiel weiter „“ bis zum Urteil: reiner Textschirm ohne
# Goldkasten; oben der Titel in gesperrten Versalien mit Zierlinie (nicht halbfett), der Text frei auf Schwarz, „Ende von Kapitel 1“
# als eigene Zeile zwischen Linien, die Heldenzeile zwischen Linien in Gold und groesser, unten „WEITER ›“ als Hauptwahl in Gold
# (Prueferbefunde 00:38: leere Kastenhaelfte, Heldenzeile klein, Weiter unauffaellig, Titel halbfett)
static var entwurf := "B"   # 557 eingeschaltet (Archiv 05.11., 08:18: „557 wie gebaut“; Runde 5 Vorlage 2 mit Mängelton, Chef 04.11., 19:54)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	Rand.ruecke(self, Rand.oben(get_viewport()))   # 399.4: unter der Kamera des Handys
	if entwurf == "B":
		_ready_b()
		return
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
	spalte.add_child(Stil.luecke(24))
	var titel := fett(Stil.zeile(Sprache.u("title"), 28, Stil.BRIGHT), Stil.BRIGHT)
	titel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	spalte.add_child(titel)
	spalte.add_child(Stil.luecke(16))
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	var innen := VBoxContainer.new()
	innen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	innen.add_theme_constant_override("separation", 0)
	rolle.add_child(innen)
	innen.add_child(Stil.txt(Sprache.t(text), 18))
	innen.add_child(Stil.luecke(12))
	var wer := ErschaffungBrs.wer(hw.volk, hw.herkunft, hw.stufe, hw.name)   # 870.4 [870.14.wanderer.kapitel]
	innen.add_child(fett(Stil.txt(wer, 15), Stil.TEXT))
	var kasten := Stil.rahmen(rolle)
	kasten.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(kasten)
	spalte.add_child(Stil.luecke(12))
	var k := Stil.knopf(Sprache.u("next"), func(): weiter.emit())
	k.name = "Weiter"
	spalte.add_child(k)

func _ready_b() -> void:
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right"]: rand.add_theme_constant_override("margin_" + s, int(24 * DP))
	rand.add_theme_constant_override("margin_top", int(36 * DP)); rand.add_theme_constant_override("margin_bottom", int(16 * DP))
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", 0)
	rand.add_child(spalte)
	var titel := Stil.zeile(Sprache.u("title").to_upper(), 22, Stil.GOLD, 3.0)
	titel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	spalte.add_child(titel)
	spalte.add_child(Stil.luecke(6))
	spalte.add_child(Spielstaende.zier())
	spalte.add_child(Stil.luecke(18))
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(rolle)
	var innen := VBoxContainer.new()
	innen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	innen.add_theme_constant_override("separation", 0)
	rolle.add_child(innen)
	# der Text in Absaetzen; die Zeile „ENDE VON KAPITEL 1“ (in Versalien im Text) steht fuer sich zwischen Linien in Gold
	for absatz in Sprache.t(text).split("\n\n"):
		if absatz == absatz.to_upper() and absatz.strip_edges() != "":
			innen.add_child(Stil.luecke(8))
			innen.add_child(Spielstaende.linie())
			innen.add_child(Stil.luecke(14))
			var e := Stil.zeile(absatz, 17, Stil.BRIGHT, 3.0)
			e.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			e.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			innen.add_child(e)
			innen.add_child(Stil.luecke(14))
			innen.add_child(Spielstaende.linie())
			innen.add_child(Stil.luecke(22))
			continue
		innen.add_child(Stil.txt(absatz, 18))
		innen.add_child(Stil.luecke(14))
	spalte.add_child(Spielstaende.linie())
	var held := VBoxContainer.new()
	held.add_theme_constant_override("separation", int(2 * DP))
	var nm := Stil.zeile(hw.name.to_upper(), 17, Stil.GOLD, 2.5)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	held.add_child(Stil.luecke(10))
	held.add_child(nm)
	var wer := Stil.zeile(ErschaffungBrs.wer(hw.volk, hw.herkunft, hw.stufe), 16, Stil.TEXT)   # 870.4
	wer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	held.add_child(wer)
	held.add_child(Stil.luecke(10))
	spalte.add_child(held)
	spalte.add_child(Spielstaende.linie())
	spalte.add_child(Stil.luecke(8))
	if Spielstaende.vorlage2:   # 557 Runde 4 (Chef 17:40: „ein Weiter, wenn dann rechts“): „WEITER ›“ rechts, so gross wie jeder Knopf
		var kw := Spielstaende.knopf("haupt", Sprache.u("next"), func(): weiter.emit())
		kw.name = "Weiter"
		spalte.add_child(Spielstaende.knopfzeile(null, kw))
	else:
		var k := Spielstaende.hauptwahl(Sprache.u("next"), func(): weiter.emit())
		k.name = "Weiter"
		k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spalte.add_child(k)
	if Spielstaende.vorlage2: Spielstaende.folge_inhalt(spalte, rolle, innen)   # 557 Vorlage 2: Weiter folgt dem Text (Chef 14:21, Bild 6)
