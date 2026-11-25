extends SceneTree
# 1654 (Moritz): Beleg Rowena Hüfte (Rock unter der Schürze), Spielkamera (spiel.tscn, Spielshader, Tusche) in Handygröße, nächster Fingerzoom (Kamera.NAH).
# Rowena im Gasthaus hinter dem Tresen, Held unsichtbar; Ruhebewegung „Ruhe_Tresen“ (dort stach der Rock am meisten, 31 Ecken)
# steht je Bild der Durchstechprüfung (6 Bilder je Bewegung wie durchstich_1631) und je Blickrichtung; Bilder nach --aus=<Ordner>.
# Nur mit Fenster, im Ordner godot:
#   xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 1080x2340 -s res://tests/bild_1654.gd -- --aus=<Ordner> [--bew=<Pose>]
# 1654 (24.11., 21:18): Pose als Argument (--bew=Stehen|Gesten|Ruhe_Tresen, ohne: Ruhe_Tresen). --richtung: kein Bild, nur je Pose, Bild
# und Blickrichtung, ob Rowenas Hüfte (thigh_l -> thigh_r, Vorderseite = oben x rechts) zur Spielkamera zeigt (Zeile BILD1654 RICHTUNG;
# zeigt = Winkel zwischen Vorderseite und Weg zur Kamera am Boden unter 60 Grad). Geht auch --headless.

const BILDER := 6
const POSEN := ["Stehen", "Gesten", "Ruhe_Tresen"]

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var aus := "user://bild_1654"
	var BEW := "Ruhe_Tresen"
	var richtung := false
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="): aus = a.substr(6)
		if a.begins_with("--bew="): BEW = a.substr(6)
		if a == "--richtung": richtung = true
	if not richtung: DirAccess.make_dir_recursive_absolute(aus)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 12 * 60
	spiel.betrete("inn", Vector2i(1, 1), "DOWN")
	for i in 10: await process_frame
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	var wer: Leute = null
	for l in spiel.leute_liste():
		if String(l.daten.get("id", "")) == "rowena": wer = l
	if wer == null:
		print("BILD1654 FEHLER Rowena fehlt")
		quit(1)
		return
	spiel.held.setze(wer.kachel + Vector2i(0, 2), "UP")
	spiel.held.visible = false
	wer.set_process(false)
	wer.set_physics_process(false)
	# 1654: Blick wie in karten.json (Rowena DOWN, Ruhe hinter dem Tresen), nicht die halbe Drehung zum Helden am Eingang, die beim
	# Anhalten stehen bliebe (-28 Grad statt 0)
	wer.blick = {"UP": PI, "DOWN": 0.0, "LEFT": -PI / 2, "RIGHT": PI / 2}.get(String(wer.daten.get("blick", "DOWN")), 0.0)
	wer.rotation.y = wer.blick
	var ap := wer.anim
	if ap == null or not ap.has_animation(BEW):
		print("BILD1654 FEHLER keine Bewegung %s" % BEW)
		quit(1)
		return
	ap.speed_scale = 0.0
	var k: Kamera = spiel.kamera
	k.ziel = wer
	k.nah = true
	k.zoom = Kamera.NAH
	var vorn := -wer.global_basis.z
	print("BILD1654 Rowena %s Blick %s" % [wer.global_position, vorn])
	if richtung:
		await _richtung(wer, ap, k)
		quit(0)
		return
	for g in [Kamera.NORD, 0.0, -Kamera.NORD]:
		k.gieren_ziel = g
		k.springe()
		for b in BILDER:
			var an := ap.get_animation(BEW)
			ap.play(BEW, 0.0)
			ap.seek(an.length * float(b) / float(BILDER), true)
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			var bild := root.get_texture().get_image()
			var huefte := wer.global_position + Vector3(0, 0.9, 0)
			var p := k.unproject_position(huefte)
			var f := "%s/g%d_b%d.png" % [aus, int(g), b]
			bild.save_png(f)
			var fuss := k.unproject_position(wer.global_position)
			var scheitel := k.unproject_position(wer.global_position + Vector3(0, 1.8, 0))
			print("BILD1654 %s Huefte %d %d Fuss %d %d Scheitel %d %d" % [f, int(p.x), int(p.y), int(fuss.x), int(fuss.y), int(scheitel.x), int(scheitel.y)])
	print("BILD1654 fertig")
	quit(0)

# Vorderseite der Hüfte gegen den Weg zur Kamera, je Pose, Bild und Blickrichtung (ohne Bild)
func _richtung(wer: Node3D, ap: AnimationPlayer, k: Kamera) -> void:
	var sk := Gebiet.finde(wer, "Skeleton3D") as Skeleton3D
	var bl := sk.find_bone("thigh_l"); var br := sk.find_bone("thigh_r")
	for bew in POSEN:
		if not ap.has_animation(bew):
			print("BILD1654 RICHTUNG %s fehlt" % bew)
			continue
		for g in [Kamera.NORD, 0.0, -Kamera.NORD]:
			k.gieren_ziel = g
			k.springe()
			var zeigt := 0
			var winkel := []
			for b in BILDER:
				var an := ap.get_animation(bew)
				ap.play(bew, 0.0)
				ap.seek(an.length * float(b) / float(BILDER), true)
				for i in 4: await process_frame
				var pl := sk.global_transform * sk.get_bone_global_pose(bl).origin
				var pr := sk.global_transform * sk.get_bone_global_pose(br).origin
				var rechts := pr - pl
				var f := Vector3.UP.cross(rechts); f.y = 0.0
				var zur := k.global_position - (pl + pr) * 0.5; zur.y = 0.0
				var w := rad_to_deg(f.normalized().angle_to(zur.normalized()))
				winkel.append(int(w))
				if w < 60.0: zeigt += 1
			print("BILD1654 RICHTUNG %s Blick %d Winkel %s zeigt %d/%d" % [bew, int(g), str(winkel), zeigt, BILDER])
