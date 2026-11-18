extends SceneTree
# 1694/1711 (Sokrates 22:13: „Messung meldet passt, Bild zeigt Fehler“): Messung am sichtbaren Gitter statt an Knochen und halt.json.
# Der Held steht im Dorf wie im Bild (bild_griff_1694, Spielkamera-Pose); gemessen wird nach dem Zeichnen:
#  - Schaft echt: Mitte der Ecken des Waffennetzes in Scheiben längs der Achse um die Faust, gegen die Achse aus halt.json (cm)
#  - Hand echt: Körpernetz mit bake_mesh_from_current_skeleton_pose (so, wie es gezeichnet wird), Ecken mit Hauptgewicht an Hand
#    oder Finger der Waffenseite; um die echte Schaftachse: Umschlingung (Winkel in 10°-Feldern mit Haut näher als Radius + 2,5 cm),
#    Spalt Handfläche (nächste Ecke der Hand selbst, ohne Finger) und Eindringen (kleinster Abstand minus Radius)
#   xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/griff_sicht_1694.gd -- --sicht1694

const FOLGE := ["quarterstaff", "handaxe", "longsword"]
const FELD := 10.0
const NAH := 0.025

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 13 * 60
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	var fehler := 0
	for i in FOLGE.size():
		hw.ausruestung["MAIN_HAND"] = {"uid": 9600 + i, "base": FOLGE[i], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		spiel.held_figur_neu("")
		spiel.held.richtung = Vector3.ZERO
		for f in 40: await process_frame
		await RenderingServer.frame_post_draw
		var z := miss(spiel.held.modell)
		print("SICHT1694 %-12s %s" % [FOLGE[i], z])
	quit(fehler)

func miss(m: Node3D) -> String:
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var t: Tragen = null
	for n in sk.get_children():
		if n is Tragen: t = n
	if t == null or t.waffe == null: return "kein Tragen"
	var s := t.seite
	var hm := t.halt.duplicate() if not t.halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
	var g := t.waffe.global_transform * Halt.griff_rahmen(hm)
	var ax := g.basis.y.normalized()
	var G := sk.global_transform
	var faust := G * sk.get_bone_global_pose(sk.find_bone("middle_01_" + s)).origin
	var mitte := g.origin + ax * (faust - g.origin).dot(ax)   # Punkt der halt-Achse auf Höhe der Faust
	# --- Schaft echt: Ecken des Waffennetzes in ±6 cm um die Faust, näher als 4 cm an der halt-Achse
	var wpts: Array[Vector3] = []
	for mi in t.waffe.find_children("*", "MeshInstance3D", true, false) + ([t.waffe] if t.waffe is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		if me == null: continue
		var tr := (mi as MeshInstance3D).global_transform
		for su in me.get_surface_count():
			for q in me.surface_get_arrays(su)[Mesh.ARRAY_VERTEX]:
				var p: Vector3 = tr * q
				var v := p - mitte
				if absf(v.dot(ax)) > 0.06: continue
				if (v - ax * v.dot(ax)).length() < 0.04: wpts.append(p)
	if wpts.is_empty(): return "kein Schaft an der Faust"
	var c := Vector3.ZERO
	for p in wpts: c += p
	c /= wpts.size()
	c = c - ax * (c - mitte).dot(ax)   # echte Achse durch c, Richtung ax
	var rs: Array[float] = []
	for p in wpts:
		var v := p - c
		rs.append((v - ax * v.dot(ax)).length())
	rs.sort()
	var r: float = rs[int(rs.size() * 0.9)]
	var versatz := (c - mitte).length()
	# --- Hand echt: gezeichnetes Körpernetz
	var hand_knochen := {}
	var hb := sk.find_bone("hand_" + s)
	var nur_hand := {hb: true}
	var stapel := [hb]
	while not stapel.is_empty():
		var b: int = stapel.pop_back()
		hand_knochen[b] = true
		for ch in sk.get_bone_children(b): stapel.append(ch)
	var felder := {}
	var spalt := INF
	var tief := INF
	var n_hand := 0
	var quer_x := (G.basis * Vector3.UP).cross(ax).normalized()
	if quer_x.length() < 0.5: quer_x = ax.cross(Vector3.RIGHT).normalized()
	var quer_y := ax.cross(quer_x)
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var mi3 := mi as MeshInstance3D
		if mi3.mesh == null or mi3.skin == null or not mi3.visible: continue
		var gebacken := mi3.bake_mesh_from_current_skeleton_pose()
		if gebacken == null: continue
		var bind := {}
		for k in mi3.skin.get_bind_count():
			var nm := mi3.skin.get_bind_name(k)
			bind[k] = sk.find_bone(nm) if nm != "" else mi3.skin.get_bind_bone(k)
		for su in mini(mi3.mesh.get_surface_count(), gebacken.get_surface_count()):
			var roh := mi3.mesh.surface_get_arrays(su)
			var neu := gebacken.surface_get_arrays(su)
			var kn = roh[Mesh.ARRAY_BONES]; var gw = roh[Mesh.ARRAY_WEIGHTS]
			var pos = neu[Mesh.ARRAY_VERTEX]
			if kn == null or gw == null or pos == null: continue
			var je: int = kn.size() / maxi(1, pos.size())
			for vi in pos.size():
				var best := -1; var bw := 0.0
				for k in je:
					if gw[vi * je + k] > bw: bw = gw[vi * je + k]; best = int(kn[vi * je + k])
				var bk: int = bind.get(best, -1)
				if not hand_knochen.has(bk): continue
				var p: Vector3 = mi3.global_transform * pos[vi]
				var v := p - c
				var l := v.dot(ax)
				if absf(l) > 0.05: continue
				var qv := v - ax * l
				var d := qv.length() - r
				n_hand += 1
				tief = minf(tief, d)
				if nur_hand.has(bk): spalt = minf(spalt, d)
				if d < NAH:
					var w := rad_to_deg(atan2(qv.dot(quer_y), qv.dot(quer_x)))
					felder[int(floor((w + 180.0) / FELD))] = true
	return "versatz_halt %.1f cm, radius %.1f cm, hand_ecken %d, umschlingung %d°, spalt_handflaeche %.1f cm, eindringen %.1f cm" % [
		100.0 * versatz, 100.0 * r, n_hand, int(felder.size() * FELD), 100.0 * spalt, 100.0 * tief]
