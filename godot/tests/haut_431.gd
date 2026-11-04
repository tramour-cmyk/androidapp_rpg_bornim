extends SceneTree
# 431c B1 (Pruefer Lauf 41439148830: Voelker kreideweiss, Ork mint, Waesche weiss) ohne Bild: die Rechnung aus den GLB
# (tools/blender348/v3/voelker_haut_rechnung.py, Lauf 41470003579) ergibt mit dem Hautbild gesunde Toene; dieselbe Formel mit Weiss
# als Bildwert ergibt genau Weiss und Mint. Hier: welches Bild der Toon-Shader je Flaeche wirklich bekommt, wie in voelkerprobe.gd
# (Gebiet.lade_glb, Gebiet.male), und ob UV und Farbe da sind. Kein Bild, kein Rendern.
#   VOELKER=<ordner mit volk_*.glb> godot --headless --path godot -s res://tests/haut_431.gd
func _init() -> void:
	var dir := OS.get_environment("VOELKER")
	var namen: Array = Array(DirAccess.get_files_at(dir)).filter(func(n): return n.begins_with("volk_") and n.ends_with(".glb"))
	if namen.is_empty(): print("HAUT431 FEHLT volk_*.glb unter ", dir)
	var weiss: Variant = Gebiet.bild("weiss") if FileAccess.file_exists("res://daten/weiss.bild") else null
	# zum Vergleich der Held (im Spiel nicht weiss): erste held_*.bin aus godot/daten
	var held: Array = Array(DirAccess.get_files_at("res://daten")).filter(func(x): return x.begins_with("held_") and x.ends_with(".bin")) if DirAccess.dir_exists_absolute("res://daten") else []
	if not held.is_empty(): namen.append("res://daten/" + String(held[0]))
	for n in namen:
		var m := Gebiet.lade_glb(n if n.begins_with("res://") else dir.path_join(n))
		var mats := []
		Gebiet.male(m, null, 2, mats)
		var volk: String = {"mensch": "HUMAN", "elf": "ELF", "zwerg": "DWARF", "huegel": "HALFLING", "ork": "HALF_ORC"}.get(n.get_file().split("_")[1], "HUMAN")
		HeldFigur.toene(m, {"haut": 0, "haarfarbe": 0, "geschlecht": "w" if n.contains("frau") else "m"}, volk)
		var vj: Variant = JSON.parse_string(FileAccess.get_file_as_string(dir.path_join("voelker.json"))) if FileAccess.file_exists(dir.path_join("voelker.json")) else null
		var hb: Variant = null   # wie voelkerprobe.gd _eigene_haut
		if vj is Dictionary:
			for e in vj["voelker"]: if e["datei"] == n: hb = e.get("haut_bild")
		print("HAUT431 %s Volk %s, Hautton 0 %s, Held haut_bild %s, eigen %s, Eichung %s, Farbe %s" % [n, volk, HeldFigur.ton(volk, "haut", 0),
			HeldFigur.geschlecht_info("w" if n.contains("frau") else "m").get("haut_bild"), hb, HeldFigur.haut_eichung(), HeldFigur.haut_farbe()])
		for mi in m.find_children("*", "MeshInstance3D", true, false):
			var me := (mi as MeshInstance3D).mesh
			for i in me.get_surface_count():
				var src := me.surface_get_material(i)
				var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
				var t: Texture2D = sm.get_shader_parameter("tex") if sm else null
				var st: Texture2D = (src as BaseMaterial3D).albedo_texture if src is BaseMaterial3D else null
				print("HAUT431   Format: Quelle %s, Shader-Bild %s (Image.Format; RGB8=4, RGBA8=5, RGBH=14, RGBAH=15, RGBF=10, RGBAF=11)" % [
					(st as ImageTexture).get_format() if st is ImageTexture else "-", (t as ImageTexture).get_format() if t is ImageTexture else "-"])
				var arr := me.surface_get_arrays(i)
				var col: Variant = arr[Mesh.ARRAY_COLOR]
				var cmin := "ohne"
				if col is PackedColorArray and (col as PackedColorArray).size() > 0:
					var lo := Color(9, 9, 9, 9)
					for c in col as PackedColorArray: lo = Color(minf(lo.r, c.r), minf(lo.g, c.g), minf(lo.b, c.b), minf(lo.a, c.a))
					cmin = str(lo)
				var uv: Variant = arr[Mesh.ARRAY_TEX_UV]
				print("HAUT431 %s %s/%d Material %s: Quelle %s, Shader-Bild %s %s, gleich Quelle %s, Weiss %s, UV %s, Farbe min %s, albedo_color %s" % [
					n, mi.name, i, src.resource_name if src else "null",
					("%s %dx%d" % [st.get_class(), st.get_width(), st.get_height()]) if st else "keins",
					t.get_class() if t else "null", ("%dx%d" % [t.get_width(), t.get_height()]) if t else "",
					str(t == st), str(weiss != null and t == weiss),
					str((uv as PackedVector2Array).size()) if uv is PackedVector2Array else "fehlt", cmin,
					str((src as BaseMaterial3D).albedo_color) if src is BaseMaterial3D else "-"])
				if sm and hb is Array and (src.resource_name.contains("Regular") or src.resource_name.contains("Superhero")):
					sm.set_shader_parameter("toen_bild", HeldFigur._lin(hb))
					sm.set_shader_parameter("toen_hell", HeldFigur._hell(hb))
				if sm: print("HAUT431   Shader %s: toenung %s, toen_bild %s, toen_hell %s, toen_farbe %s, fill %s, metall %s" % [
					sm.shader.resource_path if sm.shader else "null", sm.get_shader_parameter("toenung"), sm.get_shader_parameter("toen_bild"),
					sm.get_shader_parameter("toen_hell"), sm.get_shader_parameter("toen_farbe"), sm.get_shader_parameter("fill"), sm.get_shader_parameter("metall")])
		m.free()
	quit()
