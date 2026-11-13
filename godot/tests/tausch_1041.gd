extends "res://tests/am_zug_565.gd"
# 1041 (Chef 12.11., 15:16, Build 280, Probekampf Jägerkind vorn, Söldner hinten: „das Jägerkind ist wie von der Tarantel gestochen,
# also sehr flott in einem Bogen rumgegangen und der Söldner hat halt einfach zwei Schrittchen nach vorne gemacht, ganz gemessen“):
# Probekampf Jägerkind (ROGUE) vorn, Söldner (FIGHTER) direkt dahinter, gegen die Wölfe; das Jägerkind tauscht mit ihm den Platz.
# Misst je Bild beide: wann sie losgehen und ankommen, Tempo gegen das Tempo ihrer Schritte, die größte Richtungsänderung von einem
# Bild zum nächsten (eckig: ein Knick) und den kleinsten Abstand. Exit 0 = beide gehen im selben Bild los, kommen höchstens 2 Bilder
# auseinander an, keiner schneller als das Tempo des anderen um mehr als 10 %, kein Knick über KNICK, Abstand nie unter NAH.
# Ohne Kaufmodelle (am Rechner) mit dem eigenen Helden (Gehen). Aufruf: im Ordner godot --headless --fixed-fps 30 -s res://tests/tausch_1041.gd
# 1041 (Chef 12.11., 20:35, Film 1039: „Mensch mit Stab mit dem vorne befindlichen Mensch mit Schild und Schwert … indem er einfach
# durch ihn durchläuft“): KLASSE=FIGHTER SOELDNER=WIZARD ist sein Paar (Schild und Schwert vorn, Stab dahinter); dazu misst der Test
# je Bild den Spalt zwischen den Umrissen beider Figuren samt Waffe, Schild und Stab (Kasten aller Netze, von oben), nicht nur
# zwischen den Mitten; berühren sie sich, ist es ein Fehler. Ohne Netze (am Rechner ohne Modelle) misst er das nicht.

const KNICK := 12.0     # Grad je Bild
const NAH := 0.6
const GRENZE := 1.6

func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var p = load("res://kampf/probe.tscn").instantiate()
	root.add_child(p)
	await process_frame
	p.hero_cls = OS.get_environment("KLASSE") if OS.get_environment("KLASSE") != "" else "ROGUE"
	p.merc_cls = OS.get_environment("SOELDNER") if OS.get_environment("SOELDNER") != "" else "FIGHTER"
	p.foe = "WOLVES"
	p._start(7)
	var t0 := Time.get_ticks_msec()
	while p.fight == null and Time.get_ticks_msec() - t0 < 15000:
		await process_frame
	var k = p.fight
	await create_timer(2.5).timeout
	if not await _warte(k, "PARTY", "hero"):
		print("FEHLER Kampf vorbei, bevor der Held dran war"); quit(1); return
	var m = k.mars
	var f = m.current()
	for versuch in 4:
		if m.can_swap(f):
			break
		k.order(["wait"])
		await create_timer(0.5).timeout
		if not await _warte(k, "PARTY", "hero"):
			print("FEHLER Kampf vorbei"); quit(1); return
		f = m.current()
	if not m.can_swap(f):
		print("FEHLER kein Wechsel möglich"); quit(1); return
	# der Söldner direkt hinter den Helden (wie im Probekampf des Chefs), dort auch die Figur
	var merc = m.find("merc")
	var hinter := Vector2i(1 - f.place.x, f.place.y)
	for o in m.fighters():
		if o != merc and o.side == "PARTY" and o.place == hinter:
			o.place = merc.place
	merc.place = hinter
	for o in m.fighters():     # die Anzeige (shown) kennt die neuen Plätze, sonst stünde jeder wie neben einem zweiten in der Reihe
		if k.shown.places.has(o.id):
			k.shown.places[o.id] = o.place
	var figs := {"hero": k.figures["hero"], "merc": k.figures["merc"]}
	var mp: Vector3 = k._spot_pos(merc, hinter)
	figs.merc.position = mp
	figs.merc.home = mp
	var hp: Vector3 = k._spot_pos(f, f.place)     # allein in der Reihe: in der Mitte
	figs.hero.position = hp
	figs.hero.home = hp
	await create_timer(0.5).timeout
	print("Held %s, Söldner %s" % [f.place, merc.place])
	var vor := {}
	var rich := {}
	for id in figs:
		vor[id] = figs[id].position
	k.order(["swap", hinter, false])
	print("Held %s -> %s, Söldner %s -> %s" % [vor.hero, figs.hero.home, vor.merc, figs.merc.home])
	# los, an, größtes Tempo gegen die Schritte, Weg, größter Knick, Tempo (m/s) Mittel
	var mess := {"hero": [-1, -1, 0.0, 0.0, 0.0], "merc": [-1, -1, 0.0, 0.0, 0.0]}
	var nah := INF
	var spalt := INF     # kleinster Spalt der Umrisse (m), INF ohne Netze
	var dt := 1.0 / 30.0
	for i in 200:
		await process_frame
		for id in figs:
			var g = figs[id]
			var s: Vector3 = g.position - vor[id]
			s.y = 0.0
			var v: float = s.length() / dt
			vor[id] = g.position
			if v > 0.05:
				var w: Array = mess[id]
				if w[0] < 0:
					w[0] = i
				w[1] = i
				w[3] += v * dt
				var a: String = g.anim.current_animation if g.anim else ""
				var gang: bool = a.contains("Walk") or a.contains("Gehen") or a.contains("Run") or a.contains("Rennen")
				if not (g.position.is_equal_approx(g.home) and not gang):
					var schritt: float = g._held_mps(a) * absf(g.anim.get_playing_speed()) if gang else 0.0
					w[2] = maxf(w[2], v / maxf(schritt, 0.01) if gang else INF)
				if rich.has(id):
					var knick := rad_to_deg(absf(wrapf(atan2(s.x, s.z) - rich[id], -PI, PI)))
					w[4] = maxf(w[4], knick)
				rich[id] = atan2(s.x, s.z)
		nah = minf(nah, Vector2(figs.hero.position.x - figs.merc.position.x, figs.hero.position.z - figs.merc.position.z).length())
		var ua = _umriss(figs.hero)
		var ub = _umriss(figs.merc)
		if ua != null and ub != null:
			var gx: float = maxf(ua.position.x - ub.end.x, ub.position.x - ua.end.x)
			var gz: float = maxf(ua.position.y - ub.end.y, ub.position.y - ua.end.y)
			spalt = minf(spalt, maxf(gx, gz))
	var fehler := 0
	for id in mess:
		var w: Array = mess[id]
		var dauer: float = (w[1] - w[0] + 1) * dt
		print("%s: los Bild %d, an Bild %d (%.2f s), Weg %.2f m, %.2f m/s, Tempo höchstens %.2f-fach der Schritte, Knick höchstens %.0f°" % [id, w[0], w[1], dauer, w[3], w[3] / maxf(dauer, 0.01), w[2], w[4]])
		if w[0] < 0:
			print("FEHLER %s bewegt sich nicht" % id); fehler += 1
		elif w[2] > GRENZE:
			print("FEHLER %s gleitet" % id); fehler += 1
		if w[4] > KNICK:
			print("FEHLER %s geht eckig (Knick %.0f°)" % [id, w[4]]); fehler += 1
	var h: Array = mess.hero
	var s: Array = mess.merc
	if absi(h[0] - s[0]) > 0:
		print("FEHLER nicht zugleich los (%d Bilder auseinander)" % absi(h[0] - s[0])); fehler += 1
	if absi(h[1] - s[1]) > 2:
		print("FEHLER nicht zugleich an (%d Bilder auseinander)" % absi(h[1] - s[1])); fehler += 1
	var vh: float = h[3] / maxf((h[1] - h[0] + 1) * dt, 0.01)
	var vs: float = s[3] / maxf((s[1] - s[0] + 1) * dt, 0.01)
	if maxf(vh, vs) > minf(vh, vs) * 1.1:
		print("FEHLER Tempo ungleich (%.2f gegen %.2f m/s)" % [vh, vs]); fehler += 1
	print("Abstand Held–Söldner kleinster %.2f m" % nah)
	if nah < NAH:
		print("FEHLER zu nah (unter %.2f m)" % NAH); fehler += 1
	if spalt == INF:
		print("Umrisse: ohne Netze nicht gemessen")
	else:
		print("Umrisse Held–Söldner (Körper, Waffe, Schild, Stab) kleinster Spalt %.2f m" % spalt)
		if spalt <= 0.0:
			print("FEHLER Körper, Waffe, Schild oder Stab berühren sich (Spalt %.2f m)" % spalt); fehler += 1
	print("TAUSCH1041 %d Fehler" % fehler)
	quit(1 if fehler else 0)


## 1041: Umriss einer Figur von oben (x, z) aus den Kästen aller sichtbaren Netze unter ihr (Körper, Waffe, Schild, Stab), ohne
## Bodenschatten und Abziehbilder; null ohne Netze
func _umriss(fig):
	var r = null
	for n in fig.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if not mi.is_visible_in_tree() or mi.mesh == null or mi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY:
			continue
		var nm := String(mi.name).to_lower()
		if nm.contains("schatten") or nm.contains("shadow") or nm.contains("decal") or nm.contains("ring"):
			continue
		var box: AABB = mi.global_transform * mi.get_aabb()
		var q := Rect2(box.position.x, box.position.z, box.size.x, box.size.z)
		r = q if r == null else (r as Rect2).merge(q)
	return r
