extends SceneTree
# 653 Prüfbild aller Kombinationen: je Körpertyp ein Blatt, darauf jeder Gegenstand des Katalogs mit Modell, angelegt mit der einen
# Anlegefunktion (Halt.anlegen: Waffe rechte Faust, Schild linker Unterarm), Haltung „Stehen“, von vorn und von der Seite der Hand.
# Nur mit Fenster: im Ordner godot, xvfb-run, --resolution 360x540, -s res://tests/halt_bild_653.gd -- --aus=<ordner> [--koerper=WACHE_M,…] [--nur=shield,…]
# -> <ordner>/653_<Körper>.png, Zeilen „BILD“

var SPALTEN := 4

func _initialize() -> void:
	_lauf.call_deferred()

func arg(n: String, vor := "") -> String:
	for x in OS.get_cmdline_user_args():
		if x.begins_with("--%s=" % n): return x.substr(n.length() + 3)
	return vor

func _lauf() -> void:
	var aus := arg("aus", "/tmp")
	var ids: Array = []
	for id in Katalog.lade():
		if String(Katalog.eintrag(id).get("art", "")) in ["waffe", "schild"] and Halt.datei(id) != "": ids.append(id)
	var nur := arg("nur")   # nur diese Gegenstände (Komma), z. B. nach einem Befund des Chefs
	if nur != "": ids = ids.filter(func(i): return i in nur.split(","))
	for k in arg("koerper", "WACHE_M,WACHE_W").split(","):
		await blatt(String(k), ids, aus)
	quit()

func ansicht(dt: Drehteller, winkel: float) -> Image:
	dt.teller.rotation.y = deg_to_rad(winkel)
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	var x: Image = (dt.get_child(0) as SubViewport).get_texture().get_image()
	x.convert(Image.FORMAT_RGBA8)
	return x

func blatt(k: String, ids: Array, aus: String) -> void:
	if not FileAccess.file_exists("res://daten/held_%s.bin" % k):
		print("OHNE KOERPER ", k)
		return
	var w := {"klasse": "", "modell": k, "aussehen": {"geschlecht": k.right(1).to_lower()}, "volk": "HUMAN"}
	var dt := Drehteller.new(w, 1.6)
	dt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dt)
	dt.set_process(false)
	for i in 10: await process_frame
	var modell: Node3D = dt.teller.get_child(0) if dt.teller.get_child_count() > 0 else null
	if modell == null:
		print("OHNE KOERPER ", k)
		dt.queue_free()
		return
	var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
	var schild_l := Label3D.new()
	schild_l.pixel_size = 0.004
	schild_l.font_size = 40
	schild_l.outline_size = 10
	schild_l.modulate = Color(0.95, 0.82, 0.45)
	schild_l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	schild_l.position = Vector3(0, Drehteller.HOEHE * 1.04, 0)
	dt._v.add_child(schild_l)
	var zellen: Array[Image] = []
	for id in ids:
		var schild := String(Katalog.eintrag(id).get("art", "")) == "schild"
		var d := Halt.anlegen(sk, "unterarm_l" if schild else "faust_r", id, "Gehalten653", k)   # 967: Korrektur des Körpertyps
		if d == null:
			print("FEHLT ", k, " ", id)
			continue
		Gebiet.male(d, null, 2, [])
		schild_l.text = String(Katalog.eintrag(id).get("name", {}).get("de", id))
		var a := await ansicht(dt, 0.0)
		var b := await ansicht(dt, -90.0 if schild else 90.0)   # Seite der haltenden Hand
		var z := Image.create(a.get_width() * 2, a.get_height(), false, Image.FORMAT_RGBA8)
		z.fill(Color(0.07, 0.06, 0.05))
		z.blend_rect(a, Rect2i(Vector2i.ZERO, a.get_size()), Vector2i.ZERO)
		z.blend_rect(b, Rect2i(Vector2i.ZERO, b.get_size()), Vector2i(a.get_width(), 0))
		z.resize(z.get_width() / 2, z.get_height() / 2, Image.INTERPOLATE_LANCZOS)
		zellen.append(z)
		(d.get_parent() as Node).free()
	if zellen.is_empty():
		dt.queue_free()
		return
	var cw := zellen[0].get_width(); var ch := zellen[0].get_height()
	SPALTEN = mini(4, zellen.size())
	var zeilen := ceili(zellen.size() / float(SPALTEN))
	var ges := Image.create(cw * SPALTEN, ch * zeilen, false, Image.FORMAT_RGBA8)
	ges.fill(Color(0.03, 0.025, 0.02))
	for i in zellen.size():
		ges.blit_rect(zellen[i], Rect2i(0, 0, cw, ch), Vector2i((i % SPALTEN) * cw, (i / SPALTEN) * ch))
	var p := aus + "/653_%s.png" % k
	ges.save_png(p)
	print("BILD ", p, " ", zellen.size(), " Gegenstände")
	dt.queue_free()
	for i in 3: await process_frame
