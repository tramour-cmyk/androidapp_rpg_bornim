extends SceneTree
# 1092 (Sokrates zu 1090, Nacht 1077): dunkle, fleckige Laengsstreifen in hellen Roben (Lyra, Osric, Rowena). Messprobe am Rechner
# (Kaufdaten): je Figur nah im Stehen fuenf Bilder, je eine Ursache aus: grund, ohne_textur (Bild weiss, Eckfarben bleiben),
# ohne_schatten (Sonne ohne Schatten), ohne_licht (fill 1: keine Lichtstufen der Sonne, nur Bild mal Eckfarbe), ohne_knick (Tusche
# ohne Knicklinien, Umriss bleibt). Verschwinden die Streifen in genau einem, ist das die Ursache. Im Ordner godot:
#   xvfb-run -a godot --path . --resolution 1080x2340 -s res://tests/streifen_1092.gd -- --aus=<ordner> [--nur=osric,…]
const ROBE := [["temple", "lyra_temple"], ["temple", "osric"], ["inn", "rowena"]]
const NACHBARN := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-2, 0), Vector2i(1, -1), Vector2i(-1, -1), Vector2i(1, 1), Vector2i(-1, 1)]
const ARTEN := ["grund", "ohne_textur", "ohne_schatten", "ohne_licht", "ohne_knick"]

var aus := ""
var nur: PackedStringArray = []
var spiel: Node


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
		if a.begins_with("--nur="): nur = a.substr(6).split(",")
	_lauf.call_deferred()


func warte(s: float) -> void:
	await create_timer(s).timeout


func knips(n: String, frau: Node3D) -> void:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	var cam: Camera3D = spiel.kamera
	var o := cam.unproject_position(frau.global_position + Vector3.UP * 0.85) * float(img.get_width()) / cam.get_viewport().get_visible_rect().size.x
	var b := int(img.get_width() * 0.62); var h := int(b * 1.35)
	var r := Rect2i(clampi(int(o.x) - b / 2, 0, img.get_width() - b), clampi(int(o.y) - h / 2, 0, img.get_height() - h), b, h)
	img.get_region(r).save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")


func platz(karte_id: String, id: String) -> Vector2i:
	var j = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	var k: Dictionary = j["karten"][karte_id]
	for n in k.get("leute", []):
		if String(n["id"]) == id: return Vector2i(int(n["x"]), int(n["y"]))
	return Vector2i(-1, -1)


func art(a: String, frau: Node3D, an: bool, alt: Dictionary) -> void:
	match a:
		"ohne_textur":
			for m in frau.mats:
				if an:
					alt[m] = m.get_shader_parameter("tex")
					var w := Image.create(1, 1, false, Image.FORMAT_RGBA8); w.fill(Color.WHITE)
					m.set_shader_parameter("tex", ImageTexture.create_from_image(w))
				else: m.set_shader_parameter("tex", alt[m])
		"ohne_schatten": spiel.licht.sonne.shadow_enabled = not an
		"ohne_licht":
			for m in frau.mats:
				if an: alt[m] = m.get_shader_parameter("fill"); m.set_shader_parameter("fill", 1.0)
				else: m.set_shader_parameter("fill", alt[m])
		"ohne_knick":
			for m in spiel.kamera.tusche_mats:
				if an: alt[m] = m.get_shader_parameter("knick"); m.set_shader_parameter("knick", 100.0)
				else: m.set_shader_parameter("knick", alt[m])


func _lauf() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await warte(0.5)
	spiel.zustand.setze(Geschichte.LYRA_RESCUED)
	spiel.zustand.minuten = 11 * 60
	var fehlt := 0
	for fr in ROBE:
		var kid: String = fr[0]; var id: String = fr[1]
		if not nur.is_empty() and id not in nur: continue
		var p := platz(kid, id)
		spiel.betrete(kid, p if p.x >= 0 else Vector2i(2, 2), "UP")
		await warte(1.0)
		var karte = spiel.karte
		var hp := p
		for d in NACHBARN:
			if p.x >= 0 and karte.begehbar(p + d) and not (spiel.leute.get_children().any(func(l): return l.kachel == p + d)):
				hp = p + d; break
		spiel.betrete(kid, hp, "UP")
		await warte(2.0)
		for u in [spiel.ui.mess, spiel.ui.oben, spiel.ui.leiste, spiel.ui.textfeld]: u.visible = false
		spiel.ui.sage([])
		if not spiel.kamera.nah: spiel.kamera.nah_fern()
		await warte(1.5)
		var frau: Node3D = null
		for l in spiel.leute.get_children():
			if String(l.daten.get("id", "")) == id: frau = l
		if frau == null or frau.modell == null:
			print("STREIFEN1092 FEHLER %s nicht da (%s %s)" % [id, kid, p]); fehlt += 1; continue
		frau.set_process(false); frau.set_physics_process(false)
		var zk: Vector3 = spiel.kamera.global_position - frau.global_position
		frau.rotation.y = atan2(zk.x, zk.z)
		if frau.anim and frau.anim.has_animation("Stehen"): frau.anim.play("Stehen")
		await warte(0.6)
		if frau.anim: frau.anim.pause()   # gleiche Haltung in allen fuenf Bildern
		print("STREIFEN1092 %s %s an %s, %d Materialien, tracht %s" % [id, kid, frau.kachel, frau.mats.size(), frau.modell.get_meta("tracht", "-")])
		for a in ARTEN:
			var alt := {}
			art(a, frau, true, alt)
			spiel.ui.textfeld.visible = false
			await warte(0.3)
			await knips("%s_%s" % [id, a], frau)
			art(a, frau, false, alt)
	print("STREIFEN1092 fertig, %d fehlen" % fehlt)
	quit(0)
