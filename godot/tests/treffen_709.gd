# 709 (Chef 08.11., 21:36, über Sokrates: „… dass die Angriffe so sind, dass sie den Gegner treffen“; F2 „Biss und Hieb treffen das
# Ziel“): Messung ohne Bild am echten Kampfort, Autopilot. In jedem Bild, in dem eine Figur getroffen wird (hurt_at springt, das ist
# der Aufschlag: kampfort.gd lands), Abstand zwischen der Waffe des Angreifers und dem Körper des Ziels (Kapseln, m; < 0: darin).
# Waffe: was er in der Hand trägt (traegt(), ohne Schild und Haar) als Strecke längs des Kastens; ohne Waffe Kopf, Kiefer, Zunge,
# Hände (Kapseln); sonst der ganze Körper. Zauber und Geschosse zählen nicht (fliegen sichtbar, 348.7).
# Lücke = kleinster Abstand im Fenster ±FENSTER Bilder um den Aufschlag (Treffer wirken, sobald die Waffe nah war).
# Run: GEGNER=WOLVES,GOBLINS … KLASSEN=FIGHTER,CLERIC godot --headless --path godot --fixed-fps 30 -s res://tests/treffen_709.gd
# Exit 0 = jede Lücke ≤ LUFT_M, 1 sonst; TREFF_LOG=1 druckt jeden Treffer.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const LUFT_M := 0.05
const TIEF_M := -0.06     # Biss: tiefer als 6 cm im Körper ist durch ihn hindurch (E3; die Klinge im Getroffenen ist der Treffer selbst)
var FENSTER := int(OS.get_environment("FENSTER")) if OS.get_environment("FENSTER") != "" else 3
const DAUER_BILDER := 30 * 90
const KOPF := ["Head", "Jaw", "Tongue", "kopf", "hand", "Hand", "Claw", "claw", "Fang", "fang", "Mouth", "mouth", "Pincer", "Mandible"]

var log_an := OS.get_environment("TREFF_LOG") != ""
var hurt_vor := {}
var verlauf := {}      # Paar „a>b“ -> Ring der letzten Lücken [Bild, Lücke]
var offen := []        # [Bild des Aufschlags, Kampf, Angreifer, Ziel, Art]
var treffer := []      # [Kampf, Angreifer, Art, Ziel, Lücke beim Aufschlag, kleinste im Fenster, Bewegung]
var befund := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	var gegner := (OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "WOLVES").split(",")
	var klassen := (OS.get_environment("KLASSEN") if OS.get_environment("KLASSEN") != "" else "FIGHTER,CLERIC").split(",")
	for g in gegner:
		for k in klassen:
			var sd := int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7
			seed(sd)
			var p = Probe.new()
			p.hero_cls = k
			p.merc_cls = "FIGHTER" if k != "FIGHTER" else "CLERIC"
			p.foe = g
			root.add_child(p)
			await process_frame
			p._start(sd)
			for i in 4:
				await process_frame
			var kf = p.fight
			if kf == null:
				print("TREFFEN709 kein Kampf %s/%s" % [g, k])
				befund += 1
				p.queue_free()
				continue
			if kf.mars.find("merc") != null:
				kf.mars.find("merc").auto = true
			kf.mars.set_autopilot(true)
			if not kf.busy:
				kf.go_on()
			var kampf := "%s/%s" % [g, k]
			hurt_vor.clear()
			verlauf.clear()
			var n := 0
			while n < DAUER_BILDER:
				await process_frame
				n += 1
				_bild(kf, n, kampf)
				if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
					break
				if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
					if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
						kf.go_on()
					else:
						var c = kf.mars.current()
						var ts: Array = kf.mars.targets(c)
						kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
			for i in FENSTER + 1:
				await process_frame
				n += 1
				_bild(kf, n, kampf)
			print("Kampf %s: %s nach %d Bildern" % [kampf, kf.mars.outcome, n])
			kf.queue_free()
			p.queue_free()
			await process_frame
	_bilanz()
	quit(1 if befund > 0 else 0)


## Strecken der Waffe [a, b, Radius]: Klinge, Stab, Axt als Strecke längs des Kastens; ohne Waffe Kopf, Kiefer, Hände
func _waffe(f) -> Array:
	var out: Array = []
	for g in f.traegt():
		var nm := String(g[2])
		if nm == "" or nm.contains("shield") or nm.contains("Shield"):
			continue
		var box: AABB = g[1]
		var lang := box.get_longest_axis_index()
		var p0: Vector3 = box.get_center()
		var p1: Vector3 = p0
		p0[lang] = box.position[lang]
		p1[lang] = box.end[lang]
		out.append([g[0] * p0, g[0] * p1, 0.0, nm])
	if not out.is_empty():
		return out
	var ks: Array = f.kapseln()
	if f.fighter.monster == null:
		for i in range(10, mini(12, ks.size())):     # Unterarm bis Hand
			out.append(ks[i] + ["Hand"])
		return out if not out.is_empty() else ks
	for c in ks:
		if c.size() > 3:
			for w in KOPF:
				if String(c[3]).contains(w):
					out.append(c)
					break
	return out if not out.is_empty() else ks


## Körper des Ziels: Kapseln der Figur; bei Gegnern ohne passende Dicke (kapseln() gibt unbekannten Knochen 5 cm) Rumpf, Hals
## und Kopf dicker nach dem Namen des Knochens (Richtwert, Kobold- und Krogg-Gerüst)
const DICKE := [["spine", 0.15], ["chest", 0.14], ["belly", 0.14], ["waist", 0.13], ["pelvis", 0.15], ["body", 0.15], ["torso", 0.15],
	["abdomen", 0.15], ["thorax", 0.12], ["neck", 0.08], ["head", 0.1], ["thigh", 0.08], ["upperarm", 0.06], ["upL", 0.05], ["upR", 0.05]]
func _koerper(b) -> Array:
	var ks: Array = b.kapseln()
	if b.fighter.monster == null:
		return ks
	var s := absf(b.model.global_transform.basis.get_scale().x) if b.model else 1.0
	var out: Array = []
	for c in ks:
		var r: float = c[2]
		if c.size() > 3 and r <= 0.05 * s + 0.001:
			var nm := String(c[3]).to_lower()
			for d in DICKE:
				if nm.contains(String(d[0]).to_lower()):
					r = float(d[1]) * s
					break
		out.append([c[0], c[1], r] + (c.slice(3) if c.size() > 3 else []))
	return out


## Abstand Waffe zum Körper; zusätzlich zum Schild des Ziels (Kasten), falls kleiner, als zweite Zahl
func _luecke(a, b) -> Array:
	var best := INF
	var schild := INF
	var tk: Array = b.koerper()
	var ws: Array = _waffe(a)
	for w in ws:
		for c in tk:
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


func _bild(kf, n: int, kampf: String) -> void:
	var figs: Array = kf.figures.values()
	# Lücken jedes Paares Gegner/Held in jedem Bild (Ring), damit das Fenster vor dem Aufschlag da ist
	for a in figs:
		if not a.visible or a.down:
			continue
		for b in figs:
			if a == b or not b.visible or (a.fighter.monster == null) == (b.fighter.monster == null):
				continue
			var key := "%s>%s" % [a.fighter.id, b.fighter.id]
			var r: Array = verlauf.get(key, [])
			var l: Array = _luecke(a, b)
			r.append([n, l[0], String(a.anim.current_animation) if a.anim else "", l[1], a.anim.current_animation_position if a.anim and a.anim.current_animation != "" else -1.0, Vector2(a.position.x - b.position.x, a.position.z - b.position.z).length()])
			if r.size() > 2 * FENSTER + 2:
				r.pop_front()
			verlauf[key] = r
	if OS.get_environment("ZUG709") != "":
		for f in figs:
			var lp: Vector3 = hurt_vor.get("pos_" + f.fighter.id, f.position)
			if f.position.distance_to(lp) > 0.001:
				print("ZUG709 Bild %d %s %s gang %s ab (%.2f, %.2f) um %.3f" % [n, f.fighter.id, String(f.anim.current_animation) if f.anim else "", f.gang, f.position.x, f.position.z, f.position.distance_to(lp)])
			hurt_vor["pos_" + f.fighter.id] = f.position
	# neuer Aufschlag: Angreifer aus der Meldung (shown wird beim Aufschlag gesetzt, vor dem Treffer)
	for b in figs:
		var id: String = b.fighter.id
		if b.hurt_at >= 0.0 and b.hurt_at != hurt_vor.get(id, -1.0):
			var e: Dictionary = kf.shown
			var actor = e.get("actor")
			var fx = kf._fx_of(e, kf.mars.find(actor) if actor != null else null, kf.mars.find(id), true) if actor != null and kf.has_method("_fx_of") else null
			if actor != null and kf.figures.has(actor) and actor != id and fx == null and e.get("spell") == null:
				offen.append([n, kampf, actor, id, str(e.get("cue", ""))])
				if OS.get_environment("DIAG709") != "":
					var af = kf.figures[actor]
					for w in _waffe(af):
						var best := INF
						for c in b.kapseln():
							var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(w[0], w[1], c[0], c[1])
							best = minf(best, pq[0].distance_to(pq[1]) - float(w[2]) - float(c[2]))
						print("DIAG709 %s %s r %.2f Lücke %.2f, Höhe %.2f–%.2f" % [actor, w[3] if w.size() > 3 else "?", w[2], best, w[0].y, w[1].y])
					var dz: Vector3 = Vector3(af.position.x - b.position.x, 0, af.position.z - b.position.z).normalized()
					var km := 0.0
					for c in b.kapseln():
						for q in [c[0], c[1]]:
							km = maxf(km, dz.dot(q - b.position) + float(c[2]))
					var teile := "Körper %.2f" % km
					for g in b.traegt():
						var m := -INF
						for i in 8:
							m = maxf(m, dz.dot((g[0] as Transform3D) * (g[1] as AABB).get_endpoint(i) - b.position))
						teile += ", %s %.2f" % [g[2], m]
					print("DIAG709 vorne je Teil (beim Aufschlag): " + teile)
					print("DIAG709 Abstand Ursprung %.2f, body_r Ziel %.2f, Ziel vorne %.2f" % [Vector2(af.position.x - b.position.x, af.position.z - b.position.z).length(), b.body_r(), b.vorne(af.position - b.position)])
		hurt_vor[id] = b.hurt_at
	# Fenster voll: auswerten
	var rest := []
	for o in offen:
		if o[1] != kampf:
			continue
		if n < o[0] + FENSTER:
			rest.append(o)
			continue
		var r: Array = verlauf.get("%s>%s" % [o[2], o[3]], [])
		var beim := INF
		var klein := INF
		var klein_s := INF
		var bew := ""
		var wo := 0
		var spur := ""
		var k0 := INF
		for x in r:
			if absi(x[0] - o[0]) <= FENSTER and x[1] < k0:
				k0 = x[1]
				wo = x[0] - o[0]
			if OS.get_environment("SPUR709") != "":
				spur += " %+d:%.2f/%s@%.2f d%.2f" % [x[0] - o[0], x[1], x[2], x[4], x[5]]
		for x in r:
			if absi(x[0] - o[0]) <= FENSTER:
				klein = minf(klein, x[1])
				klein_s = minf(klein_s, x[3])
			if x[0] == o[0]:
				beim = x[1]
				bew = x[2]
		var art: String = kf.figures[o[2]].fighter.monster.id if kf.figures.has(o[2]) and kf.figures[o[2]].fighter.monster != null else "Held " + kampf.get_slice("/", 1)
		treffer.append([kampf, o[2], art, o[3], beim, klein, bew, klein_s])
		if log_an or klein > LUFT_M:
			print("Treffer Bild %d %s: %s → %s, Lücke beim Aufschlag %.2f m, kleinste ±%d %.2f m (Schild %.2f) bei %+d Bildern, %s (%s)%s" % [o[0], kampf, o[2], o[3], beim, FENSTER, klein, klein_s, wo, bew, o[4], spur])
	offen = rest


func _bilanz() -> void:
	var je := {}     # Art -> [n, Luftschläge, größte Lücke, Beispiel, nur am Schild, zu tief, tiefste]
	for t in treffer:
		var e: Array = je.get(t[2], [0, 0, -INF, "", 0, 0, INF])
		e[0] += 1
		e[6] = minf(e[6], t[5])
		if t[5] < TIEF_M and not String(t[6]).begins_with("SS_"):
			e[5] += 1
		if t[5] > LUFT_M and t[7] <= LUFT_M:
			e[4] += 1
		if t[5] > LUFT_M:
			e[1] += 1
			if t[5] > e[2]:
				e[3] = "%s %s → %s %.2f m (%s)" % [t[0], t[1], t[3], t[5], t[6]]
		e[2] = maxf(e[2], t[5])
		je[t[2]] = e
	for art in je:
		var e: Array = je[art]
		print("Angreifer %s: %d Treffer, %d mit Luft über %.0f cm (davon %d am Schild), größte Lücke %.2f m, %d zu tief (tiefste %.2f m)%s" % [art, e[0], e[1], LUFT_M * 100.0, e[4], e[2], e[5], e[6], ("; " + e[3]) if e[3] != "" else ""])
		befund += e[1] + e[5]
	print("TREFFEN709 %d Treffer, %d Luftschläge" % [treffer.size(), befund])
