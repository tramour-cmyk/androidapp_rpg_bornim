# 1292 A (Chef 16.11., 11:49; „Ja“ zu „2/2“): Bild des Kampfschirms im Probekampf Wölfe mit dem Kleriker, Liste „Können“ offen,
# Wundsegen zeigt die übrigen Segen dieses Kampfs. Aufruf im Ordner godot mit Bildschirm (xvfb-run, Renderer mobile):
#   BILD=<pfad.png> godot --rendering-method mobile --resolution 540x1170 --fixed-fps 30 -s res://tests/knopf_1292.gd
# ohne BILD nur die Prüfung der Beschriftung (KNOPF1292 …), Exit 1, wenn „2/2“ und nach einem Segen „1/2“ fehlen.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")


func _initialize() -> void:
	_run.call_deferred()


func _knopf_text(kf) -> String:
	for b in kf.ui.find_children("*", "Button", true, false):
		if String(b.text).to_upper().begins_with("WUNDSEGEN"):
			return String(b.text)
	for l in kf.ui.find_children("*", "Label", true, false):
		if String(l.text).to_upper().begins_with("WUNDSEGEN"):
			return String(l.text)
	return ""


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(540, 1170))
	root.size = Vector2i(540, 1170)
	await process_frame
	seed(7)
	var p = Probe.new()
	p.hero_cls = "CLERIC"
	p.merc_cls = "CLERIC"     # beide kennen Wundsegen: wer zuerst dran ist, zeigt den Knopf
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	var fehler := 0
	# bis der Held am Zug ist und Befehle annimmt
	var n := 0
	while n < 30 * 60:
		await process_frame
		n += 1
		if not kf.busy and not kf.playing and kf.beats.is_empty():
			var c = kf.mars.current()
			if c != null and c.side == "PARTY":
				break
			if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
				kf.go_on()
	kf.mars.set_autopilot(false)
	var h = kf.mars.current()
	for runde in [0, 1]:
		h.wund_genutzt = runde
		kf.ui._set_pick("skills")
		for i in 20:
			await process_frame
		var t := _knopf_text(kf)
		if OS.get_environment("SCHAU") != "":
			print("KNOPF1292 dran %s, Knöpfe %s, Züge %s" % [kf.mars.current().id if kf.mars.current() else "-", kf.ui.find_children("*", "Button", true, false).map(func(x): return x.text), kf.mars.moves(h)])
		var soll := "· %d/2" % (2 - runde)
		print("KNOPF1292 %s" % t)
		if not t.contains(soll):
			fehler += 1
			print("KNOPF1292 FEHLER „%s“ fehlt" % soll)
		var bild := OS.get_environment("BILD")
		if bild != "" and runde == 0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(bild)
			print("KNOPF1292 Bild %s" % bild)
	print("KNOPF1292 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
