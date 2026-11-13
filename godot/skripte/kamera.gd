class_name Kamera
extends Camera3D
# 348.6: schraeger Blick von oben (30 Grad), rechtwinklig wie das alte Spiel; drehen in 45-Grad-Schritten oder mit zwei
# Fingern, Fern (Gebietskarte, etwa sechs Kacheln quer) und Nah (Gesicht, Haende); Tusche als Bildschirmflaeche davor.

const FERN := 9.0                      # Bildbreite in Metern
const NAH := 3.4
const NORD := 45.0                     # Grundansicht wie alt, Blick nach Nordwesten (Chefrunde 25.10., 13:26, 3486 a: Tueren und Fronten zum Betrachter); Windrose: Tippen dreht dorthin zurueck

var ziel: Node3D
var gieren := NORD
var gieren_ziel := NORD
var zoom := FERN
var fern := FERN                       # 399.1 Bedienung „Karte“: Normal oder Näher (MapZoom 6,75 oder 5,6 Kacheln quer)
var nah := false
static var test_kacheln := 0.0          # 555: 0 = wie unter Bedienung „Karte“
var tusche: MeshInstance3D
var tusche_mats: Array[ShaderMaterial] = []   # 348.13: bekommen die Sonnenrichtung (Tusche nach der Lichtrichtung)
var neigung := -30.0     # 376.1 Kopfblatt (figurenprobe.gd): flacher auf Gesichtshoehe
var hinten_fest := -1.0   # 348.13: --hintenheld=<m> haelt die Stufe am Helden fest (Versuch), sonst mit dem Zoom
# 348.13b (Chef 28.10., 08:09): Tusche auch nach Laterne, Fenster, Fackel; Knoten der Gruppe „tuschelicht“ (Meta reich, kraft),
# die naechsten zum Helden gehen an den Shader; nacht von spiel._nacht; --tuschelampen=0 schaltet es ab (Vergleich, Kosten)
const TUSCHE_LAMPEN := 8              # wie LAMPEN in tusche.gdshader
var nacht := 0.0
var lampen_an := true

func _ready() -> void:
	name = "Kamera"
	projection = PROJECTION_ORTHOGONAL
	keep_aspect = KEEP_WIDTH
	fern_neu()
	size = zoom
	near = 0.5
	far = 120.0
	# Tusche: Bildschirmflaechen davor, Welt (Schablone 0) und Held (Schablone 2, feiner; Probe Build 12)
	var tu: Shader = load("res://shader/tusche.gdshader")
	var tu_held := Shader.new()
	tu_held.code = tu.code.replace("stencil_mode read, compare_equal, 0;", "stencil_mode read, compare_equal, 2;")
	# 348.13: Schattenseite kraeftiger als bisher (1,25), Lichtseite duenn (duenn im Shader); --tuschealt: wie vorher, nur nach Helligkeit
	var alt := "--tuschealt" in OS.get_cmdline_user_args()
	tusche = tusche_flaeche(tu, 1.3, 1.25 if alt else 1.7)
	tusche_flaeche(tu_held, 0.8, 1.0 if alt else 1.5)
	for m in tusche_mats: m.set_shader_parameter("richtung", 0.0 if alt else 1.0)
	if "--umrissblass" in OS.get_cmdline_user_args():   # 348.13: Vergleich mit Lauf 100
		for m in tusche_mats: m.set_shader_parameter("umriss_licht", 0.0)
	if "--zoomdick0" in OS.get_cmdline_user_args():   # 348.13: Verdoppelung im Schatten bei jedem Zoom wie 832ad3959
		for m in tusche_mats: m.set_shader_parameter("zoomdick", 0.0)
	for a in OS.get_cmdline_user_args():   # 348.13 Versuch: Stufe, ab der die hintere Seite am Helden frei bleibt
		if a.begins_with("--hintenheld="): hinten_fest = float(a.substr(13))
	if "--tuscheaussen" in OS.get_cmdline_user_args():   # 348.13: Umriss beidseits der Kante wie d08456e7d
		for m in tusche_mats: m.set_shader_parameter("innen", 0.0)
	if "--tuschelampen=0" in OS.get_cmdline_user_args(): lampen_an = false

func _process(_d: float) -> void:
	for m in tusche_mats:
		m.set_shader_parameter("licht_dir", Licht.richtung())
		m.set_shader_parameter("breite_m", size)
	tusche_mats[1].set_shader_parameter("hinten_ab", hinten_fest if hinten_fest >= 0.0 else hinten_held(size))
	tusche_lampen()

func tusche_lampen() -> void:
	var pos := PackedVector4Array()
	var kraft := PackedFloat32Array()
	if lampen_an and nacht > 0.02:
		var mitte := ziel.global_position if ziel else global_position
		var l := []
		for n in get_tree().get_nodes_in_group("tuschelicht"):
			var o := n as Node3D
			if o.is_visible_in_tree(): l.append([o.global_position.distance_squared_to(mitte), o])
		l.sort_custom(func(a, b): return a[0] < b[0])
		for e in l.slice(0, TUSCHE_LAMPEN):
			var o: Node3D = e[1]
			var p := o.global_position
			pos.append(Vector4(p.x, p.y, p.z, float(o.get_meta("reich", 3.0))))
			kraft.append(float(o.get_meta("kraft", 1.0)))
	var n := pos.size()
	while pos.size() < TUSCHE_LAMPEN:
		pos.append(Vector4(0, -100, 0, 1))
		kraft.append(0.0)
	for m in tusche_mats:
		m.set_shader_parameter("lampen", pos)
		m.set_shader_parameter("lampen_kraft", kraft)
		m.set_shader_parameter("lampen_n", n)
		m.set_shader_parameter("nacht", nacht)

# 348.13: Helfer nah (8d879cbf4): schwarzer Klumpen an der Schwerthand; die Hand liegt keine 0,25 m vor dem Koerper, darum Tusche
# beidseits der Kante. 0,05 m nah blind 8:1 besser, in der Grundansicht 6:0 schlechter (Beine und Stiefel verschwinden im Boden):
# nah 0,05, ab der Grundansicht 0,25, dazwischen gleitend
func hinten_held(s: float) -> float: return lerpf(0.05, 0.25, clampf((s - NAH) / (FERN - NAH), 0.0, 1.0))

func tusche_flaeche(sh: Shader, breite: float, dick: float) -> MeshInstance3D:
	var q := MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(2, 2)
	q.mesh = qm
	q.extra_cull_margin = 16384.0
	q.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := ShaderMaterial.new()
	m.shader = sh
	# zuletzt, auch nach der Flamme (held.gd, 100), die sich mit Schablone 1 ausnimmt; 126, weil der Nebel (nebel.gd, 127) danach
	# kommen muss (505 Prüfer Lauf 2: die Linie am Teichufer lag über dem schwarzen Nebel)
	m.render_priority = 126
	m.set_shader_parameter("px", breite)
	m.set_shader_parameter("dick", dick)
	tusche_mats.append(m)
	q.material_override = m
	q.position = Vector3(0, 0, -1)
	add_child(q)
	if "--ohnetusche" in OS.get_cmdline_user_args(): q.visible = false
	return q

func drehe(grad: float) -> void: gieren_ziel += grad

# auf die naechste Standardansicht, ohne ganze Umdrehungen nachzuholen
func nach_norden() -> void: gieren_ziel = NORD + roundf((gieren_ziel - NORD) / 360.0) * 360.0

# Norden (Karte oben, -z) auf dem Bildschirm, im Uhrzeigersinn von oben; flach wie eine Kartenrose, bei Gieren 0 oben
func nord_winkel() -> float: return deg_to_rad(gieren)

func nah_fern() -> void:
	nah = not nah
	zoom = NAH if nah else fern

func fern_neu() -> void:
	Bedienung.lade()
	var war := fern
	fern = FERN * (Bedienung.NAEHER if Bedienung.karte_nah else 1.0)
	if test_kacheln > 0.0: fern = test_kacheln * Karte.TS   # 555 Testmenue „Kartenzoom“ wie alt MapZoom.levels (Kacheln quer)
	if not nah and is_equal_approx(zoom, war): zoom = fern

# 1118 (Chef 13.11., 10:06, Test 282: „eine Mindeststufe festlegen“): mit zwei Fingern nur bis NAH, der Held bleibt von Kopf bis Fuss
# im Bild (vorher NAH * 0,8; naeher nur ueber den Reiter „Test“, test_kacheln)
func kneifen(faktor: float) -> void:
	zoom = clampf(zoom * faktor, NAH, FERN * 1.6)
	nah = zoom < (NAH + FERN) * 0.5

# 615 (Chef 07.11., t268: „Kamerabewegungen (Zoom/Drehung) um den Avatar als Fixpunkt. Bisher läuft die Kamera gerne aus dem Bild“):
# weich folgt nur der Blickpunkt am Helden; die Kamera steht immer genau 40 m vor ihm auf der Blickachse, so dreht und zoomt sie um
# ihn (vorher folgte die Lage der schon gedrehten Achse nach, der Held lief beim Drehen bis zwei Bildbreiten aus der Mitte; kamera_615)
var blickpunkt := Vector3.INF

func folge(k: float) -> void:
	if ziel == null: return
	gieren = lerpf(gieren, gieren_ziel, minf(1.0, k * 1.6))
	rotation_degrees = Vector3(neigung, gieren, 0)
	var auf := ziel.position + Vector3(0, 0.9 if nah else 0.0, 0)
	size = lerpf(size, zoom, k)
	if rand_weit > 0.0: auf = am_rand(auf)   # 505c Kartenrand
	blickpunkt = auf if blickpunkt == Vector3.INF else blickpunkt.lerp(auf, k)   # 615 um den Helden
	position = blickpunkt + global_basis.z * 40.0

# ---------------------------------------------------------------- 505c (3) Kartenrand (Chef 04.11., 14:01: „den Zoom … mitsteuern, dass halt
# dann nicht ewig weit rausgeguckt werden kann, wo nichts ist“; Zu 505 (Rand)): was die Kamera am Boden sieht, bleibt in der Karte samt
# Randwald (rand_weit Meter, dort ist es dann schwarz, nebel.gdshader); der Held bleibt im Bild (RAND_HELD vom Bildrand). Geht beides
# nicht (Ecke der Karte, schraeger Blick), wird der Ausschnitt kleiner. Grundriss: rand_weit 0, wie bisher.
var rand_karte := Rect2()             # Karte in Metern (x, z)
var rand_weit := 0.0                  # Randwald in Metern
const RAND_HELD := 1.4                # Held mindestens so weit (m, Bildmass) vom Bildrand
var rand_klein := false               # zuletzt verkleinert (Test, Bildlauf)

func rand(karte_m: Rect2, weit: float) -> void:
	rand_karte = karte_m
	rand_weit = weit

## Blickpunkt (auf, Hoehe bleibt) so verschoben und size so verkleinert, dass der Ausschnitt am Boden im Rand bleibt
func am_rand(auf: Vector3) -> Vector3:
	var th := deg_to_rad(-neigung)
	if th < 0.2: return auf          # flach (Probeblaetter): kein Boden-Ausschnitt
	var r := Vector2(global_basis.x.x, global_basis.x.z).normalized()
	var f := Vector2(-global_basis.z.x, -global_basis.z.z).normalized()
	var g0 := Vector2(auf.x, auf.z) + f * (auf.y / tan(th))   # Bildmitte am Boden
	var held := Vector2(ziel.position.x, ziel.position.z)
	var s := size
	var g = ausschnitt(g0, held, s, r, f, th)
	rand_klein = false
	if g == null:
		var lo := s * 0.3; var hi := s
		for i in 14:
			var mid := (lo + hi) * 0.5
			if ausschnitt(g0, held, mid, r, f, th) == null: hi = mid
			else: lo = mid
		s = lo
		size = s
		rand_klein = true
		g = ausschnitt(g0, held, s, r, f, th)
		if g == null: return auf
	var d: Vector2 = g - g0
	return auf + Vector3(d.x, 0, d.y)

## halbe Masse des Ausschnitts am Boden: quer (Bildbreite) und laengs (Bildhoehe / sin Neigung)
func ausschnitt_halb(s: float, th: float) -> Vector2:
	var vp := get_viewport().get_visible_rect().size if is_inside_tree() else Vector2(540, 1170)
	var asp := vp.y / maxf(vp.x, 1.0)
	return Vector2(s * 0.5, s * asp * 0.5 / sin(th))

## naechster Punkt zu g0, an dem der Ausschnitt (Groesse s) ganz in Karte samt Rand liegt und der Held im Bild ist; sonst null
func ausschnitt(g0: Vector2, held: Vector2, s: float, r: Vector2, f: Vector2, th: float) -> Variant:
	var h := ausschnitt_halb(s, th)
	var ex := absf(r.x) * h.x + absf(f.x) * h.y
	var ez := absf(r.y) * h.x + absf(f.y) * h.y
	var lo := rand_karte.position - Vector2(rand_weit, rand_weit) + Vector2(ex, ez)
	var hi := rand_karte.end + Vector2(rand_weit, rand_weit) - Vector2(ex, ez)
	if lo.x > hi.x or lo.y > hi.y: return null
	# der Held im Bild: Mitte in einem gedrehten Rechteck um ihn (quer h.x, laengs h.y, je abzueglich RAND_HELD)
	var qa := h.x - RAND_HELD; var qb := h.y - RAND_HELD / sin(th)
	if qa <= 0.0 or qb <= 0.0: return null
	var poly := PackedVector2Array([held + r * qa + f * qb, held - r * qa + f * qb, held - r * qa - f * qb, held + r * qa - f * qb])
	if lo.is_equal_approx(hi): return lo if poly_hat(poly, lo) else null
	var schnitt := Geometry2D.intersect_polygons(poly, PackedVector2Array([lo, Vector2(hi.x, lo.y), hi, Vector2(lo.x, hi.y)]))
	if schnitt.is_empty() or (schnitt[0] as PackedVector2Array).size() < 3: return null
	poly = schnitt[0]
	if Geometry2D.is_point_in_polygon(g0, poly): return g0
	var best := poly[0]; var bd := INF
	for i in poly.size():
		var q := Geometry2D.get_closest_point_to_segment(g0, poly[i], poly[(i + 1) % poly.size()])
		var dd := q.distance_squared_to(g0)
		if dd < bd: bd = dd; best = q
	return best

func poly_hat(poly: PackedVector2Array, p: Vector2) -> bool: return Geometry2D.is_point_in_polygon(p, poly)

func springe() -> void:
	gieren = gieren_ziel
	blickpunkt = Vector3.INF
	folge(1.0)

# Punkt am Boden unter einem Bildschirmpunkt
func boden(sp: Vector2) -> Variant:
	var o := project_ray_origin(sp)
	var n := project_ray_normal(sp)
	if absf(n.y) < 1e-4: return null
	return o + n * (-o.y / n.y)

# Joystick (Bildschirm) -> Richtung am Boden
func richtung(v: Vector2) -> Vector3:
	var r := global_basis.x; r.y = 0
	var f := -global_basis.z; f.y = 0
	var d := r.normalized() * v.x - f.normalized() * v.y
	return d.normalized() * minf(1.0, d.length()) if d.length() > 0.0 else d
