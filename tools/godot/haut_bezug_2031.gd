extends SceneTree
# 2031 (Bild 22:53, Gesicht Orkbluetiger): Bezug der Toenung je MakeHuman-Hautbild neu, nachdem haut_mh_flecken.py die grossflaechige
# Helligkeit der Kaufhaut uebertragen hat. Wie haut_mh.py: Median der Bildfarbe an den Ecken des Kopfnetzes im Band unter den Augen
# (9 cm, vordere Haelfte), linear, mal heutiger Bezug (toen_bild) / Median heute im selben Band. Regular am Menschen, Superhero am Ork.
# Schreibt gesicht_srgb und gesicht_hell_linear in die .json neben dem Bild (Menschenkopf gilt fuer Kopf und Leib wie in haut_mh.py).
# Aufruf: godot --headless --path godot -s $PWD/tools/godot/haut_bezug_2031.gd
const MENSCH := {"m": ["MI_Regular_Male_haut", "MI_Regular_Male_RegularMale"], "w": ["MI_Regular_Female_haut", "MI_Regular_Female_Female_Regular"]}
func _initialize() -> void: _lauf.call_deferred()

func band(volk: String, g: String, kenn: String) -> Dictionary:   # Material -> [Median linear, toen_bild]
	HeldFigur.mh_haut = kenn
	var hw := BrsHeld.fuer_spiel("Test", "Mensch", "Wachsoldat")
	var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": volk, "aussehen": {"geschlecht": g}, "ausruestung": hw.ausruestung.duplicate()}, [])
	HeldFigur.mh_haut = ""
	var augen := Vector3.INF
	for x in m.find_children("Eyes*", "MeshInstance3D", true, false): augen = (x as MeshInstance3D).mesh.get_aabb().get_center()
	var aus := {}
	for x in m.find_children("*", "MeshInstance3D", true, false):
		var mi := x as MeshInstance3D
		if not (String(mi.name).contains("Regular") or String(mi.name).contains("Head")) or mi.mesh == null: continue
		for si in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(si)
			var rn := String(src.resource_name) if src else ""
			if not (rn.contains("Regular") or rn.contains("Superhero")): continue
			var sm := mi.get_surface_override_material(si) as ShaderMaterial
			var im := (sm.get_shader_parameter("tex") as Texture2D).get_image()
			if im.is_compressed(): im.decompress()
			var a := mi.mesh.surface_get_arrays(si)
			var vs: PackedVector3Array = a[Mesh.ARRAY_VERTEX]; var uv: PackedVector2Array = a[Mesh.ARRAY_TEX_UV]
			var mz := 0.0
			for v in vs: mz += v.z
			mz /= vs.size()
			var vorn := signf(augen.z - mz)
			var k := [[], [], []]
			for i in vs.size():
				if vs[i].y > augen.y or vs[i].y < augen.y - 0.09 or (vs[i].z - mz) * vorn < 0.0: continue
				var c := im.get_pixel(clampi(int(uv[i].x * im.get_width()), 0, im.get_width() - 1), clampi(int(uv[i].y * im.get_height()), 0, im.get_height() - 1)).srgb_to_linear()
				k[0].append(c.r); k[1].append(c.g); k[2].append(c.b)
			for q in 3: (k[q] as Array).sort()
			if not (k[0] as Array).is_empty():
				aus[rn.get_basename() if rn.get_extension().is_valid_int() else rn] = [Vector3(k[0][k[0].size() / 2], k[1][k[1].size() / 2], k[2][k[2].size() / 2]), sm.get_shader_parameter("toen_bild"), (k[0] as Array).size()]
	m.free()
	return aus

func _lauf() -> void:
	for g in ["m", "w"]:
		for volk in ["HUMAN", "HALF_ORC"]:
			var heute := band(volk, g, "")
			for kenn in HeldFigur.MH_HAUT_WAHL[g.to_upper()]:
				var neu := band(volk, g, kenn)
				for rn in neu:
					if not heute.has(rn) and heute.size() != 1: continue
					var h: Array = heute[rn] if heute.has(rn) else heute.values()[0]
					var G: Vector3 = (neu[rn][0] as Vector3) * (h[1] as Vector3) / Vector3(maxf(h[0].x, 1e-4), maxf(h[0].y, 1e-4), maxf(h[0].z, 1e-4))
					var gs: Color = Color(G.x, G.y, G.z).linear_to_srgb()
					var namen: Array = [rn] if rn.contains("Superhero") else MENSCH[g]
					for n in namen:
						var p := ProjectSettings.globalize_path(HeldFigur.MH_HAUT_ORT % [kenn, n]) + ".json"
						if not FileAccess.file_exists(p): continue
						var j: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(p))
						j["gesicht_srgb"] = [snappedf(gs.r, 0.0001), snappedf(gs.g, 0.0001), snappedf(gs.b, 0.0001)]
						j["gesicht_hell_linear"] = snappedf(0.2126 * G.x + 0.7152 * G.y + 0.0722 * G.z, 0.0001)
						j["gesicht_ecken"] = neu[rn][2]
						j["bezug"] = "tools/godot/haut_bezug_2031.gd nach haut_mh_flecken.py (Bild 22:53)"
						var f := FileAccess.open(p, FileAccess.WRITE); f.store_string(JSON.stringify(j, " ")); f.close()
						print("BEZUG %s %s %s G %s" % [kenn, volk, n, j["gesicht_srgb"]])
	quit(0)
