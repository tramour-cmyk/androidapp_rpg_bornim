extends Node3D
# Probefilme aus der Bibliothek (408: Bestand vor Eigenbau, „am besten natürlich in einem Film, weil dann sehe ich auch, wenn es sich
# dreht, wie es aus allen Perspektiven ausschaut“). Läuft im Ablauf tom-probe.yml mit --write-movie; gekaufte Dateien bleiben auf dem
# Runner, ins Artefakt geht nur der Film (348.12c a).
#   --film=431   Grundkörper, Haare und Bärte der Bibliothek drehend, mit den Größen der Völker (LISTE-FIGUREN.md „Völker“, 430)
#   --film=416.4 Rennen: Jog_Fwd wie im Spiel, Jog mit halbem Beckenhub, Sprint; von der Seite und aus der Spielansicht
# Umgebung: KAUF=<gekaufte Pakete>, CC0=<freie Quaternius-Pakete> (cc0_laden.sh). Ende von selbst; Zeilen „FILM …“ ins Protokoll.

const B := preload("res://probe/bibliothek.gd")
const GOLD := Color(0.83, 0.68, 0.36)
const VOELKER := [["Hügelvolk", 1.05], ["Zwerg", 1.35], ["Elf", 1.72], ["Orkblütiger", 1.85]]
const RENN := 3.68 * 1.16     # held.gd: Rennen 3,68 Kacheln je Sekunde (wie tests/rennen_4164.gd)

var kauf := OS.get_environment("KAUF")
var cc0 := OS.get_environment("CC0")
var kamera := Camera3D.new()
var ebene := CanvasLayer.new()
var schrift := FontFile.new()
var titel := Label.new()
var schilder := []            # [Label, Node3D, Höhe über dem Knoten]
var ual: Node3D
var ual_ap: AnimationPlayer
var zeit := 0.0
var ablauf := []              # [bis Sekunde, Callable]


func _ready() -> void:
	schrift.load_dynamic_font("res://kampf/schrift/alegreya_regular.ttf")
	var welt := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.045, 0.04)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.5, 0.45)
	env.ambient_light_energy = 0.6
	welt.environment = env
	add_child(welt)
	var sonne := DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-40, -35, 0)
	sonne.light_color = Color(1.0, 0.92, 0.8)
	sonne.shadow_enabled = true
	add_child(sonne)
	add_child(kamera)
	add_child(ebene)
	titel.position = Vector2(24, 14)
	_stil(titel, 30)
	ebene.add_child(titel)
	var ual_pfad := _erste(B.dateien([cc0, kauf], ".glb").filter(func(p): return p.get_file() == "UAL1_Standard.glb"))
	ual = B.lade(ual_pfad, "") if ual_pfad != "" else null
	if ual == null: print("FILM FEHLER: UAL1_Standard.glb fehlt unter CC0/KAUF"); get_tree().quit(1); return
	ual_ap = B.spieler(ual)
	ual.visible = false
	add_child(ual)    # der Spieler stellt das Gerüst nur im Baum (für _gedaempft)
	ablauf.append([1.0, _pruefe_bewegung])
	var film := ""
	for a in OS.get_cmdline_user_args(): if a.begins_with("--film="): film = a.substr(7)
	print("FILM ", film, " KAUF=", kauf != "", " UAL=", ual_pfad)
	match film:
		"431": _film_431()
		"416.4": _film_4164()
		_: print("FILM FEHLER: --film=431 oder --film=416.4"); get_tree().quit(1)


func _process(dt: float) -> void:
	zeit += dt
	ablauf.sort_custom(func(a, b): return a[0] < b[0])
	if _streifen and is_instance_valid(_streifen): _streifen.position.x = fposmod(_streifen.position.x - _tempo * dt, 1.0)
	while not ablauf.is_empty() and zeit >= ablauf[0][0]:
		var schritt: Array = ablauf.pop_front()
		(schritt[1] as Callable).call()
	for s in schilder.duplicate():
		var l: Label = s[0]
		if not is_instance_valid(s[1]) or not (s[1] as Node3D).is_inside_tree(): l.queue_free(); schilder.erase(s); continue
		var n: Node3D = s[1]
		var p: Vector3 = n.global_position + Vector3(0, s[2], 0)
		l.visible = n.is_visible_in_tree() and not kamera.is_position_behind(p)
		l.position = kamera.unproject_position(p) - Vector2(l.size.x / 2, 0)


# Probe nach 1 s: bewegt sich jede sichtbare Figur (Hand weg von der Ruhelage), sitzen die Haare am Gerüst der Figur
func _pruefe_bewegung() -> void:
	for sk in find_children("*", "Skeleton3D", true, false):
		var s := sk as Skeleton3D
		if not s.is_visible_in_tree(): continue
		var h := s.find_bone("hand_r")
		var weg := (s.get_bone_global_pose(h).origin - s.get_bone_global_rest(h).origin).length() if h >= 0 else -1.0
		var netze := s.get_children().filter(func(c): return c is MeshInstance3D).map(func(c): return "%s%s" % [c.name, "" if c.get_node_or_null(c.skeleton) == s else "(lose)"])
		print("FILM Bewegung %s: Hand %.0f cm von der Ruhelage; %s" % [s.get_parent().get_parent().name, weg * 100, ", ".join(PackedStringArray(netze))])


func _stil(l: Label, groesse: int, farbe := GOLD) -> void:
	l.add_theme_font_override("font", schrift)
	l.add_theme_font_size_override("font_size", groesse)
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)


func _schild(text: String, an: Node3D, hoehe: float, groesse := 20, farbe := Color(0.93, 0.9, 0.84)) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stil(l, groesse, farbe)
	ebene.add_child(l)
	schilder.append([l, an, hoehe])
	return l


func _erste(l: Array) -> String:
	return l[0] if not l.is_empty() else ""


func _boden(laenge := 12.0, breite := 3.0) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(laenge, breite)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.14, 0.12)
	mat.roughness = 1.0
	pm.material = mat
	m.mesh = pm
	add_child(m)
	return m


func _linie(von: Vector3, bis: Vector3, farbe: Color) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3((bis - von).length(), 0.008, 0.008)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = farbe
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bm.material = mat
	m.mesh = bm
	add_child(m)
	m.global_position = (von + bis) / 2
	return m


func _figur(pfad: String) -> Node3D:
	var f := B.lade(pfad, _paket(pfad))
	if f == null: print("FILM FEHLER laden ", pfad); return null
	add_child(f)
	return f


func _paket(pfad: String) -> String:   # Paketordner: drei über „…/Base Characters/<Export>/x.gltf“ bzw. „…/Hairstyles/…/…/x.gltf“
	var d := pfad.get_base_dir()
	while d.length() > 1 and not d.get_file().begins_with("Universal Base Characters"): d = d.get_base_dir()
	return d if d.length() > 1 else pfad.get_base_dir()


func _bewegt(f: Node3D, namen: Array) -> AnimationPlayer:
	var q := {}
	for n in namen: if ual_ap.has_animation(n): q[n] = ual_ap.get_animation(n)
	var ap := B.bewegung(f, q)
	if not namen.is_empty() and ap.has_animation(namen[0]): ap.play(namen[0])
	return ap


func _hoehe(f: Node3D) -> float:
	var h := 0.0
	for m in f.find_children("*", "MeshInstance3D", true, false):
		var a: AABB = (m as MeshInstance3D).get_aabb()
		h = maxf(h, a.end.y)
	return h


# Haar „Rigged to Head Bone“ (eigenes Gerüst, gleiche Knochen): Netz auf das Skelett der Figur umhängen, es folgt dann deren Kopf
func _haar(f: Node3D, pfad: String) -> void:
	var h := B.lade(pfad, _paket(pfad))
	if h == null: print("FILM FEHLER Haar ", pfad); return
	var sk := B.skelett(f)
	for m in h.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		mi.owner = null
		mi.get_parent().remove_child(mi)
		sk.add_child(mi)
		mi.skeleton = NodePath("..")
	h.free()


func _koerper_name(p: String) -> String:
	var n := p.get_file().get_basename().replace("_FullBody", "")
	return n.replace("_Male", " Mann").replace("_Female", " Frau").replace("Superhero", "Superheld").replace("Regular", "Regulär").replace("Teen", "Jugend")


# 431 ------------------------------------------------------------------------------------------------------------------------------
func _film_431() -> void:
	# Kauf (Source) enthält alles der freien Standardfassung: dann nur Kauf
	var koerper := _aus_einer(func(p): return p.get_file().ends_with("_FullBody.gltf") and "Godot" in p)
	koerper = _einmal(koerper)
	var reihen := ["Regular_Male", "Regular_Female", "Superhero_Male", "Superhero_Female", "Teen_Male", "Teen_Female"]
	koerper.sort_custom(func(a, b): return _rang(a, reihen) < _rang(b, reihen))
	var haare := _aus_einer(func(p): return "Rigged to Head Bone" in p and "Godot" in p and not "_Teen" in p.get_file())
	haare = _einmal(haare)
	print("FILM 431 Körper ", koerper.size(), ": ", ", ".join(PackedStringArray(koerper.map(func(p): return p.get_file()))))
	print("FILM 431 Haare ", haare.size(), ": ", ", ".join(PackedStringArray(haare.map(func(p): return p.get_file()))))
	if koerper.is_empty(): print("FILM FEHLER keine Grundkörper"); get_tree().quit(1); return
	var maenner := koerper.filter(func(p): return "_Male" in p.get_file())
	var frauen := koerper.filter(func(p): return "_Female" in p.get_file())
	# Teil 1: alle Grundkörper nebeneinander, drehend, Linien in Völkergröße (Frauen 7 % kleiner: eigene kurze Linie)
	var teil1 := Node3D.new()
	add_child(teil1)
	var n := koerper.size()
	var abst := 0.85
	var breite := (n - 1) * abst
	for i in n:
		var f := _figur(koerper[i])
		if f == null: continue
		f.reparent(teil1)
		f.position = Vector3(-breite / 2 + i * abst, 0, 0)
		_bewegt(f, ["Idle_Loop"])
		var h := _hoehe(f)
		_schild("%s\n%s m" % [_koerper_name(koerper[i]), ("%.2f" % h).replace(".", ",")], f, -0.16, 18)
		f.set_meta("dreh", 1.0 / 12.0)
		print("FILM 431 %s Höhe %.3f m" % [koerper[i].get_file(), h])
	var boden := _boden(breite + 3.0, 2.0)
	boden.reparent(teil1)
	for v in VOELKER:
		var l := _linie(Vector3(-breite / 2 - 0.9, v[1], -0.25), Vector3(breite / 2 + 0.5, v[1], -0.25), GOLD.darkened(0.25))
		l.reparent(teil1)
		var ziel := Node3D.new()
		teil1.add_child(ziel)
		ziel.position = Vector3(-breite / 2 - 1.15, v[1] - 0.07, -0.25)
		_schild("%s %d" % [v[0], int(round(v[1] * 100))], ziel, 0.0, 16, GOLD)
	kamera.position = Vector3(0, 1.0, 5.6)
	kamera.fov = 32
	kamera.look_at(Vector3(0, 0.95, 0))
	titel.text = "431 · Bibliothek: Grundkörper (Quaternius), Linien = Völkergröße Mann"
	# Teil 2: Haare und Bärte, je Seite sechs auf dem passenden Grundkörper (Regulär, sonst der erste), Köpfe nah
	var seiten := []
	var seite := []
	for p in haare:
		seite.append(p)
		if seite.size() == 6: seiten.append(seite); seite = []
	if not seite.is_empty(): seiten.append(seite)
	var t := 12.0
	ablauf.append([t, func(): teil1.visible = false])
	for s in seiten:
		ablauf.append([t, _seite_431.bind(s, maenner, frauen, koerper)])
		t += 6.0
	ablauf.append([13.0, _pruefe_bewegung])
	ablauf.append([t, func(): get_tree().quit()])


func _aus_einer(passt: Callable) -> Array:
	var l := B.dateien([kauf], ".gltf").filter(passt)
	return l if not l.is_empty() else B.dateien([cc0], ".gltf").filter(passt)


func _einmal(l: Array) -> Array:   # je Ordner und Dateiname einmal (Male/Female haben gleiche Namen)
	var gesehen := {}
	var aus := []
	for p in l:
		var k: String = p.get_base_dir().get_file() + "/" + p.get_file()
		if not gesehen.has(k): gesehen[k] = true; aus.append(p)
	return aus


func _rang(p: String, reihen: Array) -> int:
	for i in reihen.size(): if reihen[i] in p.get_file(): return i
	return 99


var _seite_knoten: Node3D

func _seite_431(s: Array, maenner: Array, frauen: Array, alle: Array) -> void:
	if _seite_knoten: _seite_knoten.queue_free()
	_seite_knoten = Node3D.new()
	add_child(_seite_knoten)
	var abst := 0.7
	var breite := (s.size() - 1) * abst
	for i in s.size():
		var p: String = s[i]
		var weib: bool = "/Female/" in p or "Female" in p.get_file() or p.get_file() in ["Hair_Long.gltf", "Hair_Bob.gltf", "Hair_Buns.gltf"]
		var auswahl: Array = (frauen if weib else maenner)
		var basis: String = _erste(auswahl.filter(func(q): return "Regular" in q.get_file()))
		if basis == "": basis = _erste(auswahl)
		if basis == "": basis = alle[0]
		var f := _figur(basis)
		if f == null: continue
		f.reparent(_seite_knoten)
		f.position = Vector3(-breite / 2 + i * abst, 0, 0)
		_haar(f, p)
		_bewegt(f, ["Idle_Loop"])
		f.set_meta("dreh", 1.0 / 6.0)
		_schild(p.get_file().get_basename().replace("_", " ") + ("\n(Frau)" if "/Female/" in p else ""), f, 1.15, 17)
	kamera.position = Vector3(0, 1.62, 2.9)
	kamera.fov = 34
	kamera.look_at(Vector3(0, 1.5, 0))
	titel.text = "431 · Bibliothek: Haare, Bärte, Brauen (Rigged to Head Bone)"


func _physics_process(dt: float) -> void:
	for f in get_children():
		_drehe(f, dt)


func _drehe(n: Node, dt: float) -> void:
	if n is Node3D and n.has_meta("dreh"): (n as Node3D).rotate_y(TAU * float(n.get_meta("dreh")) * dt)
	for c in n.get_children(): if not c is MeshInstance3D and not c is Skeleton3D: _drehe(c, dt)


# 416.4 ----------------------------------------------------------------------------------------------------------------------------
func _film_4164() -> void:
	var koerper := B.dateien([kauf, cc0], ".gltf").filter(func(p): return p.get_file() == "Regular_Male_FullBody.gltf" and "Godot" in p)
	if koerper.is_empty(): koerper = B.dateien([cc0, kauf], ".gltf").filter(func(p): return p.get_file() == "Superhero_Male_FullBody.gltf")
	if koerper.is_empty(): print("FILM FEHLER kein Grundkörper"); get_tree().quit(1); return
	var gedaempft := _gedaempft(ual_ap.get_animation("Jog_Fwd_Loop"), 0.5)
	ual_ap.get_animation_library("").add_animation("Jog_Fwd_Gedaempft", gedaempft)
	var proben := [
		["Jetzt im Spiel: Jog_Fwd, 0,75-fach", "Jog_Fwd_Loop", 0.75],
		["Jog_Fwd, Beckenhub halb (Füße bleiben über dem Boden), 0,75-fach", "Jog_Fwd_Gedaempft", 0.75],
		["Sprint, 0,75-fach", "Sprint_Loop", 0.75],
	]
	var t := 0.0
	for pr in proben:
		ablauf.append([t, _probe_4164.bind(koerper[0], pr, false)])
		t += 4.5
		ablauf.append([t, _probe_4164.bind(koerper[0], pr, true)])
		t += 4.0
	ablauf.append([t, func(): get_tree().quit()])


var _probe_knoten: Node3D
var _streifen: Node3D
var _tempo := 0.0

func _probe_4164(koerper: String, pr: Array, spielansicht: bool) -> void:
	if _probe_knoten: _probe_knoten.queue_free()
	_probe_knoten = Node3D.new()
	add_child(_probe_knoten)
	var f := _figur(koerper)
	f.reparent(_probe_knoten)
	f.rotation_degrees.y = 90    # läuft nach +x
	var ap := _bewegt(f, [pr[1]])
	ap.speed_scale = pr[2]
	# Boden mit Querstreifen je Meter, läuft mit dem Tempo des Spiels (RENN) unter dem Helden durch
	var b := _boden(40.0, 3.0)
	b.reparent(_probe_knoten)
	_streifen = Node3D.new()
	_probe_knoten.add_child(_streifen)
	for i in 41:
		var l := _linie(Vector3(-20 + i, 0.005, -1.4), Vector3(-20 + i, 0.005, 1.4), Color(0.4, 0.35, 0.28))
		l.rotation_degrees.y = 90
		l.reparent(_streifen)
	_tempo = RENN
	if spielansicht:
		kamera.projection = Camera3D.PROJECTION_ORTHOGONAL
		kamera.size = 4.5
		var blick := Basis.from_euler(Vector3(deg_to_rad(-30), deg_to_rad(45), 0))
		kamera.global_transform = Transform3D(blick, Vector3(0, 0.9, 0) + blick.z * 12.0)
	else:
		kamera.projection = Camera3D.PROJECTION_PERSPECTIVE
		kamera.fov = 30
		kamera.position = Vector3(0, 1.0, 6.5)
		kamera.look_at(Vector3(0, 0.9, 0))
	titel.text = "416.4 · %s · %s" % [pr[0], "Spielansicht" if spielansicht else "von der Seite"]
	print("FILM 416.4 ", pr[0], " Spielansicht=", spielansicht)


# Beckenhub dämpfen: die senkrechte Abweichung vom Tiefstand mal k, aber nie so tief, dass ein Fuß unter seinen Tiefstand sinkt
func _gedaempft(a: Animation, k: float) -> Animation:
	var neu := a.duplicate(true) as Animation
	var sk := B.skelett(ual)
	var pe := sk.find_bone("pelvis")
	var spur := -1
	for i in neu.get_track_count():
		if neu.track_get_type(i) == Animation.TYPE_POSITION_3D and neu.track_get_path(i).get_concatenated_subnames() == "pelvis": spur = i
	if spur < 0: print("FILM FEHLER keine Beckenspur"); return neu
	var fuesse := [sk.find_bone("foot_l"), sk.find_bone("foot_r"), sk.find_bone("ball_l"), sk.find_bone("ball_r")].filter(func(x): return x >= 0)
	ual_ap.play("Jog_Fwd_Loop")
	var hoehen := []     # je Schlüssel: Becken und tiefster Fuß (Skelettraum, y oben)
	for j in neu.track_get_key_count(spur):
		ual_ap.seek(neu.track_get_key_time(spur, j), true)
		var tief := INF
		for fb in fuesse: tief = minf(tief, sk.get_bone_global_pose(fb).origin.y)
		hoehen.append([sk.get_bone_global_pose(pe).origin.y, tief])
	var b_min: float = hoehen.map(func(h): return h[0]).min()
	var f_min: float = hoehen.map(func(h): return h[1]).min()
	var eltern := sk.get_bone_parent(pe)
	var vorher := 0.0
	var nachher := 0.0
	for j in hoehen.size():
		var dy: float = -(hoehen[j][0] - b_min) * (1.0 - k)
		dy = maxf(dy, f_min - hoehen[j][1])         # Fuß nicht unter den Boden
		ual_ap.seek(neu.track_get_key_time(spur, j), true)
		var b_eltern := sk.get_bone_global_pose(eltern).basis if eltern >= 0 else Basis()
		var lokal: Vector3 = b_eltern.inverse() * Vector3(0, dy, 0)
		neu.track_set_key_value(spur, j, (neu.track_get_key_value(spur, j) as Vector3) + lokal)
		vorher = maxf(vorher, hoehen[j][0] - b_min)
		nachher = maxf(nachher, hoehen[j][0] + dy - b_min)
	print("FILM 416.4 Beckenhub %.1f cm -> %.1f cm" % [vorher * 100, nachher * 100])
	return neu
