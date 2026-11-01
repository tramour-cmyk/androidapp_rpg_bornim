class_name Helligkeit
extends RefCounted
# 399.1 Helligkeit wie alt (SoundSettings.kt SoundAndLight, 13e.6; App.kt liftBlack ueber dem ganzen Spiel, nicht im Hauptmenue):
# ueber das Bild ein wenig Weiss, das Schwarz hebt sich, das Licht bleibt; 0 am Anfang, hoechstens 0,10 (Mix.lift, LIFT_MAX).
# Gespeichert in user://bild.cfg wie prefs „brightness“.

const DATEI := "user://bild.cfg"
const LIFT_MAX := 0.10
const ZEICHEN := 10.0 / 255.0      # Mix.SIGN: das Probezeichen, so dunkel wie der Umriss einer Hoehle

static var wert := -1
static var schleier: ColorRect

static func lade() -> int:
	if wert < 0:
		var c := ConfigFile.new()
		wert = int(c.get_value("bild", "helligkeit", 0)) if c.load(DATEI) == OK else 0
	return wert

static func hebung(w: int) -> float: return clampi(w, 0, 100) / 100.0 * LIFT_MAX

# die Schicht ueber dem Spiel (spiel.gd nach dem Hauptmenue)
static func schicht() -> CanvasLayer:
	var e := CanvasLayer.new()
	e.layer = 120
	schleier = ColorRect.new()
	schleier.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	schleier.mouse_filter = Control.MOUSE_FILTER_IGNORE
	e.add_child(schleier)
	zeige()
	return e

static func zeige() -> void:
	if is_instance_valid(schleier): schleier.color = Color(1, 1, 1, hebung(lade()))

static func setze(w: int) -> void:
	wert = clampi(w, 0, 100)
	var c := ConfigFile.new()
	c.load(DATEI)
	c.set_value("bild", "helligkeit", wert)
	c.save(DATEI)
	zeige()
