# 2028 (Fund Prüfer 1654-Ü11, 25.11.: fast schwarze Flecken an Rowenas Handgelenken): Blick in die hohle Hand. Für alle Figuren mit
# Kaufkleid (Liste wie durchstich_1631) in Stehen, Bild 0, mit Haltung: Strahlen der Spielkamera (orthogonal, 30 Grad von oben, von vorn,
# ein Strahl je Bildpunkt bei 3,4 m auf 1080 Punkte) über ein Feld um jedes Handgelenk (Knochen hand_l, hand_r). Gezählt werden
# Bildpunkte, deren erster Treffer die Rückseite (Innenseite) der Haut an Hand oder Fingern ist: dort fehlt Haut, man sieht in die Hand,
# die Tusche zieht an den Tiefensprüngen Linien (fast schwarz). Ecken dabei wie toon.gdshader vertex() mit rueck (heldfigur RUECK).
# Rot (Ende 1), wenn eine Figur mehr als GRENZE solche Bildpunkte hat. Ohne Kaufdateien: „ohne Kauf“, Ende 0.
# Run: godot --headless --path godot -s res://tests/handgelenk_2028.gd [-- --nur=<Figur>]
extends "res://tests/durchstich_1631.gd"

const HALB := 30          # halbe Seitenlänge des Felds um das Handgelenk, Bildpunkte der Spielkamera
const NEIGUNG := 30.0
const GRENZE := 0
const HAUT := ["Regular", "Superhero", "Leib", "Kopf", "Haende", "Hände", "Hand"]

var ergebnis := {}

func _initialize() -> void:
	_messe.call_deferred()

func _messe() -> void:
	if not HauptmenueHelden.da():
		print("HAND2028 ohne Kauf, 0 Fehler")
		quit(0)
		return
	var nur := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nur="): nur = a.substr(6)
	# Helden je Tracht und Geschlecht, mit Startausrüstung und einmal mit Umhang (wie durchstich_1631)
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
				await _hand(name, m)
	var d := DirAccess.open("res://daten")
	if d:
		for f in d.get_files():
			if not (f.begins_with("held_L_") and f.ends_with(".bin")): continue
			var id := f.trim_prefix("held_L_").get_slice("_", 0)
			var name := "L_" + id
			if nur != "" and not name.begins_with(nur): continue
			var m := HeldFigur.person(id, [])
			if m == null: continue
			await _hand(name, m)
	var rot := 0
	var summe := 0
	for k in ergebnis:
		summe += int(ergebnis[k])
		if int(ergebnis[k]) > GRENZE:
			print("FEHLER %s: %d Bildpunkte am Handgelenk zeigen die Innenseite der Hand (Grenze %d)" % [k, ergebnis[k], GRENZE])
			rot += 1
	print("HAND2028 %d Figuren, %d Bildpunkte in die Hand, %d Fehler" % [ergebnis.size(), summe, rot])
	quit(1 if rot else 0)

func _hand(name: String, m: Node3D) -> void:
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
	var g := _gitter(V, netz["tri"])
	var quer := Vector3.RIGHT; var hoch := quer.cross(dir).normalized()
	var px := 3.4 / 1080.0 / maxf(m.scale.x, 0.01)
	var haut := {}
	for l in (netz["lname"] as Array).size():
		var ln: String = netz["lname"][l]
		haut[l] = HAUT.any(func(x): return ln.contains(x)) and not ln.begins_with("Kleid")
	var n := 0
	var je := []
	for bn in ["hand_l", "hand_r"]:
		var b := sk.find_bone(bn)
		if b < 0: continue
		var mitte: Vector3 = (_posen[b] as Transform3D).origin
		var nb := 0
		for iy in range(-HALB, HALB + 1):
			for ix in range(-HALB, HALB + 1):
				var von := mitte + quer * (ix * px) + hoch * (iy * px) - dir
				var h := _erster(V, netz, g, von, dir, 2.0)
				if h.is_empty(): continue
				var t: int = h[0]
				var i0: int = netz["tri"][t]
				if not haut[netz["lage"][i0]]: continue
				var fn := (V[netz["tri"][t + 1]] - V[i0]).cross(V[netz["tri"][t + 2]] - V[i0])
				if fn.dot(dir) <= 0.0: nb += 1   # Wicklung der Kaufnetze (glTF): Vorderseite zeigt längs des Blicks
		n += nb
		je.append("%s %d" % [bn, nb])
	ergebnis[name] = n
	print("HAND2028 %s: %d Bildpunkte in die Hand (%s)" % [name, n, ", ".join(je)])
	m.queue_free()
	await process_frame

# nächster Treffer längs dir (alle Lagen, beide Seiten) -> [Dreieck]
func _erster(V: PackedVector3Array, netz: Dictionary, g: Dictionary, von: Vector3, dir: Vector3, weit: float) -> Array:
	var tri: PackedInt32Array = netz["tri"]
	var best := []; var bd := INF
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
						if hit == null: continue
						var dd := von.distance_to(hit)
						if dd < bd:
							bd = dd
							best = [t]
		if not best.is_empty() and float(q) * ZELLE > bd + ZELLE * 2.0: break
	return best
