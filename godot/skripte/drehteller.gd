class_name Drehteller
extends SubViewportContainer
# 399.1 HeroTurntable wie alt (HeroDollUi.kt): der Held (daten/held.bin) dreht sich langsam, eine Drehung in etwa sechs Sekunden;
# Tippen dreht ihn eine Viertelrunde weiter. Fuer Erschaffung und Menue (Held). Ohne Modell (Probe am Rechner) bleibt der Platz leer.
# 376.1: der Held seiner Klasse mit Aussehen und Ausruestung (HeldFigur.wahl), in der Erschaffung bei jeder Wahl neu (zeige)

const DP := AktionsKnopf.DP
const HELD := "res://daten/held.bin"
var teller: Node3D
var sonne: DirectionalLight3D
var wahl := {}
const HOEHE := 1.8            # Meter: jede Figur so hoch im Teller
const RAND := 1.14            # Bildhoehe zu Figurhoehe (oben und unten 7 %)

# gross: Kastengroesse (Menue 0,62 wie alt); Erschaffung groesser (Pruefer 376.1 Lauf 2: Held zu klein fuer Gesicht und Bart)
func _init(w: Dictionary = {}, gross := 0.62) -> void:
	wahl = w
	stretch = true
	custom_minimum_size = Vector2(150, 230) * gross * DP
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if not FileAccess.file_exists(HELD): return
	var v := SubViewport.new()
	v.own_world_3d = true
	v.transparent_bg = true
	v.msaa_3d = Viewport.MSAA_4X
	add_child(v)
	var welt := WorldEnvironment.new()
	welt.environment = Environment.new()
	welt.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	welt.environment.ambient_light_color = Color(0.55, 0.5, 0.45)
	v.add_child(welt)
	sonne = DirectionalLight3D.new()   # warm von vorn oben links wie der Lichtkegel des Hauptmenues
	sonne.light_color = Color(1.0, 0.92, 0.8)
	sonne.rotation_degrees = Vector3(-40, -30, 0)
	v.add_child(sonne)
	var kam := Camera3D.new()
	# Chef 29.10., 11:10 (Archiv „399.1, Menü Ausrüstung“): der Held nie oben oder unten abgeschnitten, immer gleich gross wie alt
	# (HeroDollUi): ganz im Bild, waagrecht von vorn; zeige() bringt jede Figur auf HOEHE (Halbling wie Mensch)
	kam.fov = 26.0
	kam.position = Vector3(0, HOEHE / 2.0, HOEHE * RAND / 2.0 / tan(deg_to_rad(kam.fov) / 2.0))
	v.add_child(kam)
	teller = Node3D.new()
	v.add_child(teller)
	zeige(wahl)

func zeige(w: Dictionary) -> void:
	wahl = w
	if teller == null: return
	for c in teller.get_children(): c.free()
	var mats := []
	var modell: Node3D = HeldFigur.baue(w, mats) if not w.is_empty() else null
	if modell == null:
		modell = Gebiet.lade_glb(HELD)
		if modell == null: return
		Gebiet.male(modell, null, 2, mats)
	teller.add_child(modell)
	var box := huelle(modell, Transform3D.IDENTITY)
	if box.size.y > 0.01:   # auf HOEHE, Fuesse auf 0, Mitte auf der Drehachse
		var s := HOEHE / box.size.y
		modell.scale = Vector3.ONE * s
		modell.position = Vector3(-box.get_center().x * s, -box.position.y * s, -box.get_center().z * s)
	for m in mats:
		(m as ShaderMaterial).set_shader_parameter("metall", 1.0)
		(m as ShaderMaterial).set_shader_parameter("licht_dir", Basis.from_euler(sonne.rotation).z)   # zur Sonne wie Licht.richtung
	var anim := Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	if anim:
		Gebiet.bewegungen(anim, ["Stehen"])
		if anim.has_animation("Stehen"): anim.play("Stehen")

# Umriss aller Netze im Raum von n (Ruhehaltung)
func huelle(n: Node, t: Transform3D) -> AABB:
	var box := AABB()
	var leer := true
	var tt := t * (n as Node3D).transform if n is Node3D else t
	if n is MeshInstance3D and (n as MeshInstance3D).mesh:
		box = tt * (n as MeshInstance3D).get_aabb(); leer = false
	for c in n.get_children():
		var b := huelle(c, tt)
		if b.size.length() > 0.0:
			box = b if leer else box.merge(b); leer = false
	return box

func _process(dt: float) -> void:
	if teller: teller.rotation.y += dt * TAU / 6.0

func _gui_input(e: InputEvent) -> void:
	if teller and e is InputEventMouseButton and e.pressed: teller.rotation.y += TAU / 4.0
