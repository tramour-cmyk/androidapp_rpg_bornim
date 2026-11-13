# 1141 (Chef 13.11., 14:36: Goblins, Schamane fallen „wie Playmobil-Figuren … alle auf die gleiche Seite“): Film je Körper ohne
# Sterbebewegung bis 1141 (GEGNER=GOBLINS, SCOUTS, SHAMANS, KOBOLDS wie probe.gd FOES): ein Gegner nach dem anderen stirbt im Kampfort
# durch die echte Figur.die() (wie im Spiel: fällt, liegt, vergeht), dreimal je Körper mit den drei Sterbebewegungen, mal gespiegelt,
# mal nicht (596); Kamera von vorn halb seitlich und von oben auf den Toten (G4), Spiellicht (Signatur), Kampfschirm aus, Helden aus.
# Aufruf (Film, Probelauf): PROBE=1141 GEGNER=GOBLINS xvfb-run godot --path godot --rendering-driver opengl3 --resolution 540x1170
#   --write-movie <datei>.avi --fixed-fps 30 -s res://tests/film_tod_1141.gd
# Probebild: PROBEBILD=1141 BILDER=<ordner> GEGNER=… derselbe Aufruf ohne --write-movie
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const FORMAT := Vector2(1080, 2340)
const BLENDE_BILDER := 6
## je Tod: welche Sterbebewegung (Tod, Tod2, Tod3) und ob gespiegelt
const FOLGE := [[0, false], [1, true], [2, false]]

var schwarz: ColorRect
var lb: Label
var lz: Label
var fehler := 0
## Probebild (ohne --write-movie): BILDER=<ordner> legt je Tod ein Bild mitten im Fall und eines liegend ab, aus derselben Szene
var bilder := OS.get_environment("BILDER")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
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
	var liste := OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "GOBLINS"
	for g in liste.split(","):
		await _gegner(g.strip_edges())
	print("Film 1141 %s" % ("fertig" if fehler == 0 else "%d Fehler" % fehler))
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
	var von := schwarz.color.a
	for i in BLENDE_BILDER:
		await process_frame
		schwarz.color.a = lerpf(von, ziel, float(i + 1) / BLENDE_BILDER)


## Startwert, mit dem die() die Sterbebewegung [i] von [n] wählt und [spiegeln] würfelt (die() zieht randi() % n, dann randf())
func _seed_fuer(i: int, n: int, spiegeln: bool) -> int:
	for s in 10000:
		seed(s)
		if randi() % n == i and (randf() < 0.5) == spiegeln:
			return s
	return 0


func _gegner(g: String) -> void:
	if not Probe.FOES.has(g):
		print("FEHLER 1141: Gegner %s fehlt in probe.gd FOES" % g)
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
		print("FEHLER 1141: kein Kampfort für %s" % g)
		fehler += 1
		return
	if kf.ui != null:
		kf.ui.visible = false
	var feinde := []
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster != null:
			feinde.append(f)
		f.visible = false
	if feinde.is_empty():
		print("FEHLER 1141: keine Gegner in %s" % g)
		fehler += 1
		return
	var helden: Array = kf.figures.values().filter(func(f): return f.fighter.monster == null)
	var cam := Camera3D.new()
	kf.add_child(cam)
	cam.fov = 40.0
	cam.make_current()
	for k in FOLGE.size():
		var fig = feinde[k % feinde.size()]
		fig.visible = true
		var alle: int = 1
		for j in range(2, 5):
			if fig.anim and fig.anim.has_animation("Tod%d" % j): alle += 1
		if alle < 3:
			print("FEHLER 1141: %s hat %d Sterbebewegungen (%s)" % [fig.fighter.id, alle, fig._model_path()])
			fehler += 1
		# von vorn halb seitlich (aus Richtung der Helden, 30° gedreht) und von oben (35°): vornüber fällt er auf die Kamera zu,
		# rücklings von ihr weg, seitlich quer; so weit, dass der Liegende ganz im Bild ist (G1: 2,6 m quer)
		var mitte: Vector3 = fig.position
		var zu: Vector3 = (helden[0].position - mitte) if not helden.is_empty() else Vector3(0, 0, 1)
		zu.y = 0.0
		zu = zu.normalized().rotated(Vector3.UP, deg_to_rad(30.0))
		var hfov := 2.0 * atan(tan(deg_to_rad(cam.fov) / 2.0) * FORMAT.x / FORMAT.y)
		var d: float = 1.3 * fig._scale() / tan(hfov / 2.0)     # r2: die Füße bleiben stehen, der Tote liegt bis 1,1 m daneben
		var z := mitte + Vector3(0, 0.25, 0)
		cam.position = z + zu * d * cos(deg_to_rad(35.0)) + Vector3(0, d * sin(deg_to_rad(35.0)), 0)
		cam.look_at(z)
		kf.ink_ziel = z
		await process_frame
		if k == 0 and not Signatur.wache(kf, self, "Film 1141 " + g):
			return
		if k == 0:     # zum Schneiden: je Körper ein Film (meldung.sh, bis 15 s)
			print("Film 1141 %s: ab Bild %d" % [g, Engine.get_process_frames()])
		var welche: int = FOLGE[k][0] % alle
		lb.text = "1141 · " + String(Probe.FOES[g])
		lz.text = "%s, Sterbebewegung %d von %d%s" % [fig.fighter.monster.de, welche + 1, alle, ", gespiegelt" if FOLGE[k][1] else ""]
		await _blende(0.0)
		await create_timer(0.6).timeout
		seed(_seed_fuer(welche, alle, FOLGE[k][1]))
		fig.die()
		print("Film 1141 %s: %s %s%s, Bild %d" % [g, fig.fighter.id, fig.tod_name, " gespiegelt" if fig.gespiegelt else "", Engine.get_process_frames()])
		# wie im Spiel: fällt (Länge der Bewegung), liegt LIEGT_MS, vergeht FADE_MS
		if bilder != "":     # Probebild: mitten im Fall und liegend
			await create_timer(fig.sterbe_ms() * 0.45 / 1000.0).timeout
			await _knips(bilder + "/1141-%s-%d-fall.png" % [g, k + 1])
			await create_timer(fig.sterbe_ms() * 0.6 / 1000.0).timeout
			await _knips(bilder + "/1141-%s-%d-liegt.png" % [g, k + 1])
		while fig.visible:
			await process_frame
		await create_timer(0.3).timeout
		await _blende(1.0)
	print("Film 1141 %s: bis Bild %d" % [g, Engine.get_process_frames()])
	kf.queue_free()
	p.queue_free()
	await process_frame
	await process_frame


func _knips(datei: String) -> void:
	await process_frame
	var e := root.get_texture().get_image().save_png(datei)
	print("BILD 1141 %s %s" % [datei.get_file(), "ok" if e == OK else "FEHLER %d" % e])
	if e != OK:
		fehler += 1
