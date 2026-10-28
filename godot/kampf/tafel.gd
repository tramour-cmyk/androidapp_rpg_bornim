extends RefCounted
## 348.7a (Chef 27.10., 09:38, „3D, Effekte als Tafeln behalten“): Pinsel für zauber.gd. Zeichnet wie ein CanvasItem
## (draw_circle, draw_polygon, draw_line …) in Bildpunkten, aber als Tafel in der 3D-Szene: jede Form liegt zur Kamera gedreht
## in der Tiefe [depth] (Meter vor der Kamera), so verdecken Figuren davor sie von selbst. Am Boden sinkt nichts ein:
## tafel.gdshader holt jede Ecke vor den Boden unter ihr. Die Ecken tragen (x, y, Tiefe); der Shader rechnet sie in den Raum.

var mesh := ImmediateMesh.new()
var node := MeshInstance3D.new()
var mat := ShaderMaterial.new()
var cam: Camera3D
var size := Vector2(1080, 2340)
## Tiefe der nächsten Formen (zauber.gd setzt sie je Bahnpunkt oder Einschlag)
var depth := 10.0
## Ecken dieses Bilds (Leistung, Log „Tafeln“)
var verts := 0
var _open := false


func _init(world: Node3D, p_cam: Camera3D) -> void:
	cam = p_cam
	mat.shader = load("res://kampf/tafel.gdshader")
	mat.render_priority = 10     # nach der Tusche (sonst lägen die Umrisse über dem Feuer)
	node.mesh = mesh
	node.material_override = mat
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.custom_aabb = AABB(Vector3(-1e4, -1e4, -1e4), Vector3(2e4, 2e4, 2e4))     # Ecken in Bildpunkten: nie wegschneiden
	world.add_child(node)


## Neues Bild: alte Formen weg, Strahlen der Kamera für den Shader (ein Bildpunkt (x, y) liegt in der Sicht auf r0 + x·rx + y·ry,
## Tiefe 1); so stimmt es auch beim Heranzoomen des Schlags (Linse) und auf jedem Renderer. Aus unproject_position gerechnet:
## project_position übergeht bei der verschobenen Linse (frustum_offset) die Höhe (Probe: 200 px kamen bei −52 px an).
var r0 := Vector3(0, 0, -1)
var rx := Vector3.ZERO
var ry := Vector3.ZERO

func begin(p_size: Vector2) -> void:
	mesh.clear_surfaces()
	_open = false
	verts = 0
	size = p_size
	var t := cam.global_transform
	var s0 := cam.unproject_position(t * Vector3(0, 0, -1))
	var sx := cam.unproject_position(t * Vector3(1, 0, -1)) - s0
	var sy := cam.unproject_position(t * Vector3(0, 1, -1)) - s0
	var det := sx.x * sy.y - sx.y * sy.x
	if absf(det) < 1e-6:
		return
	# Bildpunkt q = s0 + x·sx + y·sy  ⇒  (x, y) aus der Umkehrung
	rx = Vector3(sy.y / det, -sx.y / det, 0.0)
	ry = Vector3(-sy.x / det, sx.x / det, 0.0)
	r0 = Vector3(0, 0, -1) - rx * s0.x - ry * s0.y
	mat.set_shader_parameter("r0", r0)
	mat.set_shader_parameter("rx", rx)
	mat.set_shader_parameter("ry", ry)
	if OS.get_environment("TAFEL_PRUEF") != "":
		for q in [Vector2(100, 200), Vector2(800, 1500)]:
			print("Tafel-Prüfung ", q, " -> ", cam.unproject_position(world_at(q, 12.0)))


## Punkt im Raum am Bildpunkt q in der Tiefe d (m vor der Kamera)
func world_at(q: Vector2, d: float) -> Vector3:
	return cam.global_transform * ((r0 + rx * q.x + ry * q.y) * d)


func end() -> void:
	if _open:
		mesh.surface_end()
		_open = false


func get_viewport_rect() -> Rect2:
	return Rect2(Vector2.ZERO, size)


func _v(p: Vector2, c: Color, uv := Vector2.ZERO, soft := 0.0, mid := -1.0) -> void:
	if not _open:
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		_open = true
	mesh.surface_set_color(c)
	mesh.surface_set_uv(uv)
	mesh.surface_set_uv2(Vector2(soft, mid))
	mesh.surface_add_vertex(Vector3(p.x, p.y, depth))
	verts += 1


## Weicher Kreis mit einer Farbe, die nach außen vergeht: eine Tafel, den Verlauf rechnet der Shader (die meisten Glut-, Rauch-
## und Funkenpunkte); mid: Deckkraft auf halbem Radius im Verhältnis zur Mitte (drei Stufen derselben Farbe, Flammenballen)
func soft_disc(at: Vector2, r: float, c: Color, sy := 1.0, mid := -1.0) -> void:
	if c.a <= 0.003:
		return
	var a := at + Vector2(-r, -r * sy)
	var b := at + Vector2(r, -r * sy)
	var d := at + Vector2(-r, r * sy)
	var e := at + Vector2(r, r * sy)
	_v(a, c, Vector2(-1, -1), 1.0, mid); _v(b, c, Vector2(1, -1), 1.0, mid); _v(e, c, Vector2(1, 1), 1.0, mid)
	_v(a, c, Vector2(-1, -1), 1.0, mid); _v(e, c, Vector2(1, 1), 1.0, mid); _v(d, c, Vector2(-1, 1), 1.0, mid)


func draw_circle(at: Vector2, r: float, c: Color, _filled := true, _w := -1.0, _aa := false) -> void:
	if c.a <= 0.003 or r <= 0.1:
		return
	var n := 10 if r < 6.0 else (14 if r < 20.0 else 20)
	var prev := at + Vector2(r, 0)
	for k in range(1, n + 1):
		var q := at + Vector2(cos(TAU * k / n), sin(TAU * k / n)) * r
		_v(at, c); _v(prev, c); _v(q, c)
		prev = q


func draw_polygon(pts: PackedVector2Array, cols: PackedColorArray, _uvs := PackedVector2Array(), _tex = null) -> void:
	var n := pts.size()
	if n < 3:
		return
	var one := cols.size() == 1
	if n == 3 or n == 4:
		for i in range(1, n - 1):
			_v(pts[0], cols[0]); _v(pts[i], cols[0 if one else i]); _v(pts[i + 1], cols[0 if one else i + 1])
		return
	var tri := Geometry2D.triangulate_polygon(pts)
	if tri.is_empty():
		for i in range(1, n - 1):
			tri.append_array([0, i, i + 1])
	for i in tri:
		_v(pts[i], cols[0 if one else i])


func draw_colored_polygon(pts: PackedVector2Array, c: Color, _uvs := PackedVector2Array(), _tex = null) -> void:
	draw_polygon(pts, PackedColorArray([c]))


## Linie mit weicher Kante (wie antialiased im CanvasItem): Kern voll, je Seite ein Bildpunkt Auslauf
func draw_line(a: Vector2, b: Vector2, c: Color, w := 1.0, _aa := false) -> void:
	if c.a <= 0.003 or a.distance_to(b) < 0.01:
		return
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x)
	var h := maxf(w * 0.5 - 0.5, 0.0)
	var f := h + 1.0
	var c0 := Color(c, 0.0)
	_quad(a + n * h, b + n * h, b - n * h, a - n * h, c, c, c, c)
	_quad(a + n * f, b + n * f, b + n * h, a + n * h, c0, c0, c, c)
	_quad(a - n * h, b - n * h, b - n * f, a - n * f, c, c, c0, c0)


func _quad(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, c0: Color, c1: Color, c2: Color, c3: Color) -> void:
	_v(p0, c0); _v(p1, c1); _v(p2, c2)
	_v(p0, c0); _v(p2, c2); _v(p3, c3)
