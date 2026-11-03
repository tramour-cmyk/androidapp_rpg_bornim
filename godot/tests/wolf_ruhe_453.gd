# 453 (Chef 01.11., 11:05: „Was mir aber völlig fehlt, sind diese Ruheanimationen … ob die Wölfe atmen, ob die mal ab und zu
# scharren oder sich umblicken oder knurren“): Messung ohne Bild am echten Kampfort gegen das Wolfsrudel, Autopilot, je Bild
# (--fixed-fps 30): wie lange jeder Wolf ruht (steht daheim, kein Auftrag), was er dabei spielt, wie oft eine Ruhebewegung
# beginnt, wie viele verschiedene, die längste Spanne ohne Ruhebewegung, wie weit der Kopf in Ruhe wandert.
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/wolf_ruhe_453.gd   (Exit 0 = Grenzen gehalten, 1 sonst)
# Grenzen (DESIGN-STIL „Lebendige Welt“: keine Figur starr, mindestens drei Varianten): je Wolf in Ruhe höchstens STARR_S ohne
# Ruhebewegung, mindestens ARTEN verschiedene über den Kampf.
# r2 (Chef 01.11., 13:0x: „nicht im Gleichtakt … atmen kann man nicht aussetzen, d.h. Stillstand für mehrere Sekunden geht eigentlich
# nicht“): Stillstand am Körper gemessen (Flanke, Rücken, Kopf, Schnauze, Pfote, je Bild nach dem Atem): höchstens STILL_S, in denen
# sich kein Punkt um mehr als STILL_M bewegt; Ruhebewegungen zweier Wölfe beginnen nie im selben Augenblick (Abstand ≥ ZUGLEICH_S);
# jeder Wolf atmet im eigenen Takt (Takte paarweise ≥ TAKT_UNTERSCHIED_S auseinander).
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const DAUER_BILDER := 30 * 90
const STARR_S := 9.0
const ARTEN := 3
const STILL_S := 1.0
const STILL_M := 0.002
const ZUGLEICH_S := 0.5
const TAKT_UNTERSCHIED_S := 0.05
## Punkte am Körper: [Knochen, Versatz quer (m), Versatz oben (m)] in der Ruhelage des Skeletts
const PUNKTE := [["Wolf_Spine_02SHJnt", 0.16, -0.12], ["Wolf_Spine_03SHJnt", 0.0, 0.03], ["kopf", 0.0, 0.0],
	["Wolf_Head_JawEndSHJnt", 0.0, 0.0], ["vpfoteL", 0.0, 0.0]]
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
var still := {}           # id -> [Ankerpunkte, Bilder seit Anker, längste Bilder]
var beginne := []         # [Bild, id] jeder Ruhebewegung
var takte := {}           # id -> Atemtakt (s)
var punkte_da := {}       # id -> [Knochen, Ruhepunkt im Skelett]
var bild_nr := 0
var nach_atem := {}       # id -> Punkte nach der Atemschicht


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
		kf.queue_free()     # r2: der Kampfort hängt an der Wurzel; sonst ruhten die Wölfe des ersten Kampfs im zweiten weiter
		p.queue_free()
		await process_frame
	_bericht()


func _bild(kf, k: String) -> void:
	bild_nr += 1
	for f in kf.figures.values():
		if f == null or not is_instance_valid(f) or f.fighter == null or f.fighter.monster == null or f.down:
			continue
		var id: String = "%s/%s" % [k, f.fighter.id]
		if f.anim == null:
			continue
		_still(f, id)
		var a: String = f.anim.current_animation
		var ruht: bool = not (f.tween and f.tween.is_running()) and f.position.distance_to(f.home) < 0.15 and not a in KAMPF
		if a != vor.get(id, "") and not a in GRUND and not a in KAMPF and a != "":
			beginn[id] = beginn.get(id, {})
			beginn[id][a] = beginn[id].get(a, 0) + 1
			beginne.append([bild_nr, id, a])
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


## r2: Punkte am Körper je Bild (Welt, Meter); Stillstand = so lange kein Punkt weiter als STILL_M vom Stand am Anfang der Spanne
func _still(f, id: String) -> void:
	var sk: Skeleton3D = f._find(f.model, "Skeleton3D")
	if sk == null:
		return
	if f.atem != null:
		takte[id] = f.atem.takt
	if not punkte_da.has(id):
		var oben: Vector3 = (sk.global_basis.inverse() * Vector3.UP).normalized()
		var b1 := sk.find_bone("Wolf_Spine_01SHJnt")
		var b4 := sk.find_bone("Wolf_Spine_04SHJnt")
		if b1 < 0 or b4 < 0:
			return
		var laengs: Vector3 = (sk.get_bone_global_rest(b4).origin - sk.get_bone_global_rest(b1).origin).normalized()
		var quer: Vector3 = laengs.cross(oben).normalized()
		var je_m: float = 1.0 / maxf(sk.global_basis.get_scale().y, 1e-6)
		var l := []
		for pk in PUNKTE:
			var b := sk.find_bone(pk[0])
			if b >= 0:
				l.append([b, sk.get_bone_global_rest(b).origin + (quer * float(pk[1]) + oben * float(pk[2])) * je_m])
		punkte_da[id] = l
	# die Pose mit Atem gibt es nur während der Schicht (danach stellt das Skelett die Pose der Bewegung wieder her): darum im
	# Augenblick, in dem die Atemschicht fertig ist (modification_processed); ohne Schicht (ATEM_ALT=1) direkt
	if f.atem != null:
		if not nach_atem.has(id):
			nach_atem[id] = []
			f.atem.modification_processed.connect(func(): nach_atem[id] = _punkte(sk, id))
		if nach_atem[id].is_empty():
			return
	var jetzt: Array = nach_atem[id] if f.atem != null else _punkte(sk, id)
	var st: Array = still.get(id, [jetzt, 0, 0])
	var weit := 0.0
	for i in jetzt.size():
		weit = maxf(weit, (jetzt[i] - st[0][i]).length())
	if weit > STILL_M:
		st = [jetzt, 0, st[2]]
	else:
		st[1] += 1
		if st[1] > st[2] and st[1] > STILL_S * 30:
			print("Stillstand %s %.2f s bis Bild %d in %s" % [id, st[1] / 30.0, bild_nr, f.anim.current_animation])
		st[2] = maxi(st[2], st[1])
	still[id] = st


func _punkte(sk: Skeleton3D, id: String) -> Array:
	var l := []
	for pk in punkte_da[id]:
		var b: int = pk[0]
		l.append(sk.global_transform * (sk.get_bone_global_pose(b) * (sk.get_bone_global_rest(b).affine_inverse() * pk[1])))
	return l


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
	# r2: Stillstand am Körper, gleichzeitige Ruhebewegungen, gleicher Atemtakt
	for id in still:
		var s_: float = still[id][2] / 30.0
		print("— %s: längster Stillstand am Körper %.2f s, Atemtakt %.2f s" % [id, s_, takte.get(id, 0.0)])
		if s_ > STILL_S:
			fehler += 1
	var zugleich := 0
	var kleinster := 999.0
	for i in beginne.size():
		for j in range(i + 1, beginne.size()):
			if beginne[i][1] == beginne[j][1] or beginne[i][1].get_slice("/", 0) != beginne[j][1].get_slice("/", 0):
				continue
			var d: float = absf(beginne[j][0] - beginne[i][0]) / 30.0
			kleinster = minf(kleinster, d)
			if d < ZUGLEICH_S:
				zugleich += 1
				print("zugleich: %s und %s, %.2f s" % [beginne[i], beginne[j], d])
	var gleich := 0
	var ids := takte.keys()
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			if ids[i].get_slice("/", 0) == ids[j].get_slice("/", 0) and absf(takte[ids[i]] - takte[ids[j]]) < TAKT_UNTERSCHIED_S:
				gleich += 1
	print("Wolf 453 r2: %d Ruhebewegungen, zwei Wölfe zugleich (unter %.1f s) %d, kleinster Abstand %.2f s; gleicher Atemtakt %d Paare; Atem an %d von %d Wölfen" % [
		beginne.size(), ZUGLEICH_S, zugleich, kleinster, gleich, takte.size(), still.size()])
	fehler += zugleich + gleich + (still.size() - takte.size())
	print("Wolf 453: %d Wölfe gemessen, %d Fehler (starr über %.0f s, unter %d Arten, Stillstand über %.1f s, Gleichtakt, ohne Atem)" % [ruhe_bilder.size(), fehler, STARR_S, ARTEN, STILL_S])
	quit(1 if fehler else 0)
