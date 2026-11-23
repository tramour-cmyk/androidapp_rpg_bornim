class_name Griff
extends RefCounted
# 1694 (Chef 18.11., 17:01 „Als Systemlösung, genau“; Auftrag 19.11.: „Jede Figur des Spiels hält jeden Gegenstand sichtbar richtig“):
# der eine Griff für alle Figuren mit Fingerknochen (Held, Leute, Kaufmonster mit Menschengerüst). Wie Spiele es üblich lösen:
#  1. Haltepunkt am Gegenstand: Griff, Schaftachse, Radius (Halt, regeln/halt.json; Radius aus dem Netz), zweiter Griff bei Zweihändern
#  2. Halterung an der Hand: Stelle in der Faust aus dem Netz der Figur (Haut der Handfläche, Dicke der Grundglieder), je Körper einmal
#  3. Handhaltung je Griffart: die Finger schließen sich von der Ruhe aus Glied für Glied, bis sie anliegen (wie VR-Hände, die sich um
#     den Griff legen statt einer festen Pose je Waffe); Ergebnis je Lage des Schafts in der Hand zwischengespeichert (kein Rechnen je Bild)
# Einzelbild 19.11., 08:26 (Stiel quer über den Fingern bei Messung „passt“): der Schaft lag unter dem Grundgelenk, wo in der Faust die
# Grundglieder hinunterlaufen (Finger 1,4 cm im Stiel). Richtig: an der Handfläche UND an der Beugeseite der Grundglieder, davor zur
# Handwurzel hin. Alle Zahlen im Skelettraum; Längen der Hand in HAND_LANG (Handgelenk bis Mittelfingergrundgelenk) gerechnet.

const HAND_LANG := 0.09            # m: Handgelenk bis Mittelfingergrundgelenk am Kaufkörper; die Längen unten gelten dafür
const FINGER := ["index", "middle", "ring", "pinky"]
const SCHRITT := 4.0               # Grad je Schritt
const HOECHST := 28                # Schritte je Glied (112°)
const HAUT := 0.007                # m: Endgliedspitze (Knochen) so weit über der Oberfläche: die Fingerkuppe liegt an
const HAUT_MIN := 0.004            # m: näher: Glied im Schaft, öffnen
const DAUMEN_HAUT := 0.014         # m: Daumen (dicker als die Finger)
const FAUST_TIEFE := 0.011         # m: Grundgelenk bis Haut der Handinnenseite, wenn das Netz nichts liefert
const GRUND_DICKE := 0.009         # m: Grundglied, Knochen bis Beugeseite, wenn das Netz nichts liefert
const EINDRUCK := 0.006            # m: der Schaft drückt so weit in Haut und Finger (anliegend, kein Spalt)
const HALT_WEIT := 0.07            # m: weiter weg hält die Hand den Schaft nicht (getragen, auf dem Rücken)
static var ANLEGEN := float(OS.get_environment("ANLEGEN1694")) if OS.get_environment("ANLEGEN1694") != "" else 1.0   # Anteil
static var GEKOPPELT := OS.get_environment("KOPPEL1694") == "1"   # 1694: Glieder gemeinsam beugen (Versuch 23.11.: Kuppe zuerst am Stiel)
static var ANSCHLAG := OS.get_environment("ANSCHLAG1694") != "0"   # 1694: der Reihe nach, je Glied Anschlag KETTE_GRENZE (0: 110° je Glied)
const KETTE_ANTEIL := [1.0, 1.2, 0.8]   # Grund-, Mittel-, Endglied je Schritt (Verhältnis der Beugung beim Faustschluss)
const KETTE_GRENZE := [90.0, 110.0, 80.0]   # Grad: Anschlag je Glied
static var NUR_GLIED := OS.get_environment("GLIED1694") != "0"   # 1694: Haut je Glied erst ab einem Viertel seiner Länge
static var DAUMEN_UM := OS.get_environment("DAUMEN1694") != "0"   # 1694: Daumen im Grundgelenk um den Schaft
static var DAUMEN_RAUS := OS.get_environment("RAUS1694") != "0"   # 1694: Daumen im Schaft: an den Schaft legen wie die Finger (0: wie bis 23.11., 15:5x)
const DAUMEN_GRENZEN := [40.0, 60.0, 80.0]   # Grad: Anschlag Grund-, Mittel-, Endglied des Daumens
static var DEBUG := OS.get_environment("GRIFFKETTE") != ""
static var KONV := float(OS.get_environment("KONV1694")) if OS.get_environment("KONV1694") != "" else -16.0   # Grad je Finger (Versuch Handbeil 23.11.: -14: 11 %, -18: 9 % sichtbar, Kuppen stoßen zusammen)
static var STRECKEN := OS.get_environment("STRECKEN1694") != "0"   # 1694: Finger vor dem Schließen strecken
static var GELENK := OS.get_environment("GELENK1694") != "0"   # 1694: Beugen um das Gelenk (0: um die Schaftachse, wie bis 22.11.)
const NEU_AB := 0.002              # m bzw. rad*m: so weit darf der Schaft in der Hand wandern, bevor die Finger neu schließen

## hat die Seite [s] („r“, „l“) eine Hand mit Fingern (Menschengerüst: hand_r, index_01_r …)?
static func hat_hand(sk: Skeleton3D, s: String) -> bool:
	for b in ["hand_", "middle_01_", "index_01_", "pinky_01_", "thumb_01_"]:
		if sk.find_bone(b + s) < 0: return false
	return true

## Maßstab: Skeletteinheiten je Meter Kaufhand (aus der Ruhelage der Hand)
static func einheit(sk: Skeleton3D, s: String) -> float:
	var l := sk.get_bone_global_rest(sk.find_bone("middle_01_" + s)).origin.distance_to(sk.get_bone_global_rest(sk.find_bone("hand_" + s)).origin)
	return l / HAND_LANG if l > 1e-5 else 1.0

## [Grundgelenk Mittelfinger, Fingerrichtung (Handgelenk → Knöchel), Handinnenseite] in der aktuellen Pose (rest: Ruhelage)
static func flaeche(sk: Skeleton3D, s: String, rest := false) -> Array:
	var P := func(n: String) -> Vector3:
		var i := sk.find_bone(n + s)
		return sk.get_bone_global_rest(i).origin if rest else sk.get_bone_global_pose(i).origin
	var mp: Vector3 = P.call("middle_01_"); var hp: Vector3 = P.call("hand_")
	var lang := (mp - hp).normalized()
	var fl := lang.cross((P.call("index_01_") - P.call("pinky_01_")).normalized()).normalized()
	if fl.dot(P.call("thumb_01_") - hp) < 0.0: fl = -fl
	return [mp, lang, fl]

## Haut der Handfläche (unter der Stelle des Schafts) und Dicke des Grundglieds zur Beugeseite, aus dem gezeichneten Netz in Ruhelage
## (Ecken mit Hauptgewicht an Hand bzw. Grundglied des Mittelfingers); je Skelett, Seite und Radius einmal (Meta am Skelett)
static func hand_mass(sk: Skeleton3D, s: String, r: float) -> Vector2:
	var key := "griff_%s_%d" % [s, int(round(r * 10000.0))]
	if sk.has_meta(key): return sk.get_meta(key)
	var u := einheit(sk, s)
	var haut := FAUST_TIEFE * u; var grund := GRUND_DICKE * u
	var ih := sk.find_bone("hand_" + s); var mf := sk.find_bone("middle_01_" + s)
	var f := flaeche(sk, s, true)
	var mp: Vector3 = f[0]; var lang: Vector3 = f[1]; var fl: Vector3 = f[2]
	var kinder := sk.get_bone_children(mf)
	var mlang := (sk.get_bone_global_rest(kinder[0]).origin - mp) if kinder.size() > 0 else lang * 0.04 * u
	var mlen := mlang.length(); mlang = mlang.normalized()
	var ecken := []   # [Ecke in Ruhelage, an der Hand]
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var m3 := mi as MeshInstance3D
		if m3.mesh == null or m3.skin == null or not m3.visible: continue
		var bh := -1; var bm := -1
		for k in m3.skin.get_bind_count():
			var nm := m3.skin.get_bind_name(k)
			var b := sk.find_bone(nm) if nm != "" else m3.skin.get_bind_bone(k)
			if b == ih: bh = k
			if b == mf: bm = k
		if bh < 0 and bm < 0: continue
		for su in m3.mesh.get_surface_count():
			var a := m3.mesh.surface_get_arrays(su)
			var pos = a[Mesh.ARRAY_VERTEX]; var kn = a[Mesh.ARRAY_BONES]; var gw = a[Mesh.ARRAY_WEIGHTS]
			if pos == null or kn == null or gw == null or pos.size() == 0: continue
			var je: int = kn.size() / pos.size()
			for vi in pos.size():
				var best := -1; var bw := 0.0
				for k in je:
					if gw[vi * je + k] > bw: bw = gw[vi * je + k]; best = int(kn[vi * je + k])
				if best != bh and best != bm: continue
				var knochen := ih if best == bh else mf
				ecken.append([sk.get_bone_global_rest(knochen) * (m3.skin.get_bind_pose(best) * pos[vi]), best == bh])
	var dick := -INF
	for e in ecken:
		if e[1]: continue
		var rel: Vector3 = e[0] - mp
		var t := rel.dot(mlang)
		if t > 0.2 * mlen and t < 0.8 * mlen: dick = maxf(dick, rel.dot(fl))
	if dick > 0.0: grund = dick
	var basis := mp - lang * (r + grund)
	var tief := -INF
	for e in ecken:
		if not e[1]: continue
		var rel: Vector3 = e[0] - basis
		var t := rel.dot(fl)
		if t > 0.0 and (rel - fl * t).length() < 0.012 * u: tief = maxf(tief, t)
	if tief > 0.0: haut = tief
	var w := Vector2(haut, grund)
	sk.set_meta(key, w)
	return w

## Verschiebung (quer zum Schaft, Skelettraum), die die Schaftachse durch [o] mit Richtung [d] an die Stelle in der Faust bringt;
## ZERO, wenn die Hand den Schaft nicht hält (weiter als HALT_WEIT)
## [r_bei]: Radius in einer Richtung quer zum Schaft (Skelettraum, ovale Griffe); ohne: r
static func schub(sk: Skeleton3D, s: String, o: Vector3, d: Vector3, r: float, r_bei := Callable()) -> Vector3:
	var f := flaeche(sk, s)
	var mp: Vector3 = f[0]; var lang: Vector3 = f[1]; var fl: Vector3 = f[2]
	var u := einheit(sk, s)
	var nah := o + d * (mp - o).dot(d)
	if mp.distance_to(nah) > HALT_WEIT * u: return Vector3.ZERO
	var hm := hand_mass(sk, s, r)
	var ein := EINDRUCK * u
	var fq := (fl - d * fl.dot(d)).normalized()
	var lq := (lang - d * lang.dot(d)).normalized()
	var rf := float(r_bei.call(-fq)) if r_bei.is_valid() else r     # zur Handfläche hin
	var rl := float(r_bei.call(lq)) if r_bei.is_valid() else r      # zu den Grundgliedern hin
	var ziel := mp + fq * (rf + hm.x - ein) - lang * (rl + hm.y - ein)
	var w := ziel - nah
	w -= d * w.dot(d)
	# 1694 (Netz 19.11., 09:42: Grundglied des Kleinfingers 1 cm im Griff): die Knöchellinie läuft schräg (Kleinfinger näher am
	# Handgelenk), der Schaft liegt am Mittelfinger richtig und schneidet das Grundglied des Kleinfingers; er geht so weit zur
	# Handwurzel, dass er vor jedem Grundgelenk liegt
	var zuviel := 0.0
	for fi in FINGER:
		var kf := sk.get_bone_global_pose(sk.find_bone(fi + "_01_" + s)).origin
		var a := (o + w) + d * (kf - (o + w)).dot(d)
		zuviel = maxf(zuviel, (a - kf).dot(lq) + (rl + hm.y - ein))
	return w - lq * zuviel

## Stelle in der Faust im Raum des Handknochens (Leute: der Gegenstand folgt der Hand ohne Drehung um den Griff)
static func stelle_lokal(sk: Skeleton3D, s: String, r: float) -> Vector3:
	var f := flaeche(sk, s, true)
	var hm := hand_mass(sk, s, r)
	var ein := EINDRUCK * einheit(sk, s)
	var ziel: Vector3 = f[0] + f[2] * (r + hm.x - ein) - f[1] * (r + hm.y - ein)
	return sk.get_bone_global_rest(sk.find_bone("hand_" + s)).affine_inverse() * ziel

## Schaft des Gegenstands (m, Raum des Griffs nach Halt): Querschnitt je 5 mm längs der Achse aus den Dreiecken (nicht den Ecken:
## Staffel 458.3 ist low-poly, der Griff des Langschwerts hat zwischen Knauf und Parierstange keine Ecke, der Median der Ecken nahm den
## Knauf als Griff). {"profil": {Scheibe: mittlerer Abstand}, "lo", "hi"}: freier Griff um den Griffpunkt (Querschnitt unter „grenze“),
## unten bis zum Knauf, oben bis Parierstange, Kopf oder Blatt
const GRIFF_DICK := 0.02           # m: weiteste Stelle des Querschnitts; weiter ist Knauf, Parierstange oder Kopf
const SCHEIBE := 0.005
const ACHSE_WEIT := 0.06           # m: Schnittpunkte weiter von der Griffachse gehören nicht zum Griff (Sehne, Schaft der Armbrust)
static var _schaft := {}
static func schaft(ding: Node3D, halt: Dictionary) -> Dictionary:
	var key := ""
	for mi in ding.find_children("*", "MeshInstance3D", true, false) + ([ding] if ding is MeshInstance3D else []):
		if (mi as MeshInstance3D).mesh: key += str((mi as MeshInstance3D).mesh.get_rid().get_id()) + ","
	if _schaft.has(key): return _schaft[key]
	var m := halt if not halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
	var g := Halt.griff_rahmen(m)
	var punkte := {}
	var kanten := {}   # je Scheibe Schnittkanten der Dreiecke (Paare von Punkten): der Umriss, wie er gezeichnet wird
	for mi in ding.find_children("*", "MeshInstance3D", true, false) + ([ding] if ding is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		if me == null: continue
		var tr := g.affine_inverse() * HeldFigur.im_raum(ding, mi)
		for su in me.get_surface_count():
			var a := me.surface_get_arrays(su)
			var vs: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var ix = a[Mesh.ARRAY_INDEX]
			var n: int = ix.size() if ix != null and ix.size() > 0 else vs.size()
			for t in range(0, n - 2, 3):
				var p: Array[Vector3] = []
				for k in 3: p.append(tr * vs[ix[t + k] if ix != null and ix.size() > 0 else t + k])
				var y0 := minf(p[0].y, minf(p[1].y, p[2].y)); var y1 := maxf(p[0].y, maxf(p[1].y, p[2].y))
				if y1 < -1.5 or y0 > 1.5: continue
				for sc in range(int(ceil(y0 / SCHEIBE)), int(floor(y1 / SCHEIBE)) + 1):
					var y := sc * SCHEIBE
					# 1694: nur was nah an der Achse liegt, gehört zum Griff (Bogen: die Sehne 10–15 cm daneben machte den Querschnitt
					# zum ganzen Bogen, „nicht in der Hand“)
					var nahe := 0
					for k in 3:
						var u0 := p[k]; var w0 := p[(k + 1) % 3]
						if (u0.y - y) * (w0.y - y) > 0.0 or is_equal_approx(u0.y, w0.y): continue
						var q0 := u0.lerp(w0, (y - u0.y) / (w0.y - u0.y))
						if Vector2(q0.x, q0.z).length() < ACHSE_WEIT: nahe += 1
					if nahe == 0: continue
					var qs: Array[Vector2] = []
					for k in 3:
						var u := p[k]; var w := p[(k + 1) % 3]
						if (u.y - y) * (w.y - y) > 0.0 or is_equal_approx(u.y, w.y): continue
						var q := u.lerp(w, (y - u.y) / (w.y - u.y))
						if not punkte.has(sc): punkte[sc] = []
						punkte[sc].append(Vector2(q.x, q.z)); qs.append(Vector2(q.x, q.z))
					if qs.size() >= 2:
						if not kanten.has(sc): kanten[sc] = PackedVector2Array()
						kanten[sc].append(qs[0]); kanten[sc].append(qs[1])
	# je Scheibe Mitte (der Schaft steht nicht immer genau auf der Achse aus Halt: Großaxt der Staffel 0,7 cm daneben), mittlerer und
	# größter Abstand zur Mitte
	var profil := {}; var mitte := {}; var groesst := {}
	for sc in punkte:
		var c := Vector2.ZERO
		for q in punkte[sc]: c += q
		c /= punkte[sc].size()
		var su := 0.0; var mx := 0.0
		for q in punkte[sc]:
			su += (q - c).length(); mx = maxf(mx, (q - c).length())
		profil[sc] = su / punkte[sc].size(); mitte[sc] = c; groesst[sc] = mx
	# 1694 (griff_alle 19.11., 10:13: Stiele von Axt, Speer, Stab dicker als 2 cm galten als Kopf, „kein Netz“): Grenze relativ zum
	# Querschnitt am Griffpunkt (dünnste Scheibe ±2 cm), Knauf, Parierstange und Kopf springen weit darüber hinaus
	var basis := INF
	for sc in range(-4, 5): if groesst.has(sc): basis = minf(basis, float(groesst[sc]))
	var grenze := maxf(GRIFF_DICK, basis * 1.35 + 0.003) if basis < INF else GRIFF_DICK
	var dick := func(sc: int) -> bool: return not profil.has(sc) or float(groesst[sc]) > grenze
	var lo := 0; var hi := 0
	if not dick.call(0):
		while not dick.call(lo - 1): lo -= 1
		while not dick.call(hi + 1): hi += 1
	var e := {"profil": profil, "mitte": mitte, "kanten": kanten, "groesst": groesst, "grenze": grenze, "lo": lo * SCHEIBE, "hi": hi * SCHEIBE}
	_schaft[key] = e
	return e

## gehört die Scheibe [sc] zum freien Griff (nicht Knauf, Parierstange, Kopf)?
static func frei(sch: Dictionary, sc: int) -> bool:
	return sch["profil"].has(sc) and float(sch["groesst"][sc]) <= float(sch["grenze"])

## mittlerer Radius des Schafts zwischen y0 und y1 (m, Raum des Griffs); ohne Querschnitt 1,5 cm
static func radius_bei(sch: Dictionary, y0: float, y1: float) -> float:
	var rs := []
	for sc in range(int(floor(y0 / SCHEIBE)), int(ceil(y1 / SCHEIBE)) + 1):
		if frei(sch, sc): rs.append(float(sch["profil"][sc]))
	if rs.is_empty(): return 0.015
	rs.sort()
	return rs[rs.size() / 2]

## Abstand der Oberfläche von der Mitte der Scheibe [sc] in Richtung [v] (Strahl gegen die Schnittkanten, weitester Treffer); -1 ohne
static func oberflaeche(sch: Dictionary, sc: int, v: Vector2) -> float:
	if not sch["kanten"].has(sc): return -1.0
	var c: Vector2 = sch["mitte"][sc]
	var r := v.normalized()
	var best := -1.0
	var k: PackedVector2Array = sch["kanten"][sc]
	for i in range(0, k.size() - 1, 2):
		var a := k[i] - c; var b := k[i + 1] - c
		var e := b - a
		var den := r.x * e.y - r.y * e.x
		if absf(den) < 1e-9: continue
		var t := (a.x * e.y - a.y * e.x) / den       # Abstand längs des Strahls
		var s := (a.x * r.y - a.y * r.x) / den       # Stelle auf der Kante
		if t > 0.0 and s >= -1e-4 and s <= 1.0001: best = maxf(best, t)
	return best

## größter Abstand der Oberfläche in ±45° um [v] (je 15°), über ±[weit] Scheiben (die Faust ist breit); [sonst] ohne Umriss
static func breite(sch: Dictionary, sc: int, v: Vector2, sonst: float, weit := 1) -> float:
	var m := -1.0
	for ds in range(-weit, weit + 1):
		if sch["profil"].has(sc + ds) and not frei(sch, sc + ds): continue   # Knauf, Parierstange
		for a in range(-45, 46, 15): m = maxf(m, oberflaeche(sch, sc + ds, v.rotated(deg_to_rad(a))))
	return m if m > 0.0 else sonst

## Mitte des Schafts zwischen y0 und y1 quer zur Achse (x, z im Raum des Griffs)
static func mitte_bei(sch: Dictionary, y0: float, y1: float) -> Vector2:
	var c := Vector2.ZERO; var n := 0
	for sc in range(int(floor(y0 / SCHEIBE)), int(ceil(y1 / SCHEIBE)) + 1):
		if sch["mitte"].has(sc) and frei(sch, sc): c += sch["mitte"][sc]; n += 1
	return c / n if n > 0 else Vector2.ZERO

## Radius am Griffpunkt (Hand um den Griff, ±4,5 cm)
static func radius(ding: Node3D, halt: Dictionary) -> float:
	return radius_bei(schaft(ding, halt), -0.045, 0.045)

## Lage des Gegenstands in der Faust (Skelettraum). [g]: Griffrahmen des Gegenstands im Skelettraum (Halt.griff_rahmen, Basis mit dem
## Maßstab Modell → Skelett), [sch]: schaft(); [griffart] „einhand“ (Faust mitten auf dem freien Griff, nicht auf Knauf oder Parierstange),
## „zweihand“ (Faust oben am Griff, Platz für die zweite darunter), „stab“ (wo die Bewegung ihn fasst). Ergebnis: verschieben (um so viel
## den Gegenstand verschieben), o und d (Schaftachse an der Faust), r (Radius), o2 und r2 (zweite Hand); leer, wenn die Hand nicht hält
const HAND_HALB := 0.045           # m: halbe Breite der Faust längs des Schafts
const RAND := 0.012                # m: Abstand der Faust zu Knauf und Parierstange über die halbe Faustbreite hinaus
const ZWEIT := 2.2                 # halbe Faustbreiten von Faust zu Faust bei zwei Händen
static func am_schaft(sk: Skeleton3D, s: String, g: Transform3D, sch: Dictionary, griffart: String, bewegen := true) -> Dictionary:
	var d := g.basis.y.normalized()
	var k := g.basis.y.length()
	var u := einheit(sk, s)
	var halb := HAND_HALB * u / k
	var faust := (sk.get_bone_global_pose(sk.find_bone("index_01_" + s)).origin + sk.get_bone_global_pose(sk.find_bone("pinky_01_" + s)).origin) * 0.5
	var t := (faust - g.origin).dot(d) / k
	var lo: float = sch["lo"]; var hi: float = sch["hi"]
	var y := t
	# 1694 (23.11., held_WACHE_W mit Langschwert: Mittelglied des Zeigefingers 3 cm in der Parierstange, der Finger blieb gestreckt): die
	# Faust hält RAND Abstand zu Knauf und Parierstange (der Zeigefinger reicht über die halbe Faustbreite hinaus)
	var rand := RAND * u / k
	# kurzer Griff (Dolch, Kurzschwert): die Faust an die Parierstange, der Kleinfinger darf über den Knauf (mittig lag der Zeigefinger
	# auf der Parierstange und blieb gestreckt)
	if griffart == "einhand": y = hi - halb - rand if hi - lo < 2.0 * (halb + rand) else clampf(t, lo + halb + rand, hi - halb - rand)
	elif griffart == "zweihand": y = clampf(t, minf(lo + (ZWEIT + 1.0) * halb, hi - halb - rand), hi - halb - rand)
	var laengs := d * (t - y) * k if bewegen else Vector3.ZERO
	var c := mitte_bei(sch, y - halb, y + halb)
	var o := g * Vector3(c.x, y, c.y) + laengs
	var r := radius_bei(sch, y - halb, y + halb) * k
	var ysc := int(floor(y / SCHEIBE))
	var gi := g.affine_inverse()
	var r_bei := func(richtung: Vector3) -> float:   # Richtung im Skelettraum → größter Radius an der Faust ±45° um sie (die Handfläche
		var rq := gi.basis * richtung                 # liegt breit an, ein ovaler Griff stößt mit der breiten Seite hinein)
		return breite(sch, ysc, Vector2(rq.x, rq.z), r / k, int(halb / SCHEIBE)) * k
	var w := schub(sk, s, o, d, r, r_bei)
	var haelt := w != Vector3.ZERO
	if not bewegen:   # ein anderer führt den Gegenstand (Leute: Stab am Boden): nur, ob die Hand ihn hält
		haelt = (faust - (o + d * (faust - o).dot(d))).length() < HALT_WEIT * u
		w = Vector3.ZERO
	var verschoben := laengs + w
	var form := func(p: Vector3) -> float:   # Punkt im Skelettraum → Abstand zur gezeichneten Oberfläche
		var q := gi * (p - verschoben)
		var sc := int(floor(q.y / SCHEIBE))
		if not sch["mitte"].has(sc): return (Vector2(q.x, q.z).length() - r / k) * k
		var v := Vector2(q.x, q.z) - (sch["mitte"][sc] as Vector2)
		var f2 := oberflaeche(sch, sc, v)
		return (v.length() - (f2 if f2 > 0.0 else float(sch["profil"][sc]))) * k
	var e := {"verschieben": verschoben, "o": o + w, "d": d, "r": r, "form": form, "haelt": haelt}
	if griffart == "zweihand":
		var y2 := y - ZWEIT * halb
		var c2 := mitte_bei(sch, y2 - halb, y2 + halb)
		e["o2"] = g * Vector3(c2.x, y2, c2.y) + laengs + w
		e["r2"] = radius_bei(sch, y2 - halb, y2 + halb) * k
		var ysc2 := int(floor(y2 / SCHEIBE))
		var r2: float = e["r2"]
		e["r_bei2"] = func(richtung: Vector3) -> float:
			var rq := gi.basis * richtung
			return breite(sch, ysc2, Vector2(rq.x, rq.z), r2 / k, int(halb / SCHEIBE)) * k
	return e

## Finger und Daumen um den Schaft (Achse [o] + t·[d], Radius [r]) schließen, von der Ruhe aus. [merk]: Zwischenspeicher des Aufrufers
## (Dictionary); solange der Schaft in der Hand an derselben Stelle liegt, werden nur die gemerkten Drehungen gesetzt
## [form]: Abstand eines Punkts (Skelettraum) zur Oberfläche des Gegenstands, wie gezeichnet (am_schaft „form“: ovale und eckige Griffe);
## ohne: rund mit Radius r
static func schliessen(sk: Skeleton3D, s: String, o: Vector3, d: Vector3, r: float, merk: Dictionary, form := Callable()) -> void:
	var ih := sk.find_bone("hand_" + s)
	var H := sk.get_bone_global_pose(ih).affine_inverse()
	var ol := H * o; var dl := (H.basis * d).normalized()
	var u := einheit(sk, s)
	if merk.has("o") and (merk["o"] as Vector3).distance_to(ol) < NEU_AB * u and (merk["d"] as Vector3).dot(dl) > 0.9995 and is_equal_approx(float(merk["r"]), r):
		for k in merk["dreh"]: sk.set_bone_pose_rotation(k, merk["dreh"][k])
		return
	var quer := func(p: Vector3) -> float:
		var v := p - o
		return (v - d * v.dot(d)).length()
	var abst := form if form.is_valid() else func(p: Vector3) -> float: return float(quer.call(p)) - r
	var dreh := {}
	var f := flaeche(sk, s)
	var fl: Vector3 = f[2]
	var gehalten := float(quer.call(f[0])) <= HALT_WEIT * u
	var ne := netz_finger(sk, s)
	var mk: Array[int] = []
	for g in ["_01_", "_02_", "_03_"]:
		var i := sk.find_bone("middle" + g + s)
		if i >= 0:
			mk.append(i); sk.set_bone_pose_rotation(i, sk.get_bone_rest(i).basis.get_rotation_quaternion())
	var mitte_dir: Vector3 = (sk.get_bone_global_pose(mk[1]).origin - sk.get_bone_global_pose(mk[0]).origin).normalized() if mk.size() > 1 else f[1]
	for fi in FINGER:
		var kette: Array[int] = []
		for g in ["_01_", "_02_", "_03_"]:
			var i := sk.find_bone(fi + g + s)
			if i >= 0: kette.append(i)
		if kette.size() < 2: continue
		for i in kette: sk.set_bone_pose_rotation(i, sk.get_bone_rest(i).basis.get_rotation_quaternion())
		# 1694 (23.11., griff_bild_1694: Finger schräg über dem Stiel, Stiel zwischen ihnen sichtbar): jedes Glied beugt um sein Gelenk
		# (quer zum Finger in der Ebene der Hand), nicht um die Schaftachse; um die Schaftachse gedreht lief der Finger schräg seitwärts
		var ax := d
		if GELENK:
			# Finger aneinander (in Ruhe gespreizt, im Bild Spalten zwischen den Fingern, durch die der Stiel zu sehen war): Grundglied um
			# die Handnormale parallel zum Mittelfinger
			var fr := (sk.get_bone_global_pose(kette[1]).origin - sk.get_bone_global_pose(kette[0]).origin).normalized()   # Grundglied
			var fq := (fr - fl * fr.dot(fl)).normalized(); var mq := (mitte_dir - fl * mitte_dir.dot(fl)).normalized()
			if fi != "middle" and fq.length() > 0.5 and mq.length() > 0.5:
				# parallel zum Mittelfinger und KONV Grad je Finger Abstand zu ihm hin (die Glieder sind schmaler als der Abstand der
				# Knöchel: parallel blieben 0,5 cm Spalt, in der Faust laufen die Finger zusammen)
				var zu := (sk.get_bone_global_pose(mk[0]).origin - sk.get_bone_global_pose(kette[0]).origin)
				zu = (zu - fl * zu.dot(fl) - mq * zu.dot(mq)).normalized()
				var schritte := float(abs(FINGER.find(fi) - 1))
				var ziel := mq.rotated(fl, 0.0)
				ziel = (mq + zu * tan(deg_to_rad(KONV * schritte))).normalized()
				_beuge(sk, kette[0], fl, rad_to_deg(fq.signed_angle_to(ziel, fl)) * ANLEGEN)
				fr = (sk.get_bone_global_pose(kette[1]).origin - sk.get_bone_global_pose(kette[0]).origin).normalized()
			ax = fr.cross(fl).normalized()
			# erst gestreckt (Ruhelage einiger Körper mit gebeugtem Zeigefinger: Mittelglied schon 2,2 cm im Griff, der Finger blieb
			# gerade abstehen, held_WACHE_W): jedes Glied in die Richtung des vorigen, das Grundglied in die Richtung der Hand
			if STRECKEN:
				var vorher_dir: Vector3 = f[1]
				for j in kette.size():
					var a0 := sk.get_bone_global_pose(kette[j]).origin
					var a1 := sk.get_bone_global_pose(kette[j + 1]).origin if j + 1 < kette.size() else _spitze(sk, kette[j])
					var gd := (a1 - a0); gd = (gd - ax * gd.dot(ax)).normalized()
					var vd := (vorher_dir - ax * vorher_dir.dot(ax)).normalized()
					if gd.length() > 0.5 and vd.length() > 0.5:
						_beuge(sk, kette[j], ax, rad_to_deg(gd.signed_angle_to(vd, ax)))
					vorher_dir = vd
		# Beugerichtung: die, in der die Spitze zur Handinnenseite geht (fest aus der Hand, kein Springen von Bild zu Bild, 610)
		var vor := _spitze(sk, kette[-1])
		_beuge(sk, kette[0], ax, 10.0)
		var plus := _spitze(sk, kette[-1])
		_beuge(sk, kette[0], ax, -10.0)
		var vz := 1.0 if (plus - vor).dot(fl) > 0.0 else -1.0
		# um ax = Finger × Handnormale dreht +Winkel den Finger zur Handnormalen: das ist Beugen, ohne Probe (Kleinfinger, in Ruhe schon
		# gekrümmt: die Probe an der Spitze wählte Strecken, er stand gerade ab)
		if GELENK: vz = 1.0
		if not gehalten:   # nichts in der Hand: lockere Faust
			for i in kette: _beuge(sk, i, ax, vz * 120.0 / kette.size())
		else:
			var ab := func(von: int) -> float:
				var pts: Array[Vector3] = []
				for k in range(von, kette.size()): pts.append(sk.get_bone_global_pose(kette[k]).origin)
				pts.append(_spitze(sk, kette[-1]))
				var m := INF
				for k in range(1, pts.size()):
					m = minf(m, minf(float(abst.call(pts[k])), float(abst.call((pts[k] + pts[k - 1]) * 0.5))))
				return m
			if _netz_glied(ne, kette[0]) and _netz_glied(ne, kette[1]):
				# 1694 (griff_alle 19.11., 10:48: Umschlingung 200–290°, Glieder bis 3 cm im Griff): am gezeichneten Netz schließen, Glied
				# für Glied von der Hand aus: jedes Glied beugt, bis seine Haut am Griff liegt oder ein weiter vorn liegendes Glied (noch
				# gestreckt) anstößt; so legt sich der Finger um den Griff, statt dass die Kuppe zuerst anstößt und die Glieder offen bleiben
				_kette_netz(sk, kette, ne, abst, ax, vz, u)
			else:
				for j in kette.size():
					for st in HOECHST:
						if float(ab.call(j)) <= HAUT * u: break
						_beuge(sk, kette[j], ax, vz * SCHRITT)
					var n := 0
					while float(ab.call(j)) < HAUT_MIN * u and n < HOECHST:   # im Schaft: zurück
						_beuge(sk, kette[j], ax, -vz * SCHRITT); n += 1
		for i in kette: dreh[i] = sk.get_bone_pose_rotation(i)
	if gehalten:
		var dk: Array[int] = []
		for g in ["_02_", "_03_"]:
			var i := sk.find_bone("thumb" + g + s)
			if i >= 0: dk.append(i)
		if dk.size() == 2 and _netz_glied(ne, dk[0]) and _netz_glied(ne, dk[1]):
			for i in dk: sk.set_bone_pose_rotation(i, sk.get_bone_rest(i).basis.get_rotation_quaternion())
			var nahe := func() -> float:
				var m := INF
				for i in dk:
					var P := sk.get_bone_global_pose(i)
					for q in ne[i]: m = minf(m, float(abst.call(P * q)))
				return m
			var a0: float = nahe.call()
			_beuge(sk, dk[0], d, 10.0)
			var vz := 1.0 if float(nahe.call()) < a0 else -1.0
			_beuge(sk, dk[0], d, -10.0)
			var d1 := sk.find_bone("thumb_01_" + s)
			if DAUMEN_UM and d1 >= 0:
				# 1694 (23.11., griff_bild_1694: Daumen stand am Zeigefinger vorbei nach oben, zwischen ihm und dem Zeigefinger lag der Stiel
				# offen): Daumen Glied für Glied zur Mitte des Zeigefingers (Mittelglied, wie er in der Faust gebeugt ist), jedes Glied um die
				# Achse, die seine Spitze dorthin dreht; hält, wenn die Spitze anliegt, er den Schaft drücken würde oder am Anschlag ist
				var ziel := (sk.get_bone_global_pose(sk.find_bone("index_02_" + s)).origin + sk.get_bone_global_pose(sk.find_bone("index_03_" + s)).origin) * 0.5
				var dkette: Array[int] = [d1, dk[0], dk[1]]
				for i in dkette: sk.set_bone_pose_rotation(i, sk.get_bone_rest(i).basis.get_rotation_quaternion())
				for j in dkette.size():
					var w1 := 0.0
					while w1 < float(DAUMEN_GRENZEN[j]):
						var sp := _spitze(sk, dk[-1])
						if sp.distance_to(ziel) <= DAUMEN_HAUT * u: break
						var gp := sk.get_bone_global_pose(dkette[j]).origin
						var achse := (sp - gp).cross(ziel - gp)
						if achse.length() < 1e-6: break
						_beuge(sk, dkette[j], achse.normalized(), 2.0); w1 += 2.0
						if float(nahe.call()) < NETZ_DRUCK * u or _spitze(sk, dk[-1]).distance_to(ziel) >= sp.distance_to(ziel):
							_beuge(sk, dkette[j], achse.normalized(), -2.0); w1 -= 2.0; break
					if DEBUG: print("GRIFFKETTE %s %.0f° Spitze am Zeigefinger %.1f cm" % [sk.get_bone_name(dkette[j]), w1, 100.0 * _spitze(sk, dk[-1]).distance_to(ziel) / u])
				# 1694 (23.11., griff_alle je Glied: Daumen am dicken Griff 0,6 bis 2,4 cm im Holz, Großaxt): am dicken Griff reicht der Daumen
				# nicht an den Zeigefinger, sein Weg dorthin (und teils schon die Ruhelage) liegt im Schaft; dann wie die Finger Glied für Glied
				# an den Schaft, zuletzt keins im Holz
				if DAUMEN_RAUS and float(nahe.call()) < NETZ_DRUCK * u:
					for i in dkette: sk.set_bone_pose_rotation(i, sk.get_bone_rest(i).basis.get_rotation_quaternion())
					# erst das Grundglied (Mittelhand des Daumens) um die Schaftachse vom Schaft weg, bis der Daumen frei ist (Ruhelage bis
					# 1,5 cm im Schaft, die Glieder allein kamen nicht heraus)
					var a1: float = nahe.call()
					_beuge(sk, d1, d, 2.0)
					var vz1 := 1.0 if float(nahe.call()) > a1 else -1.0
					_beuge(sk, d1, d, -2.0)
					var n := 0
					while float(nahe.call()) < NETZ_HAUT * u and n < 25:
						_beuge(sk, d1, d, vz1 * 2.0); n += 1
					if DEBUG: print("GRIFFKETTE thumb_01_r %.0f° auf, Haut %.1f cm" % [2.0 * n, 100.0 * float(nahe.call()) / u])
					_kette_netz(sk, dk, ne, abst, d, vz, u)
			else:
				_kette_netz(sk, dk, ne, abst, d, vz, u)
		else: _daumen(sk, s, abst, d, u)
	for g in ["_01_", "_02_", "_03_"]:
		var i := sk.find_bone("thumb" + g + s)
		if i >= 0: dreh[i] = sk.get_bone_pose_rotation(i)
	merk["o"] = ol; merk["d"] = dl; merk["r"] = r; merk["dreh"] = dreh

# Daumen: Mittel- und Endglied um die Schaftachse, in der Richtung, in der der Abstand kleiner wird, bis er anliegt
static func _daumen(sk: Skeleton3D, s: String, abst: Callable, d: Vector3, u: float) -> void:
	var kette: Array[int] = []
	for g in ["_02_", "_03_"]:
		var i := sk.find_bone("thumb" + g + s)
		if i >= 0: kette.append(i)
	if kette.is_empty(): return
	for i in kette: sk.set_bone_pose_rotation(i, sk.get_bone_rest(i).basis.get_rotation_quaternion())
	var ab := func() -> float:
		var sp := _spitze(sk, kette[-1])
		var gl := sk.get_bone_global_pose(kette[-1]).origin
		return minf(float(abst.call(sp)), float(abst.call((sp + gl) * 0.5)))
	for j in kette.size():
		var a: float = ab.call()
		if a <= DAUMEN_HAUT * u: return
		_beuge(sk, kette[j], d, SCHRITT)
		var vz := 1.0 if float(ab.call()) < a else -1.0
		if vz < 0.0: _beuge(sk, kette[j], d, -SCHRITT)
		for st in HOECHST:
			var vorher: float = ab.call()
			if vorher <= DAUMEN_HAUT * u: return
			_beuge(sk, kette[j], d, vz * SCHRITT)
			var nach: float = ab.call()
			if nach < HAUT_MIN * u or nach >= vorher:
				_beuge(sk, kette[j], d, -vz * SCHRITT); break

## 1694: Haut der Finger aus dem gezeichneten Netz, je Fingerknochen der Seite [s] Ecken im Raum des Knochens (Hauptgewicht an ihm,
## höchstens NETZ_JE je Knochen, gleichmäßig ausgedünnt); je Skelett einmal (Meta). Leer, wenn das Netz keine Finger hat (Faust im Netz)
const NETZ_JE := 48
const NETZ_HAUT := 0.0015          # m: Haut des Glieds so nah am Griff: liegt an
const NETZ_DRUCK := -0.003         # m: tiefer im Griff: zurück
static func netz_finger(sk: Skeleton3D, s: String) -> Dictionary:
	var key := "griff_netz_" + s
	if sk.has_meta(key): return sk.get_meta(key)
	var finger := {}
	for fi in FINGER + ["thumb"]:
		for g in ["_01_", "_02_", "_03_"]:
			var i := sk.find_bone(fi + g + s)
			if i >= 0: finger[i] = true
	var roh := {}
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var m3 := mi as MeshInstance3D
		if m3.mesh == null or m3.skin == null or not m3.visible: continue
		var bind := {}
		for k in m3.skin.get_bind_count():
			var nm := m3.skin.get_bind_name(k)
			bind[k] = sk.find_bone(nm) if nm != "" else m3.skin.get_bind_bone(k)
		for su in m3.mesh.get_surface_count():
			var a := m3.mesh.surface_get_arrays(su)
			var pos = a[Mesh.ARRAY_VERTEX]; var kn = a[Mesh.ARRAY_BONES]; var gw = a[Mesh.ARRAY_WEIGHTS]
			if pos == null or kn == null or gw == null or pos.size() == 0: continue
			var je: int = kn.size() / pos.size()
			for vi in pos.size():
				var best := -1; var bw := 0.0
				for k in je:
					if gw[vi * je + k] > bw: bw = gw[vi * je + k]; best = int(kn[vi * je + k])
				var b: int = bind.get(best, -1)
				if not finger.has(b): continue
				if not roh.has(b): roh[b] = PackedVector3Array()
				roh[b].append(m3.skin.get_bind_pose(best) * pos[vi])
	var aus := {}
	for b in roh:
		var p: PackedVector3Array = roh[b]
		# 1694 (23.11., GRIFFKETTE: Grundglied des Kleinfingers „liegt an“ schon in Ruhe, 0° gebeugt, der Finger stand ab): Haut am
		# Gelenk zur Hand (Ballen mit Gewicht am Grundglied) zählt nicht zum Glied; nur ab einem Viertel seiner Länge
		var ch := sk.get_bone_children(b)
		if NUR_GLIED and ch.size() > 0:
			var lang := sk.get_bone_rest(ch[0]).origin
			var nur := PackedVector3Array()
			for q in p: if q.dot(lang) > 0.25 * lang.length_squared(): nur.append(q)
			if nur.size() >= 8: p = nur
		var schritt := maxi(1, p.size() / NETZ_JE)
		var q := PackedVector3Array()
		for i in range(0, p.size(), schritt): q.append(p[i])
		aus[b] = q
	sk.set_meta(key, aus)
	return aus

## 1694: Kette (Glieder von der Hand aus) um die Achse [a] in Richtung [vz] schließen, am Netz [ne]: alle Glieder beugen zugleich
## in kleinen Schritten (wie VR-Hände); ein Glied hält an, sobald seine Haut oder die eines Glieds weiter vorn am Griff liegt, die weiter
## vorn liegenden beugen weiter, bis auch sie anliegen. So legt sich der Finger um den Griff, statt dass die Kuppe zuerst anstößt
static func _kette_netz(sk: Skeleton3D, kette: Array[int], ne: Dictionary, abst: Callable, a: Vector3, vz: float, u: float) -> void:
	var haut := func(von: int) -> float:
		var m := INF
		for k in range(von, kette.size()):
			var P := sk.get_bone_global_pose(kette[k])
			for q in ne.get(kette[k], PackedVector3Array()): m = minf(m, float(abst.call(P * q)))
		return m
	var eigen := func(k: int) -> float:
		var m := INF
		var P := sk.get_bone_global_pose(kette[k])
		for q in ne.get(kette[k], PackedVector3Array()): m = minf(m, float(abst.call(P * q)))
		return m
	if not GEKOPPELT:
		# bis 22.11.: der Reihe nach von der Hand aus, jedes Glied bis seine eigene Haut anliegt
		var grenze0: Array = KETTE_GRENZE if kette.size() == 3 and ANSCHLAG else [110.0, 110.0, 110.0]
		for j in kette.size():
			var w := 0.0
			while float(eigen.call(j)) > NETZ_HAUT * u and w < float(grenze0[j]):
				_beuge(sk, kette[j], a, vz * 2.0); w += 2.0
			while float(eigen.call(j)) < NETZ_DRUCK * u and w > -10.0:
				_beuge(sk, kette[j], a, -vz * 2.0); w -= 2.0
			if DEBUG: print("GRIFFKETTE %s %.0f° Haut %.1f cm" % [sk.get_bone_name(kette[j]), w, 100.0 * float(eigen.call(j)) / u])
	else:
		# 1694 (23.11., griff_bild_1694; GRIFFKETTE: Grundglied 110° bis an den Anschlag, Mittelglied 0°, Kleinfinger mit Grund 0° und
		# Spitze 110° in der Luft): alle Glieder beugen zugleich im Verhältnis der Hand (Grund : Mittel : End = 1 : 1,2 : 0,8, wie VR-Hände,
		# die sich um den Griff legen), jedes bis zu seinem Anschlag; liegt ein Glied an, halten es und alle vor ihm (zur Hand hin), die
		# weiter vorn liegenden beugen weiter, bis auch sie anliegen
		var anteil: Array = KETTE_ANTEIL if kette.size() == 3 else [1.0, 1.0]
		var grenze: Array = KETTE_GRENZE if kette.size() == 3 else [70.0, 80.0]
		var w := []; w.resize(kette.size()); w.fill(0.0)
		var fest := 0   # Glieder 0..fest-1 liegen an oder halten
		for st in 120:
			if fest >= kette.size(): break
			var bewegt := false
			for j in range(fest, kette.size()):
				var dw: float = 2.0 * float(anteil[j])
				if float(w[j]) + dw > float(grenze[j]): continue
				_beuge(sk, kette[j], a, vz * dw); w[j] = float(w[j]) + dw; bewegt = true
			for j in range(kette.size() - 1, fest - 1, -1):
				if float(eigen.call(j)) <= NETZ_HAUT * u:
					fest = j + 1; break
			if not bewegt: break
		if DEBUG:
			for j in kette.size(): print("GRIFFKETTE %s %.0f° Haut %.1f cm" % [sk.get_bone_name(kette[j]), w[j], 100.0 * float(eigen.call(j)) / u])
	# zuletzt: kein Glied im Griff (von vorn nach hinten öffnen)
	for j in range(kette.size() - 1, -1, -1):
		var n := 0
		while float(haut.call(j)) < NETZ_DRUCK * u and n < 30:
			_beuge(sk, kette[j], a, -vz * 2.0); n += 1

static func _netz_glied(ne: Dictionary, b: int) -> bool:
	return ne.has(b) and (ne[b] as PackedVector3Array).size() > 0

## Spitze des Endglieds (Skelettraum): Kind des Knochens, sonst Ende in Richtung des Glieds
static func _spitze(sk: Skeleton3D, l: int) -> Vector3:
	var ch := sk.get_bone_children(l)
	if ch.size() > 0: return sk.get_bone_global_pose(ch[0]).origin
	var gb := sk.get_bone_global_pose(l).origin
	return gb + (gb - sk.get_bone_global_pose(sk.get_bone_parent(l)).origin) * 0.85

## Knochen i um die Achse a (Skelettraum) um w Grad drehen, Kinder folgen
static func _beuge(sk: Skeleton3D, i: int, a: Vector3, w: float) -> void:
	var g := sk.get_bone_global_pose(i)
	var nb := Basis(a.normalized(), deg_to_rad(w)) * g.basis.orthonormalized()
	var p := sk.get_bone_parent(i)
	var pb := sk.get_bone_global_pose(p).basis.orthonormalized() if p >= 0 else Basis.IDENTITY
	sk.set_bone_pose_rotation(i, (pb.inverse() * nb).get_rotation_quaternion())
