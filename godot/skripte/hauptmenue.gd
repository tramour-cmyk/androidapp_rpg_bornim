class_name Hauptmenue
extends Control
# 399 (Chef 28.10., 12:34: spielbar zuerst): Hauptmenue (292) und Erschaffung wie das alte Spiel (TitleScreen, CreateScreen), nur
# Funktion: schwarz, goldene Knoepfe, Texte aus core (texte.json „ui“). Fortsetzen, wenn ein Spielstand liegt; Neues Spiel fuehrt
# durch Name, Volk, Klasse, Zusammenfassung. Ende: Signal fertig({"laden": true}) oder fertig({"name", "volk", "klasse"}).
# Aussehen des Hauptmenues (Entwurf A, Feuer B) folgt mit 292.2, 292.4.

signal fertig(wahl: Dictionary)

const VOELKER := ["HUMAN", "ELF", "DWARF", "HALFLING", "HALF_ORC"]
const KLASSEN := ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]
var st: Steuerung
var box: VBoxContainer
var wahl := {}

func _init(s: Steuerung) -> void:
	st = s
	name = "Hauptmenue"

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	var vs := get_viewport().get_visible_rect().size
	box.offset_left = vs.x * 0.1; box.offset_right = -vs.x * 0.1; box.offset_top = vs.y * 0.2
	box.add_theme_constant_override("separation", int(vs.y * 0.018))
	add_child(box)
	titel()

func leer() -> void:
	for c in box.get_children(): c.queue_free()

func zeile(t: String, groesse: int, farbe := Steuerung.GOLD) -> Label:
	var l := Label.new()
	l.text = t
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", groesse)
	l.add_theme_color_override("font_color", farbe)
	box.add_child(l)
	return l

func knopf(t: String, was: Callable) -> Button:
	var b := st.knopf_neu(t, Vector2(0, 120), 42)
	b.pressed.connect(was)
	box.add_child(b)
	return b

func titel() -> void:
	leer()
	zeile(Sprache.u("title"), 72)
	zeile(Sprache.u("subtitle"), 36, Color(0.93, 0.88, 0.76))
	box.add_child(Control.new())
	if Spielstand.gibt_es(): knopf(Sprache.u("continueGame"), func(): fertig.emit({"laden": true}))
	knopf(Sprache.u("newGame"), name_waehlen)
	knopf(Sprache.u("language"), func(): Sprache.wechsle(); titel())

func name_waehlen() -> void:
	leer()
	zeile(Sprache.u("yourName"), 48)
	var e := LineEdit.new()
	e.text = String(wahl.get("name", Sprache.u("defaultName")))
	e.max_length = 16
	e.custom_minimum_size = Vector2(0, 110)
	e.add_theme_font_size_override("font_size", 44)
	box.add_child(e)
	knopf(Sprache.u("next"), func():
		wahl["name"] = e.text.strip_edges() if e.text.strip_edges() != "" else Sprache.u("defaultName")
		volk_waehlen())
	knopf(Sprache.u("back"), titel)

func volk_waehlen() -> void:
	leer()
	zeile(Sprache.u("chooseRace"), 48)
	for v in VOELKER:
		knopf(Sprache.t(Heldwerte.lade()["voelker"][v]["name"]), func(): wahl["volk"] = v; klasse_waehlen())
	knopf(Sprache.u("back"), name_waehlen)

func klasse_waehlen() -> void:
	leer()
	zeile(Sprache.u("chooseClass"), 48)
	for k in KLASSEN:
		knopf(Sprache.t(Heldwerte.lade()["klassen"][k]["name"]), func(): wahl["klasse"] = k; zusammenfassung())
	knopf(Sprache.u("back"), volk_waehlen)

func zusammenfassung() -> void:
	leer()
	zeile(Sprache.u("summary"), 48)
	var d: Dictionary = Heldwerte.lade()
	zeile("%s · %s · %s" % [wahl["name"], Sprache.t(d["voelker"][wahl["volk"]]["name"]), Sprache.t(d["klassen"][wahl["klasse"]]["name"])], 40, Color(0.93, 0.88, 0.76))
	knopf(Sprache.u("start"), func(): fertig.emit(wahl.duplicate()))
	knopf(Sprache.u("back"), klasse_waehlen)
