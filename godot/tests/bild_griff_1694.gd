extends SceneTree
# 1694 (Chef 18.11., 17:01): Bild der rechten Hand mit Waffe im Dorf, Held angehalten im Stehen, Kamera nah an der Hand (Tusche wie im
# Spiel). Je Waffe ein Bild nach BILDER=<ordner>/<waffe>-<alt|neu>.png; GRIFF1694=0 = alter Griff.
#   GRIFF1694=0|1 BILDER=<ordner> xvfb-run -a godot --path . --resolution 900x900 -s res://tests/bild_griff_1694.gd -- --bild1694

const FOLGE := ["quarterstaff", "handaxe", "longsword"]

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 13 * 60
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
		hw.ausruestung["MAIN_HAND"] = {"uid": 9500 + i, "base": FOLGE[i], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		spiel.held_figur_neu("")
		spiel.held.richtung = Vector3.ZERO
		for f in 40: await process_frame
		var sk := Gebiet.finde(spiel.held.modell, "Skeleton3D") as Skeleton3D
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
		kam.global_position = hand + (vorn * 0.55 + rechts * 0.45 + Vector3.UP * 0.12)
		kam.look_at(hand, Vector3.UP)
		if OS.get_environment("LAENGS") != "":   # Ursache (Chef 17:38): Blick längs des Schafts auf die Faust
			var m := t.halt.duplicate() if not t.halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
			var gw := t.waffe.global_transform * Halt.griff_rahmen(m)
			var ax := gw.basis.y.normalized()
			kam.global_position = gw.origin - ax * 0.45
			kam.look_at(gw.origin, Vector3.UP if absf(ax.y) < 0.9 else Vector3.FORWARD)
		kam.make_current()
		spiel.held.process_mode = Node.PROCESS_MODE_DISABLED
		for f in 4: await process_frame
		await RenderingServer.frame_post_draw
		var datei := "%s/%s-%s.png" % [ordner, FOLGE[i], art]
		root.get_viewport().get_texture().get_image().save_png(datei)
		print("BILD1694 ", datei)
		spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
	quit(0)
