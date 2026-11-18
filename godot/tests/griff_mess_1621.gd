extends SceneTree
# 1621 (Chef 18.11., 09:1x zu den Bildern: „Auf keinem der Bilder wird die Waffe gehalten. Jede Waffe schwebt“): Messung im Dorf wie
# im Spiel, ohne Bild. Je Gang (paket, A aus 1619) und Waffe: der Held geht 60 Bilder; je Bild Abstand des Griffs der Waffe (Halt) zur
# rechten Hand (Knochen hand_r) und der linken Hand zum Schaft; dann angehalten wie im Bild (process_mode DISABLED) und die Kopie
# (bewaffne, Bewegung pausiert) wie bild_laenge_1621.
#   MESS=1621 xvfb-run -a godot --rendering-driver vulkan --rendering-method mobile --path . -s res://tests/griff_mess_1621.gd -- --mess1621

const FOLGE := ["greataxe", "maul", "greatsword"]

var spiel
var titel: Label
var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var ebene := CanvasLayer.new()
	ebene.layer = 60
	root.add_child(ebene)
	titel = Label.new()
	titel.add_theme_font_size_override("font_size", 28)
	titel.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	titel.position = Vector2(24, 210)
	ebene.add_child(titel)
	spiel.zustand.minuten = 15 * 60
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	spiel.licht.ziel = 0.0
	spiel.licht.stelle(0.0)
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	spiel.kamera.zoom = spiel.kamera.NAH
	spiel.kamera.springe()
	Sprache.lang = "de"
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	var start: Vector3 = spiel.held.position
	for gang in ["paket", "A"]:
		for i in FOLGE.size():
			HeldFigur.waffen_gehen = gang
			hw.ausruestung["MAIN_HAND"] = {"uid": 9200 + i + (10 if gang == "A" else 0), "base": FOLGE[i], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
			spiel.held_figur_neu("")
			for c in spiel.held.stoesst.get_connections(): spiel.held.stoesst.disconnect(c["callable"])
			spiel.held.position = start
			spiel.held.richtung = Vector3(0, 0, 1)
			var r := []; var l := []
			for f in 60:
				await process_frame
				if f >= 20:
					var m := miss(spiel.held.modell); r.append(m[0]); l.append(m[1])
			r.sort(); l.sort()
			var mh := miss(spiel.held.modell)
			spiel.held.process_mode = Node.PROCESS_MODE_DISABLED
			for f in 5: await process_frame
			var mf := miss(spiel.held.modell)
			print("GRIFF1621 %-5s %-10s gehend: rechte Hand–Griff Median %.1f, höchstens %.1f cm; linke Hand–Schaft Median %.1f, höchstens %.1f cm | angehalten: %.1f / %.1f cm (vorher %.1f / %.1f)" % [
				gang, FOLGE[i], r[r.size() / 2], r[-1], l[l.size() / 2], l[-1], mf[0], mf[1], mh[0], mh[1]])
			spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
			spiel.held.richtung = Vector3.ZERO
			for f in 5: await process_frame
	HeldFigur.waffen_gehen = "A"
	spiel.held.richtung = Vector3.ZERO
	print("GRIFF1621 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler else 0)

# [rechte Hand (Knochen) zum Griffpunkt der Waffe, linke Hand zur Schaftlinie], cm
func miss(m: Node3D) -> Array:
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var w: Node3D = null
	for n in m.get_children():
		if String(n.name).contains("Getragen"): w = n
	var t: Tragen = null
	for n in sk.get_children():
		if n is Tragen: t = n
	if w == null or t == null: return [-1.0, -1.0]
	var g := w.global_transform * Halt.griff_rahmen(t.halt)
	var hr := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("hand_r")).origin
	var hl := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("hand_l")).origin
	var ax := g.basis.y.normalized()
	var v := hl - g.origin
	if OS.get_environment("GENAU") != "":
		var hm := Vector3.ZERO; var n := 0
		for bn in ["index_01_r", "pinky_01_r", "middle_01_r"]:
			var bi := sk.find_bone(bn)
			if bi >= 0: hm += sk.global_transform * sk.get_bone_global_pose(bi).origin; n += 1
		hm /= maxf(1, n)
		var hl2 := Vector3.ZERO; var n2 := 0
		for bn in ["index_01_l", "pinky_01_l", "middle_01_l"]:
			var bi := sk.find_bone(bn)
			if bi >= 0: hl2 += sk.global_transform * sk.get_bone_global_pose(bi).origin; n2 += 1
		hl2 /= maxf(1, n2)
		var vr := hm - g.origin; var vl := hl2 - g.origin
		print("  QUER Fingeransatz rechts zur Schaftlinie %.1f cm (längs %.1f), links %.1f cm (längs %.1f)" % [100.0 * (vr - ax * vr.dot(ax)).length(), 100.0 * vr.dot(ax), 100.0 * (vl - ax * vl.dot(ax)).length(), 100.0 * vl.dot(ax)])
		print("  GENAU faust_welt–Griff %.1f cm, faust_welt–hand_r %.1f, Fingeransatz–Griff %.1f, Waffe bei %s, hand_r bei %s, Massstab %.2f, top_level %s" % [
			100.0 * t.faust_welt.distance_to(g.origin), 100.0 * t.faust_welt.distance_to(hr), 100.0 * hm.distance_to(g.origin), g.origin, hr,
			m.global_basis.get_scale().y, w.top_level])
	return [100.0 * hr.distance_to(g.origin), 100.0 * (v - ax * v.dot(ax)).length()]
