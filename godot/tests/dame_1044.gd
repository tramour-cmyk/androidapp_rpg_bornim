extends SceneTree
# 1044 Weg 2 (Vorentscheid Sokrates 13.11., 00:09; Lyra passt 02:30): die Frauen ausserhalb des Kampfs (HeldFigur.DAMEN) nah im
# Stehen an ihrem Platz, je vorher (UAL-Ruhe, breitbeinig) und nachher (Damenstand, heldfigur.gd Haltung.dame); dazu Messzeilen
# DAME1044 (Fussabstand und Handgelenke in Hueftbreiten, im Modifikator gemessen). Nur mit Fenster und Kaufdaten (godot.yml
# „Damenstand (1044)“), im Ordner godot:
#   xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/dame_1044.gd -- --aus=<ordner> [--nur=lyra_temple,…]
# Plaetze aus daten/karten.json (Leute mit Aussehen in leute.json, sex w), der Held auf einem freien Nachbarfeld, Kamera nah.
# 1090 (Vorentscheid Sokrates 13.11., 02:46): --rock nimmt alle sieben mit Robe (dazu Aldric, Osric; ohne Thessa), je im Stehen
# (Damenstand, wer in DAMEN ist) und im Gehen auf der Stelle (Luecke zwischen Saum und Schuh?), Bilder <id>_stehen, <id>_gehen

const FRAUEN := [["village", "liska"], ["village", "gwenna"], ["inn", "rowena"], ["shop", "thessa"], ["deep_forest", "morwen"],
	["temple", "lyra_temple"]]
const ROBE := [["village", "liska"], ["village", "gwenna"], ["inn", "rowena"], ["deep_forest", "morwen"], ["temple", "lyra_temple"],
	["elder", "aldric"], ["temple", "osric"]]
const NACHBARN := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-2, 0), Vector2i(1, -1), Vector2i(-1, -1), Vector2i(1, 1), Vector2i(-1, 1)]   # seitlich, nicht davor

var aus := ""
var nur: PackedStringArray = []
var rock := false
var spiel: Node


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
		if a.begins_with("--nur="): nur = a.substr(6).split(",")
		if a == "--rock": rock = true
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


func _lauf() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await warte(0.5)
	spiel.zustand.setze(Geschichte.LYRA_RESCUED)
	spiel.zustand.minuten = 11 * 60
	var fehlt := 0
	for fr in (ROBE if rock else FRAUEN):
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
		spiel.ui.mess.visible = false
		spiel.ui.oben.visible = false
		spiel.ui.leiste.visible = false
		spiel.ui.sage([])
		spiel.ui.textfeld.visible = false
		if not spiel.kamera.nah: spiel.kamera.nah_fern()
		await warte(1.5)
		var frau: Node3D = null
		for l in spiel.leute.get_children():
			if String(l.daten.get("id", "")) == id: frau = l
		if frau:   # steht still, zur Kamera, auch wer im Dorf gerade geht
			frau.set_process(false); frau.set_physics_process(false)
			var zk: Vector3 = spiel.kamera.global_position - frau.global_position   # Gesicht zur Kamera (die Figur blickt nach +Z)
			frau.rotation.y = atan2(zk.x, zk.z)
			if frau.anim and frau.anim.has_animation("Stehen"): frau.anim.play("Stehen")
		var haltung = frau.modell.find_child("Haltung", true, false) if frau and frau.modell else null
		if haltung == null or not ("dame" in haltung):
			print("DAME1044 FEHLER %s nicht da oder ohne Kaufkoerper (%s %s)" % [id, kid, p]); fehlt += 1; continue
		print("DAME1044 %s %s an %s, Held %s, Bewegung %s, in DAMEN %s" % [id, kid, frau.kachel, hp, frau.anim.current_animation if frau.anim else "-", haltung.dame])
		if rock:   # 1090: im Stand wie im Spiel, dann im Gehen auf der Stelle (mitten im Schritt)
			await warte(0.6)
			spiel.ui.textfeld.visible = false
			await knips("%s_stehen" % id, frau)
			if frau.anim and frau.anim.has_animation(frau.geh_anim):
				frau.anim.play(frau.geh_anim)
				await warte(0.9)
				await knips("%s_gehen" % id, frau)
				print("DAME1044 %s gehen (%s)" % [id, frau.geh_anim])
			continue
		for stand in [["vorher", false], ["nachher", true]]:
			haltung.dame = stand[1]
			haltung.dame_w = -1.0
			await warte(0.6)
			spiel.ui.textfeld.visible = false
			if stand[1]: print("DAME1044 %s im Modifikator: Fuesse %.2f, Haende %.2f Hueftbreiten auseinander" % [id, haltung.dame_mass.x, haltung.dame_mass.y])
			await knips("%s_%s" % [id, stand[0]], frau)
	print("DAME1044 fertig, %d fehlen" % fehlt)
	quit(0)
