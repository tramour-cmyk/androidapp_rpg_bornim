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

## 1694 (23.11., roter Test griff_bild_1694: Netz meldete 330° Umschlingung, im Bild lag der Stiel offen zwischen den Fingern): Prüfung
## nach dem Bild. [pk]: Punkte der Hand in Welt (hand_punkte, im Signal skeleton_updated genommen); [sv]: SubViewport derselben Welt mit
## Kamera [kam]. Gezeichnet wird nur das Stück des Schafts in der Faust (zwischen den Ebenen durch Zeige- und Kleinfingergrundgelenk) in
## Prüffarbe ohne Licht; je Blick (innen: Handfläche, außen: Handrücken) Bildpunkte mit und ohne Körper: {innen, aussen} Anteil sichtbar,
## {innen_n, aussen_n} Bildpunkte ohne Körper (zu wenige: Schaft nicht im Bild)
const SICHT_HOECHST := 0.10   # höchstens so viel des Schafts in der Faust sichtbar
const SICHT_SCHLITZ := 2      # Bildpunkte (Bild 200 px, Faust etwa 120 px breit): Schlitze bis 4 px Breite zählen nicht
const SICHT_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, fog_disabled;
uniform vec3 a; uniform vec3 d; uniform float t0; uniform float t1;
varying vec3 wp;
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	float t = dot(wp - a, d);
	if (t < t0 || t > t1) discard;
	if (length(wp - a - d * t) > 0.05) discard;   // nur am Schaft (gebogene Klinge des Messers lief zurück durch die Ebenen)
	ALBEDO = vec3(1.0, 0.0, 1.0);
}
"""
static var _sicht_mat: ShaderMaterial
# der Körper nur um die Faust (Kugel KUGEL um ihre Mitte), schwarz: Oberschenkel, Gürtel, Rock davor verdecken sonst den Schaft
const KUGEL := 0.10
const KOERPER_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, fog_disabled;
uniform vec3 mitte; uniform float weit;
varying vec3 wp;
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	if (distance(wp, mitte) > weit) discard;
	ALBEDO = vec3(0.0);
}
"""
static var _koerper_mat: ShaderMaterial

static func hand_punkte(skel: Skeleton3D, s: String) -> Dictionary:
	var pk := {}
	for b in ["hand", "index_01", "middle_01", "pinky_01", "thumb_01"]:
		pk[b] = skel.global_transform * skel.get_bone_global_pose(skel.find_bone(b + "_" + s)).origin
	return pk

static func sicht(pk: Dictionary, ding: Node3D, halt: Dictionary, sv: SubViewport, kam: Camera3D, koerper: Array, bild := "") -> Dictionary:
	if _sicht_mat == null:
		var sh := Shader.new(); sh.code = SICHT_SHADER
		_sicht_mat = ShaderMaterial.new(); _sicht_mat.shader = sh
		var sk2 := Shader.new(); sk2.code = KOERPER_SHADER
		_koerper_mat = ShaderMaterial.new(); _koerper_mat.shader = sk2
	var lang: Vector3 = (pk["middle_01"] - pk["hand"]).normalized()
	var quer: Vector3 = (pk["index_01"] - pk["pinky_01"]).normalized()
	var fl := lang.cross(quer).normalized()
	if fl.dot(pk["thumb_01"] - pk["hand"]) < 0.0: fl = -fl
	var hm := halt.duplicate() if not halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
	var W: Transform3D = ding.global_transform * Halt.griff_rahmen(hm)
	var d := W.basis.y.normalized()
	var sch := Griff.schaft(ding, halt)
	var faust: Vector3 = (pk["index_01"] + pk["pinky_01"]) * 0.5
	var yq := (W.affine_inverse() * faust).y
	var c := Griff.mitte_bei(sch, yq - 0.02, yq + 0.02)
	var a := W * Vector3(c.x, yq, c.y)
	var ti: float = (pk["index_01"] - a).dot(d); var tk: float = (pk["pinky_01"] - a).dot(d)
	_sicht_mat.set_shader_parameter("a", a); _sicht_mat.set_shader_parameter("d", d)
	_sicht_mat.set_shader_parameter("t0", minf(ti, tk)); _sicht_mat.set_shader_parameter("t1", maxf(ti, tk))
	var waffen := ding.find_children("*", "MeshInstance3D", true, false) + ([ding] if ding is MeshInstance3D else [])
	_koerper_mat.set_shader_parameter("mitte", faust); _koerper_mat.set_shader_parameter("weit", KUGEL)
	var vorher_mat := {}
	for m in koerper: vorher_mat[m] = (m as MeshInstance3D).material_override
	var aus := {}
	for bl in ["innen", "aussen"]:
		var r: Vector3 = fl if bl == "innen" else -fl
		var mitte := faust + fl * 0.01
		kam.global_position = mitte + r * 0.32 + lang * 0.06
		kam.look_at(mitte, lang)
		kam.near = 0.05
		for m in waffen: (m as MeshInstance3D).material_override = _sicht_mat
		for m in koerper: (m as MeshInstance3D).material_override = _koerper_mat
		var mit := await _pruefpunkte(sv, bild + "-" + bl if bild != "" else "")
		for m in koerper: (m as MeshInstance3D).material_override = vorher_mat[m]
		var vorher := {}
		for m in koerper:
			vorher[m] = (m as MeshInstance3D).visible; (m as MeshInstance3D).visible = false
		var ohne := await _pruefpunkte(sv)
		for m in koerper: (m as MeshInstance3D).visible = vorher[m]
		for m in waffen: (m as MeshInstance3D).material_override = null
		aus[bl] = float(mit) / maxf(1.0, float(ohne))
		aus[bl + "_n"] = ohne
	return aus

static func sicht_gut(w: Dictionary) -> bool:
	return int(w.innen_n) >= 30 and int(w.aussen_n) >= 30 and float(w.innen) <= SICHT_HOECHST and float(w.aussen) <= SICHT_HOECHST

static func _pruefpunkte(sv: SubViewport, bild := "") -> int:
	for f in 2: await sv.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := sv.get_texture().get_image()
	if bild != "": img.save_png(bild + ".png")
	img.convert(Image.FORMAT_RGB8)
	var b := img.get_data()
	var w := img.get_width(); var h := img.get_height()
	var m := PackedByteArray(); m.resize(w * h)
	for i in w * h:
		m[i] = 1 if b[3 * i] > 200 and b[3 * i + 2] > 200 and b[3 * i + 1] < 64 else 0
	# schmale Schlitze zwischen den Fingern (Glieder schmaler als der Knöchelabstand, im Spielbild nicht zu sehen) zählen nicht: die
	# Maske wird um SICHT_SCHLITZ Bildpunkte abgetragen (je Schritt fällt jeder Punkt mit einem leeren Nachbarn weg), offene Stellen bleiben
	for it in SICHT_SCHLITZ:
		var m2 := m.duplicate()
		for y in range(1, h - 1):
			for x in range(1, w - 1):
				var i := y * w + x
				if m[i] == 1 and (m[i - 1] == 0 or m[i + 1] == 0 or m[i - w] == 0 or m[i + w] == 0): m2[i] = 0
		m = m2
	var n := 0
	for i in w * h: n += m[i]
	return n
