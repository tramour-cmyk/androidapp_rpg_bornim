# 546 (Chef 04.11., 00:01, Build 249: „Wölfe weichen aus wie Schlaftabletten“): Messung ohne Grafik am Kampfort gegen das
# Wolfsrudel (probe.gd): jeder Wolf weicht aus dem Stehen einmal aus (dodge); je Bild (--fixed-fps 30) Weg und Zeit bis zum
# Ende des Satzes (bahn[0] erreicht); 703 A (Chef 08.11., 21:36): danach bleibt er dort stehen, 2 s lang nicht mehr als 0,05 m
# weiter (dreht sich nur). Ausgabe je Wolf: Satz in m und s, mittleres Tempo, Abstand zum Platz danach.
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/ausweichen_546.gd   (Exit 0 = Satz mindestens SATZ_MPS m/s und
# höchstens DREH_GRAD je Bild, danach stehen geblieben; vorher 1,71 m/s im Schritt, 0,93 s für 1,6 m)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
## Richtwerte (Maß): der Satz mindestens so schnell (m/s), Drehung höchstens so viel je Bild (438: im Lauf 28° zu viel)
const SATZ_MPS := 3.0
const DREH_GRAD := 16.0

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))     # Hochformat wie am Handy
	root.size = Vector2i(1080, 2340)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start()
	for i in 30: await process_frame
	var kf = p.fight
	# 703 (Lauf 313, Build 271: „wolf2 … danach 1.32 m bewegt“, nachgestellt 09.11.): die Gegner ziehen am Anfang selbst
	# (Platzwechsel), je nach Takt mitten in der Messung; erst messen, wenn der Kampf auf den Helden wartet und alle stehen
	var w := 0
	while w < 30 * 40 and (kf.busy or kf.playing or not kf.beats.is_empty() or kf.figures.values().any(func(f): return f.unterwegs())):
		await process_frame
		w += 1
	for i in 30: await process_frame
	print("AUSWEICHEN_546 Kampf wartet nach %.1f s" % (w / 30.0))
	var fehler := 0
	seed(5)
	for id in ["wolf1", "wolf2", "wolf3"]:
		var fig = kf.figures.get(id)
		if fig == null:
			continue
		for i in 30: await process_frame
		var heim: Vector3 = fig.home
		var start: Vector3 = fig.position
		fig.dodge(0)
		var t := 0
		var weg := 0.0
		var vor: Vector3 = fig.position
		var satz_t := -1.0
		var satz_m := 0.0
		var ziel = null
		var gier_max := 0.0
		var gier_vor: float = fig.rotation.y
		var danach := 0.0     # 703 A: weitester Weg vom Ende des Satzes in den 2 s danach
		while t < 30 * 8:
			await process_frame
			t += 1
			weg += fig.position.distance_to(vor)
			if satz_t < 0.0:
				gier_max = maxf(gier_max, absf(rad_to_deg(wrapf(fig.rotation.y - gier_vor, -PI, PI))))
			gier_vor = fig.rotation.y
			vor = fig.position
			if ziel == null and fig.bahn.size() >= 1:
				ziel = fig.bahn[0]
			if satz_t < 0.0 and ziel != null and fig.position.distance_to(ziel) < 0.02:
				satz_t = t / 30.0
				satz_m = weg
			if satz_t >= 0.0:
				danach = maxf(danach, Vector2(fig.position.x - ziel.x, fig.position.z - ziel.z).length())
				if t > satz_t * 30 + 60:
					break
		var gut := satz_t > 0.0 and satz_m / satz_t >= SATZ_MPS and gier_max <= DREH_GRAD and danach <= 0.05
		print("%s %s: Satz %.2f m in %.2f s (%.2f m/s, Drehung bis %.0f° je Bild), danach %.2f m bewegt, %.2f m vom Platz" % ["ok    " if gut else "FEHLER", id, satz_m, satz_t, satz_m / maxf(satz_t, 0.01), gier_max, danach, Vector2(fig.position.x - heim.x, fig.position.z - heim.z).length()])
		if not gut:
			fehler += 1
	print("AUSWEICHEN_546 %d Fehler" % fehler)
	quit(1 if fehler else 0)
