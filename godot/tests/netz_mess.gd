class_name NetzMess
# 1711 (Sokrates 18.11., 22:13: „Messung meldet passt, Bild zeigt Fehler“ bei 1694 Faust, 760 Biss, 1535 Flanke): Messen am gezeichneten
# Netz statt an Knochen, Haltepunkten oder Kollisionsformen. Befund 1694: Knochen und halt.json meldeten 360° Umschlingung, das Netz
# zeigte 1 cm Spalt zur Handfläche. Regeln, die dabei nötig waren:
#  1. Außerhalb der Änderung liefert get_bone_global_pose die Pose OHNE Modifikatoren (Tragen, Atem, Blick …), bake ebenso:
#     gemessen wird im Signal skeleton_updated (Endpose nach allen Modifikatoren).
#  2. Die Ruhebewegung bewegt die Figur: Median über viele Bilder, nach dem Übergang (80 Bilder nach dem Anlegen).
#  3. Nur im Renderer des Projekts (Compatibility) mit Bildschirm (xvfb): ohne Fenster ist das Netz leer, unter Vulkan in Software
#     liefert bake je Bild ein anderes, teils leeres Netz.
# Nutzung: var nm := NetzMess.new(sk); nm.knochen_unter("hand_r"); sk.skeleton_updated.connect(func(): werte.append(nm.ecken()))

var sk: Skeleton3D
var nur := {}          # Knochenindex -> true: nur Ecken mit Hauptgewicht an diesen Knochen (leer = alle)

func _init(s: Skeleton3D) -> void:
	sk = s

## Knochen und alle Kinder (z. B. „hand_r“ = Hand mit Fingern)
func knochen_unter(name: String) -> void:
	var st := [sk.find_bone(name)]
	while not st.is_empty():
		var b: int = st.pop_back()
		if b < 0: continue
		nur[b] = true
		for c in sk.get_bone_children(b): st.append(c)

## Ecken (Welt) der sichtbaren, gehäuteten Netze unter dem Skelett, mit Hauptknochen: [[Vector3, Knochenindex], …]; im Signal
## skeleton_updated aufrufen
func ecken() -> Array:
	var aus := []
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var m3 := mi as MeshInstance3D
		if m3.mesh == null or m3.skin == null or not m3.visible: continue
		var gebacken := m3.bake_mesh_from_current_skeleton_pose()
		if gebacken == null: continue
		var bind := {}
		for k in m3.skin.get_bind_count():
			var nm := m3.skin.get_bind_name(k)
			bind[k] = sk.find_bone(nm) if nm != "" else m3.skin.get_bind_bone(k)
		for su in mini(m3.mesh.get_surface_count(), gebacken.get_surface_count()):
			var roh := m3.mesh.surface_get_arrays(su)
			var pos = gebacken.surface_get_arrays(su)[Mesh.ARRAY_VERTEX]
			var kn = roh[Mesh.ARRAY_BONES]; var gw = roh[Mesh.ARRAY_WEIGHTS]
			if kn == null or gw == null or pos == null or pos.size() == 0: continue
			var je: int = kn.size() / pos.size()
			for vi in pos.size():
				var best := -1; var bw := 0.0
				for k in je:
					if gw[vi * je + k] > bw: bw = gw[vi * je + k]; best = int(kn[vi * je + k])
				var b: int = bind.get(best, -1)
				if not nur.is_empty() and not nur.has(b): continue
				aus.append([m3.global_transform * pos[vi], b])
	return aus

## Median je Schlüssel über eine Reihe von Dictionaries mit Zahlen
static func median(reihe: Array) -> Dictionary:
	var med := {}
	if reihe.is_empty(): return med
	for k in reihe[0]:
		var a := []
		for e in reihe: a.append(e[k])
		a.sort(); med[k] = a[a.size() / 2]
	return med

## 1694: Griff am gezeichneten Netz. Hand (Hand und Finger der Seite [s]) gegen die Oberfläche des Gegenstands aus seinen Dreiecken
## (Griff.schaft: Querschnitt je 5 mm, Umriss der Schnittkanten; die Ecken allein gaben bei der low-poly-Staffel 458.3 den Knauf als
## Griff), in der Lage, in der er gezeichnet wird; im Signal skeleton_updated aufrufen. Werte in cm und Grad:
##  kontakt: nächste Ecke der Handfläche zur Oberfläche (negativ: hinein), tief: Grund- und Mittelglieder, kuppe: Endglieder,
##  umschl: Winkel rundum mit Haut näher als NAH, ecken: Ecken der Hand am freien Griff, leer: der Gegenstand ist nicht in der Hand
const NAH := 0.02      # m: Haut höchstens 2 cm über dem Griff zählt als umschlossen (1694, 19.11., 10:53: mit 1 cm zählten die Mulde
                       # der Handfläche und der Spalt zwischen Kuppen und Ballen als offen, obwohl sie innen in der Faust liegen und
                       # man dort nicht durchsieht; ein Stiel quer über den Knöcheln bleibt bei 2 cm halb offen, rund 180°)
const FELD := 10.0
static func griff(skel: Skeleton3D, s: String, ding: Node3D, halt: Dictionary) -> Dictionary:
	var hm := halt.duplicate() if not halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
	var W := ding.global_transform * Halt.griff_rahmen(hm)
	var k := W.basis.y.length()            # Welt je Modellmeter
	var Wi := W.affine_inverse()
	var sch := Griff.schaft(ding, halt)
	var G := skel.global_transform
	var hb := skel.find_bone("hand_" + s)
	var faust := G * ((skel.get_bone_global_pose(skel.find_bone("index_01_" + s)).origin + skel.get_bone_global_pose(skel.find_bone("pinky_01_" + s)).origin) * 0.5)
	var qf := Wi * faust
	if Vector2(qf.x, qf.z).length() * k > 0.08 or qf.y < float(sch.lo) - 0.06 or qf.y > float(sch.hi) + 0.06:
		return {"leer": true, "ecken": 1, "kontakt": 0.0, "umschl": 0.0, "tief": 0.0, "kuppe": 0.0, "radius": 0.0}
	var nm := NetzMess.new(skel)
	nm.knochen_unter("hand_" + s)
	var felder := {}
	var spalt := INF; var tief := INF; var kuppe := INF
	var n_hand := 0
	var rsum := 0.0
	var dbg := {}
	for e in nm.ecken():
		var q: Vector3 = Wi * (e[0] as Vector3)
		if absf(q.y - qf.y) > 0.06: continue
		var sc := int(floor(q.y / Griff.SCHEIBE))
		if not Griff.frei(sch, sc) or q.y < float(sch.lo) or q.y > float(sch.hi): continue   # Knauf, Parierstange
		var v := Vector2(q.x, q.z) - (sch.mitte[sc] as Vector2)
		var fl := Griff.oberflaeche(sch, sc, v)   # Umriss, wie gezeichnet (eckige und ovale Griffe)
		var d: float = (v.length() - (fl if fl > 0.0 else float(sch.profil[sc]))) * k
		n_hand += 1
		rsum += float(sch.profil[sc]) * k
		var bname := skel.get_bone_name(e[1])
		if e[1] == hb: spalt = minf(spalt, d)
		elif bname.contains("_03_") or bname.contains("_04_"): kuppe = minf(kuppe, d)
		else: tief = minf(tief, d)
		if d < NAH:
			var fk := int(floor((rad_to_deg(atan2(v.y, v.x)) + 180.0) / FELD))
			felder[fk] = true
			if OS.get_environment("GRIFFDEBUG") != "": dbg[fk] = bname.substr(0, 3) + bname.substr(bname.find("_") + 1, 2)
	if OS.get_environment("GRIFFDEBUG") != "":
		var z := ""
		for fk in 36: z += (dbg[fk] if dbg.has(fk) else "-----") + " "
		print("GRIFFDEBUG ", z)
	return {"kontakt": 100.0 * spalt, "umschl": felder.size() * FELD, "tief": 100.0 * tief, "kuppe": 100.0 * kuppe,
		"radius": 100.0 * rsum / maxf(1, n_hand), "ecken": n_hand}

## Prüfung (1694): Handfläche am Griff (Spalt höchstens 0,3 cm; hinein höchstens 1,2 cm: die Handfläche ist 2,5 cm dick, gebeugte Finger
## ziehen die Haut am Grundgelenk nach innen), umschlossen (mindestens 300°), Grund- und Mittelglieder nicht tiefer als 0,6 cm im Griff
## (das war der Fehler: Grundglieder 1,4 cm im Stiel, der Stiel sichtbar über den Fingern), Fingerkuppen (weich, dem Griff zugewandt)
## bis 1,2 cm
static func griff_gut(w: Dictionary) -> bool:
	return w.kontakt <= 0.3 and w.kontakt >= -1.2 and w.umschl >= 300.0 and w.tief >= -0.6 and w.kuppe >= -1.2
