class_name GrasBausatz
extends RefCounted
# 804 (Chef 09.11., 21:12: „Rein damit.“; Probe 623.6, Chef 07.11.: „sah schon wirklich sehr gut aus“): Gras und Blumen aus dem
# Grass & Wind Kit v1.0.1 (REEBOO, gekauft) statt halm.gdshader, an denselben Stellen wie unser Gras (gebiet.gd baue_leben): Bueschel
# kurz und mittel auf der Wiese, hoch im hohen Gras des Walds, Blumen auf den Blumenwiesen („f“) und vereinzelt auf der Wiese; ein Wind
# fuer alles (Autoload GrassWind), der Held schiebt das Gras beiseite (WindPusher3D). Farben gedaempft (Leitbild 1).
# Das Kit liegt nur im Bau (godot.yml „Gras-Kit“, Lizenz: nie ins Repo); fehlt es, bleibt unser Gras. `an` ist der Schalter fuer die
# Grafikstufen (698) und das Testmenue; er gilt beim naechsten Aufbau eines Orts.

const KIT := "res://addons/grass_wind_kit/"
const JE := 3                         # jede dritte Stelle unseres Grases traegt einen Bueschel (Probe 623.6: jede vierte, dort lueckig am Weg)
const SATT := 0.62                    # Leitbild 1: Saettigung der Vorlagen, gedaempft
const HELL := 0.82                    # Helligkeit der Vorlagen
const FARBEN := ["base_color", "tip_color", "patch_color", "dry_tip_color", "stem_color", "petal_color_a", "petal_color_b",
	"petal_inner_color", "center_color"]
const BLUMEN := ["flower_daisy", "flower_cluster", "flower_lavender", "flower_tulip"]
# 1205 (Chef 13.11., 18:48: „verschiedene Grass Blade Single, Clump Short, Clump Medium, Clump Chunky und Clump Tall … viel mehr Varianz
# in unsere Wiesen“): Büschel je Boden nach Anteil [Netz, Anteil]; vorher Wiese kurz 45 % / mittel 55 %, hohes Gras nur „tall“
const WIESE := [["grass_clump_short", 0.38], ["grass_clump_medium", 0.34], ["grass_clump_chunky", 0.16], ["grass_blade_single", 0.12]]
const HOCH := [["grass_clump_tall", 0.7], ["grass_clump_chunky", 0.2], ["grass_blade_single", 0.1]]
# 1205: Blumenwiese („f“) dichter, seit die gezeichneten Blüten aus dorf.py bei stehendem Kit nichts mehr zeichnen (gebiet.gd gras_neu);
# vorher 0,3
const BLUMEN_WIESE := 0.5
const WIESE_VORHER := [["grass_clump_short", 0.45], ["grass_clump_medium", 0.55]]
const HOCH_VORHER := [["grass_clump_tall", 1.0]]
# 1205a A (Chef 17.11., 15:35: „1205a A, gerne auch mehr Gras?!?“): Blumen des Kits etwa doppelt so groß, in den Farben der
# gezeichneten Blüten (dorf.py flowers) statt gedämpft, je Blumenart eine oder zwei Farben (je Farbe ein Netz); Gras dichter (JE_NEU)
# 1205 (Chef 17.11., 16:23: „ein bisschen zu groß … in Dorf … Faktor 1,2 bis 1,5 und vielleicht außerhalb 1,2 bis 1,8. Halt eine Mische“):
# je Blume gestreut, im Dorf kleiner; vorher 1,7–2,2 überall
const BLUMEN_GROESSE := Vector2(1.2, 1.8)
const BLUMEN_GROESSE_DORF := Vector2(1.2, 1.5)
const BLUMEN_FARBEN := {"flower_daisy": ["E8E0D0", "D8C050"], "flower_cluster": ["A84A6A"], "flower_lavender": ["8A6AB8"],
	"flower_tulip": ["C8603A", "A84A6A"]}
const JE_NEU := 2
static var vorher := false            # 1205: Bild an den Chef (tests/wiese_bild_1205.gd): Stand vor 1205, mit den gezeichneten Blüten

static func wahl(liste: Array, x: float) -> String:
	for n in liste:
		x -= float(n[1])
		if x < 0.0: return n[0]
	return liste[liste.size() - 1][0]

static var an := true

static func da() -> bool:
	return ResourceLoader.exists(KIT + "presets/grass_summer.tres") and ResourceLoader.exists(KIT + "meshes/grass_clump_medium.res") \
		and ResourceLoader.exists(KIT + "wind/grass_wind.gd")

static func aktiv() -> bool:
	return an and Grafik.kits() and da()   # 698: Niedrig ohne Kits

# Vorlage des Kits als eigene Kopie, Farben gedaempft, ohne Leuchten (nachts sonst gluehende Spitzen)
static func stoff(vorlage: String) -> ShaderMaterial:
	var m := (load(KIT + "presets/%s.tres" % vorlage) as ShaderMaterial).duplicate() as ShaderMaterial
	for k in FARBEN:
		var c = m.get_shader_parameter(k)
		if c is Color: m.set_shader_parameter(k, Color.from_hsv((c as Color).h, (c as Color).s * SATT, (c as Color).v * HELL, (c as Color).a))
	for k in ["tip_emission", "emission"]:
		if m.get_shader_parameter(k) != null: m.set_shader_parameter(k, 0.0)
	return m

static func netz(name: String) -> Mesh:
	var p := KIT + "meshes/%s.res" % name
	return load(p) as Mesh if ResourceLoader.exists(p) else null

# stellen: Fusspunkte unseres Grases; art je Stelle: 0 Wiese, 1 hohes Gras (Wald), 2 Blumenwiese. Gibt die neuen Knoten zurueck.
static func baue(eltern: Node3D, stellen: Array[Vector3], art: PackedByteArray, dorf := false) -> Array[MultiMeshInstance3D]:
	var rng := RandomNumberGenerator.new(); rng.seed = 804
	var gruppen := {}
	var wiese: Array = WIESE_VORHER if vorher else WIESE
	var hoch: Array = HOCH_VORHER if vorher else HOCH
	for n in wiese: gruppen[n[0]] = []
	for n in hoch: gruppen[n[0]] = []
	for b in BLUMEN:
		if vorher: gruppen[b] = []
		else:
			for f in BLUMEN_FARBEN[b]: gruppen[b + "#" + f] = []
	var je := JE if vorher else JE_NEU
	var gr := Vector2(0.8, 1.1) if vorher else (BLUMEN_GROESSE_DORF if dorf else BLUMEN_GROESSE)
	for i in stellen.size():
		var p := stellen[i]
		var a := art[i]
		var blume := (a == 2 and rng.randf() < (0.3 if vorher else BLUMEN_WIESE)) or (a == 0 and rng.randf() < 0.015)
		if blume:
			var b: String = BLUMEN[rng.randi() % BLUMEN.size()]
			if not vorher: b += "#" + String(BLUMEN_FARBEN[b][rng.randi() % BLUMEN_FARBEN[b].size()])
			gruppen[b].append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(gr.x, gr.y)), p))
			continue
		if i % je != 0: continue
		var n := wahl(hoch if a == 1 else wiese, rng.randf())
		var s := rng.randf_range(0.85, 1.15)
		gruppen[n].append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s, s * rng.randf_range(0.85, 1.15), s)), p))
	var gras := stoff("grass_summer")
	var blumen := [stoff("flower_summer"), stoff("flower_spring")]
	var aus: Array[MultiMeshInstance3D] = []
	var k := 0
	for n in gruppen:
		var xf: Array = gruppen[n]
		var m := netz(n.get_slice("#", 0))
		if xf.is_empty() or m == null: continue
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = m
		mm.instance_count = xf.size()
		for j in xf.size(): mm.set_instance_transform(j, xf[j])
		var mmi := MultiMeshInstance3D.new()
		mmi.name = "Gras_" + n
		mmi.multimesh = mm
		mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF   # wie unser Gras: empfaengt Schatten, wirft keinen
		if n.contains("#"):
			mmi.material_override = blume_farbig(blumen[k % 2], Color.html(n.get_slice("#", 1))); k += 1
		elif n.begins_with("flower"):
			mmi.material_override = blumen[k % 2]; k += 1
		else:
			mmi.material_override = gras
		eltern.add_child(mmi)
		aus.append(mmi)
	return aus

# 1205a: Blütenblätter in einer Farbe der gezeichneten Blüten (Rand etwas dunkler, innen heller), Stiel und Mitte bleiben gedämpft
static func blume_farbig(vorlage: ShaderMaterial, c: Color) -> ShaderMaterial:
	var m := vorlage.duplicate() as ShaderMaterial
	m.set_shader_parameter("petal_color_a", c)
	m.set_shader_parameter("petal_color_b", c.darkened(0.2))
	m.set_shader_parameter("petal_inner_color", c.lightened(0.25))
	return m

# Der Held schiebt das Gras beiseite (Kit: hoechstens vier Schieber); einmal je Held
static func schieber(held: Node3D) -> void:
	if held == null or held.has_node("GrasSchieber"): return
	var p := KIT + "wind/wind_pusher_3d.gd"
	if not ResourceLoader.exists(p): return
	var pu: Node3D = (load(p) as GDScript).new()
	pu.name = "GrasSchieber"
	pu.set("radius", 0.8)
	held.add_child(pu)

# MIT-Hinweis (David Hoskins, Hashfunktionen im Kit; LISTE-QUELLEN „Offene Lizenzfragen“ 2): Copyright-Zeile aus dem Bau
static func mit_zeile() -> String:
	var f := FileAccess.open("res://daten/gras_mit.txt", FileAccess.READ)
	return f.get_as_text().strip_edges() if f else ""
