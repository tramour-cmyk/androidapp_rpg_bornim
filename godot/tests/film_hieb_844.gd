# 844 (aus 709, treffen_709: Goblins und Kobolde ohne Angriffsbewegung, glitten im Stehen vor, Treffer ohne Schlag): Film je Art
# (GEGNER=GOBLINS, KOBOLDS, SHAMANS wie probe.gd FOES) gegen den Kämpfer mit Schild: jeder der drei Gegner (drei Kits) geht heran,
# schlägt und geht zurück, der Reihe nach Treffer, abgewehrt, Treffer. Die Figuren spielen ihre echten Bewegungen (Figur.strike,
# hurt, abwehr), so wie kampfort.gd sie bei einem Angriff aufruft; die Regeln laufen nicht, der Ausgang ist vorgegeben (oben links).
# Kamera halb von der Seite, so dass Angreifer und Held auf dem ganzen Weg im Bild sind (G1, G4); die übrigen Figuren sind aus.
# Aufruf (Film, Probelauf): PROBE=844 GEGNER=GOBLINS xvfb-run godot --path godot --rendering-driver opengl3 --resolution 540x1170
#   --write-movie <datei>.avi --fixed-fps 30 -s res://tests/film_hieb_844.gd
# Probebild: PROBEBILD=844 BILDER=<ordner> derselbe Aufruf ohne --write-movie (je Angriff ein Bild beim Ausholen und beim Aufschlag)
# Zum Schneiden druckt er je Angriff „Film 844 … Bild a–b, Aufschlag c“.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const FORMAT := Vector2(1080, 2340)
const BLENDE_BILDER := 6
const FOLGE := [true, false, true]     # Treffer, abgewehrt, Treffer (je ein Gegner, drei Kits)

var schwarz: ColorRect
var lb: Label
var lz: Label
var fehler := 0
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
	print("Film 844 %s" % ("fertig" if fehler == 0 else "%d Fehler" % fehler))
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


func _gegner(g: String) -> void:
	if not Probe.FOES.has(g):
		print("FEHLER 844: Gegner %s fehlt in probe.gd FOES" % g)
		fehler += 1
		return
	print("Film 844 %s: ab Bild %d" % [g, Engine.get_process_frames()])
	for k in FOLGE.size():
		await _angriff(g, k, FOLGE[k])
	print("Film 844 %s: bis Bild %d" % [g, Engine.get_process_frames()])


func _angriff(g: String, k: int, treffer: bool) -> void:
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
		print("FEHLER 844: kein Kampfort für %s" % g)
		fehler += 1
		return
	if kf.ui != null:
		kf.ui.visible = false
	var held = kf.figures.get("hero")
	var feinde := []
	for id in kf.figures:
		if kf.figures[id].fighter.monster != null:
			feinde.append(kf.figures[id])
	if held == null or feinde.is_empty():
		print("FEHLER 844: Held oder Gegner fehlt (%s)" % g)
		fehler += 1
		return
	var gob = feinde[k % feinde.size()]
	for id in kf.figures:
		var f = kf.figures[id]
		if f != held and f != gob:
			f.visible = false     # nur Angreifer und Held (Prüfgegenstand, G4)
	if not gob.anim or not gob.anim.has_animation("Hieb"):
		print("FEHLER 844: %s ohne Hieb (%s)" % [gob.fighter.id, gob._model_path()])
		fehler += 1
	var cam := Camera3D.new()
	kf.add_child(cam)
	cam.fov = 40.0
	cam.make_current()
	# schräg hinter dem Helden, 25° zur Seite und von oben: der Weg des Gegners läuft im Hochformat von oben auf den Helden zu, man
	# sieht ihn von vorn ausholen und schlagen; so nah, wie Held und Gegner daheim mit Kopf und Füßen ganz ins Bild passen (G1, G4)
	var zu: Vector3 = gob.position - held.position
	zu.y = 0.0
	var quer := zu.normalized().cross(Vector3.UP)
	var z: Vector3 = (held.position as Vector3).lerp(gob.position, 0.5) + Vector3(0, 0.5, 0)
	var richt := (quer * 0.42 - zu.normalized() * 0.91).normalized()
	var punkte: Array = [held.position, held.position + Vector3(0, 1.9, 0), gob.position, gob.position + Vector3(0, 1.2, 0)]
	var vs: Vector2 = root.get_visible_rect().size
	for i in 60:
		var d := 2.5 + i * 0.15
		cam.position = z + richt * d * cos(deg_to_rad(34.0)) + Vector3(0, d * sin(deg_to_rad(34.0)), 0)
		cam.look_at(z)
		if punkte.all(func(q): var s2: Vector2 = cam.unproject_position(q); return not cam.is_position_behind(q) and s2.x > vs.x * 0.08 and s2.x < vs.x * 0.92 and s2.y > vs.y * 0.14 and s2.y < vs.y * 0.92):
			break
	kf.ink_ziel = z
	await process_frame
	if not Signatur.wache(kf, self, "Film 844 " + g):
		return
	lb.text = "844 · %s schlägt" % String(Probe.FOES[g])
	lz.text = "%s, %s" % [gob.fighter.monster.de, "Treffer" if treffer else "abgewehrt"]
	await _blende(0.0)
	await create_timer(0.4).timeout
	# wie kampfort.gd: Angriff, beim Aufschlag (0,42 der Rückgabe) Treffer oder Abwehr des Ziels; daneben bleibt er VERFEHLT_M weiter weg
	var e := {"spell": null, "roll": ["BRS", 0, 0, 0, treffer, 0, 0, false]}
	var ab := Engine.get_process_frames()
	var ms: int = gob.strike(held, e)
	var lands := int(ms * 0.42)
	if treffer:
		held.hurt(lands, false, false, "nah")
	elif held.blockt():
		held.abwehr(lands, "nah", kf.to_global(gob.angriff_von) if gob.angriff_von != Vector3.INF else gob.global_position, true, gob.niedrig())
	else:
		held.dodge(lands)
	var auf := ab + int(lands * 30 / 1000.0)
	var ende := ab + int((gob.busy_ms + 400) * 30 / 1000.0)
	if bilder != "":
		var hieb_ab: int = ab + int(gob.anlauf_ms * 30 / 1000.0)
		while Engine.get_process_frames() < hieb_ab + 9:     # Ausholen (Hieb 0,30 s)
			await process_frame
		await _knips(bilder + "/844-%s-%d-aus.png" % [g, k + 1])
		print("BILD 844 aus: %s bei %.2f s" % [gob.anim.current_animation, gob.anim.current_animation_position])
	if bilder != "":
		while Engine.get_process_frames() < auf - 3:
			await process_frame
		await _knips(bilder + "/844-%s-%d-vor.png" % [g, k + 1])
	while Engine.get_process_frames() < auf:
		await process_frame
	if bilder != "":
		await _knips(bilder + "/844-%s-%d-auf.png" % [g, k + 1])
		while Engine.get_process_frames() < auf + 4:
			await process_frame
		await _knips(bilder + "/844-%s-%d-nach.png" % [g, k + 1])
	while Engine.get_process_frames() < ende:
		await process_frame
	print("Film 844 %s %s %s: Bild %d–%d, Aufschlag %d, Anlauf %d ms, Hieb %s" % [g, gob.fighter.id, "Treffer" if treffer else "Abwehr", ab, ende, auf,
		gob.anlauf_ms, gob.hieb])
	await _blende(1.0)
	kf.queue_free()
	p.queue_free()
	await process_frame
	await process_frame


func _knips(datei: String) -> void:
	await process_frame
	var e := root.get_texture().get_image().save_png(datei)
	print("BILD 844 %s %s" % [datei.get_file(), "ok" if e == OK else "FEHLER %d" % e])
	if e != OK:
		fehler += 1
