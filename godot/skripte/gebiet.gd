class_name Gebiet
extends Node3D
# 348.6: eine Gebietskarte aus Blender (daten/<karte>.bin = glTF in Metern, tools/blender348/v3/dorf.py) mit dem Look
# der Probe Build 11: toon.gdshader auf allem, Boden mit Maske (boden.gdshader), Wasser, Glas leuchtet nachts;
# Halme, Korn, Schmetterlinge, Rauch aus <karte>-info.json („lichter“); Gluehwuermchen aus der Karte wie alt (514, gluehwuermchen.gd).

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
var halm_mmi: MultiMeshInstance3D       # 804: unser Gras, aus, solange das Gras des Kits steht (GrasBausatz)
var kit_gras: Array[MultiMeshInstance3D] = []
var kit_stellen: Array[Vector3] = []
var kit_art := PackedByteArray()
var effekte: DorfEffekte             # 814 Effekte Szene 1 (Kaminrauch, Fackeln, Staub, Fahne, Wind, Federn), nach DorfEffekte.an
var bereit := false                   # 814: aufgebaut (gras_neu darf die Effekte schalten)
var insel_ohne := PackedVector4Array()   # 814: Lichtinseln ohne die der Effekte (Fackel der Schenke)

# 804: Gras und Blumen des Kits an den Stellen unseres Grases, unser Gras dann aus; nach GrasBausatz.an (Grafikstufe 698, Testmenue)
func gras_neu() -> void:
	if GrasBausatz.aktiv() and kit_gras.is_empty() and not kit_stellen.is_empty():
		kit_gras = GrasBausatz.baue(self, kit_stellen, kit_art)
	for m in kit_gras: m.visible = GrasBausatz.an
	if halm_mmi: halm_mmi.visible = kit_gras.is_empty() or not GrasBausatz.an
	if held and GrasBausatz.an and not kit_gras.is_empty(): GrasBausatz.schieber(held)
	# 814: bis zum Ende des Umzugs schaltet „Gras“ im Testmenue auch die Effekte der Szene 1 (Bilder/s mit und ohne Pakete);
	# spiel.gd und testmodus.gd aendert bis dahin nur der Umzug (LISTE-UMZUG-BRS 2.5), danach ein eigener Schalter
	DorfEffekte.an = GrasBausatz.an
	if bereit: effekte_neu()
var insel_liste := PackedVector4Array()
var lampen: Array[OmniLight3D] = []
var raumlicht: Raumlicht   # 399.5 Grundriss
var falter: Array = []
var rauch: Array[CPUParticles3D] = []
var gluehwuermchen: Gluehwuermchen   # 514 wie alt (Fireflies) auf Wiesen, am Wasser, am Waldrand, ueber Feldern
var zeit := 0.0
var gruppen := {}                     # Durchsicht als Ganzes: Name -> {mats, a, ziel} (dorf.py „Gruppe_…“)
var held: Node3D                      # spiel.gd: wessen Oberkoerper frei bleibt, und von wo man blickt
var kamera: Camera3D
var kraut_netz: MeshInstance3D        # 490 Vorlage des Heilkrauts (dorf.py „Kraut_Vorlage“), je Kraut eine Kopie
var kraeuter := {}                    # Vector2i -> MeshInstance3D
var feuer: Array = []                 # 490 Lagerfeuer: {licht, flammen, rauch, basis}
var glut: Array[ShaderMaterial] = []  # 490 Glut im Feuer

func _init(k: Karte) -> void:
	karte = k
	Licht.nach_licht.clear()
	mip_aufraeumen()
	name = "Gebiet_" + k.id

# 680 (Chef 08.11., 16:16: Wald -> Dorf -> Schenke immer zaeher, dann Absturz): die Vorlage des Heilkrauts haengt nicht im Baum und
# ging beim Ortswechsel nicht mit; sie hielt ihr Netz samt Bildern der ganzen Karte fest (sprung_680: je Runde Wald, Dorf, Schenke
# rund 100 MB mehr Speicher). Jetzt mit dem Gebiet frei
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and kraut_netz and is_instance_valid(kraut_netz) and kraut_netz.get_parent() == null:
		kraut_netz.free()

func _ready() -> void:
	var stamm := "res://daten/" + datei(karte.id)
	info = JSON.parse_string(FileAccess.get_file_as_string(stamm + "-info.json"))
	var netz := lade_glb(stamm + ".bin")
	var vorlage := netz.find_child("Kraut_Vorlage", true, false)   # 490: nicht auf der Karte, nur als Vorlage
	if vorlage:
		vorlage.get_parent().remove_child(vorlage)
		kraut_netz = vorlage as MeshInstance3D
	add_child(netz)
	male(netz, self)
	if kraut_netz: male(kraut_netz, null, 1)   # Schablone 1 wie Blueten: ohne Bildschirmlinie
	baue_gruppen(netz)
	schlagbaum(karte.flaggen.has("barrier_open"))
	var wiese := MeshInstance3D.new()          # Waldboden ausserhalb der Karte: Bodenmaske am Rand fortgesetzt
	var pm := PlaneMesh.new()
	pm.size = Vector2(160, 160)
	wiese.mesh = pm
	wiese.material_override = boden
	if info.get("innen", false):               # 399.1 Grundriss (raum.py): ringsum schwarz
		var schwarz := StandardMaterial3D.new()
		schwarz.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		schwarz.albedo_color = Color.BLACK
		wiese.material_override = schwarz
	wiese.layers = BODEN_SCHICHT
	wiese.position = Vector3(karte.breite * Karte.TS / 2, -0.4, karte.hoehe * Karte.TS / 2)   # unter dem Flussbett (-0,34): auf -0,03 deckte sie das Wasser (-0,1) zu
	add_child(wiese)
	if info.get("innen", false):               # 399.5 Grundriss: Kamin, Kerzen, Tageslicht, Waende nach der Kamera (raumlicht.gd)
		raumlicht = Raumlicht.baue(self, info, netz)
		add_child(raumlicht)
	else: baue_lampen()
	baue_leben()
	insel_ohne = insel_liste
	bereit = true
	effekte_neu()

# 814: Effekte der Szene 1 nach DorfEffekte.an (Grafikstufe 698, Testmenue); aus: unser Rauch und die Lichtinseln wie vorher
func effekte_neu() -> void:
	var soll := DorfEffekte.aktiv() and DorfEffekte.fuer(karte.id)
	if soll and effekte == null:
		effekte = DorfEffekte.new(self)
		add_child(effekte)
		effekte.nacht_k = nacht_jetzt
		effekte.baue()
	elif not soll and effekte:
		effekte.queue_free()
		effekte = null
		for r in rauch: r.visible = true
		inseln_setzen(insel_ohne)

## 814: eine Lichtinsel dazu (Boden, Gras, Wasser malen sie selbst, BODEN_SCHICHT)
func insel_dazu(i: Vector4) -> void:
	var neu := insel_liste.duplicate()
	neu.append(i)
	inseln_setzen(neu.slice(0, 64))

func inseln_setzen(inseln: PackedVector4Array) -> void:
	insel_liste = inseln
	for m in [boden, halme, wasser, korn_mat]:
		if m:
			m.set_shader_parameter("inseln", inseln)
			m.set_shader_parameter("inseln_n", inseln.size())

# 1022 Kartenrand (Chef 12.11., 08:26; alt MapEdge, 27m; ersetzt 490 baue_dunkel, das nur den Waldboden abdunkelte und nur im Wald):
# hinter dem Waldring (dorf.py, sechs Reihen auf jeder Seite) laeuft alles ins Dunkel, Boden, Wasser, Baeume, im Dorf wie im Wald
# (toon, boden, wasser: rand_licht). Grundrisse haben keinen Rand (ringsum schwarz)
func rand_karte() -> Vector3:
	if info.get("innen", false): return Vector3.ZERO
	return Vector3(karte.breite * Karte.TS, karte.hoehe * Karte.TS, 1.0)

# Blender-Datei je Karte; weitere Gebietskarten kommen nach der Bestandsliste (348.8)
static func datei(id: String) -> String:
	return {"village": "dorf"}.get(id, id)

# 490: Bodenmaske je Karte (dorf.py MASKE): das Dorf hat boden-maske, jede weitere <karte>-boden-maske
static func maske(id: String) -> String:
	return "boden-maske" if id == "village" else id + "-boden-maske"

# 574 (Laufprotokoll Build 257: „Condition "buffer_size == 0" is true“ = ein Bild aus leeren Bytes): nur laden, was es gibt
static func maske_bild(id: String) -> Image:
	var p := "res://daten/%s.bild" % maske(id)
	if not FileAccess.file_exists(p): return null
	var img := Image.new()
	return img if img.load_png_from_buffer(FileAccess.get_file_as_bytes(p)) == OK else null

static func lade_glb(p: String) -> Node3D:
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_buffer(entschluessele(FileAccess.get_file_as_bytes(p), p), "", state)
	if err != OK: push_error("glTF %s: %d" % [p, err])
	return doc.generate_scene(state) as Node3D

# 348.12i: gekaufte Modelle liegen verschluesselt im APK (tools/blender348/verschluesseln.sh: „BKV1“, IV, AES-256-CBC mit PKCS7)
static func entschluessele(b: PackedByteArray, p: String) -> PackedByteArray:
	if b.size() < 36 or b.slice(0, 4).get_string_from_ascii() != "BKV1": return b
	if Schluessel.KAUF.length() != 64 or (b.size() - 20) % 16 != 0:
		push_error("verschluesselt, ohne Schluessel: %s" % p)
		return PackedByteArray()
	var aes := AESContext.new()
	aes.start(AESContext.MODE_CBC_DECRYPT, Schluessel.KAUF.hex_decode(), b.slice(4, 20))
	var d := aes.update(b.slice(20))
	aes.finish()
	var pad := d[d.size() - 1]
	if pad < 1 or pad > 16:
		push_error("falscher Schluessel: %s" % p)
		return PackedByteArray()
	return d.slice(0, d.size() - pad)

# 397 (Chef 28.10., 11:15: Ruhebewegungen wie im alten Spiel, mindestens drei): wer steht, spielt Stehen zwei- bis viermal, dann
# eine der anderen Ruhebewegungen (geruest.py RUHE, aus der UAL Pro) einmal, dann wieder Stehen; ohne die Kaufbewegungen nur Stehen.
# Gibt [Name, Dauer in s] der naechsten zurueck
# 592 (Chef 05.11., 22:0x: „592 so“): Stehen_3 (Idle_Tired, vornueber gebeugt) ist keine Ruhebewegung mehr, nur noch atemlos
# (held.gd ATEM_HALT); es bleiben Stehen und Umsehen
const RUHE := ["Stehen", "Stehen_2"]
static func ruhe_naechste(anim: AnimationPlayer, jetzt: String, z: RandomNumberGenerator) -> Array:
	var da := RUHE.filter(func(n): return anim.has_animation(n))
	if jetzt != "Stehen" or da.size() < 2: return ["Stehen", anim.get_animation("Stehen").length * z.randi_range(2, 4)]
	var n: String = da[z.randi_range(1, da.size() - 1)]
	return [n, anim.get_animation(n).length]

# 453.2 (Chef 01.11., 13:0x, Archiv 453.1: „aufs ganze Spiel übertragen … als ob die Leute halt wirklich leben“): Held und Leute atmen
# als eigene Schicht wie Held und Soeldner im Kampfort (kampf/atem.gd, Tuffy 453.1, dieselbe Datei): ruhig, je Figur eigener Takt und
# Versatz (seed), nach Anstrengung schneller und abklingend. Die Ruhe der UAL (Idle_Loop = Stehen) atmet selbst zweimal in 2,5 s und bei
# allen im selben Takt: in ATEM_RUHE bleibt darum ihr erstes Bild stehen (wie figur.gd _ohne_atem), nur die Schicht atmet; Stehen_2,
# Stehen_3 (Umsehen, Muede) bleiben. Ohne UAL-Geruest (Dorftiere, altes Modell) kein Atem, Rueckgabe null.
const ATEM_RUHE := ["Stehen", "Stehen_Fackel"]
static func atem_an(modell: Node3D, anim: AnimationPlayer, seed: int) -> Node:
	var sk := finde(modell, "Skeleton3D") as Skeleton3D
	if sk == null or anim == null or OS.get_environment("ATEM_ALT") != "": return null   # ATEM_ALT=1: wie vorher (Vergleich)
	for k in ["spine_02", "spine_03", "clavicle_l", "clavicle_r", "upperarm_l", "upperarm_r"]:
		if sk.find_bone(k) < 0: return null
	for n in ATEM_RUHE:
		if not anim.has_animation(n): continue
		var a := anim.get_animation(n)
		for t in a.get_track_count():
			var ty := a.track_get_type(t)
			if ty != Animation.TYPE_ROTATION_3D and ty != Animation.TYPE_POSITION_3D: continue
			while a.track_get_key_count(t) > 1: a.track_remove_key(t, a.track_get_key_count(t) - 1)
	var atem = load("res://kampf/atem.gd").new()
	atem.name = "Atem"
	atem.eigen(seed)
	sk.add_child(atem)
	return atem

# 348.6 (Helfer: Held stand nachts nach dem Rennen gegraetscht; Chef 18:20 „glitscht … und zuckt“): beim Laden verwirft Godot
# Spuren von Knochen, die in einer Bewegung ruhen (Stehen hat keine Beine); beim Wechsel blieben sie in der Pose der Bewegung
# davor stehen. Jede Bewegung bekommt fuer jeden fehlenden Knochen eine Spur mit der Ruhepose, dazu Schleife
static func bewegungen(anim: AnimationPlayer, schleifen: Array) -> void:
	var sk := finde(anim.get_parent(), "Skeleton3D") as Skeleton3D
	if sk == null: sk = finde(anim.get_parent().get_parent(), "Skeleton3D") as Skeleton3D
	for n in anim.get_animation_list():
		var a := anim.get_animation(n)
		if n in schleifen: a.loop_mode = Animation.LOOP_LINEAR
		if sk == null: continue
		var pfad := String(anim.get_node(anim.root_node).get_path_to(sk))
		var hat := {}
		for t in a.get_track_count():
			hat["%d:%s" % [a.track_get_type(t), String(a.track_get_path(t)).get_slice(":", 1)]] = true
		for b in sk.get_bone_count():
			var bn := sk.get_bone_name(b)
			var rest := sk.get_bone_rest(b)
			if not hat.has("%d:%s" % [Animation.TYPE_ROTATION_3D, bn]):
				var t := a.add_track(Animation.TYPE_ROTATION_3D)
				a.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
				a.rotation_track_insert_key(t, 0.0, rest.basis.get_rotation_quaternion())
			if not hat.has("%d:%s" % [Animation.TYPE_POSITION_3D, bn]):
				var t := a.add_track(Animation.TYPE_POSITION_3D)
				a.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
				a.position_track_insert_key(t, 0.0, rest.origin)

static func finde(n: Node, cls: String) -> Node:
	if n.get_class() == cls: return n
	for c in n.get_children():
		var r := finde(c, cls)
		if r: return r
	return null

static func bild(name: String) -> ImageTexture:
	if texcache.has(name): return texcache[name]
	var img := Image.new()
	var p := "res://daten/%s.bild" % name
	if not FileAccess.file_exists(p) or img.load_png_from_buffer(FileAccess.get_file_as_bytes(p)) != OK:   # 574: fehlt es, weiss statt Fehler
		push_warning("Gebiet.bild: %s fehlt" % p)
		img = Image.create(4, 4, false, Image.FORMAT_RGBA8); img.fill(Color.WHITE)
	if not img.has_mipmaps(): img.generate_mipmaps()
	var t := ImageTexture.create_from_image(img)
	texcache[name] = t
	return t

# 680 (Chef 08.11., 16:16: Wald -> Dorf -> Schenke immer zaeher, dann Absturz ohne Fehlerzeile): mip legte jedes Bild unter dem
# Bildobjekt des glTF ab, das bei jedem Laden neu ist, und hielt beide fuer immer fest; je Ortswechsel blieben Karte, Held und Leute
# im Speicher (sprung_680: je Runde Wald, Dorf, Schenke rund 105 MB mehr). Jetzt nur schwach gemerkt: dasselbe Bild in mehreren
# Materialien eines Ladens bleibt eins, mit dem Ort geht es
static var mipcache := {}   # Kennung des glTF-Bilds -> WeakRef auf das Bild mit Mipmaps

static func mip(t: Texture2D) -> Texture2D:
	# Bilder aus dem glTF bekommen Mipmaps (sonst flimmern Muster in der Ferne)
	if t == null: return null
	var id := t.get_instance_id()
	if mipcache.has(id):
		var alt = (mipcache[id] as WeakRef).get_ref()
		if alt: return alt
	var img := t.get_image()
	if img == null: return t
	if img.is_compressed(): img.decompress()
	if not img.has_mipmaps(): img.generate_mipmaps()
	var r := ImageTexture.create_from_image(img)
	mipcache[id] = weakref(r)
	return r

static func mip_aufraeumen() -> void:   # 680: Eintraege, deren Bild schon frei ist
	for id in mipcache.keys():
		if (mipcache[id] as WeakRef).get_ref() == null: mipcache.erase(id)

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
			if g: m.set_shader_parameter("rand_karte", g.rand_karte())   # 1022: vor durchsicht (kette nimmt ihn mit)
			if g and nm.contains("Boden"):
				m.shader = load("res://shader/boden.gdshader")
				m.set_shader_parameter("maske", bild(maske(g.karte.id)))
				for k in ["gras", "erde", "pflaster"]: m.set_shader_parameter(k, bild(k))
				m.set_shader_parameter("karte", Vector2(g.karte.breite, g.karte.hoehe) * Karte.TS)
				g.boden = m
				mi.layers = BODEN_SCHICHT
			elif g and nm.contains("Wasser"):
				m.shader = load("res://shader/wasser.gdshader")
				m.set_shader_parameter("maske", bild(maske(g.karte.id)))   # Alpha: Wassertiefe (dorf.py)
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
				if rn.begins_with("glut"):   # 490 Glut im Lagerfeuer: leuchtet von selbst, nachts staerker (nacht())
					m.set_shader_parameter("glow", 0.6)
					m.set_shader_parameter("glow_col", Vector3(1.0, 0.45, 0.15))
					if g: g.glut.append(m)
			mi.set_surface_override_material(i, m)
	for c in n.get_children(): male(c, g, mark, aus)

var nacht_jetzt := 0.0
func nacht(k: float) -> void:
	nacht_jetzt = k
	if effekte: effekte.nacht(k)
	if raumlicht: raumlicht.nacht(k)
	# 348.9: nachts wie alt geeicht (Laternen, Fenster, Lichtinseln am Boden kleiner; alt p90 46)
	for o in lampen: o.light_energy = 1.4 * k   # 348.6: alt nur ein kleiner Hof um die Laterne (Helfer: neu 4-mal zu hell, zu weit)
	for m in glut: m.set_shader_parameter("glow", 0.35 + 0.65 * k)
	for f in feuer: f["basis"] = 0.5 + 1.6 * k   # 490: Garricks Feuer, nachts die einzige warme Insel (LISTE-UMZUG-348 Stimmung)
	for m in glas:
		m.set_shader_parameter("glow", 0.5 * k)
		glanz_kette(m)
	if wasser: wasser.set_shader_parameter("night", k)
	if boden: boden.set_shader_parameter("night", k)
	if halme: halme.set_shader_parameter("night", k)
	if korn_mat: korn_mat.set_shader_parameter("night", k)
	for f in falter: (f["n"] as Node3D).visible = k < 0.5
	if gluehwuermchen: gluehwuermchen.nacht = k
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
		for k in ["tex", "sway", "cut_ab", "kontur", "licht_dir", "glow", "glow_col", "rand_karte"]:
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
		if String(karte.daten.get("art", "")) == "FOREST": x.set_shader_parameter("cut_weit", 1.3)   # 491 (353a): Held ganz zu sehen
		laub.append(x)
		x = x.next_pass as ShaderMaterial

func nah(_an: bool, held_pos: Vector3) -> void:
	for m in laub: m.set_shader_parameter("cut_pos", held_pos + Vector3(0, 0.9, 0))

# ---------------------------------------------------------------- Durchsicht als Ganzes (DESIGN-STIL „Karte und Raeume“, alt WorldScreen.hides)
# Haus, Stand, Brunnen, Laterne, Schild: verdeckt das Ding den Oberkoerper des Helden (Strahlen von Huefte bis Kopf zur Kamera),
# wird es als Ganzes halb durchsichtig, weich in 0,3 s; was nur bis zur Huefte reicht (Bank, Theke, Fass), bleibt deckend.
const DURCH_SCHICHT := 1 << 19         # nur fuer die Strahlen; der Held geht nach Karte.begehbar, nicht nach Koerpern
const DURCH_A := 0.5                   # alt: zusammen halb (Test 0.1.576: 0,2 zu stark; 27e.1: 35 % zu schwach)

# 530 (Chef 03.11., 23:40 „Schlagbaum öffnet sich nicht visuell“): der Balken ist zu oder steht offen aufrecht am Pfosten wie alt
# (MapTownIso.barrier open; dorf.py „Schlagbaum_zu_…“, „Schlagbaum_auf_…“); beim Laden und nach jeder neuen Flagge (spiel.gd flaggen_neu)
func schlagbaum(offen: bool) -> void:
	for n in find_children("Schlagbaum_*", "", true, false):
		var nm := String(n.name)
		if n is Node3D: (n as Node3D).visible = nm.begins_with("Schlagbaum_auf") == offen

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
					glanz_kette(m)
				elif a >= 1.0: m.next_pass = null
			var x := m
			while x:
				x.set_shader_parameter("weg", 1.0 if a < 1.0 else 0.0)
				x.set_shader_parameter("durch_a", a)
				x = x.next_pass as ShaderMaterial

# 608 (Chef 07.11., t268: „Pims Hütte am Tag, wenn sie transparent wird, … dann geht das Licht im Haus an“): die Durchgaenge der
# Durchsicht (kette) nahmen den Glanz der Fenster von dem Augenblick, als das Haus zum ersten Mal durchsichtig wurde; war das nachts,
# leuchteten sie am Tag weiter. Jetzt bekommt die Kette den Glanz des deckenden Durchgangs, beim Einhaengen und bei jedem Tageswechsel
static func glanz_kette(m: ShaderMaterial) -> void:
	var x := m.next_pass as ShaderMaterial
	while x:
		x.set_shader_parameter("glow", m.get_shader_parameter("glow"))
		x = x.next_pass as ShaderMaterial

# Blender (x, y Norden, z oben) -> Godot (x, y oben, z Sueden)
static func gpos(p: Array) -> Vector3:
	return Vector3(float(p[0]), float(p[2]), -float(p[1]))

const BODEN_SCHICHT := 2     # Boden nur im Licht der Sonne; Laternen und Fenster malen ihn selbst (boden.gdshader, inseln)
func baue_lampen() -> void:
	var inseln := PackedVector4Array()
	for l in info["lichter"]:
		var art: String = l["art"]
		if art == "feuer":   # 490 Lagerfeuer (dorf.py lagerfeuer): Licht flackert, Flammen und Rauch, Tag und Nacht
			var fq := gpos(l["pos"])
			inseln.append(Vector4(fq.x, fq.z, 3.2 * Karte.TS, 1.0))
			baue_feuer(fq)
			continue
		if art != "laterne" and art != "fenster": continue
		var q := gpos(l["pos"])
		if art == "fenster":   # wie MapLight WINDOW: vor dem Haus auf den Boden, Reichweite 1,6 Kacheln, Staerke 0,7
			inseln.append(Vector4(q.x, q.z + 0.5, 1.6 * Karte.TS, 0.7))
			tuschelicht(Vector3(q.x, maxf(q.y, 1.2), q.z + 0.3), 1.6 * Karte.TS, 0.6)   # 348.13b
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
		o.set_meta("reich", o.omni_range)   # 348.13b: Tusche nach der Laterne
		o.set_meta("kraft", 0.95)
		o.add_to_group("tuschelicht")
	inseln = inseln.slice(0, 64)
	for m in [boden, halme, wasser]:
		if m:
			m.set_shader_parameter("inseln", inseln)
			m.set_shader_parameter("inseln_n", inseln.size())
	insel_liste = inseln

# 348.13b: Ort eines Lichts ohne eigenes OmniLight3D (Fenster) fuer die Tusche (Kamera.tusche_lampen)
func tuschelicht(p: Vector3, reich: float, kraft: float) -> void:
	var o := Node3D.new()
	o.position = p
	o.set_meta("reich", reich)
	o.set_meta("kraft", kraft)
	o.add_to_group("tuschelicht")
	add_child(o)

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
	var mimg := Gebiet.maske_bild(karte.id)
	if mimg == null: return   # 574: Grundrisse (Schenke, Laden, Aeltester, Tempel) haben keine Bodenmaske und kein Gras
	var rng := RandomNumberGenerator.new(); rng.seed = 348
	var xf: Array[Transform3D] = []; var cu: Array[Color] = []
	var kxf: Array[Transform3D] = []; var kcu: Array[Color] = []
	var art := PackedByteArray()   # 804: je Halm 0 Wiese, 1 hohes Gras, 2 Blumenwiese (GrasBausatz)
	var wald := String(karte.daten.get("art", "")) == "FOREST"
	for r in karte.hoehe:
		for c in karte.breite:
			var t := karte.zeichen(Vector2i(c, r))
			var n := 0
			var korn := t == "c"
			var hoch := t == "," and wald   # 490 hohes Gras (Tile.TALL_GRASS) im Wald: dichter und hoeher, dort lauern Ratten und Woelfe
			if t == "." or t == "f": n = 9
			elif hoch: n = 22
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
				var s := rng.randf_range(0.16, 0.34) if not hoch else rng.randf_range(0.3, 0.5)
				var b := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s, s * (rng.randf_range(0.75, 1.2) if not hoch else rng.randf_range(1.3, 1.8)), s))
				xf.append(Transform3D(b, Vector3(x, 0.0, z)))
				art.append(1 if hoch else (2 if t == "f" else 0))
				var g := rng.randf_range(0.85, 1.2) * (0.8 if hoch else 1.0)
				cu.append(Color(0.95 * g, 1.0 * g, 0.85 * g, 1))
	halme = halm_netz(xf, cu, "halme", 0.0)
	halm_mmi = letztes_netz
	korn_mat = halm_netz(kxf, kcu, "korn", 1.0)
	for t in xf: kit_stellen.append(t.origin)
	kit_art = art
	gras_neu()
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
	gluehwuermchen = Gluehwuermchen.new(karte)   # 514: statt Teilchen nur an den Blumenbeeten („blumen“)
	add_child(gluehwuermchen)

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

var letztes_netz: MultiMeshInstance3D
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
	letztes_netz = mmi
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
	for f in feuer:   # 490: Flackern wie MapLight FIRE (zwei Wellen und Rauschen)
		var o: OmniLight3D = f["licht"]
		o.light_energy = float(f["basis"]) * (0.85 + 0.1 * sin(zeit * 9.0) + 0.07 * sin(zeit * 23.0 + 1.3) + 0.05 * randf())
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

# ---------------------------------------------------------------- 490 Lagerfeuer und Heilkraeuter
func baue_feuer(at: Vector3) -> void:
	var o := OmniLight3D.new()
	o.position = at + Vector3(0, 0.35, 0)
	o.omni_range = 4.5
	o.light_color = Color(1.0, 0.62, 0.3)
	o.omni_attenuation = 0.9
	o.light_cull_mask = 0xFFFFF & ~BODEN_SCHICHT
	o.shadow_enabled = false
	add_child(o)
	o.set_meta("reich", 3.2 * Karte.TS)
	o.set_meta("kraft", 1.0)
	o.add_to_group("tuschelicht")
	var fl := CPUParticles3D.new()   # Flammen: kurze, aufsteigende Funken in Orange bis Gelb, nach oben schmaler
	fl.amount = 26; fl.lifetime = 0.7; fl.preprocess = 1.0
	fl.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE; fl.emission_sphere_radius = 0.12
	fl.direction = Vector3.UP; fl.spread = 14.0; fl.gravity = Vector3(0, 0.6, 0)
	fl.initial_velocity_min = 0.35; fl.initial_velocity_max = 0.7
	fl.scale_amount_min = 1.6; fl.scale_amount_max = 2.6
	var cv := Curve.new(); cv.add_point(Vector2(0, 1.0)); cv.add_point(Vector2(1, 0.15)); fl.scale_amount_curve = cv
	var gr := Gradient.new(); gr.set_color(0, Color(1.0, 0.85, 0.45, 0.9)); gr.add_point(0.4, Color(1.0, 0.5, 0.15, 0.8)); gr.set_color(gr.get_point_count() - 1, Color(0.6, 0.15, 0.05, 0))
	fl.color_ramp = gr
	var qm := QuadMesh.new(); qm.size = Vector2(0.14, 0.18)
	qm.material = punkt_mat(true)
	fl.mesh = qm
	fl.position = at + Vector3(0, 0.08, 0)
	add_child(fl)
	var r := baue_rauch(at + Vector3(0, 0.5, 0))
	rauch.append(r)
	feuer.append({"licht": o, "flammen": fl, "rauch": r, "basis": 1.0})

## die Heilkraeuter von heute (spiel.gd kraut_da): je Kachel ein Kraut, etwas versetzt und gedreht; gepflueckte verschwinden
func zeige_kraeuter(da: Array[Vector2i]) -> void:
	for t in kraeuter.keys():
		if not t in da:
			(kraeuter[t] as Node).queue_free()
			kraeuter.erase(t)
	if kraut_netz == null: return
	for t in da:
		if kraeuter.has(t): continue
		var m := kraut_netz.duplicate() as MeshInstance3D
		var h := hash(t)
		m.position = karte.kachel_pos(t) + Vector3(((h & 255) / 255.0 - 0.5) * 0.4, 0.0, (((h >> 8) & 255) / 255.0 - 0.5) * 0.4)
		m.rotation.y = ((h >> 16) & 255) / 255.0 * TAU
		add_child(m)
		kraeuter[t] = m
