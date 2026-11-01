class_name Ortsblende
extends Control
# 399.1 Schwarzblende zwischen Orten wie alt (24.1, InterludeUi.kt MapVeil und InterludeVeil, InterludeClock.kt, Interlude.kt):
# beim Spielbeginn und beim ersten Besuch der Name des Orts klein und gesperrt, darunter ein Satz; sonst nur der Name; eine Tuer
# im Dorf blinzelt nur. Die Worte kommen, stehen, bis sie zu lesen sind (Tippen beendet frueher), gehen, dann steigt der Ort aus
# dem Schwarz. In Godot ist alles schon gezeichnet, wenn die Blende kommt: ohne Ladebalken und Spruch (267.1). Zeiten und Saetze
# aus core: intro.json „blende“ (IntroExport.kt).

signal fertig

const DP := AktionsKnopf.DP
# VeilInk (InterludeUi.kt)
const TEXT := Color("e6ddcb")
const NAME := Color("b59a6a")
const LINIE := Color(0xb5 / 255.0, 0x9a / 255.0, 0x6a / 255.0, 0x66 / 255.0)
const KERN := Color("15110e")

static var letzter := {}                  # VeilMemory.last: der zuletzt gezeigte Satz, nie zweimal hintereinander

var art: Dictionary
var art_name := ""
var ms := 0.0
var verlassen := -1.0                     # leaveMs
var tippt := false
var worte: Control

static func daten() -> Dictionary: return Zwischenbild.daten().get("blende", {})

# InterludeClock.kindFor: FULL beim Spielbeginn ([von] leer) und beim ersten Besuch, BLINK von Tuer zu Tuer im Dorf, sonst NAME
static func art_fuer(von: String, nach: String, erster: bool) -> String:
	var dorf: Array = daten().get("dorf", [])
	if von == "" or erster: return "FULL"
	if von in dorf and nach in dorf: return "BLINK"
	return "NAME"

# Interlude.placeLines: was beim Betreten von [karte] passt; nachts kommen die eigenen Saetze der Nacht doppelt ins Los
static func saetze(karte: String, z: Zustand, nacht: bool) -> Array:
	var alle: Array = daten().get("orte", {}).get(karte, []).filter(func(l):
		return (not l.has("nacht") or bool(l["nacht"]) == nacht) and (not l.has("braucht") or z.has(String(l["braucht"]))) \
			and (not l.has("ohne") or not z.has(String(l["ohne"]))))
	var eigen := alle.filter(func(l): return l.has("nacht") and bool(l["nacht"]))
	if eigen.is_empty(): return alle
	return eigen + eigen + alle.filter(func(l): return not l.has("nacht"))

# Interlude.pick: einer zufaellig, nie der letzte, ausser es gibt nur ihn
static func waehle(l: Array, zuletzt, zufall: RandomNumberGenerator):
	if l.is_empty(): return null
	var frei := l.filter(func(x): return x != zuletzt)
	if frei.is_empty(): frei = l
	return frei[zufall.randi_range(0, frei.size() - 1)]

static func glatt(x: float) -> float: return x * x * (3.0 - 2.0 * x)

# InterludeClock.at, alles gezeichnet: [Schleier, Worte, vorbei]
func bei(t: float) -> Array:
	var ein := float(art["ein_ms"]); var aus := float(art["aus_ms"]); var weg := float(art["schleier_aus_ms"])
	if verlassen < 0.0 and (t >= float(art["mind_ms"]) or tippt): verlassen = t
	var geht := 1.0 - clampf((t - verlassen) / maxf(1.0, aus), 0.0, 1.0) if verlassen >= 0.0 else 1.0
	var w := 0.0
	if art_name != "BLINK":
		w = glatt(minf(1.0 if ein == 0.0 else clampf(t / ein, 0.0, 1.0), geht))
	var s := 1.0 - glatt(clampf((t - verlassen - aus * 2.0 / 3.0) / weg, 0.0, 1.0)) if verlassen >= 0.0 else 1.0
	return [s, w, s <= 0.0]

func _init(art_: String, name_: String, satz) -> void:
	art_name = art_
	art = daten().get("arten", {}).get(art_, {"ein_ms": 0, "mind_ms": 0, "aus_ms": 0, "schleier_aus_ms": 500})
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# ein Hauch Vignette, damit das Schwarz nicht wie ein Absturz aussieht
	var grund := TextureRect.new()
	grund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grund.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grund.stretch_mode = TextureRect.STRETCH_SCALE
	grund.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	g.colors = PackedColorArray([KERN, Color("0a0807"), Color.BLACK])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.46)
	t.fill_to = Vector2(0.5, 0.46 + 0.62)   # Radius 0,62 der groesseren Seite (hochkant: der Hoehe)
	t.width = 64; t.height = 128
	grund.texture = t
	add_child(grund)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mitte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(mitte)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override("separation", 0)
	mitte.add_child(v)
	worte = v
	var n := Stil.zeile(name_.to_upper(), 13, NAME, 4.0)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(n)
	if satz != null:
		v.add_child(Erschaffung.luecke(14))
		var r := ColorRect.new()
		r.color = LINIE
		r.custom_minimum_size = Vector2(44, 1) * DP
		r.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(r)
		v.add_child(Erschaffung.luecke(18))
		var l := Stil.zeile(Sprache.t(satz), 19, TEXT, 0.6)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_constant_override("line_spacing", int((28 - 19 * 1.2) * Stil.SP))
		v.add_child(l)
	_stelle()

func _ready() -> void:
	worte.custom_minimum_size.x = get_viewport_rect().size.x - 2 * 36 * DP
	_stelle()

func _gui_input(e: InputEvent) -> void:
	if (e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed):
		tippt = true
		accept_event()

func _process(dt: float) -> void:
	ms += dt * 1000.0
	if _stelle():
		set_process(false)
		fertig.emit()

func _stelle() -> bool:
	var b := bei(ms)
	modulate.a = b[0]
	worte.modulate.a = b[1]
	if b[0] < 0.5: mouse_filter = Control.MOUSE_FILTER_IGNORE   # der Ort nimmt das Tippen wieder, sobald er aufsteigt
	return b[2]
