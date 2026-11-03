# 406.2a (Chef 03.11., 09:03, Archiv 406.2a: „einfach nur versuchen, ob das hinhaut … Auf jeden Fall nicht das Hopsen aus dem Sword
# and Shield Paket“; 09:06: „auch mit Stab oder mit Axt“): kurzer Film, unter einer Minute. Je Held drei Angriffe auf einen Wolf in
# gut 4 m: er rennt wie im Dorf hin (figur.gd _kampfrennen), schlägt und geht rückwärts heim; echter Ablauf _held_schlag, die Regeln
# ruhen. Kämpfer mit Langschwert und Rundschild, Magier mit Kampfstab, Kämpfer mit Kriegsaxt. Kamera seitlich vor dem Helden, folgt
# ihm (Chef 08:57 zum Parade-Film: „die Perspektive ist Murks“), jede Figur ganz im Bild (G1), Spiellicht (Signatur 457).
# Aufruf (Bild, Probelauf nach 389): PROBE=406.2a xvfb-run godot --path godot --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_4062a.gd
# MESS=1 (--headless, ohne Bild): je Anlauf Bewegung, Weg, Zeit; Kampfrennen da, Schild und Waffe in der Hand
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const FORMAT := Vector2(1080, 2340)
const BLENDE_BILDER := 8
const RAND_M := 1.9          # m quer im Bild neben Held und Wolf (Waffe, Schwanz, Rand)
const ABSTAND := 4.4          # m vom Helden zum Wolf, deutlich über RUN_FROM (1,2 m)
const WINKEL := [55.0, 40.0, 70.0]     # drei Anläufe schräg zur Seite: Weg quer im Bild der Spielkamera, Lichtung frei (film_406)
const HELDEN := [
	{"cls": "FIGHTER", "name": "Kämpfer · Langschwert und Rundschild"},
	{"cls": "WIZARD", "name": "Magier · Kampfstab"},
	{"cls": "FIGHTER", "name": "Kämpfer · Kriegsaxt", "main": "greataxe"}]

var mess := OS.get_environment("MESS") != ""
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
	for h in HELDEN:
		await _held(h)
	print("Film 406.2a %s" % ("Messung: %d Befunde" % fehler if mess else "fertig"))
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


func _held(h: Dictionary) -> void:
	var p = Probe.new()
	p.hero_cls = String(h.cls)
	p.merc_cls = "CLERIC" if h.cls != "CLERIC" else "FIGHTER"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	if h.has("main"):     # Kriegsaxt: zweihändig, ohne Schild (tabellen.json kennt sie nicht als Probewaffe)
		var hs: Dictionary = p.tables.probe[h.cls].hero.hero
		hs.main = hs.main.duplicate()
		hs.main.id = h.main
		hs.main.de = "Kriegsaxt"
		hs.main.two = true
		hs["schild"] = ""
	p._start(7)
	for i in 12:     # _arm_kauf wartet auf den Baum und ein Bild
		await process_frame
	var kf = p.fight
	if kf == null:
		print("FEHLER 406.2a: kein Kampfort für %s" % h.name)
		fehler += 1
		return
	if kf.ui != null:
		kf.ui.visible = false
	kf.playing = true     # die Regeln ruhen (wie film_406 Sichtung); _process des Kampforts läuft weiter
	var held = kf.figures["hero"]
	var wolf = null
	for id in kf.figures:
		var f = kf.figures[id]
		if f.tween:
			f.tween.kill()
		if f == held:
			continue
		if wolf == null and f.fighter.monster != null:
			wolf = f
		else:
			f.visible = false
			f.set_process(false)
	if held.anim == null or not held.kauf:
		print("FEHLER 406.2a: %s ohne Kaufhelden (daten/kampf-bewegungen.bin, Kaufkörper)" % h.name)
		fehler += 1
		kf.queue_free()
		p.queue_free()
		await process_frame
		return
	held.position = held.home
	held._idle()
	var zu: Vector3 = wolf.home - held.home
	zu.y = 0.0
	zu = zu.normalized()
	var kampfweg := []
	for w in WINKEL:
		var d := zu.rotated(Vector3.UP, deg_to_rad(w))
		var q: Vector3 = held.home + d * ABSTAND
		q.y = wolf.home.y
		kampfweg.append(q)
	wolf.position = kampfweg[0]
	wolf._face(held.home - wolf.position)
	# Kamera aus Richtung der Spielkamera (dort ist die Lichtung frei, film_406), etwas zur Seite des Wegs gedreht: der Held rennt quer
	# durchs Bild, Brust und Schild zur Kamera
	var von: Vector3 = kf.cam.global_position - held.home
	von.y = 0.0
	von = von.normalized().rotated(Vector3.UP, deg_to_rad(-20.0))
	var cam := Camera3D.new()
	kf.add_child(cam)
	cam.fov = 40.0
	var hfov := 2.0 * atan(tan(deg_to_rad(cam.fov) / 2.0) * FORMAT.x / FORMAT.y)
	# so weit weg, dass Held und Wolf quer mit Rand ganz ins Bild passen (G1); kommt der Held näher, fährt sie mit heran (Helden groß)
	var rechts := von.cross(Vector3.UP).normalized()
	var abstand := func() -> float:
		return clampf(absf((wolf.position - held.position).dot(rechts)) + RAND_M, 2.6, 5.2) / 2.0 / tan(hfov / 2.0)
	var d_cam: float = abstand.call()
	var mitte: Vector3 = held.position.lerp(wolf.position, 0.5)
	_kamera_auf(cam, kf, mitte, von, d_cam)
	cam.make_current()
	await process_frame
	if not mess and not Signatur.wache(kf, self, "Film 406.2a " + String(h.name)):
		return
	if lb:
		lb.text = "406.2a · Angriff im Rennen wie im Dorf"
		lz.text = String(h.name)
	await _blende(0.0)
	await create_timer(0.8).timeout
	for i in WINKEL.size():
		wolf.position = kampfweg[i]
		wolf._face(held.home - wolf.position)
		held._face(wolf.position - held.position)
		var vorher: String = held.anim.current_animation
		var ms: int = held._held_schlag(wolf)
		var t := 0.0
		var lauf := ""
		var ende: float = held.busy_ms / 1000.0 + 0.6
		while t < ende:
			await process_frame
			t += 1.0 / 30.0
			var c: String = held.anim.current_animation
			if lauf == "" and c != vorher and not c.begins_with("SS_Idle") and c not in ["Kampfstehen", "Stehen"]:
				lauf = c
			mitte = mitte.lerp(held.position.lerp(wolf.position, 0.5), 0.12)
			d_cam = lerpf(d_cam, abstand.call(), 0.06)
			_kamera_auf(cam, kf, mitte, von, d_cam)
		var gut := lauf.begins_with("Kampfrennen")
		print("Film 406.2a %s Anlauf %d: Bewegung %s, Aufschlag %d ms, Schild „%s“, Stab %s, %s" % [h.name, i + 1, lauf, ms, held._schild(), held._stab(), "gut" if gut else "FEHLER kein Kampfrennen"])
		if not gut:
			fehler += 1
		if lauf == "SS_RunForward":
			print("FEHLER 406.2a: SS_RunForward (Chef: nie das Hopsen)")
	await create_timer(0.4).timeout
	await _blende(1.0)
	kf.queue_free()
	p.queue_free()
	await process_frame
	await process_frame


func _kamera_auf(cam: Camera3D, kf, ziel: Vector3, von: Vector3, d: float) -> void:
	var z := ziel + Vector3(0, 0.95, 0)
	cam.position = z + von * d + Vector3(0, d * 0.22, 0)     # etwa 12° von oben wie die Spielkamera, nicht flach
	cam.look_at(z)
	kf.ink_ziel = z     # Tusche nach Licht nach dieser Kamera (kampfort.gd _ink_licht)
