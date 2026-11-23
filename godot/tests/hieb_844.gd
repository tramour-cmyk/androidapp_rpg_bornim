extends SceneTree
# 844 (aus 709, treffen_709: Goblins und Kobolde ohne Angriffsbewegung, glitten im Stehen vor, Treffer ohne Schlag): jeder Goblin,
# Kobold und Schamane im Kampfort (je Kit) hat „Hieb“, einen Wurzelweg „Gehen“ und „hieb“ (info) und schlägt so, dass seine Waffe im
# ganzen Hieb über dem Boden bleibt (BODEN_M) und nicht durch den eigenen Körper geht (E3, KOERPER_M); beim Aufschlag liegt die
# Klinge vor ihm und nicht unter Kniehöhe des Helden (AUF_HOCH_M). Der Weg der Waffe ist der, mit dem figur.gd den Stand rechnet
# (_hieb_bahn). Ohne Bild, Sekunden. Der Späher schießt nur und hat keinen Hieb.
# Aufruf: im Ordner godot mit -s res://tests/hieb_844.gd   (Exit 0 = gut; ohne gebaute Modelle FALSCH); HIEB_LOG=1 druckt jedes Bild

const Probe = preload("res://kampf/probe.gd")
const BODEN_M := -0.03     # der Stab des Schamanen steht in Ruhe auf dem Boden
const KOERPER_M := 0.0
const AUF_HOCH_M := 0.3
var log_an := OS.get_environment("HIEB_LOG") != ""
var f := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var n := 0
	for g in ["GOBLINS", "KOBOLDS", "SHAMANS"]:
		n += await _art(g)
	if n < 9:
		print("HIEB844 FALSCH nur %d Gegner geprüft (Modelle fehlen?)" % n)
		f += 1
	print("HIEB844 %s" % ("gut" if f == 0 else "%d Fehler" % f))
	quit(1 if f > 0 else 0)


func _art(g: String) -> int:
	var n := 0
	for k in 3:
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = g
		root.add_child(p)
		await process_frame
		p._start(5)
		for i in 6:
			await process_frame
		var kf = p.fight
		var feinde := []
		if kf != null:
			for id in kf.figures:
				if kf.figures[id].fighter.monster != null:
					feinde.append(kf.figures[id])
		if k < feinde.size():
			n += 1
			_pruef(g, feinde[k])
		p.queue_free()
		await process_frame
	return n


func _pruef(g: String, fig) -> void:
	var name_: String = String(fig._model_path()).get_file()
	if fig.anim == null or not fig.anim.has_animation("Hieb") or fig.hieb.size() < 3 or not fig.weg.has("Gehen"):
		print("HIEB844 FALSCH %s %s: Hieb %s, info hieb %s, Wurzelweg %s" % [g, name_, fig.anim != null and fig.anim.has_animation("Hieb"), fig.hieb, fig.weg.keys()])
		f += 1
		return
	var bahn: Array = fig._hieb_bahn("Hieb", deg_to_rad(float(fig.hieb[2])))
	if bahn.is_empty():
		print("HIEB844 FALSCH %s %s: kein Weg der Waffe" % [g, name_])
		f += 1
		return
	var boden := INF
	var koerper := INF
	var auf: Array = []
	var t_auf := float(fig.hieb[1])
	for b in bahn:
		for w in b[1]:
			boden = minf(boden, minf((w[0] as Vector3).y, (w[1] as Vector3).y) - float(w[2]))
			for c in b[2]:
				var pq := Geometry3D.get_closest_points_between_segments(w[0], w[1], c[0], c[1])
				koerper = minf(koerper, pq[0].distance_to(pq[1]) - float(w[2]) - float(c[2]))
		if absf(float(b[0]) - t_auf) < 0.5 / 30.0 and not b[1].is_empty():
			auf = b[1][0]
		if log_an and not b[1].is_empty():
			var w0: Array = b[1][0]
			print("  %s %.2f s: Griff (%.2f, %.2f, %.2f) Spitze (%.2f, %.2f, %.2f)" % [name_, b[0], w0[0].x, w0[0].y, w0[0].z, w0[1].x, w0[1].y, w0[1].z])
	var hoch := -INF
	var vor := -INF
	if not auf.is_empty():
		hoch = maxf((auf[0] as Vector3).y, (auf[1] as Vector3).y)
		vor = maxf((auf[0] as Vector3).z, (auf[1] as Vector3).z)
	var gut: bool = boden >= BODEN_M and koerper >= KOERPER_M and hoch >= AUF_HOCH_M and vor > 0.2
	print("HIEB844 %s %s %s: Hieb %.2f s, Aufschlag %.2f s (Klinge bis %.2f m hoch, %.2f m vor), tiefste Stelle %.2f m, zum eigenen Körper %.3f m" % [
		"ok" if gut else "FALSCH", g, name_, fig.anim.get_animation("Hieb").length, t_auf, hoch, vor, boden, koerper])
	if not gut:
		f += 1
