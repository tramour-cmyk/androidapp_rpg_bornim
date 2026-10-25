class_name Gebiet
extends Node3D
# 348.6: eine Gebietskarte aus Blender (daten/<karte>.bin = glTF in Metern, tools/blender348/v3/dorf.py) mit dem Look
# der Probe Build 11: toon.gdshader auf allem, Boden mit Maske (boden.gdshader), Wasser, Glas leuchtet nachts;
# Halme, Korn, Schmetterlinge, Rauch, Gluehwuermchen aus <karte>-info.json („lichter“).

static var texcache := {}
static var toon: Shader

var karte: Karte
var info: Dictionary
var laub: Array[ShaderMaterial] = []   # Durchsicht um den Helden (toon.gdshader), beide Durchgaenge
var glas: Array[ShaderMaterial] = []
var wasser: ShaderMaterial
var boden: ShaderMaterial
var halme: ShaderMaterial
var korn_mat: ShaderMaterial
var insel_liste := PackedVector4Array()
var lampen: Array[OmniLight3D] = []
var falter: Array = []
var rauch: Array[CPUParticles3D] = []
var gluehen: Array[CPUParticles3D] = []
var zeit := 0.0
var gruppen := {}                     # Durchsicht als Ganzes: Name -> {mats, a, ziel} (dorf.py „Gruppe_…“)
var held: Node3D                      # spiel.gd: wessen Oberkoerper frei bleibt, und von wo man blickt
var kamera: Camera3D

func _init(k: Karte) -> void:
	karte = k
	Licht.nach_licht.clear()
	name = "Gebiet_" + k.id

func _ready() -> void:
	var stamm := "res://daten/" + datei(karte.id)
	info = JSON.parse_string(FileAccess.get_file_as_string(stamm + "-info.json"))
	var netz := lade_glb(stamm + ".bin")
	add_child(netz)
	male(netz, self)
	baue_gruppen(netz)
	var wiese := MeshInstance3D.new()          # Waldboden ausserhalb der Karte: Bodenmaske am Rand fortgesetzt
	var pm := PlaneMesh.new()
	pm.size = Vector2(160, 160)
	wiese.mesh = pm
	wiese.material_override = boden
	wiese.layers = BODEN_SCHICHT
	wiese.position = Vector3(karte.breite * Karte.TS / 2, -0.4, karte.hoehe * Karte.TS / 2)   # unter dem Flussbett (-0,34): auf -0,03 deckte sie das Wasser (-0,1) zu
	add_child(wiese)
	baue_lampen()
	baue_leben()

# Blender-Datei je Karte; weitere Gebietskarten kommen nach der Bestandsliste (348.8)
static func datei(id: String) -> String:
	return {"village": "dorf"}.get(id, id)

static func lade_glb(p: String) -> Node3D:
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", state)
	if err != OK: push_error("glTF %s: %d" % [p, err])
	return doc.generate_scene(state) as Node3D

static func finde(n: Node, cls: String) -> Node:
	if n.get_class() == cls: return n
	for c in n.get_children():
		var r := finde(c, cls)
		if r: return r
	return null

static func bild(name: String) -> ImageTexture:
	if texcache.has(name): return texcache[name]
	var img := Image.new()
	img.load_png_from_buffer(FileAccess.get_file_as_bytes("res://daten/%s.bild" % name))
	if not img.has_mipmaps(): img.generate_mipmaps()
	var t := ImageTexture.create_from_image(img)
	texcache[name] = t
	return t

static func mip(t: Texture2D) -> Texture2D:
	# Bilder aus dem glTF bekommen Mipmaps (sonst flimmern Muster in der Ferne)
	if t == null: return null
	if texcache.has(t): return texcache[t]
	var img := t.get_image()
	if img == null: return t
	if img.is_compressed(): img.decompress()
	if not img.has_mipmaps(): img.generate_mipmaps()
	var r := ImageTexture.create_from_image(img)
	texcache[t] = r
	return r

# Schablone (Stencil) fuer die Tusche wie Probe Build 12: 1 = Blueten (ohne Linie, sonst schwarze Kaefer) und Buesche (eigene Linie), 2 = Held (feinere Linie)
static var markiert := {}
static func toon_mark(k: int) -> Shader:
	if toon == null: toon = load("res://shader/toon.gdshader")
	if not markiert.has(k):
		var sh := Shader.new()
		sh.code = toon.code.replace("render_mode cull_disabled, specular_disabled;", "render_mode cull_disabled, specular_disabled;\nstencil_mode write, compare_always, %d;" % k)
		markiert[k] = sh
	return markiert[k]

# jedes Netz bekommt den Look der Probe; g (Gebiet) merkt sich Boden, Wasser, Glas und die Dorfmaterialien;
# mark = Schablone fuer alles (2 Held), sonst 1 fuer Blueten; aus sammelt die Materialien (Held: Aufhellung im Schatten)
static func male(n: Node, g: Gebiet = null, mark := 0, aus: Array = []) -> void:
	if toon == null: toon = load("res://shader/toon.gdshader")
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var nm := String(mi.name)
		for i in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(i)
			var m := ShaderMaterial.new()
			if g and nm.contains("Boden"):
				m.shader = load("res://shader/boden.gdshader")
				m.set_shader_parameter("maske", bild("boden-maske"))
				for k in ["gras", "erde", "pflaster"]: m.set_shader_parameter(k, bild(k))
				m.set_shader_parameter("karte", Vector2(g.karte.breite, g.karte.hoehe) * Karte.TS)
				g.boden = m
				mi.layers = BODEN_SCHICHT
			elif g and nm.contains("Wasser"):
				m.shader = load("res://shader/wasser.gdshader")
				m.set_shader_parameter("maske", bild("boden-maske"))   # Alpha: Wassertiefe (dorf.py)
				m.set_shader_parameter("karte", Vector2(g.karte.breite, g.karte.hoehe) * Karte.TS)
				g.wasser = m
			else:
				var rn := String(src.resource_name) if src else ""
				var busch := rn.begins_with("laub_busch")   # Tusche im Zeichner (toon kontur), nicht als Bildschirmlinie
				var nadel := rn.begins_with("laub_nadel")   # Runde 10 (Helfer an Lauf 35: Fichten als schwarzer Scherenschnitt): feinere Linie wie der Held
				# Runde 11 (Chefrunde 25.10., 11:48: Tusche nach dem Licht fuer alle Objekte, auch Baeume): Laubkronen wie die Buesche
				var krone := rn.begins_with("laub") and not busch and not nadel
				m.shader = toon_mark(mark) if mark else (toon_mark(1) if rn.begins_with("bluete") or busch or krone else (toon_mark(2) if nadel else toon))
				if busch or krone:
					m.set_shader_parameter("kontur", 1.0)
					m.set_shader_parameter("licht_dir", Licht.richtung())
					Licht.nach_licht.append(m)
				aus.append(m)
				var tex: Texture2D = null
				if src is BaseMaterial3D: tex = (src as BaseMaterial3D).albedo_texture
				m.set_shader_parameter("tex", mip(tex) if tex else bild("weiss"))
				if src and String(src.resource_name).begins_with("laub"):
					m.set_shader_parameter("sway", 1.0)
					if g and not busch: g.durchsicht(m, 2 if nadel else (1 if krone else 0))   # Busch kniehoch: keine Durchsicht (ersetzte sonst den Shader mit Schablone)
				elif g and src and String(src.resource_name).begins_with("rinde"):
					m.set_shader_parameter("cut_ab", 1.4)
					g.durchsicht(m)
				if g and nm.contains("Glas"): g.glas.append(m)
			mi.set_surface_override_material(i, m)
	for c in n.get_children(): male(c, g, mark, aus)

func nacht(k: float) -> void:
	# 348.9: nachts wie alt geeicht (Laternen, Fenster, Lichtinseln am Boden kleiner; alt p90 46)
	for o in lampen: o.light_energy = 1.4 * k   # 348.6: alt nur ein kleiner Hof um die Laterne (Helfer: neu 4-mal zu hell, zu weit)
	for m in glas: m.set_shader_parameter("glow", 0.5 * k)
	if wasser: wasser.set_shader_parameter("night", k)
	if boden: boden.set_shader_parameter("night", k)
	if halme: halme.set_shader_parameter("night", k)
	if korn_mat: korn_mat.set_shader_parameter("night", k)
	for f in falter: (f["n"] as Node3D).visible = k < 0.5
	for g in gluehen: g.emitting = k > 0.6
	for r in rauch: r.color = Color(0.70, 0.68, 0.65, 0.55).lerp(Color(0.31, 0.29, 0.28, 0.5), k)

# Laub vor dem Helden, nach der Tusche (Prioritaet 1, 2 wie Rauch), sonst Tuschering an der Lochkante: erst nur Tiefe (vorderste
# Lage gewinnt), dann halbdurchsichtig nur diese Lage; sonst malt eine innere, verschattete Kugel oder der Stamm dunkle Keile.
# Laub und Rinde sind geschlossen: ohne Rueckseiten (nicht ins Innere angeschnittener Kronen sehen).
static var durch_shader := {}   # [Schablone, cull] -> drei Durchgaenge
# mark: Schablone wie toon_mark (2 = feinere Linie, Fichten), sonst ersetzte die Durchsicht sie
static func durch_shaders(mark: int, cull: String) -> Array:
	var key := [mark, cull]
	if not durch_shader.has(key):
		var basis := toon_mark(mark) if mark else toon
		var liste: Array[Shader] = []
		# DURCH malt jeden Bildpunkt nur einmal (Schablone 3), sonst dunkeln aufeinanderliegende Teile doppelt ab (Helfer: Vordach, Fensterrahmen)
		for art in [cull + ",", cull + ", depth_draw_always, blend_mix, unshaded,\n#define DURCH\n#define TIEFE\n", cull + ", depth_draw_never, blend_mix,\n#define DURCH\n#define EINMAL\n"]:
			var sh := Shader.new()
			var code := basis.code
			if art.contains("DURCH"): code = toon.code   # ohne die Schablone der Zeichnung (toon_mark), die gilt nur deckend
			sh.code = code.replace("render_mode cull_disabled,", "render_mode " + art)
			if art.contains("EINMAL"): sh.code = sh.code.replace("specular_disabled;", "specular_disabled;\nstencil_mode read, write, compare_not_equal, 3;")
			liste.append(sh)
		durch_shader[key] = liste
	return durch_shader[key]

# die beiden Durchgaenge nach der Tusche (TIEFE, DURCH) an m haengen; gibt den letzten zurueck
static func kette(m: ShaderMaterial, sh: Array) -> ShaderMaterial:
	var vor := m
	for i in [1, 2]:
		var d := ShaderMaterial.new()
		d.shader = sh[i]
		d.render_priority = i
		for k in ["tex", "sway", "cut_ab", "kontur", "licht_dir", "glow", "glow_col"]:
			if m.get_shader_parameter(k) != null: d.set_shader_parameter(k, m.get_shader_parameter(k))
		if m.get_shader_parameter("kontur"): Licht.nach_licht.append(d)
		vor.next_pass = d
		vor = d
	return vor

func durchsicht(m: ShaderMaterial, mark := 0) -> void:
	var sh := durch_shaders(mark, "cull_back")
	m.shader = sh[0]
	kette(m, sh)
	var x := m
	while x:
		x.set_shader_parameter("cut_on", 1.0)
		laub.append(x)
		x = x.next_pass as ShaderMaterial

func nah(_an: bool, held_pos: Vector3) -> void:
	for m in laub: m.set_shader_parameter("cut_pos", held_pos + Vector3(0, 0.9, 0))

# ---------------------------------------------------------------- Durchsicht als Ganzes (DESIGN-STIL „Karte und Raeume“, alt WorldScreen.hides)
# Haus, Stand, Brunnen, Laterne, Schild: verdeckt das Ding den Oberkoerper des Helden (Strahlen von Huefte bis Kopf zur Kamera),
# wird es als Ganzes halb durchsichtig, weich in 0,3 s; was nur bis zur Huefte reicht (Bank, Theke, Fass), bleibt deckend.
const DURCH_SCHICHT := 1 << 19         # nur fuer die Strahlen; der Held geht nach Karte.begehbar, nicht nach Koerpern
const DURCH_A := 0.5                   # alt: zusammen halb (Test 0.1.576: 0,2 zu stark; 27e.1: 35 % zu schwach)

func baue_gruppen(n: Node) -> void:
	if n is MeshInstance3D and String(n.name).begins_with("Gruppe_"):
		var mi := n as MeshInstance3D
		var key := String(mi.name).trim_suffix("_Glas")
		if not gruppen.has(key): gruppen[key] = {"mats": [], "a": 1.0, "ziel": 1.0}
		for i in mi.mesh.get_surface_count():
			var m := mi.get_surface_override_material(i) as ShaderMaterial
			# eigene Kette (Laub am Haus: Efeu, Blumenkasten) bleibt; sonst kommt sie erst beim Ausblenden dazu
			gruppen[key]["mats"].append({"m": m, "eigen": m.next_pass != null, "kette": null})
		if not String(mi.name).ends_with("_Glas"):
			var body := StaticBody3D.new()
			body.collision_layer = DURCH_SCHICHT
			body.collision_mask = 0
			body.set_meta("gruppe", key)
			var cs := CollisionShape3D.new()
			cs.shape = mi.mesh.create_trimesh_shape()
			body.add_child(cs)
			mi.add_child(body)
	for c in n.get_children(): baue_gruppen(c)

func _physics_process(_dt: float) -> void:
	if held == null or kamera == null or gruppen.is_empty(): return
	var raum := get_world_3d().direct_space_state
	var zur := kamera.global_basis.z          # zur Kamera (sie blickt nach -z)
	var quer := kamera.global_basis.x
	var treffer := {}
	for h in [1.05, 1.4, 1.7]:                # Huefte bis Kopf (Held 1,8 m)
		for s in [-0.12, 0.0, 0.12]:              # Rumpfbreite; 0,2 traf das Standdach neben dem Umhang (Helfer an drehen)
			var von: Vector3 = held.global_position + Vector3(0, h, 0) + quer * s
			var q := PhysicsRayQueryParameters3D.create(von, von + zur * 40.0, DURCH_SCHICHT)
			var aus: Array[RID] = []
			for k in 3:                       # bis drei Dinge hintereinander
				q.exclude = aus
				var r := raum.intersect_ray(q)
				if r.is_empty(): break
				var gk: String = (r["collider"] as Node).get_meta("gruppe")
				treffer[gk] = treffer.get(gk, 0) + 1
				aus.append(r["rid"])
	# erst ab 4 von 9 Strahlen: ein Pfahl vor dem Helden laesst ihn sichtbar und wird nicht zum grauen Schleier (Helfer an drehen, Laterne)
	for key in gruppen: gruppen[key]["ziel"] = DURCH_A if treffer.get(key, 0) >= 4 else 1.0

func blende_gruppen(dt: float) -> void:
	for key in gruppen:
		var g: Dictionary = gruppen[key]
		var a: float = g["a"]
		var z: float = g["ziel"]
		if a == z: continue
		a = move_toward(a, z, dt / 0.3)
		g["a"] = a
		for e in g["mats"]:
			var m: ShaderMaterial = e["m"]
			if not e["eigen"]:
				if a < 1.0 and m.next_pass == null:
					if e["kette"] == null:             # der deckende Durchgang bleibt (toon kennt „weg“), Schablone auch
						kette(m, durch_shaders(0, "cull_disabled"))
						e["kette"] = m.next_pass
					else: m.next_pass = e["kette"]
				elif a >= 1.0: m.next_pass = null
			var x := m
			while x:
				x.set_shader_parameter("weg", 1.0 if a < 1.0 else 0.0)
				x.set_shader_parameter("durch_a", a)
				x = x.next_pass as ShaderMaterial

# Blender (x, y Norden, z oben) -> Godot (x, y oben, z Sueden)
static func gpos(p: Array) -> Vector3:
	return Vector3(float(p[0]), float(p[2]), -float(p[1]))

const BODEN_SCHICHT := 2     # Boden nur im Licht der Sonne; Laternen und Fenster malen ihn selbst (boden.gdshader, inseln)
func baue_lampen() -> void:
	var inseln := PackedVector4Array()
	for l in info["lichter"]:
		var art: String = l["art"]
		if art != "laterne" and art != "fenster": continue
		var q := gpos(l["pos"])
		if art == "fenster":   # wie MapLight WINDOW: vor dem Haus auf den Boden, Reichweite 1,6 Kacheln, Staerke 0,7
			inseln.append(Vector4(q.x, q.z + 0.5, 1.6 * Karte.TS, 0.7))
			continue
		inseln.append(Vector4(q.x, q.z, float(l.get("reich", 2.6)) * Karte.TS, float(l.get("kraft", 0.95))))   # LAMP (Bruecke 2,4/0,8; Kael 1,2/0,3)
		if l.get("kerze", false): continue   # Kaels Laterne: nur ein kleiner, matter Fleck, kein Laternenlicht
		var o := OmniLight3D.new()
		o.position = q
		o.omni_range = 3.0
		o.light_color = Color(1.0, 0.7, 0.38)
		o.omni_attenuation = 0.8
		o.light_cull_mask = 0xFFFFF & ~BODEN_SCHICHT
		add_child(o)
		lampen.append(o)
	inseln = inseln.slice(0, 64)
	for m in [boden, halme, wasser]:
		if m:
			m.set_shader_parameter("inseln", inseln)
			m.set_shader_parameter("inseln_n", inseln.size())
	insel_liste = inseln

# ---------------------------------------------------------------- Leben (WorldScreen.kt): Gras, Korn, Falter, Rauch, Gluehwuermchen
static func kreuz() -> ArrayMesh:
	# zwei gekreuzte Flaechen, 1 m breit und hoch, Fuss bei y = 0
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for a in [0.0, PI * 0.5]:
		var r := Vector3(cos(a), 0, sin(a)) * 0.5
		var q := [-r, r, r + Vector3.UP, -r + Vector3.UP]
		var uv := [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
		for k in [0, 1, 2, 0, 2, 3]:
			st.set_normal(Vector3.UP); st.set_uv(uv[k]); st.add_vertex(q[k])
	return st.commit()

func baue_leben() -> void:
	var ts := Karte.TS
	var mimg := Image.new()
	mimg.load_png_from_buffer(FileAccess.get_file_as_bytes("res://daten/boden-maske.bild"))
	var rng := RandomNumberGenerator.new(); rng.seed = 348
	var xf: Array[Transform3D] = []; var cu: Array[Color] = []
	var kxf: Array[Transform3D] = []; var kcu: Array[Color] = []
	for r in karte.hoehe:
		for c in karte.breite:
			var t := karte.zeichen(Vector2i(c, r))
			var n := 0
			var korn := t == "c"
			if t == "." or t == "f": n = 9
			elif t == "T": n = 5
			elif korn: n = 36
			for k in n:
				var x := (c + rng.randf()) * ts; var z := (r + rng.randf()) * ts
				if korn:   # Runde 11 (Urteil Chef 12:11: Gestruepwiese): gleichmaessig verteilt (6 x 6 je Kachel, verrueckt), aufrecht, fast gleich hoch
					x = (c + (k % 6 + rng.randf_range(0.15, 0.85)) / 6.0) * ts; z = (r + (k / 6 + rng.randf_range(0.15, 0.85)) / 6.0) * ts
				var px := mimg.get_pixel(clampi(int(x / ts * 16), 0, mimg.get_width() - 1), clampi(int(z / ts * 16), 0, mimg.get_height() - 1))
				if korn:
					if px.r < 0.5: continue   # Runde 6: Feldrand folgt der krummen Ackererde (dorf.py), nicht der Kachel
				elif px.r > 0.3 or px.g > 0.25 or px.a > 0.4: continue   # nicht auf Weg, Pflaster, Ufer und Wasser
				if korn:
					var h := rng.randf_range(0.95, 1.08) * (0.85 if px.r < 0.62 else 1.0)   # am Feldrand niedriger (alt: 0,85)
					var bk := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(0.62, h, 0.62))
					kxf.append(Transform3D(bk, Vector3(x, 0.0, z)))
					var gk := rng.randf_range(0.92, 1.08)
					kcu.append(Color(gk, gk, gk, 1))
					continue
				var s := rng.randf_range(0.16, 0.34)
				var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s, s * rng.randf_range(0.75, 1.2), s))
				xf.append(Transform3D(b, Vector3(x, 0.0, z)))
				var g := rng.randf_range(0.85, 1.2)
				cu.append(Color(0.95 * g, 1.0 * g, 0.85 * g, 1))
	halme = halm_netz(xf, cu, "halme", 0.0)
	korn_mat = halm_netz(kxf, kcu, "korn", 1.0)
	# Schmetterlinge an Blumen und Heu (weiss, gelb, orange, blau)
	var cols := [Color(0.97, 0.96, 0.92), Color(0.97, 0.88, 0.38), Color(0.94, 0.63, 0.25), Color(0.5, 0.72, 0.97)]
	var k := 0
	rng.seed = 349   # eigene Folge: Falter springen nicht, wenn sich das Gras aendert (Runde 6: weisser Falter im Gras)
	for l in info["lichter"]:
		if l["art"] != "blumen" and l["art"] != "heu": continue
		var n := Node3D.new()
		var wm := StandardMaterial3D.new()
		wm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		wm.cull_mode = BaseMaterial3D.CULL_DISABLED
		wm.albedo_color = cols[k % cols.size()]
		var wings: Array = []
		for sgn in [-1, 1]:
			var piv := Node3D.new()
			n.add_child(piv)
			var w := MeshInstance3D.new()
			var qm := QuadMesh.new(); qm.size = Vector2(0.055, 0.045)
			w.mesh = qm; w.material_override = wm
			w.rotation_degrees = Vector3(-90, 0, 0)
			w.position = Vector3(0.03 * sgn, 0, 0)
			piv.add_child(w)
			wings.append([piv, sgn])
		add_child(n)
		falter.append({"n": n, "w": wings, "c": gpos(l["pos"]), "ph": rng.randf() * TAU, "sp": rng.randf_range(0.6, 1.0), "r": rng.randf_range(0.6, 1.4)})
		k += 1
	for l in info["lichter"]:
		var at := gpos(l["pos"])
		if l["art"] == "rauch": rauch.append(baue_rauch(at))
		elif l["art"] == "blumen": gluehen.append(baue_gluehen(at))

func baue_rauch(at: Vector3) -> CPUParticles3D:
	var pr := CPUParticles3D.new()
	pr.amount = 24; pr.lifetime = 6.0; pr.preprocess = 6.0
	pr.direction = Vector3(0, 1, 0); pr.spread = 12.0
	pr.initial_velocity_min = 0.18; pr.initial_velocity_max = 0.3
	pr.gravity = Vector3(0.09, 0.03, 0.04)
	pr.scale_amount_min = 0.5; pr.scale_amount_max = 0.8
	var cv := Curve.new(); cv.add_point(Vector2(0, 0.35)); cv.add_point(Vector2(1, 1.6)); pr.scale_amount_curve = cv
	var gr := Gradient.new(); gr.set_color(0, Color(1, 1, 1, 0)); gr.add_point(0.3, Color(1, 1, 1, 0.4)); gr.set_color(gr.get_point_count() - 1, Color(1, 1, 1, 0))   # Fuss weich: Kaminrand bleibt sichtbar
	pr.color_ramp = gr
	var qm := QuadMesh.new(); qm.size = Vector2(0.45, 0.45)
	qm.material = punkt_mat(false)
	pr.mesh = qm
	pr.position = at + Vector3(0, 0.15, 0)
	add_child(pr)
	return pr

func baue_gluehen(at: Vector3) -> CPUParticles3D:
	var ff := CPUParticles3D.new()
	ff.amount = 7; ff.lifetime = 2.2; ff.emitting = false
	ff.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX; ff.emission_box_extents = Vector3(2.2, 0.4, 2.2)
	ff.gravity = Vector3.ZERO; ff.direction = Vector3(1, 0.3, 0); ff.spread = 180.0
	ff.initial_velocity_min = 0.03; ff.initial_velocity_max = 0.12
	var gr := Gradient.new(); gr.set_color(0, Color(0.97, 1, 0.78, 0)); gr.add_point(0.3, Color(0.97, 1, 0.78, 1)); gr.add_point(0.6, Color(0.88, 0.97, 0.47, 0.9)); gr.set_color(gr.get_point_count() - 1, Color(0.88, 0.97, 0.47, 0))
	ff.color_ramp = gr
	var qm := QuadMesh.new(); qm.size = Vector2(0.07, 0.07)
	qm.material = punkt_mat(true)
	ff.mesh = qm
	ff.position = at + Vector3(0, 0.7, 0)
	add_child(ff)
	return ff

func halm_netz(xf: Array[Transform3D], cu: Array[Color], tex: String, korn: float) -> ShaderMaterial:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = kreuz()
	mm.instance_count = xf.size()
	for i in xf.size():
		mm.set_instance_transform(i, xf[i]); mm.set_instance_custom_data(i, cu[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := ShaderMaterial.new(); m.shader = load("res://shader/halm.gdshader")
	m.set_shader_parameter("tex", bild(tex))
	m.set_shader_parameter("korn", korn)
	m.set_shader_parameter("inseln", insel_liste)
	m.set_shader_parameter("inseln_n", insel_liste.size())
	mmi.material_override = m
	mmi.layers = BODEN_SCHICHT   # Licht der Laternen wie der Boden aus den Inseln
	add_child(mmi)
	return m

static var _punkt: ImageTexture
static func punkt_mat(leuchtet: bool) -> StandardMaterial3D:
	if _punkt == null:
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		for y in 32:
			for x in 32:
				var d := Vector2(x - 15.5, y - 15.5).length() / 16.0
				img.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - d, 0, 1) ** 1.6))
		_punkt = ImageTexture.create_from_image(img)
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if leuchtet: sm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	sm.vertex_color_use_as_albedo = true
	sm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	sm.albedo_texture = _punkt
	sm.render_priority = 1   # nach der Tusche (kamera.gd, Prioritaet 0): sonst liegen Linien dahinter auf dem Rauch
	return sm

func _process(dt: float) -> void:
	zeit += dt
	blende_gruppen(dt)
	for f in falter:
		var n: Node3D = f["n"]
		if not n.visible: continue
		var t: float = zeit * float(f["sp"]) + float(f["ph"])
		var r: float = f["r"]
		var c: Vector3 = f["c"]
		var p := c + Vector3(sin(t * 0.7) * r, 0.45 + 0.25 * sin(t * 2.3) + 0.1 * sin(t * 5.1), sin(t * 1.4) * r * 0.5)
		var v := p - n.position
		n.position = p
		if v.length() > 1e-4: n.rotation.y = atan2(v.x, v.z)
		var flap := sin(zeit * 26.0 + float(f["ph"])) * 1.1
		for w in f["w"]: (w[0] as Node3D).rotation.z = flap * float(w[1])
