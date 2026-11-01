# 453 (Chef 01.11., 11:05: „Was mir aber völlig fehlt, sind diese Ruheanimationen … ob die Wölfe atmen, ob die mal ab und zu
# scharren oder sich umblicken oder knurren“): Messung ohne Bild am echten Kampfort gegen das Wolfsrudel, Autopilot, je Bild
# (--fixed-fps 30): wie lange jeder Wolf ruht (steht daheim, kein Auftrag), was er dabei spielt, wie oft eine Ruhebewegung
# beginnt, wie viele verschiedene, die längste Spanne ohne Ruhebewegung, wie weit der Kopf in Ruhe wandert.
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/wolf_ruhe_453.gd   (Exit 0 = Grenzen gehalten, 1 sonst)
# Grenzen (DESIGN-STIL „Lebendige Welt“: keine Figur starr, mindestens drei Varianten): je Wolf in Ruhe höchstens STARR_S ohne
# Ruhebewegung, mindestens ARTEN verschiedene über den Kampf.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const DAUER_BILDER := 30 * 90
const STARR_S := 9.0
const ARTEN := 3
## Ruhebewegungen (alles außer der Grundschleife und den Kampfbewegungen)
const GRUND := ["Stehen", "Hocke", "Kampfstehen"]
const KAMPF := ["Gehen", "Rennen", "Biss", "Sprung", "Sprungbiss", "Treffer", "Ausweichen", "Tod", "Heulen"]

var ruhe_bilder := {}     # id -> Bilder in Ruhe
var anim_bilder := {}     # id -> {Bewegung: Bilder in Ruhe}
var beginn := {}          # id -> {Ruhebewegung: Anzahl}
var starr := {}           # id -> [Bilder seit der letzten Ruhebewegung (nur Ruhebilder), längste]
var vor := {}             # id -> letzte Bewegung
var kopf := {}            # id -> [kleinste, größte Drehung des Halses in Ruhe]
var laute := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	if not FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json"):
		print("Wolf 453: ohne Kaufwolf, nichts zu messen")
		quit(0)
		return
	for k in (OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(["FIGHTER", "CLERIC"])):
		var p = Probe.new()
		p.hero_cls = k
		p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
		p.foe = "WOLVES"
		root.add_child(p)
		await process_frame
		p._start(int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7)
		for i in 4:
			await process_frame
		var kf = p.fight
		if kf == null:
			print("kein Kampf")
			quit(1)
			return
		kf.mars.find("merc").auto = true
		kf.mars.set_autopilot(true)
		if not kf.busy:
			kf.go_on()
		var n := 0
		while n < DAUER_BILDER:
			await process_frame
			n += 1
			_bild(kf, k)
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				kf.go_on()
		p.queue_free()
		await process_frame
	_bericht()


func _bild(kf, k: String) -> void:
	for f in kf.figures.values():
		if f == null or not is_instance_valid(f) or f.fighter == null or f.fighter.monster == null or f.down:
			continue
		var id: String = "%s/%s" % [k, f.fighter.id]
		if f.anim == null:
			continue
		var a: String = f.anim.current_animation
		var ruht: bool = not (f.tween and f.tween.is_running()) and f.position.distance_to(f.home) < 0.15 and not a in KAMPF
		if a != vor.get(id, "") and not a in GRUND and not a in KAMPF and a != "":
			beginn[id] = beginn.get(id, {})
			beginn[id][a] = beginn[id].get(a, 0) + 1
			starr[id] = [0, starr.get(id, [0, 0])[1]]
		vor[id] = a
		if not ruht:
			continue
		ruhe_bilder[id] = ruhe_bilder.get(id, 0) + 1
		anim_bilder[id] = anim_bilder.get(id, {})
		anim_bilder[id][a] = anim_bilder[id].get(a, 0) + 1
		var s: Array = starr.get(id, [0, 0])
		if a in GRUND:
			s[0] += 1
			s[1] = maxi(s[1], s[0])
		starr[id] = s
		if f.neck:
			var kk: Array = kopf.get(id, [999.0, -999.0])
			kopf[id] = [minf(kk[0], f.neck.turned), maxf(kk[1], f.neck.turned)]


func _bericht() -> void:
	var fehler := 0
	for id in ruhe_bilder:
		var arten: Dictionary = beginn.get(id, {})
		var st: float = starr.get(id, [0, 0])[1] / 30.0
		var kk: Array = kopf.get(id, [0.0, 0.0])
		print("— %s: Ruhe %.1f s, Bewegungen %s, Ruhebewegungen %s, längste starr %.1f s, Hals %.0f..%.0f°" % [id,
			ruhe_bilder[id] / 30.0, anim_bilder.get(id, {}), arten, st, kk[0], kk[1]])
		if ruhe_bilder[id] > STARR_S * 30 * 2 and (st > STARR_S or arten.size() < ARTEN):
			fehler += 1
	print("Wolf 453: %d Wölfe gemessen, %d mit zu wenig Leben (starr über %.0f s oder unter %d Arten)" % [ruhe_bilder.size(), fehler, STARR_S, ARTEN])
	quit(1 if fehler else 0)
