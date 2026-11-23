extends SceneTree
# 1570: Prüfbild Umhang in der Spielkamera (Handy 540x1170, Spielshader, Tusche, Schatten wie im Spiel), je Aufruf ein Stand:
#   welt:  Wachsoldat geht im Dorf mit Zweihänder (Gehen_axt), Kamera des Spiels nah, rechte Seite zur Kamera; Stelle: rechter Unterarm
#   kampf: Kämpfer (Wachsoldat) im Probekampf mit Handaxt und Schild, Rücken zur Kampfkamera, Kampfhaltung; Stelle: linke Flanke
#   kloster: Klosterschülerin geht im Dorf ohne Waffe, Rücken zur Kamera (Auftrag 1570, 23.11.); Stelle: linkes Schulterblatt
# Gibt je Bild die Bildstelle aus (STELLE1570 <fall> x y), das Markieren und Zusammensetzen alt gegen neu macht der Aufrufer.
# Aufruf: PROBE=1570 xvfb-run -a godot --path godot --rendering-driver opengl3 --resolution 540x1170 --fixed-fps 30
#   -s res://tests/umhang_bild_1570.gd -- --bild=1570 --fall=welt|kampf|kloster --aus=<datei.png>
const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")

var fall := "welt"
var aus := ""

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--fall="): fall = a.substr(7)
		if a.begins_with("--aus="): aus = a.substr(6)
	(_kampf if fall == "kampf" else _welt).call_deferred()

func _bilder(n: int) -> void:
	for i in n: await process_frame

func _speichern(stelle: Vector2) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(aus)
	print("STELLE1570 %s %d %d" % [fall, int(stelle.x), int(stelle.y)])
	print("BILD ", aus)
	quit(0)

func _knochen(sk: Skeleton3D, n: String) -> Vector3:
	return sk.global_transform * sk.get_bone_global_pose(sk.find_bone(n)).origin

# ---- Welt ----
func _welt() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await _bilder(5)
	spiel.zustand.minuten = 12 * 60
	spiel.licht.ziel = 0.0
	spiel.licht.stelle(0.0)
	var kl := fall == "kloster"
	var w := BrsHeld.fuer_spiel("Test", "Mensch", "Klosterschüler" if kl else "Wachsoldat")
	spiel.werte = w
	if kl: spiel.zustand.aussehen = HeldFigur.vorgabe("Klosterschüler", "w")
	if kl: w.ausruestung.erase("MAIN_HAND")
	else: w.ausruestung["MAIN_HAND"] = {"base": "greatsword"}
	w.ausruestung["CLOAK"] = {"base": "cloak"}
	w.ausruestung.erase("OFF_HAND")
	spiel.held_figur_neu("")
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	if spiel.herde:
		spiel.herde.aus = true
		spiel.herde.process_mode = Node.PROCESS_MODE_DISABLED
	var h = spiel.held
	# Zweihändergang (tragen.gd GANG_ZWEI -> „axt“); ein Zweihändermodell ist im Bau von main nicht (daten/waffen), darum der Gang allein
	if not kl and h.waffengang == "" and h.anim and h.anim.has_animation("Gehen_axt"):
		h.waffengang = "axt"; h.gang_w = HeldFigur.TAKT_GEHEN; h.renn_w = HeldFigur.TAKT_RENNEN
	h.setze(Vector2i(19, 15), "DOWN")
	spiel.kamera.nah = true
	spiel.kamera.zoom = spiel.kamera.NAH
	spiel.kamera.springe()
	await _bilder(20)
	# nach Nordosten: Kamera blickt nach Nordwesten, die rechte Seite des Helden zeigt zu ihr
	# kloster: nach Nordwesten, von der Kamera weg (Rücken zu ihr)
	h.geh_zu(h.global_position + (Vector3(-3.0, 0.0, -3.0) if kl else Vector3(3.0, 0.0, -3.0)))
	await _bilder(int(OS.get_environment("BILD1570_WELT")) if OS.get_environment("BILD1570_WELT") != "" else 26)
	spiel.kamera.springe()
	await _bilder(1)
	var ap := Gebiet.finde(h, "AnimationPlayer") as AnimationPlayer
	if ap: ap.pause()
	h.halt()
	await _bilder(2)
	var sk := Gebiet.finde(h, "Skeleton3D") as Skeleton3D
	var cam := root.get_camera_3d()
	var p := (_knochen(sk, "lowerarm_r") + _knochen(sk, "hand_r")) * 0.5
	if kl: p = (_knochen(sk, "spine_03") * 2.0 + _knochen(sk, "clavicle_l") + _knochen(sk, "upperarm_l")) * 0.25   # linkes Schulterblatt
	print("WELT1570 Bewegung %s" % (ap.current_animation if ap else "?"))
	await _speichern(cam.unproject_position(p))

# ---- Kampf ----
func _kampf() -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	p.ohne_soeldner = true
	root.add_child(p)
	await process_frame
	var blatt: Dictionary = p.tables.probe["FIGHTER"].hero.hero
	var main: Dictionary = (blatt["main"] as Dictionary).duplicate()
	main["id"] = "handaxe"
	blatt["main"] = main
	p._start(7)
	await _bilder(4)
	var kf = p.fight
	if kf.ui != null: kf.ui.visible = false
	var bis := Time.get_ticks_msec() + 15000
	while kf.playing and Time.get_ticks_msec() < bis:
		await process_frame
	kf.playing = true
	var fg = null
	for id in kf.figures:
		var f = kf.figures[id]
		f.set_process(false)
		if f.fighter.monster == null and fg == null: fg = f
		else: f.visible = false
	var sk := Gebiet.finde(fg, "Skeleton3D") as Skeleton3D
	var mitte: Vector3 = kf._ground(0, 0)
	var cam: Camera3D = kf.cam
	var vorn: Vector3 = cam.global_position - mitte
	vorn.y = 0.0
	vorn = vorn.normalized()
	fg.position = mitte
	fg.rotation = Vector3(0, atan2(vorn.x, vorn.z) + PI, 0)   # Rücken zur Kamera
	var halt := "SS_IdleCombat" if fg.anim.has_animation("SS_IdleCombat") else "Kampfstehen"
	fg.anim.play(halt, 0.0)
	fg.anim.seek(0.0, true)
	fg.anim.pause()
	await process_frame
	var vs: Vector2 = root.get_visible_rect().size
	var fuss := cam.unproject_position(mitte)
	var kopf := cam.unproject_position(mitte + Vector3(0, 1.85 * fg.scale.y, 0))
	var z := clampf(vs.y * 0.40 / maxf(fuss.y - kopf.y, 1.0), 1.0, 6.0)
	var c := Vector2(fuss.x, (fuss.y + kopf.y) * 0.5 + (fuss.y - kopf.y) * 0.05)
	var per: float = kf.base_size / vs.y
	cam.size = kf.base_size / z
	cam.frustum_offset = Vector2(kf.base_off.x + (c.x - vs.x / 2.0) * per, kf.base_off.y - (c.y - vs.y / 2.0) * per)
	kf.base_size = cam.size
	kf.base_off = cam.frustum_offset
	if not Signatur.wache(kf, self, "Bild 1570"):
		return
	await _bilder(10)
	print("KAMPF1570 Haltung %s, Waffe %s" % [halt, fg._waffe_id()])
	# linke Flanke: neben spine_02 auf Höhe der Achsel, nach links (Figur +X)
	var fl := sk.global_transform * (sk.get_bone_global_pose(sk.find_bone("spine_02")).origin + Vector3(0.22, 0.0, 0.0))
	await _speichern(cam.unproject_position(fl))
