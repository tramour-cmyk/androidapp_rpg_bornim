# 760 (Chef 09.11., 14:00; wiederholt 12.11., 20:09 und 15.11., 12:57: „ich werde angesprungen, aber sehe nichts davon“): der Wolf
# springt bei „Anspringen“ wirklich. Echter Kampfort gegen das Rudel, jede Ansage ein Anspringen (ZUG=pounce wie der Reiter Test).
# Geprüft je Bild an jedem Wolf mit gebautem Sprung (sprung.gd; Kaufwolf ohne Sprungbiss der Quelle):
#  - es gibt Sprünge, jeder hebt ab (Scheitel mindestens 0,15 m) und legt im Flug Weg zurück (mindestens 0,5 m);
#  - mindestens einer springt aus dem Stand (Absprung höchstens 0,2 m von dort, wo er zuletzt stand: daheim oder abgesetzt, 717 C);
#  - der Flug endet am Boden, Rumpf waagerecht (auch wenn er im Flug fällt);
#  - nach dem Sprung steht er binnen 10 s wieder auf dem eigenen Platz (höchstens 0,15 m daneben);
#  - Messung (sperrt nicht, Zeile MESSUNG760): der Biss reicht hin (Chef 15.11., 16:56: „beißt einen Meter zu kurz … bleibt am oder kurz vorm Schild hängen und verursacht aber
#    Schaden“): beim Treffer kommen die Zähne an den Körper (Lücke höchstens LUECKE_TREFFER), daneben schnappen sie knapp vor Körper
#    oder Schild zu (höchstens LUECKE_DANEBEN, nicht tiefer als LUECKE_TIEF im Körper; wie biss_1284).
# Ohne Tier mit Wurzelweg (kampf/daten ohne Kaufwolf): übersprungen (exit 0).
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/sprung_760.gd   (exit 0 = alles erfüllt)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const FPS := 30.0
const RUNDEN := 4
## so lange nach dem Aufkommen steht er spätestens wieder auf seinem Platz (s)
const HEIM_S := 10.0
## Lücke der Zähne zum Ziel (m): beim Treffer am Körper, daneben knapp vor Körper oder Schild (wie biss_1284)
const LUECKE_TREFFER := 0.06
const LUECKE_DANEBEN := 0.25
const LUECKE_TIEF := -0.05
const KOPF := ["Head", "Jaw", "Tongue", "kopf", "Mouth", "mouth", "Fang", "fang"]

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _gut(ok: bool, text: String) -> void:
	print(("gut " if ok else "FEHLER ") + text)
	if not ok:
		fehler += 1


func _lauf() -> void:
	seed(760)
	# Handy hochkant wie biss_1284 (sonst liegt „im Bild“ des Bissplatzes, 438, im Querformat anders als am Gerät)
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
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
	var biss := {}          # Wolf -> {ziel, ausgang, koerper, schild}: der laufende Sprungbiss
	var bisse := []         # fertige [Wolf, Ziel, Ausgang, Lücke Körper, Lücke Schild, Zeit]
	var shown_vor = null
	Mars.test_gegnerzug = "pounce"
	while n < int(FPS) * 240:
		await process_frame
		n += 1
		if Mars.test_gegnerzug == "":
			Mars.test_gegnerzug = "pounce"
		var t := n / FPS
		# Ausgang des Angriffs aus dem Kampfbericht (wie biss_1284): Treffer oder daneben, und das Ziel
		var e_sh: Dictionary = kf.shown
		if e_sh != shown_vor and not e_sh.is_empty():
			shown_vor = e_sh
			var ak = e_sh.get("actor")
			var ro = e_sh.get("roll")
			# Ausgang aus dem Wurf, sonst (Meldung „schlagen ins Leere“ ohne Wurf) aus dem Schaden
			if ak != null and kf.figures.has(ak) and e_sh.get("target") != null and (ro is Array and ro.size() > 4 or e_sh.has("damage")):
				var wf = kf.figures[ak]
				if not biss.has(wf) or not flug.has(wf) and t - float(biss[wf].t) > 4.0:     # ein alter Ausgang (Biss im Stand) zählt nicht
					biss[wf] = {"ziel": "", "ausgang": "", "koerper": {}, "schild": {}, "t": t}
				if biss[wf].ausgang == "":
					var trifft: bool = bool(ro[4]) if ro is Array and ro.size() > 4 else int(e_sh.get("damage", 0)) > 0
					biss[wf].ausgang = "Treffer" if trifft else "daneben"
					biss[wf].ziel = str(e_sh.get("target"))
					biss[wf].t = t
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
				# ein Ausgang aus einem früheren Biss ohne Sprung (im Stand) zählt nicht
				if not biss.has(f) or not flug[f].has("biss") and t - float(biss[f].t) > 4.0:
					biss[f] = {"ziel": "", "ausgang": "", "koerper": {}, "schild": {}, "t": t}
				flug[f]["biss"] = true
				for z in kf.figures.values():
					if z.fighter.monster == null and z.visible and not z.down:
						var lu: Array = _luecke(f, z)
						biss[f].koerper[z.fighter.id] = minf(float(biss[f].koerper.get(z.fighter.id, INF)), lu[0])
						biss[f].schild[z.fighter.id] = minf(float(biss[f].schild.get(z.fighter.id, INF)), lu[1])
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
					if biss.has(f):
						var bz: Dictionary = biss[f]
						bisse.append([f.fighter.id, bz.ziel, bz.ausgang, float(bz.koerper.get(bz.ziel, INF)), float(bz.schild.get(bz.ziel, INF)), t])
						biss.erase(f)
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
	var kurz_biss := 0
	for bz in bisse:
		var gut := true
		if bz[2] == "Treffer":
			gut = bz[3] <= LUECKE_TREFFER
		elif bz[2] == "daneben":
			gut = minf(bz[3], bz[4]) <= LUECKE_DANEBEN and bz[3] >= LUECKE_TIEF
		if not gut:
			kurz_biss += 1
		print("760 %.2f Biss %s an %s, %s: Lücke der Zähne Körper %.2f, Schild %.2f m%s" % [bz[5], bz[0], bz[1], bz[2] if bz[2] != "" else "ohne Ausgang", bz[3], bz[4], "" if gut else " – FALSCH"])
	# Messung, sperrt nicht (Sokrates 15.11.: „als Messung im Test“): von der Schildseite kommt die Schnauze beim Treffer noch nicht
	# an den Körper, ohne dass der Wolf im Helden steckt (709.1, ruht bis 930)
	print("MESSUNG760 der Biss reicht hin: Treffer am Körper (bis %.2f m), daneben knapp davor (bis %.2f m): %s, %d von %d nicht" % [LUECKE_TREFFER, LUECKE_DANEBEN, "erfüllt" if kurz_biss == 0 else "NICHT erfüllt", kurz_biss, bisse.size()])
	_gut(nicht_heim == 0, "nach dem Sprung zurück auf dem eigenen Platz (%d nicht)" % nicht_heim)
	print("SPRUNG760 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler else 0)


## Zähne: Kapseln von Kopf und Kiefer (wie biss_1284)
func _zaehne(f) -> Array:
	var out: Array = []
	for c in f.kapseln():
		if c.size() > 3:
			for w in KOPF:
				if String(c[3]).contains(w):
					out.append(c)
					break
	return out


## [Lücke zum Körper, Lücke zum Schild] wie biss_1284 _luecke
func _luecke(a, b) -> Array:
	var best := INF
	var schild := INF
	var ws: Array = _zaehne(a)
	for w in ws:
		for c in b.koerper():
			var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(w[0], w[1], c[0], c[1])
			best = minf(best, pq[0].distance_to(pq[1]) - float(w[2]) - float(c[2]))
	for g in b.traegt():
		if not String(g[2]).to_lower().contains("shield"):
			continue
		var inv: Transform3D = (g[0] as Transform3D).affine_inverse()
		var box: AABB = g[1]
		var sc: float = absf((g[0] as Transform3D).basis.get_scale().x)
		for w in ws:
			for j in 9:
				var q: Vector3 = inv * (w[0] as Vector3).lerp(w[1], j / 8.0)
				var dx := maxf(box.position.x - q.x, q.x - box.end.x)
				var dy := maxf(box.position.y - q.y, q.y - box.end.y)
				var dz := maxf(box.position.z - q.z, q.z - box.end.z)
				var d: float = (maxf(dx, maxf(dy, dz)) if dx <= 0 and dy <= 0 and dz <= 0 else Vector3(maxf(dx, 0), maxf(dy, 0), maxf(dz, 0)).length()) * sc
				schild = minf(schild, d - float(w[2]))
	return [best, schild]
