# 760 (Chef 09.11., 14:00; wiederholt 12.11., 20:09 und 15.11., 12:57: „ich werde angesprungen, aber sehe nichts davon“): der Wolf
# springt bei „Anspringen“ wirklich. Echter Kampfort gegen das Rudel, jede Ansage ein Anspringen (ZUG=pounce wie der Reiter Test).
# Geprüft je Bild an jedem Wolf mit gebautem Sprung (sprung.gd; Kaufwolf ohne Sprungbiss der Quelle):
#  - es gibt Sprünge, jeder hebt ab (Scheitel mindestens 0,15 m) und legt im Flug Weg zurück (mindestens 0,5 m);
#  - mindestens einer springt aus dem Stand (Absprung höchstens 0,2 m von dort, wo er zuletzt stand: daheim oder abgesetzt, 717 C);
#  - der Flug endet am Boden, Rumpf waagerecht (auch wenn er im Flug fällt);
#  - nach dem Sprung steht er binnen 10 s wieder auf dem eigenen Platz (höchstens 0,15 m daneben).
# Ohne Tier mit Wurzelweg (kampf/daten ohne Kaufwolf): übersprungen (exit 0).
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/sprung_760.gd   (exit 0 = alles erfüllt)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const FPS := 30.0
const RUNDEN := 4
## so lange nach dem Aufkommen steht er spätestens wieder auf seinem Platz (s)
const HEIM_S := 10.0

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _gut(ok: bool, text: String) -> void:
	print(("gut " if ok else "FEHLER ") + text)
	if not ok:
		fehler += 1


func _lauf() -> void:
	seed(760)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	Mars.test_gegnerzug = "pounce"     # schon die erste Ansage: der Sprung vom eigenen Platz
	p._start(760)
	for i in 4:
		await process_frame
	var kf = p.fight
	kf.mars.find("merc").auto = true
	kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
	var woelfe := []
	for f in kf.figures.values():
		if f.fighter.monster != null and f.weg.has("Gehen") and f.anim != null and f.anim.has_animation("Biss"):
			woelfe.append(f)
	if woelfe.is_empty():
		print("übersprungen: kein Tier mit Wurzelweg und Biss (kampf/daten ohne Kaufwolf)")
		quit(0)
		return
	while kf.verhuellt:
		await process_frame
	var n := 0
	var wahlen := 0
	var ring_seit := -1
	var flug := {}          # Figur -> {von, hoch, weit, platz}: der laufende Sprung
	var spruenge := []      # fertige Sprünge [Wolf, Scheitel, Weite, Absprung vom Platz, Zeit]
	var schief := 0         # Bilder außerhalb des Flugs über dem Boden oder geneigt
	var ruhe := {}          # Figur -> Ort, an dem sie zuletzt stand
	var offen := {}         # Figur -> Zeit des letzten Sprungs, bis sie wieder daheim stand
	var nicht_heim := 0
	Mars.test_gegnerzug = "pounce"
	while n < int(FPS) * 240:
		await process_frame
		n += 1
		if Mars.test_gegnerzug == "":
			Mars.test_gegnerzug = "pounce"
		var t := n / FPS
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		for f in woelfe:
			if not is_instance_valid(f):
				continue
			var cur := String(f.anim.current_animation)
			var fliegt: bool = f.sprung_gebaut and cur == "Sprungbiss" and not f.down
			if fliegt:
				if not flug.has(f):
					var r: Vector3 = ruhe.get(f, f.home)
					flug[f] = {"von": f.position, "hoch": 0.0, "weit": 0.0, "platz": Vector2(f.position.x - r.x, f.position.z - r.z).length()}
					if OS.get_environment("SCHAU_760") != "":
						print("760 %.2f %s springt ab %s (Platz %s)" % [t, f.fighter.id, f.position.snapped(Vector3.ONE * 0.01), f.home.snapped(Vector3.ONE * 0.01)])
				var e: Dictionary = flug[f]
				# Einzelbilder für die eigene Prüfung (BILD_760=<Ordner>, nur mit Bild): geduckt, im Scheitel, im Aufkommen
				var ordner := OS.get_environment("BILD_760")
				if ordner != "" and DisplayServer.get_name() != "headless":
					var x: float = f.anim.current_animation_position
					for st in [["duck", 0.2, 0.26], ["flug", 0.45, 0.56], ["biss", 0.74, 0.8]]:
						var key := "%s-%d" % [st[0], spruenge.size()]
						if x >= st[1] and x < st[2] and not has_meta(key):
							set_meta(key, true)
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png("%s/760-%s.png" % [ordner, key])
							print("760 Bild %s bei %.2f s" % [key, t])
				e.hoch = maxf(e.hoch, f.position.y - (e.von as Vector3).y)
				e.weit = maxf(e.weit, Vector2(f.position.x - e.von.x, f.position.z - e.von.z).length())
			else:
				if not f.unterwegs() and not f.down:
					ruhe[f] = f.position     # wo er zuletzt stand (daheim oder nach einem Biss abgesetzt, 717 C)
				if flug.has(f):
					var e: Dictionary = flug[f]
					spruenge.append([f.fighter.id, e.hoch, e.weit, e.platz, t])
					flug.erase(f)
					offen[f] = t
					if OS.get_environment("SCHAU_760") != "":
						print("760 %.2f %s gelandet: Scheitel %.2f m, Weite %.2f m" % [t, f.fighter.id, e.hoch, e.weit])
				if not f.down and (absf(f.position.y - f.home.y) > 0.005 or absf(f.model.rotation.x) > 0.001):
					schief += 1
				if offen.has(f) and Vector2(f.position.x - f.home.x, f.position.z - f.home.z).length() < 0.15:
					offen.erase(f)
				# nach HEIM_S noch nicht daheim (der Heimweg schließt an den Biss an)
				if offen.has(f) and t - float(offen[f]) > HEIM_S:
					nicht_heim += 1
					print("760 %.2f %s nach %.0f s nicht daheim: steht %s, Platz %s, gang „%s“" % [t, f.fighter.id, HEIM_S, f.position.snapped(Vector3.ONE * 0.01), f.home.snapped(Vector3.ONE * 0.01), f.gang])
					offen.erase(f)
				if f.down:
					offen.erase(f)
		# der Spieler: wartet (die Wölfe sollen springen, nicht fallen), Ring nach RING_MS gut
		if kf.ring_open:
			if ring_seit < 0:
				ring_seit = n
			elif n - ring_seit >= int(kf.RING_MS / 1000.0 * FPS):
				kf._answer_ring(Mars.GOOD)
		else:
			ring_seit = -1
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				if wahlen >= RUNDEN:
					break
				wahlen += 1
				kf.order(["wait"])
	for f in offen:
		if is_instance_valid(f) and not f.down and not f.unterwegs():
			nicht_heim += 1
			print("760 Ende: %s steht %s, Platz %s, gang „%s“" % [f.fighter.id, f.position.snapped(Vector3.ONE * 0.01), f.home.snapped(Vector3.ONE * 0.01), f.gang])
	var flach := 0
	var kurz := 0
	var stand := 0
	for s in spruenge:
		if s[1] < 0.15:
			flach += 1
		if s[2] < 0.5:
			kurz += 1
		if s[3] <= 0.2:
			stand += 1
	_gut(not spruenge.is_empty(), "Sprünge: %d" % spruenge.size())
	_gut(flach == 0, "jeder Sprung hebt ab (Scheitel ab 0,15 m): %d zu flach; %s" % [flach, spruenge.map(func(s): return "%.2f" % s[1])])
	_gut(kurz == 0, "jeder Sprung legt Weg zurück (ab 0,5 m): %d zu kurz; %s" % [kurz, spruenge.map(func(s): return "%.2f" % s[2])])
	_gut(stand > 0, "aus dem Stand, ohne Anlauf: %d von %d" % [stand, spruenge.size()])
	_gut(schief == 0, "außerhalb des Flugs am Boden und waagerecht (%d Bilder nicht)" % schief)
	_gut(nicht_heim == 0, "nach dem Sprung zurück auf dem eigenen Platz (%d nicht)" % nicht_heim)
	print("SPRUNG760 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler else 0)
