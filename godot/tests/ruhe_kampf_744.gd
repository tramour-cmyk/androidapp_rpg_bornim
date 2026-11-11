# 744 A (Chef 09.11., 11:18: „mal verweilen, eine Ruheanimation haben“; 11:22 „744 A“: ein Bewegungsbaustein für alle Figuren auf
# Karte und Kampfort): Messung ohne Bild am echten Kampfort, Autopilot, je Gegnergruppe: wie lange jedes Monster ruht (daheim, kein
# Auftrag), welche Ruhebewegungen es dabei beginnt und die längste Spanne in Ruhe ohne eine. Wie wolf_ruhe_453, für jede Art.
# Run: GEGNER=RATS,SPINNE,… godot --headless --path godot --fixed-fps 30 -s res://tests/ruhe_kampf_744.gd   (Exit 0 = Grenzen gehalten)
# Grenze (DESIGN-STIL C2/C4, Lebendige Welt): wer eine Ruhebewegung hat, ruht höchstens STARR_S ohne eine; zwei Monster beginnen nie
# im selben Augenblick (C3, Abstand ≥ ZUGLEICH_S). Wer keine eigene hat (Goblins, Skelette …), wird nur gezählt.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const DAUER_BILDER := 30 * 75
const STARR_S := 9.0
const ZUGLEICH_S := 0.5
const GRUND := ["Stehen", "Hocke", "Kampfstehen", "SS_IdleCombat"]
const KAMPF := ["Gehen", "Rennen", "Biss", "Hauer", "Hieb", "Hieb2", "Sprung", "Sprungbiss", "Ansturm", "Treffer", "Ausweichen",
	"Ausweichen links", "Tod", "Heulen", "Drohen", "Netzwurf", "Bisskette", "Spucken", "Auferstehen", "Kriechen"]
const GRUPPEN := ["WOLVES", "RATS", "BATS", "SPINNE", "BOARS", "LEECHES", "SLUGS", "WIEDERGAENGER3", "GRABHUNDE", "SKELETONS", "GOBLINS"]

var ruhe := {}            # id -> Bilder in Ruhe
var beginn := {}          # id -> {Ruhebewegung: Anzahl}
var starr := {}           # id -> [Ruhebilder seit der letzten Ruhebewegung, längste]
var vor := {}             # id -> letzte Bewegung
var hat := {}             # id -> Ruhebewegungen, die das Modell kennt
var beginne := []         # [Bild, Gruppe, id]
var bild_nr := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	var gruppen: PackedStringArray = OS.get_environment("GEGNER").split(",") if OS.get_environment("GEGNER") != "" else PackedStringArray(GRUPPEN)
	for g in gruppen:
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = g
		root.add_child(p)
		await process_frame
		p._start(int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7)
		for i in 4:
			await process_frame
		var kf = p.fight
		if kf == null:
			print("RUHE744 %s: kein Kampf" % g)
			p.queue_free()
			continue
		kf.mars.find("merc").auto = true
		kf.mars.set_autopilot(true)
		if not kf.busy:
			kf.go_on()
		var n := 0
		while n < DAUER_BILDER:
			await process_frame
			n += 1
			_bild(kf, g)
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				kf.go_on()
		kf.queue_free()
		p.queue_free()
		await process_frame
	_bericht()


func _bild(kf, g: String) -> void:
	bild_nr += 1
	for f in kf.figures.values():
		if f == null or not is_instance_valid(f) or f.fighter == null or f.fighter.monster == null or f.down or f.anim == null:
			continue
		var id: String = "%s/%s" % [g, f.fighter.id]
		if not hat.has(id):
			var l := []
			for a in f.anim.get_animation_list():
				if not a in GRUND and not a in KAMPF and not String(a).begins_with("RESET"):
					l.append(String(a))
			hat[id] = l
		var a: String = f.anim.current_animation
		var ruht: bool = not (f.tween and f.tween.is_running()) and f.position.distance_to(f.home) < 0.15 and not a in KAMPF
		if a != vor.get(id, "") and not a in GRUND and not a in KAMPF and a != "":
			beginn[id] = beginn.get(id, {})
			beginn[id][a] = beginn[id].get(a, 0) + 1
			beginne.append([bild_nr, g, id])
			starr[id] = [0, starr.get(id, [0, 0])[1]]
		vor[id] = a
		if not ruht:
			continue
		ruhe[id] = ruhe.get(id, 0) + 1
		var s: Array = starr.get(id, [0, 0])
		if a in GRUND:
			s[0] += 1
			s[1] = maxi(s[1], s[0])
		starr[id] = s


func _bericht() -> void:
	var fehler := 0
	for id in ruhe:
		var st: float = starr.get(id, [0, 0])[1] / 30.0
		var b: Dictionary = beginn.get(id, {})
		var n := 0
		for k in b:
			n += int(b[k])
		var ok := true
		if not hat[id].is_empty() and ruhe[id] > STARR_S * 30 * 2 and st > STARR_S:
			ok = false
			fehler += 1
		print("RUHE744 %s %s: Ruhe %.1f s, Ruhebewegungen %d %s, längste ohne %.1f s, Modell kennt %s" % ["ok" if ok else "FEHLER", id,
			ruhe[id] / 30.0, n, b, st, hat[id]])
	var zugleich := 0
	for i in beginne.size():
		for j in range(i + 1, beginne.size()):
			if beginne[i][1] != beginne[j][1] or beginne[i][2] == beginne[j][2]:
				continue
			if absf(beginne[j][0] - beginne[i][0]) / 30.0 < ZUGLEICH_S:
				zugleich += 1
	print("RUHE744 zugleich begonnen (< %.1f s): %d" % [ZUGLEICH_S, zugleich])
	if zugleich > 0:
		fehler += 1
	print("RUHE744 %s" % ("0 Fehler" if fehler == 0 else "%d Fehler" % fehler))
	quit(0 if fehler == 0 else 1)
