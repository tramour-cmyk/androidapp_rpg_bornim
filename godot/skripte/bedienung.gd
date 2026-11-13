class_name Bedienung
extends RefCounted
# 399.1 Menue System, Teil „Bedienung“ und „Rückfragen“ wie alt (MenuSigns.kt SystemSigns, GameViewModel prefs): Steuerung nur
# Wischen (663, Chef 08.11., 15:24: kein Steuerkreuz mehr, nur Touch), Joystick Fein/Normal/Ruhig (StickFeel.runAt), Rennen mit Ring oder Taste, Aktionsknopf rechts oder
# links, Karte Normal oder Näher (MapZoom), Rütteln, Rückfragen. Vorgaben wie alt; gespeichert in user://bedienung.cfg.

const DATEI := "user://bedienung.cfg"
const RING_DP := [76.0, 94.0, 113.0]   # StickFeel.runAt: Fein, Normal, Ruhig
const NAEHER := 5.6 / 6.75              # MapZoom: „Näher“ 5,6 Kacheln quer statt 6,75

static var geladen := false
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
static var fert_gruppen := {}           # 762 (Chef 21:33): Gruppe -> offen, nur was der Spieler im Reiter Fertigkeiten umgeklappt hat

static func lade() -> void:
	if geladen: return
	geladen = true
	var c := ConfigFile.new()
	if c.load(DATEI) != OK: return
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
	var fg = c.get_value("bedienung", "fert_gruppen", {})
	fert_gruppen = fg if fg is Dictionary else {}

static func speichere() -> void:
	var c := ConfigFile.new()
	for k in ["ring", "lauf_taste", "links", "karte_nah", "ruetteln", "rueckfragen", "blut", "tempo", "kampftext", "zeichen_gesehen", "fert_gruppen"]:
		c.set_value("bedienung", k, _wert(k))
	c.save(DATEI)

static func _wert(k: String) -> Variant:
	match k:
		"ring": return ring
		"lauf_taste": return lauf_taste
		"links": return links
		"karte_nah": return karte_nah
		"ruetteln": return ruetteln
		"blut": return blut
		"tempo": return tempo
		"kampftext": return kampftext
		"zeichen_gesehen": return zeichen_gesehen
		"fert_gruppen": return fert_gruppen
	return rueckfragen

static func blut_stufe() -> int:
	lade()
	return blut

## 527 (Abgleich 512, Chef 03.11., 23:26 „besser machen“): Tempo wie alt (BattlePace.set): jede Bewegung im Kampf dauert so viel mal
## so lang; Ruhig 1,35, Normal 1, Schnell 0,7
static func tempo_faktor() -> float:
	lade()
	return [1.35, 1.0, 0.7, 0.25][clampi(tempo, 0, 3)]     # 1020.2 C: „sehr schnell“ nur im Testmodus (Testmodus, Kampfort), nie gespeichert

static func ring_dp() -> float:
	lade()
	return RING_DP[ring]

# alt HapticFeedbackType: TextHandleMove kurz (etwas vor dir zu tun, Weg geht nicht), LongPress beim Rennen
static func ruettle(lang := false) -> void:
	lade()
	if ruetteln: Input.vibrate_handheld(40 if lang else 15)
