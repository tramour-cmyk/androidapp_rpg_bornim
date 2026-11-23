class_name Grafik
extends RefCounted
# 698 Grafikstufen (698a A, Chef 16.11., 06:46: „698a machen wir wie empfohlen. Also A mit den Hinweisen, die du gegeben hast.“):
# Hoch, Mittel, Niedrig und Automatisch im Systemmenue (Zeichen „Grafik“, Gruppe „Spiel“). Die Signatur bleibt in jeder Stufe
# (Tuschelinie, Licht aus Quelle, Gold, Nebel am Rand); gespart wird an Schatten, Schaerfe des Spielbilds (nur 3D, Schrift und
# Menues bleiben scharf) und den gekauften Effekten:
#   Hoch:    Sonnenschatten 4096 px weich (Stufe 2), Innenschatten, Tusche nach Lampen, 3D voll, Gras und Effekte der Kits,
#            Glühen von Flammen, Glut, Kristallen und Pilzen (1270.4, licht.gd setze_gluehen)
#   Mittel:  Sonnenschatten 2048 px weich (Stufe 1), sonst wie Hoch, 3D 85 %
#   Niedrig: Sonnenschatten 1024 px hart, ohne Innenschatten (Kamin, Fackel, Tageslicht), Tusche nur nach Helligkeit, 3D 70 %,
#            ohne Kits (unser eigenes Gras, unser Rauch und die Lichtinseln)
# Automatisch (Vorgabe): misst beim ersten Start hinter der Einmess-Blende (spiel.gd einmessen, Chef 06:55, Worte Homer 1365) kurz
# die Grafikzeit je Stufe am ersten Ort und nimmt die hoechste, die mit Luft reicht (Stellungnahme Sokrates: nicht „beginnend bei Hoch“). Danach misst es mit; braucht die Grafik
# zehn Sekunden am Stueck mehr als ein Bild bei 60 Hz, geht es eine Stufe herunter, aber erst am naechsten Ladepunkt (Ortswechsel,
# Kampfort), nie mitten in der Szene, und sagt es dort einmal („Grafik: Mittel“). Herauf nie von selbst.
# Gespeichert in user://bild.cfg (Abschnitt „grafik“) neben der Helligkeit. In Laeufen mit Argumenten gilt Hoch wie bisher,
# ausser --grafik=hoch|mittel|niedrig; ebenso ohne Bildschirm (Tests mit -s).

const DATEI := "user://bild.cfg"
const NIEDRIG := 0
const MITTEL := 1
const HOCH := 2
const WAHL := ["auto", "hoch", "mittel", "niedrig"]          # Reihenfolge beim Antippen
const NAMEN := {"auto": ["Automatisch", "Automatic"], "hoch": ["Hoch", "High"], "mittel": ["Mittel", "Medium"], "niedrig": ["Niedrig", "Low"]}
const STUFE_NAME := ["niedrig", "mittel", "hoch"]

# je Stufe (Index NIEDRIG, MITTEL, HOCH)
const SONNE_PX := [1024, 2048, 4096]
const SONNE_WEICH := [0, 1, 2]                 # RenderingServer.SHADOW_QUALITY_*: 0 hart, 1 sehr weich niedrig, 2 weich niedrig
const SCHAERFE := [0.70, 0.85, 1.0]           # Viewport.scaling_3d_scale

# Worte der Einmess-Blende (STORY-BLENDE.md „Einmessen beim ersten Start“, Homer 1365), wortgetreu
const EINMESSEN_TITEL := ["Die Feder wird angesetzt.", "The quill is put to the page."]   # [1365.einmessen.titel]
const EINMESSEN_TEXT := ["Das Spiel misst die Grafik einmalig auf dein Gerät ein. Das dauert nur einige Sekunden.",
	"The game is tuning its graphics to your device. This happens once and takes only a few seconds."]   # [1365.einmessen.text]
const EINMESSEN_WAHL := ["Ändern kannst du sie jederzeit im Systemmenü unter „Grafik“.",
	"You can change this at any time under “Graphics” in the system menu."]   # [1365.einmessen.wahl]

const ZIEL_MS := 1000.0 / 60.0                 # ein Bild bei 60 Hz (ohne Takt)
const LUFT := 0.8                              # Anfangsmessung: die Stufe muss mit 20 % Luft reichen (der erste Ort ist oft ein Raum)
const RUCKEL_SEK := 10                         # so viele Sekunden am Stueck ueber ZIEL_MS, dann eine Stufe herunter
const MESS_VOR := 8                            # Anfangsmessung: Bilder nach dem Umschalten, die nicht zaehlen
const MESS_BILDER := 30                        # und die gemessenen

static var wahl := ""                          # leer: noch nicht geladen
static var auto_stufe := -1                    # Automatisch: gewaehlte Stufe, -1 noch nicht gemessen
static var aktiv := HOCH                       # die Stufe, die gerade gilt (am letzten Ladepunkt gesetzt)
static var gesenkt := false                    # Automatisch hat gesenkt, gilt am naechsten Ladepunkt (dann die Meldung)
static var _sek_ms := 0.0
static var _sek_bilder := 0
static var _sek_dauer := 0.0
static var _ruckel := 0
static var _gemessen := false                  # Grafikzeit wird am Viewport gemessen
static var zwang := -1                         # Bildlauf --grafik698: diese Stufe, gleich welche Wahl
static var probe := false                      # Test grafik_698: Automatisch auch ohne Bildschirm, ohne Speichern

static func lade() -> void:
	if wahl != "": return
	var c := ConfigFile.new()
	var ok := c.load(DATEI) == OK
	wahl = String(c.get_value("grafik", "wahl", "auto")) if ok else "auto"
	if not wahl in WAHL: wahl = "auto"
	auto_stufe = clampi(int(c.get_value("grafik", "auto", -1)), -1, HOCH) if ok else -1
	# 1270.6: eine Messung mit dem alten Ziel (60 Hz, vor dem Takt 30) gilt nicht; einmal neu einmessen am naechsten Ort
	if auto_stufe >= 0 and int(c.get_value("grafik", "takt", 0)) != int(Testmodus.TAKTE[Testmodus.TAKT_SPIEL]): auto_stufe = -1
	aktiv = stufe()

static func speichere() -> void:
	if fest() >= 0 or probe: return
	var c := ConfigFile.new()
	c.load(DATEI)
	c.set_value("grafik", "wahl", wahl)
	c.set_value("grafik", "auto", auto_stufe)
	c.set_value("grafik", "takt", int(Testmodus.TAKTE[Testmodus.TAKT_SPIEL]))   # 1270.6: Ziel, mit dem gemessen wurde
	c.save(DATEI)

## Laeufe mit Argumenten: Hoch wie bisher, oder die Stufe aus --grafik=
static func fest() -> int:
	if zwang >= 0: return zwang
	var args := OS.get_cmdline_user_args()
	if probe or (args.is_empty() and DisplayServer.get_name() != "headless"): return -1   # Tests mit -s laufen ohne Bildschirm
	for a in args:
		if a.begins_with("--grafik="): return maxi(STUFE_NAME.find(a.substr(9)), NIEDRIG)
	return HOCH

static func automatisch() -> bool:
	lade()
	return wahl == "auto" and fest() < 0

## die Stufe nach der Wahl (gilt erst am naechsten Ladepunkt oder sofort nach einer Wahl im Menue)
static func stufe() -> int:
	if fest() >= 0: return fest()
	if wahl == "auto": return HOCH if auto_stufe < 0 else auto_stufe
	return STUFE_NAME.find(wahl)

static func name_wahl(de: bool) -> String:
	lade()
	return NAMEN[wahl][0 if de else 1]

static func name_stufe(s: int, de: bool) -> String: return NAMEN[STUFE_NAME[s]][0 if de else 1]

## Systemmenue: Antippen wechselt Automatisch, Hoch, Mittel, Niedrig; gilt sofort fuer Schatten und Schaerfe, Gras und Effekte der
## Kits ab dem naechsten Ort
static var neu_laden := false                  # 1670a A: nach einer Wahl im Menue den Ort beim Schliessen neu aufbauen

static func weiter(tree: SceneTree) -> void:
	lade()
	neu_laden = true
	wahl = WAHL[(WAHL.find(wahl) + 1) % WAHL.size()]
	gesenkt = false
	speichere()
	setze(tree, stufe())

# ---------------------------------------------------------------- Schalter der Stufe (gelesen beim Aufbau)

static func innen_schatten() -> bool: return aktiv >= MITTEL
static func tusche_lampen() -> bool: return aktiv >= MITTEL
static func kits() -> bool: return aktiv >= MITTEL
static func gluehen() -> bool: return aktiv >= HOCH       # 1270.4 (Chef 16.11., 17:32)
static func sonne_px() -> int: return SONNE_PX[aktiv]     # 1645: Kampfort liest sie beim Betreten und Verlassen

# ---------------------------------------------------------------- Ladepunkte

## am Ladepunkt (Ortswechsel unter der Blende, Aufbau des Kampforts): die Stufe nach der Wahl setzen; gibt die Meldung zurueck, wenn
## Automatisch gesenkt hat („Grafik: Mittel“), sonst ""
static func ladepunkt(tree: SceneTree, de := true) -> String:
	lade()
	_ruckel = 0; _sek_bilder = 0; _sek_ms = 0.0; _sek_dauer = 0.0
	var s := stufe()
	var meldung := ""
	if gesenkt and automatisch() and s < aktiv: meldung = ("Grafik: %s" if de else "Graphics: %s") % name_stufe(s, de)
	gesenkt = false
	setze(tree, s)
	return meldung

## Schatten und Schaerfe sofort (unter der Blende oder nach einer Wahl im Menue); Innenschatten an den Lichtern mit „grafik_schatten“
static func setze(tree: SceneTree, s: int) -> void:
	aktiv = clampi(s, NIEDRIG, HOCH)
	RenderingServer.directional_shadow_atlas_set_size(SONNE_PX[aktiv], true)
	RenderingServer.directional_soft_shadow_filter_set_quality(SONNE_WEICH[aktiv])
	if tree == null: return
	tree.root.scaling_3d_scale = 0.5 if Testmodus.aufl_50 else SCHAERFE[aktiv]   # 1270.6 Messbuild „3D halb“
	for n in tree.get_nodes_in_group("grafik_schatten"):
		if n is Light3D: (n as Light3D).shadow_enabled = innen_schatten()
	for n in tree.get_nodes_in_group("grafik_gluehen"):
		if n is WorldEnvironment and (n as WorldEnvironment).environment: Licht.setze_gluehen((n as WorldEnvironment).environment)

## Automatisch, erste Ladung: unter der Blende kurz je Stufe messen, von Hoch abwaerts, die hoechste mit Luft nehmen
static func braucht_messung() -> bool: return automatisch() and auto_stufe < 0

## 1270.6: das Ziel je Bild folgt dem Takt des Spiels (fest 30, Testmodus.TAKT_SPIEL): ein Bild bei 30 Bildern je Sekunde statt bei
## 60 Hz; vorher waehlte das Einmessen am A56 Niedrig, obwohl die Welt dort 59 Bilder/s lief (Chef 18.11., 14:22, Build 298)
static func ziel_ms() -> float:
	return 1000.0 / Engine.max_fps if Engine.max_fps > 0 else ZIEL_MS

static func messen(tree: SceneTree) -> void:
	var vp := tree.root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	_gemessen = true
	var wahl_ := NIEDRIG
	var ziel := ziel_ms()
	var takt := Engine.max_fps
	Engine.max_fps = 0                         # frei messen; mit Takt waere die Zeit von Bild zu Bild immer ein Takt
	var bis := Time.get_ticks_msec() + 4000
	for s in [HOCH, MITTEL]:
		setze(tree, s)
		var summe := 0.0
		var n := 0
		var i := 0
		var t := Time.get_ticks_usec()
		while n < MESS_BILDER and Time.get_ticks_msec() < bis:
			await tree.process_frame
			var jetzt := Time.get_ticks_usec()
			i += 1
			if i > MESS_VOR: summe += zeit_ms(vp, (jetzt - t) / 1000.0); n += 1
			t = jetzt
		var ms := summe / maxi(n, 1)
		print("GRAFIK698 Anfang %s: %.1f ms (%d Bilder)" % [STUFE_NAME[s], ms, n])
		if n > 0 and ms <= ziel * LUFT: wahl_ = s; break
	Engine.max_fps = takt
	auto_stufe = wahl_
	speichere()
	setze(tree, wahl_)

## Grafikzeit eines Bilds; ohne Messung am Viewport (Renderer ohne Zeitstempel) die Zeit von Bild zu Bild
static func zeit_ms(vp: RID, dt_ms: float) -> float:
	var g := RenderingServer.viewport_get_measured_render_time_gpu(vp)
	return g if g > 0.0 else dt_ms

## jedes Bild der Welt (spiel.gd _process), ausser unter der Blende: Automatisch misst mit und merkt sich das Senken
static func bild(tree: SceneTree, dt: float) -> void:
	if gesenkt or aktiv <= NIEDRIG or not automatisch(): return
	var vp := tree.root.get_viewport_rid()
	if not _gemessen:
		RenderingServer.viewport_set_measure_render_time(vp, true)
		_gemessen = true
	var g := RenderingServer.viewport_get_measured_render_time_gpu(vp)
	# ohne Zeitstempel die Zeit von Bild zu Bild; mit Takt liegt die immer knapp ueber einem Takt, daher 10 % Spiel (1270.6)
	_sek_ms += g if g > 0.0 else dt * 1000.0 / 1.1
	_sek_bilder += 1
	_sek_dauer += dt
	if _sek_dauer < 1.0: return
	_ruckel = _ruckel + 1 if _sek_ms / _sek_bilder > ziel_ms() else 0
	_sek_ms = 0.0; _sek_bilder = 0; _sek_dauer = 0.0
	if _ruckel >= RUCKEL_SEK:
		auto_stufe = aktiv - 1
		gesenkt = true
		speichere()
		print("GRAFIK698 gesenkt auf %s" % STUFE_NAME[auto_stufe])
