# 2032-Ü3 (Prüferin 25.11., 19:51: neu zwischen Faust und Gürtel eine fast schwarze Fläche): Lagenkarte ohne Bild. Spielkamera-Strahlen
# wie guertel_2032.gd (Stehen, Bild 0, mit Haltung und rueck) über ein Feld um das Handgelenk, je Strahl der erste Treffer als Zeichen:
# . nichts (Raum dahinter)   H/h Haut Hand und Finger vorn/innen   U/u Unterarm   O/o Oberarm   L/l übrige Haut
# 0..9 Kleidstück vorn (Legende), * Kleid innen. Mit --dunkel: je Treffer vorn zusätzlich Normale zur Kamera (Streiflicht < 0,25: ~).
# Run: godot --headless --path godot -s res://tests/zerleg_2032.gd -- --nur=L_rowena [--feld=60] [--schritt=2]
extends "res://tests/guertel_2032.gd"

func _guertel(name: String, m: Node3D) -> void:
	var feld := 60
	var schritt := 2
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--feld="): feld = int(a.substr(7))
		if a.begins_with("--schritt="): schritt = int(a.substr(10))
	root.add_child(m)
	await process_frame
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var ap := m.get_node_or_null("AnimationPlayer") as AnimationPlayer
	var netz := _sammle(sk)
	var haltung: Node = null
	for c in sk.get_children():
		if c is HeldFigur.Haltung: haltung = c
	ap.speed_scale = 0.0
	ap.play("Stehen", 0.0)
	ap.seek(0.0, true)
	if haltung:
		haltung.grund_w = -1.0; haltung.arm_w = -1.0; haltung.dame_w = -1.0
	sk.skeleton_updated.connect(_nach_update.bind(sk))
	_posen = []
	_warte = true
	await process_frame
	await process_frame
	sk.skeleton_updated.disconnect(_nach_update)
	var lage := _haut(netz, _posen)
	var V: PackedVector3Array = lage[0]; var N: PackedVector3Array = lage[1]
	var dir := Vector3(0, -sin(deg_to_rad(NEIGUNG)), -cos(deg_to_rad(NEIGUNG)))
	var rueck := float(HeldFigur.RUECK)
	for i in V.size(): V[i] += dir * rueck * smoothstep(0.0, 0.2, N[i].dot(dir))
	var art := PackedByteArray(); art.resize(V.size())
	for tl in netz["teile"]:
		var b0: int = tl[0]; var anz: int = tl[1]; var bs = tl[2]; var ws = tl[3]; var nn: int = tl[4]; var bb: PackedInt32Array = tl[5]
		for i in anz:
			var best := 0
			for q in nn:
				if ws[i * nn + q] > ws[i * nn + best]: best = q
			var kn := sk.get_bone_name(bb[bs[i * nn + best]]) if bb[bs[i * nn + best]] >= 0 else ""
			var c := "L"
			if FINGER.any(func(x): return kn.begins_with(x)): c = "H"
			elif kn.begins_with("lowerarm"): c = "U"
			elif kn.begins_with("upperarm"): c = "O"
			art[b0 + i] = c.unicode_at(0)
	var lname: Array = netz["lname"]
	var g := _gitter(V, netz["tri"])
	var quer := Vector3.RIGHT; var hoch := quer.cross(dir).normalized()
	var px := 3.4 / 1080.0 / maxf(m.scale.x, 0.01)
	var tri: PackedInt32Array = netz["tri"]
	var legende := {}
	for bn in ["hand_r", "hand_l"]:
		var b := sk.find_bone(bn)
		if b < 0: continue
		var mitte: Vector3 = (_posen[b] as Transform3D).origin
		print("ZERLEG2032 %s %s Feld %d Schritt %d (oben = oben im Bild, links = links im Bild)" % [name, bn, feld, schritt])
		var zahl := {}
		for iy in range(feld, -feld - 1, -schritt):
			var zeile := ""
			for ix in range(-feld, feld + 1, schritt):
				var von := mitte + quer * (ix * px) + hoch * (iy * px) - dir
				var e := _alle(V, netz, g, von, dir, 2.0)
				var z := "."
				if not e.is_empty():
					var t: int = e[0][1]
					var i0: int = tri[t]
					var fn := (V[tri[t + 1]] - V[i0]).cross(V[tri[t + 2]] - V[i0])
					var innen := fn.dot(dir) <= 0.0
					var ln: String = lname[netz["lage"][i0]]
					if ln.begins_with("Kleid"):
						if innen: z = "*"
						else:
							if not legende.has(ln): legende[ln] = String.chr(48 + legende.size())
							z = legende[ln]
					else:
						z = String.chr(art[i0])
						if innen: z = z.to_lower()
				zahl[z] = zahl.get(z, 0) + 1
				zeile += z
			print("ZK " + zeile)
		print("ZERLEG2032 %s %s Zählung %s" % [name, bn, str(zahl)])
	print("ZERLEG2032 Legende %s" % str(legende))
	# Ecken von Hand und Fingern im Inneren eines Kleidstücks: Strahl in zwei Richtungen, beide mit ungerader Zahl Schnitte (Parität)
	var drin := {}
	for i in V.size():
		if art[i] != 72: continue
		for l in lname.size():
			if not String(lname[l]).begins_with("Kleid"): continue
			var ok := true
			for rd in [Vector3(1, 0.13, 0.07), Vector3(-0.11, 0.17, 1)]:
				var n := 0
				for e in _alle_lage(V, netz, g, V[i], rd.normalized(), 0.6, l): n += 1
				if n % 2 == 0: ok = false; break
			if ok:
				var sd := "r" if V[i].x < 0 else "l"
				drin["%s %s" % [lname[l], sd]] = drin.get("%s %s" % [lname[l], sd], 0) + 1
	print("ZERLEG2032 %s Fingerecken im Kleid %s" % [name, str(drin)])
	m.queue_free()
	await process_frame

func _alle_lage(V: PackedVector3Array, netz: Dictionary, g: Dictionary, von: Vector3, dir: Vector3, weit: float, l: int) -> Array:
	var tri: PackedInt32Array = netz["tri"]
	return _alle(V, netz, g, von + dir * 0.0005, dir, weit).filter(func(e): return int(netz["lage"][tri[e[1]]]) == l)
