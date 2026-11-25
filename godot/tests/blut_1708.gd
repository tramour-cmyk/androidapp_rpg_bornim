extends SceneTree
# 1708 (Chef 25.11., 16:03: „das Blut muss da anfangen, wo jemand getroffen wird. Das Blut materialisiert sich nicht irgendwo im
# Raum, sondern da, wo man getroffen wird“): echter Kampfort je Gegnerart, Held und Kleriker gegen sie, Ring gut. Je Treffer mit Blut
# (kampf_ui.bleeding neu, im Bild des Aufschlags) der Berührungspunkt Angriffsteil–Körper: die Stelle der Kapseln des Getroffenen
# (Oberfläche) nächst am Angriffsteil des Angreifers (Waffe in der Hand oder im Modell, im Prankenhieb die linke Pranke, beim Tier
# Kopf, Kiefer, Zunge; wie 709 _hieb_bahn, hier eigens nachgebaut). Fernangriff (Pfeil, Zauber): die Stelle des Rumpfs zum Schützen
# (figur.treffpunkt_fern, 601.1). Gemessen am Schirm, in Körperhöhen (_tall):
#  - Beginn der Tropfen (kampf_ui blut_ursprung, sonst wie _draw_blood auf origin/main) zum Berührungspunkt, im Bild des Aufschlags;
#  - Blutfleck (TrefferFx „treffer“, kampfort _fx_szene2) zum Berührungspunkt, im selben Bild, wenn das Effektpaket da ist;
#  - geht mit: 0,6 s danach je Bild der Beginn der Tropfen zum Berührungspunkt, der mit dem nächsten Knochen des Getroffenen geht.
# Grenze BLUT_AB je Treffer. Messung (sperrt nicht): Weite der Tropfen vom Beginn (Körperhöhen), Treffer ohne Gerüst oder Angriffsteil.
# 1708 B (Chef 19:22, 16:03): auch das Angriffsteil selbst: beim Aufschlag eines Treffers mit Blut reicht es bis an den Körper
# (Lücke Angriffsteil–Körper höchstens BLUT_AB Körperhöhen, Körperhöhe aus den Kapseln des Getroffenen); je Biss oder Prankenhieb
# an einer Figur mit Schild der nächste Augenblick an ihr: endet er am Schild (Schild näher als der Körper, Körper nicht berührt),
# darf kein Blut kommen. Fall je Schildbiss: Treffer mit Schaden (Blut), Biss endet am Schild; oder Fehlschlag ohne Blut.
# Ausgabe „BLUT1708 n Treffer, k über …“, „LUECKE1708 …“, „SCHILD1708 …“. Ohne Kaufmodelle (kampf/daten): übersprungen.
# Aufruf im Ordner godot: --headless --fixed-fps 30 -s res://tests/blut_1708.gd   (GEGNER1708=WOLVES,KROGG … nur diese)

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const TrefferFx = preload("res://kampf/treffer_fx.gd")
const Bedienung = preload("res://skripte/bedienung.gd")
const FPS := 30.0
const BLUT_AB := 0.05
const MIT_S := 0.6
const JE_ART := 3          # so viele Treffer mit Blut je Gegnerart
const ZEIT_S := 120.0      # längstens je Gegnerart
## Kapitel 1 (probe.gd FOES ohne Doppelte: RUDEL, RATTE, FLEDERMAUS, SPINNE, SCOUTS sind dieselben Arten)
const ARTEN := ["WOLVES", "KROGG", "GRAK", "GRIMM", "SPIDER", "SCOUT", "RATS", "BATS", "GOBLINS", "SHAMANS", "KOBOLDS", "BOARS",
	"CENTIPEDES", "LEECHES", "SLUGS", "SKELETONS", "WIEDERGAENGER3", "GRABHUNDE"]
const BISS := ["head", "jaw", "tongue", "kopf", "fang", "mouth", "maul", "schnauze", "beak"]
const PRANKE := ["hand_l", "index_", "middle_", "pinky_", "ring_", "thumb_"]

var n_treffer := 0
var n_ueber := 0
var n_fleck := 0
var n_fleck_ueber := 0
var n_ohne := 0
var n_luecke := 0          # 1708 B: Treffer mit Blut, Angriffsteil weiter als BLUT_AB Körperhöhen vom Körper
var n_nah := 0             # Nahtreffer mit gemessener Lücke
var luecke_max := 0.0
var n_schildbiss := 0      # Bisse und Prankenhiebe, die am Schild enden
var n_schildblut := 0      # davon mit Blut (Treffer mit Schaden)
var schild_zeilen := []
var mit_max := 0.0
var weiten := []
var zeilen := []
var sichtbar := {}     # Figur -> Knochen (Welt), wie zu sehen: im skeleton_updated gelesen (mit den Modifiern: Atem, Zucken …)


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	seed(1708)
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	Bedienung.lade()
	Bedienung.blut = maxi(Bedienung.blut, 2)
	if not FileAccess.file_exists("res://kampf/daten/kauf.txt"):
		print("übersprungen: ohne Kaufmodelle (kampf/daten)")
		quit(0)
		return
	var arten: Array = Array(OS.get_environment("GEGNER1708").split(",")) if OS.get_environment("GEGNER1708") != "" else ARTEN
	for art in arten:
		await _art(String(art))
	print("BLUT1708 Fleck: %d gemessen, %d über %.2f; ohne Gerüst oder Angriffsteil (wie bisher Mitte): %d; Effektpaket %s" % [n_fleck, n_fleck_ueber, BLUT_AB, n_ohne, "da" if TrefferFx.aktiv() else "fehlt"])
	print("MESSUNG1708 Beginn geht mit dem Getroffenen: höchstens %.2f Körperhöhen daneben (0,6 s nach dem Aufschlag)" % mit_max)
	if not weiten.is_empty():
		weiten.sort()
		print("MESSUNG1708 Weite der Tropfen vom Beginn: Mitte %.2f, größte %.2f Körperhöhen (%d Treffer)" % [weiten[weiten.size() / 2], weiten[-1], weiten.size()])
	print("LUECKE1708 %d Nahtreffer mit Blut, %d mit Angriffsteil über %.2f Körperhöhen vom Körper (größte %.2f)" % [n_nah, n_luecke, BLUT_AB, luecke_max])
	print("SCHILD1708 %d Bisse am Schild, davon %d mit Blut (Treffer mit Schaden, Biss endet am Schild)" % [n_schildbiss, n_schildblut])
	var fehler := n_luecke + n_schildblut + n_ueber + n_fleck_ueber + (1 if n_treffer == 0 else 0) + (1 if mit_max > BLUT_AB else 0)
	print("BLUT1708 %d Treffer, %d über %.2f Körperhöhen, %s" % [n_treffer, n_ueber, BLUT_AB, "gut" if fehler == 0 else "FEHLER %d" % fehler])
	quit(1 if fehler > 0 else 0)


func _art(art: String) -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = art
	root.add_child(p)
	await process_frame
	p._start(1708)
	for i in 4:
		await process_frame
	var kf = p.fight
	kf.mars.find("merc").auto = true
	kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
	while kf.verhuellt:
		await process_frame
	sichtbar.clear()
	for f in kf.figures.values():
		var fsk := f._find(f.model, "Skeleton3D") as Skeleton3D if f.model != null else null
		if fsk != null:
			fsk.skeleton_updated.connect(func() -> void:
				var h: Array = sichtbar.get(f, [])
				h.append(_haltung(f))
				if h.size() > 4:
					h.pop_front()
				sichtbar[f] = h)
	var zug := "paw" if art == "KROGG" else ""
	Mars.test_gegnerzug = zug
	var t0_blut := int(kf.ui.bleeding.get("t0", -1)) if not kf.ui.bleeding.is_empty() else -1
	var fx0: Variant = TrefferFx.zuletzt
	var ring_seit := -1
	var n := 0
	var hier := 0
	var mit: Array = []        # [Getroffener, Knochen, Versatz im Knochen, bis Bild]
	var pranken := 0
	var bisse := {}            # 1708 B: Angreifer -> {an, bild, koerper, schild, hoch, blut}
	var je: int = int(OS.get_environment("JE1708")) if OS.get_environment("JE1708") != "" else JE_ART
	while n < int(FPS * ZEIT_S * je / JE_ART) and (hier < je or art == "KROGG" and pranken == 0 and hier < 4 * je):
		await process_frame
		n += 1
		if Mars.test_gegnerzug == "" and zug != "":
			Mars.test_gegnerzug = zug
		# das Blut kommt im Zeitgeber des Aufschlags, vor dem Stellen der Gerüste in diesem Bild: gemessen im nächsten Bild, mit der
		# Haltung, wie sie im Bild des Aufschlags zu sehen war (skeleton_updated)
		var bl: Dictionary = kf.ui.bleeding
		_bisse(art, kf, bisse, bl if not bl.is_empty() and int(bl.t0) != t0_blut else {})
		if not bl.is_empty() and int(bl.t0) != t0_blut and kf.figures.has(bl.by) and kf.figures.has(bl.on):
			t0_blut = int(bl.t0)
			hier += 1
			var m: Array = _messe(art, kf, kf.figures[bl.by], kf.figures[bl.on], fx0)
			fx0 = TrefferFx.zuletzt
			if not m.is_empty():
				mit = m
			pranken += 1 if String(kf.figures[bl.by].anim.current_animation) == "Prankenhieb" else 0
		if not mit.is_empty() and Engine.get_process_frames() <= int(mit[3]) and is_instance_valid(mit[0]) and not kf.ui.bleeding.is_empty() and int(kf.ui.bleeding.t0) == int(mit[4]):
			var on = mit[0]
			var sk: Skeleton3D = on._find(on.model, "Skeleton3D")
			var q: Vector3 = ((sichtbar[on] as Array)[-1].pose[int(mit[1])] as Transform3D) * (mit[2] as Vector3)
			var d: float = kf.screen_of(kf.to_local(q)).distance_to(_ursprung(kf.ui, on)) / maxf(kf.ui._tall(on), 1.0)
			mit_max = maxf(mit_max, d)
			if OS.get_environment("SCHAU1708") != "":
				var an: Variant = kf.ui.bleeding.get("an")
				var ap: Vector3 = (an as Node3D).global_position if an is Node3D and is_instance_valid(an) else Vector3.INF
				print("1708 mit Bild %d %s: %.3f, Haut: Anker %.3f m, Punkt %.3f m" % [Engine.get_process_frames(), on.fighter.id, d, _haut(on, ap), _haut(on, q)])
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if kf.ring_open:
			ring_seit = n if ring_seit < 0 else ring_seit
			if n - ring_seit >= int(kf.RING_MS * kf.ring_faktor / 1000.0 * FPS):
				kf._answer_ring(Mars.GOOD)
		else:
			ring_seit = -1
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				var ts: Array = kf.mars.targets(kf.mars.current())
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	Mars.test_gegnerzug = ""
	for by in bisse.keys():
		_biss_ende(art, by, bisse[by])
	if hier == 0:
		print("1708 %s: kein Treffer mit Blut in %.0f s" % [art, n / FPS])
	p.queue_free()
	await process_frame
	await process_frame


## Beginn der Tropfen am Schirm: wie _draw_blood (blut_ursprung, auf origin/main die Mitte: Fuß + 0,55 Körperhöhen)
func _ursprung(ui, on) -> Vector2:
	if ui.has_method("blut_ursprung"):
		return ui.blut_ursprung(on)
	var to: Vector2 = ui._foot(on)
	return Vector2(to.x, to.y - ui._tall(on) * 0.55)


## Angriffsteil des Angreifers als Kapseln [a, b] (Welt), wie 709 _hieb_bahn
func _teile(f) -> Array:
	var out: Array = []
	var sk := f._find(f.model, "Skeleton3D") as Skeleton3D if f.model != null else null
	if sk == null:
		return out
	if f.anim != null and String(f.anim.current_animation) == "Prankenhieb":
		for c in f.kapseln():
			var nm := String(c[3]) if c.size() > 3 else ""
			if nm == "hand_l" or nm.ends_with("_l") and PRANKE.any(func(w): return nm.begins_with(w)):
				out.append(c)
		return out
	for at in f.find_children("*", "BoneAttachment3D", true, false):
		var was := String(at.get_meta("was", ""))
		if was == "" or was.contains("shield"):
			continue
		# der Anhänger kann in diesem Augenblick noch die Haltung des letzten Bilds zeigen: über den Knochen, wie er jetzt steht
		var kn: Transform3D = sk.global_transform * sk.get_bone_global_pose(at.bone_idx)
		var hm: Dictionary = f.klinge_halt(at)
		if not hm.is_empty():
			var tr: Transform3D = kn * (at.global_transform.affine_inverse() * (at.get_child(0) as Node3D).global_transform)
			out.append([tr * (hm.griff as Vector3), tr * (hm.spitze as Vector3), 0.0])
			continue
		for mm in at.find_children("*", "MeshInstance3D", true, false):
			var box: AABB = mm.get_aabb()
			var ax := box.get_longest_axis_index()
			var p0: Vector3 = box.get_center()
			var p1: Vector3 = p0
			p0[ax] = box.position[ax]
			p1[ax] = box.end[ax]
			var tm: Transform3D = kn * (at.global_transform.affine_inverse() * mm.global_transform)
			out.append([tm * p0, tm * p1, 0.0])
	if out.is_empty() and f.fighter.monster != null:
		for at in f.find_children("*", "BoneAttachment3D", true, false):
			if String(at.bone_name).to_lower().contains("hand") and not at.has_meta("was"):
				var kn2: Transform3D = sk.global_transform * sk.get_bone_global_pose(at.bone_idx)
				for mm in at.find_children("*", "MeshInstance3D", true, false):
					var box: AABB = mm.get_aabb()
					var ax := box.get_longest_axis_index()
					var p0: Vector3 = box.get_center()
					var p1: Vector3 = p0
					p0[ax] = box.position[ax]
					p1[ax] = box.end[ax]
					var tm: Transform3D = kn2 * (at.global_transform.affine_inverse() * mm.global_transform)
					out.append([tm * p0, tm * p1, 0.0])
		if not out.is_empty():
			return out
		for c in f.kapseln():
			var nm := String(c[3]).to_lower() if c.size() > 3 else ""
			if not nm.begins_with("ik_") and (BISS + ["chelicere", "hand"]).any(func(w): return nm.contains(w)):
				out.append(c)
	return out


## ein Treffer mit Blut: [Getroffener, Knochen, Versatz, bis Bild] für „geht mit“, leer ohne Berührungspunkt
func _messe(art: String, kf, by, on, fx0) -> Array:
	# im Bild des Aufschlags, wie kapseln() das Gerüst liefert (Haltung der Bewegung; der Zeitgeber des Aufschlags lief schon)
	var hb: Dictionary = _haltung(by)
	var ho: Dictionary = _haltung(on)
	# Fernangriff wie kampfort _fx_of: Zauber, Netzwurf der Spinne, Pfeil
	var fern: bool = kf.shown.get("spell") != null or by.fighter.ranged() or by.fighter.monster != null and by.fighter.monster.id == Mars.SPIDER and by.netz_los_ms >= 0
	var punkt := Vector3.INF
	var luecke := INF
	var naechst := INF
	var teil := ""
	if fern:
		punkt = on.treffpunkt_fern(by.cast_point() if by.cast_point() != null else by.head())
		teil = "Geschoss"
	else:
		var ws: Array = hb.teile
		teil = "Pranke" if hb.anim == "Prankenhieb" else ("Klinge" if by.fighter.monster == null or by.traegt().any(func(g): return not String(g[2]).contains("shield")) else "Biss")
		for w in ws:
			for c in ho.koerper:
				var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(w[0], w[1], c[0], c[1])
				var d: Vector3 = pq[0] - pq[1]
				if d.length() < naechst:
					naechst = d.length()
					luecke = d.length() - float(c[2])
					punkt = pq[1] + (d.normalized() * float(c[2]) if d.length() > float(c[2]) else d)
	var ui = kf.ui
	var hoch: float = maxf(ui._tall(on), 1.0)
	var ur: Vector2 = _ursprung(ui, on)
	weiten.append(_weite(ui, on) / hoch)
	if punkt == Vector3.INF:
		n_ohne += 1
		print("1708 %s %s %s an %s: ohne Gerüst oder Angriffsteil" % [art, teil, by.fighter.id, on.fighter.id])
		return []
	n_treffer += 1
	# der Punkt im Raum des Knochens, an dem das Blut hängt (sonst des nächsten), in dieses Bild mitgenommen
	var sk := on._find(on.model, "Skeleton3D") as Skeleton3D
	var an: Variant = kf.ui.bleeding.get("an")
	var best: int = int((an as Node3D).get_meta("knochen", -1)) if an is Node3D and is_instance_valid(an) else -1
	var bd := INF
	var pose: Array = ho.pose
	for i in (pose.size() if best < 0 else 0):
		var nm := sk.get_bone_name(i).to_lower()
		if nm.begins_with("ik_") or nm == "root":
			continue
		var pa := sk.get_bone_parent(i)
		var a: Vector3 = (pose[i] as Transform3D).origin
		var b: Vector3 = a if pa < 0 else (pose[pa] as Transform3D).origin
		var d := Geometry3D.get_closest_point_to_segment(punkt, a, b).distance_to(punkt)
		if d < bd:
			bd = d
			best = pa if pa >= 0 else i
	var aus: Vector3 = (pose[best] as Transform3D).affine_inverse() * punkt
	var am: Vector2 = kf.screen_of(kf.to_local(punkt))
	var d1 := am.distance_to(ur) / hoch
	if OS.get_environment("SCHAU1708") != "" and on.has_method("treffpunkt"):
		print("1708 schau: Test %s, Figur jetzt %s, Anker %s (Knochen %s); Teile Test %d, Figur %d; Haltung von Bild %d/%d, jetzt %d" % [punkt, on.treffpunkt(by), (an as Node3D).global_position if an is Node3D else "-", (an as Node3D).get_meta("knochen", "–") if an is Node3D else "-", (hb.teile as Array).size(), by.angriffs_kapseln().size(), hb.bild, ho.bild, Engine.get_process_frames()])
	var zu: bool = d1 > BLUT_AB
	n_ueber += 1 if zu else 0
	var lk := ""
	if not fern:
		var lh: float = maxf(luecke, 0.0) / _hoehe_m(ho.koerper)
		n_nah += 1
		luecke_max = maxf(luecke_max, lh)
		var sl: float = _abstand(hb.teile, ho.schild)
		lk = ", Lücke %.2f Körperhöhen%s" % [lh, (", Schild %.2f" % (maxf(sl, 0.0) / _hoehe_m(ho.koerper))) if sl < INF else ""]
		if lh > BLUT_AB:
			n_luecke += 1
			zu = true
	var fl := ""
	var fx: Variant = TrefferFx.zuletzt
	if fx != fx0 and fx is Node3D and is_instance_valid(fx):
		var d2: float = am.distance_to(kf.screen_of(kf.to_local((fx as Node3D).global_position))) / hoch
		n_fleck += 1
		n_fleck_ueber += 1 if d2 > BLUT_AB else 0
		fl = ", Fleck %.2f" % d2
		zu = zu or d2 > BLUT_AB
	print("%s 1708 %s %s %s an %s: Tropfen ab %.2f Körperhöhen vom Berührungspunkt%s (Angriffsteil %.2f m vom Körper%s)" % [
		"FEHLER" if zu else "gut", art, teil, by.fighter.id, on.fighter.id, d1, fl, luecke if luecke < INF else 0.0, lk])
	return [on, best, aus, Engine.get_process_frames() + int(MIT_S * FPS), int(kf.ui.bleeding.get("t0", -1))]


## Angriffsteil, Körper und Knochen (Welt) von [f] in diesem Bild
func _haltung(f) -> Dictionary:
	var sk := f._find(f.model, "Skeleton3D") as Skeleton3D if f.model != null else null
	var pose: Array = []
	if sk != null:
		for i in sk.get_bone_count():
			pose.append(sk.global_transform * sk.get_bone_global_pose(i))
	return {"teile": _teile(f), "koerper": f.koerper(), "schild": f.schild_kapseln() if f.has_method("schild_kapseln") else [], "pose": pose, "anim": String(f.anim.current_animation) if f.anim != null else "", "bild": Engine.get_process_frames()}


## weiteste Strecke eines Tropfens vom Beginn (px), wie _draw_blood (gleiche Würfel), bis er landet
func _weite(ui, on) -> float:
	var k = ui.kampfort
	var bl: Dictionary = ui.bleeding
	var level: int = k.blood_level()
	var to: Vector2 = ui._foot(on)
	var from: Vector2 = ui._foot(k.figures[bl.by]) if k.figures.has(bl.by) else to
	var tall: float = ui._tall(on)
	var dx := to.x - from.x
	var dy := (to.y - from.y) * 0.5 - 0.3 * to.distance_to(from)
	var base := -25.0 if dx == 0.0 and dy == 0.0 else rad_to_deg(atan2(dy, dx))
	var unit := tall / 40.0
	var origin: Vector2 = _ursprung(ui, on)
	var rnd := RandomNumberGenerator.new()
	rnd.seed = int(bl.seed) * 31
	var count := maxi(int(((15 if level >= 2 else 6) + ((8 if level >= 2 else 3) if bl.crit else 0)) * (0.55 + 1.1 * float(bl.hurt))), 2)
	var weit := 0.0
	for i in count:
		var ang := deg_to_rad(base + rnd.randf_range(-70.0, 55.0))
		var speed := unit * ((rnd.randf() * 70.0 + 40.0) if level >= 2 else (rnd.randf() * 45.0 + 25.0))
		rnd.randf()
		rnd.randf()
		rnd.randi_range(0, 2)
		for j in 31:
			var t := j / 30.0
			var x := cos(ang) * speed * t
			var y := sin(ang) * speed * t + 160.0 * unit * t * t
			if origin.y + y >= to.y:
				y = to.y - origin.y
			weit = maxf(weit, Vector2(x, y).length())
			if origin.y + y >= to.y:
				break
	return weit


## Abstand (m) von [p] zur Oberfläche der Kapseln von [f] (< 0: darin)
func _haut(f, p: Vector3) -> float:
	var best := INF
	for c in f.koerper():
		best = minf(best, Geometry3D.get_closest_point_to_segment(p, c[0], c[1]).distance_to(p) - float(c[2]))
	return best


## Körperhöhe (m) aus den Kapseln
func _hoehe_m(koerper: Array) -> float:
	var lo := INF
	var hi := -INF
	for c in koerper:
		lo = minf(lo, minf((c[0] as Vector3).y, (c[1] as Vector3).y) - float(c[2]))
		hi = maxf(hi, maxf((c[0] as Vector3).y, (c[1] as Vector3).y) + float(c[2]))
	return maxf(hi - lo, 0.1)


## kleinster Abstand (m) der Strecken [teile] zur Oberfläche der Kapseln [ks] (< 0: darin), INF ohne
func _abstand(teile: Array, ks: Array) -> float:
	var best := INF
	for w in teile:
		for c in ks:
			var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(w[0], w[1], c[0], c[1])
			best = minf(best, pq[0].distance_to(pq[1]) - float(c[2]) - float(w[2]))
	return best


## 1708 B: je Bild jeder Biss oder Prankenhieb an einer Figur mit Schild; gemerkt wird der Augenblick, in dem das Angriffsteil ihr
## (Körper oder Schild) am nächsten ist, und ob in dem Biss Blut kam
func _bisse(art: String, kf, bisse: Dictionary, blut: Dictionary) -> void:
	if OS.get_environment("SCHAU1708B") != "":
		for f in kf.figures.values():
			if f.fighter.side == "FOES" or f.anim == null or not sichtbar.has(f) or not String(f.anim.current_animation).contains("Attack") and String(f.anim.current_animation) != "Hieb":
				continue
			for o in kf.figures.values():
				if o.fighter.side == "FOES" and not o.down and sichtbar.has(o):
					print("1708B Bild %d %s %s %.2f s an %s: Lücke %.2f m, %s%s" % [Engine.get_process_frames(), f.fighter.id, f.anim.current_animation, f.anim.current_animation_position, o.fighter.id,
						_abstand((sichtbar[f] as Array)[-1].teile, (sichtbar[o] as Array)[-1].koerper), o.anim.current_animation, " BLUT" if not blut.is_empty() else ""])
	for f in kf.figures.values():
		if f.fighter.side != "FOES" or f.anim == null or not sichtbar.has(f):
			continue
		var an := String(f.anim.current_animation)
		var beisst: bool = an.to_lower().contains("biss") or an == "Prankenhieb"
		if not beisst:
			if bisse.has(f):
				_biss_ende(art, f, bisse[f])
				bisse.erase(f)
			continue
		var hb: Dictionary = (sichtbar[f] as Array)[-1]
		var b: Dictionary = bisse.get(f, {"an": null, "naechst": INF, "blut": false, "anim": an})
		for o in kf.figures.values():
			if o.fighter.side == "FOES" or o.down or not sichtbar.has(o):
				continue
			var ho: Dictionary = (sichtbar[o] as Array)[-1]
			if (ho.schild as Array).is_empty():
				continue
			var dk := _abstand(hb.teile, ho.koerper)
			var ds := _abstand(hb.teile, ho.schild)
			if minf(dk, ds) < float(b.naechst):
				b.merge({"an": o, "naechst": minf(dk, ds), "koerper": dk, "schild": ds, "hoch": _hoehe_m(ho.koerper), "bild": Engine.get_process_frames()}, true)
		if not blut.is_empty() and kf.figures.get(blut.by) == f:
			b.blut = true
		bisse[f] = b


func _biss_ende(art: String, by, b: Dictionary) -> void:
	if b.get("an") == null or not is_instance_valid(by):
		return
	var h: float = float(b.hoch)
	var dk: float = float(b.koerper) / h
	var ds: float = float(b.schild) / h
	var am_schild: bool = ds <= BLUT_AB and ds < dk and dk > BLUT_AB
	if not am_schild:
		return
	n_schildbiss += 1
	n_schildblut += 1 if b.blut else 0
	print("%s 1708 Schild %s %s %s an %s (Bild %d): Schild %.2f, Körper %.2f Körperhöhen; %s" % ["FEHLER" if b.blut else "gut", art, b.anim,
		by.fighter.id, b.an.fighter.id, int(b.bild), ds, dk, "Treffer mit Schaden, Blut, Biss endet am Schild" if b.blut else "ohne Blut"])
