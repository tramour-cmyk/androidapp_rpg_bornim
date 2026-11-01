class_name Rand
extends RefCounted
# 399.4 (Test 139, Chef 28.10., 21:4x: „Ganz oben ist auf dem Handy eine Kamera … manche Sachen kann man gar nicht lesen … nimm oben
# auch sozusagen den Rand weg. Den kann man ja trotzdem schwarz machen“): wie alt (App.kt safeDrawingPadding, die Leisten verborgen)
# bleibt oben frei, was die Kamera verdeckt (sichere Flaeche des Geraets); dort liegt ein schwarzes Band ueber allem, die Oberflaechen
# (Steuerung, Menue, Hauptmenue) ruecken darunter. Unten und an den Seiten bleibt alles, wie es ist.

const EBENE := 119                      # unter der Helligkeit (120), ueber Menue, Hauptmenue, Zwischenbild
static var test_oben := -1.0            # Tests ohne Geraet: so hoch statt der sicheren Flaeche
static var beim_start := -1.0           # 399.4 (t143: Rand fehlte): was oben() beim Aufbau der Welt gab, fuer „Gerät“

# Hoehe des Randes oben in Einheiten der Oberflaeche (1080 breit, canvas_items)
static func oben(vp: Viewport) -> float:
	if test_oben >= 0.0: return test_oben
	var w := DisplayServer.window_get_size()
	if w.y <= 0: return 0.0
	var s := DisplayServer.get_display_safe_area()
	return maxf(0.0, float(s.position.y)) * vp.get_visible_rect().size.y / float(w.y)

# ein Control direkt in einer CanvasLayer: oben Angehaengtes rueckt um r hinab, unten Angehaengtes bleibt
static func ruecke(c: Control, r: float) -> void:
	if r <= 0.0: return
	if is_zero_approx(c.anchor_top): c.offset_top += r
	if is_zero_approx(c.anchor_bottom): c.offset_bottom += r

static func band(r: float) -> CanvasLayer:
	var e := CanvasLayer.new()
	e.layer = EBENE
	e.name = "RandOben"
	var b := ColorRect.new()
	b.color = Color.BLACK
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	b.offset_bottom = r
	e.add_child(b)
	e.visible = r > 0.0
	return e
