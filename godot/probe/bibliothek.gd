extends RefCounted
# 431, 416.4 (Tom 01.11.): Modelle der Bibliothek (Quaternius CC0, gekaufte Pakete unter KAUF; 408) zur Laufzeit laden, ohne Import.
# Die glTF der Universal Base Characters verweisen auf Bilder, die so nicht neben ihnen liegen („T_Hair_1_Normal_png.png“ statt
# ../Textures/T_Hair_1_Normal.png; Godot 4.7.2 stuerzt dann ab): Verweise vor dem Laden auf die Datei gleichen Namens im Paket
# umbiegen, was fehlt, wird ein graues Bild.

static var _bilder := {}   # Dateiname klein -> Pfad
static var _wurzeln := {}


static func dateien(wurzeln: Array, endung: String) -> Array:
	var aus := []
	for w in wurzeln:
		if w != "" and DirAccess.dir_exists_absolute(w): _sammle(w, endung, aus)
	aus.sort()
	return aus


static func _sammle(d: String, endung: String, aus: Array) -> void:
	for f in DirAccess.get_files_at(d):
		if f.to_lower().ends_with(endung): aus.append(d.path_join(f))
	for u in DirAccess.get_directories_at(d):
		if not u.begins_with("."): _sammle(d.path_join(u), endung, aus)


# 457.1 (Chef 01.11., 11:49: „unsere Signatur muss sich wiederfinden“): jedes geladene Modell standardmaessig mit dem Toon-Zeichner des
# Spiels (Gebiet.male, Schablone 2 wie der Held: feinere Tusche, Licht nach Licht.richtung); ohne nur mit --ohnetoon oder toon=false
static func spielbild(n: Node3D) -> Node3D:
	if n == null or "--ohnetoon" in OS.get_cmdline_user_args(): return n
	var mats := []
	Gebiet.male(n, null, 2, mats)
	for m in mats:
		(m as ShaderMaterial).set_shader_parameter("metall", 1.0)
		(m as ShaderMaterial).set_shader_parameter("licht_dir", Licht.richtung())
	return n


# wurzel: Paketordner, in dem die Bilder gesucht werden
static func lade(pfad: String, wurzel: String, toon := true) -> Node3D:
	var n := _lade(pfad, wurzel)
	return spielbild(n) if toon else n


static func _lade(pfad: String, wurzel: String) -> Node3D:
	var d := GLTFDocument.new()
	var s := GLTFState.new()
	if pfad.ends_with(".glb"):
		return d.generate_scene(s) if d.append_from_file(pfad, s) == OK else null
	if not _wurzeln.has(wurzel):
		_wurzeln[wurzel] = true
		for p in dateien([wurzel], ".png"): _bilder.get_or_add(p.get_file().to_lower(), p)
	var j: Variant = JSON.parse_string(FileAccess.get_file_as_string(pfad))
	if not j is Dictionary: return null
	var grau := OS.get_cache_dir().path_join("bornim_grau.png")
	if not FileAccess.file_exists(grau):
		var im := Image.create(2, 2, false, Image.FORMAT_RGB8)
		im.fill(Color(0.5, 0.5, 0.5))
		im.save_png(grau)
	for b in j.get("images", []):
		var uri: String = b.get("uri", "")
		if uri == "" or uri.begins_with("data:") or FileAccess.file_exists(pfad.get_base_dir().path_join(uri)): continue
		var n := uri.get_file().to_lower()
		b["uri"] = _relativ(pfad.get_base_dir(), _bilder.get(n, _bilder.get(n.replace("_png.png", ".png"), grau)))
	# base_path: Godot nimmt davon den Ordner, also die Datei selbst
	if d.append_from_buffer(JSON.stringify(j).to_utf8_buffer(), pfad, s) != OK: return null
	return d.generate_scene(s)


# GLTFDocument haengt jeden Bildverweis an den Ordner der Datei, auch einen absoluten
static func _relativ(von: String, nach: String) -> String:
	var a := von.simplify_path().split("/", false)
	var b := nach.simplify_path().split("/", false)
	var i := 0
	while i < mini(a.size(), b.size()) and a[i] == b[i]: i += 1
	var teile: Array[String] = []
	for k in a.size() - i: teile.append("..")
	for k in range(i, b.size()): teile.append(b[k])
	return "/".join(teile)


static func skelett(n: Node) -> Skeleton3D:
	var l := n.find_children("*", "Skeleton3D", true, false)
	return l[0] if not l.is_empty() else null


static func spieler(n: Node) -> AnimationPlayer:
	var l := n.find_children("*", "AnimationPlayer", true, false)
	return l[0] if not l.is_empty() else null


# Bewegung der UAL auf eine Figur gleichen Geruests (65 Knochen, gleiche Namen): Spuren auf deren Skelett umschreiben; Lagen nur fuer
# Becken und Wurzel, damit die Knochenlaengen der Figur bleiben. Die Beckenlage der Quelle (Puppe der UAL) passt nur zu deren
# Beinlaenge: mit dem Verhaeltnis der Beckenhoehen in Ruhe skaliert (Helfer 01.11., Film 431: Erwachsene 4 cm im Boden,
# Jugend 10 cm darueber, weil die Lage der Puppe unveraendert galt)
static func bewegung(figur: Node3D, quellen: Dictionary, quelle_sk: Skeleton3D = null) -> AnimationPlayer:
	var sk := skelett(figur)
	var k := 1.0
	if quelle_sk:
		var pq := quelle_sk.find_bone("pelvis")
		var pz := sk.find_bone("pelvis")
		if pq >= 0 and pz >= 0 and quelle_sk.get_bone_global_rest(pq).origin.y > 0.01:
			k = sk.get_bone_global_rest(pz).origin.y / quelle_sk.get_bone_global_rest(pq).origin.y
	var weg := str(figur.get_path_to(sk))
	var lib := AnimationLibrary.new()
	for name in quellen:
		var a := (quellen[name] as Animation).duplicate(true) as Animation
		for i in range(a.get_track_count() - 1, -1, -1):
			var knochen := a.track_get_path(i).get_concatenated_subnames()
			if knochen == "" or sk.find_bone(knochen) < 0: a.remove_track(i); continue
			if a.track_get_type(i) == Animation.TYPE_POSITION_3D and not knochen in ["pelvis", "root"]: a.remove_track(i); continue
			a.track_set_path(i, NodePath(weg + ":" + knochen))
			if a.track_get_type(i) == Animation.TYPE_POSITION_3D and k != 1.0:
				for j in a.track_get_key_count(i): a.track_set_key_value(i, j, (a.track_get_key_value(i, j) as Vector3) * k)
		a.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation(name, a)
	var ap := AnimationPlayer.new()
	figur.add_child(ap)
	ap.add_animation_library("", lib)
	return ap
