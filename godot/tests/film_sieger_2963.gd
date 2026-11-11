# 296.3 (Siegerpose, Chef 23.10., 18:25; Bestand zuerst 377; 408: „wenn es sich dreht, wie es aus allen Perspektiven ausschaut“):
# Sichtungsfilm der Siegerposen aus dem Bestand am Kaufhelden (Kämpfer mit Schwert und Schild) im Kampfort, im Spiellicht (Toon,
# Tusche nach Licht, Schatten), Spielkamera herangezogen. Je Kandidat: Kampfstehen, die Bewegung ganz, kurz halten, Kampfstehen;
# erst von vorn, dann dieselbe Bewegung, während der Held sich einmal ganz herumdreht. Nummer, Paket und Name oben. Die Regeln laufen nicht. Wie film_438a.gd.
# Quellen: die Protofactor-Sätze (sieger2963.py: Spott, Sieg, Jubel; je Bewegung eine .glb auf dem Gerüst der UAL) und
# Celebration aus der UAL Pro.
# Aufruf: B2963=<ordner mit den .glb> UAL_PRO=<UAL1.glb> PROBE=296.3 xvfb-run godot --path godot --rendering-driver opengl3
#   --resolution 540x1170 --write-movie <datei>.avi --fixed-fps 30 -s res://tests/film_sieger_2963.gd
# Probebild (511): BILD_S=a,b,… (Sekunden ab dem ersten Kandidaten) je ein Bild nach BILD (mehrere: -1, -2 … vor .png), dann Ende;
# BILD_S=vorn: je Kandidat ein Bild mitten in der Bewegung von vorn (BILDER=<n>: nur die ersten n)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const HeldFigur = preload("res://skripte/heldfigur.gd")
const Gebiet = preload("res://skripte/gebiet.gd")
const Signatur = preload("res://kampf/signatur.gd")

const UAL := ["Celebration"]

var fg: Node3D
var anim: AnimationPlayer
var sk: Skeleton3D
var lb: Label
var lz: Label
var grund_y := 0.0
var zeit := 0.0           # Sekunden ab dem ersten Kandidaten
var bilder: Array = []
var gezeigt: Array = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# 656 (Lauf 310): „vorn“ wurde als Zahl 0 gelesen, das Bild entstand nach 0,03 s im Kampfstehen statt mitten in jeder Pose
	if OS.get_environment("BILD_S") != "vorn":
		for x in OS.get_environment("BILD_S").split(",", false):
			bilder.append(float(x))
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	if kf.ui != null:
		kf.ui.visible = false
	var bis := Time.get_ticks_msec() + 15000
	while kf.playing and Time.get_ticks_msec() < bis:
		await process_frame
	kf.playing = true     # keine Meldungen der Regeln mehr; _process des Kampforts läuft weiter (Tusche nach Licht)
	for id in kf.figures:
		var f = kf.figures[id]
		f.set_process(false)
		if f.fighter.monster == null and fg == null and f.fighter.id != "merc":
			fg = f
		else:
			f.visible = false
	anim = fg.anim
	sk = _find(fg, "Skeleton3D") as Skeleton3D
	if not fg.kauf:
		print("Film 296.3: ohne Kaufheld (daten/kampf-bewegungen.bin), nichts zu filmen")
		quit(0)
		return
	var namen := []
	var ordner := OS.get_environment("B2963")
	if ordner != "" and DirAccess.dir_exists_absolute(ordner):
		var dateien := Array(DirAccess.get_files_at(ordner)).filter(func(d): return String(d).ends_with(".glb"))
		dateien.sort()
		for d in dateien:
			var n := String(d).get_basename()
			if _dazu(ordner.path_join(d), [n]):
				namen.append(n)
	if OS.get_environment("UAL_PRO") != "":
		for n in UAL:
			if _dazu(OS.get_environment("UAL_PRO"), [n]):
				namen.append(n)
	print("Film 296.3: %d Kandidaten: %s" % [namen.size(), ", ".join(namen)])
	if namen.is_empty():
		print("FEHLER Film 296.3: keine Kandidaten (B2963, UAL_PRO)")
		quit(1)
		return
	var mitte: Vector3 = kf._ground(0, 0)
	var cam: Camera3D = kf.cam
	var vorn: Vector3 = cam.global_position - mitte
	vorn.y = 0.0
	vorn = vorn.normalized()
	fg.position = mitte
	# 656 (Vergleich Umhang vorher/nachher): BILD_DREH=<Grad> dreht den Helden fürs Probebild weiter (150: schräg von hinten)
	grund_y = atan2(vorn.x, vorn.z) + deg_to_rad(30.0 + OS.get_environment("BILD_DREH").to_float())
	fg.rotation = Vector3(0, grund_y, 0)
	# Spielkamera (waagerecht, Linse verschoben) herangezogen: Held mittig, stehend etwa 40 % der Bildhöhe (Platz für erhobene Arme)
	var vs: Vector2 = root.get_visible_rect().size
	_spiel("Kampfstehen", 0.0)
	await process_frame
	var fuss := cam.unproject_position(mitte)
	var kopf := cam.unproject_position(mitte + Vector3(0, 1.85 * fg.scale.y, 0))
	var z := clampf(vs.y * 0.40 / maxf(fuss.y - kopf.y, 1.0), 1.0, 6.0)
	var c := Vector2(fuss.x, (fuss.y + kopf.y) * 0.5 + (fuss.y - kopf.y) * 0.05)
	var per: float = kf.base_size / vs.y
	cam.size = kf.base_size / z
	cam.frustum_offset = Vector2(kf.base_off.x + (c.x - vs.x / 2.0) * per, kf.base_off.y - (c.y - vs.y / 2.0) * per)
	kf.base_size = cam.size
	kf.base_off = cam.frustum_offset
	if not Signatur.wache(kf, self, "Film 296.3"):     # 457.2: Toon-Licht, Tusche nach Licht, Schatten wie im Spiel
		return
	var cl := CanvasLayer.new()
	root.add_child(cl)
	lb = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.03), int(vs.x / 17.0), Color(0.95, 0.82, 0.45))
	lz = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.085), int(vs.x / 30.0), Color(0.92, 0.88, 0.80))
	lz.size = Vector2(vs.x * 0.92, vs.y * 0.1)
	lz.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	print("Film Start Bild %d" % Engine.get_frames_drawn())
	var i := 0
	for n in namen:
		i += 1
		lb.text = "%d · %s" % [i, _paket(n)]
		lz.text = n + ("  ·  " + OS.get_environment("BILD_TEXT") if OS.get_environment("BILD_TEXT") != "" else "")   # 656: „vorher“/„nachher“ im Bild
		var lang := anim.get_animation(n).length
		# 296.3 (Chef 08.11., 16:44: „dreimal den Helden von hinten … was soll ich jetzt da für Siegerposen beurteilen?“; die ganze
		# Drehung stand im Probebild mitten in der Bewegung bei 180°): erst von vorn ohne Drehung, dann dieselbe Bewegung einmal drehend
		var ganz := maxf(lang, 3.0) + 1.0     # eine ganze Drehung über Bewegung, Halten und das Kampfstehen danach
		await _stueck("Kampfstehen", 0.6, 0.0)
		if OS.get_environment("BILD_S") == "vorn":     # Probebild: je Kandidat ein Bild mitten in der Bewegung von vorn, dann Ende
			_spiel_ab(n)
			await _warte(lang * 0.5, 0.0)
			await RenderingServer.frame_post_draw
			var pfad := OS.get_environment("BILD").get_basename() + "-%d.png" % i
			root.get_texture().get_image().save_png(pfad)
			print("Probebild 296.3: %s von vorn → %s" % [n, pfad.get_file()])
			if i >= int(OS.get_environment("BILDER")) if OS.get_environment("BILDER") != "" else i >= namen.size():
				quit(0)
				return
			continue
		await _stueck(n, lang, 0.0)
		await _stueck("halt", 0.4, 0.0)
		lz.text = n + (" · gedreht" if Sprache.aktiv() == "de" else " · turning")
		await _stueck("Kampfstehen", 0.4, 0.0)
		await _stueck(n, lang, TAU * lang / ganz)
		await _stueck("halt", 0.4, TAU * 0.4 / ganz)
		await _stueck("Kampfstehen", ganz - lang - 0.4, TAU * (ganz - lang - 0.4) / ganz)
		fg.rotation.y = grund_y
		gezeigt.append(n)
	lb.text = ""
	lz.text = ""
	await _warte(0.3, 0.0)
	print("Film 296.3: fertig, gezeigt %d: %s" % [gezeigt.size(), ", ".join(gezeigt)])
	quit(0)


## Paket aus dem Namen (Protofactor hängt das Paket an: S&S, 1hMelee, 2HandMelee, Bow, Wizard)
static func _paket(n: String) -> String:
	if n in UAL:
		return "UAL Pro"
	for k in [["S_S", "Schwert & Schild"], ["1hMelee", "Einhandwaffe"], ["2HandMelee", "Zweihandwaffe"], ["Wizard", "Zauberer"], ["Bow", "Bogen"]]:
		if n.contains(k[0]):
			return k[1]
	return "Protofactor"


## [n] für [dauer] Sekunden spielen (halt: anhalten), dabei um [dreh] weiterdrehen
func _stueck(n: String, dauer: float, dreh: float) -> void:
	if n == "halt":
		anim.speed_scale = 0.0
		await _warte(dauer, dreh)
		anim.speed_scale = 1.0
		return
	if n == "Kampfstehen":
		_spiel(n, 0.25)
	else:
		anim.play(n, 0.2, 1.0, false)
		anim.seek(0.0, true)
	await _warte(dauer, dreh)
	if n != "Kampfstehen":
		print("Stück %s %.2f s" % [n, dauer])


func _spiel_ab(n: String) -> void:
	anim.play(n, 0.2, 1.0, false)
	anim.seek(0.0, true)


func _spiel(n: String, blend: float) -> void:
	if anim.has_animation(n):
		anim.play(n, blend)


func _warte(s: float, dreh: float) -> void:
	var t := 0.0
	var schritt := dreh / maxf(s * 30.0, 1.0)
	while t < s:
		await process_frame
		fg.rotation.y += schritt
		_schatten()
		t += 1.0 / 30.0     # Bilder bei --fixed-fps 30
		zeit += 1.0 / 30.0
		if not bilder.is_empty() and zeit >= float(bilder[0]):
			bilder.pop_front()
			await RenderingServer.frame_post_draw
			var pfad := OS.get_environment("BILD")
			if OS.get_environment("BILD_S").contains(","):
				pfad = pfad.get_basename() + "-%d.png" % (OS.get_environment("BILD_S").split(",", false).size() - bilder.size())
			root.get_texture().get_image().save_png(pfad)
			print("Probebild 296.3: %.2f s, %s → %s" % [zeit, lz.text if lz != null else "", pfad.get_file()])
			if bilder.is_empty():
				quit(0)
				return


## der weiche Bodenschatten folgt dem Becken am Boden
var _sh0 = null

func _schatten() -> void:
	var sh := fg.get_node_or_null("Bodenschatten") as Node3D
	if sh == null:
		return
	if _sh0 == null:
		_sh0 = sh.position
	var b := sk.find_bone("pelvis")
	var p: Vector3 = fg.global_transform.affine_inverse() * (sk.global_transform * sk.get_bone_global_pose(b).origin)
	sh.position = Vector3(_sh0.x + p.x / fg.scale.x, _sh0.y, _sh0.z + p.z / fg.scale.z)


## Bewegungen einer .glb (Gerüst der UAL) dem Kaufhelden geben, wie film_438a.gd (figur.gd _kaufheld)
func _dazu(pfad: String, namen: Array) -> bool:
	if not FileAccess.file_exists(pfad):
		print("fehlt Datei %s" % pfad)
		return false
	var sc := Gebiet.lade_glb(pfad)
	var ap := _find(sc, "AnimationPlayer") as AnimationPlayer
	var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / HeldFigur.bew_becken
	var weg := str(HeldFigur._pfad(fg.model, sk))
	var lib := anim.get_animation_library("")
	var ok := false
	for n in namen:
		if ap == null or not ap.has_animation(n):
			print("fehlt Bewegung %s in %s" % [n, pfad.get_file()])
			continue
		var an := ap.get_animation(n).duplicate(true) as Animation
		for t in range(an.get_track_count() - 1, -1, -1):
			var bn := String(an.track_get_path(t)).get_slice(":", 1)
			an.track_set_path(t, NodePath("%s:%s" % [weg, bn]))
			var ty := an.track_get_type(t)
			if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]) or sk.find_bone(bn) < 0:
				an.remove_track(t)
			elif ty == Animation.TYPE_POSITION_3D:
				for i in an.track_get_key_count(t): an.track_set_key_value(t, i, an.track_get_key_value(t, i) * f)
		an.loop_mode = Animation.LOOP_NONE
		if lib.has_animation(n):
			lib.remove_animation(n)
		lib.add_animation(n, an)
		ok = true
	sc.free()
	return ok


func _label(cl: CanvasLayer, pos: Vector2, fs: int, farbe: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", maxi(4, fs / 6))
	l.add_theme_font_size_override("font_size", fs)
	cl.add_child(l)
	return l


func _find(n: Node, cls: String) -> Node:
	if n.is_class(cls):
		return n
	for c in n.get_children():
		var r := _find(c, cls)
		if r:
			return r
	return null
