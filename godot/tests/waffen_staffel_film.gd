# 458.3 Waffenformen gestaffelt (Chef 01.11., 19:5x, Archiv 458.3: „Staffel nach Stufe, Seltenheit über Material und Zeichen“; Vorlage
# „als Tabelle je Art und Film Stufe 1–20“): alle Waffenarten mit Formen aus der Datendatei (tools/gegenstaende/gegenstaende.json, Spalte
# formen) in einem Raster 3 × 6, drehend. Teil 1 zählt Stufe 1 bis 20 hoch, jede Art zeigt die Form, die ab dieser Stufe gilt (gewöhnlich).
# Teil 2 und 3: dieselben Formen auf Stufe 1 und Stufe 20 durch alle sechs Seltenheiten (Material und Zeichen als Bild je Klasse,
# tools/blender348/waffen_staffel.py; Glimmen ab „sehr selten“). Gezeichnet wie im Kampf (Toon, Tusche nach Licht und Sonne mit Schatten
# aus signatur.gd, 457.2), wie tests/waffen_film.gd.
# Nur als Probelauf (389) mit --write-movie: STAFFEL=<ordner> KATALOG=<gegenstaende.json> xvfb-run godot --path godot
# --resolution 1080x2340 --write-movie <datei>.avi --fixed-fps 30 -s res://tests/waffen_staffel_film.gd
# Ohne --write-movie und mit PRUEFEN=1: lädt alles, prüft Materialien und Bilder, zeichnet nichts (kein Probelauf, 390a).
extends SceneTree

const Figur = preload("res://kampf/figur.gd")
const Signatur = preload("res://kampf/signatur.gd")
const SPALTEN := 3
const ZEILEN := 6
const BREIT := 1.3
const HOCH := 1.22
const GROESSE := 0.84
const DREH_S := 6.0
const STUFE_S := 1.0
const SELTEN_S := 2.0
const GOLD := Color(0.86, 0.74, 0.45)
const SELTENHEITEN := ["COMMON", "UNCOMMON", "RARE", "VERY_RARE", "EPIC", "DIVINE"]
const SELTEN_DE := {"COMMON": "gewöhnlich", "UNCOMMON": "ungewöhnlich", "RARE": "selten", "VERY_RARE": "sehr selten",
	"EPIC": "episch", "DIVINE": "göttlich"}
# Farben der Seltenheit wie Rarity in Gear.kt
const SELTEN_FARBE := {"COMMON": Color("9A9AA6"), "UNCOMMON": Color("3FB24F"), "RARE": Color("3C7DE0"), "VERY_RARE": Color("9A4FE0"),
	"EPIC": Color("E8841A"), "DIVINE": Color("E8C030")}

var ordner := ""
var staffel: Dictionary = {}
var bilder: Dictionary = {}
var arten: Array = []          # [{id, name, formen: [{ab, netz}]}]
var formen: Dictionary = {}    # netz -> {knoten, flaechen: [[MeshInstance3D, i, material, klasse]]}
var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _bild(netz: String, mat: String, sel: String) -> Texture2D:
	var k := "%s__%s__%s" % [netz, mat, sel]
	if not bilder.has(k):
		var img := Image.load_from_file(ordner.path_join(k + ".png"))
		if img == null:
			print("FEHLT Bild ", k)
			fehler += 1
			img = Image.create(4, 4, false, Image.FORMAT_RGB8)
			img.fill(Color(1, 0, 1))
		img.generate_mipmaps()
		bilder[k] = ImageTexture.create_from_image(img)
	return bilder[k]


func _sammle(n: Node, liste: Array) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var m := mi.mesh.surface_get_material(i)
			var name := m.resource_name if m else ""
			if name == "":
				print("FEHLT Materialname ", mi.name, " ", i)
				fehler += 1
			var sm := ShaderMaterial.new()
			sm.shader = Figur.toon_mark()
			sm.set_shader_parameter("fill", 0.42)
			mi.set_surface_override_material(i, sm)
			liste.append([mi, i, name, name.get_slice(".", 0), sm])
	for c in n.get_children():
		_sammle(c, liste)


func _faerbe(netz: String, sel: String) -> void:
	var gl: Dictionary = staffel.glimmen.get(sel, {})
	for f in formen[netz].flaechen:
		var sm: ShaderMaterial = f[4]
		sm.set_shader_parameter("tex", _bild(netz, String(f[2]), sel))
		var st := float(gl.get("klassen", {}).get(String(f[3]), 0.0)) if not gl.is_empty() else 0.0
		sm.set_shader_parameter("glow", st)
		if st > 0.0:
			var c: Array = gl.farbe
			sm.set_shader_parameter("glow_col", Color(c[0], c[1], c[2]))


func _form_bei(art: Dictionary, stufe: int) -> Dictionary:
	var w: Dictionary = art.formen[0]
	for f in art.formen:
		if int(f.ab) <= stufe:
			w = f
	return w


func _lesbar(netz: String) -> String:
	var e: Dictionary = staffel.formen.get(netz, {})
	var n := String(e.get("datei", netz)).get_file().get_basename()
	n = n.trim_prefix("sm_").replace("mdvl_weapons_", "").trim_suffix("_01").replace("_", " ")
	return "%s · %s" % [String(e.get("paket", "?")), n]


func _text(t: String, groesse: int, farbe: Color, wo: Vector3, eltern: Node) -> Label3D:
	var l := Label3D.new()
	l.text = t
	l.font_size = groesse
	l.pixel_size = 0.0021
	l.modulate = farbe
	l.outline_size = 0
	l.position = wo
	eltern.add_child(l)
	return l


func _run() -> void:
	ordner = OS.get_environment("STAFFEL")
	var kat: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("KATALOG")))
	staffel = JSON.parse_string(FileAccess.get_file_as_string(ordner.path_join("staffel.json")))
	for g in kat.gegenstaende:
		if g.get("formen") != null:
			arten.append({"id": g.id, "name": g.name.de, "formen": g.formen})
	var welt := Node3D.new()
	root.add_child(welt)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.13, 0.12, 0.11)   # Probelauf 1: dunkle Hölzer auf 0,05 unsichtbar
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.55, 0.52, 0.48)
	env.environment.ambient_light_energy = 0.6
	welt.add_child(env)
	var sonne := DirectionalLight3D.new()
	sonne.rotation_degrees = Vector3(-50, 35, 0)
	sonne.light_energy = 1.2
	welt.add_child(sonne)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = ZEILEN * HOCH + 0.9
	cam.position = Vector3(0, 0.25, 6.0)
	welt.add_child(cam)
	cam.look_at_from_position(cam.position, Vector3(0, 0.25, 0))
	cam.current = true
	# Zellen: Dreher je Art, darin alle Formen der Art, sichtbar nur die gültige
	var zellen: Array = []
	for j in arten.size():
		var art: Dictionary = arten[j]
		var d := Node3D.new()
		d.position = Vector3((j % SPALTEN - (SPALTEN - 1) / 2.0) * BREIT, ((ZEILEN - 1) / 2.0 - j / SPALTEN) * HOCH + 0.1, 0)
		welt.add_child(d)
		for f in art.formen:
			var netz := String(f.netz)
			if formen.has(netz):
				continue
			var doc := GLTFDocument.new()
			var st := GLTFState.new()
			if doc.append_from_file(ordner.path_join(netz + ".glb"), st) != OK:
				print("FEHLT Form ", netz)
				fehler += 1
				continue
			var w := doc.generate_scene(st) as Node3D
			w.scale = Vector3.ONE * GROESSE
			var liste: Array = []
			_sammle(w, liste)
			formen[netz] = {"knoten": w, "flaechen": liste, "zelle": d}
			d.add_child(w)
			w.visible = false
		var name := _text(String(art.name), 22, GOLD, d.position + Vector3(0, -0.5, 0.4), welt)
		var form := _text("", 16, GOLD.darkened(0.15), d.position + Vector3(0, -0.6, 0.4), welt)
		# Probelauf 1: im Gleichtakt stand das ganze Raster zugleich auf der Kante; je Zelle versetzt (goldener Winkel)
		zellen.append({"dreher": d, "name": name, "form": form, "phase": fmod(j * 0.382, 1.0)})
	for netz in formen:
		for sel in SELTENHEITEN:
			_faerbe(netz, sel)
	print("Staffel-Film geladen: %d Arten, %d Formen, %d Bilder, %d Fehler" % [arten.size(), formen.size(), bilder.size(), fehler])
	if OS.get_environment("PRUEFEN") != "":
		quit(1 if fehler > 0 else 0)
		return
	Signatur.einrichten(welt, cam, Vector3.ZERO, env.environment, sonne, true)
	await process_frame
	if not Signatur.wache(welt, self, "Staffel-Film"):
		return
	var kopf := _text("", 40, GOLD, Vector3(0, ZEILEN / 2.0 * HOCH + 0.42, 0.4), welt)
	var unter := _text("", 26, GOLD, Vector3(0, ZEILEN / 2.0 * HOCH + 0.2, 0.4), welt)
	_text("458.3 · Waffenformen nach Stufe und Seltenheit", 18, GOLD.darkened(0.3), Vector3(0, -ZEILEN / 2.0 * HOCH - 0.05, 0.4), welt)
	var abschnitte: Array = []
	for s in range(1, 21):
		abschnitte.append({"stufe": s, "sel": "COMMON", "s": STUFE_S, "teil": "Stufe %d" % s})
	for s in [1, 20]:
		for sel in SELTENHEITEN:
			abschnitte.append({"stufe": s, "sel": sel, "s": SELTEN_S, "teil": "Stufe %d · Seltenheit" % s})
	var k := 0
	for a in abschnitte:
		kopf.text = String(a.teil)
		unter.text = SELTEN_DE[a.sel]
		unter.modulate = SELTEN_FARBE[a.sel]
		for j in arten.size():
			var f := _form_bei(arten[j], int(a.stufe))
			for g in arten[j].formen:
				if formen.has(String(g.netz)):
					formen[String(g.netz)].knoten.visible = String(g.netz) == String(f.netz)
			if formen.has(String(f.netz)):
				_faerbe(String(f.netz), String(a.sel))
			zellen[j].form.text = "%s · ab %d" % [_lesbar(String(f.netz)), int(f.ab)]
		for _b in int(float(a.s) * 30.0):
			for z in zellen:
				z.dreher.rotation.y = TAU * fmod(k / (DREH_S * 30.0) + z.phase, 1.0)
			k += 1
			await process_frame
	print("Staffel-Film: %d Arten, %d Formen, %d Abschnitte, %d Bilder, %d Fehler" % [arten.size(), formen.size(), abschnitte.size(), k, fehler])
	quit(0)
