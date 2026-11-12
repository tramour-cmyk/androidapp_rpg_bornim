# 348.7 (Umzug Godot): der Kampfort von MARS. Vorgabe ist der heutige Kampfschirm (app SkirmishScreen.kt, core FightCamera.kt):
# eine Kamera aus 25° von oben, die Kampflinie 30° nach rechts, die Helden vorn links, die Gegner hinten rechts in zwei
# Reihen; darunter Kampfbericht, Lebensbalken und Knöpfe; der Ring beim angesagten Schlag. Die Regeln laufen in einem
# eigenen Faden (wie ProbeRun), der Schirm spielt ihre Meldungen nacheinander ab.
# Aufruf: Kampfort.new(party, foes, tables, potions, rueckkehr) als Kind eines Knotens; rueckkehr(outcome) am Ende, nach
# einem Sieg steht in [reward] der Lohn (regeln/lohn.gd), den die Welt dem Helden gutschreibt. Ein Held ohne LP kommt nie
# in den Kampf: setup gibt dann false, der Kampfort beendet sich mit "NONE" (Test 89.2 b).
extends Node3D

const Mars = preload("res://regeln/mars.gd")
const Lohn = preload("res://regeln/lohn.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Ui = preload("res://kampf/kampf_ui.gd")
const Figur = preload("res://kampf/figur.gd")
const Wucht = preload("res://regeln/trefferwucht.gd")
const Zauber = preload("res://kampf/zauber.gd")
const Signatur = preload("res://kampf/signatur.gd")

# FightCamera.kt
const PITCH := 25.0
const LENS := 1.5
const MID := 0.64
const AXIS := 30.0
const FRONT_M := 1.4
const BACK_M := 2.9
const HALF_M := 0.9
const FOE_HALF_M := 1.2         # Wölfe sind lang: mit 0,9 klebten sie aneinander, Balken lag auf dem Nachbarn (Prüfer Runde 7)
const NEAR_M := 1.0
const ALONE_HERO_B := 0.35
const BACK_GAP_A := 2.4          # 0,8 wie alt; der Wolf hinten stand im Rumpf des vorderen (Prüfer Runde 7); 1,6: Pfoten im Bild auf dem Ohr des rechten vorderen (Prüfer 25.10. Runde 10; Tiefe wirkt im Bild wenig, 2,4 m: 16 px Luft)
const BACK_GAP_B := -2.0         # 567 (Chef 04.11., Build 257): mit −1,0 stand der hintere im Bild genau hinter dem rechten vorderen, jetzt mittig dahinter (tests/abstand_567.gd)
# einer vorn, zwei hinten (Grimmzahn Runde 7): vorn 0,3 m nach rechts, hinten 1 m zurück, 0,45 m weiter auseinander und 0,85 m
# nach links (Grimmzahn hinten rechts lief sonst über den Bildrand); gemessen: Deckung der Wache 36 % → 1 %
const SOLO_BACK_A := 0.6       # 438: einer vorn, einer hinten: hinten 0,6 m weiter zurück und 1,3 m zur Seite
# 567 (Chef 04.11., 17:00–17:15, Build 257: zwei Goblins, zwei Wölfe „fast übereinander“): −1,3 nach links hob die Schräge der
# 30°-Linie auf, der hintere stand im Bild 10 dp neben dem vorderen, Füße auf dessen Kopfhöhe (72 % Deckung). Jetzt der vordere
# 0,7 m nach links, der hintere 0,6 m nach rechts: wieder 1,3 m quer (438, Wölfe nicht ineinander), im Bild 126 dp, 6–9 %
const SOLO_BACK_B := 0.6
const SOLO_FRONT_B := -0.7
const PAIR_FRONT_B := 0.3
const PAIR_BACK_A := 1.0
const PAIR_BACK_B := 0.45
const PAIR_BACK_SHIFT := -0.85
const FOE_LEFT_BACK_M := 0.55
const FOE_LEFT_OUT_M := 0.45
const FOE_SIZE := 1.5
## 348.9: Größe gegen den Wolf wie im alten Bild (BeastArt.size: Wolf 76, Wildschwein 90, Ratte 39), geteilt durch das Maß der Modelle (Schulter 0,8 / 0,9 / 0,3 m)
## Ratte Runde 11 (Chef 25.10., 18:32 „deutlich größer“): Modell 0,6 m Schulter (figur.gd ART_GROESSE), in echter Größe gegen den Wolf
## Chef 25.10., 19:05 („die Riesenratten jetzt so groß von der Risthöhe wie die Helden … übertrieben“): Ratte in echter Größe gegen
## die Helden (0,6 m), ohne die Bildvergrößerung FOE_SIZE·WOLF_SIZE der Gegner
const ART_SIZE := {"boar": 90.0 / 76.0 * 0.8 / 0.9, "giant_rat": 1.0 / (FOE_SIZE * WOLF_SIZE),
		"giant_bat": 1.0 / (FOE_SIZE * WOLF_SIZE)}     # 348.7 Riesenfledermaus: echte Größe (fledermaus.py, Abnahmeliste)
const WOLF_SIZE := 0.88         # 1,08 nach Messung (Schulter/Held alt 0,64, neu 0,52) wirkte im Bild „wie Kälber“ (Prüfer Lauf 14); zurück
# SkirmishScreen.kt
const SAY_MS := 1100
const AUSWEICH_VOR_MS := 250     # 438: Ausweichen beginnt so viel vor dem Aufschlag
const TODESZEILE_ANTEIL := 0.6     # 438: Todeszeile nach diesem Anteil der Sterbebewegung
const NACHTRAG_MS := 150     # 438: Meldung, deren Zeile schon mit der Bewegung stand
const RING_MS := 1100
const PERFECT_MS := 90
const GOOD_MS := 260
## 249: Blut wie im alten Spiel, Stufe 1 (wenige kleine Tropfen) ist dort die Vorgabe; 0 aus, 2 mehr mit Flecken am Boden.
## Der Schalter im Menü kommt mit Toms Systemmenü.

var mars
var tables: Dictionary
var on_end: Callable
## Starts the same fight anew ("Nochmal").
var again_fn: Callable
var zurueck_text: Array = []     # 1020.2 B: Text des Knopfs „Zurück“ [de, en], leer: „Zurück“
## 1034 (Chef 12.11., 15:04): Probekampf mit dem Testhelden, nichts geht in den Spielstand; das Siegfenster sagt es, Geschichtsgegenstände
## (Schlüsseldinge wie Graks Schlüssel, der versiegelte Brief) sind keine Probebeute
var ohne_folgen := false
## 1034: Probekampf mit dem Spielhelden: nach einer Niederlage kein „Nochmal“ (sie zählt wie im Spiel)
var again_nicht_nach_niederlage := false
var cam: Camera3D
var ui
var figures := {}          # id -> Figur
var fx_zahl := {}          # 494: wie oft je Art ein Effekt flog (Test spinne_494: Netz statt Pfeil)
var shown := {}            # the last message played: hp, places, intents, queue, sp
## 296.2: the hero's experience before the fight, how far above the place he stands, the level cap (null: chapter's)
var progress := {}
var verhuellt := false     # 402: die Blende vor dem Kampf steht noch (Kampfblende.gd)
var messpause := false     # 806: „Kampf messen“ (Bausteine806) hält die Meldungen an, bis jeder Baustein gemessen ist
## 296.2: what the won fight brings ({xp, gold, items, level, levels, xp_total, lines}), empty otherwise
var reward := {}
## 399.2 (aufruf.gd): Kampfort und Tageszeit aus dem Aufruf; heute gibt es nur den Wald, die Tageszeit dämpft das Licht
var ort := "wald"
var tageszeit := "tag"
## 493: welcher Kampfort im Wald (kampfort_wald.py SPOT): lichtung, waldrand, teich, baum, felsen, steinkreis; fehlt sein Modell im
## Bau, die Lichtung
var platz := "lichtung"
## 836 (Homer 830): Flaggen des Spielstands (Zustand.flaggen, dasselbe Dictionary; aufruf.gd aus lage „flaggen“); Hinweise, die einmal
## je Spielstand kommen, merken sich hier, dass sie gezeigt sind. Proben und Tests: leer, je Kampf neu
var flaggen := {}
## 527: Tempo aus dem Menue System (Bedienung.tempo_faktor; aufruf.gd setzt es, Proben und Tests bleiben bei 1): alle Bewegungen,
## Wartezeiten und Zeilen des Kampfs laufen über Engine.time_scale so viel mal so lang, die Blende davor und der Reaktionsring nicht
## (der Ring misst in Echtzeit)
var tempo := 1.0
var _tempo_an := false
## 600 (Chef 05.11., t266: „Beschleunigungsknopf einbauen (analog Würfelergebnis oder Raster)“): im Spiel (aufruf.gd) ein Knopf neben
## Würfel und Raster, der das Tempo aus dem Menü weiterschaltet; nicht in Proben und Tests (die setzen die Zeit selbst)
var tempo_knopf := false
const PLAETZE := ["lichtung", "waldrand", "teich", "baum", "felsen", "steinkreis"]


## 493 wie alt (BattleScene.spotFor): was um die Kachel [t] auf [karte] steht: Wasser bis 4 Kacheln → Teich, stehende Steine bis 3 →
## Steinkreis, ein liegender Stamm bis 3 → Baum, Felsen bis 3 → Felsen; sonst mit 8 Bäumen in 5 × 5 der Waldrand, sonst die Lichtung
static func platz_fuer(karte, t: Vector2i) -> String:
	if karte == null:
		return "lichtung"
	var art := func(c: Vector2i) -> String:
		var z: String = karte.zeichen(c)
		return String(karte.kacheln.get(z, {}).get("name", ""))
	var nah := func(name_: String, r: int) -> bool:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if art.call(t + Vector2i(dx, dy)) == name_:
					return true
		return false
	if nah.call("WATER", 4): return "teich"
	if nah.call("MENHIR", 3): return "steinkreis"
	if nah.call("LOG", 3): return "baum"
	if nah.call("ROCK", 3): return "felsen"
	var baeume := 0
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			if art.call(t + Vector2i(dx, dy)) == "TREE": baeume += 1
	return "waldrand" if baeume >= 8 else "lichtung"


## 493: Dateiname des Kampforts im Bau („kampfort-wald“, „-teich“ …), auf die Lichtung zurück, wenn er fehlt
func _platz_datei(name_: String, endung: String) -> String:
	var p := "res://kampf/daten/%s-%s.%s" % [name_, platz, endung]
	if platz != "lichtung" and FileAccess.file_exists(p):
		return p
	return "res://kampf/daten/%s.%s" % [name_, endung]
var lang := 0

# the rules' thread and its beats (ProbeRun)
var worker: Thread
var beats: Array = []
var beats_lock := Mutex.new()
var ring_sem := Semaphore.new()
var ring_answer := Mars.NONE
var busy := false
var playing := false
var ring_open := false
var ring_start := 0
var ring_for := ""
## 249: Uhr der Kampfeffekte in ms, läuft mit Engine.time_scale (Probe im Zeitraffer)
var clock_ms := 0.0
## 249: der kritische oder tödliche Schlag, der die Szene heranrückt und rucken lässt: {by, on, w, t0}
var hit := {}
var cam_z := 1.0                 # 438: Zoom und Mitte, wie _hit_camera sie zuletzt gesetzt hat (ein neuer Schlag beginnt dort)
var cam_p := Vector2.ZERO
var base_size := 1.0
var base_off := Vector2.ZERO


func setup(party: Array, foes: Array, p_tables: Dictionary, potions: Dictionary, p_on_end: Callable, seed := -1, p_progress := {}) -> bool:
	tables = p_tables
	on_end = p_on_end
	progress = p_progress
	if not Mars.can_fight(party):
		return false
	var dice = Wuerfel.new(null if seed < 0 else seed)
	var words = Wuerfel.new(null if seed < 0 else seed + 279)
	# 399.2: aus der Welt atemlos (Skirmish winded: Initiative mit Nachteil), satt (+1 auf Angriffe und Schaden), Eröffnung (Opening:
	# NORMAL, AMBUSHED Gegner zuerst, HERO_FIRST Held zuerst)
	mars = Mars.new(party, foes, tables, dice, words, lang, bool(p_progress.get("atemlos", false)), String(p_progress.get("eroeffnung", "NORMAL")))
	mars.fed = bool(p_progress.get("satt", false))
	mars.gesehen = flaggen     # 840: Eingebungen einmal je Spielstand (836: Zustand.flaggen, aufruf.gd setzt flaggen vor setup)
	mars.smoke = int(p_progress.get("rauch", 0))     # D4.1, 494: Morwens Rauchbündel gegen Krogg (aufruf.gd lage „rauch“)
	for k in potions:
		mars.potions[k] = int(potions[k])
	mars.listener = func(e): _post({"say": _mit_waffen(e)})
	return true


func _ready() -> void:
	if mars == null:
		_refused.call_deferred()
		return
	_setup_world()
	ui = Ui.new()
	ui.kampfort = self
	add_child(ui)
	for f in mars.fighters():
		var fig := Figur.new()
		fig.setup(f, self)
		add_child(fig)
		figures[f.id] = fig
	shown = _state_now()
	for fig in figures.values():
		fig.snap_to(_spot_pos(fig.fighter, shown.places[fig.fighter.id]))
	_umriss_messen.call_deferred()
	get_viewport().size_changed.connect(_fit_camera)
	_fit_camera()
	ui.refresh()
	# 402: die Blende vor dem Kampf wie alt (progress „blende“: aus der Welt, nicht in Proben und Tests)
	if bool(progress.get("blende", false)):
		var ebene := CanvasLayer.new()
		ebene.layer = 100
		add_child(ebene)
		var zufall := RandomNumberGenerator.new()
		zufall.randomize()
		var kb := Kampfblende.new(String(progress.get("eroeffnung", "NORMAL")), Kampfblende.lage(mars), zufall)
		verhuellt = true
		kb.geht.connect(func():
			verhuellt = false
			_geheul_beim_erscheinen()     # 939: wie alt, wenn die Blende fort ist
			_tempo_setzen())
		ebene.add_child(kb)
	else:
		_geheul_beim_erscheinen()
		_tempo_setzen()
	_run(func(): mars.start(_react))


## 600: Ruhig, Normal, Schnell wie im Menü (Bedienung.tempo), gilt sofort, bleibt gespeichert; während der Blende erst, wenn sie geht
func tempo_wechseln() -> void:
	Bedienung.tempo = (Bedienung.tempo + 1) % (4 if Testmodus.ist_an() else 3)     # 1020.2 C: im Testmodus auch „sehr schnell“
	Bedienung.speichere()
	tempo = Bedienung.tempo_faktor()
	if verhuellt:
		return
	Engine.time_scale = 1.0 / tempo
	_tempo_an = true


func _tempo_setzen() -> void:
	if is_equal_approx(tempo, 1.0) or tempo <= 0.0:
		return
	Engine.time_scale = 1.0 / tempo
	_tempo_an = true


func _exit_tree() -> void:
	if _tempo_an:
		Engine.time_scale = 1.0
		_tempo_an = false
	if worker and worker.is_started():
		ring_sem.post()
		worker.wait_to_finish()


# ---------------------------------------------------------------- world: ground, light, camera, ink
func _setup_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	# Prüfer Lauf 14: obere Bildhälfte dunkel (Mittel 16–54 gegen alt 33–87); Waldinneres heller grün, Ferne wie alt oben (32/42/26)
	env.background_color = Color(0.13, 0.17, 0.10)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.66, 0.75)     # wie Toms licht.gd am Tag
	# heller als im Dorf: der alte Kampfort ist im Mittel 78 hell, neu mit Dorflicht 54, so 72 (Prüfer Stand 7: Wald zu dunkel)
	env.ambient_light_energy = 0.75
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.8
	env.adjustment_contrast = 1.06
	env.fog_enabled = true
	env.fog_light_color = Color(0.09, 0.14, 0.15)         # Waldinneres (ForestCam #14221A); Stand 9: oben doppelt so hell wie alt, grau; Runde 4: gelbstichig, kühler
	# Ferne heller im Dunst (Prüfer Lauf 14: Wald oben dunkel), aber nach Tiefe: erst ab 16 m (Gruppe 13 m, Gegner 15–17 m)
	# (Prüfer Stand 9: Gras dunstig; vorher 40 % Dunst über den Kämpfern)
	env.fog_mode = Environment.FOG_MODE_DEPTH
	env.fog_depth_begin = 16.0
	env.fog_depth_end = 70.0     # Runde 5: Wald oben flach (Streuung 23 gegen 34)
	env.fog_depth_curve = 0.4
	env.fog_density = 1.0
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	# höher und von vorn als im Dorf (licht.gd -50, 25): sonst liegt der Schatten der Bäume auf der Lichtung (Lauf 11:
	# Wölfe schwarz, grauer Wolf Helligkeit 8, ohne Baumschatten 43); mit Tusche nach Licht −45, 55 (Chef 28.10., 08:09, r9 ja);
	# Schlagschatten weich, nicht schwarz (Prüfer Stand 7). 457.2: Werte in signatur.gd, damit Proben mit eigener Bühne gleich zeichnen
	Signatur.sonne_wie_kampf(sun, tusche() == "licht")
	if tageszeit == "abend":     # 399.2: nur Funktion, Feinschliff auf der Feintuning-Liste
		sun.light_energy *= 0.75
		sun.light_color = Color(1.0, 0.74, 0.52)
		env.ambient_light_energy *= 0.8
	elif tageszeit == "nacht":
		sun.light_energy *= 0.3
		sun.light_color = Color(0.62, 0.7, 1.0)
		env.ambient_light_color = Color(0.4, 0.46, 0.62)
		env.ambient_light_energy *= 0.5
	add_child(sun)
	_build_forest()
	cam = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_FRUSTUM
	cam.near = 0.1
	cam.far = 120.0
	add_child(cam)
	# Tusche wie Toms kamera.gd: Welt (Schablone 0) und Gruppe mit Waffen (Schablone 2, feiner; Probe Build 12)
	var tu: Shader = load("res://kampf/tusche.gdshader")
	var tu_held := Signatur.schablone(tu, 2)
	_sun = sun
	if tusche() == "licht":     # 348.13 Probe (Tom): Tusche nach Licht wie kamera.gd; Welt, Gruppe, Gegner (signatur.gd)
		_ink_mats.append_array(Signatur.tusche_licht(cam))
	elif tusche() != "0":     # Prüflauf: TUSCHE=0 misst, was die Linie ausmacht
		_ink(tu, 1.3, 1.25)
		_ink(tu_held, 0.8, 1.0)


func _ink(sh: Shader, width: float, thick: float) -> void:
	_ink_mats.append(Signatur.quad(cam, sh, width, thick))

var _sun: DirectionalLight3D
## 348.13a (Chef 28.10., 08:09, Archiv: r9 ja): Tusche nach Licht ist Vorgabe; TUSCHE=alt die alte Tusche, TUSCHE=0 ohne
## 457.2: OHNE_SIGNATUR=1 wie TUSCHE=0 (und ohne Schatten, signatur.gd)
static func tusche() -> String:
	if Signatur.aus():
		return "0"
	return OS.get_environment("TUSCHE") if OS.has_environment("TUSCHE") else "licht"
var _ink_mats: Array[ShaderMaterial] = []
## 457.2: Mitte des Bildinhalts für die Tusche (Welt) mit der Kamera, die gerade zeichnet; null = Kampfmitte mit [cam]; nur Proben (probe.gd NAH)
var ink_ziel = null
func _ink_licht() -> void:
	if tusche() != "licht" or _ink_mats.is_empty(): return
	if OS.get_environment("TUSCHE_DBG") != "" and Engine.get_process_frames() % 30 == 0:     # 348.13a: Sonne am Schirm (wie sl im Shader)
		var lv := cam.global_transform.basis.inverse() * _sun.global_transform.basis.z
		print("Sonne Schirm ", Vector2(lv.x, -lv.y).normalized(), " Laenge ", Vector2(lv.x, lv.y).length())
	# 457.2: Bildbreite und Tiefe der breiten Linie aus der Kamera, die gerade zeichnet, und der Kampfmitte (im Spiel wie
	# vorher: Tiefe d0, Breite mit dem Zoom); Proben mit eigener Kamera oder Nähe setzen [ink_ziel] auf ihr Bildziel
	var c := cam
	var wo: Vector3 = to_global(_ground(0, 0))
	if ink_ziel != null:
		wo = ink_ziel
		if get_viewport().get_camera_3d() != null:
			c = get_viewport().get_camera_3d()
	Signatur.nachfuehren(_ink_mats, c, _sun, wo, get_viewport().get_visible_rect().size)


## Die Lichtung (tools/blender348/kampfort_wald.py): Bäume, Büsche, Steine, Boden mit Weg und Sonnentupfen, Grasbüschel.
## Der Wald-Knoten liegt in der Kampfmitte, um 60° gedreht: örtlich x = zu den Gegnern (a), z = quer nach rechts (b).
var forest: Node3D

func _build_forest() -> void:
	forest = Node3D.new()
	forest.rotation.y = deg_to_rad(90.0 - AXIS)
	add_child(forest)
	var p := _platz_datei("kampfort-wald", "bin")     # 493
	if FileAccess.file_exists(p):
		var doc := GLTFDocument.new()
		var st := GLTFState.new()
		if doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", st) == OK:
			var n := doc.generate_scene(st) as Node3D
			_toon_all(n)
			# die nahe Eiche vorn links (kampfort_wald.py „Rahmen“) wirft keinen Schlagschatten: ihre Krone liegt außerhalb des
			# Schattenausschnitts, der Schatten kam abgeschnitten mit geraden Kanten (Prüfer Boden 2); die Maske malt ihn weich
			for mi in n.find_children("Rahmen*", "MeshInstance3D", true, false):
				(mi as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			forest.add_child(n)
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(140, 140)
	pm.subdivide_width = 8
	pm.subdivide_depth = 8
	ground.mesh = pm
	var gm := ShaderMaterial.new()
	gm.shader = load("res://kampf/wald_boden.gdshader")
	gm.set_shader_parameter("maske", _picture(_platz_datei("wald-maske", "bild").get_file().get_basename(), Color(0, 0, 0, 0)))     # 493
	gm.set_shader_parameter("gras", _picture("gras", Color(0.30, 0.38, 0.20)))
	gm.set_shader_parameter("erde", _picture("erde", Color(0.42, 0.34, 0.24)))
	ground.material_override = gm
	ground.position.y = -0.01
	forest.add_child(ground)
	_grass()
	_lichtung_806()


## 806: zwei Lichtschächte mit Staub (R7) hinter den Kämpfern, von der Kamera aus gesehen (wie _grass: 15 m Abstand, Blick örtlich
## (0,866, −0,5)); Paket fehlt oder Grafikstufe aus: nichts
func _lichtung_806() -> void:
	if OS.get_environment("EFFEKTE_806") == "0":     # Vergleich und Bilder/s vorher
		return
	# Kein Bodennebel mehr (Archiv „806, Lichtung mit Nebel“, 11.11., 12:06: mit Nebel nur, wenn die Bilder/s nicht sinken, sonst ohne):
	# Test 277 (Chef 20:27/20:30) 13 Bilder/s mit, 17 ohne, und „den Nebel habe ich wirklich nicht gesehen“; vier Lagen über den
	# ganzen Schirm kosteten am Handy etwa 18 ms je Bild. NEBEL_806=1 zeigt ihn noch zum Vergleich (Bildpaar am Rechner)
	if OS.get_environment("NEBEL_806") == "1":
		KampfEffekte.nebel(self, 0.45, 0.28)
	var cam_l := Vector2(-0.866 * 15.0, 0.5 * 15.0)
	for quer: float in [-5.5, 4.5]:
		var q := cam_l + Vector2(0.866, -0.5) * 22.0 + Vector2(0.5, 0.866) * quer
		KampfEffekte.staub(forest, Vector3(q.x, 0.0, q.y), 1.6)


func _toon_all(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(i)
			var m := ShaderMaterial.new()
			var rn: String = src.resource_name if src else ""
			# ferne Bäume ohne Tuschelinie: Schablone 1 wie Blüten (kampfort_wald.py FERN)
			m.shader = _inkless_toon() if rn.ends_with("_fern") else load("res://kampf/toon.gdshader")
			if src is BaseMaterial3D and (src as BaseMaterial3D).albedo_texture:
				m.set_shader_parameter("tex", (src as BaseMaterial3D).albedo_texture)
			else:
				m.set_shader_parameter("tex", _plain(Color.WHITE))
			if rn.begins_with("laub"):
				m.set_shader_parameter("sway", 1.0)
			mi.set_surface_override_material(i, m)
	for c in n.get_children():
		_toon_all(c)


var _inkless: Shader = null
func _inkless_toon() -> Shader:
	if _inkless == null:
		_inkless = Shader.new()
		var code: String = (load("res://kampf/toon.gdshader") as Shader).code
		_inkless.code = code.replace("render_mode cull_disabled, specular_disabled;", "render_mode cull_disabled, specular_disabled;\nstencil_mode write, compare_always, 1;")
	return _inkless


## A painted picture from tex.py (or the mask), stored as .bild so Godot does not import it.
func _picture(name: String, fallback: Color) -> Texture2D:
	var p := "res://kampf/daten/%s.bild" % name
	if FileAccess.file_exists(p):
		var img := Image.new()
		if img.load_png_from_buffer(FileAccess.get_file_as_bytes(p)) == OK:
			img.generate_mipmaps()
			return ImageTexture.create_from_image(img)
	return _plain(fallback)


## Grasbüschel wie Toms gebiet.gd (halm.gdshader), nur wo die Kamera hinsieht und nicht auf dem Weg.
func _grass() -> void:
	if OS.get_environment("HALME") == "0":     # Prüflauf: ohne Büschel
		return
	var mask := Image.new()
	var mp := _platz_datei("wald-maske", "bild")     # 493
	if not FileAccess.file_exists(mp) or mask.load_png_from_buffer(FileAccess.get_file_as_bytes(mp)) != OK:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 3487
	var xf: Array[Transform3D] = []
	var cu: Array[Color] = []
	var d := 15.0
	var cam_l := Vector2(-0.866 * d, 0.5 * d)
	var view := Vector2(0.866, -0.5)
	var side := Vector2(0.5, 0.866)
	var fwd := 8.0
	while fwd < 60.0:
		var half := 0.22 * fwd + 1.0
		var per := 11 if fwd < 30 else 4     # Chef 19:05: „bisschen mehr richtige Wiese“ (vorher 5 und 2)
		for k in int(half * 2.0 * per * 0.5):
			var q := cam_l + view * (fwd + rng.randf() * 0.5) + side * rng.randf_range(-half, half)
			var mpx: float = mask.get_width() / 140.0     # Maske 140 m (kampfort_wald.py PX)
			var px := mask.get_pixel(clampi(int((q.x + 70.0) * mpx), 0, mask.get_width() - 1), clampi(int((q.y + 70.0) * mpx), 0, mask.get_height() - 1))
			# Prüfer Boden 1: „gleichmäßig wie ein Tapetenmuster“: Dichte schwankt in Flecken von einigen Metern
			if sin(q.x * 0.9 + sin(q.y * 0.6) * 2.0) * sin(q.y * 0.7 + sin(q.x * 0.5) * 1.7) < rng.randf_range(-0.6, 0.6):
				continue
			if px.g > 0.3:     # Steine (kampfort_wald.py STEIN_ORTE)
				continue
			if px.r > 0.65 or (px.r > 0.3 and rng.randf() < 0.5):     # Rand: einzelne Büschel im Weg (ausgefranst)
				continue
			var s := rng.randf_range(0.16, 0.34)
			var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s, s * rng.randf_range(0.75, 1.2), s))
			xf.append(Transform3D(b, Vector3(q.x, 0.0, q.y)))
			var g := rng.randf_range(0.85, 1.2) * (1.0 - px.b * 0.4)
			cu.append(Color(0.95 * g, 1.0 * g, 0.85 * g, 1))
		fwd += 0.5
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for a in [0.0, PI * 0.5]:
		var r := Vector3(cos(a), 0, sin(a)) * 0.5
		var quad := [-r, r, r + Vector3.UP, -r + Vector3.UP]
		var uv := [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
		for k in [0, 1, 2, 0, 2, 3]:
			st.set_normal(Vector3.UP)
			st.set_uv(uv[k])
			st.add_vertex(quad[k])
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = st.commit()
	mm.instance_count = xf.size()
	for i in xf.size():
		mm.set_instance_transform(i, xf[i])
		mm.set_instance_custom_data(i, cu[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var hm := ShaderMaterial.new()
	hm.shader = load("res://kampf/halm.gdshader")
	hm.set_shader_parameter("tex", _picture("halme", Color(0.34, 0.39, 0.24)))
	mmi.material_override = hm
	forest.add_child(mmi)
	halm_mat = hm
	# 806 (Chef 09.11., 21:12: Kampforte mit den Paketen schöner): Gras und Blumen des Kits wie im Dorf (804, GrasBausatz) an den
	# Stellen unserer Büschel, unser Gras dann aus; fehlt das Kit oder ist der Schalter aus (698), bleibt halm.gdshader
	if GrasBausatz.aktiv():
		# Chef 10.11., 08:58: „Vielleicht ein bisschen mehr Gras“, die Blumen sah er kaum: jede zweite Stelle trägt einen zweiten
		# Büschel daneben (der Bausatz nimmt jede dritte, so 1,5-mal so viele), und in Flecken von einigen Metern Blumenwiese (Bausatz:
		# dort 30 % Blumen statt 1,5 %), damit sie als Gruppen zu sehen sind statt einzeln verstreut
		var stellen: Array[Vector3] = []
		var art := PackedByteArray()
		var rb := RandomNumberGenerator.new()
		rb.seed = 806
		for i in xf.size():
			var o: Vector3 = xf[i].origin
			var fleck: bool = sin(o.x * 0.35 + 1.3) * sin(o.z * 0.41 + sin(o.x * 0.2)) > 0.62
			stellen.append(o)
			art.append(2 if fleck else 0)
			if i % 2 == 0:
				stellen.append(o + Vector3(rb.randf_range(-0.35, 0.35), 0.0, rb.randf_range(-0.35, 0.35)))
				art.append(2 if fleck else 0)
		kit_gras = GrasBausatz.baue(forest, stellen, art)
		# Standbild 10.11. (Jerry, vor der Vorlage): ohne unser Gras lag zwischen den Büscheln kahler Boden, und die hellen Spitzen der
		# Büschel standen wie Stroh im Bild: unser Gras bleibt als Grund, die Spitzen dunkler (Lichtung im Wald, nicht Sommerwiese)
		for k in kit_gras:
			var m := k.material_override as ShaderMaterial
			if m == null or k.name.begins_with("Gras_flower"):
				continue
			m = m.duplicate() as ShaderMaterial
			for f in ["tip_color", "dry_tip_color"]:
				var c = m.get_shader_parameter(f)
				if c is Color:
					m.set_shader_parameter(f, (c as Color).darkened(0.35))
			k.material_override = m


var kit_gras: Array[MultiMeshInstance3D] = []
## 806: die Kämpfer schieben das Gras des Kits beiseite (Kit: höchstens vier Schieber), die Gruppe zuerst
func _kit_schieber() -> void:
	if kit_gras.is_empty():
		return
	var n := 0
	for side in ["PARTY", "FOES"]:
		for fig in figures.values():
			if fig.fighter.side != side or not fig.visible:
				continue
			if n >= 4:
				return
			GrasBausatz.schieber(fig)
			n += 1


var halm_mat: ShaderMaterial = null
func _grass_spots() -> void:
	_kit_schieber()
	if halm_mat == null:
		return
	var sp: Array[Vector3] = []
	for fig in figures.values():
		if fig.visible and sp.size() < 8:
			sp.append(fig.grass_spot())
	var n := sp.size()
	while sp.size() < 8:
		sp.append(Vector3.ZERO)
	halm_mat.set_shader_parameter("spots", sp)
	halm_mat.set_shader_parameter("spot_n", n)


func _plain(c: Color) -> ImageTexture:
	var img := Image.create(4, 4, false, Image.FORMAT_RGB8)
	img.fill(c)
	return ImageTexture.create_from_image(img)


## The scene above the orders, in viewport pixels.
func scene_rect() -> Rect2:
	var vs := get_viewport().get_visible_rect().size
	# 992 (kamera_992, Wölfe Zug 2: der Kasten war ein Bild lang 1207 statt 849 px hoch, bevor er sich neu ordnete; _rand_kamera nahm
	# die Linse darum für die halbe Szene zurück, 4 % in einem Bild, und kam langsam wieder): die Szene ist die, für die die Kamera
	# zuletzt gepasst wurde (kampf_ui.fitted_h), nicht der Kasten in diesem Augenblick
	var below: float = ui.panel_height() if ui else vs.y * 0.33
	if ui and ui.fitted_h > 0.0 and ui.panel:
		below = ui.fitted_h - ui.panel.offset_bottom
	return Rect2(0, 0, vs.x, maxf(vs.y - below, vs.y * 0.4))


# FightCamera: f from the old lens, the middle of the fight at MID of the scene, the horizon f·tan(PITCH) above it;
# a level camera with shifted lens, so upright things stay upright.
var f_px := 1.0
var d0 := 14.0
var eye := 6.0
var horizon_y := 0.0

func _fit_camera() -> void:
	var g_alt := _ground(0, 0)     # 494 (Prüfer 512b, 573): Tote rücken nur mit dem Boden, nie auf ihren Platz
	var vs := get_viewport().get_visible_rect().size
	var sr := scene_rect()
	var w := sr.size.x
	var h := sr.size.y
	var u := w / 412.0
	f_px = (h * 0.72 - h * 0.40) / tan(deg_to_rad(15.0)) * LENS
	var mid_y := h * MID
	horizon_y = mid_y - f_px * tan(deg_to_rad(PITCH))
	var per_m0 := 120.0 * u / 1.75
	d0 = f_px / per_m0
	eye = d0 * tan(deg_to_rad(PITCH))
	cam.position = Vector3(0, eye, 0)
	cam.rotation = Vector3.ZERO
	cam.size = cam.near * vs.y / f_px
	cam.frustum_offset = Vector2(0, (horizon_y - vs.y / 2.0) * cam.near / f_px)
	base_size = cam.size
	base_off = cam.frustum_offset
	if forest:
		forest.position = _ground(0, 0)
	for fig in figures.values():
		if fig.dead_at >= 0:     # 573: wer gefallen ist, bleibt liegen, wo er fiel (Krogg sprang am Ende 1,5 m, Grak 2,9 m)
			fig.snap_to(fig.position + _ground(0, 0) - g_alt)
		elif zuege == 0 and not busy:
			fig.snap_to(_spot_pos(fig.fighter, shown.places[fig.fighter.id]))
		else:
			# 864 (Chef 10.11., 13:26 und 11.11., 07:08: „Beam-Schritt … in die Ausgangsgegnerlage zurück“, beam_864): wächst der Kasten zu
			# Beginn des Heldenzugs („…“ → Knöpfe), passt die Kamera neu; wer nach seinem Angriff beim Helden stehen blieb (717.1, rückt
			# erst im eigenen Zug in die Reihe), sprang hier auf seinen Platz. Jetzt rückt jeder nur mit dem Boden, der Abstand zum Platz bleibt
			var platz := _spot_pos(fig.fighter, shown.places[fig.fighter.id])
			fig.snap_to(fig.position + platz - fig.home)
			fig.home = platz
	# 992 (Chef 11.11., 20:29, Test 277: „der Bildschirm springt am Anfang zwei, dreimal … das Bild zuckt einfach ab und zu“; kamera_992:
	# Linse ein Bild lang auf Grundstellung, dann zurück, weil hier cam.size gesetzt wurde, während _rand_kamera sie zurückgenommen hatte
	# oder ein Schlag heranzoomte): die Linse bleibt im selben Bild, wo sie war, nur um die neue Grundstellung
	if not hit.is_empty():
		_hit_camera()
	elif rand_z < 1.0:
		_rand_anwenden()


## 249: Zoom und Ruck des Schlags in [hit] wie im alten MARS: in 110 ms (tödlich 220) heran, so lange der Halt dauert
## (tödlich 900 ms), in 450 ms (700) zurück; Mitte ist der Fußpunkt des Getroffenen. Über Größe und Versatz der Linse, so
## folgen Ansagen, Balken und Ring, die über screen_of gezeichnet werden, von selbst.
func _hit_camera() -> void:
	if hit.is_empty() or cam == null:
		return
	var w: String = hit.w
	var kill := w == Wucht.KILL
	var el: float = clock_ms - hit.t0
	var t_in := 220.0 if kill else 110.0
	var hold := 900.0 if kill else float(Wucht.STOP_MS[w])
	var t_out := 700.0 if kill else 450.0
	var on = figures.get(hit.on)
	if on == null or (el >= t_in + hold + t_out and el >= Wucht.jolt_ms(w)):
		hit = {}
		cam.size = base_size
		cam.frustum_offset = base_off
		cam_z = 1.0
		return
	var by = figures.get(hit.by, on)
	var hz := 1.0
	if el < t_in:
		hz = _soft(el / t_in)
	elif el > t_in + hold:
		hz = 1.0 - _soft(minf((el - t_in - hold) / t_out, 1.0))
	var jp := Wucht.jolt(el / Wucht.jolt_ms(w))
	var z := 1.0 + hz * (0.10 if kill else Wucht.zoom(w)) + 0.03 * jp
	if not hit.has("pivot"):
		hit["pivot"] = _pivot(_near_of(on.position), 1.0 + (0.10 if kill else Wucht.zoom(w)) + 0.03)
	var p: Vector2 = hit.pivot
	var z0: float = hit.get("z0", 1.0)
	if absf(z0 - 1.0) > 0.0001 and el < t_in:     # 438: vom Stand des vorigen Schlags weich zum neuen (992: auch aus dem Rückzug von _rand_kamera)
		var s := _soft(el / t_in)
		z = lerpf(z0, z, s)
		p = (hit.p0 as Vector2).lerp(p, s)
	cam_z = z
	cam_p = p
	cam.size = base_size / z
	var off := p + (base_off - p) / z
	# der Ruck: die Szene ein Stück vom Schlagenden zum Getroffenen hin (am Schirm, in dp)
	var dir := p - _near_of(by.position)
	if dir.length() > 0.0001:
		var vs := get_viewport().get_visible_rect().size
		off -= dir.normalized() * jp * Wucht.jolt_dp(w) * (vs.x / 412.0) * cam.size / vs.y
	cam.frustum_offset = off


## 438 (Prüfer Film r2: Wolf rechts halb abgeschnitten, 42,6 s; wolf_mess_438: ein Wolf auf dem Umweg um den Nachbarn bis 175 px
## aus dem Bild): läuft eine Figur über den Rand der Szene, geht die Linse weich ein Stück zurück (um die Mitte der Szene), bis alle
## im Bild sind, und danach langsam wieder heran. Während eines Schlags (hit) führt _hit_camera.
var rand_z := 1.0
const RAND_RAUS := 0.18     # je Bild zum nötigen Rückzug
const RAND_REIN := 0.03     # je Bild zurück zur Grundstellung
func _rand_kamera() -> void:
	if cam == null or not hit.is_empty():
		rand_z = 1.0
		return
	var vs := get_viewport().get_visible_rect().size
	var sr := scene_rect()
	var c := sr.size / 2.0
	var m := 8.0 * vs.x / 412.0
	var need := 1.0
	for fig in figures.values():
		if not fig.visible or fig.dead_at >= 0:
			continue
		# 438 (wolf_mess_438: Wolf 1 lief nach dem Fehlbiss an den Rand, die Linse kam erst nach): wer unterwegs ist, zählt
		# auch an den Ecken seiner Bahn, so geht die Linse schon zurück, bevor er ankommt
		var vers: Array = [Vector3.ZERO]
		if fig.unterwegs():
			for bp in fig.bahn:
				vers.append(Vector3(bp.x - fig.position.x, 0.0, bp.z - fig.position.z))
		for k in fig.kapseln():
			for v in vers:
				for q0 in [k[0], k[1]]:
					var q: Vector3 = q0 + v
					var s0: Vector2 = c + (screen_of(q) - c) / rand_z     # wo der Punkt ohne Rückzug läge
					var d: Vector2 = s0 - c
					# 438 (wolf_mess_438, Lauf 153: Wolf 1 bis 56 px draußen): mit der Dicke der Kapsel, nicht nur ihrer Achse
					var r0: float = k[2] / m_per_dp(q) * (sr.size.x / 412.0) / rand_z
					if absf(d.x) > 1.0:
						need = minf(need, (c.x - m) / (absf(d.x) + r0))
					if absf(d.y) > 1.0:
						need = minf(need, (c.y - m) / (absf(d.y) + r0))
		# 415 r4 (Lauf 181, G1): auch Waffe und Schild ganz im Bild
		for q in fig.waffen_punkte():
			var dw: Vector2 = (screen_of(q) - c) / rand_z
			if absf(dw.x) > 1.0:
				need = minf(need, (c.x - m) / absf(dw.x))
			if absf(dw.y) > 1.0:
				need = minf(need, (c.y - m) / absf(dw.y))
		# 988 (wolf_mess_438 Lauf 369: CLERIC neigte sich beim Ausweichen auf der Stelle 11 px über den Rand): eine Bewegung auf
		# der Stelle zählt mit allen Haltungen, die sie noch nimmt (Figur.reichweite), nicht nur mit der jetzigen
		var rw: Array = fig.reichweite.get(String(fig.anim.current_animation), []) if fig.anim else []
		for e in rw:
			var q: Vector3 = fig.global_transform * (e[0] as Vector3)
			var d3: Vector2 = (screen_of(q) - c) / rand_z
			var r3: float = float(e[1]) / m_per_dp(q) * (sr.size.x / 412.0) / rand_z
			if absf(d3.x) > 1.0:
				need = minf(need, (c.x - m) / (absf(d3.x) + r3))
			if absf(d3.y) > 1.0:
				need = minf(need, (c.y - m) / (absf(d3.y) + r3))
		# 438 (wolf_mess_438: Wolf 1 drehte am Rand auf der Stelle, der Kopf schwang 45 px hinaus): wer gerade läuft oder dreht,
		# zählt mit dem ganzen Kreis, den sein Körper beim Drehen überstreicht
		if fig.tween and fig.tween.is_running():
			var rr := 0.0
			for k in fig.kapseln():
				for q0 in [k[0], k[1]]:
					rr = maxf(rr, Vector2(q0.x - fig.position.x, q0.z - fig.position.z).length() + k[2])
			for v in vers:
				for dv in [Vector3(rr, 0, 0), Vector3(-rr, 0, 0), Vector3(0, 0, rr), Vector3(0, 0, -rr)]:
					var d2: Vector2 = (screen_of(fig.position + v + dv) - c) / rand_z
					if absf(d2.x) > 1.0:
						need = minf(need, (c.x - m) / absf(d2.x))
	need = clampf(need, 0.8, 1.0)
	rand_z = lerpf(rand_z, need, RAND_RAUS if need < rand_z else RAND_REIN)
	if absf(rand_z - 1.0) < 0.001:
		rand_z = 1.0
	_rand_anwenden()


## 992: die Linse nach rand_z um die Mitte der Szene (aus _rand_kamera und _fit_camera); rand_p ist diese Mitte (ein Schlag beginnt dort)
var rand_p := Vector2.ZERO
func _rand_anwenden() -> void:
	var vs := get_viewport().get_visible_rect().size
	var c := scene_rect().size / 2.0
	var per := base_size / vs.y
	rand_p = Vector2(base_off.x + (c.x - vs.x / 2.0) * per, base_off.y - (c.y - vs.y / 2.0) * per)
	cam.size = base_size / rand_z
	cam.frustum_offset = rand_p + (base_off - rand_p) / rand_z


## 348.7 (Helfer Lauf 126: Heldin am Rand angeschnitten): die Mitte des Zooms so nah an [p] wie möglich, aber so, dass bei
## [z] jede stehende Figur ganz in der Szene bleibt (über dem Bedienfeld, 8 dp Rand); geht das nicht, bleibt es bei [p].
func _pivot(p: Vector2, z: float) -> Vector2:
	var vs := get_viewport().get_visible_rect().size
	var per_px := base_size / vs.y
	var half := Vector2(vs.x, vs.y) * per_px / 2.0
	var m := 8.0 * (vs.x / 412.0) * per_px
	var below := (vs.y - scene_rect().size.y) * per_px
	var lo := Vector2(base_off.x - half.x + m, base_off.y - half.y + below + m)
	var hi := Vector2(base_off.x + half.x - m, base_off.y + half.y - m)
	var k := 1.0 - 1.0 / z
	var c := p
	# erst alle; passt das nicht, wenigstens die Gruppe und der Getroffene (Helfer: Mira am linken Rand halb abgeschnitten)
	for only_party in [false, true]:
		var r := _pivot_range(p, z, k, lo, hi, only_party)
		if r[0].x <= r[1].x and r[0].y <= r[1].y:
			c.x = clampf(p.x, r[0].x, r[1].x)
			c.y = clampf(p.y, r[0].y, r[1].y)
			break
	return c


func _pivot_range(p: Vector2, z: float, k: float, lo: Vector2, hi: Vector2, only_party: bool) -> Array:
	var mn := Vector2(-INF, -INF)
	var mx := Vector2(INF, INF)
	for fig in figures.values():
		if not fig.visible or fig.down:
			continue
		if only_party and fig.fighter.side != "PARTY" and fig != figures.get(hit.get("on", "")):
			continue
		var foot := _near_of(fig.position)
		var top := _near_of(fig.head())
		var wolf: bool = Figur.vier(fig.fighter)
		var w: float = (top.y - foot.y) * (0.8 if wolf else 0.45)
		for q in [Vector2(foot.x - w, foot.y), Vector2(foot.x + w, top.y)]:
			# sichtbar bei Zoom z um c: lo ≤ c + (q - c)·z … umgestellt nach c
			mx.x = minf(mx.x, (q.x - lo.x / z) / k)
			mn.x = maxf(mn.x, (q.x - hi.x / z) / k)
			mx.y = minf(mx.y, (q.y - lo.y / z) / k)
			mn.y = maxf(mn.y, (q.y - hi.y / z) / k)
	return [mn, mx]


## Wo [q] (Welt) auf der Nahebene der Kamera liegt, in deren Maß (wie frustum_offset).
func _near_of(q: Vector3) -> Vector2:
	var rel := q - cam.position
	return Vector2(rel.x, rel.y) * cam.near / maxf(-rel.z, 0.01)


static func _soft(x: float) -> float:
	return 0.5 - 0.5 * cos(PI * clampf(x, 0.0, 1.0))


## Meter je dp an der Stelle [q] ohne Zoom (für das Zittern des Getroffenen).
func m_per_dp(q: Vector3) -> float:
	var vs := get_viewport().get_visible_rect().size
	return (vs.x / 412.0) * maxf(cam.position.z - q.z, 0.1) / f_px


## Where (a, b) lies: a metres along the fight towards the foes, b across to the right (FightCamera.ground).
func _ground(a: float, b: float) -> Vector3:
	var ax := sin(deg_to_rad(AXIS))
	var ad := cos(deg_to_rad(AXIS))
	return Vector3(a * ax + b * ad, 0, -(d0 + a * ad - b * ax))


## The way a figure of [foe] faces, in the world.
func facing(foe: bool) -> Vector3:
	var ax := sin(deg_to_rad(AXIS))
	var ad := cos(deg_to_rad(AXIS))
	var d := Vector3(ax, 0, -ad)
	return -d if foe else d


## FightCamera.stand
func _stand(foe: bool, back: bool, slot: int, alone: bool) -> Vector2:
	var row := BACK_M if back else FRONT_M
	if not foe and back and not alone:
		return Vector2(-row - NEAR_M + 0.6, 0.6 + (-0.7 if slot == 0 else 0.7))
	var half := FOE_HALF_M if foe else HALF_M
	var b := (0.0 if foe else ALONE_HERO_B) if alone else (-half if slot == 0 else half)
	# Gegner vorn links ein Stück weiter weg: sonst stand der Kopf des Söldners zwischen seinen Vorderläufen (Prüfer Runde 8)
	if foe and not back and not alone and slot == 0:
		row += FOE_LEFT_BACK_M
		b -= FOE_LEFT_OUT_M
	return Vector2(row, b) if foe else Vector2(-row - NEAR_M, b)


func _spot_pos(f, spot: Vector2i) -> Vector3:
	var ab := _spot_ab(f, spot)
	# 587 (Läufe 275/276, groesse_587: mit 1,3-fach stand die Riesenspinne hinten 0,22 m im Wolf vorn; Grimmzahn 0,84 m im Wolf
	# hinten): wer hinten steht, weicht den Umrissen der vorderen aus (Wölfe des Rudels reichen schon, bleiben wie 438)
	if f.side == "FOES" and spot.x == Mars.BACK:
		ab = _ausweichen(f, ab)
	return _ground(ab.x, ab.y)


const AUSWEICH_LUFT := 0.08     # 587: Meter zwischen den Umrissen
## 587: rückt ab (a in die Tiefe, b zur Seite) so weit, dass der Umriss von f am Boden (wie groesse_587: Kasten im Raum) keinen
## vorderen Gegner deckt: zur Seite oder nach hinten, je nachdem, was weniger weit ist
func _ausweichen(f, ab: Vector2) -> Vector2:
	var b := _umriss(f)
	if b.size == Vector2.ZERO:
		return ab
	var vorn := []
	for o in mars.fighters():
		if o != f and o.side == "FOES" and shown.places.has(o.id) and shown.places[o.id].x == Mars.FRONT and _present(o):
			var a := _umriss(o)
			if a.size != Vector2.ZERO:
				var ao := _spot_ab(o, shown.places[o.id])
				var g := _ground(ao.x, ao.y)
				vorn.append(Rect2(a.position + Vector2(g.x, g.z), a.size).grow(AUSWEICH_LUFT / 2.0))
	if vorn.is_empty():
		return ab
	var frei := func(q: Vector2) -> bool:
		var g := _ground(q.x, q.y)
		var r := Rect2(b.position + Vector2(g.x, g.z), b.size).grow(AUSWEICH_LUFT / 2.0)
		for v in vorn:
			if r.intersects(v):
				return false
		return true
	if frei.call(ab):
		return ab
	var w := 0.05
	while w <= 4.0:
		for q in [ab + Vector2(0.0, w), ab + Vector2(0.0, -w), ab + Vector2(w, 0.0)]:
			if frei.call(q):
				return q
		w += 0.05
	return ab


## 587: nach den ersten Bildern die Umrisse der Gegner messen (dann stimmen sie, wie groesse_587 und wolf_mess_438 sie lesen) und
## wer hinten steht und noch daheim ist, an die Stelle setzen, die den vorderen ausweicht
const UMRISS_NACH := 10
func _umriss_messen() -> void:
	for i in UMRISS_NACH:
		await get_tree().process_frame
		if not is_inside_tree():
			return
	for fig in figures.values():
		if fig.fighter.side == "FOES" and fig.visible:
			fig.footprint()
	for fig in figures.values():
		var f = fig.fighter
		if f.side == "FOES" and shown.places.has(f.id) and shown.places[f.id].x == Mars.BACK and fig.position.distance_to(fig.home) < 0.01:
			fig.snap_to(_spot_pos(f, shown.places[f.id]))


## 587: Umriss einer Figur am Boden als Kasten im Raum um ihren Ursprung (x, z; figur.gd footprint, wie groesse_587), leer ohne Figur
func _umriss(f) -> Rect2:
	# Lauf 284 (Kaufwölfe 15,6 m „ineinander“): früh gefragt, vor dem ersten Bild, merkt sich die Figur einen falschen Umriss;
	# darum nur, wenn er schon da ist (_umriss_messen)
	if f == null or not figures.has(f.id) or not figures[f.id].is_inside_tree() or not figures[f.id]._foot_ok:
		return Rect2()
	var fig = figures[f.id]
	var bb: AABB = Transform3D(fig.global_transform.basis, Vector3.ZERO) * fig.footprint()
	return Rect2(bb.position.x, bb.position.z, bb.size.x, bb.size.z)


func _spot_ab(f, spot: Vector2i) -> Vector2:
	var alone := _alone(f, spot.x)
	var ab := _stand(f.side == "FOES", spot.x == Mars.BACK, spot.y, alone)
	# a foe alone in the back behind two in front stands between and behind them, not hidden behind the right one
	# (SkirmishScreen.kt BACK_GAP_A, BACK_GAP_B, Build 89)
	if f.side == "FOES" and spot.x == Mars.BACK and alone and not _alone(null, Mars.FRONT, "FOES"):
		ab = Vector2(ab.x + BACK_GAP_A, BACK_GAP_B)
	# 438 (Chef 31.10., 23:31, Film 403: Wölfe „wieder aneinander vorbeigehen“; tests/wolf_mess_438.gd): einer allein vorn, einer
	# allein hinten standen genau hintereinander, 1,5 m Mitte zu Mitte, der Kaufwolf ist 2,3 m lang: 0,5 m ineinander. Hinten
	# dann schräg versetzt wie das Paar hinten (PAIR_BACK_*), um eine Wolfslänge
	elif f.side == "FOES" and spot.x == Mars.BACK and alone and _count(Mars.FRONT, "FOES") == 1:
		ab = Vector2(ab.x + SOLO_BACK_A, SOLO_BACK_B)
	elif f.side == "FOES" and spot.x == Mars.FRONT and alone and _count(Mars.BACK, "FOES") == 1:
		ab.y += SOLO_FRONT_B
	# 348.7 Grimmzahn Runde 7 (Prüfer Runde 6: „Wolf auf Wolf“, „zweiköpfiger Wolf“): einer allein vorn vor zweien hinten stand
	# im Bild genau vor dem linken hinteren (37 % verdeckt); vorn ein Stück nach rechts, hinten weiter auseinander und zurück
	if f.side == "FOES" and _alone(null, Mars.FRONT, "FOES") and not _alone(null, Mars.BACK, "FOES") and _count(Mars.FRONT, "FOES") == 1:
		if spot.x == Mars.FRONT:
			ab.y += PAIR_FRONT_B
		else:
			ab.x += PAIR_BACK_A
			ab.y += PAIR_BACK_B * (-1.0 if spot.y == 0 else 1.0)
			ab.y += PAIR_BACK_SHIFT
	if f.side == "FOES":
		ab = _naeher(f, ab, spot.x == Mars.BACK)
	return ab


## 506.1 (Chef 10.11., 12:25, Film 506: „der dritte Wiedergänger … steht ja so weit hinten … läuft ja allein schon eine halbe
## Stunde … cool, dass die so langsam gehen. Aber die müssen irgendwie dann näher am Gegner sein“): wer langsam geht (Anmarsch
## unter LANGSAM_MPS, gemessen am Wurzelweg seines Modells: Wiedergänger 0,82–0,88 m/s, Skelett rund 1,6), steht in der
## Nahaufstellung: vorn NAH_VORN_M (Tiefe) vor dem Helden, hinten NAH_REIHE_M dahinter; sein Gang bleibt langsam. Die übrigen
## Gegner (Wölfe, Goblins, Skelette) stehen wie abgenommen. Nur näher, nie weiter weg
const LANGSAM_MPS := 1.2
const NAH_VORN_M := 3.0       # vordere Reihe: Mitte zu Mitte in der Tiefe zum Helden (vorher 3,8–4,35 m)
const NAH_REIHE_M := 1.6       # hintere Reihe so weit hinter der vorderen (anmarsch_506_1: Deckung im Bild 32 %, bei 1,3 m 35 %)
## 567: allein hinter zweien vorn stand er mit BACK_GAP_B −2,0 bei 3,6 m Tiefe hinter der Mitte der beiden (−0,22) im Bild mittig:
## je Meter Tiefe 0,49 m nach links
const NAH_SCHRAEG := -(-0.22 - BACK_GAP_B) / (BACK_M + BACK_GAP_A - (FRONT_M + FOE_LEFT_BACK_M + FRONT_M) / 2.0)
func _naeher(f, ab: Vector2, hinten: bool) -> Vector2:
	if not _langsam(f):
		return ab
	var held_a := -(FRONT_M + NEAR_M)
	if not hinten:
		return Vector2(minf(ab.x, held_a + NAH_VORN_M), ab.y)
	var a := minf(ab.x, held_a + NAH_VORN_M + NAH_REIHE_M)
	# allein hinter zweien vorn (BACK_GAP_B: im Bild mittig dahinter): die Tiefe verschiebt im Bild zur Seite (Achse 30°), darum
	# mit der kürzeren Tiefe weniger weit nach links, so dass er im Bild zwischen den beiden bleibt
	var vorn := []
	for o in mars.fighters():
		if o != f and o.side == "FOES" and shown.places.has(o.id) and shown.places[o.id].x == Mars.FRONT and _present(o):
			vorn.append(_spot_ab(o, shown.places[o.id]))
	if vorn.size() == 2 and _alone(f, Mars.BACK):
		var mitte: Vector2 = (vorn[0] + vorn[1]) / 2.0
		return Vector2(a, mitte.y + NAH_SCHRAEG * (a - mitte.x))
	return Vector2(a, ab.y)


func _langsam(f) -> bool:
	if not figures.has(f.id) or f.ranged():
		return false
	var v: float = figures[f.id].anmarsch_mps()
	return v > 0.0 and v < LANGSAM_MPS


func _alone(f, row: int, side := "") -> bool:
	var sd: String = f.side if f != null else side
	var n := 0
	for o in mars.fighters():
		if o != f and o.side == sd and shown.places.has(o.id) and shown.places[o.id].x == row and _present(o):
			n += 1
	return n == 0 if f != null else n <= 1


func _count(row: int, side: String) -> int:
	var n := 0
	for o in mars.fighters():
		if o.side == side and shown.places.has(o.id) and shown.places[o.id].x == row and _present(o):
			n += 1
	return n


func _present(f) -> bool:
	return shown.hp.get(f.id, f.hp) > 0 or figures.has(f.id) and figures[f.id].falling()


## Screen point of a world position (for names, signs, the ring).
func screen_of(p: Vector3) -> Vector2:
	return cam.unproject_position(p)


func foe_scale(f) -> float:
	if f.monster == null:
		return 1.0
	# 399.2a: der Jungwolf halb so groß wie der Wolf (Packs.kt cubs 0,55)
	return _foe_scale(f) * float(f.monster.get("scale", 1.0))


func _foe_scale(f) -> float:
	if Figur.vier(f):
		if Figur.ersatz().begins_with("kauf_"):     # 387: gekaufte Tiere (kauftier.py) in echter Größe wie im Kauf
			return 1.0
		return FOE_SIZE * WOLF_SIZE * ART_SIZE.get(Figur.ersatz(), 1.0)
	if Figur.eigene_haut(f):
		return 1.0     # 494 Riesenspinne (kaufspinne.py, Spannweite 1,69 m wie LISTE-FIGUREN): echte Größe wie die Kauftiere, nicht 1,5-fach
	if Mars.koerper_of(f.monster) in Figur.ZWEI:     # 348.7: Goblin in echter Größe (goblin.py), im Bild wie FoeArt (PX 0,66 wie BeastArt, Held 0,75); 348.12 Grak ebenso
		return FOE_SIZE * WOLF_SIZE
	return FOE_SIZE


# ---------------------------------------------------------------- the rules' thread (ProbeRun)
func _post(b: Dictionary) -> void:
	beats_lock.lock()
	beats.append(b)
	beats_lock.unlock()


func _react(t, intent) -> String:
	_post({"ring": t.id, "intent": intent})
	ring_sem.wait()
	return ring_answer


func _run(block: Callable) -> void:
	busy = true
	# 399.2 (Test 133, Chef 16:4x: „gar keine Option, eine Tasche oder Flucht oder Abwehr zu klicken … kann anscheinend nur noch
	# kämpfen“; Foto: nur „WOLF 6/12“ und „ZURÜCK“): nach einem Befehl wieder die Hauptauswahl wie SkirmishScreen.order (pick =
	# Pick.Main); bisher erst, wenn ein Gegner den Helden angriff (ring_open), sonst blieb die Zielwahl stehen
	ui.pick = "main"
	ui.pick_arg = null
	ui.refresh()
	if worker and worker.is_started():
		worker.wait_to_finish()
	worker = Thread.new()
	worker.start(func():
		block.call()
		_post({"done": true}))


func order(o: Array) -> void:
	if busy or mars.outcome != "ONGOING":
		return
	_run(func(): mars.act(o, _react))


func go_on() -> void:
	if busy or mars.outcome != "ONGOING":
		return
	_run(func(): mars.proceed(_react))


## 272 (Testmodus): gewinnen oder verlieren sofort; läuft der Kampf noch, gilt es, sobald er wartet (SkirmishScreen endAsked).
## 545 (Chef 05.11., 19:2x: „der Knopf erst greift, wenn Held am Zug -> muss vorher wirken“): läuft der Kampf, überspringt er den
## Rest (_skip_beats), statt jeden Zug der Gegner abzuspielen; so gilt der Knopf gleich, auch wenn der Held nicht am Zug ist
var end_asked = null
func test_end(win: bool) -> void:
	if mars.outcome != "ONGOING":
		return
	if busy:
		end_asked = win
		if ring_open:
			_answer_ring(Mars.GOOD)
		return
	end_asked = null
	_run(func(): mars.test_end(win))


## 545: der Rest des laufenden Zugs ohne Bild: Worte fallen weg, Ringe gelten als gut (der Held fällt dabei nicht unnötig),
## am Ende („done“) wirkt der Knopf (_done)
func _skip_beats() -> void:
	beats_lock.lock()
	var rest := beats.duplicate()
	beats.clear()
	beats_lock.unlock()
	for x in rest:
		if x.has("ring"):
			ring_answer = Mars.GOOD
			ring_sem.post()
		elif x.has("done"):
			_done()
			return


func tap() -> void:
	if not ring_open:
		return
	var off := absi(Time.get_ticks_msec() - (ring_start + RING_MS))
	_answer_ring(Mars.PERFECT if off <= PERFECT_MS else (Mars.GOOD if off <= GOOD_MS else Mars.NONE))


func _answer_ring(r: String) -> void:
	if not ring_open:
		return
	ring_open = false
	ring_answer = r
	ui.ring_verdict(r)
	var klang = get_node_or_null("/root/Klang")
	if klang != null and r != Mars.NONE:
		klang.effekt("block", 0.8 if r == Mars.PERFECT else 0.5)     # 939 (alt SkirmishScreen 726): Block bei perfekt, leiser bei gut
	ring_sem.post()


## 999: welche Waffe jeder der Gruppe gerade führt (Fighter.drawn), mit der Meldung, wie sie gesagt wurde; die Figur zeigt sie, wenn
## die Meldung dran ist (Wechsel ohne Zugverlust, mars.gd „draw“, „swap“ mit Waffe)
func _mit_waffen(e: Dictionary) -> Dictionary:
	var d := {}
	for f in mars.fighters():
		if f.hero != null:
			d[f.id] = f.drawn
	e["drawn"] = d
	return e


func _state_now() -> Dictionary:
	var hp := {}
	var places := {}
	var sp := {}
	for f in mars.fighters():
		hp[f.id] = f.hp
		places[f.id] = f.place
		sp[f.id] = f.sp
	return {"hp": hp, "places": places, "intents": mars.intents.duplicate(), "queue": mars.queue(), "sp": sp, "status": mars._statuses(), "hidden": mars._hidden()}


# ---------------------------------------------------------------- playing the beats one after another
func _process(_dt: float) -> void:
	_ink_licht()
	clock_ms += _dt * 1000.0
	_hit_camera()
	_rand_kamera()
	_grass_spots()
	if ring_open and Time.get_ticks_msec() > ring_start + RING_MS + GOOD_MS + 60:
		_answer_ring(Mars.NONE)
	if playing or verhuellt or messpause:     # 402: unter der Blende warten Worte und Züge; 806: ebenso beim Messen
		return
	if end_asked != null:
		_skip_beats()
		return
	beats_lock.lock()
	var b = beats.pop_front() if not beats.is_empty() else null
	beats_lock.unlock()
	if b == null:
		return
	playing = true
	if b.has("say"):
		await _play_say(b.say)
	elif b.has("ring"):
		await _play_ring(b.ring, b.intent)
	elif b.has("done"):
		_done()
	playing = false


func _play_say(e: Dictionary) -> void:
	var before: Dictionary = shown.hp
	if OS.get_environment("DBGPL") != "" and absf(clock_ms / 1000.0 - float(OS.get_environment("DBGPL"))) < 4.0:
		print("PL %.1f actor %s cue %s text %s places %s" % [clock_ms / 1000.0, e.actor, e.cue, String(e.text).left(50), e.places])
	shown = e
	# 566: wer im Schatten steht, ist nur schwach zu sehen (figur.gd im_schatten)
	var im_schatten: Dictionary = e.get("hidden", {})
	for id in figures:
		figures[id].im_schatten(im_schatten.has(id))
	for id in e.get("drawn", {}):     # 999
		if figures.has(id):
			figures[id].waffe_ziehen(bool(e.drawn[id]))
	for f in mars.fighters():
		# called to the fight (Hilfe rufen); the rules' thread may already hold one this message does not know yet
		if not figures.has(f.id) and e.places.has(f.id):
			var fig := Figur.new()
			fig.setup(f, self)
			add_child(fig)
			figures[f.id] = fig
			fig.snap_to(_spot_pos(f, e.places[f.id]) + facing(true) * -3.0)
	var actor = e.actor
	var target = e.target
	var by = mars.find(actor) if actor != null else null
	var tg = mars.find(target) if target != null else null
	var across: bool = by != null and tg != null and actor != target and by.side != tg.side
	var lunge_ms := 0
	var busy_ms := 0
	if across and (e.roll != null or e.spell != null or e.cue == "DUCKED"):
		lunge_ms = figures[actor].strike(figures[target], e)
		busy_ms = figures[actor].busy_ms
	# 717.1 A (Chef 09.11., 09:03/09:06; F8): Zurechtrücken beginnt im Zug der Gegner und darf in den Zug des Helden hinein auslaufen,
	# nie erst dort anfangen: was im Zug des Helden umgestellt wurde (glide_to merkt es vor), rückt mit dem nächsten Zug der Gegner
	if by != null and by.side == "FOES":
		for fid in figures:
			if fid != actor or lunge_ms == 0:
				figures[fid].zurueck_in_reihe()
	for id in e.intents:
		var aimed: Array = e.intents[id][1]
		figures[id].announce(e.intents[id][0], figures.get(aimed[0]) if aimed.size() > 0 else null)
	for id in figures:
		if not e.intents.has(id):
			figures[id].announce(null)
	# 439 (Chef 31.10., 23:31: „beim Helden einmal die Treffer-Animation, bevor der Angriff richtig da war“; tests/wolf_mess_438.gd):
	# „wirft sich auf …“ (POUNCED) kommt als eigene Meldung nach dem Sprungbiss, wenn der Wolf schon wieder daheim steht; der Held fiel
	# dann ohne Wolf. Jetzt fällt er beim Aufprall des Sprungs (mars.gd: ein Sprung, der trifft und ihn stehen lässt, wirft ihn um),
	# und die Meldung danach zeigt nur noch den Text.
	if lunge_ms > 0 and actor != null and target != null and figures[actor].letzter_sprung and e.damage > 0 \
			and e.hp.get(target, 1) > 0 and figures.has(target):
		var opfer = figures[target]
		opfer.sturz_vorweg = true
		get_tree().create_timer(int(lunge_ms * 0.42) / 1000.0).timeout.connect(func(): if is_instance_valid(opfer): opfer.knocked_down())
	if e.cue == "POUNCED" and target != null:
		if figures[target].sturz_vorweg:
			figures[target].sturz_vorweg = false
		else:
			figures[target].knocked_down()
	elif e.cue == "RISES" and actor != null:
		figures[actor].rise()
	elif e.cue == "CIRCLE" and actor != null:
		figures[actor].howl()
	elif e.cue == "FOE_FLEES" and target != null and figures.has(target):     # 399.2a: die Jungwölfe laufen nach hinten davon
		figures[target].flee_off(-facing(true))
	var lands := int(lunge_ms * 0.42)
	# 348.7 (Rest aus 249, BattleFxLayer): Zauber und Pfeile fliegen sichtbar, auch daneben; der Treffer fällt, wenn sie ankommen
	var fx = _fx_of(e, by, tg, across)
	if fx != null:
		fx_zahl[fx] = int(fx_zahl.get(fx, 0)) + 1
		var los: float = maxf(0.0, float(figures[actor].netz_los_ms)) if fx == "WEB" else 0.0     # 494: das Netz fliegt mitten im Netzwurf los
		if fx in Zauber.BOMBS:     # 935: die Flasche fliegt los, wenn der Arm über dem Kopf nach vorn geht
			los = maxf(0.0, float(figures[actor].wurf_los_ms))
		var step: float = ui.cast(fx, actor, target, _crit(e), _missed(e) or e.cue == "DUCKED", los)
		lands = int(step + los + Zauber.arrives(fx))
		busy_ms = maxi(busy_ms, figures[actor].busy_ms)     # 348.7b: Seitenschritt hin und zurück
	# 438 (Prüfer Film 08:18: Würfelzeile, Schaden und Leiste 0:07,9, der Wolf trifft den Helden erst 0:09,7): Meldung, Würfel,
	# Lebensleisten und Bedienfeld erst beim Aufschlag (DESIGN-ABNAHME: „Bewegung zuerst, dann eine einzige Textzeile mit Ausgang
	# und Schaden“); bis dahin zeigt shown die Leben von vorher
	var spaeter: bool = lands > 0 and (lunge_ms > 0 or fx != null)
	if spaeter:
		var vorher := e.duplicate()
		vorher.hp = before
		shown = vorher
		var sturz: bool = target != null and figures.has(target) and figures[target].sturz_vorweg
		get_tree().create_timer(lands / 1000.0).timeout.connect(func():
			if is_same(shown, vorher):
				shown = e
			_zeigen(e)
			# 438 (Prüfer Film r2: „prallt gegen Ansgar“ 3,7 s nach dem Biss): die Meldung zum Sturz (POUNCED) kommt von den Regeln
			# erst nach dem Sprungbiss, gespielt, wenn der Wolf daheim ist; der Held fällt aber beim Aufprall. Jetzt steht sie mit dem Biss
			if sturz:
				_vorweg("POUNCED", target))
	else:
		_zeigen(e)
	# 399.3: Klang der Meldung wie MarsSound.kt, der Treffer, wenn er im Bild landet (nur mit dem Autoload Klang der Spielfassung)
	var klang = get_node_or_null("/root/Klang")
	if klang != null and not e.get("klang_vorweg", false):     # 296.3: schon mit der Zeile vorweg gespielt
		klang.kampf(e, mars, lands if lunge_ms > 0 or fx != null else -1)
	for id in e.hp:
		if not figures.has(id):
			continue
		var was: int = before.get(id, e.hp[id])
		# 406: wer mit Schild kämpft, wehrt ab, bevor der Angriff ankommt (Figur.abwehr); welche Abwehr, sagt die Art des Angriffs
		var art := ""
		if target == id and across and actor != null and figures.has(actor):
			art = "sprung" if figures[actor].letzter_sprung and lunge_ms > 0 else ("fern" if fx != null else "nah")
		if e.hp[id] < was:
			var mx: int = mars.find(id).max_hp if mars.find(id) != null else 1
			figures[id].hurt(lands, e.hp[id] <= 0, (was - e.hp[id]) * 4 >= mx, art)
		elif target == id and _missed(e) and across and figures[id].blockt():
			# 406.2: gelungene Abwehr nach der Seite des Angreifers, gegen tiefe Gegner tief
			var af = figures.get(actor)
			var von := Vector3.INF     # 662: vom Platz, an dem der Angriff ankommt, nicht von dort, wo er losläuft
			if af != null:
				von = to_global(af.angriff_von) if af.angriff_von != Vector3.INF else af.global_position
			figures[id].abwehr(lands, art, von, true, af != null and af.niedrig())
		elif target == id and _missed(e) and across:
			# 438 (Prüfer Film r2: Klinge durch Wolf 2 ohne Treffer): wer ausweicht, ist schon weg, wenn der Hieb ankommt
			figures[id].dodge(maxi(0, lands - AUSWEICH_VOR_MS) if lunge_ms > 0 and fx == null else lands)
	# 249 (wie im alten MARS, SkirmishScreen.kt): beim Aufschlag rückt ein kritischer oder tödlicher Schlag die Szene heran
	# und ruckt sie in Schlagrichtung; ein Hieb, Biss oder Schuss, der trifft, lässt Blut spritzen, weg vom Schlagenden
	if target != null and actor != null and e.damage > 0 and figures.has(target) and tg != null:
		var crit := _crit(e)
		var w := Wucht.of(crit, e.damage, tg.max_hp, e.hp.get(target, 1) <= 0)
		var gore := 1.0 - float(e.hp.get(target, 0)) / maxi(tg.max_hp, 1)
		var wound: bool = e.wound and blood_level() > 0
		get_tree().create_timer(lands / 1000.0).timeout.connect(func():
			if Wucht.jolt_dp(w) > 0.0:
				# 438 (Prüfer Film 08:18: Kamera zoomt 0:38 ruckartig): kam der Schlag, während der vorige noch heranrückte,
				# sprang die Linse auf Grundstellung und von dort neu heran; jetzt beginnt er, wo die Linse gerade steht
				# 992 (kamera_992: hatte _rand_kamera die Linse zurückgenommen, sprang sie beim Schlag in einem Bild auf Grundstellung): von dort
				var z0_: float = cam_z if not hit.is_empty() or rand_z >= 1.0 else rand_z
				var p0_: Vector2 = cam_p if not hit.is_empty() or rand_z >= 1.0 else rand_p
				hit = {"by": actor, "on": target, "w": w, "t0": clock_ms, "z0": z0_, "p0": p0_}
			if wound:
				ui.bleed(actor, target, w == Wucht.CRIT or (w == Wucht.KILL and crit), gore, tg.monster.id if tg.monster != null else ""))
	# 399.2 (Chef 28.10., 16:10: „wenn nur noch zwei Wölfe da sind und die dann in einer Linie stehen, dann läuft der hintere Wolf
	# durch den vorderen“; umweg_399 Lauf 168): greift einer von hinten an, tauscht er mit dem vorderen den Platz (mars.gd
	# _leap_forward); beide liefen zugleich auf derselben Linie gegeneinander. Wer Platz macht, geht erst, wenn der Angreifer vorbei ist
	# 438 (Prüfer Film 08:18: Platztausch 1/3, während Wolf 3 angreift): wer Platz macht, geht erst nach dem Biss (Angriff, Treffer,
	# dann Neuformation wie 439), nicht schon, wenn der Angreifer anläuft
	var warte_ms: int = lands + 200 if lunge_ms > 0 and actor != null and figures.has(actor) else 0
	# 439 (Chef 31.10., 23:31: „Neuformation der Wölfe beginnt, bevor der getroffene Wolf stirbt“): fällt in dieser Meldung ein
	# Gegner, rücken die anderen erst auf, wenn er gestürzt ist und gelegen hat (Figur.sterbe_ms, LIEGT_MS); erst Angriff, Treffer,
	# Tod, dann die Neuformation. Die nächste Meldung wartet so lange.
	var tot_ms := -1
	for id in e.hp:
		if figures.has(id) and e.hp[id] <= 0 and before.get(id, 1) > 0 and figures[id].fighter.side == "FOES":
			tot_ms = maxi(tot_ms, lands + figures[id].sterbe_ms() + Figur.LIEGT_MS)
	if tot_ms > 0:
		# 438 (Prüfer Film 08:18: Todesmeldung 0,7 s nach dem Verschwinden): „… bricht zusammen“ (FOE_FALLS, die nächste Meldung
		# der Regeln) steht in der Zeile, sobald er gefallen ist, nicht erst nach Liegen und Ausblenden
		var fall_ms := -1
		for id in e.hp:
			if figures.has(id) and e.hp[id] <= 0 and before.get(id, 1) > 0 and figures[id].fighter.side == "FOES":
				# 438 (Prüfer Film r2: „sackt zusammen“ 1 s nach dem Liegen): die Zeile, während er zusammensackt (Rumpf erreicht den
				# Boden bei gut 0,8 der Bewegung „Tod“, wolf_mess_438), nicht erst, wenn die Bewegung zu Ende ist
				fall_ms = maxi(fall_ms, lands + int(figures[id].sterbe_ms() * TODESZEILE_ANTEIL))
		await get_tree().create_timer(fall_ms / 1000.0).timeout
		_todesmeldung_vorweg(e)
		await get_tree().create_timer(maxi(0, tot_ms - fall_ms) / 1000.0).timeout
		warte_ms = 0
	for f in mars.fighters():
		# 573 (Chef 04.11., 20:33: „wenn jemand tot ist, bitte nicht mehr die Position verändern“; der letzte Jungwolf wurde nach dem
		# Haken „ich gewinne“ tot in die Mitte gezogen, tote_573): wer keine Trefferpunkte mehr hat, bleibt liegen, wo er fiel
		if figures.has(f.id) and e.places.has(f.id) and not f.fled and f.hp > 0:     # 399.2a: wer flieht, kommt nicht an seinen Platz zurück
			var ziel := _spot_pos(f, e.places[f.id])
			if warte_ms > 0 and f.id != actor and not figures[f.id].home.is_equal_approx(ziel):
				get_tree().create_timer(warte_ms / 1000.0).timeout.connect(figures[f.id].glide_to.bind(ziel, by != null and by.side == "FOES"))
			else:
				figures[f.id].glide_to(ziel, by != null and by.side == "FOES")
	# 717 C: beim Platztausch kommt der neue Platz des einen vor dem des anderen; erst wenn alle Plätze dieser Meldung stehen, rücken
	# die Vorgemerkten (im Zug der Gegner)
	if by != null and by.side == "FOES":
		for fid in figures:
			figures[fid].zurueck_in_reihe()
	if tot_ms > 0:
		await get_tree().create_timer(maxi(SAY_MS, maxi(lunge_ms, busy_ms) - tot_ms) / 1000.0).timeout
		return
	# 751 (Chef 09.11., 14:00: „manchmal verschwindet das einfach alles“; haenger_751: je Biss 8 s „…“): lunge_ms ist die Zeit bis zum
	# Treffer geteilt durch 0,42 und wuchs mit dem Anlauf weit über die Bewegung hinaus; ein Gegner meldet seine wirkliche Dauer
	# (busy_ms, ohne das Zurechtrücken, das in den Zug des Helden auslaufen darf, F8)
	var dauer := busy_ms if busy_ms > 0 and by != null and by.side == "FOES" else maxi(lunge_ms, busy_ms)
	await get_tree().create_timer(maxi(NACHTRAG_MS if _nur_nachtrag(e) else SAY_MS, dauer) / 1000.0).timeout


## Zeile, Bedienfeld und Würfel einer Meldung (438: beim Aufschlag, sonst sofort); vorweg Gezeigtes nicht noch einmal
func _zeigen(e: Dictionary) -> void:
	if e.text != "" and not e.get("vorweg", false):
		ui.log_line(e.text, e.get("cue") == "EINGEBUNG")     # 840: die Eingebung des Helden in eigener Farbe
	ui.refresh()
	ui.show_roll(e)


## 438: die Meldung „fällt“ zu den Gegnern, die in [e] gefallen sind, wartet schon (die Regeln sagen sie gleich nach dem Schlag);
## jetzt in die Zeile, ihr Schlag zeigt dann nur noch den Rest
func _todesmeldung_vorweg(e: Dictionary) -> void:
	beats_lock.lock()
	for b in beats:
		if b.has("say") and b.say.get("cue") == "FOE_FALLS" and e.hp.get(b.say.get("target"), 1) <= 0 and not b.say.get("vorweg", false):
			b.say["vorweg"] = true
			ui.log_line(b.say.text)
			# 296.3 (Chef 08.11., 21:28, t270.11: Geheul „3 Sekunden zu spät“): Klang der Zeile (Sturz, Todesschrei) mit ihr, nicht
			# erst, wenn die Meldung nach dem Liegen dran ist
			var klang = get_node_or_null("/root/Klang")
			if klang != null:
				b.say["klang_vorweg"] = true
				klang.kampf(b.say, mars)
	beats_lock.unlock()


## 438: die nächste wartende Meldung [cue] an [target] jetzt in die Zeile (die Bewegung dazu ist schon zu sehen)
func _vorweg(cue: String, target: String) -> void:
	beats_lock.lock()
	for b in beats:
		if b.has("say") and b.say.get("cue") == cue and b.say.get("target") == target and not b.say.get("vorweg", false):
			b.say["vorweg"] = true
			ui.log_line(b.say.text)
			break
	beats_lock.unlock()


## 438 (Prüfer Film r2: 18 von 48 s ohne Bewegung): eine Meldung, deren Zeile schon vorweg stand und zu der nichts mehr geschieht,
## hält den Kampf nicht noch einmal SAY_MS auf
func _nur_nachtrag(e: Dictionary) -> bool:
	return e.get("vorweg", false) and e.cue in ["POUNCED", "FOE_FALLS"]


## 348.7: warmes Licht am Ziel eines Feuerzaubers, ab seiner Ankunft, flackernd verlöschend
func fire_light(id: String, after_ms: float, ms: float, big: bool) -> void:
	var fig = figures.get(id)
	if fig == null:
		return
	var l := OmniLight3D.new()
	l.light_color = Color(1.0, 0.62, 0.3)
	l.omni_range = 4.0 if big else 2.5
	l.light_energy = 0.0
	add_child(l)
	l.position = fig.position + Vector3(0, 0.7, 0)
	var tw := create_tween()
	tw.tween_interval(after_ms / 1000.0)
	tw.tween_property(l, "light_energy", 3.0 if big else 2.0, 0.05)
	tw.tween_property(l, "light_energy", 0.0, ms / 1000.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(l.queue_free)


## Daneben: ein Angriff, der nicht trifft, oder ein Rettungswurf, der alles abwehrt (roll[4] heißt beim Angriff „trifft“,
## beim Rettungswurf „gerettet“; bisher galt eine gerettete Heilige Flamme als Treffer ohne Ausweichen)
func _missed(e: Dictionary) -> bool:
	if e.roll == null:
		return false
	if e.roll[0] == "SAVE":
		return e.roll[4] and e.damage == 0
	return not e.roll[4]


## Kritisch nur bei einem Angriff mit der 20 (eine 20 beim Rettungswurf zählte bisher auch)
func _crit(e: Dictionary) -> bool:
	return Mars.ist_krit(e.roll)     # 478: auch nach dem BRS


## Welcher Effekt zu einer Meldung gehört (BattleFx.kt FLYING, Battle.kt weaponFx): der Zauber, der gerade wirkt, auf sein Ziel;
## ein Schuss mit einer Fernwaffe als Pfeil; sonst keiner (Hieb und Biss zeigen Zittern und Blut)
func _fx_of(e: Dictionary, by, tg, across: bool):
	if by == null or tg == null:
		return null
	if e.spell != null and (across or e.spell in ["HEAL", "BLESS"]):
		return e.spell
	if across and e.roll != null and by.monster != null and by.monster.id == Mars.SPIDER:
		var fs = figures.get(String(by.id))     # 494: nur der Netzwurf fliegt (Figur.strike), sonst beißt sie
		return "WEB" if fs != null and fs.netz_los_ms >= 0 else null
	# 601 (Chef 05.11., Build 266: „Bei Fehlschuss mit Bogen ist gar kein Pfeil zu sehen“): duckt sich das Ziel (MSG130_DUCKS, ohne
	# Wurf), schoss der Späher (Figur.strike) ohne Pfeil; jetzt fliegt er daneben wie alt (BattleFx, DUCKED als Fehlschuss)
	if across and (e.roll != null or e.cue == "DUCKED") and by.ranged():
		return "ARROW"
	return null


func _play_ring(target_id: String, intent: Dictionary) -> void:
	ring_for = target_id
	ring_start = Time.get_ticks_msec()
	ring_open = true
	ui.ring_open(target_id, intent)
	var klang = get_node_or_null("/root/Klang")
	if klang != null:
		klang.effekt("swing_heavy", 0.6)     # 939 (alt SkirmishScreen 713): schwerer Schwung, wenn der Ring aufgeht
	while ring_open:
		await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	ui.ring_close()


func _refused() -> void:
	if on_end.is_valid():
		on_end.call("NONE")
	queue_free()


var zuege := 0     # 709: fertige Züge (kampf_ui.panel_passt)
func _done() -> void:
	shown.queue = mars.queue()
	busy = false
	zuege += 1
	if end_asked != null and mars.outcome == "ONGOING":
		test_end(bool(end_asked))
		return
	end_asked = null     # 545: schon vorher entschieden (Held fiel im übersprungenen Rest)
	if mars.outcome == "WON" and reward.is_empty():
		# 399.2: Ausrüstung als Beute (Loot.drops) würfelt die Welt, die Held und Tasche kennt (progress „beute“, aufruf.gd)
		var beute: Callable = progress.get("beute", Callable())
		# 870.5: Heldenstufe nach BRS (progress „stand“, Brs.neuer_stand) und Gebiet für den Erfahrungstopf (progress „gebiet“)
		reward = Lohn.reward(mars, progress.get("stand", {}), mars.dice, String(progress.get("gebiet", "")),
			beute.call(mars) if beute.is_valid() else [], ohne_folgen)     # 644a A, 633: die Welt liest Stufe und Boss der besiegten Gegner
		_sieg_klang()
	if mars.outcome == "ONGOING" and mars.pilot_next():
		go_on()
	ui.refresh()
	ui.panel_passt.call_deferred()     # 709: was während des Zugs an der Höhe des Kastens geschah


## 939 (alt BattleScreen 523, 587): zum Lohn epische Beute (ab EPIC), sonst Beute, sonst Münzen; ein Stufenaufstieg danach wie
## alt beim Weiterblättern zum Feld mit der Stufe (hier alles in einem Fenster, darum kurz nach dem Lohn)
const STUFE_KLANG_MS := 1400
func _sieg_klang() -> void:
	var klang = get_node_or_null("/root/Klang")
	if klang == null or reward.is_empty():
		return
	var episch: bool = (reward.get("gear", []) as Array).any(func(g): return Beute.SELTENHEIT.find(String(g.get("rarity", "COMMON"))) >= Beute.SELTENHEIT.find("EPIC"))
	var beute: bool = not (reward.get("items", []) as Array).is_empty() or not (reward.get("gear", []) as Array).is_empty()
	klang.effekt("loot_epic" if episch else ("loot" if beute else "coins"))
	if int(reward.get("levels", 0)) > 0:
		get_tree().create_timer(STUFE_KLANG_MS / 1000.0, true, false, true).timeout.connect(func(): if is_instance_valid(klang): klang.effekt("level_up"))


## 939 (alt SkirmishScreen 548, „256: wolves now and then howl as they appear“): Wölfe heulen beim Erscheinen, halb so oft
func _geheul_beim_erscheinen() -> void:
	var klang = get_node_or_null("/root/Klang")
	if klang == null or not mars.all.any(func(f): return f.side == "FOES" and f.monster != null and String(f.monster.get("id", "")) in [Mars.WOLF, Mars.DIRE_WOLF]):
		return
	if randf() < 0.5:
		klang.effekt("howl")


func again() -> void:
	var fn := again_fn
	queue_free()
	if fn.is_valid():
		fn.call()


func finish() -> void:
	if mars == null:
		return
	if on_end.is_valid():
		on_end.call(mars.outcome)
	queue_free()


## 399.2: wie viel Blut (Menü System „Blut“: Aus, Dezent, Deutlich; MarsLayout bloodLevel)
func blood_level() -> int:
	return Bedienung.blut_stufe()
