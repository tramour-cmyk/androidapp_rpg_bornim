extends SceneTree
# 1044 Weg 2 (Vorentscheid Sokrates 13.11., 00:09, billigen/1044-frauenstand.md): Lyra im Tempel vorher (UAL-Ruhe, breitbeinig) und
# nachher (Damenstand, heldfigur.gd Haltung.dame), je in der Spielansicht und nah um Lyra; dazu Messzeilen DAME1044 (Fussabstand in
# Hueftbreiten, Handgelenke vor dem Bauch). Nur mit Fenster und Kaufdaten (godot.yml „Damenstand (1044)“), im Ordner godot:
#   xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/dame_1044.gd -- --aus=<ordner>

var aus := ""
var spiel: Node


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
	_lauf.call_deferred()


func warte(s: float) -> void:
	await create_timer(s).timeout


func knips(n: String, lyra: Node3D = null) -> void:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	if lyra:
		var cam: Camera3D = spiel.kamera
		var o := cam.unproject_position(lyra.global_position + Vector3.UP * 0.85) * float(img.get_width()) / cam.get_viewport().get_visible_rect().size.x
		print("DAME1044 Lyra im Bild %s (Fenster %s, Bild %d)" % [o, cam.get_viewport().get_visible_rect().size, img.get_width()])
		var b := int(img.get_width() * 0.62); var h := int(b * 1.35)
		var r := Rect2i(clampi(int(o.x) - b / 2, 0, img.get_width() - b), clampi(int(o.y) - h / 2, 0, img.get_height() - h), b, h)
		img = img.get_region(r)
	img.save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")


func messe(n: String, m: Node3D) -> void:
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var p := func(b: String) -> Vector3: return sk.get_bone_global_pose(sk.find_bone(b)).origin
	var breite: float = (p.call("thigh_l") - p.call("thigh_r")).length()
	var fuss: float = Vector2(p.call("foot_l").x - p.call("foot_r").x, p.call("foot_l").z - p.call("foot_r").z).length()
	var hand: float = (p.call("hand_l") - p.call("hand_r")).length()
	print("DAME1044 %s Fuesse %.2f Hueftbreiten, Haende %.2f Hueftbreiten auseinander, Hand links %.2f / rechts %.2f ueber dem Becken" % [n, fuss / breite, hand / breite,
		(p.call("hand_l").y - p.call("pelvis").y) / breite, (p.call("hand_r").y - p.call("pelvis").y) / breite])


func _lauf() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await warte(0.5)
	spiel.zustand.setze(Geschichte.LYRA_RESCUED)
	spiel.zustand.minuten = 11 * 60
	var lyra: Node3D = null
	var haltung = null
	for ansicht in [["spiel", Vector2i(4, 4)], ["nah", Vector2i(7, 2)]]:
		spiel.betrete("temple", ansicht[1], "UP")
		await warte(2.0)
		spiel.ui.mess.visible = false
		spiel.ui.oben.visible = false
		spiel.ui.leiste.visible = false
		spiel.ui.sage([])
		spiel.ui.textfeld.visible = false
		if ansicht[0] == "nah" and not spiel.kamera.nah: spiel.kamera.nah_fern()
		await warte(1.5)
		lyra = null
		for l in spiel.leute.get_children():
			if String(l.daten.get("id", "")) == "lyra_temple": lyra = l
		if lyra == null or lyra.modell == null:
			print("DAME1044 FEHLER Lyra nicht im Tempel"); quit(1); return
		haltung = lyra.modell.find_child("Haltung", true, false)
		if haltung == null or not ("dame" in haltung):
			print("DAME1044 FEHLER keine Haltung an Lyra (Kaufkoerper fehlt?)"); quit(1); return
		print("DAME1044 Lyra ", lyra.kachel, " Bewegung ", lyra.anim.current_animation if lyra.anim else "-", " dame in leute.json ", haltung.dame)
		for stand in [["vorher", false], ["nachher", true]]:
			haltung.dame = stand[1]
			haltung.dame_w = -1.0
			await warte(0.6)
			spiel.ui.textfeld.visible = false
			messe("%s %s" % [ansicht[0], stand[0]], lyra.modell)
			if stand[1]: print("DAME1044 %s im Modifikator: Fuesse %.2f, Haende %.2f Hueftbreiten auseinander" % [ansicht[0], haltung.dame_mass.x, haltung.dame_mass.y])
			await knips("%s_%s" % [ansicht[0], stand[0]], lyra if ansicht[0] == "nah" else null)
	print("DAME1044 fertig")
	quit(0)
