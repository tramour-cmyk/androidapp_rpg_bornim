extends SceneTree
# 2024 (Chef 25.11., 13:45, Sokrates 13:48/13:55 A): beim Prankenhieb zuckt und blutet der Held im Augenblick des Aufschlags der Pranke.
# Echter Kampfort gegen Krogg, jeder Gegnerzug ein Prankenhieb (Mars.test_gegnerzug „paw“), Ring gut. Je Prankenhieb, der trifft:
#  Aufschlag = Bild, in dem Kroggs linke Pranke (hand_l, gezeichnet) dem Getroffenen am nächsten ist (waagerecht);
#  Reaktion = Bild, in dem der Getroffene zuckt (Figur.hurt_at gesetzt; Blut und Treffer-Effekt kommen im selben Bild, kampfort lands).
# Grenze: Reaktion höchstens GRENZE_S nach dem Aufschlag und nicht davor. Ausgabe „AUFSCHLAG2024 n Treffer, k zu spät/früh“.
# Nur mit Kroggs Modell (kampf/daten); ohne: übersprungen. Aufruf im Ordner godot: --headless --fixed-fps 30 -s res://tests/aufschlag_2024.gd

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const FPS := 30.0
const GRENZE_S := 0.1

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	seed(int(OS.get_environment("SEED")) if OS.has_environment("SEED") else 7)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "KROGG"
	root.add_child(p)
	await process_frame
	p._start(2024)
	for i in 4:
		await process_frame
	var kf = p.fight
	kf.mars.find("merc").auto = true
	kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
	var krogg = null
	for f in kf.figures.values():
		if f.fighter.monster != null and String(f.fighter.monster.id) == "bugbear":
			krogg = f
	if krogg == null or krogg.anim == null or not krogg.anim.has_animation("Prankenhieb"):
		print("übersprungen: Krogg ohne Prankenhieb (kampf/daten aus krogg_gestalt.py)")
		quit(0)
		return
	var sk: Skeleton3D = krogg._find(krogg.model, "Skeleton3D")
	var hl := sk.find_bone("hand_l")
	var andere: Array = kf.figures.values().filter(func(f): return f != krogg)
	var hurt0 := {}
	for f in andere:
		hurt0[f] = f.hurt_at
	Mars.test_gegnerzug = "paw"
	var n := 0
	var im_hieb := false
	var bahn := {}          # Figur -> [kleinster Abstand, Zeit]
	var treffer := 0
	var schief := 0
	var auf := []           # Aufschläge dieses Hiebs je Figur
	var t_reakt := {}
	var ring_seit := -1
	while n < int(FPS) * 150 and treffer < 3:
		await process_frame
		n += 1
		var t := n / FPS
		if Mars.test_gegnerzug == "":
			Mars.test_gegnerzug = "paw"
		var hieb: bool = String(krogg.anim.current_animation) == "Prankenhieb"
		if hieb and not im_hieb:
			bahn.clear()
			t_reakt.clear()
		if hieb:
			var pw: Vector3 = sk.global_transform * sk.get_bone_global_pose(hl).origin
			for f in andere:
				var d := Vector2(pw.x - f.global_position.x, pw.z - f.global_position.z).length()
				if not bahn.has(f) or d < float(bahn[f][0]):
					bahn[f] = [d, t]
		for f in andere:
			if f.hurt_at != hurt0[f]:
				hurt0[f] = f.hurt_at
				t_reakt[f] = t
		if im_hieb and not hieb:
			for f in t_reakt:
				if bahn.has(f):
					treffer += 1
					var dt: float = float(t_reakt[f]) - float(bahn[f][1])
					var ok := dt >= -0.5 / FPS and dt <= GRENZE_S
					schief += 0 if ok else 1
					print("%s Prankenhieb an %s: Aufschlag %.2f s (Pranke %.2f m), Reaktion %.2f s, %+.2f s" % [
						"gut" if ok else "FEHLER", f.fighter.id, bahn[f][1], bahn[f][0], t_reakt[f], dt])
		im_hieb = hieb
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				var ts: Array = kf.mars.targets(kf.mars.current())
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		if kf.ring_open:
			ring_seit = n if ring_seit < 0 else ring_seit
			if n - ring_seit >= int(kf.RING_MS * kf.ring_faktor / 1000.0 * FPS):
				kf._answer_ring(Mars.GOOD)
		else:
			ring_seit = -1
	Mars.test_gegnerzug = ""
	fehler = schief + (1 if treffer == 0 else 0)
	print("AUFSCHLAG2024 %d Treffer, %d zu spät/früh, %s" % [treffer, schief, "gut" if fehler == 0 else "%d FEHLER" % fehler])
	quit(1 if fehler > 0 else 0)
