extends SceneTree
# 2024 (Chef 25.11., 13:45, Sokrates 13:48/13:55 A): beim Prankenhieb zuckt und blutet der Held im Augenblick des Aufschlags der Pranke.
# Echter Kampfort gegen Krogg, jeder Gegnerzug ein Prankenhieb (Mars.test_gegnerzug „paw“), Ring gut. Je Prankenhieb, der trifft:
#  Aufschlag = erstes Bild, in dem Kroggs linke Pranke (hand_l, gezeichnet) bis auf NAH_M an ihren kleinsten Abstand zum Getroffenen
#  herankommt (waagerecht; Chef 13:45: das erste Ankommen der Pranke ist der Schlag, nicht das Weiterschwingen);
#  Reaktion = Bild, in dem der Getroffene zuckt (Figur.hurt_at gesetzt; Blut und Treffer-Effekt kommen im selben Bild, kampfort lands);
#  sichtbar = erstes Bild danach, in dem sein Kopf sich SICHTBAR_M bewegt hat.
# Grenze: Reaktion und sichtbares Zucken höchstens GRENZE_S nach dem Aufschlag und nicht davor. Ausgabe „AUFSCHLAG2024 n Treffer, k zu spät/früh“.
# Nur mit Kroggs Modell (kampf/daten); ohne: übersprungen. Aufruf im Ordner godot: --headless --fixed-fps 30 -s res://tests/aufschlag_2024.gd

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const FPS := 30.0
const GRENZE_S := 0.1
const NAH_M := 0.1
const SICHTBAR_M := 0.02

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
	var t_sicht := {}
	var kopf0 := {}
	var ring_seit := -1
	while n < int(FPS) * 150 and treffer < 3:
		await process_frame
		n += 1
		var t := Engine.get_process_frames() / FPS
		if Mars.test_gegnerzug == "":
			Mars.test_gegnerzug = "paw"
		var hieb: bool = String(krogg.anim.current_animation) == "Prankenhieb"
		if hieb and not im_hieb:
			bahn.clear()
			t_reakt.clear()
			t_sicht.clear()
			kopf0.clear()
		if hieb:
			var pw: Vector3 = sk.global_transform * sk.get_bone_global_pose(hl).origin
			for f in andere:
				var d := Vector2(pw.x - f.global_position.x, pw.z - f.global_position.z).length()
				if not bahn.has(f):
					bahn[f] = []
				(bahn[f] as Array).append([d, t])
		for f in andere:
			if f.hurt_at != hurt0[f]:
				hurt0[f] = f.hurt_at
				if not t_reakt.has(f):     # die erste Reaktion zählt (spätere: Zittern derselben Meldung)
					t_reakt[f] = t
					kopf0[f] = _kopf(f)
			elif kopf0.has(f) and not t_sicht.has(f) and kopf0[f] != null and _kopf(f) != null and (_kopf(f) as Vector3).distance_to(kopf0[f]) > SICHTBAR_M:
				t_sicht[f] = t
		if im_hieb and not hieb:
			for f in t_reakt:
				if bahn.has(f):
					treffer += 1
					var b: Array = bahn[f]
					var dmin: float = b.map(func(x): return x[0]).min()
					var ta := -1.0
					for x in b:
						if float(x[0]) <= dmin + NAH_M:
							ta = float(x[1])
							break
					var dt: float = float(t_reakt[f]) - ta
					var ds: float = float(t_sicht.get(f, 99.0)) - ta
					var ok := dt >= -0.5 / FPS and dt <= GRENZE_S and ds <= GRENZE_S + 0.01
					schief += 0 if ok else 1
					print("%s Prankenhieb an %s: Aufschlag %.2f s (Pranke %.2f m), Reaktion %.2f s (%+.2f s), Kopf bewegt %.2f s (%+.2f s)" % [
						"gut" if ok else "FEHLER", f.fighter.id, ta, dmin, t_reakt[f], dt, float(t_sicht.get(f, -1.0)), ds])
		im_hieb = hieb or (im_hieb and n % 1 == 0 and String(krogg.anim.current_animation) == "Prankenhieb")
		if not hieb and im_hieb:
			im_hieb = false
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


## Kopf des Getroffenen in der Welt (gezeichnet), null ohne Gerüst
func _kopf(f):
	var sk := f._find(f.model, "Skeleton3D") as Skeleton3D if f.model != null else null
	if sk == null:
		return null
	for nm in ["Head", "head", "Kopf"]:
		var b := sk.find_bone(nm)
		if b >= 0:
			return sk.global_transform * sk.get_bone_global_pose(b).origin
	return null
