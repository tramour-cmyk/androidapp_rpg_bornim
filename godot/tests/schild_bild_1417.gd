extends SceneTree
# 1417 Bild an den Chef: die Wachsoldatin des Hauptmenüs (Hauptmenü wie im Spiel, dieselbe Stelle der Bewegung, gleiche Kamera).
# 1675 (Chef 18.11., 15:57): drei nebeneinander, beschriftet, der Schild gelb umrahmt; heutiger Code, nur die Stellgrößen der Stände:
#   vor 1417 (bfbb8ab02): Arm am Bein (Abspreizen 0), Stoff nicht verschoben
#   1417 (b78ad10b9):     Arm 25 Grad abgespreizt, Stoff nicht verschoben
#   neu (1675):           Arm am Bein (Abspreizen 0), Stoff hinter dem Schild (HauptmenueHelden.StoffHinterSchild)
# Darunter je Stand der Schild vergroessert (1675-Ü4). Dazu das ganze Handybild des neuen Stands. Nur mit Fenster (godot.yml „Schild im Hauptmenü (1417)“), im Ordner godot:
#   PROBE=1417 xvfb-run -a godot --path . --rendering-driver vulkan --rendering-method mobile --resolution 1080x2340 \
#     -s res://tests/schild_bild_1417.gd -- --aus=<ordner>

var STAENDE := [
	["vor 1417 (bfbb8ab02)", "Arm am Bein, Stoff durch den Schild", 0.0, false],
	["1417 (b78ad10b9)", "Arm 25 Grad abgespreizt", 25.0, false],
	["neu (1675, %s)" % _commit(), "Arm am Bein, Stoff hinter dem Schild", 0.0, true],
]

## 1675-Ü4: Beschriftung mit dem Commit des neuen Stands
static func _commit() -> String:
	var o := []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], o)
	return String(o[0]).strip_edges() if not o.is_empty() and String(o[0]).strip_edges() != "" else "?"
var aus := ""

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	_lauf.call_deferred()

func _lauf() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	Hauptmenue.vorspann_gezeigt = true
	var hm := Hauptmenue.new(null)
	root.add_child(hm)
	for i in 40: await process_frame   # Lauf 531: nach 10 Bildern war alles schwarz (Einblendung des Menüs)
	var neu: HauptmenueHelden = null
	for c in hm.find_children("*", "HauptmenueHelden", true, false): neu = c
	if neu == null or neu.figuren.is_empty():
		print("SCHILDBILD1417 keine Helden"); quit(1); return
	var m := neu.figuren[0].get_child(0) as Node3D
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	var stoff = m.get_node_or_null("StoffHinterSchild")
	var tr: Tragen = null
	for c in sk.get_children():
		if c is Tragen and (c as Tragen).gang == "schildarm": tr = c
	if tr == null or stoff == null:
		print("SCHILDBILD1417 kein Schild oder kein StoffHinterSchild"); quit(1); return
	var stelle := ap.current_animation_position if ap else 0.0
	var bilder := []
	var naehe := []
	var mass := Vector2.ONE
	for st in STAENDE:
		tr.schild_abspreiz = float(st[2])
		for mt in stoff.mats: (mt as ShaderMaterial).set_shader_parameter("schild_an", 1.0 if st[3] else 0.0)
		if ap: ap.seek(stelle, true); ap.pause()
		neu._bilder = 0
		neu._v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		for k in 20: await process_frame
		await RenderingServer.frame_post_draw
		var img := root.get_texture().get_image()
		if st[3]: img.save_png(aus + "/1675_handy_neu.png")   # ganzes Handybild
		mass = Vector2(img.get_size()) / root.get_visible_rect().size
		var g := neu.get_global_rect()
		# linkes Drittel des Bilds: die Wachsoldatin ganz, ohne den Zauberlehrling
		var r := Rect2i(Vector2i(g.position * mass), Vector2i(Vector2(g.size.x * 0.34, g.size.y) * mass)).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		var aus_ := img.get_region(r)
		# Schild umrahmen: Ecken seiner Netze in das Bild der Kamera, von dort in den Ausschnitt
		var kam := neu._v.get_camera_3d()
		var f := g.size * mass / Vector2(neu._v.size)
		var lo := Vector2(INF, INF); var hi := -lo
		for mi in tr.waffe.find_children("*", "MeshInstance3D", true, false) + ([tr.waffe] if tr.waffe is MeshInstance3D else []):
			var bb := (mi as MeshInstance3D).get_aabb()
			for e in 8:
				var p := kam.unproject_position((mi as MeshInstance3D).global_transform * bb.get_endpoint(e)) * f + g.position * mass - Vector2(r.position)
				lo = lo.min(p); hi = hi.max(p)
		# 1675-Ü4 (LISTE-HANDWERK-FIGUR-PRUEFBILD: bei Kleinem ein Ausschnitt): der Schild allein, quadratisch, auf Spaltenbreite vergroessert
		var sm := (lo + hi) / 2.0
		var sg := int(maxf(hi.x - lo.x, hi.y - lo.y)) + 40
		var sq := Rect2i(Vector2i(sm) - Vector2i(sg, sg) / 2, Vector2i(sg, sg)).intersection(Rect2i(Vector2i.ZERO, aus_.get_size()))
		var nah := aus_.get_region(sq)
		nah.resize(aus_.get_width(), aus_.get_width() * sq.size.y / maxi(sq.size.x, 1), Image.INTERPOLATE_NEAREST)
		naehe.append(nah)
		_rahmen(aus_, Rect2i(Vector2i(lo) - Vector2i(6, 6), Vector2i(hi - lo) + Vector2i(12, 12)), Color(1.0, 0.85, 0.1))
		bilder.append(aus_)
		print("SCHILDBILD1417 %s: abspreiz %.0f, Stoff verschoben %s, Ausschnitt %s, Schild %s bis %s" % [st[0], st[2], st[3], r, lo, hi])
	# drei nebeneinander, darueber die Beschriftung (Label im eigenen Fenster gezeichnet)
	var w: int = bilder[0].get_width(); var h: int = bilder[0].get_height()
	var hn := 0
	for n in naehe: hn = maxi(hn, (n as Image).get_height())
	var fs := clampi(w / 14, 10, 30)   # 1675-Ü4: bei 540 Punkten Breite lief Schrift 30 ins Bild
	var kopf := fs * 5
	var v := SubViewport.new()
	v.size = Vector2i(w * 3 + 16, h + kopf + 8 + hn)
	v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(v)
	var bg := ColorRect.new(); bg.color = Color(0.08, 0.08, 0.08); bg.size = Vector2(v.size); v.add_child(bg)
	for i in 3:
		var t := TextureRect.new()
		t.texture = ImageTexture.create_from_image(bilder[i])
		t.position = Vector2(i * (w + 8), kopf)
		v.add_child(t)
		var tn := TextureRect.new()
		tn.texture = ImageTexture.create_from_image(naehe[i])
		tn.position = Vector2(i * (w + 8), kopf + h + 8)
		v.add_child(tn)
		var l := Label.new()
		l.text = "%s\n%s" % [STAENDE[i][0], STAENDE[i][1]]
		l.position = Vector2(i * (w + 8) + 10, 8)
		l.size = Vector2(w - 20, kopf - 12)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		l.add_theme_font_size_override("font_size", fs)
		l.add_theme_color_override("font_color", Color(1, 1, 1))
		v.add_child(l)
	for k in 5: await process_frame
	await RenderingServer.frame_post_draw
	v.get_texture().get_image().save_png(aus + "/1675_drei.png")
	print("BILD ", aus + "/1675_drei.png")
	print("BILD ", aus + "/1675_handy_neu.png")
	quit()

func _rahmen(img: Image, r: Rect2i, c: Color) -> void:
	r = r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	for d in 4:
		img.fill_rect(Rect2i(r.position.x, r.position.y + d, r.size.x, 1), c)
		img.fill_rect(Rect2i(r.position.x, r.end.y - 1 - d, r.size.x, 1), c)
		img.fill_rect(Rect2i(r.position.x + d, r.position.y, 1, r.size.y), c)
		img.fill_rect(Rect2i(r.end.x - 1 - d, r.position.y, 1, r.size.y), c)
