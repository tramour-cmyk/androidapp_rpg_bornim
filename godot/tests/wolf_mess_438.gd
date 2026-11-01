# 438, 439, 440 (Chef 31.10., 23:31–23:34, Film 403): Messung ohne Bild am echten Kampfort gegen das Wolfsrudel, Autopilot,
# je Bild (--fixed-fps 30): Gleiten (Rumpf bewegt sich, aber die Bewegung hat keine Schritte, oder schneller als ihre Schritte),
# Pfoten, die am Boden rutschen, Wölfe, die einander oder den Helden durchdringen, Tod (wie lange er fällt und liegt, bevor er
# verschwindet), Reihenfolge (rückt einer auf, bevor der Getroffene liegt; zuckt der Held getroffen, bevor die Schnauze da ist).
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/wolf_mess_438.gd   (Exit 0 = alle Grenzen gehalten, 1 sonst)
# Grenzen: GRENZEN unten; MESS_LOG=1 druckt je Bild jeden Wolf.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const DAUER_BILDER := 30 * 90
## Grenzen: Gleiten je Bild (m) ohne Schritte, Pfote rutscht am Boden (cm je Bewegung), Durchdringung (m), Tod: liegt mindestens (s)
const GLEIT_M := 0.012
const PFOTE_CM := 6.0
const DURCH_M := 0.05
const LIEGT_S := 1.0
const GLEIT_SUMME_M := 0.5     # je Bewegung über beide Kämpfe
const DURCH_BILDER := 30
const SCHRITTE := ["Gehen", "Rennen", "Zurück", "Sprungbiss", "Ausweichen zurück", "Ausweichen links", "Ausweichen"]
const PFOTEN := ["vpfoteL", "vpfoteR", "hpfoteL", "hpfoteR"]

var log_an := OS.get_environment("MESS_LOG") != ""
var vor := {}         # id -> [Ort, Gier]
var pf_vor := {}      # id+pfote -> Ort
var pf_h0 := {}
var pf_sum := {}      # id+anim -> cm
var gleiten := {}     # anim -> [Bilder, Summe m, größte m je Bild]
var durch := []       # [Bild, a, b, Tiefe]
var tod := {}         # id -> {fall, weg, tod_lang}
var befund := 0
var _letzt := ""
var heim := {}        # id -> letzter Platz (home)
var held_anim := {}   # id -> letzte Bewegung des Helden/Söldners
var reihe := []       # 439: [Bild, Text] Verstöße gegen Angriff, Treffer, Tod, Neuformation
var tote := {}        # k -> [Bild bis Ende des Liegens]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json"):
		print("Wolf 438: ohne Kaufwolf, nichts zu messen")
		quit(0)
		return
	for k in (OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(["FIGHTER", "CLERIC"])):
		var p = Probe.new()
		p.hero_cls = k
		p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
		p.foe = OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES"
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
		vor.clear()
		while n < DAUER_BILDER:
			await process_frame
			n += 1
			_bild(kf, n, k)
			if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
				break
			if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
				if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
					kf.go_on()
				else:
					var c = kf.mars.current()
					var ts: Array = kf.mars.targets(c)
					kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
		for i in 200:     # Nachlauf: wer zuletzt fiel, liegt und verschwindet
			await process_frame
			n += 1
			_bild(kf, n, k)
		print("Kampf %s: %s nach %d Bildern, Wolf %s" % [k, kf.mars.outcome, n, preload("res://kampf/figur.gd").ersatz()])
		kf.queue_free()
		p.queue_free()
		await process_frame
	_bilanz()
	quit(1 if befund > 0 else 0)


func _wolf(f) -> bool:
	return f.fighter.monster != null


func _bild(kf, n: int, k: String) -> void:
	var figs: Array = kf.figures.values()
	if log_an and String(kf.shown.get("text", "")) != _letzt:
		_letzt = String(kf.shown.get("text", ""))
		print("Meldung %d %s | cue %s schaden %s sprung %s" % [n, _letzt, kf.shown.get("cue"), kf.shown.get("damage"), str(kf.figures[kf.shown.actor].letzter_sprung) if kf.shown.get("actor") != null and kf.figures.has(kf.shown.actor) else "-"])
	# 439: Neuformation erst nach dem Tod; Treffer des Helden erst, wenn ein Wolf beißt
	for f in figs:
		var fid := "%s/%s" % [k, f.fighter.id]
		if _wolf(f) and f.dead_at >= 0 and not tote.has(fid):
			tote[fid] = n + int((f.sterbe_ms() + f.LIEGT_MS) / 1000.0 * 30.0) - 1 if f.has_method("sterbe_ms") else n
	for f in figs:
		var fid := "%s/%s" % [k, f.fighter.id]
		if _wolf(f) and not f.down:
			if heim.has(fid) and not heim[fid].is_equal_approx(f.home):
				for t in tote:
					if t.begins_with(k + "/") and n < tote[t]:
						reihe.append([n, "%s rückt auf, bevor %s gestorben ist und gelegen hat" % [fid, t]])
			heim[fid] = f.home
		elif not _wolf(f) and f.anim:
			var a := String(f.anim.current_animation)
			if a in ["Treffer", "Sturz"] and held_anim.get(fid, "") != a:
				var beisst := false
				for w in figs:
					if _wolf(w) and w.anim and String(w.anim.current_animation) in ["Biss", "Sprung", "Sprungbiss"]:
						beisst = true
				if not beisst:
					reihe.append([n, "%s zeigt %s, aber kein Wolf beißt (Meldung: %s)" % [fid, a, String(kf.shown.get("text", ""))]])
			held_anim[fid] = a
	for f in figs:
		if not _wolf(f) or not f.visible:
			continue
		var id := "%s/%s" % [k, f.fighter.id]
		var nm: String = f.anim.current_animation if f.anim else ""
		var p: Vector3 = f.global_position
		# Tod: ab die() bis unsichtbar
		if f.dead_at >= 0 and not tod.has(id):
			tod[id] = {"ab": n, "weg": -1, "tod_lang": f.anim.get_animation("Tod").length if f.anim and f.anim.has_animation("Tod") else 0.0}
		if vor.has(id) and not f.down:
			var d: float = Vector2(p.x - vor[id][0].x, p.z - vor[id][0].z).length()
			var dg: float = absf(wrapf(f.rotation.y - vor[id][1], -PI, PI))
			if d > GLEIT_M and not (nm in SCHRITTE):
				var g: Array = gleiten.get(nm, [0, 0.0, 0.0])
				gleiten[nm] = [g[0] + 1, g[1] + d, maxf(g[2], d)]
			elif nm in ["Gehen", "Rennen"] and f.has_method("_mps") and not f.weg.is_empty() and f.weg.has(nm):
				var soll: float = f._mps(nm) / 30.0 * absf(f.anim.get_playing_speed())
				if d > soll * 1.35 + 0.005:
					var g2: Array = gleiten.get(nm + " zu schnell", [0, 0.0, 0.0])
					gleiten[nm + " zu schnell"] = [g2[0] + 1, g2[1] + d - soll, maxf(g2[2], d - soll)]
			if dg > deg_to_rad(4.0) and not (nm in SCHRITTE) and d < 0.01 and not (f.halt != null and (f.halt.wirkt or f.halt.drehen)):
				var g3: Array = gleiten.get("dreht auf der Stelle in " + nm, [0, 0.0, 0.0])
				gleiten["dreht auf der Stelle in " + nm] = [g3[0] + 1, g3[1] + rad_to_deg(dg), maxf(g3[2], rad_to_deg(dg))]
		_pfoten(f, id, nm)
		vor[id] = [p, f.rotation.y]
		if log_an:
			print("Bild %d %s %s %.2f x%.2f Ort %.2f,%.2f Gier %.0f tween %s unten %s" % [n, id, nm, f.anim.current_animation_position if nm != "" else 0.0, f.anim.get_playing_speed() if f.anim else 0.0,
				p.x, p.z, rad_to_deg(f.rotation.y), f.tween != null and f.tween.is_running(), f.down])
	for id in tod:
		if tod[id].weg < 0 and id.begins_with(k + "/"):
			var fid: String = id.get_slice("/", 1)
			if kf.figures.has(fid) and not kf.figures[fid].visible:
				tod[id].weg = n
	# Durchdringung: Punkte entlang der Längsachse jedes Wolfs gegen den Umriss der anderen (stehend oder nicht)
	for a in figs:
		if not _wolf(a) or not a.visible or a.down:
			continue
		var box: AABB = a.footprint()
		var halb: float = a.own_r()
		for b in figs:
			if b == a or not b.visible or b.down:
				continue
			var tief := 0.0
			for i in 5:
				var z: float = lerpf(box.position.z + halb, box.end.z - halb, i / 4.0)
				var q: Vector3 = a.global_transform * Vector3(0, 0, z)
				tief = minf(tief, b.clearance(q) - halb)
			if tief < -DURCH_M:
				durch.append([n, "%s/%s" % [k, a.fighter.id], "%s/%s" % [k, b.fighter.id], -tief, a.anim.current_animation if a.anim else ""])


## Je Bild die langsamste der vier Pfoten (m, waagerecht): wer Schritte macht, hat immer eine Pfote fest am Boden (nahe 0); rutschen
## alle zugleich, gleitet das Tier. Summe je Bewegung gegen den Weg des Rumpfs.
func _pfoten(f, id: String, nm: String) -> void:
	var sk := f._find(f.model, "Skeleton3D") as Skeleton3D
	if sk == null or f.down:
		return
	var lo := INF
	var alle := true
	for pn in PFOTEN:
		var bi := sk.find_bone(pn)
		if bi < 0:
			alle = false
			continue
		var ohne: Vector3 = sk.global_transform * sk.get_bone_global_pose(bi).origin
		var p: Vector3 = f.halt.ort[pn] if f.halt != null and f.halt.wirkt and f.halt.ort.has(pn) else ohne
		if f.tritt != null and f.tritt.fest.has(pn):
			p = f.tritt.fest[pn]
		var key: String = id + pn
		if pf_vor.has(key):
			lo = minf(lo, Vector2(p.x - pf_vor[key].x, p.z - pf_vor[key].z).length())
			if log_an and OS.get_environment("MESS_PFOTE") == id:
				print("Pfote %s %s %s %.3f h %.3f" % [id, nm, pn, Vector2(p.x - pf_vor[key].x, p.z - pf_vor[key].z).length(), p.y - f.global_position.y])
		else:
			alle = false
		pf_vor[key] = p
	if alle and lo < INF:
		var e: Array = pf_sum.get(nm, [0, 0.0, 0.0])
		var rumpf: float = Vector2(f.global_position.x - vor[id][0].x, f.global_position.z - vor[id][0].z).length() if vor.has(id) else 0.0
		pf_sum[nm] = [e[0] + 1, e[1] + lo, e[2] + rumpf]


func _bilanz() -> void:
	print("— 438 Gleiten (Rumpf bewegt sich ohne Schritte; Bilder, Summe m, größte m je Bild)")
	for nm in gleiten:
		var g: Array = gleiten[nm]
		print("  %s: %d Bilder, %.2f, %.3f" % [nm if nm != "" else "(keine)", g[0], g[1], g[2]])
		if not nm.begins_with("dreht") and g[1] > GLEIT_SUMME_M:
			befund += 1
			print("    Befund: mehr als %.1f m" % GLEIT_SUMME_M)
		elif nm.begins_with("dreht") and g[2] > 9.0:
			befund += 1
			print("    Befund: mehr als 9° in einem Bild")
	print("— 438 Pfoten (je Bild die langsamste; Schritte: nahe 0)")
	for nm in pf_sum:
		var e: Array = pf_sum[nm]
		print("  %s: %d Bilder, langsamste Pfote zusammen %.0f cm bei %.0f cm Rumpfweg (%.0f %%)" % [nm, e[0], e[1] * 100.0, e[2] * 100.0, 100.0 * e[1] / maxf(e[2], 0.01)])
	print("— 438 Durchdringung über %.2f m: %d Bilder" % [DURCH_M, durch.size()])
	var gez := {}
	for d in durch:
		var k: String = d[1] + "→" + d[2] + " " + d[4]
		if not gez.has(k):
			gez[k] = [d[0], d[3], 0]
		gez[k][1] = maxf(gez[k][1], d[3])
		gez[k][2] += 1
	for k in gez:
		print("  %s: ab Bild %d, %d Bilder, tiefste %.2f m" % [k, gez[k][0], gez[k][2], gez[k][1]])
	var ww := 0
	for d in durch:
		if not d[2].ends_with("/hero") and not d[2].ends_with("/merc"):
			ww += 1
	var tief := 0.0
	for d in durch:
		if not d[2].ends_with("/hero") and not d[2].ends_with("/merc"):
			tief = maxf(tief, d[3])
	if ww > DURCH_BILDER or tief > 0.3:     # 438: Wolf in Wolf; Wolf am Helden (Biss) nur zur Kenntnis
		befund += 1
		print("    Befund: Wolf in Wolf %d Bilder (Grenze %d), tiefste %.2f m (Grenze 0,30)" % [ww, DURCH_BILDER, tief])
	print("— 439 Reihenfolge (Angriff, Treffer, Tod, Neuformation): %d Verstöße" % reihe.size())
	for r in reihe:
		print("  Bild %d: %s" % [r[0], r[1]])
	if not reihe.is_empty():
		befund += 1
	print("— 440 Tod (Sterbebewegung, dann verschwunden nach s)")
	for id in tod:
		var t: Dictionary = tod[id]
		var s: float = (t.weg - t.ab) / 30.0 if t.weg >= 0 else -1.0
		print("  %s: Sterbebewegung %.2f s, sichtbar %.2f s" % [id, t.tod_lang, s])
		if s < 0.0:
			print("    (Kampf vorher zu Ende)")
		elif s < t.tod_lang + LIEGT_S:
			befund += 1
			print("    Befund: verschwunden, bevor er gefallen ist und %.1f s gelegen hat" % LIEGT_S)
	print("Befunde: %d" % befund)
