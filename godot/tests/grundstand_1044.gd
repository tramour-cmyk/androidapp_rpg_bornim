extends SceneTree
# 1044 wiederholt (Chef 15.11., 21:50): Grundstand der Leute ausserhalb des Kampfs (heldfigur.gd Haltung.grund). Je Person ein Bild,
# links vorher (UAL-Ruhe, breitbeinig), rechts nachher (Grundstand, Arme je Person), im Stehen an ihrem Platz, Kamera nah; dazu
# Messzeilen GRUND1044 (Knoechel in Hueftgelenkabstaenden, Knie gebeugt). Nur mit Fenster und Kaufdaten, im Ordner godot:
#   xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/grundstand_1044.gd -- --aus=<ordner> [--nur=bram,…]
# Ohne Kaufkoerper: „GRUND1044 FEHLER“.

const LEUTE := [["village", "bram"], ["village", "liska"], ["temple", "osric"], ["village", "jorin"], ["inn", "rowena"], ["village", "gwenna"]]
const NACHBARN := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-2, 0), Vector2i(1, -1), Vector2i(-1, -1), Vector2i(1, 1), Vector2i(-1, 1)]

var aus := ""
var nur: PackedStringArray = []
var spiel: Node
var fehler := 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
		if a.begins_with("--nur="): nur = a.substr(6).split(",")
	_lauf.call_deferred()


func warte(s: float) -> void:
	await create_timer(s).timeout


func bild(p: Node3D) -> Image:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	var cam: Camera3D = spiel.kamera
	var o := cam.unproject_position(p.global_position + Vector3.UP * 0.85) * float(img.get_width()) / cam.get_viewport().get_visible_rect().size.x
	var b := int(img.get_width() * 0.62); var h := int(b * 1.35)
	var r := Rect2i(clampi(int(o.x) - b / 2, 0, img.get_width() - b), clampi(int(o.y) - h / 2, 0, img.get_height() - h), b, h)
	return img.get_region(r)


func platz(karte_id: String, id: String) -> Vector2i:
	var j = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	for n in j["karten"][karte_id].get("leute", []):
		if String(n["id"]) == id: return Vector2i(int(n["x"]), int(n["y"]))
	return Vector2i(-1, -1)


func _lauf() -> void:
	if aus != "": DirAccess.make_dir_recursive_absolute(aus)
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await warte(0.5)
	spiel.zustand.setze(Geschichte.LYRA_RESCUED)
	spiel.zustand.minuten = 11 * 60
	for fr in LEUTE:
		var kid: String = fr[0]; var id: String = fr[1]
		if not nur.is_empty() and id not in nur: continue
		var p := platz(kid, id)
		spiel.betrete(kid, p if p.x >= 0 else Vector2i(2, 2), "UP")
		await warte(1.0)
		var hp := p
		for d in NACHBARN:
			if p.x >= 0 and spiel.karte.begehbar(p + d) and not (spiel.leute.get_children().any(func(l): return l.kachel == p + d)):
				hp = p + d; break
		spiel.betrete(kid, hp, "UP")
		await warte(2.0)
		for n in ["mess", "oben", "leiste", "textfeld"]: spiel.ui.get(n).visible = false
		spiel.ui.sage([])
		if not spiel.kamera.nah: spiel.kamera.nah_fern()
		await warte(1.5)
		var pe: Node3D = null
		for l in spiel.leute.get_children():
			if String(l.daten.get("id", "")) == id: pe = l
		if pe:
			pe.set_process(false); pe.set_physics_process(false)
			var zk: Vector3 = spiel.kamera.global_position - pe.global_position
			pe.rotation.y = atan2(zk.x, zk.z) + deg_to_rad(25.0)   # etwas schraeg: Arme am Ruecken und in der Seite sichtbar
			if pe.anim and pe.anim.has_animation("Stehen"): pe.anim.play("Stehen")
		var haltung = pe.modell.find_child("Haltung", true, false) if pe and pe.modell else null
		if haltung == null or not ("grund" in haltung):
			print("GRUND1044 FEHLER %s nicht da oder ohne Kaufkoerper" % id); fehler += 1; continue
		var bilder := []
		for an in [false, true]:
			haltung.grund = an
			haltung.grund_w = -1.0; haltung.arm_w = -1.0
			await warte(0.6)
			spiel.ui.textfeld.visible = false
			bilder.append(await bild(pe))
			if an: print("GRUND1044 %s Knoechel %.2f Hueftgelenkabstaende, Knie %.0f/%.0f Grad, Arme %s" % [id, haltung.grund_mass.x,
				haltung.grund_mass.y, haltung.grund_mass.z, haltung.arme])
		if aus != "":
			var a: Image = bilder[0]; var c: Image = bilder[1]
			var z := Image.create(a.get_width() * 2 + 8, a.get_height(), false, a.get_format())
			z.fill(Color(0.83, 0.69, 0.22))
			z.blit_rect(a, Rect2i(Vector2i.ZERO, a.get_size()), Vector2i.ZERO)
			z.blit_rect(c, Rect2i(Vector2i.ZERO, c.get_size()), Vector2i(a.get_width() + 8, 0))
			z.save_png(aus + "/" + id + ".png")
			print("BILD ", aus + "/" + id + ".png")
	print("GRUND1044 %d Fehler" % fehler)
	quit(1 if fehler else 0)
