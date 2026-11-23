extends SceneTree
# 1694 (Chef 18.11., 17:01): Bild der rechten Hand mit Waffe im Dorf, Held angehalten im Stehen, Kamera nah an der Hand (Tusche wie im
# Spiel). Je Waffe ein Bild nach BILDER=<ordner>/<waffe>-<alt|neu>.png; GRIFF1694=0 = alter Griff; LAENGS=1 Blick längs des Schafts;
# SPIELKAMERA=1 die Spielkamera (mit --resolution 540x1170 wie das Handy).
#   GRIFF1694=0|1 BILDER=<ordner> xvfb-run -a godot --path . --resolution 900x900 -s res://tests/bild_griff_1694.gd -- --bild1694

const FOLGE := ["quarterstaff", "handaxe", "longsword", "greatsword", "greataxe"]   # 1694: dazu Zweihänder (458.3)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 13 * 60
	spiel.licht_nach_uhr(true)   # Chef 21:37 („nix zu erkennen“): Tageslicht wirklich setzen, sonst stand das Licht vom Start (Nacht)
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	var ordner := OS.get_environment("BILDER")
	var art := "alt" if OS.get_environment("GRIFF1694") == "0" else "neu"
	var kam := Camera3D.new()
	root.add_child(kam)
	kam.fov = 30.0
	for i in FOLGE.size():
		if OS.get_environment("NUR") != "" and FOLGE[i] != OS.get_environment("NUR"): continue   # Einzelbild (783 W1)
		hw.ausruestung["MAIN_HAND"] = {"uid": 9500 + i, "base": FOLGE[i], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
		spiel.held_figur_neu("")
		spiel.held.richtung = Vector3.ZERO
		var sk := Gebiet.finde(spiel.held.modell, "Skeleton3D") as Skeleton3D
		var bew := OS.get_environment("GANG")   # 1694: Zweihänder im Gehen (Gehen_axt), beide Hände am Schaft; Bild bei Stelle STELLE s
		if bew != "" and FOLGE[i] in Tragen.GANG_ZWEI:
			preload("res://tests/griff_sicht_1694.gd").geh(spiel, sk, bew)
			var ap := Gebiet.finde(spiel.held.modell, "AnimationPlayer") as AnimationPlayer
			ap.seek(float(OS.get_environment("STELLE")) if OS.get_environment("STELLE") != "" else 0.3, true)
			ap.speed_scale = 0.0
		for f in 40: await process_frame
		var t: Tragen = null
		for n in sk.get_children():
			if n is Tragen: t = n
		if t == null:
			print("BILD1694 %s: kein Tragen" % FOLGE[i]); continue
		t.merken = true
		await process_frame
		var hand: Vector3 = sk.global_transform * t.posen[sk.find_bone("middle_01_r")].origin
		var vorn: Vector3 = spiel.held.modell.global_basis * Vector3.BACK
		var rechts: Vector3 = spiel.held.modell.global_basis * Vector3.LEFT
		var weit := float(OS.get_environment("WEIT")) if OS.get_environment("WEIT") != "" else 1.0   # 1694: Zweihänder, beide Hände im Bild
		kam.global_position = hand + (vorn * 0.55 + rechts * 0.45 + Vector3.UP * 0.12) * weit
		kam.look_at(hand, Vector3.UP)
		if OS.get_environment("LAENGS") != "":   # Ursache (Chef 17:38): Blick längs des Schafts auf die Faust
			var m := t.halt.duplicate() if not t.halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
			var gw := t.waffe.global_transform * Halt.griff_rahmen(m)
			var ax := gw.basis.y.normalized()
			kam.global_position = gw.origin - ax * 0.45
			kam.look_at(gw.origin, Vector3.UP if absf(ax.y) < 0.9 else Vector3.FORWARD)
		if OS.get_environment("BLICK") != "":   # 1694 (23.11.): Blick im Rahmen der Hand (Endpose): innen (Handfläche), aussen (Handrücken), daumen, klein
			var P := func(b: String) -> Vector3: return sk.global_transform * t.posen[sk.find_bone(b + "_r")].origin
			var lang: Vector3 = (P.call("middle_01") - P.call("hand")).normalized()
			var quer: Vector3 = (P.call("index_01") - P.call("pinky_01")).normalized()
			var fl := lang.cross(quer).normalized()
			if fl.dot(P.call("thumb_01") - P.call("hand")) < 0.0: fl = -fl
			var mitte: Vector3 = (P.call("index_01") + P.call("pinky_01")) * 0.5 + fl * 0.02
			var r: Vector3 = {"innen": fl, "aussen": -fl, "daumen": quer, "klein": -quer}[OS.get_environment("BLICK")]
			kam.global_position = mitte + (r * 0.32 + lang * 0.08) * weit
			kam.look_at(mitte, lang if absf(r.dot(lang)) < 0.9 else Vector3.UP)
		if OS.get_environment("OHNE_KLEID") != "":   # nur zum Nachstellen: Umhang und Rock verdecken im Längsblick die Faust
			for n in sk.find_children("Kleid_*", "MeshInstance3D", false, false): n.visible = false
		if OS.get_environment("MARKE") != "":   # nur zum Nachstellen: Kugeln an den Knochen der Endpose (Spitzen, Grundgelenke) und auf der Schaftachse
			var ende := {}
			sk.skeleton_updated.connect(func():
				for b in ["middle_01_r", "middle_03_r", "index_03_r", "pinky_03_r", "hand_r"]: ende[b] = sk.global_transform * sk.get_bone_global_pose(sk.find_bone(b)).origin, CONNECT_ONE_SHOT)
			await process_frame
			var mh := t.halt.duplicate() if not t.halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
			var gw2 := t.waffe.global_transform * Halt.griff_rahmen(mh)
			var punkte := {"achse": gw2.origin + gw2.basis.y.normalized() * 0.03}
			punkte.merge(ende)
			for k in punkte:
				var kugel := MeshInstance3D.new(); var sm := SphereMesh.new(); sm.radius = 0.004; sm.height = 0.008; kugel.mesh = sm
				var mat := StandardMaterial3D.new(); mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; mat.no_depth_test = true
				mat.albedo_color = Color.CYAN if k == "achse" else (Color.YELLOW if k.begins_with("middle_01") else Color.MAGENTA)
				kugel.material_override = mat; root.add_child(kugel); kugel.global_position = punkte[k]
				print("MARKE ", k, " ", punkte[k])
		if OS.get_environment("PRUEFFARBE") != "":   # Sokrates 23:41 „Waffe farbig, nicht schwarz“: Holz 6A4A2E und Leder 3A2A20 (waffen.py)
			# werden im Bild schwarz (ungeschattet gemessen 30,0C,01); nur zur Prüfung des Griffs: Waffe 4fach aufgehellt, alt wie neu, im Bild vermerkt
			for q in t.waffe.find_children("*", "MeshInstance3D", true, false) + ([t.waffe] if t.waffe is MeshInstance3D else []):
				for s in (q as MeshInstance3D).get_surface_override_material_count():
					var sm := (q as MeshInstance3D).get_surface_override_material(s)
					if sm is ShaderMaterial: (sm as ShaderMaterial).set_shader_parameter("toenung", _prueffarbe())
		if OS.get_environment("SPIELKAMERA") != "": spiel.kamera.springe()   # Chef 21:37: dieselbe Hand in Spielkamera und Handygröße
		else: kam.make_current()
		if OS.get_environment("LAUFEN_LASSEN") == "": spiel.held.process_mode = Node.PROCESS_MODE_DISABLED
		for f in 4: await process_frame
		await RenderingServer.frame_post_draw
		var datei := "%s/%s-%s%s.png" % [ordner, FOLGE[i], art, ("-" + OS.get_environment("BLICK")) if OS.get_environment("BLICK") != "" else ""]
		root.get_viewport().get_texture().get_image().save_png(datei)
		print("BILD1694 ", datei, " gang=", t.gang, " zweite Faust neben dem Schaft %.1f cm" % (100.0 * t.zweit_fehl))
		spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
	quit(0)

# PRUEFFARBE=1: Faktor 4 (bis 22.11.); PRUEFFARBE=r,g,b: eigener Faktor (1694, 23.11.: Faktor 4 überstrahlte den Stiel weiß im Glanz)
static func _prueffarbe() -> Vector3:
	var t := OS.get_environment("PRUEFFARBE").split(",")
	if t.size() == 3: return Vector3(float(t[0]), float(t[1]), float(t[2]))
	return Vector3(4.0, 4.0, 4.0)
