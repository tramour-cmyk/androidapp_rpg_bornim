extends SceneTree
# 531 Vorlage (Chef 03.11., 23:42, Build 249: „Garrick wie alt und besser: Gesicht, Langbogen auf dem Rücken, vertreibt Tiere sichtbar mit
# der Fackel, Ruhebewegungen“; 04.11., 19:27 „Film statt Bild“). Je Prüfgegenstand eine Vorlage (G4, 1076: nur der Prüfgegenstand, etwa
# dreimal, bis 15 s; kein Text im Bild, Lauf 288):
#   Film: ein Wolf jagt den Helden an Garricks Feuer, Garrick nimmt die Fackel aus dem Feuer, schwenkt sie zum Tier, das Tier geht;
#         dreimal (Tag, Abend, Nacht), Spielkamera auf die Mitte zwischen Garrick und Tier. Die Regeln laufen (Herde, Schutzort).
#         Gibt je Abwehr „GARRICKFILM schnitt <bild>“ aus; tools: ffmpeg schneidet je 4,6 s ab dort zusammen.
#   Bild (-- --bild=<datei>.png): Garrick in Ruhe von hinten schräg, Langbogen und Köcher auf dem Rücken (643, heldfigur.gd ruecken_tragen)
# Gesicht: 475; Ruhebewegungen: 1044 (heldfigur.gd RUHE_JE „garrick“: umsehen, greifen, trinken), nicht hier.
# Aufruf im Ordner godot: xvfb-run -a -s "-screen 0 540x1170x24" godot --rendering-driver opengl3 --path . --resolution 540x1170
#   --write-movie <datei>.avi --fixed-fps 30 -s res://tests/garrick_film_531.gd     (Bild: ohne --write-movie, mit -- --bild=…)

var spiel
var g: Leute
var bild := ""
var bilder := 0

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--bild="): bild = a.substr(7)
	_lauf.call_deferred()

func warte(s: float) -> void:
	for i in maxi(1, roundi(s * 30.0)):
		await process_frame
		bilder += 1
		if spiel.ui.textfeld: spiel.ui.textfeld.visible = false

func _lauf() -> void:
	if not FileAccess.file_exists("res://daten/forest.bin"):
		print("GARRICKFILM ohne daten/forest"); quit(1); return
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 10 * 60
	spiel.betrete("forest", Vector2i(10, 10), "RIGHT")
	for i in 5: await process_frame
	spiel.ui.visible = false   # Pruefer Lauf 288: keine Bedienung, kein Text im Bild
	for l in spiel.leute.get_children():
		if l is Leute and String(l.daten.get("id", "")) == "garrick": g = l
	if g == null or spiel.herde == null:
		print("GARRICKFILM kein Garrick oder keine Herde"); quit(1); return
	var sk := Gebiet.finde(g.modell, "Skeleton3D") as Skeleton3D
	print("GARRICKFILM Ruecken: Bogen %s, Koecher %s" % [sk.has_node("RueckenBogen"), sk.has_node("RueckenKoecher")])
	if bild != "":
		await knips_ruecken(); return
	spiel.kamera.ziel = g
	spiel.kamera.springe()
	var h: Herde = spiel.herde
	h.kampf.disconnect(spiel._kampf_auf_karte)
	h.kampf.connect(func(_m, _e, _w): print("GARRICKFILM FEHLER Kampf am Feuer"))
	var gesehen := 0
	for zeit in [10 * 60, 19 * 60 + 30, 23 * 60]:
		if zeit >= 19 * 60 and spiel.zustand.minuten < 19 * 60: spiel.licht.umschalten()
		spiel.zustand.minuten = zeit
		await warte(1.5)
		if await jagd(h): gesehen += 1
		await warte(1.0)
	print("GARRICKFILM fertig, %d von 3 Abwehren" % gesehen)
	quit(0 if gesehen == 3 else 1)

## Garrick von hinten schraeg (links hinten, etwas erhoeht), Brust in der Bildmitte, Tag
func knips_ruecken() -> void:
	spiel.herde.aus = true
	g.set_process(false)
	await warte(1.0)
	var cam := Camera3D.new()
	root.add_child(cam)
	var vorn := Vector3(sin(g.rotation.y), 0, cos(g.rotation.y))
	var links := vorn.cross(Vector3.UP) * -1.0
	var brust := g.global_position + Vector3.UP * 1.0
	cam.global_position = brust - vorn * 4.0 + links * 1.8 + Vector3.UP * 0.9
	cam.look_at(brust, Vector3.UP)
	cam.fov = 40.0
	cam.make_current()
	await warte(0.5)
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(bild)
	print("GARRICKFILM Bild ", bild)
	quit()

## ein Jaeger der Herde jagt den Helden von Osten an den Schutzort (wie garrick_531.gd); true, wenn Garrick abwehrte
func jagd(h: Herde) -> bool:
	var jaeger: Streuner = null
	for s in h.liste:
		if s.temper() == "JAEGER" and jaeger == null: jaeger = s
		else: s.ruhig_bis = 1 << 40; s.jagt = false
	if jaeger == null:
		print("GARRICKFILM FEHLER kein Jaeger"); return false
	var t := Vector2i(14, 10)
	if not spiel.karte.begehbar(t): t = Vector2i(15, 9)
	jaeger.kachel = t; jaeger.von = t; jaeger.heim = t + Vector2i(3, 0); jaeger.jagt = true; jaeger.naechst_ms = 0
	jaeger.ruhig_bis = 0
	jaeger.position = spiel.karte.kachel_pos(t)
	h.frieden_bis = 0
	# Pruefer Lauf 288: das Tier gibt 4,8-7 m vor Garrick auf; Spielkamera normal, Mitte zwischen Garrick und Tier
	var mitte := Node3D.new()
	g.get_parent().add_child(mitte)
	mitte.global_position = (g.global_position + jaeger.global_position) * 0.5
	if spiel.kamera.nah: spiel.kamera.nah_fern()
	spiel.kamera.ziel = mitte
	var sah := false
	for i in 12 * 30:
		await warte(1.0 / 30.0)
		mitte.global_position = (g.global_position + jaeger.global_position) * 0.5
		if g.abwehr and g.abwehr.laeuft() and not sah:
			sah = true
			print("GARRICKFILM schnitt %d" % Engine.get_process_frames())
		if sah and not g.abwehr.laeuft(): break
	mitte.queue_free()
	print("GARRICKFILM Abwehr %s" % ("gesehen" if sah else "FEHLT"))
	return sah
