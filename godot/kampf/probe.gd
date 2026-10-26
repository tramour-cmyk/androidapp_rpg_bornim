# 348.7: Probekampf wie im Systemmenü des alten Spiels (Skirmish.probe): Held und Söldner der gewählten Klassen auf
# Stufe 3, zwei Heiltränke, gegen das Wolfsrudel (oder Grak, Spinne, Späher). Erste Szene des Prüf-APKs, bis Toms
# Projekt den Kampf aus der Welt aufruft (Kampfort.setup).
extends Control

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Kampfort = preload("res://kampf/kampfort.gd")
const Figur = preload("res://kampf/figur.gd")
const CLASSES := ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]
const NAMES := {"FIGHTER": "Kämpfer", "WIZARD": "Magier", "ROGUE": "Schurke", "CLERIC": "Kleriker"}
const FOES := {"WOLVES": "Wolfsrudel", "GRAK": "Grak", "SPIDER": "Spinne", "SCOUT": "Späher", "RATS": "Ratten", "GRIMM": "Grimmzahn", "GOBLINS": "Goblins", "SCOUTS": "Goblin-Späher", "SHAMANS": "Goblin-Schamanen", "KOBOLDS": "Kobolde"}

var tables: Dictionary
var hero_cls := "FIGHTER"
var merc_cls := "WIZARD"
var foe := "WOLVES"
var box: VBoxContainer
var fight: Node
## the hero's name on the comparison picture (MarsShot: "Mira")
var still_name := ""


func _ready() -> void:
	tables = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var vs := get_viewport().get_visible_rect().size
	var th := Theme.new()
	th.default_font_size = int(vs.x / 412.0 * 16.0)
	theme = th
	box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = vs.x * 0.06
	box.offset_right = -vs.x * 0.06
	box.offset_top = vs.y * 0.08
	box.add_theme_constant_override("separation", int(vs.y * 0.012))
	add_child(box)
	_menu()
	for a in OS.get_cmdline_user_args():
		if a == "--kampf":
			_start()
		elif a.begins_with("--bild="):     # Vergleichsbild alt/neu: wie MarsShot (Kleriker, Söldner Kämpfer, Wölfe)
			_still(a.substr(7))


func _still(path: String) -> void:
	hero_cls = "CLERIC"
	still_name = "Mira"
	merc_cls = "FIGHTER"
	foe = OS.get_environment("GEGNER") if OS.has_environment("GEGNER") else "WOLVES"     # GEGNER=GRIMM, RATS …
	_start.call_deferred(7)
	var schau := OS.get_environment("SCHAU") != ""
	await get_tree().create_timer(1.0 if schau else 2.5).timeout
	if schau:     # Kurzvideo: gleich anhalten, nicht auf den Zug der Gruppe warten
		if OS.get_environment("OHNEUI") != "" and fight.ui != null:
			fight.ui.visible = false
		await _schau()
		return
	# wie im alten Bild: der Held ist dran, die Knöpfe stehen (höchstens 10 s warten)
	# im Zeitraffer bis zum Zug der Gruppe (die Gegner sind oft zuerst dran; Schritte sonst rund eine Minute)
	Engine.time_scale = 8.0
	var until := Time.get_ticks_msec() + 60000
	while Time.get_ticks_msec() < until and fight and (fight.busy or fight.playing or fight.mars.current().side != "PARTY"):
		await get_tree().process_frame
	Engine.time_scale = 1.0
	if fight:
		print("Dran %s, beschäftigt %s, spielt %s, %d ms" % [fight.mars.current().id, fight.busy, fight.playing, Time.get_ticks_msec()])
	await get_tree().create_timer(0.6).timeout
	# Würfelzeile ganz oder gar nicht (Prüfer Runde 4: „halb ausgeblendet“): beginnt gleich das Ausblenden, abwarten
	var ui = fight.ui
	if ui.roll_shown != null:
		var age: int = Time.get_ticks_msec() - ui.roll_at
		if age > ui.ROLL_MS - 300 and age < ui.ROLL_MS + ui.ROLL_FADE_MS:
			await get_tree().create_timer((ui.ROLL_MS + ui.ROLL_FADE_MS - age + 50) / 1000.0).timeout
	# 296.2: ZUSTAND=1 legt Zustände auf Held und ersten Wolf, um ihre Zeichen zu zeigen
	if OS.get_environment("ZUSTAND") != "":
		var fs: Array = fight.mars.fighters()
		fs[0].status = {"POISON": 2, "BLEED": 3}
		for f in fs:
			if f.side == "FOES" and f.standing():
				f.status = {"STUN": 1, "WEAK": 2}
				break
		# ein verwundeter Wolf, damit der Lebensbalken an der Ansage einen Rest zeigt
		for f in fs:
			if f.side == "FOES" and f.standing() and f.status.is_empty():
				f.hp = maxi(1, f.max_hp * 2 / 5)
				fight.shown.hp[f.id] = f.hp
				break
		fight.shown["status"] = fight.mars._statuses()
		await get_tree().create_timer(0.2).timeout
	# 296.2: SIEG=1 beendet den Kampf als Sieg und zeigt den Endschirm mit dem Lohn
	if OS.get_environment("SIEG") != "":
		fight.test_end(true)
		var stop := Time.get_ticks_msec() + 20000
		while Time.get_ticks_msec() < stop and (fight.busy or fight.playing or not fight.beats.is_empty()):
			await get_tree().process_frame
		await get_tree().create_timer(1.5).timeout
		print("Lohn ", fight.reward.get("lines", []))
	# 348.7: HALTUNG=Lefzen:0.5 hält alle Wölfe in dieser Bewegung an dieser Stelle (Sekunden), für Standbilder der Ruhebewegungen
	var hal := OS.get_environment("HALTUNG")
	if hal != "":
		for id in fight.figures:
			var fg = fight.figures[id]
			var hn: String = fg.scharren_name() if hal.get_slice(":", 0) == "Scharren" and fg.has_method("scharren_name") else hal.get_slice(":", 0)
			if fg.anim and fg.anim.has_animation(hn):
				fg.anim.play(hn, 0.0)
				fg.anim.seek(float(hal.get_slice(":", 1)), true)
				fg.anim.pause()
				fg.set_process(false)     # Runde 15: sonst zappelt der Wolf nach 4–9 s (Lefzen/Scharren) oder wechselt in die Hocke
				fg.fidget_at = 0
		await get_tree().create_timer(0.2).timeout
		for id in fight.figures:
			for sk in fight.figures[id].find_children("*", "Skeleton3D", true, false):
				var i: int = sk.find_bone("vpfoteL")
				if i >= 0:
					print("Pfote %s: %s, Kiefer %s" % [id, sk.get_bone_global_pose(i).origin.snapped(Vector3.ONE * 0.01), sk.get_bone_pose_rotation(sk.find_bone("kiefer")).get_euler().snapped(Vector3.ONE * 0.01)])
			for ps in fight.figures[id].find_children("Pfotenschatten", "MeshInstance3D", true, false):
				print("Pfotenschatten %s: %s sichtbar %s, Figur y %.3f" % [id, ps.global_position.snapped(Vector3.ONE * 0.01), ps.is_visible_in_tree(), fight.figures[id].global_position.y])
		await get_tree().create_timer(0.2).timeout
	if hal != "":     # Runde 15: unmittelbar vor dem Bild noch einmal an die Stelle (Kampfablauf kann umgeschaltet haben)
		for id in fight.figures:
			var fg = fight.figures[id]
			var hn: String = fg.scharren_name() if hal.get_slice(":", 0) == "Scharren" and fg.has_method("scharren_name") else hal.get_slice(":", 0)
			if fg.anim and fg.anim.has_animation(hn):
				fg.anim.play(hn, 0.0)
				fg.anim.seek(float(hal.get_slice(":", 1)), true)
				fg.anim.pause()
				if not fg.paws.is_empty():
					fg._paw_shadow_update()
				print("Haltung fest %s: %s" % [id, hn])
	_report_facing()
	_report_cover()
	_report_snout()
	_report_tail()
	if OS.get_environment("MASKE") != "":     # Kobold Runde 3b: Gegner flach magenta, als Maske für die Farbmessung gegen alt
		var mm := StandardMaterial3D.new()
		mm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mm.albedo_color = Color(1, 0, 1)
		for id in fight.figures:
			if fig_of(id).fighter.monster != null:
				for mi in fig_of(id).find_children("*", "MeshInstance3D", true, false):
					mi.material_override = mm
	for id in fight.figures:
		var fg = fight.figures[id]
		print("Haltung %s: %s, Ansage %s" % [id, fg.anim.current_animation if fg.anim else "-", fight.shown.intents.get(id, [{}])[0].get("effect", "")])
	if OS.get_environment("NAH") != "":     # NAH=gob2: Nahaufnahme des Kopfes aus Richtung der Kampfkamera (Gesicht prüfen)
		var fg = fight.figures[OS.get_environment("NAH")]
		var kopf: Vector3 = fg.head() - Vector3(0, 0.12, 0)
		var sk_n := _skeleton(fig_of(OS.get_environment("NAH")))
		if sk_n != null and sk_n.find_bone("neck-neckTop") >= 0:     # Kobold Runde 3d (3c: NAH=gob1 zeigte nur Boden): der Kopf am Halsknochen
			var bn := sk_n.find_bone("neck-neckTop")
			var pn := sk_n.get_bone_global_pose(bn)
			var vn: Vector3 = (sk_n.global_basis * (pn.basis * sk_n.get_bone_global_rest(bn).basis.inverse() * Vector3(0, 0, 1))).normalized()
			kopf = sk_n.global_transform * pn.origin + vn * 0.06 * fg._scale()
		var nah := Camera3D.new()
		fight.add_child(nah)
		nah.fov = 20.0
		var weg: Vector3 = (fight.cam.global_position - kopf).normalized()
		if OS.get_environment("NAHVORN") != "":     # Schamane Runde 3: von vorn auf das Gesicht (Blick des Kopfes, waagerecht)
			var fig = fig_of(OS.get_environment("NAH"))
			weg = fig.global_basis.z.normalized()
			if fig.neck:
				weg = weg.rotated(Vector3.UP, deg_to_rad(float(OS.get_environment("NAHVORN"))))
		nah.position = kopf + weg * float(OS.get_environment("NAHM") if OS.get_environment("NAHM") != "" else "1.4")
		nah.look_at(kopf)
		nah.make_current()
		if fight.ui != null:     # ui ist CanvasLayer, kein CanvasItem: die Anzeige blieb in der Nahaufnahme stehen
			fight.ui.visible = false
		await get_tree().process_frame
	if OS.get_environment("OHNEUI") != "" and fight.ui != null:     # Vergleichsblatt ohne Kampfanzeige (Schamane Runde 3; ui ist CanvasLayer)
		fight.ui.visible = false
		await get_tree().process_frame
	# 249: EFFEKT=KILL|CRIT|HARD (EFFEKTZIEL=<id>): der erste der Gruppe schlägt den ersten Gegner, Bildfolge ab dem Aufschlag
	# als <bild>-<ms>.png (Zoom, Ruck, Zittern, Blut); BLUT_TREFFER=0..1 wie schwer verwundet
	var fx := OS.get_environment("EFFEKT")
	if fx != "":
		var by = fight.mars.fighters().filter(func(x): return x.side == "PARTY")[0]
		var foes: Array = fight.mars.fighters().filter(func(x): return x.side == "FOES" and x.standing())
		var on = foes[0]
		if OS.get_environment("EFFEKTZIEL") != "":
			on = fight.mars.find(OS.get_environment("EFFEKTZIEL"))
		var lunge: int = fight.figures[by.id].strike(fight.figures[on.id], {"spell": null})
		await get_tree().create_timer(lunge * 0.42 / 1000.0).timeout
		# Leben wie nach dem echten Treffer (tödlich 0); die Ansage geht wie im Spiel erst mit der nächsten Meldung „fällt“
		var hp_now := {}
		for id in fight.shown.hp:
			hp_now[id] = fight.shown.hp[id]
		hp_now[on.id] = 0 if fx == "KILL" else maxi(1, int(hp_now[on.id]) - 6)
		fight.shown["hp"] = hp_now
		fight.ui.refresh()
		fight.hit = {"by": by.id, "on": on.id, "w": fx, "t0": fight.clock_ms}
		fight.figures[on.id].hurt(0, fx == "KILL")
		fight.ui.bleed(by.id, on.id, fx == "CRIT", float(OS.get_environment("BLUT_TREFFER")) if OS.get_environment("BLUT_TREFFER") != "" else 0.5, "")
		var t0: float = fight.clock_ms
		for at in [0, 50, 110, 200, 330, 500, 750, 1100, 1600]:
			while fight.clock_ms - t0 < at:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var fp := path.get_basename() + "-%04d.png" % at
			get_viewport().get_texture().get_image().save_png(fp)
			print("Bild ", fp, " Linse ", fight.cam.size, " ", fight.cam.frustum_offset)
		get_tree().quit()
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("Bild ", path)
	get_tree().quit()


## 348.12f, 368 (Chef 26.10., 16:23: Bewegungen als Kurzvideo): SCHAU=1 hält den Kampf an und spielt allen Gegnern dieselbe
## Bewegung nacheinander vor, Name oben (SCHAU_TITEL davor); mit --write-movie aufgenommen, Godot beendet sich am Ende
const SCHAU := [["Stehen", "Stehen"], ["Gehen", "Gehen"], ["Hocke", "Hocke"], ["Sprung", "Sprung"], ["Biss", "Biss"],
		["Treffer", "Treffer"], ["Ausweichen", "Ausweichen"], ["Lefzen", "Lefzen"], ["Drohen", "Drohen"], ["Tod", "Tod"]]

func _schau() -> void:
	fight.set_process(false)
	var foes: Array = []
	for id in fight.figures:
		var fg = fight.figures[id]
		fg.set_process(false)
		if fg.fighter.monster != null and fg.anim:
			foes.append(fg)
	var cl := CanvasLayer.new()
	add_child(cl)
	var lb := Label.new()
	var vs := get_viewport().get_visible_rect().size
	lb.position = Vector2(vs.x * 0.05, vs.y * 0.05)
	lb.add_theme_font_size_override("font_size", int(vs.x / 14.0))
	lb.add_theme_color_override("font_color", Color(0.95, 0.82, 0.45))
	lb.add_theme_color_override("font_outline_color", Color.BLACK)
	lb.add_theme_constant_override("outline_size", int(vs.x / 90.0))
	cl.add_child(lb)
	var titel := OS.get_environment("SCHAU_TITEL")
	for z in SCHAU:
		var nm: String = z[0]
		var lang := 0.0
		for fg in foes:
			fg.down = nm == "Tod"     # wie die(): liegend ohne Pfotenschatten
			if fg.anim.has_animation(nm):
				fg.anim.play(nm, 0.15)
				fg.anim.seek(0.0, true)
				lang = maxf(lang, fg.anim.get_animation(nm).length)
		if lang == 0.0:
			print("Schau: %s fehlt" % nm)
			continue
		lb.text = (titel + ": " if titel != "" else "") + z[1]
		var loop: bool = foes[0].anim.get_animation(nm).loop_mode != Animation.LOOP_NONE if foes[0].anim.has_animation(nm) else false
		var warte := clampf(lang, 1.6, 2.4) if loop else clampf(lang + 0.3, 0.8, 3.0)
		print("Schau %s: %.2f s, gezeigt %.2f s" % [nm, lang, warte])
		# 348.7 (Helfer 26.10., Film Lauf 118: beim Tod der Ratte blieben die Pfotenschatten stehen): die Figuren laufen hier
		# ohne _process, die Pfotenschatten darum je Bild von Hand nachführen
		var t_ende := get_tree().create_timer(warte)
		while t_ende.time_left > 0.0:
			for fg in foes:
				if not fg.paws.is_empty():
					fg._paw_shadow_update()
			await get_tree().process_frame
	await get_tree().create_timer(0.6).timeout
	get_tree().quit()


## For the Prüflauf: which way each figure looks (heel to toe, or its +Z) against the way it should face.
## 348.7 Grimmzahn Runde 7 (Prüfer Runde 6: „Wolf auf Wolf“): Umriss jeder Figur am Schirm aus den Ecken ihrer Netze in
## Ruhelage, in Zellen zu 12 px; „Deckung a b“ = Anteil der Zellen von a, die b verdeckt (b näher an der Kamera)
func _report_cover() -> void:
	if fight == null:
		return
	const C := 12
	var cells := {}
	for id in fight.figures:
		var fig = fig_of(id)
		var own := {}
		var r := Rect2()
		for mi in fig.find_children("*", "MeshInstance3D", true, false):
			var m: Mesh = (mi as MeshInstance3D).mesh
			if m == null:
				continue
			for si in m.get_surface_count():
				var vs: PackedVector3Array = m.surface_get_arrays(si)[Mesh.ARRAY_VERTEX]
				for i in range(0, vs.size(), 3):
					var p: Vector2 = fight.screen_of((mi as MeshInstance3D).global_transform * vs[i])
					r = Rect2(p, Vector2.ZERO) if r.size == Vector2.ZERO and r.position == Vector2.ZERO else r.expand(p)
					own[Vector2i(int(p.x) / C, int(p.y) / C)] = true
		cells[id] = own
		print("Rahmen %s: %d,%d-%d,%d, %d Zellen" % [id, r.position.x, r.position.y, r.end.x, r.end.y, own.size()])
	for a in cells:
		for b in cells:
			if a == b or fight.figures[a].fighter.side != fight.figures[b].fighter.side:
				continue
			if fight.cam.global_position.distance_to(fig_of(b).global_position) >= fight.cam.global_position.distance_to(fig_of(a).global_position):
				continue
			var n := 0
			for c in cells[a]:
				if cells[b].has(c):
					n += 1
			if n > 0:
				print("Deckung %s %s: %d%%" % [a, b, 100 * n / maxi(1, cells[a].size())])


func _report_facing() -> void:
	if fight == null:
		return
	for id in fight.figures:
		var fig = fig_of(id)
		var want: Vector3 = fight.facing(fig.fighter.side == "FOES")
		var got: Vector3 = fig.global_basis.z
		var sk := _skeleton(fig)
		if sk:
			var a := sk.find_bone("ankleR-heelR")
			var b := sk.find_bone("ballR-toeR")
			if a >= 0 and b >= 0:
				got = sk.global_transform * sk.get_bone_global_pose(b).origin - sk.global_transform * sk.get_bone_global_pose(a).origin
		got.y = 0
		if fig.neck:
			print("Hals %s: %.0f° gegen den Rumpf (soll %.0f°)" % [id, fig.neck.turned, fig.neck.want])
			if fig.aim != null:
				var ta: Vector3 = fig.aim.position - fig.position
				print("Ziel %s: %s, %.0f° vom Rumpf" % [id, fig.aim.fighter.id if "id" in fig.aim.fighter else fig.aim.name, rad_to_deg(fig.global_basis.z.signed_angle_to(ta, Vector3.UP))])
		if sk and sk.find_bone("foR-wrR") >= 0:
			var hb := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("foR-wrR"))
			print("Hand %s: Ort %s, x %s, y %s, z %s" % [id, hb.origin, hb.basis.x.normalized(), hb.basis.y.normalized(), hb.basis.z.normalized()])
			for s_ in ["L", "R"]:     # Schamane: Hände gegen die Figur (vorn = Blickrichtung, Höhe über dem Boden)
				var hp: Vector3 = (sk.global_transform * sk.get_bone_global_pose(sk.find_bone("fo%s-wr%s" % [s_, s_]))).origin - fig.global_position
				print("Hand%s %s: vor %.2f, hoch %.2f, seitlich %.2f m" % [s_, id, hp.dot(fig.global_basis.z.normalized()), hp.y, hp.dot(fig.global_basis.x.normalized())])
		for w in fig.find_children("Waffe", "", true, false) + fig.find_children("Schild", "", true, false):
			var gb: Basis = (w as Node3D).global_basis.orthonormalized()
			print("%s %s: Achse (Klinge) %s, Fläche %s, Ort %s" % [w.name, id, gb.y.snapped(Vector3.ONE * 0.01), gb.z.snapped(Vector3.ONE * 0.01), (w as Node3D).global_position.snapped(Vector3.ONE * 0.01)])
		if sk and fig.fighter.monster != null and fig.fighter.monster.id == Mars.SCOUT:
			_bogen_schnitt(id, fig, sk)
		var foot: Vector2 = fight.screen_of(fig.global_position)
		var top: Vector2 = fight.screen_of(fig.head())
		print("Schirm %s: Fuß %d,%d Kopf %d,%d" % [id, foot.x, foot.y, top.x, top.y])
		for oid in fight.figures:
			if fight.figures[oid].fighter.side != fig.fighter.side:
				var to: Vector3 = fight.figures[oid].position - fig.position
				print("  zu %s: %.0f°" % [oid, rad_to_deg(want.signed_angle_to(to, Vector3.UP))])
		print("Blick %s: soll %s, ist %s, Winkel %.0f°" % [id, want.normalized(), got.normalized(), rad_to_deg(want.signed_angle_to(got, Vector3.UP))])


## 348.7 Späher Runde 4 (Sokrates: Schnitt von oberem Wurfarm und Arm vorher nachstellen): kleinster Abstand des oberen
## Wurfarms (Griff bis Spitze, Achse des Bogens) zu Ober- und Unterarm links, im Raum (cm) und am Schirm (Bildpunkte)
func _bogen_schnitt(id, fig, sk: Skeleton3D) -> void:
	var bow: Node3D = null
	for w in fig.find_children("Schild", "", true, false) + fig.find_children("Waffe", "", true, false):
		bow = w
	if bow == null or sk.find_bone("foL-wrL") < 0:
		return
	var g := sk.global_transform
	var at := func(n: String) -> Vector3: return g * sk.get_bone_global_pose(sk.find_bone(n)).origin
	var hand: Vector3 = bow.global_position     # _hold: Ursprung des Bogens = Mitte der Faust
	var x: Vector3 = fig.global_basis.x.normalized()
	var px_cm: float = fight.screen_of(hand).distance_to(fight.screen_of(hand + x * 0.01))
	# Glieder als Strecken mit halber Dicke (cm): Arm 4, Bein 6
	var arm := [[at.call("upL-elL"), at.call("elL-foL"), 4.0, "Oberarm"], [at.call("elL-foL"), hand, 4.0, "Unterarm"]]
	var leg := [[at.call("hipL-thighL"), at.call("kneeL-calfL"), 6.0, "Oberschenkel"], [at.call("kneeL-calfL"), at.call("ankleL-ballL"), 5.0, "Wade"]]
	for wa in [[1.0, arm, "oberer"], [-1.0, leg, "unterer"]]:
		var tip: Vector3 = bow.global_transform * Vector3(0, 0.505 * wa[0], 0)
		var grip: Vector3 = bow.global_transform * Vector3(0, 0.12 * 0.505 * wa[0], 0)
		var worst := INF
		var where := ""
		for seg in wa[1]:
			for k in range(6, 21):     # ab 30 % der Länge: unten steckt er in der Faust
				var p: Vector3 = hand.lerp(tip, k / 20.0)
				var s2: Vector2 = fight.screen_of(p)
				var q: Vector2 = Geometry2D.get_closest_point_to_segment(s2, fight.screen_of(seg[0]), fight.screen_of(seg[1]))
				var m: float = s2.distance_to(q) - (seg[2] + 2.0) * px_cm
				if m < worst:
					worst = m
					where = "%s bei %d %%" % [seg[3], k * 5]
		if wa[0] > 0.0:     # der obere Wurfarm soll auch nicht quer über Rumpf und Kopf liegen
			var rumpf := [at.call("pelvis-waist"), at.call("neck-neckTop")]
			var r_frei := INF
			for k in range(6, 21):
				var s3: Vector2 = fight.screen_of(hand.lerp(tip, k / 20.0))
				r_frei = minf(r_frei, s3.distance_to(Geometry2D.get_closest_point_to_segment(s3, fight.screen_of(rumpf[0]), fight.screen_of(rumpf[1]))) - 14.0 * px_cm)
			var view: Vector3 = (bow.global_position - fight.cam.global_position).normalized()
			print("Bogen %s: oberer Wurfarm zum Rumpf frei %.1f cm; Krümmung zur Kamera %.0f° (90° = ganz sichtbar), Neigung am Schirm %.0f°" % [id, r_frei / px_cm, rad_to_deg(acos(absf(bow.global_basis.x.normalized().dot(view)))), rad_to_deg((fight.screen_of(tip) - fight.screen_of(hand)).angle_to(Vector2.UP))])
		print("Bogen %s: %s Wurfarm frei %.1f px (%.1f cm; enger: %s)" % [id, wa[2], worst, worst / px_cm, where])


func fig_of(id):
	return fight.figures[id]


func _skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var r := _skeleton(c)
		if r:
			return r
	return null


func _menu() -> void:
	for c in box.get_children():
		c.queue_free()
	_title("Probekampf (MARS, Godot)")
	_title("Held")
	box.add_child(_pick_row(CLASSES, NAMES, hero_cls, func(v): hero_cls = v; _menu()))
	_title("Söldner")
	box.add_child(_pick_row(CLASSES, NAMES, merc_cls, func(v): merc_cls = v; _menu()))
	_title("Gegner")
	box.add_child(_pick_row(FOES.keys(), FOES, foe, func(v): foe = v; _menu()))
	var go := Button.new()
	go.text = "Kämpfen"
	go.custom_minimum_size = Vector2(0, get_viewport().get_visible_rect().size.y * 0.06)
	go.pressed.connect(_start)
	box.add_child(go)


func _title(s: String) -> void:
	var l := Label.new()
	l.text = s
	l.add_theme_color_override("font_color", Color(0.86, 0.68, 0.30))
	box.add_child(l)


func _pick_row(keys: Array, names: Dictionary, now: String, set_it: Callable) -> HBoxContainer:
	var r := HBoxContainer.new()
	for k in keys:
		var b := Button.new()
		b.text = names[k]
		b.toggle_mode = true
		b.button_pressed = k == now
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, get_viewport().get_visible_rect().size.y * 0.05)
		var key: String = k
		b.pressed.connect(func(): set_it.call(key))
		r.add_child(b)
	return r


func _start(seed := -1) -> void:
	var dice = Wuerfel.new(null if seed < 0 else seed + 1)
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	var hs: Dictionary = tables.probe[hero_cls].hero
	var ms: Dictionary = tables.probe[merc_cls].merc
	var merc_back: bool = ms.hero.main.ranged or merc_cls == "WIZARD" or merc_cls == "CLERIC"
	var party := [
		Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), hs.hero, int(hs.hp), hs.hero.second, skills),
		Mars.hero_fighter("merc", "PARTY", Vector2i(Mars.BACK, 0) if merc_back else Vector2i(Mars.FRONT, 1), ms.hero, int(ms.hp), ms.hero.second, skills),
	]
	var foes := []
	var lineup: Array = {
		"WOLVES": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["wolf2", Mars.WOLF, Vector2i(0, 1)], ["wolf3", Mars.WOLF, Vector2i(1, 0)]],
		"GRAK": [["grak", Mars.GRAK, Vector2i(0, 0)]],
		"SPIDER": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["spider", Mars.SPIDER, Vector2i(1, 0)]],
		"SCOUT": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["scout", Mars.SCOUT, Vector2i(1, 0)]],
		# 348.9: drei Riesenratten im Aussehen, Regeln noch die des Wolfs (Ratte in MARS fehlt noch)
		"RATS": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["wolf2", Mars.WOLF, Vector2i(0, 1)], ["wolf3", Mars.WOLF, Vector2i(1, 0)]],
		# 348.7: Grimmzahn allein vorn, zwei Wölfe seiner Leibwache (Packs.kt guard) hinten an den Seiten; im Aussehen, Regeln
		# noch die des Wolfs (vorn rechts stand ihm der hintere Wolf auf dem Rücken, hinten verschwand er hinter der Wache: Prüfer Runden 2, 3)
		"GRIMM": [[Figur.GRIMM, Mars.WOLF, Vector2i(0, 0)], ["wolf1", Mars.WOLF, Vector2i(1, 0)], ["wolf2", Mars.WOLF, Vector2i(1, 1)]],
		# 348.7: drei Goblins, je eines der Kits (goblin.py), mit den Regeln des Goblins
		"GOBLINS": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["gob2", Mars.CALLED, Vector2i(0, 1)], ["gob3", Mars.CALLED, Vector2i(1, 0)]],
		# 348.7: drei Goblin-Späher, je eines der Kits (goblin.py ART=goblin_archer), mit den Regeln des Spähers
		"SCOUTS": [["gob1", Mars.SCOUT, Vector2i(0, 0)], ["gob2", Mars.SCOUT, Vector2i(0, 1)], ["gob3", Mars.SCOUT, Vector2i(1, 0)]],
		# 348.7: drei Goblin-Schamanen im Aussehen (goblin.py ART=goblin_shaman), Regeln noch die des Goblins (Schamane in MARS fehlt)
		"SHAMANS": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["gob2", Mars.CALLED, Vector2i(0, 1)], ["gob3", Mars.CALLED, Vector2i(1, 0)]],
		# 348.7: drei Kobolde im Aussehen (goblin.py ART=kobold), Regeln noch die des Goblins (Kobold in MARS fehlt)
		"KOBOLDS": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["gob2", Mars.CALLED, Vector2i(0, 1)], ["gob3", Mars.CALLED, Vector2i(1, 0)]],
	}[foe]
	Figur.ersatz_art = {"RATS": "giant_rat", "SHAMANS": Figur.SHAMAN, "KOBOLDS": Figur.KOBOLD}.get(foe, "")
	if still_name != "":
		party[0].hero = party[0].hero.duplicate()
		party[0].hero.name = still_name
	for e in lineup:
		var m: Dictionary = monsters[e[1]]
		if e[0] == Figur.GRIMM:     # Name aus den Regeln (Monsters.kt dire_wolf)
			m = m.duplicate()
			m.de = "Grimmzahn, der Leitwolf"
			m.en = "Grimfang the Alpha"
		elif foe == "KOBOLDS":     # Name aus den Regeln (Monsters.kt kobold)
			m = m.duplicate()
			m.de = "Kobold"
			m.en = "Kobold"
		elif foe == "SHAMANS":     # Name aus den Regeln (Monsters.kt goblin_shaman)
			m = m.duplicate()
			m.de = "Goblin-Schamane"
			m.en = "Goblin Shaman"
		foes.append(Mars.monster_fighter(e[0], e[2], m, dice.roll_expr(m.hp)))
	visible = false
	fight = Kampfort.new()
	# 296.2: der Held der Probe steht am Anfang seiner Stufe; ohne LP kein Kampf
	var xp := int(tables.xpForLevel[int(hs.hero.level)])
	if not fight.setup(party, foes, tables, {"potion": 2}, func(_outcome): visible = true, seed, {"xp": xp}):
		visible = true
		fight.free()
		fight = null
		return
	if foe == "GRIMM":     # Grimmzahn ohne Nummer, die Wölfe 1 und 2 (die Regeln zählen nach Art)
		for i in foes.size():
			foes[i].nr = i
	fight.again_fn = _start
	get_tree().root.add_child.call_deferred(fight)


## 348.7 Kobold Runde 2 (Sokrates, billigen/3487-kobold-r1 (b): Schnauze im Bild schräg nach unten, Ursache nachstellen): die
## Schnauze liegt in Ruhelage längs +Z des Modells und hängt fest am Knochen „neck-neckTop“; seine Drehung gegen die Ruhelage gibt
## ihre Richtung jetzt. Am Schirm Winkel (0° waagerecht, + nach unten) und Länge von 15 cm, im Raum der Winkel zum Blick der
## Kamera (90° = Profil)
func _report_snout() -> void:
	if fight == null:
		return
	for id in fight.figures:
		var fig = fig_of(id)
		if fig.fighter.monster == null:
			continue
		var sk := _skeleton(fig)
		if sk == null:
			continue
		var b := sk.find_bone("neck-neckTop")
		if b < 0:
			continue
		var pose := sk.get_bone_global_pose(b)
		var rest := sk.get_bone_global_rest(b)
		var v: Vector3 = (sk.global_basis * (pose.basis * rest.basis.inverse() * Vector3(0, 0, 1))).normalized()
		var p: Vector3 = sk.global_transform * pose.origin
		var a: Vector2 = fight.screen_of(p)
		var e: Vector2 = fight.screen_of(p + v * 0.15)
		var ray: Vector3 = (p - fight.cam.global_position).normalized()
		print("Schnauze %s: Schirm %.0f° unter der Waagerechten, %.0f px je 15 cm; zur Kamera %.0f° (90 = Profil), im Raum %.0f° unter der Waagerechten" % [id, rad_to_deg(atan2(e.y - a.y, absf(e.x - a.x))), a.distance_to(e), rad_to_deg(acos(clampf(absf(v.dot(ray)), 0, 1))), rad_to_deg(asin(clampf(-v.y, -1, 1)))])


## 348.7 Kobold Runde 3b (Prüfer 3a: im Spielbild liegt der Schwanz waagerecht, die Spitze 30–40 % der Höhe über dem Boden; in Blender
## liegt er auf): die Ecken, die ganz am Knochen „pelvis-hipR“ hängen und in Ruhelage hinter dem Becken liegen, selbst gehäutet, Höhe
## über dem Fuß der Figur (Ruhelage und jetzt), in Zentimetern und als Anteil der Figurhöhe
func _report_tail() -> void:
	if fight == null:
		return
	for id in fight.figures:
		var fig = fig_of(id)
		if fig.fighter.monster == null:
			continue
		var sk := _skeleton(fig)
		if sk == null or sk.find_bone("pelvis-hipR") < 0:
			continue
		var hb := sk.find_bone("pelvis-hipR")
		for mi in fig.find_children("*", "MeshInstance3D", true, false):
			if mi.skin == null or mi.mesh == null:
				continue
			var bind := -1
			for i in mi.skin.get_bind_count():
				if mi.skin.get_bind_bone(i) == hb or mi.skin.get_bind_name(i) == "pelvis-hipR":
					bind = i
			if bind < 0:
				continue
			var bp: Transform3D = mi.skin.get_bind_pose(bind)
			var rest: Transform3D = sk.get_bone_global_rest(hb)
			var pose: Transform3D = sk.get_bone_global_pose(hb)
			for s in mi.mesh.get_surface_count():
				var arr: Array = mi.mesh.surface_get_arrays(s)
				var V: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
				var B = arr[Mesh.ARRAY_BONES]
				var W = arr[Mesh.ARRAY_WEIGHTS]
				if B == null or W == null or V.is_empty():
					continue
				var nb: int = B.size() / V.size()
				var ys: Array = []
				var zr_min := 1e9
				var tip := Vector3.ZERO
				var tip_now := Vector3.ZERO
				var hip_rest: Vector3 = rest.origin
				var sel := 0
				var vmin := 1e9
				var vmax := -1e9
				for i in V.size():
					if int(B[i * nb]) != bind or float(W[i * nb]) < 0.99:
						continue
					var r: Vector3 = rest * (bp * V[i])
					if r.z > hip_rest.z - 0.02:     # nur hinter dem Becken (Schnauze längs +Z)
						continue
					var w: Vector3 = sk.global_transform * (pose * (bp * V[i]))
					sel += 1
					vmin = minf(vmin, w.y)
					vmax = maxf(vmax, w.y)
					var dxz: float = Vector2(r.x - hip_rest.x, r.z - hip_rest.z).length()     # Spitze: am weitesten von der Hüfte
					if dxz > zr_min or zr_min > 1e8:
						zr_min = dxz
						tip = r
						tip_now = w
				if sel == 0:
					continue
				var foot: float = fig.global_position.y
				var hgt := 0.80     # Kobold: Doll 80 cm
				var sf: Vector2 = fight.screen_of(Vector3(fig.global_position.x, foot, fig.global_position.z))
				var st: Vector2 = fight.screen_of(tip_now)
				var sw: Vector2 = fight.screen_of(sk.global_transform * pose.origin)
				print("Schwanz %s am Schirm: Fuß %s, Wurzel (Hüfte) %s, Spitze %s" % [id, sf.round(), sw.round(), st.round()])
				var g0: Vector3 = Vector3(fig.global_position.x, foot, fig.global_position.z)
				print("Schwanz %s Achsen am Schirm je 30 cm am Boden: +X %s, −Z (hinten) %s" % [id, (fight.screen_of(g0 + sk.global_basis.x.normalized() * 0.3) - sf).round(), (fight.screen_of(g0 - sk.global_basis.z.normalized() * 0.3) - sf).round()])
				print("Schwanz %s: %d Ecken, Spitze Ruhelage %.1f cm über 0, jetzt %.1f cm über dem Fuß (%.0f %%), tiefste %.1f, höchste %.1f cm; Animation %s %.2f s" % [id, sel, tip.y * 100.0, (tip_now.y - foot) * 100.0, (tip_now.y - foot) / hgt * 100.0, (vmin - foot) * 100.0, (vmax - foot) * 100.0, fig.anim.current_animation if fig.anim else "-", fig.anim.current_animation_position if fig.anim else 0.0])
