# 656 (Chef 08.11., 21:50, Archiv „656, gleich Film“: „gib mir einmal das Ganze dann in einer Kampfpose oder in einer 3D-Rotation,
# wo man sieht, wie sich derjenige dreht“; aufgefallen in der Rückenansicht): Film des Kämpfers mit Umhang (neu, Armgewichte am
# Schlüsselbein) im Kampfort, Spiellicht (Toon, Tusche nach Licht, Schatten), Spielkamera herangezogen.
# Teil 1 von hinten: Kampfstehen, die drei Schwerthiebe des Spiels (SS_SwordAttack1–3, wie figur.gd _hieb), Abwehr mit dem Schild.
# Teil 2: der Hieb, der den Schwertarm am höchsten hebt, an seiner höchsten Stelle angehalten, der Held dreht sich einmal ganz.
# Teil 3: die drei Hiebe hintereinander, während der Held sich einmal ganz dreht. Die Regeln laufen nicht. Wie film_sieger_2963.gd.
# Aufruf: PROBE=656 xvfb-run godot --path godot --rendering-driver opengl3 --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_umhang_656.gd   (FILM_TEXT=<Zusatz oben>, z. B. „vorher“ für den eigenen Vergleich)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")

const HIEBE := ["SS_SwordAttack1", "SS_SwordAttack2", "SS_SwordAttack3"]
const ABWEHR := ["SS_BlockMedium1", "SS_BlockHeavy1"]

var fg: Node3D
var anim: AnimationPlayer
var sk: Skeleton3D
var lb: Label
var lz: Label
var hinten := 0.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
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
		print("Film 656: ohne Kaufheld (daten/kampf-bewegungen.bin), nichts zu filmen")
		quit(0)
		return
	var hiebe := HIEBE.filter(func(n): return anim.has_animation(n))
	var abwehr := ABWEHR.filter(func(n): return anim.has_animation(n))
	print("Film 656: Hiebe %s, Abwehr %s" % [", ".join(hiebe), ", ".join(abwehr)])
	if hiebe.is_empty():
		print("FEHLER Film 656: keine Schwerthiebe am Kaufhelden")
		quit(1)
		return
	# höchste Stelle der Schwerthand je Hieb (Höhe der Hand über dem Becken), für Teil 2
	var hoch := _hoechste(hiebe)
	print("Film 656: Schwertarm am höchsten in %s bei %.2f s (Hand %.2f m über dem Becken)" % [hoch[0], hoch[1], hoch[2]])
	var mitte: Vector3 = kf._ground(0, 0)
	var cam: Camera3D = kf.cam
	var vorn: Vector3 = cam.global_position - mitte
	vorn.y = 0.0
	vorn = vorn.normalized()
	fg.position = mitte
	hinten = atan2(vorn.x, vorn.z) + PI     # Rücken zur Kamera, wie der Held im Kampf zu den Gegnern hin steht
	fg.rotation = Vector3(0, hinten, 0)
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
	if not Signatur.wache(kf, self, "Film 656"):     # 457.2: Toon-Licht, Tusche nach Licht, Schatten wie im Spiel
		return
	var cl := CanvasLayer.new()
	root.add_child(cl)
	lb = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.03), int(vs.x / 17.0), Color(0.95, 0.82, 0.45))
	lz = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.085), int(vs.x / 30.0), Color(0.92, 0.88, 0.80))
	var zusatz := OS.get_environment("FILM_TEXT")
	var titel := "Umhang" + ("  ·  " + zusatz if zusatz != "" else "")
	print("Film Start Bild %d" % Engine.get_frames_drawn())
	# Teil 1: von hinten, Hiebe und Abwehr
	lb.text = titel
	lz.text = "1 · von hinten · Schwerthiebe"
	await _stueck("Kampfstehen", 1.0, 0.0)
	for n in hiebe:
		await _stueck(n, anim.get_animation(n).length, 0.0)
		await _stueck("Kampfstehen", 0.5, 0.0)
	if not abwehr.is_empty():
		lz.text = "1 · von hinten · Abwehr mit dem Schild"
		await _stueck(abwehr[0], anim.get_animation(abwehr[0]).length, 0.0)
		await _stueck("Kampfstehen", 0.6, 0.0)
	# Teil 2: Schwertarm oben angehalten, eine ganze Drehung
	lz.text = "2 · Schwertarm oben · Drehung"
	anim.play(hoch[0], 0.2, 1.0, false)
	anim.seek(0.0, true)
	await _warte(float(hoch[1]), 0.0)
	anim.speed_scale = 0.0
	await _warte(0.6, 0.0)
	await _warte(9.0, TAU)
	await _warte(0.6, 0.0)
	anim.speed_scale = 1.0
	await _stueck("Kampfstehen", 0.6, 0.0)
	# Teil 3: die Hiebe hintereinander, eine ganze Drehung darüber
	lz.text = "3 · Schwerthiebe · Drehung"
	var lang := 0.0
	for n in hiebe:
		lang += anim.get_animation(n).length + 0.3
	for n in hiebe:
		var d: float = anim.get_animation(n).length
		await _stueck(n, d, TAU * d / lang)
		await _stueck("Kampfstehen", 0.3, TAU * 0.3 / lang)
	fg.rotation.y = hinten
	await _stueck("Kampfstehen", 0.8, 0.0)
	lb.text = ""
	lz.text = ""
	await _warte(0.3, 0.0)
	print("Film 656: fertig")
	quit(0)


## [Bewegung, Zeit, Höhe]: die Stelle, an der die rechte Hand am höchsten über dem Becken steht
func _hoechste(namen: Array) -> Array:
	var h := sk.find_bone("hand_r")
	var b := sk.find_bone("pelvis")
	var best := [namen[0], anim.get_animation(namen[0]).length * 0.45, -INF]
	if h < 0 or b < 0:
		return best
	var tief := INF
	for n in namen:
		anim.play(n, 0.0, 1.0, false)
		var lang: float = anim.get_animation(n).length
		var t := 0.0
		while t <= lang:
			anim.seek(t, true)
			var y := sk.get_bone_global_pose(h).origin.y - sk.get_bone_global_pose(b).origin.y
			if y > best[2]:
				best = [n, t, y]
			tief = minf(tief, y)
			t += 1.0 / 30.0
	anim.stop()
	if best[2] - tief < 0.05:     # Stellung folgte dem Suchen nicht: Mitte des ersten Hiebs
		print("Film 656: Höhe der Hand nicht messbar (%.2f m Spanne)" % (best[2] - tief))
		return [namen[0], anim.get_animation(namen[0]).length * 0.45, 0.0]
	return best


## [n] für [dauer] Sekunden spielen, dabei um [dreh] weiterdrehen
func _stueck(n: String, dauer: float, dreh: float) -> void:
	if n == "Kampfstehen":
		_spiel(n, 0.25)
	else:
		anim.play(n, 0.15, 1.0, false)
		anim.seek(0.0, true)
		print("Stück %s %.2f s" % [n, dauer])
	await _warte(dauer, dreh)


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
