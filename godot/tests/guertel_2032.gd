# 2032 (Prüfer 25.11., 17:00 zu 2028-Ü5: Rowenas rechte Finger auf dem Gürtel fast schwarz, Lagen dort Kleid-Innenseite): Für alle Figuren
# mit Kaufkleid (Liste wie handgelenk_2028) in Stehen, Bild 0, mit Haltung: Strahlen der Spielkamera (orthogonal, 30 Grad von oben, von vorn,
# ein Strahl je Bildpunkt bei 3,4 m auf 1080 Punkte) über ein Feld um jedes Handgelenk. Gezählt werden Bildpunkte an Hand und Fingern
# (der Strahl trifft irgendwo Haut mit Hand- oder Fingerknochen), deren erster Treffer die Rückseite (Innenseite) eines Kleidstücks ist und
# die einen ebensolchen Nachbarn haben (Fläche). Ecken wie toon.gdshader vertex() mit rueck (heldfigur RUECK).
# Rot (Ende 1), wenn eine Figur mehr als GRENZE solche Bildpunkte hat. Ohne Kaufdateien: „ohne Kauf“, Ende 0.
# Run: godot --headless --path godot -s res://tests/guertel_2032.gd [-- --nur=<Figur>]
extends "res://tests/handgelenk_2028.gd"

const GRENZE_2032 := 4
const FINGER := ["hand_", "thumb", "index", "middle", "ring", "pinky"]

func _messe() -> void:
	if not HauptmenueHelden.da():
		print("GUERTEL2032 ohne Kauf, 0 Fehler")
		quit(0)
		return
	var nur := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nur="): nur = a.substr(6)
	for h in ["Wachsoldat", "Zauberlehrling", "Jägerkind", "Klosterschüler", "Wanderer"]:
		for g in ["m", "w"]:
			if not HeldFigur.da(h, g): continue
			var hw := BrsHeld.fuer_spiel("Test", "Mensch", h)
			var modell := String(HeldFigur.tracht({"herkunft": h, "aussehen": {"geschlecht": g}})["modell"])
			var start_netze := ""
			for um in [false, true]:
				var aus := hw.ausruestung.duplicate()
				if um: aus["CLOAK"] = {"base": "cloak"}
				var name := modell + ("+Umhang" if um else "")
				if nur != "" and not name.begins_with(nur): continue
				var m := HeldFigur.baue({"herkunft": h, "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": aus}, [])
				if m == null: continue
				var sicht := ",".join(m.find_children("*", "MeshInstance3D", true, false).filter(func(x): return (x as MeshInstance3D).visible).map(func(x): return String(x.name)))
				if um and sicht == start_netze:
					m.free()
					continue
				start_netze = sicht
				await _guertel(name, m)
	var d := DirAccess.open("res://daten")
	if d:
		for f in d.get_files():
			if not (f.begins_with("held_L_") and f.ends_with(".bin")): continue
			var id := f.trim_prefix("held_L_").get_slice("_", 0)
			var name := "L_" + id
			if nur != "" and not name.begins_with(nur): continue
			var m := HeldFigur.person(id, [])
			if m == null: continue
			await _guertel(name, m)
	var rot := 0
	var summe := 0
	for k in ergebnis:
		summe += int(ergebnis[k])
		if int(ergebnis[k]) > GRENZE_2032:
			print("FEHLER %s: %d Bildpunkte an Hand und Fingern zeigen die Innenseite des Kleids (Grenze %d)" % [k, ergebnis[k], GRENZE_2032])
			rot += 1
	print("GUERTEL2032 %d Figuren, %d Bildpunkte Kleid-Innenseite an der Hand, %d Fehler" % [ergebnis.size(), summe, rot])
	quit(1 if rot else 0)

func _guertel(name: String, m: Node3D) -> void:
	root.add_child(m)
	await process_frame
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var ap := m.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if sk == null or ap == null or not ap.has_animation("Stehen"):
		m.queue_free()
		return
	var netz := _sammle(sk)
	if netz.is_empty():
		m.queue_free()
		return
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
	if _posen.is_empty():
		m.queue_free()
		return
	var lage := _haut(netz, _posen)
	var V: PackedVector3Array = lage[0]; var N: PackedVector3Array = lage[1]
	var dir := Vector3(0, -sin(deg_to_rad(NEIGUNG)), -cos(deg_to_rad(NEIGUNG)))
	var rueck := float(HeldFigur.RUECK)
	for i in V.size(): V[i] += dir * rueck * smoothstep(0.0, 0.2, N[i].dot(dir))
	# je Ecke: Haut an Hand oder Fingern (Knochen mit dem größten Gewicht); je Lage: Kleid
	var hand := PackedByteArray(); hand.resize(V.size())
	for tl in netz["teile"]:
		var b0: int = tl[0]; var anz: int = tl[1]; var bs = tl[2]; var ws = tl[3]; var nn: int = tl[4]; var bb: PackedInt32Array = tl[5]
		for i in anz:
			var best := 0
			for q in nn:
				if ws[i * nn + q] > ws[i * nn + best]: best = q
			var kn := sk.get_bone_name(bb[bs[i * nn + best]]) if bb[bs[i * nn + best]] >= 0 else ""
			hand[b0 + i] = 1 if FINGER.any(func(x): return kn.begins_with(x)) else 0
	var kleid := {}
	for l in (netz["lname"] as Array).size():
		kleid[l] = String(netz["lname"][l]).begins_with("Kleid")
	var g := _gitter(V, netz["tri"])
	var quer := Vector3.RIGHT; var hoch := quer.cross(dir).normalized()
	var px := 3.4 / 1080.0 / maxf(m.scale.x, 0.01)
	var tri: PackedInt32Array = netz["tri"]
	var n := 0
	var je := []
	for bn in ["hand_l", "hand_r"]:
		var b := sk.find_bone(bn)
		if b < 0: continue
		var mitte: Vector3 = (_posen[b] as Transform3D).origin
		var rs := {}
		var stueck := {}
		for iy in range(-HALB, HALB + 1):
			for ix in range(-HALB, HALB + 1):
				var von := mitte + quer * (ix * px) + hoch * (iy * px) - dir
				var alle := _alle(V, netz, g, von, dir, 2.0)
				if alle.is_empty(): continue
				var t: int = alle[0][1]
				var i0: int = tri[t]
				if not kleid[netz["lage"][i0]]: continue
				var fn := (V[tri[t + 1]] - V[i0]).cross(V[tri[t + 2]] - V[i0])
				if fn.dot(dir) > 0.0: continue   # Vorderseite (Wicklung der Kaufnetze: vorn zeigt längs des Blicks)
				var an_hand := false
				for e in alle:
					var tt: int = e[1]
					if not kleid[netz["lage"][tri[tt]]] and hand[tri[tt]] == 1: an_hand = true; break
				if not an_hand: continue
				rs[Vector2i(ix, iy)] = true
				var ln: String = netz["lname"][netz["lage"][i0]]
				stueck[ln] = stueck.get(ln, 0) + 1
		var nb := 0
		for q in rs:
			for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if rs.has(q + o):
					nb += 1
					break
		n += nb
		je.append("%s %d%s" % [bn, nb, (" " + str(stueck)) if nb > 0 else ""])
	ergebnis[name] = n
	print("GUERTEL2032 %s: %d Bildpunkte Kleid-Innenseite an der Hand (%s)" % [name, n, ", ".join(je)])
	m.queue_free()
	await process_frame

# alle Treffer längs dir (alle Lagen, beide Seiten), nach Abstand -> [[Abstand, Dreieck], ...]
func _alle(V: PackedVector3Array, netz: Dictionary, g: Dictionary, von: Vector3, dir: Vector3, weit: float) -> Array:
	var tri: PackedInt32Array = netz["tri"]
	var res := []
	var bis := von + dir * weit
	var gesehen := {}
	for q in int(weit / ZELLE) + 2:
		var c := _zelle(von + dir * (float(q) * ZELLE))
		for x in range(c.x - 1, c.x + 2):
			for y in range(c.y - 1, c.y + 2):
				for z in range(c.z - 1, c.z + 2):
					var k := Vector3i(x, y, z)
					if not g.has(k): continue
					for t in g[k]:
						if gesehen.has(t): continue
						gesehen[t] = true
						var hit = Geometry3D.segment_intersects_triangle(von, bis, V[tri[t]], V[tri[t + 1]], V[tri[t + 2]])
						if hit != null: res.append([von.distance_to(hit), t])
	res.sort_custom(func(a, b): return a[0] < b[0])
	return res
