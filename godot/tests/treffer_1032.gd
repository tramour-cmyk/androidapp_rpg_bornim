# 1032 (Chef 12.11., 14:08, Build 280, MARS-Probekampf Wölfe, Held und Söldner Wachsoldat): „macht mein Wachsoldat, nachdem ich
# jeweils meinen Angriff gemacht hatte, so eine Stolperbewegung. Aber dafür war gar kein Angriff.“ Messung ohne Bild: Held und
# Söldner Kämpfer auf Auto gegen das Wolfsrudel; je Treffer-Bewegung (Treffer, SS_GetHit…) einer Figur der Gruppe die letzte
# Meldung mit Schaden an ihr. Befund: mehr Treffer-Bewegungen als Treffer an ihr, oder eine ohne Schadensmeldung davor.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/treffer_1032.gd   (GEGNER=WOLVES, SEEDS=1-4)
# Exit 0 = kein Befund.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")


func _initialize() -> void:
	_lauf.call_deferred()


func _treffer(nm: String) -> bool:
	return nm == "Treffer" or nm.begins_with("SS_GetHit")


func _lauf() -> void:
	var gegner := OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES"
	var bis := int(OS.get_environment("SEEDS")) if OS.get_environment("SEEDS") != "" else 4
	var befunde := 0
	for s in range(1, bis + 1):
		seed(s)
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "FIGHTER"
		p.foe = gegner
		root.add_child(p)
		await process_frame
		p._start(s)
		for i in 4:
			await process_frame
		var kf = p.fight
		var m = kf.mars
		# MANUELL=1: wie der Chef (12.11., 14:08) beide von Hand: Angriff auf den ersten stehenden Gegner, Ringe nach Zufall beantwortet
		var manuell := OS.get_environment("MANUELL") != ""
		if not manuell:
			m.find("merc").auto = true
			if m.set_autopilot(true) and not kf.busy:
				kf.go_on()
		var ring_ab := -1
		var meld := []         # [Bild, Meldung]
		kf.meldung.connect(func(e): meld.append([Engine.get_process_frames(), e]))
		# Gegenrichtung (Chef: „im Text war ein Angriff, aber keine Animation dazu“): jede Angriffsmeldung eines Gegners an die Gruppe
		# (mit Wurf) braucht binnen 3 s eine Angriffsbewegung des Gegners (lunging oder eine Bewegung außer Stehen, Gehen, Ruhe)
		var offen := []        # [Bild, Meldung, gesehen]
		kf.meldung.connect(func(e):
			var a = kf.mars.find(e.actor) if e.actor != null else null
			var z = kf.mars.find(e.target) if e.target != null else null
			if a != null and z != null and a.side == "FOES" and z.side == "PARTY" and e.roll != null:
				offen.append([Engine.get_process_frames(), e, false]))
		var vor_anim := {}
		var fehl := []
		var gesamt := 0
		for i in 30 * 150:
			await process_frame
			if m.outcome != "ONGOING" and not kf.busy:
				break
			if manuell:
				if kf.ring_open:
					if ring_ab < 0:
						ring_ab = i + randi_range(5, 25)
					elif i >= ring_ab:
						kf._answer_ring([Mars.NONE, Mars.GOOD, Mars.PERFECT][randi() % 3])
						ring_ab = -1
				elif not kf.busy and not kf.playing and kf.beats.is_empty() and m.current().side == "PARTY":
					var tz: Array = m.targets(m.current())
					var ziel = tz[0] if not tz.is_empty() else null
					if ziel != null:
						kf.order(["attack", ziel.id])
					else:
						kf.go_on()
				elif not kf.busy and not kf.playing and kf.beats.is_empty():
					kf.go_on()
			for o in offen.duplicate():
				var af = kf.figures.get(o[1].actor)
				if af != null and (af.lunging() or (af.anim != null and af.anim.current_animation in ["Biss", "Sprungbiss", "Anspringen", "Angriff", "Rennen"])):
					offen.erase(o)
				elif Engine.get_process_frames() - o[0] > 90:
					fehl.append("%.1f s Angriff ohne Bewegung: „%s“" % [i / 30.0, o[1].text])
					offen.erase(o)
			for id in kf.figures:
				var f = kf.figures[id]
				if f.fighter.side != "PARTY" or f.anim == null:
					continue
				var nm: String = f.anim.current_animation
				if _treffer(nm) and not _treffer(String(vor_anim.get(id, ""))):
					gesamt += 1
					# die letzte Meldung, die diese Figur trifft (Ziel, Angreifer der Gegner), und die gerade gespielte
					var grund = null
					for k in range(meld.size() - 1, -1, -1):
						var e: Dictionary = meld[k][1]
						if e.target == id and e.actor != null and kf.mars.find(e.actor) != null and kf.mars.find(e.actor).side == "FOES":
							grund = meld[k]
							break
					var jetzt: Dictionary = meld[-1][1] if not meld.is_empty() else {}
					var alt: float = (Engine.get_process_frames() - grund[0]) / 30.0 if grund != null else 99.0
					var benutzt: bool = grund != null and grund[1].get("_1032", false)
					var eigen: bool = jetzt.get("actor") != null and kf.mars.find(jetzt.actor) != null and kf.mars.find(jetzt.actor).side == "PARTY"
					if grund == null or alt > 8.0 or benutzt or eigen:
						fehl.append("%.1f s %s %s: letzte Angriffsmeldung an ihr %s, gerade „%s“ (Handelnder %s)" % [i / 30.0, id, nm,
							("vor %.1f s „%s“%s" % [alt, grund[1].text, ", schon gezeigt" if benutzt else ""]) if grund != null else "keine",
							jetzt.get("text", ""), jetzt.get("actor", "")])
					if grund != null:
						grund[1]["_1032"] = true
				vor_anim[id] = nm
		if not fehl.is_empty():
			befunde += 1
		print("  Seed %d: Treffer-Bewegungen der Gruppe %d, ohne Angriff %d" % [s, gesamt, fehl.size()])
		for z in fehl:
			print("    " + z)
		p.queue_free()
		for i in 5:
			await process_frame
	print("1032 Treffer ohne Angriff: %s" % ("kein Befund" if befunde == 0 else "%d Läufe mit Befund" % befunde))
	quit(0 if befunde == 0 else 1)
