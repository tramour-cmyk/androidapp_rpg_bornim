extends SceneTree
# 1092 A (Chef 14.11., 10:11 „a. mit den Ergaenzungen“): Falten als Form im Rock statt nur gemalt; genau ein Standbild vorher/nachher
# bei seitlichem Licht. Lyra (Tempel), Osric (Tempel), Rowena (Schenke) nah an ihrem Platz im Stehen, Gesicht zur Kamera, je zwei
# Bilder: <id>_<stand>_spiel (Licht des Raums wie im Spiel) und <id>_<stand>_seite (dazu eine warme Lampe links neben der Figur, auf
# Hueft-hoehe, damit eine Flanke jeder Falte im Licht und die andere im Schatten liegt). Nur mit Fenster und Kaufdaten (godot.yml
# „Robe 1092“), im Ordner godot:
#   xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/robe_1092.gd -- --aus=<ordner> --stand=nachher|vorher

const ROBE := [["temple", "lyra_temple"], ["temple", "osric"], ["inn", "rowena"]]
const NACHBARN := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-2, 0), Vector2i(1, -1), Vector2i(-1, -1), Vector2i(1, 1), Vector2i(-1, 1)]

var aus := ""
var stand := "nachher"
var spiel: Node


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
		if a.begins_with("--stand="): stand = a.substr(8)
	_lauf.call_deferred()


func warte(s: float) -> void:
	await create_timer(s).timeout


func knips(n: String, fig: Node3D) -> void:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	var cam: Camera3D = spiel.kamera
	var o := cam.unproject_position(fig.global_position + Vector3.UP * 0.75) * float(img.get_width()) / cam.get_viewport().get_visible_rect().size.x
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
		spiel.ui.mess.visible = false
		spiel.ui.oben.visible = false
		spiel.ui.leiste.visible = false
		spiel.ui.sage([])
		spiel.ui.textfeld.visible = false
		if not spiel.kamera.nah: spiel.kamera.nah_fern()
		await warte(1.5)
		var fig: Node3D = null
		for l in spiel.leute.get_children():
			if String(l.daten.get("id", "")) == id: fig = l
		if fig == null or fig.modell == null:
			print("ROBE1092 FEHLER %s nicht da (%s %s)" % [id, kid, p]); fehlt += 1; continue
		fig.set_process(false); fig.set_physics_process(false)
		var zk: Vector3 = spiel.kamera.global_position - fig.global_position   # Gesicht zur Kamera (die Figur blickt nach +Z)
		fig.rotation.y = atan2(zk.x, zk.z)
		if fig.anim and fig.anim.has_animation("Stehen"): fig.anim.play("Stehen")
		await warte(0.6)
		if fig.anim: fig.anim.pause()   # gleiche Haltung in beiden Bildern
		print("ROBE1092 %s %s an %s, Stand %s, tracht %s" % [id, kid, fig.kachel, stand, fig.modell.get_meta("tracht", "-")])
		spiel.ui.textfeld.visible = false
		await knips("%s_%s_spiel" % [id, stand], fig)
		# seitliches Licht: links der Figur von der Kamera aus, etwas davor, auf Hueft-hoehe
		var rechts: Vector3 = spiel.kamera.global_basis.x; rechts.y = 0.0; rechts = rechts.normalized()
		var vorn := Vector3(zk.x, 0.0, zk.z).normalized()
		var lampe := OmniLight3D.new()
		lampe.light_color = Color(1.0, 0.82, 0.6)
		lampe.light_energy = 2.2
		lampe.omni_range = 4.0
		lampe.shadow_enabled = true
		spiel.add_child(lampe)
		lampe.global_position = fig.global_position - rechts * 1.3 + vorn * 0.35 + Vector3.UP * 0.9
		await warte(0.3)
		spiel.ui.textfeld.visible = false
		await knips("%s_%s_seite" % [id, stand], fig)
		lampe.queue_free()
		await warte(0.2)
	print("ROBE1092 fertig, %d fehlen" % fehlt)
	quit(0)
