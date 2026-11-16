class_name KampfEffekte
extends RefCounted
# 806 (Chef 09.11., 21:12: „in den Kampforten … ganz anders gestalten und dass es besser ausschaut“; Zuordnung LISTE-EFFEKTE.md):
# zum Gras des Kits (804, GrasBausatz) ein flacher Bodennebel aus R8 Weather FX (nur der mist-Shader, ohne Wettersteuerung) und
# Lichtschächte mit Staub aus R7 (dust_motes) über der Lichtung. Gedämpft (Leitbild 1): Nebel graugrün und dünn, Staub golden
# (nur Gold glänzt), ohne die Punktlichter des Effekts (am Handy je Licht teuer). Die Pakete liegen nur im Bau (godot.yml „Effekt-Pakete“);
# fehlt eins, bleibt der Kampfort wie bisher. `an` ist der Schalter für die Grafikstufen (698), er gilt beim nächsten Aufbau.

const NEBEL := "res://addons/weather_fx/shaders_3d/mist.gdshader"
const STAUB := "res://addons/reeboo_vfx/effects/dust_motes.tscn"
const NEBEL_LAGEN := 4             # Kit: 12 Lagen; jede Lage deckt den ganzen Schirm (Bilder/s am Handy), vier reichen bis 1 m Höhe
const NEBEL_FARBE := Color(0.52, 0.57, 0.54, 1.0)

static var an := true

## Testmenü (806): ein Paket liegt im Bau, gleich ob der Schalter an ist
static func da() -> bool:
	return ResourceLoader.exists(NEBEL) or ResourceLoader.exists(STAUB)

static func da_nebel() -> bool:
	return an and ResourceLoader.exists(NEBEL)

static func da_staub() -> bool:
	return an and ResourceLoader.exists(STAUB)

## Bodennebel um die Kamera (der Shader legt die Lagen selbst um sie), Lagen bis `hoch` m über dem Boden
static func nebel(eltern: Node3D, hoch := 1.0, dichte := 0.55) -> MeshInstance3D:
	if not da_nebel():
		return null
	var ecken := PackedVector3Array()
	for i in NEBEL_LAGEN:
		var y := float(i) / float(NEBEL_LAGEN - 1)
		ecken.append_array([Vector3(-1, y, -1), Vector3(1, y, -1), Vector3(-1, y, 1), Vector3(1, y, 1)])
	var verts := PackedVector3Array()
	var uv := PackedVector2Array()
	var idx := PackedInt32Array()
	for q in ecken.size() / 4:
		var b := verts.size()
		for k in 4:
			verts.append(ecken[q * 4 + k])
		uv.append_array([Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)])
		idx.append_array([b, b + 1, b + 2, b + 1, b + 3, b + 2])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_TEX_UV] = uv
	arr[Mesh.ARRAY_INDEX] = idx
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var mi := MeshInstance3D.new()
	mi.name = "Bodennebel"
	mi.mesh = m
	mi.top_level = true
	mi.custom_aabb = AABB(Vector3(-100000, -100000, -100000), Vector3(200000, 200000, 200000))
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := ShaderMaterial.new()
	mat.shader = load(NEBEL)
	mat.set_shader_parameter("intensity", 1.0)
	mat.set_shader_parameter("density", dichte)
	mat.set_shader_parameter("color", NEBEL_FARBE)
	mat.set_shader_parameter("depth", hoch)
	mat.set_shader_parameter("radius", 40.0)
	mat.set_shader_parameter("wind", Vector3(0.25, 0.0, 0.1))
	mat.set_shader_parameter("ground", 0.0)
	mat.set_shader_parameter("scene_light", 1.0)
	mi.material_override = mat
	eltern.add_child(mi)
	return mi

## Lichtschacht mit Staub an `wo` (örtlich zu `eltern`), `gross` skaliert den Schacht; ohne das Punktlicht des Effekts
static func staub(eltern: Node3D, wo: Vector3, gross := 1.0) -> Node3D:
	if not da_staub():
		return null
	var fx := (load(STAUB) as PackedScene).instantiate() as Node3D
	fx.name = "Lichtschacht"
	# gleich weg, nicht queue_free: VFXEffect._ready merkt sich seine Lichter und flackerte sonst ein freigegebenes (SCRIPT ERROR)
	for l in fx.find_children("*", "Light3D", true, false):
		l.get_parent().remove_child(l)
		l.free()
	var schacht := fx.get_node_or_null("Shaft") as MeshInstance3D
	if schacht and schacht.material_override is ShaderMaterial:
		var sm := (schacht.material_override as ShaderMaterial).duplicate() as ShaderMaterial
		sm.set_shader_parameter("emission_energy", 0.14)     # Effekt 0,22: im Tageslicht der Lichtung sonst ein heller Zylinder
		schacht.material_override = sm
	fx.position = wo
	fx.scale = Vector3.ONE * gross
	eltern.add_child(fx)
	return fx
