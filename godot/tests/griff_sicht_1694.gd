extends SceneTree
# 1694/1711 (Sokrates 22:13: „Messung meldet passt, Bild zeigt Fehler“): Messung am sichtbaren Gitter statt an Knochen und halt.json.
# Der Held steht im Dorf wie im Bild (bild_griff_1694, Spielkamera-Pose); gemessen wird nach dem Zeichnen:
#  - Schaft echt: Mitte der Ecken des Waffennetzes in Scheiben längs der Achse um die Faust, gegen die Achse aus halt.json (cm)
#  - Hand echt: Körpernetz mit bake_mesh_from_current_skeleton_pose (so, wie es gezeichnet wird), Ecken mit Hauptgewicht an Hand
#    oder Finger der Waffenseite; um die echte Schaftachse: Umschlingung (Winkel in 10°-Feldern mit Haut näher als Radius + 2,5 cm),
#    Spalt Handfläche (nächste Ecke der Hand selbst, ohne Finger) und Eindringen (kleinster Abstand minus Radius)
#   MESS=1694 xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/griff_sicht_1694.gd   (Exit 1 bei Fehler; ohne Bildschirm ist das Netz leer)

const FOLGE := ["quarterstaff", "handaxe", "longsword"]
const FELD := 10.0
const NAH := 0.025
var fehler_zahl := 0
var reihe := []   # je Aktualisierung des Skeletts ein Satz Werte (cm, Grad)

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
	for i in FOLGE.size():
		hw.ausruestung["MAIN_HAND"] = {"uid": 9600 + i, "base": FOLGE[i], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		spiel.held_figur_neu("")
		spiel.held.richtung = Vector3.ZERO
		for f in 80: await process_frame   # Übergang nach dem Anlegen abwarten (bis 4 Bilder mit hohler Faust)
		# außerhalb der Änderung gibt get_bone_global_pose die Pose ohne Modifikatoren (auch bake): gemessen wird in skeleton_updated
		var sk := Gebiet.finde(spiel.held.modell, "Skeleton3D") as Skeleton3D
		var erg := {}
		var mod: Node3D = spiel.held.modell
		var cb := func(): erg["z"] = miss(mod)
		reihe.clear()
		sk.skeleton_updated.connect(cb)
		for f in 20: await process_frame   # die Ruhebewegung bewegt die Hand: Median über 20 Bilder
		sk.skeleton_updated.disconnect(cb)
		if not reihe.is_empty() and reihe[0].umschl == 0.0 and reihe[0].haut < -100.0:
			print("SICHT1694 FEHLER: keine Haut im Netz (ohne Bildschirm gestartet? bake braucht xvfb)"); fehler_zahl += 1; continue
		if reihe.is_empty():
			print("SICHT1694 %-12s %s" % [FOLGE[i], erg.get("z", "keine Aktualisierung")]); continue
		if OS.get_environment("REIHE") != "":
			for e in reihe: print("  R k=%.1f u=%d t=%.1f h=%.1f a=%.1f r=%.1f" % [e.kontakt, int(e.umschl), e.tief, e.haut, e.achse, e.radius])
		var med := {}
		for k in reihe[0]:
			var a := []
			for e in reihe: a.append(e[k])
			a.sort(); med[k] = a[a.size() / 2]
		var gut: bool = med.kontakt <= 0.3 and med.kontakt >= -0.8 and med.umschl >= 300.0 and med.tief >= -1.0
		print("SICHT1694 %-12s Spalt Handfläche %.1f cm, Umschlingung %d°, Eindringen %.1f cm, Haut %.1f cm, Achse %.1f cm, Radius %.1f cm, Versatz halt %.1f cm (Median %d Bilder)%s" % [
			FOLGE[i], med.kontakt, int(med.umschl), med.tief, med.haut, med.achse, med.radius, med.versatz, reihe.size(), "" if gut else "  FEHLER"])
		fehler_zahl += 0 if gut else 1
	print("SICHT1694 %d Fehler" % fehler_zahl)
	quit(1 if fehler_zahl > 0 else 0)

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
	if wpts.is_empty(): return "kein Schaft an der Faust (getragen, nicht gehalten)"
	var c := Vector3.ZERO
	for p in wpts: c += p
	c /= wpts.size()
	c = c - ax * (c - mitte).dot(ax)   # echte Achse durch c, Richtung ax
	var rs: Array[float] = []
	for p in wpts:
		var v := p - c
		rs.append((v - ax * v.dot(ax)).length())
	rs.sort()
	var r: float = rs[rs.size() / 2]   # Median: Parierstange und Klingenansatz zählen nicht
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
	# Handinnenseite wie tragen.gd _an_schaft: senkrecht auf Fingerrichtung und Knöchellinie, zur Daumenseite
	var mp := faust
	var hp := G * sk.get_bone_global_pose(hb).origin
	var lang := (mp - hp).normalized()
	var zf := G * sk.get_bone_global_pose(sk.find_bone("index_01_" + s)).origin
	var kf := G * sk.get_bone_global_pose(sk.find_bone("pinky_01_" + s)).origin
	var th := G * sk.get_bone_global_pose(sk.find_bone("thumb_01_" + s)).origin
	var fl := lang.cross((zf - kf).normalized()).normalized()
	if fl.dot(th - hp) < 0.0: fl = -fl
	var haut_innen := -INF   # Haut der Handinnenseite unter dem Mittelfingergrundgelenk (m entlang fl)
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
				var vm := p - mp
				if nur_hand.has(bk) and (vm - fl * vm.dot(fl)).length() < 0.025: haut_innen = maxf(haut_innen, vm.dot(fl))
				if d < NAH:
					var w := rad_to_deg(atan2(qv.dot(quer_y), qv.dot(quer_x)))
					felder[int(floor((w + 180.0) / FELD))] = true
	var achse_innen := (c - mp).dot(fl)
	# Prüfung (1694): Schaft an der Handfläche (Spalt zwischen Schaftoberfläche und Haut unter dem Grundgelenk höchstens 0,3 cm),
	# umschlungen (mindestens 300°), nicht tief im Finger (Eindringen höchstens 1 cm)
	var kontakt := achse_innen - r - haut_innen
	reihe.append({"kontakt": 100.0 * kontakt, "umschl": felder.size() * FELD, "tief": 100.0 * tief, "haut": 100.0 * haut_innen,
		"achse": 100.0 * achse_innen, "radius": 100.0 * r, "versatz": 100.0 * versatz})
	return ("haut_tragen %.2f, haut_innen %.1f cm, achse_innen %.1f cm, " % [t.haut_tiefe, 100.0 * haut_innen, 100.0 * achse_innen]) + "versatz_halt %.1f cm, radius %.1f cm, hand_ecken %d, umschlingung %d°, spalt_handflaeche %.1f cm, eindringen %.1f cm" % [
		100.0 * versatz, 100.0 * r, n_hand, int(felder.size() * FELD), 100.0 * spalt, 100.0 * tief]
