# 593 (Chef 05.11., 19:2x, Build 266: „Ausweichbewegungen müssen nicht links – rechts sein, sondern können auch rückwärts gehen
# (so als Alternative)“): Messung ohne Grafik am Kampfort (probe.gd) gegen Ratten, Spinne, Grak, Wölfe: jeder Gegner weicht dreimal
# aus dem Stehen aus (dodge); gemessen, wohin der Satz geht (im Blick des Gegners: zurück oder zur Seite) und ob er einem anderen
# näher kommt als 0,1 m. Exit 0 = je Art mindestens einmal rückwärts, keiner in einen anderen. Ohne Kaufmodelle nichts zu messen.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/ausweichen_593.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const ARTEN := ["RATS", "SPINNE", "GRAK", "WOLVES"]

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin"):
		print("AUSWEICHEN593 ohne Kaufmodelle, nichts zu messen")
		quit(0)
		return
	for art in ARTEN:
		await _art(art)
	print("AUSWEICHEN593 %d Fehler" % fehler)
	quit(1 if fehler else 0)


func _art(art: String) -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = art
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 30: await process_frame
	var kf = p.fight
	kf.playing = true     # keine Meldungen der Regeln: nur die Ausweichsätze
	var rueck := 0
	var seite := 0
	var nah := INF
	var gezaehlt := 0
	for id in kf.figures:
		var fig = kf.figures[id]
		if fig.fighter.monster == null or fig.down:
			continue
		gezaehlt += 1
		for n in 3:
			for i in 20: await process_frame
			var start: Vector3 = fig.position
			var b: Basis = fig.basis
			fig.dodge(0)
			var weitest := start
			var t := 0
			while t < 30 * 6:
				await process_frame
				t += 1
				if fig.position.distance_to(start) > weitest.distance_to(start):
					weitest = fig.position
				for jd in kf.figures:
					var o = kf.figures[jd]
					if o != fig and o.visible and not o.down:
						nah = minf(nah, Vector2(o.position.x - fig.position.x, o.position.z - fig.position.z).length() - 0.3 * (fig.scale.x + o.scale.x))
				if t > 20 and fig.position.distance_to(fig.home) < 0.02 and not fig.lunging():
					break
			var l := b.inverse() * (weitest - start)
			var art_satz := "zurück" if -l.z > absf(l.x) * 0.8 else ("seitlich" if l.length() > 0.1 else "am Platz")
			if art_satz == "zurück": rueck += 1
			elif art_satz == "seitlich": seite += 1
			print("  %s %s Satz %d: %s (quer %.2f m, zurück %.2f m)" % [art, id, n + 1, art_satz, l.x, -l.z])
	var gut := gezaehlt == 0 or rueck >= 1
	print("%s %s: %d rückwärts, %d seitlich; nächster Abstand %.2f m" % ["ok    " if gut else "FEHLER", art, rueck, seite, nah])
	if not gut:
		fehler += 1
	p.queue_free()
	for i in 5: await process_frame
