extends Node3D
# Probefilme aus der Bibliothek (408: Bestand vor Eigenbau, „am besten natürlich in einem Film, weil dann sehe ich auch, wenn es sich
# dreht, wie es aus allen Perspektiven ausschaut“). Läuft im Ablauf tom-probe.yml mit --write-movie; gekaufte Dateien bleiben auf dem
# Runner, ins Artefakt geht nur der Film (348.12c a).
#   --film=431   Grundkörper, Haare und Bärte der Bibliothek drehend, mit den Größen der Völker (LISTE-FIGUREN.md „Völker“, 430)
#   --film=431v  Völker Runde 3: Grundkörper je Volk aus tools/blender348/v3/voelker.py (Umgebung VOELKER=<ordner>), Mann und Frau,
#                Kopf-, Beinanteil, Schulter gemessen gegen Homers Ziele; Hügelvolk neben Goblin; Schattenriss
#   --film=376.1 Heldin: alle Frauentrachten der Bibliothek (Modular Character Outfits) mit dem Kaufkopf Regulär Frau, drehend
#   --film=416.4 Rennen: Jog_Fwd wie im Spiel, Jog mit halbem Beckenhub, Sprint; von der Seite und aus der Spielansicht
# Umgebung: KAUF=<gekaufte Pakete>, CC0=<freie Quaternius-Pakete> (cc0_laden.sh). Ende von selbst; Zeilen „FILM …“ ins Protokoll.
# Hochformat wie das Spiel (1080 × 2340, Lauf 41291021273: der Film nimmt die Projektgröße, nicht --resolution): Felder mit je einer
# Kamera (SubViewport) in derselben Welt; jede Figur steht weit weg von den anderen, jede Kamera sieht nur ihre.

const B := preload("res://probe/bibliothek.gd")
const GOLD := Color(0.83, 0.68, 0.36)
const WEISS := Color(0.93, 0.9, 0.84)
const VOELKER := [["Hügelvolk", 1.05], ["Zwerg", 1.35], ["Elf", 1.72], ["Orkblütiger", 1.85]]
const FRAU := 0.93            # Frauen 7 % kleiner (430)
const RENN := 3.68 * 1.16     # held.gd: Rennen 3,68 Kacheln je Sekunde (wie tests/rennen_4164.gd)
const BREITE := 1080.0
const HOEHE := 2340.0
const OBEN := 150.0           # Titelband

var kauf := OS.get_environment("KAUF")
var cc0 := OS.get_environment("CC0")
var ebene := CanvasLayer.new()
var schrift := FontFile.new()
var titel := Label.new()
var felder := []              # Controls eines Teils (Container und Überlagerung), werden beim nächsten Teil entfernt
var schilder := []            # [Label, Node3D, Höhe über dem Knoten, Kamera]
var rahmen := []              # [Kamera, Figur, Höhe, Name, unten]: Prüfung, ob unterer Punkt (Füße, bei Köpfen Schultern) und Scheitel im Feld liegen
var knoten: Node3D            # 3D-Teile des laufenden Teils
var ual: Node3D
var ual_ap: AnimationPlayer
var zeit := 0.0
var ablauf := []              # [ab Sekunde, Callable]
# 457.1 (Chef 01.11., 11:49: „unsere Signatur muss sich wiederfinden“): standardmaessig wie im Spiel gezeichnet: Licht und Schatten aus
# licht.gd (Sonne, Umgebung, Tonwerte), Figuren mit dem Toon-Zeichner (bibliothek.gd spielbild), Tusche nach Licht je Feld (shader/tusche.gdshader
# wie kamera.gd: Welt Schablone 0, Figuren Schablone 2, feiner); --ohnetoon: wie vorher, nur mit Schalter
var spielbild := "--ohnetoon" not in OS.get_cmdline_user_args()
var licht: Licht
var tusche_mats := []   # je Flaeche [Material, Kamera, Feldgroesse]


func _ready() -> void:
	schrift.load_dynamic_font("res://kampf/schrift/alegreya_regular.ttf")
	if spielbild:
		licht = Licht.new()
		add_child(licht)
		licht.env.background_color = Color(0.05, 0.045, 0.04)
	else:
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
	var leer := Camera3D.new()   # die Hauptansicht zeigt nur den Grund, gezeichnet wird in den Feldern
	leer.cull_mask = 0
	add_child(leer)
	add_child(ebene)
	var grund := ColorRect.new()
	grund.color = Color(0.03, 0.028, 0.025)
	grund.size = Vector2(BREITE, HOEHE)
	ebene.add_child(grund)
	titel.position = Vector2(30, 24)
	titel.size = Vector2(BREITE - 60, OBEN - 30)
	titel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stil(titel, 34)
	ebene.add_child(titel)
	var ual_pfad := _erste(B.dateien([cc0, kauf], ".glb").filter(func(p): return p.get_file() == "UAL1_Standard.glb"))
	ual = B.lade(ual_pfad, "", false) if ual_pfad != "" else null
	if ual == null: print("FILM FEHLER: UAL1_Standard.glb fehlt unter CC0/KAUF"); get_tree().quit(1); return
	ual_ap = B.spieler(ual)
	ual.visible = false
	ual.position = Vector3(0, -50, 0)
	add_child(ual)    # der Spieler stellt das Gerüst nur im Baum (für _gedaempft)
	var film := ""
	for a in OS.get_cmdline_user_args(): if a.begins_with("--film="): film = a.substr(7)
	print("FILM ", film, " KAUF=", kauf != "", " UAL=", ual_pfad)
	match film:
		"431": _film_431()
		"416.4": _film_4164()
		"376.1": _film_3761()
		"431v": _film_431v()
		"458": _film_458()
		_: print("FILM FEHLER: --film=431, 431v, 416.4, 376.1 oder 458"); get_tree().quit(1)


func _process(dt: float) -> void:
	zeit += dt
	for e in tusche_mats:
		if not is_instance_valid(e[1]): continue
		var m: ShaderMaterial = e[0]
		var cam: Camera3D = e[1]
		m.set_shader_parameter("licht_dir", Licht.richtung())
		# Bildbreite in Metern wie Kamera.size im Spiel: senkrecht gestellt (ortho) oder in der Entfernung des Blickpunkts
		var r: Vector2 = e[2]
		var hoch := cam.size if cam.projection == Camera3D.PROJECTION_ORTHOGONAL else 2.0 * tan(deg_to_rad(cam.fov) / 2.0) * maxf(0.5, cam.global_position.length())
		m.set_shader_parameter("breite_m", hoch * r.x / maxf(1.0, r.y))
	ablauf.sort_custom(func(a, b): return a[0] < b[0])
	while not ablauf.is_empty() and zeit >= ablauf[0][0]:
		var schritt: Array = ablauf.pop_front()
		(schritt[1] as Callable).call()
	if _streifen and is_instance_valid(_streifen): _streifen.position.x = fposmod(_streifen.position.x - _tempo * dt, 1.0)
	for s in schilder.duplicate():
		var l = s[0]
		if not is_instance_valid(l) or not is_instance_valid(s[1]) or not (s[1] as Node3D).is_inside_tree():
			if is_instance_valid(l): l.queue_free()
			schilder.erase(s)
			continue
		var cam: Camera3D = s[3]
		var p: Vector3 = (s[1] as Node3D).global_position + Vector3(0, s[2], 0)
		(l as Label).position = cam.unproject_position(p) - Vector2((l as Label).size.x / 2, 0)


func _physics_process(dt: float) -> void:
	if knoten and is_instance_valid(knoten):
		for f in knoten.get_children():
			if f is Node3D and f.has_meta("dreh"): (f as Node3D).rotate_y(TAU * float(f.get_meta("dreh")) * dt)


# Teil wechseln: Felder, Schilder und 3D-Teile des vorigen weg
func _neuer_teil(text: String) -> void:
	for c in felder: if is_instance_valid(c): c.queue_free()
	felder.clear()
	rahmen.clear()
	if knoten: knoten.queue_free()
	knoten = Node3D.new()
	add_child(knoten)
	titel.text = text
	ablauf.append([zeit + 1.0, _pruefe])


# ein Feld: Rechteck auf dem Schirm, eigene Kamera; Rückgabe [Kamera, Überlagerung für Schilder]
func _feld(r: Rect2, ortho := 0.0) -> Array:
	var c := SubViewportContainer.new()
	c.position = r.position
	c.size = r.size
	c.stretch = true
	var v := SubViewport.new()
	v.size = Vector2i(r.size)
	v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var cam := Camera3D.new()
	if ortho > 0.0:
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = ortho          # senkrechte Ausdehnung in Metern
	v.add_child(cam)
	if spielbild: _tusche(cam, r.size)
	c.add_child(v)
	ebene.add_child(c)
	var o := Control.new()
	o.position = r.position
	o.size = r.size
	o.clip_contents = true
	o.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ebene.add_child(o)
	var rand := ReferenceRect.new()   # dünner Goldrand je Feld
	rand.border_color = GOLD.darkened(0.45)
	rand.border_width = 2.0
	rand.editor_only = false
	rand.size = r.size
	o.add_child(rand)
	felder.append_array([c, o])
	cam.current = true
	return [cam, o]


# 457.1: Tusche wie kamera.gd tusche_flaeche (Welt 1,3/1,7, Figuren 0,8/1,5, nach Licht)
func _tusche(cam: Camera3D, groesse: Vector2) -> void:
	var tu: Shader = load("res://shader/tusche.gdshader")
	var tu_fig := Shader.new()
	tu_fig.code = tu.code.replace("stencil_mode read, compare_equal, 0;", "stencil_mode read, compare_equal, 2;")
	for e in [[tu, 1.3, 1.7], [tu_fig, 0.8, 1.5]]:
		var q := MeshInstance3D.new()
		var qm := QuadMesh.new()
		qm.size = Vector2(2, 2)
		q.mesh = qm
		q.extra_cull_margin = 16384.0
		q.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var m := ShaderMaterial.new()
		m.shader = e[0]
		m.render_priority = 127
		m.set_shader_parameter("px", e[1])
		m.set_shader_parameter("dick", e[2])
		m.set_shader_parameter("richtung", 1.0)
		q.material_override = m
		q.position = Vector3(0, 0, -1)
		cam.add_child(q)
		tusche_mats.append([m, cam, groesse])


func _stil(l: Label, groesse: int, farbe := GOLD) -> void:
	l.add_theme_font_override("font", schrift)
	l.add_theme_font_size_override("font_size", groesse)
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 8)


func _text(o: Control, text: String, pos: Vector2, groesse := 26, farbe := WEISS) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	_stil(l, groesse, farbe)
	o.add_child(l)
	return l


# Schild, das einem Punkt über einer Figur folgt (waagrecht mittig)
func _schild(feld: Array, text: String, an: Node3D, hoehe: float, groesse := 26) -> void:
	var l := _text(feld[1], text, Vector2.ZERO, groesse)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	schilder.append([l, an, hoehe, feld[0]])


func _erste(l: Array) -> String:
	return l[0] if not l.is_empty() else ""


func _boden(mitte: Vector3, laenge: float, breite: float) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(laenge, breite)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.14, 0.12)
	mat.roughness = 1.0
	pm.material = mat
	m.mesh = pm
	knoten.add_child(m)
	m.position = mitte
	return m


func _linie(von: Vector3, bis: Vector3, farbe: Color, eltern: Node3D = null) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3((bis - von).length(), 0.006, 0.006)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = farbe
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bm.material = mat
	m.mesh = bm
	(eltern if eltern else knoten).add_child(m)
	m.position = (von + bis) / 2
	if absf((bis - von).z) > absf((bis - von).x): m.rotation_degrees.y = 90
	return m


func _figur(pfad: String, wo: Vector3) -> Node3D:
	var f := B.lade(pfad, _paket(pfad))
	if f == null: print("FILM FEHLER laden ", pfad); return null
	knoten.add_child(f)
	f.position = wo
	return f


func _paket(pfad: String) -> String:   # Paketordner „Universal Base Characters…“ (Bilder darunter)
	var d := pfad.get_base_dir()
	while d.length() > 1 and not d.get_file().begins_with("Universal Base Characters"): d = d.get_base_dir()
	return d if d.length() > 1 else pfad.get_base_dir()


func _bewegt(f: Node3D, namen: Array) -> AnimationPlayer:
	var q := {}
	for n in namen: if ual_ap.has_animation(n): q[n] = ual_ap.get_animation(n)
	var ap := B.bewegung(f, q, B.skelett(ual))
	if not namen.is_empty() and ap.has_animation(namen[0]): ap.play(namen[0])
	return ap


func _hoehe(f: Node3D) -> float:
	var h := 0.0
	for m in f.find_children("*", "MeshInstance3D", true, false): h = maxf(h, (m as MeshInstance3D).get_aabb().end.y)
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


func _deutsch(p: String) -> String:
	var n := p.get_file().get_basename().replace("_FullBody", "")
	return n.replace("_Male", " Mann").replace("_Female", " Frau").replace("Superhero", "Superheld").replace("Regular", "Regulär").replace("Teen", "Jugend")


func _m(x: float) -> String:
	return ("%.2f" % x).replace(".", ",")


# Prüfung ohne Bild (auch im Ablauf): bewegt sich jede Figur, sitzt jedes Haar am Gerüst, liegen Füße und Scheitel im Feld
func _pruefe() -> void:
	for r in rahmen:
		var cam: Camera3D = r[0]
		var f: Node3D = r[1]
		if not is_instance_valid(f): continue
		var gr := cam.get_viewport().get_visible_rect().size
		var fuss := cam.unproject_position(f.global_position + Vector3(0, r[4] if r.size() > 4 else 0.0, 0))
		var kopf := cam.unproject_position(f.global_position + Vector3(0, r[2], 0))
		var drin := func(p: Vector2): return p.x >= 0 and p.y >= 0 and p.x <= gr.x and p.y <= gr.y
		var sk := B.skelett(f)
		var h := sk.find_bone("hand_r")
		var weg := (sk.get_bone_global_pose(h).origin - sk.get_bone_global_rest(h).origin).length() if h >= 0 else -1.0
		var netze := sk.get_children().filter(func(c): return c is MeshInstance3D).map(func(c): return "%s%s" % [c.name, "" if c.get_node_or_null(c.skeleton) == sk else "(lose)"])
		if sk.find_bone("ball_l") >= 0:   # Goblin (eigenes Geruest) hat keine Ballen
			var tief := INF   # Ballen über dem Boden: in Ruhe etwa 3 cm; deutlich darunter steht die Figur im Boden, darüber schwebt sie
			for b in ["ball_l", "ball_r"]: if sk.find_bone(b) >= 0: tief = minf(tief, (sk.global_transform * sk.get_bone_global_pose(sk.find_bone(b))).origin.y - f.global_position.y)
			print("FILM Ballen %s: %.1f cm über dem Boden (Ruhe %.1f cm)" % [r[3], tief * 100, (sk.global_transform * sk.get_bone_global_rest(sk.find_bone("ball_l"))).origin.y * 100 - f.global_position.y * 100])
		print("FILM Feld %s: Feld %dx%d, unten %s %s, Scheitel %s %s; Hand %.0f cm aus der Ruhelage; %s" % [r[3], gr.x, gr.y,
			str(fuss.round()), "drin" if drin.call(fuss) else "DRAUSSEN", str(kopf.round()), "drin" if drin.call(kopf) else "DRAUSSEN",
			weg * 100, ", ".join(PackedStringArray(netze))])


# 431 ------------------------------------------------------------------------------------------------------------------------------
func _film_431() -> void:
	var koerper := _einmal(_aus_einer(func(p): return p.get_file().ends_with("_FullBody.gltf") and "Godot" in p))
	var haare := _einmal(_aus_einer(func(p): return "Rigged to Head Bone" in p and "Godot" in p and not "_Teen" in p.get_file()))
	print("FILM 431 Körper ", koerper.size(), ": ", ", ".join(PackedStringArray(koerper.map(func(p): return p.get_file()))))
	print("FILM 431 Haare ", haare.size(), ": ", ", ".join(PackedStringArray(haare.map(func(p): return p.get_file()))))
	if koerper.is_empty(): print("FILM FEHLER keine Grundkörper"); get_tree().quit(1); return
	ablauf.append([0.0, _koerper_431.bind(koerper)])
	var seiten := []
	var seite := []
	for p in haare:
		seite.append(p)
		if seite.size() == 6: seiten.append(seite); seite = []
	if not seite.is_empty(): seiten.append(seite)
	var t := 12.0
	for i in seiten.size():
		ablauf.append([t, _haare_431.bind(seiten[i], koerper, i + 1, seiten.size())])
		t += 6.0
	ablauf.append([t, func(): get_tree().quit()])


func _aus_einer(passt: Callable) -> Array:   # Kauf (Source) enthält alles der freien Standardfassung: dann nur Kauf
	var l := B.dateien([kauf], ".gltf").filter(passt)
	return l if not l.is_empty() else B.dateien([cc0], ".gltf").filter(passt)


func _einmal(l: Array) -> Array:   # je Ordner und Dateiname einmal (Male/Female haben gleiche Namen)
	var gesehen := {}
	var aus := []
	for p in l:
		var k: String = p.get_base_dir().get_file() + "/" + p.get_file()
		if not gesehen.has(k): gesehen[k] = true; aus.append(p)
	return aus


# Raster 2 Spalten × 3 Zeilen unter dem Titel
func _raster(i: int) -> Rect2:
	var w := BREITE / 2.0
	var h := (HOEHE - OBEN) / 3.0
	return Rect2(Vector2((i % 2) * w, OBEN + (i / 2) * h), Vector2(w, h))


# Ganzkörperfeld: leicht von oben (10°), damit der Boden mit Schatten sichtbar ist (Prüfer 376.1: waagrecht lag er unsichtbar auf Kante)
func _ganz(cam: Camera3D, x: float) -> void:
	cam.rotation_degrees.x = -10.0
	cam.position = Vector3(x, 1.08, 0.0) + cam.basis.z * 8.0


# Teil 1: Grundkörper, links Mann, rechts Frau, je Zeile eine Art (Regulär, Superheld, Jugend); gleicher Maßstab in allen Feldern;
# Goldlinien in Völkergröße (Frau 7 % kleiner)
func _koerper_431(koerper: Array) -> void:
	_neuer_teil("431 · Bibliothek: Grundkörper (Quaternius Universal Base Characters), alle im gleichen Maßstab · Goldlinie = Größe des Volkes")
	var arten := ["Regular", "Superhero", "Teen"]
	for z in arten.size():
		for s in 2:
			var name: String = arten[z] + ("_Male" if s == 0 else "_Female") + "_FullBody.gltf"
			var p := _erste(koerper.filter(func(q): return q.get_file() == name))
			if p == "": continue
			var x := (z * 2 + s) * 6.0
			var f := _figur(p, Vector3(x, 0, 0))
			if f == null: continue
			_bewegt(f, ["Idle_Loop"])
			f.set_meta("dreh", 1.0 / 12.0)
			var h := _hoehe(f)
			var feld := _feld(_raster(z * 2 + s), 2.35)
			var cam: Camera3D = feld[0]
			_ganz(cam, x)
			_boden(Vector3(x, 0, 0), 1.8, 1.2)
			var k := 1.0 if s == 0 else FRAU
			for v in VOELKER:
				var y: float = v[1] * k
				_linie(Vector3(x - 0.9, y, -0.5), Vector3(x + 0.9, y, -0.5), GOLD.darkened(0.2))
				var l := _text(feld[1], "%s %d" % [v[0], int(round(y * 100))], Vector2(10, cam.unproject_position(Vector3(x, y, -0.5)).y - 30), 20, GOLD)
				l.name = "Linie"
			_text(feld[1], "%s · %s m" % [_deutsch(p), _m(h)], Vector2(12, 8), 26)
			rahmen.append([cam, f, h, p.get_file()])
			print("FILM 431 %s Höhe %.3f m" % [p.get_file(), h])


# Teil 2: Haare, Bärte, Brauen, je Seite sechs auf dem Regulär-Körper (Frauenhaar auf der Frau), Kopf und Schultern nah
func _haare_431(s: Array, koerper: Array, nr: int, von: int) -> void:
	_neuer_teil("431 · Bibliothek: Haare, Bärte, Brauen (Seite %d von %d), auf dem Grundkörper Regulär" % [nr, von])
	for i in s.size():
		var p: String = s[i]
		var weib := "/Female/" in p or "Female" in p.get_file()
		var basis := _erste(koerper.filter(func(q): return q.get_file() == ("Regular_Female_FullBody.gltf" if weib else "Regular_Male_FullBody.gltf")))
		if basis == "": basis = _erste(koerper.filter(func(q): return ("_Female" if weib else "_Male") in q.get_file()))
		if basis == "": basis = koerper[0]
		var x := 50.0 + i * 6.0
		var f := _figur(basis, Vector3(x, 0, 0))
		if f == null: continue
		_haar(f, p)
		_bewegt(f, ["Idle_Loop"])
		f.set_meta("dreh", 1.0 / 6.0)
		var h := _hoehe(f)
		var feld := _feld(_raster(i), 0.85)
		var cam: Camera3D = feld[0]
		cam.position = Vector3(x, h - 0.33, 4.0)
		_text(feld[1], p.get_file().get_basename().replace("Hair_", "").replace("_", " ") + (" (Frau)" if weib else ""), Vector2(12, 8), 28)
		rahmen.append([cam, f, h, p.get_file(), h - 0.7])


# 376.1 ----------------------------------------------------------------------------------------------------------------------------
const TRACHTEN := {"Knight": "Ritterin (Platte)", "Knight_Cloth": "Ritterin (Stoff)", "Noble": "Adlige", "Peasant": "Bäuerin",
	"Ranger": "Waldläuferin", "Wizard": "Magierin"}

func _film_3761() -> void:
	var trachten := _einmal(_aus_einer(func(p): return "/Outfits/" in p and p.get_file().begins_with("Female_") and "Godot" in p))
	var kopf := _erste(B.dateien([kauf], ".gltf").filter(func(p): return p.get_file() == "Regular_Female_OnlyHead.gltf"))
	var haar := _erste(_aus_einer(func(p): return "Rigged to Head Bone" in p and "/Female/" in p and p.get_file() == "Hair_Ponytail_2.gltf"))
	print("FILM 376.1 Trachten ", trachten.size(), ": ", ", ".join(PackedStringArray(trachten.map(func(p): return p.get_file()))), "; Kopf ", kopf.get_file(), "; Haar ", haar.get_file())
	if trachten.is_empty(): print("FILM FEHLER keine Frauentrachten"); get_tree().quit(1); return
	if kopf == "": print("FILM 376.1 ohne Kaufkopf (KAUF fehlt): nur Trachten")
	ablauf.append([0.0, _trachten_3761.bind(trachten.slice(0, 6), kopf, haar)])
	ablauf.append([14.0, func(): get_tree().quit()])


func _trachten_3761(trachten: Array, kopf: String, haar: String) -> void:
	_neuer_teil("376.1 · Heldin: alle Frauentrachten der Bibliothek (Quaternius Modular Character Outfits), Kopf Regulär Frau, Zopf")
	for i in trachten.size():
		var p: String = trachten[i]
		var x := 100.0 + i * 6.0
		var f := _figur(p, Vector3(x, 0, 0))
		if f == null: continue
		if kopf != "": _haar(f, kopf)        # Kopf wie Haar: eigenes Gerüst, gleiche Knochen, aufs Gerüst der Tracht
		if haar != "": _haar(f, haar)
		_bewegt(f, ["Idle_Loop"])
		f.set_meta("dreh", 1.0 / 12.0)
		var h := _hoehe(f)
		var feld := _feld(_raster(i), 2.35)
		var cam: Camera3D = feld[0]
		_ganz(cam, x)
		_boden(Vector3(x, 0, 0), 1.8, 1.2)
		var n := p.get_file().get_basename().trim_prefix("Female_")
		_text(feld[1], "%s · %s" % [TRACHTEN.get(n, n), n], Vector2(12, 8), 26)
		rahmen.append([cam, f, h, p.get_file()])


# 431v -----------------------------------------------------------------------------------------------------------------------------
# Runde 3 (Chef 01.11., 11:42, „431 wie Sokrates“): Homers Punkte 1, 2 mit Zahlen (voelker.json), Mann und Frau je Volk, Hügelvolk neben
# Goblin (LISTE-FIGUREN.md „Verwechslungsgefahr“), Schattenriss („am Schattenriss ohne Ausrüstung erkennbar“, 430)
const VOLK_REIHE := ["Mensch", "Elf", "Zwerg", "Hügelvolk", "Orkblütiger"]
var voelker := {}   # "Volk/mann|frau" -> Eintrag aus voelker.json
var volk_dir := OS.get_environment("VOELKER")

func _film_431v() -> void:
	var j: Variant = JSON.parse_string(FileAccess.get_file_as_string(volk_dir.path_join("voelker.json")))
	if not j is Dictionary: print("FILM FEHLER voelker.json fehlt unter VOELKER=", volk_dir); get_tree().quit(1); return
	for e in j["voelker"]:
		voelker["%s/%s" % [e["volk"], "frau" if e["frau"] else "mann"]] = e
		print("FILM 431v %s %s: %.3f m, Kopf 1/%.2f, Beine %.3f, Schulter %.3f m (%.2f gegen Mensch, %.2f im Verhältnis zur Größe)" % [e["volk"],
			"Frau" if e["frau"] else "Mann", e["groesse_m"], e["kopf_1_durch"], e["bein_anteil"], e["schulter_m"], e["schulter_gegen_mensch"], e["schulter_rel_gegen_mensch"]])
	ablauf.append([0.0, _reihe_431v])
	ablauf.append([14.0, _goblin_431v])
	ablauf.append([22.0, _riss_431v])
	ablauf.append([30.0, func(): get_tree().quit()])


func _volk_figur(e: Dictionary, wo: Vector3) -> Node3D:
	var f := _figur(volk_dir.path_join(String(e["datei"])), wo)
	if f == null: return null
	_bewegt(f, ["Idle_Loop"])
	return f


func _ziel_text(e: Dictionary) -> String:
	var z: Dictionary = e["ziel"]
	var t := "%s\n%d cm" % [e["volk"], int(round(float(e["groesse_m"]) * 100))]
	t += "\nKopf 1/%s" % _m1(float(e["kopf_1_durch"])) + (" (%s)" % _m1(1.0 / float(z["kopf"])) if z.has("kopf") else "")
	t += "\nBeine %s" % _m(float(e["bein_anteil"])) + (" (%s)" % _m(float(z["bein"])) if z.has("bein") else "")
	if z.has("schulter"):   # absolut gegen den Menschen („abs“) oder im Verhältnis zur Größe („rel“), wie Homers Satz es meint
		var sz: Array = z["schulter"]
		t += "\nSchulter %s (%s)%s" % [_m(float(e["schulter_gegen_mensch"] if sz[0] == "abs" else e["schulter_rel_gegen_mensch"])), _m(float(sz[1])),
			"" if sz[0] == "abs" else "*"]
	return t


func _m1(x: float) -> String:
	return ("%.1f" % x).replace(".", ",")


# eine Reihe Figuren in einem Feld (gleicher Maßstab), darunter die Zahlen, darüber je eine Goldlinie in Homers Größe
func _reihe(r: Rect2, liste: Array, x0: float, dreh: float, zahlen := true, titel_feld := "", frei := 0) -> Array:
	var abstand := 0.75
	var breite := abstand * (liste.size() + frei)   # frei: Plaetze rechts fuer Figuren ohne Eintrag (Goblin)
	var hoch := maxf(breite * r.size.y / r.size.x, 2.6)
	var feld := _feld(r, hoch)
	var cam: Camera3D = feld[0]
	var mitte := x0 + (liste.size() + frei - 1) * abstand / 2.0
	cam.position = Vector3(mitte, hoch / 2.0 - 0.15, 8.0)
	_boden(Vector3(mitte, 0, 0), breite + 1.0, 1.6)
	var figuren := []
	for i in liste.size():
		var e: Dictionary = liste[i]
		var x := x0 + i * abstand
		var f := _volk_figur(e, Vector3(x, 0, 0))
		if f == null: continue
		f.set_meta("dreh", dreh)
		figuren.append(f)
		var h := _hoehe(f)
		var soll: float = float(e["ziel"]["h"]) * (0.93 if e["frau"] else 1.0)
		_linie(Vector3(x - 0.25, soll, -0.5), Vector3(x + 0.25, soll, -0.5), GOLD.darkened(0.2))
		if zahlen:   # Zahlen über den Figuren (über 1,9 m frei)
			var l := _text(feld[1], _ziel_text(e), Vector2.ZERO, 19)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			l.size = Vector2(r.size.x / (liste.size() + frei), 150)
			var unten := cam.unproject_position(Vector3(x, 1.97, 0))
			l.position = Vector2(unten.x - l.size.x / 2.0, unten.y - l.size.y)
		rahmen.append([cam, f, h, String(e["datei"])])
	if titel_feld != "": _text(feld[1], titel_feld, Vector2(14, 8), 26, GOLD)
	return figuren


func _liste(geschlecht: String) -> Array:
	return VOLK_REIHE.map(func(v): return voelker.get(v + "/" + geschlecht, {})).filter(func(e): return not e.is_empty())


func _reihe_431v() -> void:
	_neuer_teil("431 · Völker Runde 3: Grundkörper je Volk (Ork auf Superheld, übrige Regulär), gemessen; in Klammern Homers Ziel · Schulter gegen Mensch, * im Verhältnis zur Größe · Goldstrich = Größe")
	var h := (HOEHE - OBEN) / 2.0
	_reihe(Rect2(Vector2(0, OBEN), Vector2(BREITE, h)), _liste("mann"), 0.0, 1.0 / 14.0, true, "Männer")
	_reihe(Rect2(Vector2(0, OBEN + h), Vector2(BREITE, h)), _liste("frau"), 20.0, 1.0 / 14.0, true, "Frauen (7 % kleiner)")


func _goblin_431v() -> void:
	_neuer_teil("431 · Hügelvolk neben Goblin (Verwechslung bei gleicher Größe: Kopf, Haltung; Haut im Spiel getönt) und Mensch als Maßstab")
	var liste := [voelker.get("Mensch/mann", {}), voelker.get("Hügelvolk/mann", {}), voelker.get("Hügelvolk/frau", {})].filter(func(e): return not e.is_empty())
	var r := Rect2(Vector2(0, OBEN), Vector2(BREITE, HOEHE - OBEN))
	var fig := _reihe(r, liste, 40.0, 1.0 / 8.0, true, "", 1)
	var gpfad := volk_dir.path_join("goblin.glb")
	if FileAccess.file_exists(gpfad) and not fig.is_empty():
		var x := 40.0 + liste.size() * 0.75
		var g := _figur(gpfad, Vector3(x, 0, 0))
		if g:
			var gap := B.spieler(g)
			if gap and gap.get_animation_list().size() > 0: gap.play(gap.get_animation_list()[0])
			g.set_meta("dreh", 1.0 / 8.0)
			var gh := _hoehe(g)
			print("FILM 431v Goblin %.3f m" % gh)
			var cam: Camera3D = rahmen[-1][0]
			var l := _text(felder[-1], "Goblin\n%d cm" % int(round(gh * 100)), Vector2.ZERO, 19)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			l.size = Vector2(BREITE / (liste.size() + 1), 150)
			var unten := cam.unproject_position(Vector3(x, 1.97, 0))
			l.position = Vector2(unten.x - l.size.x / 2.0, unten.y - l.size.y)
			rahmen.append([cam, g, gh, "goblin"])
	else:
		print("FILM 431v ohne Goblin (goblin.glb fehlt)")


# Schattenriss: schwarz auf hellem Grund, oben von vorn, unten von der Seite
func _riss_431v() -> void:
	_neuer_teil("431 · Schattenriss ohne Ausrüstung (Homer: „am Schattenriss erkennbar, welches Volk“): oben von vorn, unten von der Seite")
	var h := (HOEHE - OBEN) / 2.0
	for z in 2:
		var figs := _reihe(Rect2(Vector2(0, OBEN + z * h), Vector2(BREITE, h)), _liste("mann"), 60.0 + z * 20.0, 0.0, false)
		var schwarz := StandardMaterial3D.new()
		schwarz.albedo_color = Color.BLACK
		schwarz.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for f in figs:
			if z == 1: (f as Node3D).rotation_degrees.y = 90
			for m in (f as Node3D).find_children("*", "MeshInstance3D", true, false): (m as MeshInstance3D).material_override = schwarz
	var env := Environment.new()   # heller Grund hinter den Rissen, nur in diesen Kameras
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.78, 0.74, 0.66)
	for r in rahmen: (r[0] as Camera3D).environment = env


# 416.4 ----------------------------------------------------------------------------------------------------------------------------
func _film_4164() -> void:
	var koerper := B.dateien([kauf], ".gltf").filter(func(p): return p.get_file() == "Regular_Male_FullBody.gltf" and "Godot" in p)
	if koerper.is_empty(): koerper = B.dateien([cc0, kauf], ".gltf").filter(func(p): return p.get_file() == "Superhero_Male_FullBody.gltf")
	if koerper.is_empty(): print("FILM FEHLER kein Grundkörper"); get_tree().quit(1); return
	ual_ap.get_animation_library("").add_animation("Jog_Fwd_Gedaempft", _gedaempft(ual_ap.get_animation("Jog_Fwd_Loop"), 0.5))
	var proben := [
		["1 · jetzt im Spiel: Jog_Fwd, 0,75-fach", "Jog_Fwd_Loop", 0.75],
		["2 · Jog_Fwd mit halbem Beckenhub, 0,75-fach", "Jog_Fwd_Gedaempft", 0.75],
		["3 · Sprint, 0,75-fach", "Sprint_Loop", 0.75],
	]
	for i in proben.size():
		ablauf.append([i * 6.0, _probe_4164.bind(koerper[0], proben[i])])
	ablauf.append([proben.size() * 6.0, func(): get_tree().quit()])


var _streifen: Node3D
var _tempo := 0.0

func _probe_4164(koerper: String, pr: Array) -> void:
	_neuer_teil("416.4 · Rennen · %s · Boden läuft im Tempo des Spiels (%s m/s), Grundkörper ohne Tracht" % [pr[0], _m(RENN)])
	var f := _figur(koerper, Vector3.ZERO)
	f.rotation_degrees.y = 90    # läuft nach +x
	var ap := _bewegt(f, [pr[1]])
	ap.speed_scale = pr[2]
	_boden(Vector3.ZERO, 40.0, 4.0)
	_streifen = Node3D.new()
	knoten.add_child(_streifen)
	for i in 41: _linie(Vector3(-20 + i, 0.004, -1.8), Vector3(-20 + i, 0.004, 1.8), Color(0.42, 0.36, 0.28), _streifen)
	_tempo = RENN
	var h := (HOEHE - OBEN) / 2.0
	var seite := _feld(Rect2(Vector2(0, OBEN), Vector2(BREITE, h)))
	var cs: Camera3D = seite[0]
	cs.fov = 34
	cs.position = Vector3(0, 0.95, 4.6)
	cs.look_at(Vector3(0, 0.9, 0))
	_text(seite[1], "von der Seite", Vector2(14, 10), 28, GOLD)
	var spiel := _feld(Rect2(Vector2(0, OBEN + h), Vector2(BREITE, h)), 3.6)
	var cg: Camera3D = spiel[0]
	var blick := Basis.from_euler(Vector3(deg_to_rad(-30), deg_to_rad(45), 0))
	cg.global_transform = Transform3D(blick, Vector3(0, 0.9, 0) + blick.z * 12.0)
	_text(spiel[1], "Spielansicht (schräg von oben)", Vector2(14, 10), 28, GOLD)
	var hf := _hoehe(f)
	rahmen.append([cs, f, hf, "Seite"])
	rahmen.append([cg, f, hf, "Spiel"])
	print("FILM 416.4 ", pr[0])


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
	var b_min: float = hoehen.map(func(x): return x[0]).min()
	var f_min: float = hoehen.map(func(x): return x[1]).min()
	var eltern := sk.get_bone_parent(pe)
	var vorher := 0.0
	var nachher := 0.0
	for j in hoehen.size():
		var dy: float = -(hoehen[j][0] - b_min) * (1.0 - k)
		dy = maxf(dy, f_min - hoehen[j][1])         # Fuß nicht unter den Boden
		ual_ap.seek(neu.track_get_key_time(spur, j), true)
		var b_eltern := sk.get_bone_global_pose(eltern).basis if eltern >= 0 else Basis()
		neu.track_set_key_value(spur, j, (neu.track_get_key_value(spur, j) as Vector3) + b_eltern.inverse() * Vector3(0, dy, 0))
		vorher = maxf(vorher, hoehen[j][0] - b_min)
		nachher = maxf(nachher, hoehen[j][0] + dy - b_min)
	ual_ap.stop()
	print("FILM 416.4 Beckenhub %.1f cm -> %.1f cm" % [vorher * 100, nachher * 100])
	return neu


# 458.3 ----------------------------------------------------------------------------------------------------------------------------
# (Chef 01.11., 13:1x, Archiv 458; 408 Bestand vor Eigenbau, „in einem Film … wenn es sich dreht“): je Gegenstand ohne Netz
# (LISTE-NETZE.md „Haupthand, Nebenhand“) die Kandidaten aus dem Bestand nebeneinander drehend, im Spielbild; der Chef wählt.
# Pakete (LISTE-BESTAND.md „Waffen und Schilde“): O Omie (OBJ), A Anker (FBX), V Avramania (glb), P PolyMech (FBX), Q Props MegaKit.
# Je Feld die gemessene Länge (längste Seite); Netze stehen in ihrer Datei-Größe, nur eine Datei in Zentimetern wird auf Meter gebracht.
const KANDIDATEN_458 := [
	["Streitkolben (mace)", ["O:Mace/sm_mace.obj", "A:Maces/Mace.fbx", "A:Maces/Spiked Mace.fbx", "V:mdvl_weapons_mace_01.glb"]],
	["Streitaxt (battleaxe)", ["O:Battle Axe/sm_battle_axe.obj", "A:Axes/Battle Axe.fbx", "A:Axes/Axe.fbx"]],
	["Morgenstern (morningstar)", ["A:Maces/Spiked Club.fbx", "A:Maces/Spiked Mace.fbx", "O:Flail/sm_flail.obj", "A:Maces/Flail.fbx"]],
	["Kriegshammer (warhammer)", ["O:War Hammer/sm_war_hammer.obj", "A:Hammers/Warhammer.fbx", "A:Hammers/Hammer.fbx", "O:War Pick/sm_war_pick.obj"]],
	["Zweihänder (greatsword)", ["A:Swords/Greatsword.fbx", "A:Swords/Claymore.fbx", "A:Swords/Two-Handed Sword.fbx"]],
	["Großaxt (greataxe)", ["O:Great Axe/sm_greataxe.obj", "A:Axes/Two handed Axe.fbx"]],
	["Zweihandhammer (maul)", ["A:Hammers/Two-Handed Hammer.fbx"]],
	["Hellebarde (halberd)", ["O:Halberd/sm_halberd.obj", "A:Axes/Halberd.fbx", "A:Axes/Bardiche.fbx", "A:Spears/Polearm.fbx"]],
	["Magierstab (staff)", ["O:Staff Magic/sm_staff_magic.obj", "V:mdvl_weapons_staff_01.glb"]],
	["Langbogen (longbow)", ["A:Bows/Long Bow.fbx", "A:Bows/Recurve Bow.fbx", "O:Bow/sm_bow.obj"]],
	["Leichte Armbrust (light_crossbow)", ["O:CrossBow/sm_crossbow.obj", "A:Bows/Crossbow.fbx", "V:mdvl_weapons_crossbow_01.glb"]],
	["Turmschild (tower_shield)", ["O:ShieldKite/sm_shield_kite.obj", "P:Iron_Long_shield.fbx", "P:Lionheart_Long_shield.fbx", "P:kite_Shield.fbx"]],
	["Foliant (tome)", ["A:Magic/Spellbook.fbx", "A:Magic/Open Spellbook.fbx"]],
	["Fackel (torch)", ["Q:Torch_Metal.gltf"]],
]
const PAKET_458 := {"O": "exported_meshes", "A": "Low Poly Medieval Weapons", "V": "Weapons_Shields/glTF", "P": "Shields", "Q": "fantasy-props-megakit/Exports/glTF"}
const PAKET_NAME_458 := {"O": "Omie", "A": "Anker", "V": "Avramania", "P": "PolyMech", "Q": "Quaternius Props"}
const SEITE_458 := 7.0     # Sekunden je Gegenstand (eine Drehung in 6 s)

func _film_458() -> void:
	var alle := []
	for e in [".obj", ".fbx", ".glb", ".gltf"]: alle.append_array(B.dateien([kauf, cc0], e))
	var n := 0
	for i in KANDIDATEN_458.size():
		var k: Array = KANDIDATEN_458[i]
		var pfade := []
		for c in k[1]:
			var teil: PackedStringArray = String(c).split(":", true, 1)
			var ende: String = PAKET_458[teil[0]] + "/" + teil[1]
			var p := _erste(alle.filter(func(q): return String(q).ends_with(ende)))
			print("FILM 458 %s: %s %s" % [k[0], c, "da" if p != "" else "FEHLT"])
			if p != "": pfade.append([teil[0], p])
		if pfade.is_empty(): continue
		ablauf.append([n * SEITE_458, _seite_458.bind(k[0], pfade, n)])
		n += 1
	if n == 0: print("FILM FEHLER keine Kandidaten (KAUF/CC0)"); get_tree().quit(1); return
	ablauf.append([n * SEITE_458, func(): get_tree().quit()])


func _seite_458(name: String, pfade: Array, nr: int) -> void:
	_neuer_teil("458.3 · Bestand: %s · Kandidaten drehend, im Spielbild" % name)
	for i in mini(pfade.size(), 6):
		var p: String = pfade[i][1]
		var d := _ding_458(p)
		if d == null: print("FILM FEHLER laden ", p); continue
		var x := 400.0 + nr * 40.0 + i * 6.0
		var halter := Node3D.new()
		knoten.add_child(halter)
		halter.position = Vector3(x, 0, 0)
		halter.add_child(d)
		halter.set_meta("dreh", 1.0 / 6.0)
		# Größe messen, Zentimeter-Dateien auf Meter; längste Seite senkrecht (Klinge, Schaft stehen); mittig auf die Drehachse
		var box := _box_458(d)
		var lang := maxf(box.size.x, maxf(box.size.y, box.size.z))
		if lang > 20.0:
			d.scale = Vector3.ONE * 0.01
			box = _box_458(d)
			lang = maxf(box.size.x, maxf(box.size.y, box.size.z))
		if box.size.x >= box.size.y and box.size.x >= box.size.z: d.rotation_degrees.z = 90
		elif box.size.z > box.size.y: d.rotation_degrees.x = 90
		box = _box_458(d)
		d.position -= box.get_center() - halter.global_position
		var feld := _feld(_raster(i), maxf(0.4, lang * 1.15))
		var cam: Camera3D = feld[0]
		cam.rotation_degrees.x = -12.0
		cam.position = Vector3(x, 0, 0) + cam.basis.z * (lang * 2.0 + 2.0)
		var paket: String = PAKET_NAME_458[pfade[i][0]]
		_text(feld[1], "%s · %s" % [paket, p.get_file().get_basename()], Vector2(12, 8), 26)
		_text(feld[1], "Länge %s m" % _m(lang), Vector2(12, 44), 22, GOLD)
		print("FILM 458 %s: %s %s, Länge %.2f m" % [name, paket, p.get_file(), lang])


func _box_458(n: Node3D) -> AABB:
	var b := AABB()
	var erst := true
	for m in n.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		var a := mi.global_transform * mi.get_aabb()
		if erst:
			b = a
			erst = false
		else: b = b.merge(a)
	return b


# OBJ (Omie) und FBX (Anker, PolyMech) zur Laufzeit; glb/gltf über die Bibliothek
func _ding_458(p: String) -> Node3D:
	var n: Node3D = null
	var e := p.get_extension().to_lower()
	if e == "glb" or e == "gltf": return B.lade(p, p.get_base_dir())
	if e == "fbx":
		var d := FBXDocument.new()
		var s := FBXState.new()
		if d.append_from_file(p, s) == OK: n = d.generate_scene(s)
	elif e == "obj": n = _obj_458(p)
	return B.spielbild(n) if n else null


# OBJ mit MTL: Ecken, Flächen (Vielecke als Fächer), Grundfarbe Kd und Bild map_Kd (TGA, PNG) je Material
func _obj_458(p: String) -> Node3D:
	var f := FileAccess.open(p, FileAccess.READ)
	if f == null: return null
	var v := PackedVector3Array()
	var vt := PackedVector2Array()
	var vn := PackedVector3Array()
	var mats := {}
	var teile := {}   # Material -> SurfaceTool
	var jetzt := ""
	while not f.eof_reached():
		var z := f.get_line().strip_edges()
		var a := z.split(" ", false)
		if a.is_empty(): continue
		match a[0]:
			"v": v.append(Vector3(a[1].to_float(), a[2].to_float(), a[3].to_float()))
			"vt": vt.append(Vector2(a[1].to_float(), 1.0 - a[2].to_float()))
			"vn": vn.append(Vector3(a[1].to_float(), a[2].to_float(), a[3].to_float()))
			"mtllib": mats.merge(_mtl_458(p.get_base_dir().path_join(z.substr(7).strip_edges())))
			"usemtl": jetzt = z.substr(7).strip_edges()
			"f":
				if not teile.has(jetzt):
					var neu := SurfaceTool.new()
					neu.begin(Mesh.PRIMITIVE_TRIANGLES)
					teile[jetzt] = neu
				var st: SurfaceTool = teile[jetzt]
				var ecken := a.slice(1)
				for t in range(1, ecken.size() - 1):
					for ec in [ecken[0], ecken[t + 1], ecken[t]]:
						var ix := String(ec).split("/")
						if ix.size() > 1 and ix[1] != "" and vt.size() > 0: st.set_uv(vt[ix[1].to_int() - 1])
						if ix.size() > 2 and ix[2] != "" and vn.size() > 0: st.set_normal(vn[ix[2].to_int() - 1])
						st.add_vertex(v[ix[0].to_int() - 1])
	var am := ArrayMesh.new()
	for k in teile:
		var st: SurfaceTool = teile[k]
		if vn.is_empty(): st.generate_normals()
		st.commit(am)
		am.surface_set_material(am.get_surface_count() - 1, mats.get(k, StandardMaterial3D.new()))
	var mi := MeshInstance3D.new()
	mi.mesh = am
	var n := Node3D.new()
	n.add_child(mi)
	return n


func _mtl_458(p: String) -> Dictionary:
	var aus := {}
	var f := FileAccess.open(p, FileAccess.READ)
	if f == null: return aus
	var m: StandardMaterial3D = null
	while not f.eof_reached():
		var z := f.get_line().strip_edges()
		if z.begins_with("newmtl "):
			m = StandardMaterial3D.new()
			aus[z.substr(7).strip_edges()] = m
		elif m and z.begins_with("Kd "):
			var a := z.split(" ", false)
			m.albedo_color = Color(a[1].to_float(), a[2].to_float(), a[3].to_float())
		elif m and z.begins_with("map_Kd "):
			var bild := p.get_base_dir().path_join(z.substr(7).strip_edges().replace("\\", "/"))
			if not FileAccess.file_exists(bild):   # Omie: Bilder oft in einem anderen Ordner des Pakets
				var name := bild.get_file().get_basename().to_lower()
				var w := p.get_base_dir().get_base_dir().get_base_dir()
				for e in [".tga", ".png", ".jpg"]:
					var l := B.dateien([w], e).filter(func(q): return String(q).get_file().get_basename().to_lower() == name)
					if not l.is_empty():
						bild = l[0]
						break
			var im := Image.load_from_file(bild) if FileAccess.file_exists(bild) else null
			if im:
				m.albedo_texture = ImageTexture.create_from_image(im)
				m.albedo_color = Color.WHITE
	return aus
