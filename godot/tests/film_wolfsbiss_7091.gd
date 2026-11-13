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
	# Chef 13.11., 20:12 (t284.7c: zweiter Biss vom Helden verdeckt): genau von der Seite, flach (15°), kein Biss hinter einem Körper
	cam.position = z + quer * d * cos(deg_to_rad(15.0)) + Vector3(0, d * sin(deg_to_rad(15.0)), 0)
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
	# Lauf 451: _bite gibt die Zeit vor Engine.time_scale (/ 0,42); kampfort.gd rechnet lands = ms * 0,42, der Film nahm sie roh, darum
	# zuckte der Held 2,2 s nach dem Biss, als der Wolf schon zurück war
	var ms: int = int(wolf._bite(held, false, 0.0 if treffer else 0.3, treffer) * 0.42)
	var art := "biss" if held.blockt() else "nah"
	if treffer:
		held.hurt(ms, false, true, art)
	elif held.blockt():
		held.abwehr(ms, art, kf.to_global(wolf.angriff_von) if wolf.angriff_von != Vector3.INF else wolf.global_position, true, wolf.niedrig())
	else:
		held.dodge(ms)
	var n := 0
	var nah := INF     # Lauf 451: nächste Annäherung der Schnauze an den Helden, sie muss mit dem Biss zusammenfallen
	var nah_ms := 0
	# Chef 13.11., 20:13 (t284.7p „sieht man ja nicht im Film“): um den Biss (±0,5 s) läuft der Film auf ZEITLUPE (0,35) verlangsamt;
	# die Uhr des Skripts zählt Spielzeit (t), nicht Bilder, damit Biss, Messung und Abschnitte gleich bleiben
	var t := 0.0
	var lupe := float(OS.get_environment("ZEITLUPE")) if OS.get_environment("ZEITLUPE") != "" else (1.0 if mess else 0.35)
	while t < ms + 2600:
		Engine.time_scale = lupe if absf(t - ms) < 500.0 else 1.0
		await process_frame
		t += 1000.0 / 30.0 * Engine.time_scale
		n = int(t * 30.0 / 1000.0)
		var sv: float = wolf._schnauze_vorn()     # die Schnauze (Kapseln der Bissteile) reicht im Biss vor den Rumpf
		var dn := Vector2(wolf.position.x - held.position.x, wolf.position.z - held.position.z).length() - (sv if is_finite(sv) else 0.0)
		if dn < nah:
			nah = dn
			nah_ms = int(t)
		if mess and OS.get_environment("KURVE") != "" and n % 3 == 0 and t <= ms + 900:     # 709.1 Messlauf: Verlauf je 0,1 s
			print("KURVE 7091 %s %s %s: %4d ms Rumpf %.2f m, Schnauze vor dem Rumpf %s, Bewegung %s %.2f s, Tempo %.2f" % [g, klasse,
					"T" if treffer else "A", int(t), dn + (sv if is_finite(sv) else 0.0), "%.2f" % sv if is_finite(sv) else "keine Kapsel",
					wolf.anim.current_animation if wolf.anim else "-", wolf.anim.current_animation_position if wolf.anim else 0.0,
					wolf.anim.get_playing_speed() if wolf.anim else 0.0])
		if mess and absf(t - ms) <= 17.0:
			print("MESS 7091 %s %s %s: Schnauze %s, Biss bei %d ms" % [g, klasse, "Treffer" if treffer else "Abwehr", wolf.position, ms])
	if mess:
		print("MESS 7091 %s %s %s: am nächsten %.2f m bei %d ms, Biss bei %d ms, Versatz %d ms%s" % [g, klasse, "Treffer" if treffer else "Abwehr",
				nah, nah_ms, ms, nah_ms - ms, "" if absi(nah_ms - ms) <= 250 else " FALSCH"])
		if absi(nah_ms - ms) > 250:
			fehler += 1
	Engine.time_scale = 1.0
	await _blende(1.0)
	kf.queue_free()
	p.queue_free()
	await process_frame
	await process_frame
