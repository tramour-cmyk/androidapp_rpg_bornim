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

static var an := true

static func da() -> bool:
	return ResourceLoader.exists(KIT + "presets/grass_summer.tres") and ResourceLoader.exists(KIT + "meshes/grass_clump_medium.res") \
		and ResourceLoader.exists(KIT + "wind/grass_wind.gd")

static func aktiv() -> bool:
	return an and da()

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
static func baue(eltern: Node3D, stellen: Array[Vector3], art: PackedByteArray) -> Array[MultiMeshInstance3D]:
	var rng := RandomNumberGenerator.new(); rng.seed = 804
	var gruppen := {"grass_clump_short": [], "grass_clump_medium": [], "grass_clump_tall": []}
	for b in BLUMEN: gruppen[b] = []
	for i in stellen.size():
		var p := stellen[i]
		var a := art[i]
		var blume := (a == 2 and rng.randf() < 0.3) or (a == 0 and rng.randf() < 0.015)
		if blume:
			gruppen[BLUMEN[rng.randi() % BLUMEN.size()]].append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(0.8, 1.1)), p))
			continue
		if i % JE != 0: continue
		var n := "grass_clump_tall" if a == 1 else ("grass_clump_short" if rng.randf() < 0.45 else "grass_clump_medium")
		var s := rng.randf_range(0.85, 1.15)
		gruppen[n].append(Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3(s, s * rng.randf_range(0.85, 1.15), s)), p))
	var gras := stoff("grass_summer")
	var blumen := [stoff("flower_summer"), stoff("flower_spring")]
	var aus: Array[MultiMeshInstance3D] = []
	var k := 0
	for n in gruppen:
		var xf: Array = gruppen[n]
		var m := netz(n)
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
		if n.begins_with("flower"):
			mmi.material_override = blumen[k % 2]; k += 1
		else:
			mmi.material_override = gras
		eltern.add_child(mmi)
		aus.append(mmi)
	return aus

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
