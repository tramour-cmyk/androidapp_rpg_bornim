# 457.2 (Chef 01.11., 11:49: „unsere Signatur muss sich wiederfinden“): die Signatur des Kampforts an einer Stelle, damit
# jede Probe wie das Spiel zeichnet: Toon-Licht (toon.gdshader, figur.gd), Tusche nach Licht (tusche_licht.gdshader, drei
# Schablonen: Welt 0, Gruppe 2, Gegner 3), Sonne mit Schlagschatten. Der Kampfort (kampfort.gd) baut seine Tusche und Sonne
# hier; Probeskripte mit eigener Bühne (tests/schilde_film.gd u. a.) rufen einrichten(). Ohne Signatur nur mit Schalter
# OHNE_SIGNATUR=1 (Messläufe wie TUSCHE=0, MASKE); dann steht es im Log, und eine Vorlage braucht „Chef erlaubt ohne Signatur“.
# Vor jedem Bild prüft pruefen(), ob alles da ist; fehlt etwas, bricht die Probe ab (wache()).
extends Node

const SONNE_LICHT := Vector3(-45, 55, 0)     # Chef 28.10., 08:09 (r9 ja): mit Tusche nach Licht die Sonne −45, 55

var mats: Array[ShaderMaterial] = []
var cam: Camera3D
var sonne: DirectionalLight3D
## Mitte des Bildinhalts (Welt): Tiefe für die breite Linie, Bildbreite in Metern
var ziel := Vector3.ZERO
## freie Bühne (Dinge schweben, kein Boden der Lichtung): breite Linie in jeder Höhe
var frei := false


static func aus() -> bool:
	return OS.get_environment("OHNE_SIGNATUR") != ""


## Der Schalter, mit dem eine Probe bewusst ohne volle Signatur zeichnet ("" = keiner): OHNE_SIGNATUR=1, die Messläufe
## der Tusche (TUSCHE=0 ohne Linie, TUSCHE=alt alte Tusche, kampfort.gd) und MASKE (Gegner flach magenta, probe.gd).
static func schalter() -> String:
	if aus():
		return "OHNE_SIGNATUR=1"
	if OS.has_environment("TUSCHE") and OS.get_environment("TUSCHE") != "licht":
		return "TUSCHE=" + OS.get_environment("TUSCHE")
	if OS.get_environment("MASKE") != "":
		return "MASKE=" + OS.get_environment("MASKE")
	return ""


## Sonne wie im Kampfort: Richtung bei Tusche nach Licht, Schlagschatten weich, nicht schwarz.
static func sonne_wie_kampf(sun: DirectionalLight3D, licht: bool) -> void:
	sun.rotation_degrees = Vector3(-65, 0, 0)     # höher und von vorn als im Dorf (kampfort.gd)
	if licht or OS.has_environment("KAMPF_SONNE"):     # 348.13a Probe (Tom): KAMPF_SONNE=<Höhe>,<seitlich>
		var sv := (OS.get_environment("KAMPF_SONNE") if OS.has_environment("KAMPF_SONNE") else "%d,%d" % [SONNE_LICHT.x, SONNE_LICHT.y]).split(",")
		sun.rotation_degrees = Vector3(float(sv[0]), float(sv[1]), 0)
	sun.shadow_enabled = not aus()
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 40.0
	sun.shadow_blur = 1.5
	sun.shadow_opacity = 0.7     # Prüfer Stand 7: harte schwarze Schatten
	sun.shadow_normal_bias = 1.2
	sun.light_energy = 1.3
	sun.light_color = Color(1.0, 0.94, 0.82)


## Bildschirmfüllende Fläche vor der Kamera mit einer Tusche (vertex schreibt POSITION direkt).
static func quad(c: Camera3D, sh: Shader, width: float, thick: float) -> ShaderMaterial:
	var q := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(2, 2)
	q.mesh = qm
	q.extra_cull_margin = 16384.0
	q.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var tm := ShaderMaterial.new()
	tm.shader = sh
	tm.set_shader_parameter("px", width)
	tm.set_shader_parameter("dick", thick)
	if OS.get_environment("TUSCHE_MAGENTA") != "":     # Messlauf: Breite der Linie zählen (tusche_breite.py)
		tm.set_shader_parameter("ink", Color(1, 0, 1))
	q.material_override = tm
	q.position = Vector3(0, 0, -1)
	q.name = "Tusche"
	c.add_child(q)
	return tm


static func schablone(sh: Shader, n: int) -> Shader:
	var s := Shader.new()
	s.code = sh.code.replace("stencil_mode read, compare_equal, 0;", "stencil_mode read, compare_equal, %d;" % n)
	return s


## Tusche nach Licht wie im Kampfort: Welt (Schablone 0), Gruppe mit Waffen (2), Gegner (3, Runde 7: wie der Held).
static func tusche_licht(c: Camera3D) -> Array[ShaderMaterial]:
	var tu: Shader = load("res://kampf/tusche_licht.gdshader")
	var out: Array[ShaderMaterial] = []
	out.append(quad(c, tu, 1.3, 1.7))     # 348.13a (Chef 27.10., 09:41): Schattenseite im Kampf kräftiger als im Dorf
	out.append(quad(c, schablone(tu, 2), 0.8, 1.5))
	out.append(quad(c, schablone(tu, 3), 0.8, 1.5))
	# Probe TUSCHE_DICK=<Faktor auf den Umriss>; Chef 28.10., 08:09 (r9 ja): 1,3
	var k := float(OS.get_environment("TUSCHE_DICK")) if OS.has_environment("TUSCHE_DICK") else 1.3
	for m in out:
		m.set_shader_parameter("umriss_dick", k)
	return out


## Bildbreite in Metern in der Tiefe [d] vor der Kamera (Kamera hält die Höhe, KEEP_HEIGHT).
static func breite(c: Camera3D, d: float, vs: Vector2) -> float:
	var asp := vs.x / maxf(vs.y, 1.0)
	match c.projection:
		Camera3D.PROJECTION_ORTHOGONAL:
			return c.size * asp
		Camera3D.PROJECTION_FRUSTUM:
			return c.size / c.near * d * asp
	return 2.0 * d * tan(deg_to_rad(c.fov / 2.0)) * asp


## Je Bild: Licht, Bildbreite und Tiefe der breiten Linie nach der Kamera, die gerade zeichnet, und dem Ziel in ihr. Im
## Kampfort ist das Ziel die Kampfmitte: gleiche Werte wie vorher (Tiefe d0, Breite aus base_size); Proben, die die Kamera
## umsetzen (SCHAU=dreh, NAH, Film 438a), bekommen so die Linie, die das Spiel in dieser Nähe zeichnen würde.
static func nachfuehren(ms: Array[ShaderMaterial], c: Camera3D, sun: DirectionalLight3D, wo: Vector3, vs: Vector2, offen := false) -> void:
	if ms.is_empty() or c == null or sun == null:
		return
	var d := maxf(-(c.global_transform.affine_inverse() * wo).z, 0.1)
	var bm := breite(c, d, vs)
	for m in ms:
		m.set_shader_parameter("licht_dir", sun.global_transform.basis.z)
		m.set_shader_parameter("breite_m", bm)
		m.set_shader_parameter("nah_bis", d + 5.0)     # 348.13a: breite Linie nur auf der Lichtung (Helfer: Kronen oben als dicker Ast)
		m.set_shader_parameter("nah_ab", d - 6.0)
		if offen:     # freie Bühne: keine Lichtung, kein Boden; breite Linie in jeder Höhe
			m.set_shader_parameter("hoch_bis", 1000.0)
			m.set_shader_parameter("fuss_bis", -1000.0)
	for i in range(1, ms.size()):     # Held und (Runde 7) Gegner gleich
		ms[i].set_shader_parameter("hinten_ab", lerpf(0.05, 0.25, clampf((bm - 3.4) / (9.0 - 3.4), 0.0, 1.0)))


## Eigene Bühne mit Signatur: Sonne wie im Kampf (vorhandene wird angepasst), Tonwerte wie im Kampf, Tusche an [c].
## [wo]: Mitte des Bildinhalts; [offen]: Dinge schweben (kein Boden). Gibt den Knoten zurück, der je Bild nachführt.
static func einrichten(welt: Node3D, c: Camera3D, wo: Vector3, env: Environment = null, sun: DirectionalLight3D = null, offen := false) -> Node:
	var s = load("res://kampf/signatur.gd").new()
	s.name = "Signatur"
	s.cam = c
	s.ziel = wo
	s.frei = offen
	if env != null:
		env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		env.adjustment_enabled = true
		env.adjustment_saturation = 0.8
		env.adjustment_contrast = 1.06
	if sun == null:
		sun = DirectionalLight3D.new()
		welt.add_child(sun)
	sonne_wie_kampf(sun, true)
	s.sonne = sun
	if aus():
		print("OHNE SIGNATUR (Schalter OHNE_SIGNATUR=1): keine Tusche, kein Schatten; Vorlage nur mit „Chef erlaubt ohne Signatur“ (457)")
	else:
		s.mats = tusche_licht(c)
	welt.add_child(s)
	return s


func _process(_dt: float) -> void:
	nachfuehren(mats, cam, sonne, ziel, get_viewport().get_visible_rect().size, frei)


## Was der Signatur in [wurzel] fehlt ("" = alles da): sichtbare Netze ohne Toon (beleuchtetes StandardMaterial3D),
## keine Tusche, keine Sonne mit Schatten. Unbeleuchtete Stoffe (Flammen, Masken, Schatten unter den Pfoten) zählen nicht.
static func pruefen(wurzel: Node) -> String:
	var fehlt: Array[String] = []
	var ohne_toon: Array[String] = []
	var toon := 0
	for n in wurzel.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if not mi.is_visible_in_tree() or mi.mesh == null or mi.name == "Tusche":
			continue
		for i in mi.mesh.get_surface_count():
			var m: Material = mi.material_override
			if m == null:
				m = mi.get_surface_override_material(i)
			if m == null:
				m = mi.mesh.surface_get_material(i)
			if m is ShaderMaterial:
				toon += 1
			elif m == null or (m is BaseMaterial3D and (m as BaseMaterial3D).shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED):
				if ohne_toon.size() < 5:
					ohne_toon.append(String(wurzel.get_path_to(mi)))
	if not ohne_toon.is_empty():
		fehlt.append("ohne Toon: " + ", ".join(ohne_toon))
	if toon == 0:
		fehlt.append("kein Netz mit Toon")
	var tusche := false
	for n in wurzel.find_children("Tusche", "MeshInstance3D", true, false):
		var tm = (n as MeshInstance3D).material_override
		if tm is ShaderMaterial and (tm as ShaderMaterial).shader != null and (tm as ShaderMaterial).shader.code.contains("licht_dir"):
			tusche = true
	if not tusche:
		fehlt.append("keine Tusche nach Licht")
	var schatten := false
	for n in wurzel.find_children("*", "DirectionalLight3D", true, false):
		if (n as DirectionalLight3D).shadow_enabled and (n as DirectionalLight3D).is_visible_in_tree():
			schatten = true
	if not schatten:
		fehlt.append("keine Sonne mit Schatten")
	return "; ".join(fehlt)


## Vor dem ersten Bild einer Probe: fehlt etwas an der Signatur und steht kein OHNE_SIGNATUR=1, Abbruch mit Exit 3.
## Gibt true zurück, wenn gezeichnet werden darf.
static func wache(wurzel: Node, tree: SceneTree, was: String) -> bool:
	if schalter() != "":
		print("Signatur %s: OHNE (Schalter %s); Vorlage nur mit „Chef erlaubt ohne Signatur“ (457)" % [was, schalter()])
		return true
	var f := pruefen(wurzel)
	if f == "":
		print("Signatur %s: Toon, Tusche nach Licht, Schatten" % was)
		return true
	printerr("FEHLER Signatur %s: %s. Probe ohne Signatur nur mit OHNE_SIGNATUR=1 (457)" % [was, f])
	tree.quit(3)
	return false
