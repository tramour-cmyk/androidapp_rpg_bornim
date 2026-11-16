# 995 (Chef 11.11., 20:58, Film 744: Grabhund „wie halb transparent“; Augen klar in einer Farbe, Nasenrücken und Ohren lesbarer):
# Probebild der drei Grabhunde im Kampfort im Spiellicht (Toon, Tusche nach Licht, Schatten), Kampfanzeige aus. Ein Bild in der
# Spielkamera, dazu je Hund eine Nahaufnahme des Kopfes aus Richtung der Kampfkamera (Kopfknochen „BARGHEST_ Head“).
# Aufruf: PROBEBILD=995 xvfb-run -a -s "-screen 0 1080x2340x24" godot --rendering-driver opengl3 --path godot --resolution 1080x2340
#   -s res://tests/grabhund_995.gd   (BILD=<pfad.png>: Spielbild; Nahaufnahmen <pfad>-hound1.png …; NAHM=<m> Abstand, Standard 1,6)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "GRABHUNDE"
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
	kf.playing = true     # keine Meldungen der Regeln mehr; der Kampfort läuft weiter (Tusche nach Licht)
	await create_timer(1.5).timeout
	if not Signatur.wache(kf, self, "Probebild 995"):
		return
	var pfad := OS.get_environment("BILD") if OS.get_environment("BILD") != "" else "/tmp/grabhund_995.png"
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(pfad)
	print("Probebild 995: Spielkamera → %s" % pfad)
	var abstand := float(OS.get_environment("NAHM")) if OS.get_environment("NAHM") != "" else 1.6
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster == null:
			continue
		var sk: Array = f.find_children("*", "Skeleton3D", true, false)
		if sk.is_empty():
			continue
		var s: Skeleton3D = sk[0]
		var b := s.find_bone("BARGHEST_ Head")
		if b < 0:
			print("FEHLER Probebild 995: kein Kopfknochen in %s" % id)
			continue
		var kopf: Vector3 = s.global_transform * s.get_bone_global_pose(b).origin
		# Kopfmitte etwas vor dem Gelenk (Richtung Schnauze = Blick der Figur)
		kopf += f.global_basis.z.normalized() * 0.12 * f.scale.y
		var nah := Camera3D.new()
		kf.add_child(nah)
		nah.fov = 22.0
		var weg: Vector3 = (kf.cam.global_position - kopf).normalized()
		nah.position = kopf + weg * abstand
		nah.look_at(kopf)
		nah.make_current()
		kf.ink_ziel = kopf     # Tusche wie im Spiel in dieser Nähe
		for i in 3:
			await process_frame
		await RenderingServer.frame_post_draw
		var np := pfad.get_basename() + "-%s.png" % id
		root.get_texture().get_image().save_png(np)
		print("Probebild 995: Kopf %s → %s" % [id, np.get_file()])
		nah.queue_free()
	kf.cam.make_current()
	quit(0)
