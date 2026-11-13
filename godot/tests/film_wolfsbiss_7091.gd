# 709.1 (709c A, Chef 11.11., 07:56: Wolf greift gerade von vorn an, Biss in die Schildunterkante; Treffer: zerrt, Held taumelt;
# Abwehr: Schildstoß, der Wolf prallt zurück; ohne Schild Unterarm oder Oberschenkel): Film je Gegner (GEGNER=WOLVES, GRIMM) gegen
# den Helden mit Schild (Kämpfer), den Kleriker und einen Helden ohne Schild (Zauberlehrling), je einmal Treffer und einmal Abwehr.
# Die Figuren spielen ihre echten Bewegungen (Figur._bite, hurt, abwehr) so, wie kampfort.gd sie bei einem Biss aufruft; die Regeln
# laufen nicht, der Ausgang ist vorgegeben (oben links). Kamera halb von der Seite, so dass Wolf und Held ganz im Bild sind (G1, G4).
# Aufruf (Film, Probelauf): PROBE=709.1 GEGNER=WOLVES xvfb-run godot --path godot --rendering-driver opengl3 --resolution 540x1170
#   --write-movie <datei>.avi --fixed-fps 30 -s res://tests/film_wolfsbiss_7091.gd
# MESS=1 ohne Bild: druckt je Biss Abstand der Schnauze zu Schild und Körper beim Aufschlag (Prüfung vor dem Film)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const FORMAT := Vector2(1080, 2340)
const BLENDE_BILDER := 6
## [Klasse des Helden, Treffer?]
const FOLGE := [["FIGHTER", true], ["FIGHTER", false], ["CLERIC", true], ["CLERIC", false], ["WIZARD", true]]

var mess := OS.get_environment("MESS") != ""
var schwarz: ColorRect
var lb: Label
var lz: Label
var fehler := 0


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
	var liste := OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES"
	for g in liste.split(","):
		print("Film 7091 %s: ab Bild %d" % [g, Engine.get_process_frames()])
		for f in FOLGE:
			await _biss(g.strip_edges(), f[0], f[1])
		print("Film 7091 %s: bis Bild %d" % [g, Engine.get_process_frames()])
	print("Film 7091 %s" % ("fertig" if fehler == 0 else "%d Fehler" % fehler))
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


const NAMEN := {"FIGHTER": "Kämpfer mit Schild", "CLERIC": "Kleriker mit Schild", "WIZARD": "Zauberlehrling ohne Schild"}


func _biss(g: String, klasse: String, treffer: bool) -> void:
	var p = Probe.new()
	p.hero_cls = klasse
	p.merc_cls = "ROGUE" if klasse != "ROGUE" else "FIGHTER"
	p.foe = g
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 12:
		await process_frame
	var kf = p.fight
	if kf == null:
		print("FEHLER 7091: kein Kampfort für %s" % g)
		fehler += 1
		return
	if kf.ui != null:
		kf.ui.visible = false
	var held = kf.figures.get("hero")
	var wolf = null
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster != null and wolf == null:
			wolf = f
	for id in kf.figures:
		var f = kf.figures[id]
		if f != held and f != wolf:
			f.visible = false     # nur Wolf und Held (Prüfgegenstand, G4)
	if held == null or wolf == null:
		print("FEHLER 7091: Held oder Wolf fehlt (%s, %s)" % [g, klasse])
		fehler += 1
		return
	var cam := Camera3D.new()
	kf.add_child(cam)
	cam.fov = 40.0
	var mitte: Vector3 = (held.position + wolf.position) * 0.5
	var zu: Vector3 = wolf.position - held.position
	zu.y = 0.0
	var quer := zu.normalized().cross(Vector3.UP)
	var hfov := 2.0 * atan(tan(deg_to_rad(cam.fov) / 2.0) * FORMAT.x / FORMAT.y)
	var d: float = (zu.length() * 0.5 + 1.2) / tan(hfov / 2.0)
	var z := mitte + Vector3(0, 0.6, 0)
	cam.position = z + (quer * 0.85 - zu.normalized() * 0.5).normalized() * d * cos(deg_to_rad(28.0)) + Vector3(0, d * sin(deg_to_rad(28.0)), 0)
	cam.look_at(z)
	cam.make_current()
	kf.ink_ziel = z
	await process_frame
	if not mess and not Signatur.wache(kf, self, "Film 7091 " + g):
		return
	lb.text = "709.1 · %s gegen %s" % [String(Probe.FOES[g]), NAMEN.get(klasse, klasse)]
	lz.text = "Treffer" if treffer else "abgewehrt"
	print("Film 7091 %s %s %s: ab Bild %d" % [g, klasse, "Treffer" if treffer else "Abwehr", Engine.get_process_frames()])
	await _blende(0.0)
	await create_timer(0.5).timeout
	# wie kampfort.gd beim Biss: Angreifer beißt, beim Aufschlag Treffer oder Abwehr des Ziels
	var ms: int = wolf._bite(held, false, 0.0 if treffer else 0.3, treffer)
	var art := "biss" if held.blockt() else "nah"
	if treffer:
		held.hurt(ms, false, true, art)
	elif held.blockt():
		held.abwehr(ms, art, kf.to_global(wolf.angriff_von) if wolf.angriff_von != Vector3.INF else wolf.global_position, true, wolf.niedrig())
	else:
		held.dodge(ms)
	var n := 0
	while n * 1000 / 30 < ms + 2600:
		await process_frame
		n += 1
		if mess and abs(n * 1000 / 30 - ms) <= 17:
			print("MESS 7091 %s %s %s: Schnauze %s, Biss bei %d ms" % [g, klasse, "Treffer" if treffer else "Abwehr", wolf.position, ms])
	await _blende(1.0)
	kf.queue_free()
	p.queue_free()
	await process_frame
	await process_frame
