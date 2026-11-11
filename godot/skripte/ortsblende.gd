class_name Ortsblende
extends Control
# 399.1 Schwarzblende zwischen Orten wie alt (24.1, InterludeUi.kt MapVeil und InterludeVeil, InterludeClock.kt, Interlude.kt):
# beim Spielbeginn und beim ersten Besuch der Name des Orts gesperrt, Zierleiste, darunter ein Satz (661: worte_spalte); sonst nur der Name; eine Tuer
# im Dorf blinzelt nur. Die Worte kommen, stehen, bis sie zu lesen sind (Tippen beendet frueher), gehen, dann steigt der Ort aus
# dem Schwarz. In Godot ist alles schon gezeichnet, wenn die Blende kommt: ohne Ladebalken und Spruch (267.1). Zeiten und Saetze
# aus core: intro.json „blende“ (IntroExport.kt).

signal fertig

const DP := AktionsKnopf.DP
# VeilInk (InterludeUi.kt)
const TEXT := Color("e6ddcb")

static var letzter := {}                  # VeilMemory.last: der zuletzt gezeigte Satz, nie zweimal hintereinander

var art: Dictionary
var art_name := ""
var ms := 0.0
var verlassen := -1.0                     # leaveMs
var lesen := 0.0                          # 556: Lesezeit der Worte (readMs)
var tippt := false
var worte: Control

static func daten() -> Dictionary: return Zwischenbild.daten().get("blende", {})

## 556: der Grund jeder Blende, reines Schwarz ueber den ganzen Schirm
static func schwarz() -> ColorRect:
	var r := ColorRect.new()
	r.color = Color.BLACK
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

## t63.1, 556 (Chef 04.11., 07:52 „teilweise zu kurz zum Lesen“): wie lange Worte mit [zeichen] Zeichen stehen (InterludeClock.readMs);
## alt stand die Blende zwischen Orten, bis die Karte gezeichnet war (Sekunden), in Godot ist alles schon da
static func lese_ms(zeichen: int, d: Dictionary) -> float:
	return float(d.get("lesen_ms", 1000)) + float(d.get("lesen_je_zeichen_ms", 40)) * zeichen

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
	if verlassen < 0.0 and (t >= maxf(float(art["mind_ms"]), lesen) or tippt): verlassen = t
	var geht := 1.0 - clampf((t - verlassen) / maxf(1.0, aus), 0.0, 1.0) if verlassen >= 0.0 else 1.0
	var w := 0.0
	if art_name != "BLINK":
		w = glatt(minf(1.0 if ein == 0.0 else clampf(t / ein, 0.0, 1.0), geht))
	var s := 1.0 - glatt(clampf((t - verlassen - aus * 2.0 / 3.0) / weg, 0.0, 1.0)) if verlassen >= 0.0 else 1.0
	return [s, w, s <= 0.0]

func _init(art_: String, name_: String, satz) -> void:
	art_name = art_
	art = daten().get("arten", {}).get(art_, {"ein_ms": 0, "mind_ms": 0, "aus_ms": 0, "schleier_aus_ms": 500})
	if art_ != "BLINK":
		lesen = lese_ms(name_.length() + (Sprache.t(satz).length() if satz != null else 0), daten())
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# 556 (Chef 04.11., 07:52: „nicht komplett schwarz im Hintergrund, sondern haben ein ‚Leuchten‘ in der Mitte. Bitte klassische
	# schwarz. Das andere wirft Ringe.“): reines Schwarz statt der Vignette (der Radialverlauf in 8 Bit zeigte Stufen)
	add_child(Ortsblende.schwarz())
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mitte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(mitte)
	worte = Ortsblende.worte_spalte(name_, Sprache.t(satz) if satz != null else "")
	mitte.add_child(worte)
	_stelle()

## 661 (Chef 08.11., 15:11; 10.11., 09:34 Kramladen „wieder relativ klein“; 10:17 „die Blenden wie von dir vorgeschlagen …
## gebrochene Zierleiste gefällt mir“): ein Aufbau fuer alle Blenden, Ort, Rast (753), Kampf normal, Hinterhalt, Boss: der Name
## gesperrt so gross wie die Titel der Schirme ohne Kasten (549a), darunter deren Zierleiste mit Raute (Spielstaende.zier), dann der
## Satz gross, beim Kampf darunter der Satz des Gegners etwas kleiner. Der Kampf unterscheidet sich nur durch Tempo und Klang, der
## Hinterhalt dazu durch die gebrochene Zierleiste. Vorher (556, 753, 402): Name 13 sp, Goldstrich 44 dp, Satz 19 sp; im Kampf
## erst der Satz, dann Strich und Name 24/30 sp.
const NAME_SP := Stil.TITEL_SP            # 22 sp wie die Titel der Schirme (586a)
const SATZ_SP := 21.0
const SATZ_ZEILE := 31.0
const NEBEN_SP := 17.0
const NEBEN_ZEILE := 25.0

static func worte_spalte(name_: String, satz: String, neben := "", gebrochen := false) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override("separation", 0)
	v.add_child(_zeile(name_.to_upper().replace("ß", "SS"), NAME_SP, Stil.GOLD, 3.0, 0.0))
	v.add_child(Stil.luecke(8))
	v.add_child(zier(gebrochen))
	if satz != "":
		v.add_child(Stil.luecke(14))
		v.add_child(_zeile(satz, SATZ_SP, TEXT, 0.6, SATZ_ZEILE))
	if neben != "":
		v.add_child(Stil.luecke(14))
		v.add_child(_zeile(neben, NEBEN_SP, Color(TEXT, 0.8), 0.4, NEBEN_ZEILE))
	return v

static func _zeile(text: String, sp: float, farbe: Color, sperrung: float, zeile_sp: float) -> Label:
	var l := Stil.zeile(text, sp, farbe, sperrung)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if zeile_sp > 0.0: l.add_theme_constant_override("line_spacing", int((zeile_sp - sp * 1.2) * Stil.SP))
	return l

## die Zierleiste der Schirme (549a); beim Hinterhalt gebrochen: jede Seite zweimal gerissen und versetzt, die Raute gespalten
static func zier(gebrochen := false) -> Control:
	if not gebrochen: return Spielstaende.zier()
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, 14 * DP)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func():
		var mi := c.size / 2
		var w := 1.0 * DP
		var x := c.size.x
		# je Seite drei Stuecke mit zwei Rissen (Luecke 1,5 dp), aussen ruhig, zur Raute hin staerker versetzt (dp)
		var luecke := 1.5 * DP
		for seite in [[x * 0.12, mi.x - 10 * DP, [0.0, 1.6, -1.2]], [x * 0.88, mi.x + 10 * DP, [0.0, -1.6, 1.2]]]:
			var aussen: float = seite[0]; var innen: float = seite[1]
			var punkte := [aussen, lerp(aussen, innen, 0.55), lerp(aussen, innen, 0.8), innen]
			var richtung := signf(innen - aussen)
			for i in 3:
				var von: float = punkte[i] + (richtung * luecke / 2 if i > 0 else 0.0)
				var bis: float = punkte[i + 1] - (richtung * luecke / 2 if i < 2 else 0.0)
				var y: float = mi.y + float(seite[2][i]) * DP
				c.draw_line(Vector2(von, y), Vector2(bis, y), Stil.RIM, w, true)
		# Raute senkrecht gespalten, die Haelften gegeneinander versetzt
		var r := 4.5 * DP
		var links := mi + Vector2(-1.4, -1.0) * DP
		var rechts := mi + Vector2(1.4, 1.0) * DP
		c.draw_polyline(PackedVector2Array([links + Vector2(0, -r), links + Vector2(-r, 0), links + Vector2(0, r)]), Stil.GOLD, w, true)
		c.draw_polyline(PackedVector2Array([rechts + Vector2(0, -r), rechts + Vector2(r, 0), rechts + Vector2(0, r)]), Stil.GOLD, w, true))
	return c

func _ready() -> void:
	worte.custom_minimum_size.x = get_viewport_rect().size.x - 2 * 36 * DP
	_stelle()

# 619 (Chef 07.11., 268.18: „Aktionsknopf drückt die Blende gleich mit weg“): wie alt (InterludeUi detectTapGestures) zaehlt nur ein
# ganzer Tipp auf der Blende, Druck und Loslassen; ein Finger, der schon unten war, als sie kam, beendet sie nicht
var unten := false

func _gui_input(e: InputEvent) -> void:
	if not (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT) and not e is InputEventScreenTouch: return
	if e.pressed: unten = true
	elif unten: tippt = true
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
