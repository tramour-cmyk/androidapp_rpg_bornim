# 494 (Wochenziel 03.11. Reihe 3: „jeder Gegner aus dem alten Spiel kämpft an seinem Ort … je Gegner höchstens ein Lauf“): kurzer
# Film je Gegner der Probe (GEGNER=BOARS,… wie probe.gd FOES): erst der Gegner allein von nah (Ruhe, 4 s), dann der Kampf gegen Kämpfer
# und Kleriker auf Autopilot in Echtzeit, die Kamera aus Richtung der Spielkamera (dort ist die Lichtung frei, film_406), so weit,
# dass alle Stehenden ganz im Bild sind (G1), Spiellicht (Signatur 457).
# Aufruf (Bild, Probelauf nach 389): PROBE=494 GEGNER=BOARS xvfb-run godot --path godot --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_gegner_494.gd       DAUER_MS Kampf je Gegner (18000), MESS=1 ohne Bild: wer im Bild steht
# Probebild (511, Bauserver mit film=nein): BILDER=<ordner> ohne --write-movie legt je Gegner zwei Bilder ab, aus demselben Skript
#   und derselben Szene wie der Film: <ordner>/494-<GEGNER>-nah.png (Teil 1) und -spiel.png (Spielkamera mit Kampfschirm, 2 s im Kampf)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const FORMAT := Vector2(1080, 2340)
const BLENDE_BILDER := 8
const DAUER_MS := 18000

var mess := OS.get_environment("MESS") != ""
var bilder := OS.get_environment("BILDER")
## 506 (Tom): derselbe Film für einen anderen Vorgang (NR=506 GEGNER=SKELETONS): Nummer in der Überschrift und im Bildnamen
var nr := OS.get_environment("NR") if OS.get_environment("NR") != "" else "494"
var schwarz: ColorRect
var lb: Label
var lz: Label
var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not mess:
		var deck := CanvasLayer.new()
		deck.layer = 128
		schwarz = ColorRect.new()
		schwarz.color = Color.BLACK
		schwarz.set_anchors_preset(Control.PRESET_FULL_RECT)
		schwarz.mouse_filter = Control.MOUSE_FILTER_IGNORE
		deck.add_child(schwarz)
		root.add_child(deck)
		var cl := CanvasLayer.new()
		cl.layer = 10
		root.add_child(cl)
		var vs: Vector2 = root.get_visible_rect().size
		lb = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.03), int(vs.x / 19.0), Color(0.95, 0.82, 0.45))
		lz = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.075), int(vs.x / 28.0), Color(0.92, 0.88, 0.80))
	var liste := OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "BOARS,CENTIPEDES"
	for g in liste.split(","):
		await _gegner(g.strip_edges())
	print("Film 494 %s" % ("Messung: %d Befunde" % fehler if mess else "fertig"))
	quit(1 if fehler > 0 else 0)


func _label(cl: CanvasLayer, pos: Vector2, fs: int, farbe: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", maxi(fs / 6, 3))
	cl.add_child(l)
	return l


func _blende(ziel: float) -> void:
	if schwarz == null:
		return
	var von := schwarz.color.a
	for i in BLENDE_BILDER:
		await process_frame
		schwarz.color.a = lerpf(von, ziel, float(i + 1) / BLENDE_BILDER)


func _gegner(g: String) -> void:
	if not Probe.FOES.has(g):
		print("FEHLER 494: Gegner %s fehlt in probe.gd FOES" % g)
		fehler += 1
		return
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = g
	root.add_child(p)
	await process_frame
	p._start(5)
	for i in 12:
		await process_frame
	var kf = p.fight
	if kf == null:
		print("FEHLER 494: kein Kampfort für %s" % g)
		fehler += 1
		return
	if kf.ui != null:
		kf.ui.visible = false
	var feinde := []
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster != null:
			feinde.append(f)
	print("Film 494 %s: %s, Modell %s" % [g, ", ".join(feinde.map(func(f): return "%s (%s)" % [f.fighter.monster.de, f.fighter.monster.id])),
		feinde[0]._model_path() if not feinde.is_empty() else "-"])
	var von: Vector3 = kf.cam.global_position - kf._ground(0, 0)
	von.y = 0.0
	von = von.normalized().rotated(Vector3.UP, deg_to_rad(25.0))     # etwas von der Seite: Körper der Vierbeiner lang im Bild
	var cam := Camera3D.new()
	kf.add_child(cam)
	cam.fov = 40.0
	var hfov := 2.0 * atan(tan(deg_to_rad(cam.fov) / 2.0) * FORMAT.x / FORMAT.y)
	# Teil 1: der Gegner von nah, bevor der Kampf weiterläuft (go_on erst in Teil 2)
	var nah = feinde[0] if not feinde.is_empty() else null
	if nah != null:
		# Prüfer Lauf 265 (G1): Grimmzahn (1,75-fach) ohne Kopf, Fühler der Schnecke, Morgenstern Kroggs am Rand; Rand nach Größe
		# und Länge des Tiers statt fest 1,2 m
		var rand: float = 1.2 * maxf(1.0, nah._scale()) + 0.5 * float(nah.mass.get("laenge_m", 0.0)) * nah._scale()
		_auf(cam, kf, [nah], von, hfov, rand)
	# 506 (Helfer 08.11., 12:55, G1: im Nahbild ein zweites Skelett angeschnitten): im Nahbild nur der eine Gegner, die übrigen
	# Figuren erst zum Kampf wieder sichtbar
	var verborgen := []
	for id in kf.figures:
		var f = kf.figures[id]
		if f != nah and f.visible:
			f.visible = false
			verborgen.append(f)
	cam.make_current()
	await process_frame
	if not mess and not Signatur.wache(kf, self, "Film 494 " + g):
		return
	if lb:
		lb.text = nr + " · " + String(Probe.FOES[g])
		lz.text = "Ruhe, von nah" + (" · " + OS.get_environment("ZEILE") if OS.get_environment("ZEILE") != "" else "")     # 744: vorher/nachher
	await _blende(0.0)
	if bilder != "":
		await _knips(bilder + "/%s-%s-nah.png" % [nr, g])
		if lb:
			lb.text = ""
			lz.text = ""
		cam.current = false
		kf.cam.make_current()
		if kf.ui != null:
			kf.ui.visible = true
	# 744: RUHE_S verlängert die Ruhe von nah (Ruhebewegungen kommen alle 3–7 s), DAUER_MS=0 lässt den Kampf aus
	await create_timer((float(OS.get_environment("RUHE_S")) if OS.get_environment("RUHE_S") != "" else 4.0) if bilder == "" else 0.5).timeout
	for f in verborgen:
		f.visible = true
	# Teil 2: Kampf auf Autopilot, Echtzeit
	if lz:     # 506 (Helfer: Zeile verkehrt herum): die Helden kämpfen gegen den Gegner, nicht umgekehrt
		lz.text = "Kämpfer und Kleriker gegen %s · Autopilot, Echtzeit" % String(Probe.FOES[g])
	kf.mars.find("merc").auto = true
	kf.mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var n := 0
	var dauer := int(OS.get_environment("DAUER_MS")) if OS.get_environment("DAUER_MS") != "" else DAUER_MS
	if bilder != "":
		dauer = 2000
	while n < dauer * 30 / 1000 and kf.mars.outcome == "ONGOING":
		await process_frame
		n += 1
		if bilder != "":
			continue     # Probebild: Spielkamera bleibt, wie der Spieler den Kampf sieht
		var stehen: Array = kf.figures.values().filter(func(f): return f.visible and f.dead_at < 0)
		if not stehen.is_empty():
			_auf(cam, kf, stehen, von, hfov, 1.6, 0.05)
	print("Film 494 %s: Kampf %s nach %.1f s" % [g, kf.mars.outcome, n / 30.0])
	if bilder != "":
		await _knips(bilder + "/%s-%s-spiel.png" % [nr, g])
	await create_timer(1.5).timeout
	await _blende(1.0)
	kf.queue_free()
	p.queue_free()
	await process_frame
	await process_frame


func _knips(datei: String) -> void:
	await process_frame
	await process_frame
	var bild := root.get_texture().get_image()
	var e := bild.save_png(datei)
	print("BILD 494 %s %s" % [datei.get_file(), "ok" if e == OK else "FEHLER %d" % e])
	if e != OK:
		fehler += 1


## Kamera aus [von] auf die Mitte der [figuren], so weit, dass sie quer mit [rand] m ganz ins Bild passen; [weich] < 1 folgt sanft
func _auf(cam: Camera3D, kf, figuren: Array, von: Vector3, hfov: float, rand: float, weich := 1.0) -> void:
	var rechts := von.cross(Vector3.UP).normalized()
	var lo := INF
	var hi := -INF
	var mitte := Vector3.ZERO
	for f in figuren:
		var q: float = (f.position as Vector3).dot(rechts)
		lo = minf(lo, q)
		hi = maxf(hi, q)
		mitte += f.position
	mitte /= figuren.size()
	var d := clampf(hi - lo + 2.0 * rand, 2.4, 9.0) / 2.0 / tan(hfov / 2.0)
	var z := mitte + Vector3(0, 0.7, 0)
	var soll := z + von * d + Vector3(0, d * 0.22, 0)
	cam.position = soll if weich >= 1.0 else cam.position.lerp(soll, weich)
	cam.look_at(z)
	kf.ink_ziel = z
