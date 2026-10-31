class_name Bedienung
extends RefCounted
# 399.1 Menue System, Teil „Bedienung“ und „Rückfragen“ wie alt (MenuSigns.kt SystemSigns, GameViewModel prefs): Steuerung Wischen
# oder Klassisch (Steuerkreuz), Joystick Fein/Normal/Ruhig (StickFeel.runAt), Rennen mit Ring oder Taste, Aktionsknopf rechts oder
# links, Karte Normal oder Näher (MapZoom), Rütteln, Rückfragen. Vorgaben wie alt; gespeichert in user://bedienung.cfg.

const DATEI := "user://bedienung.cfg"
const RING_DP := [76.0, 94.0, 113.0]   # StickFeel.runAt: Fein, Normal, Ruhig
const NAEHER := 5.6 / 6.75              # MapZoom: „Näher“ 5,6 Kacheln quer statt 6,75

static var geladen := false
static var klassisch := false           # prefs controls „classic“
static var ring := 1                    # stickFeel
static var lauf_taste := false          # runButton
static var links := false               # leftHanded
static var karte_nah := false           # mapNear
static var ruetteln := true             # haptics
static var rueckfragen := true          # confirmations
static var blut := 1                    # bloodLevel: Aus, Dezent, Deutlich (399.2, Jerry: der Kampfort zeigt so viel Blut)
static var tempo := 1                   # battleTempo: Ruhig, Normal, Schnell (alt nur im klassischen Kampf, BattlePace)
static var kampftext := false           # battleAuto: Zeilen laufen von selbst (alt nur im klassischen Kampf)
static var zeichen_gesehen := false     # 425 signHintSeen: „Halte ein Zeichen gedrückt …“ einmal beim ersten Menue System

static func lade() -> void:
	if geladen: return
	geladen = true
	var c := ConfigFile.new()
	if c.load(DATEI) != OK: return
	klassisch = bool(c.get_value("bedienung", "klassisch", false))
	ring = clampi(int(c.get_value("bedienung", "ring", 1)), 0, 2)
	lauf_taste = bool(c.get_value("bedienung", "lauf_taste", false))
	links = bool(c.get_value("bedienung", "links", false))
	karte_nah = bool(c.get_value("bedienung", "karte_nah", false))
	ruetteln = bool(c.get_value("bedienung", "ruetteln", true))
	rueckfragen = bool(c.get_value("bedienung", "rueckfragen", true))
	blut = clampi(int(c.get_value("bedienung", "blut", 1)), 0, 2)
	tempo = clampi(int(c.get_value("bedienung", "tempo", 1)), 0, 2)
	kampftext = bool(c.get_value("bedienung", "kampftext", false))
	zeichen_gesehen = bool(c.get_value("bedienung", "zeichen_gesehen", false))

static func speichere() -> void:
	var c := ConfigFile.new()
	for k in ["klassisch", "ring", "lauf_taste", "links", "karte_nah", "ruetteln", "rueckfragen", "blut", "tempo", "kampftext", "zeichen_gesehen"]:
		c.set_value("bedienung", k, _wert(k))
	c.save(DATEI)

static func _wert(k: String) -> Variant:
	match k:
		"klassisch": return klassisch
		"ring": return ring
		"lauf_taste": return lauf_taste
		"links": return links
		"karte_nah": return karte_nah
		"ruetteln": return ruetteln
		"blut": return blut
		"tempo": return tempo
		"kampftext": return kampftext
		"zeichen_gesehen": return zeichen_gesehen
	return rueckfragen

static func blut_stufe() -> int:
	lade()
	return blut

static func ring_dp() -> float:
	lade()
	return RING_DP[ring]

# alt HapticFeedbackType: TextHandleMove kurz (etwas vor dir zu tun, Weg geht nicht), LongPress beim Rennen
static func ruettle(lang := false) -> void:
	lade()
	if ruetteln: Input.vibrate_handheld(40 if lang else 15)
