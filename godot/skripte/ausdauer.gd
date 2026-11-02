class_name Ausdauer
extends RefCounted
# 399.1 Atem zum Rennen wie alt (Stamina.kt, 86.3, 131): ein voller Vorrat reicht bei Konstitution 10 etwa 6 s, je Punkt Bonus 2 s
# mehr oder weniger, je zwei Stufen 1 s mehr, halb so lange in schwerer Ruestung ohne die Staerke dafuer; der Ausdauertrank
# verdoppelt ihn (86.6). Er fuellt sich in 40 s beim Gehen, in 20 s im Stehen, mit einer Rast sofort. Leer geht der Held, bis ein
# Viertel zurueck ist; betrunken rennt er nicht (181). Gespeichert in Zustand.ausdauer, atemlos.

const GEHEN_MS := 40000.0
const STEHEN_MS := 20000.0
const WIEDER := 0.25

static func reicht_ms(hw: Heldwerte, trank := false) -> float:
	var s := maxf(6.0 + 2.0 * hw.mod("CON") + int(hw.stufe / 2), 2.0)
	return s * 1000.0 * (0.5 if schwer(hw) else 1.0) * (2.0 if trank else 1.0)

# schwere Ruestung am Koerper ohne Staerke 13 (Kettenhemd im SRD)
static func schwer(hw: Heldwerte) -> bool:
	var g = hw.ding("CHEST")
	return g != null and String(Beute.grundform(String(g["base"])).get("gewicht", "")) == "HEAVY" and hw.wert("STR") < 13

# ein Bild von dt ms: der Held bewegt sich, will rennen; zurueck, ob er rennt
static func schritt(z: Zustand, hw: Heldwerte, dt: float, bewegt: bool, will: bool) -> bool:
	var rennt := bewegt and will and not z.atemlos and not z.betrunken()
	if rennt: z.ausdauer -= dt / reicht_ms(hw, z.ausdauer_trank)
	elif bewegt: z.ausdauer += dt / GEHEN_MS
	else: z.ausdauer += dt / STEHEN_MS
	z.ausdauer = clampf(z.ausdauer, 0.0, 1.0)
	if z.ausdauer <= 0.0: z.atemlos = true
	elif z.atemlos and z.ausdauer >= WIEDER: z.atemlos = false
	return rennt and not z.atemlos

# StaminaBar wie alt: rechts in der Mitte, 10 x 96 dp, schwarz, gefuellt von unten in Gold (atemlos rostrot), duenner Rand; blendet
# ein (250 ms), solange er nicht voll ist, und aus (900 ms), wenn er es ist
class Balken extends Control:
	var z: Zustand
	var sicht := 0.0
	func _init() -> void:
		var dp := AktionsKnopf.DP
		custom_minimum_size = Vector2(10, 96) * dp
		size = custom_minimum_size
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		position = Vector2(-(10 + 10) * dp, -48 * dp)
	func _process(dt: float) -> void:
		if z == null: return
		var voll := z.ausdauer >= 1.0
		sicht = move_toward(sicht, 0.0 if voll else 1.0, dt / (0.9 if voll else 0.25))
		modulate.a = sicht
		visible = sicht > 0.0
		queue_redraw()
	func _draw() -> void:
		if z == null: return
		var dp := AktionsKnopf.DP
		var r := StyleBoxFlat.new()
		r.bg_color = Color(0, 0, 0, 0.8); r.set_corner_radius_all(int(2 * dp))
		draw_style_box(r, Rect2(Vector2.ZERO, size))
		var pad := 2 * dp
		var h := (size.y - 2 * pad) * z.ausdauer
		var f := r.duplicate() as StyleBoxFlat
		f.bg_color = Color("9a4a3a") if z.atemlos else Stil.GOLD
		if h > 0: draw_style_box(f, Rect2(pad, size.y - pad - h, size.x - 2 * pad, h))
		var rand := StyleBoxFlat.new()
		rand.draw_center = false; rand.border_color = Stil.RIM; rand.set_border_width_all(maxi(1, int(dp))); rand.set_corner_radius_all(int(2 * dp))
		draw_style_box(rand, Rect2(Vector2.ZERO, size))
