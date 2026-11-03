# 406.2a (Chef 03.11., 09:03, Archiv 406.2a: „einfach nur versuchen, ob das hinhaut … Auf jeden Fall nicht das Hopsen aus dem Sword
# and Shield Paket“; 09:06: „auch mit Stab oder mit Axt“): kurzer Film, unter einer Minute. Je Held drei Angriffe auf einen Wolf in
# gut 4 m: er rennt wie im Dorf hin (figur.gd _kampfrennen), schlägt und geht rückwärts heim; echter Ablauf _held_schlag, die Regeln
# ruhen. Kämpfer mit Langschwert und Rundschild, Magier mit Kampfstab, Kämpfer mit Kriegsaxt. Kamera seitlich vor dem Helden, folgt
# ihm (Chef 08:57 zum Parade-Film: „die Perspektive ist Murks“), jede Figur ganz im Bild (G1), Spiellicht (Signatur 457).
# Aufruf (Bild, Probelauf nach 389): PROBE=406.2a xvfb-run godot --path godot --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_4062a.gd
# MESS=1 (--headless, ohne Bild): je Anlauf Bewegung, Weg, Zeit; Kampfrennen da, Schild und Waffe in der Hand
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const FORMAT := Vector2(1080, 2340)
const BLENDE_BILDER := 8
const ABSTAND := 4.4          # m vom Helden zum Wolf, deutlich über RUN_FROM (1,2 m)
const WINKEL := [55.0, 40.0, 70.0]     # drei Anläufe schräg zur Seite: Weg quer im Bild der Spielkamera, Lichtung frei (film_406)
const HELDEN := [
	{"cls": "FIGHTER", "name": "Kämpfer · Langschwert und Rundschild"},
	{"cls": "WIZARD", "name": "Magier · Kampfstab"},
	{"cls": "FIGHTER", "name": "Kämpfer · Kriegsaxt", "main": "greataxe"}]

var mess := OS.get_environment("MESS") != ""
var diag := OS.get_environment("DIAG") != "" and not mess     # Lauf 223 nachstellen: Wolf und Waffen fehlen im Bild, Schatten da
var schwarz: ColorRect
var lb: Label
var lz: Label
var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not mess:
		var deck := CanvasLayer.new()
		deck.layer = 128
		schwarz = ColorRect.new()
		schwarz.color = Color.BLACK
		schwarz.set_anchors_preset(Control.PRESET_FULL_RECT)
		schwarz.mouse_filter = Control.MOUSE_FILTER_IGNORE
		deck.add_child(schwarz)
		root.add_child(deck)
		var cl := CanvasLayer.new()
		cl.layer = 10
		root.add_child(cl)
		var vs: Vector2 = root.get_visible_rect().size
		lb = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.03), int(vs.x / 19.0), Color(0.95, 0.82, 0.45))
		lz = _label(cl, Vector2(vs.x * 0.04, vs.y * 0.075), int(vs.x / 28.0), Color(0.92, 0.88, 0.80))
	for h in HELDEN:
		await _held(h)
	print("Film 406.2a %s" % ("Messung: %d Befunde" % fehler if mess else "fertig"))
	quit(1 if fehler > 0 else 0)


func _label(cl: CanvasLayer, pos: Vector2, fs: int, farbe: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", maxi(fs / 6, 3))
	cl.add_child(l)
	return l


func _blende(ziel: float) -> void:
	if schwarz == null:
		return
	var von := schwarz.color.a
	for i in BLENDE_BILDER:
		await process_frame
		schwarz.color.a = lerpf(von, ziel, float(i + 1) / BLENDE_BILDER)


func _held(h: Dictionary) -> void:
	var p = Probe.new()
	p.hero_cls = String(h.cls)
	p.merc_cls = "CLERIC" if h.cls != "CLERIC" else "FIGHTER"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	if h.has("main"):     # Kriegsaxt: zweihändig, ohne Schild (tabellen.json kennt sie nicht als Probewaffe)
		var hs: Dictionary = p.tables.probe[h.cls].hero.hero
		hs.main = hs.main.duplicate()
		hs.main.id = h.main
		hs.main.de = "Kriegsaxt"
		hs.main.two = true
		hs["schild"] = ""
	p._start(7)
	for i in 12:     # _arm_kauf wartet auf den Baum und ein Bild
		await process_frame
	var kf = p.fight
	if kf == null:
		print("FEHLER 406.2a: kein Kampfort für %s" % h.name)
		fehler += 1
		return
	if kf.ui != null:
		kf.ui.visible = false
	kf.playing = true     # die Regeln ruhen (wie film_406 Sichtung); _process des Kampforts läuft weiter
	var held = kf.figures["hero"]
	var wolf = null
	for id in kf.figures:
		var f = kf.figures[id]
		if f.tween:
			f.tween.kill()
		if f == held:
			continue
		if wolf == null and f.fighter.monster != null:
			wolf = f
		else:
			f.visible = false
			f.set_process(false)
	if held.anim == null or not held.kauf:
		print("FEHLER 406.2a: %s ohne Kaufhelden (daten/kampf-bewegungen.bin, Kaufkörper)" % h.name)
		fehler += 1
		kf.queue_free()
		p.queue_free()
		await process_frame
		return
	held.position = held.home
	held._idle()
	var zu: Vector3 = wolf.home - held.home
	zu.y = 0.0
	zu = zu.normalized()
	var kampfweg := []
	for w in WINKEL:
		var d := zu.rotated(Vector3.UP, deg_to_rad(w))
		var q: Vector3 = held.home + d * ABSTAND
		q.y = wolf.home.y
		kampfweg.append(q)
	wolf.position = kampfweg[0]
	wolf._face(held.home - wolf.position)
	# Kamera aus Richtung der Spielkamera (dort ist die Lichtung frei, film_406), etwas zur Seite des Wegs gedreht: der Held rennt quer
	# durchs Bild, Brust und Schild zur Kamera
	# Lauf 237 (DIAG2): in der Spielrichtung zeichnen Wolf (487 Punkte), Schwert (284), Schild (245) mit; die Filmkamera 20° daneben
	# aus 15 m sah Schwert und Schild kaum (11, 18 Punkte). Darum Richtung der Spielkamera, fov 30 und folgen wie film_406 (_folgen):
	# so nah, dass Held und Wolf ganz im Bild sind (G1), Held groß; weiter weg sofort, näher langsam
	var von: Vector3 = kf.cam.global_position - held.home
	von.y = 0.0
	von = von.normalized()
	var cam := Camera3D.new()
	kf.add_child(cam)
	cam.fov = 30.0
	var folge := {"mitte": Vector3.ZERO, "d": -1.0, "aus": 0}
	_kamera_auf(cam, kf, held.position.lerp(wolf.position, 0.5), von, 8.0)
	_folgen(cam, kf, held, wolf, folge, true)
	cam.make_current()
	await process_frame
	if not mess and not Signatur.wache(kf, self, "Film 406.2a " + String(h.name)):
		return
	if lb:
		lb.text = "406.2a · Angriff im Rennen wie im Dorf"
		lz.text = String(h.name)
	await _blende(0.0)
	await create_timer(0.8).timeout
	if diag:
		await _matrix(kf, cam, held, wolf, kampfweg[0], String(h.name))
		if h != HELDEN[0]:
			await _blende(1.0)
			kf.queue_free()
			p.queue_free()
			await process_frame
			return
	for i in WINKEL.size():
		wolf.position = kampfweg[i]
		wolf._face(held.home - wolf.position)
		held._face(wolf.position - held.position)
		var vorher: String = held.anim.current_animation
		var ms: int = held._held_schlag(wolf)
		var t := 0.0
		var lauf := ""
		var ende: float = held.busy_ms / 1000.0 + 0.6
		while t < ende:
			await process_frame
			t += 1.0 / 30.0
			var c: String = held.anim.current_animation
			if lauf == "" and c != vorher and not c.begins_with("SS_Idle") and c not in ["Kampfstehen", "Stehen"]:
				lauf = c
			if diag and i == 0 and t >= 0.5 and t < 0.5 + 1.0 / 30.0:
				await _diag(kf, cam, held, wolf, String(h.name) + " Anlauf 1 bei 0,5 s")
			_folgen(cam, kf, held, wolf, folge, false)
		var gut := lauf.begins_with("Kampfrennen")
		print("Film 406.2a %s Anlauf %d: Bewegung %s, Aufschlag %d ms, Schild „%s“, Stab %s, %s" % [h.name, i + 1, lauf, ms, held._schild(), held._stab(), "gut" if gut else "FEHLER kein Kampfrennen"])
		if not gut:
			fehler += 1
		if lauf == "SS_RunForward":
			print("FEHLER 406.2a: SS_RunForward (Chef: nie das Hopsen)")
	print("Film 406.2a %s: Bilder mit angeschnittener Figur %d (G1)" % [h.name, folge.aus])
	await create_timer(0.4).timeout
	await _blende(1.0)
	kf.queue_free()
	p.queue_free()
	await process_frame
	await process_frame


func _kamera_auf(cam: Camera3D, kf, ziel: Vector3, von: Vector3, d: float) -> void:
	var z := ziel + Vector3(0, 0.95, 0)
	cam.position = z + von * d + Vector3(0, d * 0.22, 0)     # etwa 12° von oben wie die Spielkamera, nicht flach
	cam.look_at(z)
	kf.ink_ziel = z     # Tusche nach Licht nach dieser Kamera (kampfort.gd _ink_licht)


## wie film_406 _folgen, nur Held und Wolf: Richtung und Neigung fest (_kamera_auf), Abstand so, dass beide ganz im Bild sind
const RAND_X := 0.88
const RAND_OBEN := 0.66      # oben die Schrift
const RAND_UNTEN := 0.9
func _folgen(cam: Camera3D, kf, held, wolf, folge: Dictionary, erst: bool) -> void:
	var ty := tan(deg_to_rad(cam.fov) / 2.0)
	var tx := ty * FORMAT.x / FORMAT.y
	var b := cam.global_transform.basis
	var fw := -b.z
	var pts := []
	var mitte := Vector3.ZERO
	for f in [held, wolf]:
		var h: float = (1.85 if f.fighter.monster == null else 0.9) * f.scale.y
		var r: float = f.body_r() + (0.5 if f == held else 0.15)     # Waffe weit ausgeholt
		for q in [Vector3.ZERO, Vector3(0, h + (0.4 if f == held else 0.0), 0)]:
			for sx in [-1.0, 1.0]:
				pts.append(f.global_position + q + b.x * r * sx)
		mitte += f.global_position + Vector3(0, h * 0.5, 0)
	mitte /= 2.0
	folge.mitte = mitte if erst else (folge.mitte as Vector3).lerp(mitte, 0.08)
	var c: Vector3 = folge.mitte
	var d_noetig := 3.0
	for p in pts:
		var rel: Vector3 = p - c
		var x := absf(rel.dot(b.x))
		var y := rel.dot(b.y)
		var z := rel.dot(fw)
		d_noetig = maxf(d_noetig, x / (tx * RAND_X) - z)
		d_noetig = maxf(d_noetig, (y / (ty * RAND_OBEN) if y > 0.0 else -y / (ty * RAND_UNTEN)) - z)
	var d: float = folge.d
	d = d_noetig if erst or d < 0.0 or d_noetig > d else lerpf(d, d_noetig, 0.03)
	folge.d = d
	cam.global_position = c - fw * d
	kf.ink_ziel = c
	for f in [held, wolf]:
		var h: float = (1.85 if f.fighter.monster == null else 0.9) * f.scale.y
		for q in [f.global_position, f.global_position + Vector3(0, h, 0)]:
			var rel: Vector3 = q - cam.global_position
			var z := rel.dot(fw)
			if z <= 0.1 or absf(rel.dot(b.x)) > tx * z or absf(rel.dot(b.y)) > ty * z:
				folge.aus += 1
				return


## DIAG=1 (Lauf 223, Prüfer: Wolf unsichtbar, nur sein Schatten; keine Waffe, kein Schild in der Hand): was liegt wo, was ist
## sichtbar, was zeichnet der Schirm an dieser Stelle; dann je Teil für ein Bild rot und unbeschattet: kommt es dann ins Bild?
func _diag(kf, cam: Camera3D, held, wolf, wann: String) -> void:
	var vp := root
	print("DIAG %s: Kamera aktiv %s (Film %s, Spiel %s), Bild %s, cam %s fov %.0f" % [wann, vp.get_camera_3d(), cam, kf.cam, vp.get_visible_rect().size, cam.global_position, cam.fov])
	var teile := []     # [Name, Knoten]
	teile.append(["Wolf", wolf.model])
	teile.append(["Held", held.model])
	for at in held.model.find_children("*", "BoneAttachment3D", true, false):
		if at.has_meta("was"):
			teile.append(["Waffe " + String(at.get_meta("was")), at])
	for t in teile:
		var n: Node3D = t[1]
		var mis: Array = n.find_children("*", "MeshInstance3D", true, false)
		var box := AABB()
		var erst := true
		for mi in mis:
			var g: AABB = mi.global_transform * mi.get_aabb()
			box = g if erst else box.merge(g)
			erst = false
		var c: Vector3 = box.get_center()
		var px := cam.unproject_position(c)
		print("DIAG   %s: im Baum sichtbar %s, Netze %d, Mitte %s, Größe %s, Maßstab %s, im Kegel %s, Schirm %s, hinter %s" % [t[0], n.is_visible_in_tree(), mis.size(), c, box.size, n.global_transform.basis.get_scale(), cam.is_position_in_frustum(c), px, cam.is_position_behind(c)])
		for mi in mis.slice(0, 4):
			var m = mi.get_surface_override_material(0) if mi.get_surface_override_material_count() > 0 else null
			if m == null:
				m = mi.material_override
			var sh := ""
			if m is ShaderMaterial and m.shader:
				sh = "%s weg %s glow %s" % [m.shader.resource_path if m.shader.resource_path != "" else "eigen", m.get_shader_parameter("weg"), m.get_shader_parameter("glow")]
			print("DIAG     %s: sichtbar %s, Schatten %d, Ebenen %d, Rand %.1f, Haut %s, Stoff %s" % [mi.name, mi.is_visible_in_tree(), mi.cast_shadow, mi.layers, mi.extra_cull_margin, mi.skin != null, sh])
		await process_frame
		var img0 := vp.get_texture().get_image()
		var f0 := _farbe(img0, px)
		# je Teil ein Bild rot, unbeschattet, ohne Tiefentest: kommt es an dieser Stelle?
		var rot := StandardMaterial3D.new()
		rot.albedo_color = Color.RED
		rot.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rot.no_depth_test = true
		var alt := []
		for mi in mis:
			alt.append(mi.material_overlay)
			mi.material_overlay = rot
		await process_frame
		await process_frame
		var img1 := vp.get_texture().get_image()
		var f1 := _farbe(img1, px)
		var rote := 0
		for y in range(0, img1.get_height(), 4):
			for x in range(0, img1.get_width(), 4):
				var q := img1.get_pixel(x, y)
				if q.r > 0.8 and q.g < 0.2 and q.b < 0.2:
					rote += 1
		print("DIAG     %s Schirm an der Mitte vorher %s, rot drüber %s, rote Punkte im Bild (je 4. Punkt) %d" % [t[0], f0, f1, rote])
		for k in mis.size():
			mis[k].material_overlay = alt[k]
		await process_frame


func _farbe(img: Image, px: Vector2) -> String:
	var vs := Vector2(img.get_width(), img.get_height())
	var s := vs / Vector2(root.get_visible_rect().size)
	var x := int(clampf(px.x * s.x, 0, vs.x - 1))
	var y := int(clampf(px.y * s.y, 0, vs.y - 1))
	var c := img.get_pixel(x, y)
	return "(%d,%d)=%.2f/%.2f/%.2f" % [x, y, c.r, c.g, c.b]


## DIAG=1 Lauf 2 (Lauf 230: Wolf nicht gekappt (rot ohne Tiefentest 343 Punkte), kein Wald dazwischen (tests/sicht_4062a.gd), im
## Bild von Lauf 223 nur sein Schatten): trägt der Wolf überhaupt Bildpunkte bei? Je Kamera (Film 15 m, Spiel, nah 5 m) und Lage
## (daheim, Anlaufpunkt): Bild mit und ohne Wolf (visible), Zahl der geänderten Punkte im Kasten um seinen Rumpf; ebenso Schwert
## und Schild (Anhänger an der Hand) und der Held. Dazu die Stoffe des Wolfs mit allen Werten, die etwas verschwinden lassen können.
func _matrix(kf, film_cam: Camera3D, held, wolf, weg_punkt: Vector3, wer: String) -> void:
	var vp := root
	for mi in wolf.model.find_children("*", "MeshInstance3D", true, false):
		var m: MeshInstance3D = mi
		var stoffe := []
		for s in m.mesh.get_surface_count():
			var x = m.get_surface_override_material(s)
			if x == null:
				x = m.material_override
			if x == null:
				x = m.mesh.surface_get_material(s)
			var t := "%s" % x
			if x is ShaderMaterial:
				t = "Shader %s cut_on %s weg %s rueck %s vorrang %s nach %s prio %d next %s" % [x.shader.resource_path if x.shader.resource_path != "" else "eigen", x.get_shader_parameter("cut_on"), x.get_shader_parameter("weg"), x.get_shader_parameter("rueck"), x.get_shader_parameter("vorrang"), x.get_shader_parameter("nach"), x.render_priority, x.next_pass]
				if x.shader.code.contains("stencil_mode"):
					t += " stencil " + x.shader.code.substr(x.shader.code.find("stencil_mode"), 40).split("\n")[0]
			stoffe.append(t)
		print("DIAG2 Wolf-Netz %s: Sicht %s, Bereich bis %.0f, transparency %.2f, lod_bias %.2f, Ebenen %d, Stoffe %s" % [m.name, m.is_visible_in_tree(), m.visibility_range_end, m.transparency, m.lod_bias, m.layers, stoffe])
	var nah := Camera3D.new()
	kf.add_child(nah)
	nah.fov = film_cam.fov
	var teile := [["Wolf", wolf, func(): return wolf.global_position + Vector3(0, 0.45, 0)], ["Held", held, func(): return held.global_position + Vector3(0, 1.2, 0)]]
	for at in held.model.find_children("*", "BoneAttachment3D", true, false):
		if at.has_meta("was"):
			teile.append(["Waffe " + String(at.get_meta("was")), at, func(): return (at as Node3D).global_position])
	var heim: Vector3 = wolf.home
	for lage in ["daheim", "Anlaufpunkt"]:
		wolf.position = heim if lage == "daheim" else weg_punkt
		var mitte: Vector3 = held.position.lerp(wolf.position, 0.5) + Vector3(0, 0.6, 0)
		var von: Vector3 = film_cam.global_position - mitte
		nah.global_position = mitte + von.normalized() * 5.0
		nah.look_at(mitte)
		for k in [["Film", film_cam], ["Spiel", kf.cam], ["nah 5 m", nah]]:
			var c: Camera3D = k[1]
			c.make_current()
			kf.ink_ziel = mitte
			await process_frame
			await process_frame
			var zeile := PackedStringArray()
			for t in teile:
				var n: Node3D = t[1]
				var px: Vector2 = c.unproject_position(t[2].call())
				await RenderingServer.frame_post_draw
				var mit := vp.get_texture().get_image()
				n.visible = false
				await process_frame
				await RenderingServer.frame_post_draw
				var ohne := vp.get_texture().get_image()
				n.visible = true
				var s := Vector2(mit.get_width(), mit.get_height()) / Vector2(vp.get_visible_rect().size)
				var cx := int(px.x * s.x)
				var cy := int(px.y * s.y)
				var anders := 0
				var alle := 0
				for y in range(cy - 40, cy + 41, 2):
					for x in range(cx - 40, cx + 41, 2):
						if x < 0 or y < 0 or x >= mit.get_width() or y >= mit.get_height():
							continue
						alle += 1
						var a := mit.get_pixel(x, y)
						var b := ohne.get_pixel(x, y)
						if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.08:
							anders += 1
				zeile.append("%s %d/%d bei (%d,%d)%s" % [t[0], anders, alle, cx, cy, "" if c.is_position_in_frustum(t[2].call()) else " außerhalb"])
			print("DIAG2 %s %s, Lage %s: %s" % [wer, k[0], lage, ", ".join(zeile)])
	wolf.position = weg_punkt
	film_cam.make_current()
	nah.queue_free()
