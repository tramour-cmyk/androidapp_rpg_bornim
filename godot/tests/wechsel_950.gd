extends "res://tests/am_zug_565.gd"
# 950 (Chef 11.11., 13:44, t276: Platztausch von Held und Söldner gleitet): Probekampf Mira (Kleriker) und Söldner gegen die Wölfe;
# Mira tauscht die Reihe mit dem Söldner. Misst je Bild beide: Tempo (m/s) gegen das Tempo ihrer Schritte, ob eine Gehbewegung läuft,
# solange sie sich bewegen, und den kleinsten Abstand der beiden. Exit 0 = beide gehen, keiner gleitet (höchstens 1,6-fach, D4),
# Abstand nie unter 0,35 m. Ohne Kaufmodelle (am Rechner) ohne Gehbewegung: dann nur die Zahlen.
# Aufruf: im Ordner godot --headless --fixed-fps 30 -s res://tests/wechsel_950.gd

const GRENZE := 1.6
const NAH := 0.35

func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var p = load("res://kampf/probe.tscn").instantiate()
	root.add_child(p)
	await process_frame
	p.hero_cls = "CLERIC"
	p.still_name = "Mira"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	p._start(7)
	var t0 := Time.get_ticks_msec()
	while p.fight == null and Time.get_ticks_msec() - t0 < 15000:
		await process_frame
	var k = p.fight
	await create_timer(2.5).timeout
	if not await _warte(k, "PARTY", "hero"):
		print("FEHLER Kampf vorbei, bevor Mira dran war"); quit(1); return
	var m = k.mars
	var f = m.current()
	for versuch in 4:     # wer schon gewechselt hat (moved), wartet seinen nächsten Zug ab
		if m.can_swap(f):
			break
		k.order(["wait"])
		await create_timer(0.5).timeout
		if not await _warte(k, "PARTY", "hero"):
			print("FEHLER Kampf vorbei"); quit(1); return
		f = m.current()
	var spot = null
	# mit dem Söldner tauschen, wenn er in der anderen Reihe steht; sonst auf den ersten freien Platz dort
	for s in preload("res://regeln/mars.gd").SPOTS:
		if s.x != f.place.x and (spot == null or m.fighters().any(func(o): return o.id == "merc" and o.place == s)):
			if spot == null or m.fighters().any(func(o): return o.id == "merc" and o.place == s):
				spot = s
	print("Mira %s, Söldner %s, Ziel %s" % [f.place, m.find("merc").place, spot])
	if spot == null or not m.can_swap(f):
		print("FEHLER kein Wechsel möglich"); quit(1); return
	var beide: bool = m.find("merc").place == spot
	var figs := {"hero": k.figures["hero"], "merc": k.figures["merc"]}
	var vor := {}
	for id in figs:
		vor[id] = figs[id].position
	k.order(["swap", spot, false])
	var mess := {"hero": [0.0, 0.0, 0, 0], "merc": [0.0, 0.0, 0, 0]}     # größtes Tempo, Weg, Bilder in Bewegung, davon ohne Gehen
	var nah := INF
	var dt := 1.0 / 30.0
	for i in 150:
		await process_frame
		for id in figs:
			var g = figs[id]
			var v: float = g.position.distance_to(vor[id]) / dt
			vor[id] = g.position
			if v > 0.05:
				var a: String = g.anim.current_animation if g.anim else ""
				var gang: bool = a.contains("Walk") or a.contains("Gehen") or a.contains("Run") or a.contains("Rennen")
				var schritt: float = g._held_mps(a) * absf(g.anim.get_playing_speed()) if gang else 0.0
				mess[id][0] = maxf(mess[id][0], v / maxf(schritt, 0.01) if gang else INF)
				mess[id][1] += v * dt
				mess[id][2] += 1
				if not gang:
					mess[id][3] += 1
					print("ohne Gehen %s Bild %d: %s, %.2f m/s, am Platz %s" % [id, i, a, v, g.position.is_equal_approx(g.home)])
		nah = minf(nah, Vector2(figs.hero.position.x - figs.merc.position.x, figs.hero.position.z - figs.merc.position.z).length())
	var fehler := 0
	for id in mess:
		var w: Array = mess[id]
		print("%s: Weg %.2f m in %d Bildern, ohne Gehbewegung %d, Tempo höchstens %.2f-fach der Schritte" % [id, w[1], w[2], w[3], w[0]])
		if w[2] == 0:
			if id == "hero" or beide:
				print("FEHLER %s hat sich nicht bewegt" % id); fehler += 1
		elif w[3] > 0 or w[0] > GRENZE:
			print("FEHLER %s gleitet" % id); fehler += 1
	print("Abstand Held–Söldner kleinster %.2f m" % nah)
	if nah < NAH:
		print("FEHLER zu nah (unter %.2f m)" % NAH); fehler += 1
	print("WECHSEL950 %d Fehler" % fehler)
	quit(1 if fehler else 0)
