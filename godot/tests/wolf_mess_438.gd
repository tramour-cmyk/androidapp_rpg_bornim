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
## 438 Prüfer Film 08:18: Drehsprünge in jeder Bewegung, Kopf im Helden, Würfelzeile vor dem Treffer
const DREH_BILD_GRAD := 16.0     # TURN_DPS 450°/s bei 30 Bildern: 15° je Bild
# 988 (Lauf 369, CLERIC ohne Schild nach BRS, Bild 281 und 588: Kiefer beim Biss −0,040 m an Becken–Brust): seit 709 (Chef 08.11.,
# 21:36: Angriffe treffen) fasst die Kieferkapsel (Jaw 0,04 m) BISS_TIEF (0,01 m) in den Körper; die Grenze −0,04 (01.11., vor 709)
# verbot jede Berührung, mit Schild fiel das nie auf (der Biss trifft dort den Schild). Jetzt die Knochen des Kopfs so weit draußen,
# wie die Kieferkapsel abzüglich BISS_TIEF reicht; tiefer misst weiter r2 (KOERPER_M, Kapsel gegen Kapsel)
const KOPF_M := -0.03     # = figur.gd BISS_TIEF − Kieferkapsel 0,04
const WOLF_KOPF := ["kopf", "Wolf_Head_TopSHJnt", "Wolf_Head_JawEndSHJnt"]
const KOERPER := [["pelvis", "spine_03", 0.17], ["spine_03", "neck_01", 0.14], ["neck_01", "Head", 0.08], ["Head", "Head", 0.11],
	["thigh_l", "calf_l", 0.08], ["thigh_r", "calf_r", 0.08]]
const WW_M := 0.10
var dreh_max := {}     # anim -> [Bilder über DREH_BILD_GRAD, größte Grad]
var kopf := {}         # wolf→held -> [Bilder, tiefste m, erstes Bild]
var roll_vor := 0
var wurf := []         # [Bild, Ziel, Schaden]
var hurt_vor := {}
var hurt_ab := {}      # id -> [Bilder, an denen der Getroffene zu zittern beginnt]
## 438 Prüfer Film r2: ganzer Körper (Kapseln um die Knochen, Schild, Klinge), Zeilen zur Bewegung, Stillstand, Bildrand, Sprünge
const KOERPER_M := 0.03
var koerper := {}      # wolf→mensch Teil -> [Bilder, tiefste m, erstes Bild, Bewegung]
var klinge := []       # [Bild, Mensch, Wolf, Tiefe]
var klinge_koerper := []   # 438: [Bild, Wolf, Schlüssel, Tiefe, Bewegung] Klinge im Wolf, Treffer erst in der Bilanz geprüft
var zeilen := []       # [Bild, Text]
var zeilen_n := 0
var anim_ab := {}      # id -> {Bewegung: [Bilder, an denen sie beginnt]}
var anim_vor := {}
var tief_y := {}       # Sterbender -> [[Bild, Höhe des Rumpfs]]
var still := 0
var diag_n := 0              # 562: Zeilen „438 DIAG“
var diag_kopf_n := 0         # 988: Zeilen „438 DIAG Kopf“
var diag_rand_n := 0         # 988: Zeilen „438 DIAG Rand“
var gleit_n := 0             # 900: Zeilen „438 GLEIT“
var still_spannen := []    # [ab Bild, Bilder, Zeile]
var still_ab := -1
var lage_vor := {}
var rand := {}         # id -> [Bilder, erstes Bild, größte px]
var ui_vor := {}
var ui_sprung := {}    # Ansage/Balken -> [Bilder, erstes Bild, größte px]
var biss_bild := {}    # Wolf -> letztes Bild mit Biss
var wurf_ohne := []
var groesse_gedruckt := false
const RUHE := ["", "Stehen", "Kampfstehen", "Hocke", "Pro_Sword_Idle", "Ruhelage"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# 438 r2: Bildrand und Ansagen im Handyformat (headless war das Fenster 2340 × 2340)
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	if not FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json") and OS.get_environment("EIGENER_WOLF") == "":
		print("Wolf 438: ohne Kaufwolf, nichts zu messen")
		quit(0)
		return
	for k in (OS.get_environment("KLASSEN").split(",") if OS.get_environment("KLASSEN") != "" else PackedStringArray(["FIGHTER", "CLERIC"])):
		# 438: auch der Zufall der Bewegungen (randf: Ausweichen, Ruhe) fest, sonst misst jeder Lauf einen anderen Kampf
		seed(int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7)
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
		while n < (int(OS.get_environment("BILDER")) if OS.get_environment("BILDER") != "" else DAUER_BILDER):
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
	var spur := OS.get_environment("SPUR438")     # 562 am Rechner: SPUR438=<von>-<bis> schreibt je Bild jede Figur
	if spur != "" and n >= int(spur.get_slice("-", 0)) and n <= int(spur.get_slice("-", 1)):
		for f in figs:
			if f.fighter.id.begins_with("wolf"):
				print("SPUR %d %s rot=%.0f anim=%s gang=%s auf=(%.2f,%.2f) heim=(%.2f,%.2f) tween=%s unterwegs=%s bahn=%s warte=%d" % [n, f.fighter.id, rad_to_deg(f.rotation.y),
					f.anim.current_animation if f.anim else "", f.gang, f.position.x, f.position.z, f.home.x, f.home.z,
					f.tween != null and f.tween.is_running(), f.unterwegs(), f.bahn, f._warte_n])
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
				# 900 (Lauf 335: Biss 7 Bilder 0,56 m, ohne Kaufdaten am Rechner nicht nachstellbar): wer gleitet, wobei, je Bild
				if nm in ["Biss", "Treffer"] and gleit_n < 30:
					gleit_n += 1
					print("438 GLEIT Bild %d %s %s %.2f s: %.3f m, gang=%s tween=%s abgesetzt=%s heim %.2f m, Meldung: %s" % [n, id, nm,
						f.anim.current_animation_position, d, f.gang, f.tween != null and f.tween.is_running(), f._abgesetzt,
						Vector2(f.home.x - p.x, f.home.z - p.z).length(), String(kf.shown.get("text", "")).left(60)])
			elif nm in ["Gehen", "Rennen"] and f.has_method("_mps") and not f.weg.is_empty() and f.weg.has(nm):
				var soll: float = f._mps(nm) / 30.0 * absf(f.anim.get_playing_speed())
				if d > soll * 1.35 + 0.005:
					if OS.get_environment("SCHAU_RENNEN") != "":
						print("Rennen Bild %d %s: %.3f m statt %.3f, Tempo %.2f (Schleife %.2f), Gang %s, Bild der Bewegung %.2f" % [n, id, d, soll, f.anim.speed_scale, f.anim.get_playing_speed(), f.gang, f.anim.current_animation_position])
					var g2: Array = gleiten.get(nm + " zu schnell", [0, 0.0, 0.0])
					gleiten[nm + " zu schnell"] = [g2[0] + 1, g2[1] + d - soll, maxf(g2[2], d - soll)]
			if rad_to_deg(dg) > DREH_BILD_GRAD and nm != "Tod":
				var dm: Array = dreh_max.get(nm, [0, 0.0])
				dreh_max[nm] = [dm[0] + 1, maxf(dm[1], rad_to_deg(dg))]
				if log_an:
					print("Drehsprung Bild %d %s %s %.0f°" % [n, id, nm, rad_to_deg(dg)])
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
	# 438: Würfelzeile und Schaden erst, wenn der Getroffene zittert (hurt)
	for f in figs:
		var hid := "%s/%s" % [k, f.fighter.id]
		if f.hurt_at >= 0.0 and f.hurt_at != hurt_vor.get(hid, -1.0):
			hurt_ab[hid] = hurt_ab.get(hid, []) + [n]
		hurt_vor[hid] = f.hurt_at
	if kf.ui.roll_at != roll_vor:
		roll_vor = kf.ui.roll_at
		var ak = kf.shown.get("actor")
		if kf.ui.roll_shown != null and ak != null and kf.figures.has(ak) and _wolf(kf.figures[ak]) and kf.shown.get("roll") != null:
			if n - int(biss_bild.get("%s/%s" % [k, ak], -999)) > 45:
				wurf_ohne.append([n, "%s/%s" % [k, ak], String(kf.shown.get("text", ""))])
		if kf.ui.roll_shown != null and int(kf.shown.get("damage", 0)) > 0:
			wurf.append([n, "%s/%s" % [k, kf.ui.roll_shown[0]], int(kf.shown.damage), String(kf.shown.get("text", ""))])
	# 438: Kopf des Wolfs (Knochen kopf, Schädeldach, Kieferspitze) im Körper von Held und Söldner, gemessen gegen Kapseln um
	# deren Knochen in der jetzigen Haltung (Becken–Brust 0,17 m, Brust–Kopf 0,12 m, Kopf 0,11 m, Beine 0,08 m); der Umriss
	# footprint() taugt dafür nicht (Kaufkörper in T-Haltung: Arme 1,8 m breit)
	for a in figs:
		if not _wolf(a) or not a.visible or a.down:
			continue
		var sk := a._find(a.model, "Skeleton3D") as Skeleton3D
		if sk == null:
			continue
		var pts := []
		for bn in WOLF_KOPF:
			var bi := sk.find_bone(bn)
			if bi >= 0:
				pts.append(sk.global_transform * sk.get_bone_global_pose(bi).origin)
		for b in figs:
			if _wolf(b) or not b.visible or b.down:
				continue
			var t := -INF
			for q in pts:
				t = maxf(t, _im_koerper(b, q))
			# 988 (Lauf 355/365 auf Build 277, CLERIC ohne Schild nach BRS): wer, in welcher Bewegung, welcher Knochen an welcher Kapsel
			if t > KOPF_M - 0.02 and diag_kopf_n < 24:
				diag_kopf_n += 1
				print("438 DIAG Kopf Bild %d %s: %s %s gang=%s auf %s rot %.0f | %s %s auf %s rot %.0f ss=%s hurt=%s | t %.3f %s | Abstand %.2f busy=%s hit=%s Zeile %s" % [n, k,
					a.fighter.id, a.anim.current_animation if a.anim else "", a.gang, a.global_position, rad_to_deg(a.rotation.y),
					b.fighter.id, b.anim.current_animation if b.anim else "", b.global_position, rad_to_deg(b.rotation.y),
					b._ss(), b.hurt_at >= 0.0, t, _kopf_wo(b, sk), Vector2(a.global_position.x - b.global_position.x,
					a.global_position.z - b.global_position.z).length(), kf.busy, not kf.hit.is_empty(), str(kf.shown.get("text", ""))])
			if t > KOPF_M:
				var key := "%s/%s→%s/%s" % [k, a.fighter.id, k, b.fighter.id]
				var e: Array = kopf.get(key, [0, -INF, n])
				kopf[key] = [e[0] + 1, maxf(e[1], t), e[2]]
	_r2(kf, n, k, figs)
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
			# 438 (Prüfer: Achsenpunkte mit Rand gegen den Kasten zu grob): Raster über den ganzen Umriss, ohne Rand
			for i in 7:
				for j in 3:
					var z: float = lerpf(box.position.z, box.end.z, i / 6.0)
					var x: float = lerpf(box.position.x, box.end.x, j / 2.0)
					var q: Vector3 = a.global_transform * Vector3(x, 0, z)
					tief = minf(tief, b.clearance(q))
			if tief < -DURCH_M:
				durch.append([n, "%s/%s" % [k, a.fighter.id], "%s/%s" % [k, b.fighter.id], -tief, a.anim.current_animation if a.anim else ""])
				# 562 (Läufe 275/276/279: mit dem schnelleren Hinweg der Helden 0,13 m Wolf in Wolf): wer was tut, je Fund höchstens 12 Zeilen
				if diag_n < 12:
					diag_n += 1
					print("438 DIAG Bild %d %s: %s %s gang=%s heim=%s auf %s | %s %s gang=%s heim=%s auf %s | tief %.2f busy=%s" % [n, k,
						a.fighter.id, a.anim.current_animation if a.anim else "", a.gang, a.home, a.global_position,
						b.fighter.id, b.anim.current_animation if b.anim else "", b.gang, b.home, b.global_position, -tief, kf.busy])


## 438 Prüfer Film r2: alles, was der Prüfer im Film r2 sah, je Bild gemessen
func _r2(kf, n: int, k: String, figs: Array) -> void:
	var ui = kf.ui
	# Zeilen mit Bild
	while zeilen_n < ui.lines.size():
		zeilen.append([n, String(ui.lines[zeilen_n]), k])
		zeilen_n += 1
	if ui.lines.size() < zeilen_n:
		zeilen_n = ui.lines.size()
	# Beginn jeder Bewegung je Figur
	for f in figs:
		var id := "%s/%s" % [k, f.fighter.id]
		var a := String(f.anim.current_animation) if f.anim else ""
		if a != anim_vor.get(id, ""):
			var d: Dictionary = anim_ab.get(id, {})
			d[a] = d.get(a, []) + [n]
			anim_ab[id] = d
			anim_vor[id] = a
		if _wolf(f) and a in ["Biss", "Sprungbiss", "Sprung"]:
			biss_bild[id] = n
	# Größe einmal: Schulter des Söldners, Rücken und Ohren des Wolfs (Welt, m)
	if not groesse_gedruckt and n == 5:
		groesse_gedruckt = true
		for f in figs:
			var sk := f._find(f.model, "Skeleton3D") as Skeleton3D
			if sk == null:
				continue
			var hoch := -INF
			var schulter := -INF
			for c in f.kapseln():
				hoch = maxf(hoch, maxf(c[0].y, c[1].y) + c[2])
			for bn in ["clavicle_l", "upperarm_l", "Wolf_Spine_02SHJnt", "Wolf_Spine_03SHJnt"]:
				var bi := sk.find_bone(bn)
				if bi >= 0:
					schulter = maxf(schulter, (sk.global_transform * sk.get_bone_global_pose(bi).origin).y)
			for g in f.traegt():
				print("Trägt %s/%s %s: Kasten %s, Maßstab %s" % [k, f.fighter.id, g[2], g[1], (g[0] as Transform3D).basis.get_scale()])
			print("Umriss %s/%s: %s" % [k, f.fighter.id, f.footprint()])
			print("Größe %s/%s: oben %.2f m, Schulter/Rücken %.2f m, Maßstab %.2f" % [k, f.fighter.id, hoch, schulter, f.model.global_transform.basis.get_scale().x])
	# Körper: Wolf (Kapseln) gegen Mensch (Kapseln, Schild, Klinge)
	for a in figs:
		if not _wolf(a) or not a.visible or a.down:
			continue
		var wk: Array = a.kapseln()
		for b in figs:
			if _wolf(b) or not b.visible or b.down:
				continue
			var tief := -INF
			var teil := ""
			var mk: Array = b.kapseln()
			for i in mk.size():
				for c in wk:
					var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(c[0], c[1], mk[i][0], mk[i][1])
					var t: float = c[2] + mk[i][2] - pq[0].distance_to(pq[1])
					if t > tief:
						tief = t
						teil = ["Rumpf", "Brust", "Hals", "Kopf", "Bein", "Bein", "Unterbein", "Unterbein", "Arm", "Arm", "Unterarm", "Unterarm"][mini(i, 11)]
			for g in b.traegt():
				var inv: Transform3D = (g[0] as Transform3D).affine_inverse()
				var box: AABB = g[1]
				var sc: float = absf((g[0] as Transform3D).basis.get_scale().x)
				for c in wk:
					for j in 5:
						var q: Vector3 = inv * (c[0] as Vector3).lerp(c[1], j / 4.0)
						var dx := maxf(box.position.x - q.x, q.x - box.end.x)
						var dy := maxf(box.position.y - q.y, q.y - box.end.y)
						var dz := maxf(box.position.z - q.z, q.z - box.end.z)
						var t: float = c[2] - (maxf(dx, maxf(dy, dz)) if dx <= 0 and dy <= 0 and dz <= 0 else Vector3(maxf(dx, 0), maxf(dy, 0), maxf(dz, 0)).length()) * sc
						if t > tief:
							tief = t
							teil = String(g[2]) if String(g[2]) != "" else "Haar"
						if t > KOERPER_M and OS.get_environment("SCHAU_SCHILD") != "":
							print("Schild %s Bild %d %s: Kapsel %s r %.2f, Tiefe %.3f, %s bei %.2f, Träger %s, Abstand %.2f" % [a.fighter.id, n, g[2], c[3], c[2], t, a.anim.current_animation, a.anim.current_animation_position, b.anim.current_animation, Vector2(a.position.x - b.position.x, a.position.z - b.position.z).length()])
			if tief > KOERPER_M:
				var key := "%s/%s→%s/%s %s" % [k, a.fighter.id, k, b.fighter.id, teil]
				# 438: die Klinge im getroffenen Wolf ist der Treffer selbst; ob sie ohne Treffer durchfährt, misst „Klinge durch einen
				# Wolf ohne Treffer“ (±8 Bilder). Hier zählt sie nur, wenn der Wolf in diesen Bildern nicht getroffen wird (Bilanz)
				if teil in ["longsword", "shortsword", "quarterstaff", "dagger"]:
					klinge_koerper.append([n, "%s/%s" % [k, a.fighter.id], key, tief, String(a.anim.current_animation) if a.anim else ""])
					continue
				var e: Array = koerper.get(key, [0, -INF, n, String(a.anim.current_animation) if a.anim else ""])
				koerper[key] = [e[0] + 1, maxf(e[1], tief), e[2], e[3]]
	# Wolf in Wolf am Körper (Kapseln), auch im Sprung und beim Platztausch
	for i in figs.size():
		var a = figs[i]
		if not _wolf(a) or not a.visible or a.down:
			continue
		for j in range(i + 1, figs.size()):
			var b = figs[j]
			if not _wolf(b) or not b.visible or b.down:
				continue
			var tief := -INF
			for c in a.kapseln():
				for d in b.kapseln():
					var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(c[0], c[1], d[0], d[1])
					tief = maxf(tief, c[2] + d[2] - pq[0].distance_to(pq[1]))
			if tief > 0.05:
				var key := "%s/%s↔%s/%s" % [k, a.fighter.id, k, b.fighter.id]
				var e: Array = koerper.get(key, [0, -INF, n, "%s/%s" % [String(a.anim.current_animation) if a.anim else "", String(b.anim.current_animation) if b.anim else ""]])
				koerper[key] = [e[0] + 1, maxf(e[1], tief), e[2], e[3]]
	# Klinge durch einen Wolf
	for b in figs:
		if _wolf(b) or not b.visible or b.down:
			continue
		for g in b.traegt():
			if String(g[2]).contains("shield") or String(g[2]) == "":
				continue
			var box: AABB = g[1]
			var lang := box.get_longest_axis_index()
			var p0: Vector3 = box.get_center()
			var p1: Vector3 = p0
			p0[lang] = box.position[lang]
			p1[lang] = box.end[lang]
			var a0: Vector3 = g[0] * p0
			var a1: Vector3 = g[0] * p1
			for a in figs:
				if not _wolf(a) or not a.visible or a.down:
					continue
				var tief := -INF
				for c in a.kapseln():
					var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(a0, a1, c[0], c[1])
					tief = maxf(tief, c[2] - pq[0].distance_to(pq[1]))
				if tief > KOERPER_M:
					klinge.append([n, "%s/%s" % [k, b.fighter.id], "%s/%s" % [k, a.fighter.id], tief])
	# Sterbende: Höhe des Rumpfs
	for f in figs:
		if _wolf(f) and f.dead_at >= 0 and f.visible:
			var sk := f._find(f.model, "Skeleton3D") as Skeleton3D
			var bi := sk.find_bone("Wolf_Spine_02SHJnt") if sk else -1
			if bi >= 0:
				var id := "%s/%s" % [k, f.fighter.id]
				tief_y[id] = tief_y.get(id, []) + [[n, (sk.global_transform * sk.get_bone_global_pose(bi).origin).y, f.fighter.name(0)]]
	# Stillstand: keine Figur bewegt sich oder spielt etwas anderes als Ruhe, die Linse steht
	var bewegt: bool = not kf.hit.is_empty()
	for f in figs:
		if not f.visible:
			continue
		var id := "%s/%s" % [k, f.fighter.id]
		var a := String(f.anim.current_animation) if f.anim else ""
		var l: Array = lage_vor.get(id, [f.global_position, f.rotation.y])
		if not (a in RUHE) or f.global_position.distance_to(l[0]) > 0.002 or absf(f.rotation.y - l[1]) > 0.003 or f.hurt_at >= 0.0:
			bewegt = true
		lage_vor[id] = [f.global_position, f.rotation.y]
	if kf.mars.outcome == "ONGOING":
		if not bewegt:
			still += 1
			if still_ab < 0:
				still_ab = n
		elif still_ab >= 0:
			if n - still_ab >= 15:
				still_spannen.append([still_ab, n - still_ab, str(kf.shown.get("text", "")), str(kf.shown.get("cue", ""))])
			still_ab = -1
	# Bildrand: Kapseln jeder sichtbaren Figur in der Szene (über dem Bedienfeld)
	var sr: Rect2 = kf.scene_rect()
	for f in figs:
		if not f.visible or f.dead_at >= 0:
			continue
		var raus := 0.0
		for c in f.kapseln():
			for q in [c[0], c[1]]:
				var sp: Vector2 = kf.screen_of(q)
				var rpx: float = c[2] / kf.m_per_dp(q) * (sr.size.x / 412.0)
				raus = maxf(raus, maxf(maxf(-(sp.x - rpx), sp.x + rpx - sr.size.x), -(sp.y - rpx)))
		if OS.get_environment("SCHAU_RAND") != "" and n == 5:
			var lo := Vector2(INF, INF)
			var hi := -lo
			for c in f.kapseln():
				for q in [c[0], c[1]]:
					lo = lo.min(kf.screen_of(q))
					hi = hi.max(kf.screen_of(q))
			print("Rand %s: %s bis %s, Szene %s, Fenster %s" % [f.fighter.id, lo, hi, sr, kf.get_viewport().get_visible_rect()])
		if raus > 6.0 and OS.get_environment("SCHAU_RAND") != "":
			print("Rand Bild %d %s %.0f px: %s bei %s, Zoom %.2f rand_z %.3f gang %s rot %.0f heim %s platz %s, Zeile %s" % [n, f.fighter.id, raus, f.anim.current_animation if f.anim else "", f.global_position, kf.cam_z, kf.rand_z, f.gang, rad_to_deg(f.rotation.y), f.home, str(kf.shown.places), str(kf.shown.get("text", ""))])
		if raus > 6.0 and diag_rand_n < 16:     # 988 (Lauf 355/365: Kleriker 44,3 s bis 11 px draußen): wo, wie gezoomt, welche Bewegung
			diag_rand_n += 1
			print("438 DIAG Rand Bild %d %s/%s %.0f px: %s auf %s rot %.0f gang %s tween %s unterwegs %s | %s | Szene %s, cam_z %.2f rand_z %.3f size %.3f off %s hit %s | Zeile %s" % [n, k,
				f.fighter.id, raus, f.anim.current_animation if f.anim else "", f.global_position, rad_to_deg(f.rotation.y), f.gang,
				f.tween != null and f.tween.is_running(), f.unterwegs(), _rand_wo(kf, f, sr), sr, kf.cam_z, kf.rand_z, kf.cam.size,
				kf.cam.frustum_offset, not kf.hit.is_empty(), str(kf.shown.get("text", ""))])
		if raus > 6.0:
			var id := "%s/%s" % [k, f.fighter.id]
			var e: Array = rand.get(id, [0, n, 0.0])
			rand[id] = [e[0] + 1, e[1], maxf(e[2], raus)]
	# Ansagen und Balken: Sprung über 40 dp in einem Bild (gleitend höchstens ein Viertel des Wegs je Bild)
	# (gegen den eigenen Fußpunkt: läuft der Wolf, läuft seine Ansage mit)
	var jetzt := {}
	for id in ui.sign_of:
		if kf.figures.has(id):
			jetzt["Ansage " + String(id)] = (ui.sign_of[id] as Rect2).position - kf.screen_of(kf.figures[id].position)
	for id in ui.balken_of:
		if kf.figures.has(id):
			jetzt["Balken " + String(id)] = ui.balken_of[id] - kf.screen_of(kf.figures[id].position)
	for key in jetzt:
		if ui_vor.has(key) and n > 30:     # die ersten Bilder stellen sich alle erst auf (unter der Blende)
			var d: float = (jetzt[key] as Vector2).distance_to(ui_vor[key])
			if d > 40.0 * ui.dp:
				var e: Array = ui_sprung.get(k + " " + key, [0, n, 0.0])
				ui_sprung[k + " " + key] = [e[0] + 1, e[1], maxf(e[2], d / ui.dp)]
	ui_vor = jetzt
	ui.balken_of.clear()


## 438: wie tief [q] (Welt) in einer Kapsel um die Knochen von [f] liegt (m, < 0: so weit draußen)
## 988: welcher Wolfsknochen welcher Kapsel des Getroffenen am nächsten ist
func _kopf_wo(f, wsk: Skeleton3D) -> String:
	var sk := f._find(f.model, "Skeleton3D") as Skeleton3D
	if sk == null:
		return "-"
	var best := -INF
	var wo := ""
	for bn in WOLF_KOPF:
		var bi := wsk.find_bone(bn)
		if bi < 0:
			continue
		var q: Vector3 = wsk.global_transform * wsk.get_bone_global_pose(bi).origin
		for c in KOERPER:
			var i0 := sk.find_bone(c[0])
			var i1 := sk.find_bone(c[1])
			if i0 < 0 or i1 < 0:
				continue
			var a: Vector3 = sk.global_transform * sk.get_bone_global_pose(i0).origin
			var b: Vector3 = sk.global_transform * sk.get_bone_global_pose(i1).origin
			if c[0] == "Head":
				a += sk.global_basis.y.normalized() * 0.1
				b = a
			var p := Geometry3D.get_closest_point_to_segment(q, a, b)
			var t: float = float(c[2]) - q.distance_to(p)
			if t > best:
				best = t
				wo = "%s an %s-%s (Höhe %.2f)" % [bn, c[0], c[1], q.y]
	return wo


## 988: welche Seite, welche Kapsel über den Rand ragt
func _rand_wo(kf, f, sr: Rect2) -> String:
	var best := -INF
	var wo := ""
	var i := 0
	for c in f.kapseln():
		for q in [c[0], c[1]]:
			var sp: Vector2 = kf.screen_of(q)
			var rpx: float = c[2] / kf.m_per_dp(q) * (sr.size.x / 412.0)
			for s in [["links", -(sp.x - rpx)], ["rechts", sp.x + rpx - sr.size.x], ["oben", -(sp.y - rpx)]]:
				if float(s[1]) > best:
					best = float(s[1])
					wo = "%s Kapsel %d bei %s (r %.0f px, Höhe %.2f)" % [s[0], i, sp, rpx, q.y]
		i += 1
	return wo


func _im_koerper(f, q: Vector3) -> float:
	var sk := f._find(f.model, "Skeleton3D") as Skeleton3D
	if sk == null:
		return -INF
	var t := -INF
	for c in KOERPER:
		var i0 := sk.find_bone(c[0])
		var i1 := sk.find_bone(c[1])
		if i0 < 0 or i1 < 0:
			continue
		var a: Vector3 = sk.global_transform * sk.get_bone_global_pose(i0).origin
		var b: Vector3 = sk.global_transform * sk.get_bone_global_pose(i1).origin
		if c[0] == "Head":
			a += sk.global_basis.y.normalized() * 0.1     # Kopfmitte über dem Gelenk
			b = a
		var p := Geometry3D.get_closest_point_to_segment(q, a, b)
		t = maxf(t, float(c[2]) - q.distance_to(p))
	return t


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
	var ww_tief := 0
	for d in durch:
		if not d[2].ends_with("/hero") and not d[2].ends_with("/merc") and d[3] > WW_M:
			ww_tief += 1
	print("— 438 Wolf in Wolf tiefer als %.2f m (Raster): %d Bilder" % [WW_M, ww_tief])
	if ww_tief > 0:
		befund += 1
		print("    Befund: Wölfe laufen durcheinander")
	print("— 438 Kopf des Wolfs im Körper von Held oder Söldner (tiefer als %.2f m): %d Paare" % [KOPF_M, kopf.size()])
	for key in kopf:
		print("  %s: ab Bild %d, %d Bilder, tiefste %.2f m" % [key, kopf[key][2], kopf[key][0], kopf[key][1]])
	if not kopf.is_empty():
		befund += 1
		print("    Befund: Kopf im Getroffenen")
	print("— 438 Drehsprünge über %.0f° in einem Bild" % DREH_BILD_GRAD)
	for nm in dreh_max:
		print("  %s: %d Bilder, größte %.0f°" % [nm if nm != "" else "(keine)", dreh_max[nm][0], dreh_max[nm][1]])
	if not dreh_max.is_empty():
		befund += 1
		print("    Befund: Drehsprung")
	var frueh := 0
	for w in wurf:
		var ok := false
		for b in hurt_ab.get(w[1], []):
			if absi(b - w[0]) <= 3:
				ok = true
		if not ok:
			frueh += 1
			print("  Bild %d: Würfel und %d Schaden an %s ohne Treffer im Bild (±3 Bilder): %s" % [w[0], w[2], w[1], w[3]])
	print("— 438 Würfelzeile mit Schaden ohne Treffer im selben Augenblick: %d von %d" % [frueh, wurf.size()])
	if frueh > 0:
		befund += 1
		print("    Befund: Würfelzeile vor oder nach dem Treffer")
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
	_bilanz_r2()
	print("Befunde: %d" % befund)


func _sek(n: int) -> String:
	return "%.1f s" % (n / 30.0)


func _bilanz_r2() -> void:
	for kk in klinge_koerper:
		var getroffen := false
		for h in hurt_ab.get(kk[1], []):
			if absi(h - kk[0]) <= 8:
				getroffen = true
		if not getroffen:
			var e: Array = koerper.get(kk[2], [0, -INF, kk[0], kk[4]])
			koerper[kk[2]] = [e[0] + 1, maxf(e[1], kk[3]), e[2], e[3]]
	print("— 438 r2 Wolf im Körper, Schild oder Klinge eines Menschen (tiefer als %.2f m): %d" % [KOERPER_M, koerper.size()])
	for key in koerper:
		print("  %s: ab %s (%s), %d Bilder, tiefste %.2f m" % [key, _sek(koerper[key][2]), koerper[key][3], koerper[key][0], koerper[key][1]])
	if not koerper.is_empty():
		befund += 1
	var ohne := 0
	var gez := {}
	for b in klinge:
		var getroffen := false
		for h in hurt_ab.get(b[2], []):
			if absi(h - b[0]) <= 8:
				getroffen = true
		if not getroffen:
			ohne += 1
			var key: String = b[1] + "→" + b[2]
			if not gez.has(key) or b[0] - gez[key][-1][0] > 15:
				gez[key] = gez.get(key, []) + [[b[0], b[3]]]
	print("— 438 r2 Klinge durch einen Wolf ohne Treffer: %d Bilder" % ohne)
	for key in gez:
		for e in gez[key]:
			print("  %s ab %s, %.2f m" % [key, _sek(e[0]), e[1]])
	if ohne > 0:
		befund += 1
	print("— 438 r2 Würfelzeile eines Wolfs ohne Biss in den 1,5 s davor: %d" % wurf_ohne.size())
	for w in wurf_ohne:
		print("  %s %s: %s" % [_sek(w[0]), w[1], w[2]])
	if not wurf_ohne.is_empty():
		befund += 1
	# Sturz-Meldung zum Biss: Zeile gegen den Beginn von Sturz/Treffer des Getroffenen
	print("— 438 r2 Zeilen „springt an / prallt gegen / wirft sich auf“ gegen Sturz im Bild")
	for z in zeilen:
		if not (z[1].contains(" springt ") or z[1].contains("prallt gegen") or z[1].contains("wirft sich auf")):
			continue
		var best := 9999
		for id in anim_ab:
			for a in ["Sturz", "Treffer", "SS_GetHitHeavyFront", "SS_GetHitLightFront"]:     # 406: mit Schild der Treffer des Satzes
				for b in anim_ab[id].get(a, []):
					if absi(b - z[0]) < absi(best):
						best = b - z[0]
		print("  %s %s: Sturz %+.1f s" % [_sek(z[0]), z[1], best / 30.0])
		if absi(best) > 9:
			befund += 1
	print("— 438 r2 Todeszeile gegen Liegen (Rumpf am Boden)")
	for id in tief_y:
		var reihe_y: Array = tief_y[id]
		var lo := INF
		for e in reihe_y:
			lo = minf(lo, e[1])
		var liegt := -1
		for e in reihe_y:
			if e[1] <= lo + 0.03:
				liegt = e[0]
				break
		var nm: String = reihe_y[0][2]
		for z in zeilen:
			if z[2] == id.get_slice("/", 0) and z[1].begins_with(nm + " ") and (z[1].contains("fällt") or z[1].contains("liegen") or z[1].contains("sackt")) and z[0] >= reihe_y[0][0] - 30:
				print("  %s: stirbt %s, liegt %s, Zeile %s (%+.1f s zum Liegen): %s" % [id, _sek(reihe_y[0][0]), _sek(liegt), _sek(z[0]), (z[0] - liegt) / 30.0, z[1]])
				if z[0] - liegt > 9:
					befund += 1
				break
	print("— 438 r2 Stillstand (keine Bewegung, Linse ruht): %s, Spannen ab 0,5 s:" % _sek(still))
	for sp in still_spannen:
		print("  ab %s %s nach „%s“ (%s)" % [_sek(sp[0]), _sek(sp[1]), sp[2], sp[3]])
	print("— 438 r2 Figur am Bildrand angeschnitten: %d" % rand.size())
	for id in rand:
		print("  %s: ab %s, %d Bilder, bis %.0f px draußen" % [id, _sek(rand[id][1]), rand[id][0], rand[id][2]])
	if not rand.is_empty():
		befund += 1
	print("— 438 r2 Ansage oder Leiste springt (über 40 dp in einem Bild; Gleiten bleibt darunter): %d" % ui_sprung.size())
	for key in ui_sprung:
		print("  %s: ab %s, %d Mal, bis %.0f dp" % [key, _sek(ui_sprung[key][1]), ui_sprung[key][0], ui_sprung[key][2]])
	if not ui_sprung.is_empty():
		befund += 1
